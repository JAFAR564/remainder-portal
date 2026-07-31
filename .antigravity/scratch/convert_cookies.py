import sys

def convert_cookies(input_path, output_path):
    cookies = []
    with open(input_path, 'r') as f:
        for line in f:
            line = line.strip()
            if not line:
                continue
            # Netscape cookies can start with #HttpOnly_ but are otherwise tab-separated
            domain_line = False
            if line.startswith("#HttpOnly_"):
                line = line[len("#HttpOnly_"):]
                domain_line = True
            elif line.startswith("#"):
                continue
            
            parts = line.split('\t')
            if len(parts) >= 7:
                name = parts[5]
                value = parts[6]
                cookies.append(f"{name}={value}")
    
    cookie_header = "; ".join(cookies)
    with open(output_path, 'w') as f:
        f.write(cookie_header)
    print(f"Converted {len(cookies)} cookies to {output_path}")

if __name__ == "__main__":
    convert_cookies("/home/vortex/remainder-portal/cookies.txt", "/home/vortex/remainder-portal/cookies_header.txt")
