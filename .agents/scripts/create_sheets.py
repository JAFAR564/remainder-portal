import sys
import subprocess
import google.auth
from google.oauth2.credentials import Credentials
from googleapiclient.discovery import build
from googleapiclient.errors import HttpError

def get_gcloud_token():
    try:
        # Run gcloud auth print-access-token in a subprocess to extract the active token
        result = subprocess.run(
            ['gcloud', 'auth', 'print-access-token'],
            capture_output=True,
            text=True,
            check=True
        )
        token = result.stdout.strip()
        if token:
            print("🔑 Successfully retrieved active gcloud access token.")
            return token
    except Exception as e:
        print(f"⚠️ Could not retrieve token via gcloud: {e}")
    return None

def main():
    print("🔄 Initializing Google Sheets setup...")
    
    service = None
    gcloud_token = get_gcloud_token()
    
    if gcloud_token:
        # Use gcloud token directly
        credentials = Credentials(token=gcloud_token)
        service = build('sheets', 'v4', credentials=credentials)
    else:
        # Fall back to standard ADC
        print("ℹ️ Falling back to Application Default Credentials (ADC)...")
        try:
            scopes = ['https://www.googleapis.com/auth/spreadsheets']
            credentials, project = google.auth.default(scopes=scopes)
            service = build('sheets', 'v4', credentials=credentials)
        except Exception as e:
            print(f"❌ Error loading credentials: {e}")
            print("Please login to gcloud in your terminal first:")
            print("  gcloud auth login")
            sys.exit(1)

    # Spreadsheet Schema
    spreadsheet_body = {
        'properties': {
            'title': 'The Remainder Portal Database'
        },
        'sheets': [
            {
                'properties': {
                    'title': 'applications'
                }
            },
            {
                'properties': {
                    'title': 'roster'
                }
            }
        ]
    }

    try:
        # Create Spreadsheet
        print("Creating spreadsheet...")
        spreadsheet = service.spreadsheets().create(body=spreadsheet_body, fields='spreadsheetId,spreadsheetUrl').execute()
        spreadsheet_id = spreadsheet.get('spreadsheetId')
        spreadsheet_url = spreadsheet.get('spreadsheetUrl')
        
        print(f"✅ Spreadsheet created successfully!")
        print(f"🔗 URL: {spreadsheet_url}")
        print(f"🆔 ID: {spreadsheet_id}")
        
        # Write Headers
        print("Writing database headers...")
        
        # applications tab headers
        service.spreadsheets().values().update(
            spreadsheetId=spreadsheet_id,
            range='applications!A1:G1',
            valueInputOption='RAW',
            body={'values': [['id', 'submitted_at', 'applicant_email', 'character_name', 'faction', 'answers', 'status']]}
        ).execute()

        # roster tab headers
        service.spreadsheets().values().update(
            spreadsheetId=spreadsheet_id,
            range='roster!A1:H1',
            valueInputOption='RAW',
            body={'values': [['id', 'character_name', 'player_name', 'faction', 'faceclaim_name', 'faceclaim_img_url', 'status', 'joined_date']]}
        ).execute()
        
        # Populate initial mock data
        print("Writing initial mock data...")
        
        mock_apps = [
            ['app-01', '2026-07-04T12:00:00Z', 'cillian.fan@example.com', 'Alistair Vance', 'Aethelgard Alliance', '["I wish to join the sanctuary to archive precision movements and rare gold timepieces.", "My lineage dates back to the old clockmakers of Zurich.", "I will dedicate my watches to the grand archive of time."]', 'Pending'],
            ['app-02', '2026-07-04T14:30:00Z', 'clara.oswald@example.com', 'Clara Oswald', 'Elysium Chrono Syndicate', '["Time is a canvas, and watches are the paintbrushes.", "I travel across timelines to preserve chronological sanity.", "I seek entry to share my collection of pocket-watch singularities."]', 'Pending']
        ]
        
        mock_roster = [
            ['member-01', 'Alistair Vance', 'Admin', 'Aethelgard Alliance', 'Cillian Murphy', 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?auto=format&fit=crop&q=80&w=200', 'Active', '2026-01-15'],
            ['member-02', 'Lorna Cole', 'Lorna', 'Vanguard Order', 'Jenna Coleman', 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?auto=format&fit=crop&q=80&w=200', 'Active', '2026-02-20']
        ]
        
        service.spreadsheets().values().update(
            spreadsheetId=spreadsheet_id,
            range='applications!A2',
            valueInputOption='RAW',
            body={'values': mock_apps}
        ).execute()

        service.spreadsheets().values().update(
            spreadsheetId=spreadsheet_id,
            range='roster!A2',
            valueInputOption='RAW',
            body={'values': mock_roster}
        ).execute()
        
        print("🎉 Google Sheet Setup Complete!")
        print("\nSave this Spreadsheet ID for your proxy configuration:")
        print(f"SPREADSHEET_ID={spreadsheet_id}")
        
    except HttpError as err:
        print(f"❌ HTTP Error occurred: {err}")
    except Exception as err:
        print(f"❌ Error: {err}")

if __name__ == '__main__':
    main()
