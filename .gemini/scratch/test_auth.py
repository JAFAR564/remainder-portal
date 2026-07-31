import json
import httpx
from pathlib import Path

cookies_json_path = "/home/vortex/.notebooklm-mcp-cli/profiles/default/cookies.json"
with open(cookies_json_path) as f:
    cookies = json.load(f)

cookie_header = "; ".join(f"{k}={v}" for k, v in cookies.items())

user_agents = {
    "mac": "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36",
    "linux": "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36",
    "windows": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36"
}

for platform, ua in user_agents.items():
    print(f"\n--- Testing with UA platform: {platform} ---")
    headers = {
        "User-Agent": ua,
        "Accept": "text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8",
        "Accept-Language": "en-US,en;q=0.9",
        "Sec-Fetch-Dest": "document",
        "Sec-Fetch-Mode": "navigate",
        "Sec-Fetch-Site": "none",
        "Sec-Fetch-User": "?1",
        "Cookie": cookie_header
    }
    
    with httpx.Client(headers=headers, follow_redirects=False, timeout=10.0) as client:
        response = client.get("https://notebooklm.google.com/")
        print(f"Initial status: {response.status_code}")
        print(f"Location: {response.headers.get('Location')}")
        
        # If redirected, follow it manually to see if we hit login
        url = "https://notebooklm.google.com/"
        history = []
        while response.status_code in (301, 302, 303, 307, 308):
            url = response.headers.get('Location')
            history.append((response.status_code, url))
            response = client.get(url)
            print(f"Redirected to: {response.status_code} {url}")
            if "accounts.google.com" in url:
                print("Redirected to accounts.google.com -> REJECTED")
                break
        else:
            print(f"Final destination: {response.status_code} {url}")
            if response.status_code == 200:
                print("Successfully reached NotebookLM -> ACCEPTED!")
