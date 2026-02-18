#!/usr/bin/env python3
"""Execute just the referral INSERT statements."""
import requests
import time

SUPABASE_TOKEN = "sbp_573715d84de517dc89b7633fdef4225c73cf238a"
PROJECT_REF = "owfioycwviwjteviwkka"
API_URL = f"https://api.supabase.com/v1/projects/{PROJECT_REF}/database/query"
HEADERS = {
    "Authorization": f"Bearer {SUPABASE_TOKEN}",
    "Content-Type": "application/json",
}

with open("referrals_only.sql", "r") as f:
    full_sql = f.read()

# Split into individual statements
statements = []
current = []
for line in full_sql.split("\n"):
    stripped = line.strip()
    if stripped.startswith("--") or stripped == "":
        continue
    current.append(line)
    if stripped.endswith(";"):
        statements.append("\n".join(current))
        current = []

print(f"Total referral statements: {len(statements)}")

for i, stmt in enumerate(statements):
    print(f"[{i+1}/{len(statements)}] Executing {len(stmt)} bytes...")
    resp = requests.post(API_URL, headers=HEADERS, json={"query": stmt})
    if resp.status_code == 201:
        print(f"  OK")
    else:
        print(f"  ERROR ({resp.status_code}): {resp.text[:300]}")
    time.sleep(0.5)

print("Done!")
