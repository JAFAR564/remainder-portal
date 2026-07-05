import os
import sys
import json
import subprocess
import urllib.parse
from http.server import HTTPServer, BaseHTTPRequestHandler
import datetime
import google.auth
from google.oauth2.credentials import Credentials
from googleapiclient.discovery import build

PORT = int(os.environ.get("PORT", 8080))
SPREADSHEET_ID = "1r4I_4NCkxpRCzfydGOcdcS-swOUwoT-b91CJpNvNg3Y"

def get_sheets_service():
    # 1. First, check if running in a container without gcloud CLI (like Cloud Run)
    # We try fallback to ADC first, as it is the standard production path
    try:
        scopes = ['https://www.googleapis.com/auth/spreadsheets']
        credentials, _ = google.auth.default(scopes=scopes)
        return build('sheets', 'v4', credentials=credentials)
    except Exception as adc_err:
        print(f"ℹ️ ADC lookup failed/unavailable, trying local gcloud auth: {adc_err}")
        
    # 2. Local development fallback: run gcloud auth print-access-token
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
        sys.exit(1)

class SheetsProxyHandler(BaseHTTPRequestHandler):
    def _set_cors_headers(self):
        self.send_header('Access-Control-Allow-Origin', '*')
        self.send_header('Access-Control-Allow-Methods', 'GET, POST, OPTIONS')
        self.send_header('Access-Control-Allow-Headers', 'Content-Type, Authorization')

    def do_OPTIONS(self):
        self.send_response(200)
        self._set_cors_headers()
        self.end_headers()

    def do_GET(self):
        parsed_path = urllib.parse.urlparse(self.path)
        path = parsed_path.path
        
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
    print(f"🚀 Production-ready Sheets Proxy running on port {PORT}")
    try:
        httpd.serve_forever()
    except KeyboardInterrupt:
        print("\nStopping proxy...")
        httpd.server_close()

if __name__ == '__main__':
    run_server()
