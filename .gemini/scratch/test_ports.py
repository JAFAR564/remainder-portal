import socket

targets = [
    ("127.0.0.1", 9222),
    ("127.0.0.1", 9223),
    ("192.168.0.1", 9222),
    ("192.168.0.1", 9223),
    ("localhost", 9222),
    ("localhost", 9223),
]

for host, port in targets:
    try:
        sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        sock.settimeout(2.0)
        sock.connect((host, port))
        sock.close()
        print(f"Connection to {host}:{port} -> SUCCESS!")
    except Exception as e:
        print(f"Connection to {host}:{port} -> FAILED ({e})")
