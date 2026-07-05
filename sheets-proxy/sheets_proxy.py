import os
import sys
import json
import subprocess
import urllib.parse
from http.server import HTTPServer, BaseHTTPRequestHandler
import datetime
import google.auth
from google.oauth2 import service_account
from google.oauth2.credentials import Credentials
from googleapiclient.discovery import build

PORT = int(os.environ.get("PORT", 8080))
SPREADSHEET_ID = "1r4I_4NCkxpRCzfydGOcdcS-swOUwoT-b91CJpNvNg3Y"

def load_cleaned_service_account(path):
    with open(path, 'r', encoding='utf-8') as f:
        content = f.read()
    
    # Manual key extraction to completely bypass JSON parsing vulnerabilities
    info = {}
    keys = [
        "type", "project_id", "private_key_id", "private_key", 
        "client_email", "client_id", "auth_uri", "token_uri", 
        "auth_provider_x509_cert_url", "client_x509_cert_url", "universe_domain"
    ]
    
    for key in keys:
        key_pattern = f'"{key}":'
        idx = content.find(key_pattern)
        if idx != -1:
            start_idx = idx + len(key_pattern)
            val_start = content.find('"', start_idx)
            if val_start != -1:
                val_end = content.find('"', val_start + 1)
                if val_end != -1:
                    val = content[val_start + 1:val_end]
                    if key == "private_key":
                        # Replace carriage returns and actual newlines with escaped \n
                        val = val.replace('\r', '').replace('\n', '\\n')
                        val = val.replace('\\\\n', '\\n')
                    info[key] = val
                    
    # Validate that we successfully parsed the essential fields
    if not info.get("private_key") or not info.get("client_email"):
        raise ValueError("Essential Service Account fields ('private_key' or 'client_email') could not be parsed.")
        
    return info

def get_sheets_service():
    scopes = ['https://www.googleapis.com/auth/spreadsheets']
    creds_path = os.environ.get("GOOGLE_APPLICATION_CREDENTIALS")
    adc_error = None
    
    # 1. Try custom service account key loader if path is specified
    file_error = None
    if creds_path and os.path.exists(creds_path):
        try:
            print(f"🔑 Loading credentials from file path: {creds_path}")
            info = load_cleaned_service_account(creds_path)
            credentials = service_account.Credentials.from_service_account_info(info, scopes=scopes)
            return build('sheets', 'v4', credentials=credentials)
        except Exception as file_err:
            file_error = file_err
            print(f"⚠️ File path credentials load failed: {file_err}")
            
    # 2. Try default ADC (fallback)
    try:
        credentials, _ = google.auth.default(scopes=scopes)
        return build('sheets', 'v4', credentials=credentials)
    except Exception as err:
        adc_error = err
        print(f"ℹ️ ADC lookup failed/unavailable: {err}")
        
    # 3. Local development fallback: run gcloud auth print-access-token
    try:
        result = subprocess.run(
            ['gcloud', 'auth', 'print-access-token'],
            capture_output=True,
            text=True,
            check=True
        )
        token = result.stdout.strip()
        credentials = Credentials(token=token)
        return build('sheets', 'v4', credentials=credentials)
    except Exception as e:
        print(f"❌ Error loading credentials from all sources: {e}")
        raise Exception(f"Google authentication failed. File Path Error: {file_error}. ADC Error: {adc_error}. Local gcloud Error: {e}")

class SheetsProxyHandler(BaseHTTPRequestHandler):
    def _set_cors_headers(self):
        self.send_header('Access-Control-Allow-Origin', '*')
        self.send_header('Access-Control-Allow-Methods', 'GET, POST, OPTIONS')
        self.send_header('Access-Control-Allow-Headers', 'Content-Type, Authorization')

    def do_OPTIONS(self):
        self.send_response(200)
        self._set_cors_headers()
        self.end_headers()

    def do_HEAD(self):
        self.send_response(200)
        self._set_cors_headers()
        self.end_headers()

    def do_GET(self):
        parsed_path = urllib.parse.urlparse(self.path)
        path = parsed_path.path
        
        if path == '/' or path == '/health':
            self.send_response(200)
            self.send_header('Content-Type', 'application/json')
            self._set_cors_headers()
            self.end_headers()
            self.wfile.write(json.dumps({'status': 'healthy'}).encode('utf-8'))
            return

        try:
            service = get_sheets_service()
            
            # GET /roster
            if path == '/roster':
                result = service.spreadsheets().values().get(
                    spreadsheetId=SPREADSHEET_ID,
                    range='roster!A2:H'
                ).execute()
                
                rows = result.get('values', [])
                roster = []
                for r in rows:
                    if len(r) >= 8:
                        roster.append({
                            'id': r[0],
                            'character_name': r[1],
                            'player_name': r[2],
                            'faction': r[3],
                            'faceclaim_name': r[4],
                            'faceclaim_img_url': r[5],
                            'status': r[6],
                            'joined_date': r[7]
                        })
                
                self.send_response(200)
                self.send_header('Content-Type', 'application/json')
                self._set_cors_headers()
                self.end_headers()
                self.wfile.write(json.dumps(roster).encode('utf-8'))
                return

            # GET /applications/pending
            elif path == '/applications/pending':
                result = service.spreadsheets().values().get(
                    spreadsheetId=SPREADSHEET_ID,
                    range='applications!A2:G'
                ).execute()
                
                rows = result.get('values', [])
                applications = []
                for r in rows:
                    if len(r) >= 7 and r[6] == 'Pending':
                        try:
                            answers = json.loads(r[5])
                        except:
                            answers = [r[5]]
                            
                        applications.append({
                            'id': r[0],
                            'submitted_at': r[1],
                            'applicant_email': r[2],
                            'character_name': r[3],
                            'faction': r[4],
                            'answers': answers,
                            'status': r[6]
                        })
                
                self.send_response(200)
                self.send_header('Content-Type', 'application/json')
                self._set_cors_headers()
                self.end_headers()
                self.wfile.write(json.dumps(applications).encode('utf-8'))
                return

            else:
                self.send_error(404, "Endpoint not found")
                
        except Exception as e:
            self.send_response(500)
            self.send_header('Content-Type', 'application/json')
            self._set_cors_headers()
            self.end_headers()
            self.wfile.write(json.dumps({'error': str(e)}).encode('utf-8'))

    def do_POST(self):
        parsed_path = urllib.parse.urlparse(self.path)
        path = parsed_path.path
        
        try:
            content_length = int(self.headers['Content-Length'])
            post_data = self.rfile.read(content_length)
            body = json.loads(post_data.decode('utf-8'))
            
            service = get_sheets_service()

            # POST /admittance/decision
            if path == '/admittance/decision':
                app_id = body.get('app_id')
                decision = body.get('decision')
                
                result = service.spreadsheets().values().get(
                    spreadsheetId=SPREADSHEET_ID,
                    range='applications!A2:G'
                ).execute()
                
                rows = result.get('values', [])
                row_idx = -1
                target_app = None
                
                for idx, r in enumerate(rows):
                    if len(r) > 0 and r[0] == app_id:
                        row_idx = idx + 2
                        target_app = r
                        break
                
                if row_idx == -1:
                    self.send_error(404, "Application ID not found")
                    return
                
                service.spreadsheets().values().update(
                    spreadsheetId=SPREADSHEET_ID,
                    range=f'applications!G{row_idx}',
                    valueInputOption='RAW',
                    body={'values': [[decision]]}
                ).execute()
                
                if decision == 'Approved' and target_app:
                    char_name = target_app[3]
                    email = target_app[2]
                    faction = target_app[4]
                    
                    roster_id = f"member-{int(datetime.datetime.now().timestamp())}"
                    joined_date = datetime.date.today().strftime('%Y-%m-%d')
                    
                    new_member = [
                        roster_id,
                        char_name,
                        email.split('@')[0],
                        faction,
                        char_name,
                        "https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?auto=format&fit=crop&q=80&w=200",
                        "Active",
                        joined_date
                    ]
                    
                    service.spreadsheets().values().append(
                        spreadsheetId=SPREADSHEET_ID,
                        range='roster!A2',
                        valueInputOption='RAW',
                        body={'values': [new_member]}
                    ).execute()
                
                self.send_response(200)
                self.send_header('Content-Type', 'application/json')
                self._set_cors_headers()
                self.end_headers()
                self.wfile.write(json.dumps({'success': True}).encode('utf-8'))
                return

            # POST /applications/submit
            elif path == '/applications/submit':
                applicant_email = body.get('applicant_email')
                character_name = body.get('character_name')
                faction = body.get('faction')
                answers = body.get('answers')
                
                if not applicant_email or not character_name or not faction or not answers:
                    self.send_response(400)
                    self.send_header('Content-Type', 'application/json')
                    self._set_cors_headers()
                    self.end_headers()
                    self.wfile.write(json.dumps({'error': 'Missing required fields'}).encode('utf-8'))
                    return
                
                app_id = f"app-{int(datetime.datetime.now().timestamp())}"
                submitted_at = datetime.datetime.now().isoformat() + "Z"
                
                new_app = [
                    app_id,
                    submitted_at,
                    applicant_email,
                    character_name,
                    faction,
                    json.dumps(answers),
                    'Pending'
                ]
                
                service.spreadsheets().values().append(
                    spreadsheetId=SPREADSHEET_ID,
                    range='applications!A2',
                    valueInputOption='RAW',
                    body={'values': [new_app]}
                ).execute()
                
                self.send_response(200)
                self.send_header('Content-Type', 'application/json')
                self._set_cors_headers()
                self.end_headers()
                self.wfile.write(json.dumps({'success': True, 'app_id': app_id}).encode('utf-8'))
                return
                
            else:
                self.send_error(404, "Endpoint not found")
                
        except Exception as e:
            self.send_response(500)
            self.send_header('Content-Type', 'application/json')
            self._set_cors_headers()
            self.end_headers()
            self.wfile.write(json.dumps({'error': str(e)}).encode('utf-8'))

def run_server():
    server_address = ('', PORT)
    httpd = HTTPServer(server_address, SheetsProxyHandler)
    print(f"🚀 Resilient Sheets Proxy running on port {PORT}")
    try:
        httpd.serve_forever()
    except KeyboardInterrupt:
        print("\nStopping proxy...")
        httpd.server_close()

if __name__ == '__main__':
    run_server()
