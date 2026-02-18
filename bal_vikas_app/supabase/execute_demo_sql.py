#!/usr/bin/env python3
"""
Execute demo_1000_data.sql on Supabase via Management API.
Splits the SQL into logical statement chunks and executes them sequentially.
"""

import requests
import time
import sys

SUPABASE_TOKEN = "sbp_573715d84de517dc89b7633fdef4225c73cf238a"
PROJECT_REF = "owfioycwviwjteviwkka"
API_URL = f"https://api.supabase.com/v1/projects/{PROJECT_REF}/database/query"

HEADERS = {
    "Authorization": f"Bearer {SUPABASE_TOKEN}",
    "Content-Type": "application/json",
}


def execute_sql(sql, label=""):
    """Execute SQL via Supabase Management API."""
    resp = requests.post(API_URL, headers=HEADERS, json={"query": sql})
    if resp.status_code == 201:
        return True
    else:
        print(f"  ERROR ({resp.status_code}): {resp.text[:500]}")
        return False


def main():
    with open("demo_1000_data.sql", "r") as f:
        full_sql = f.read()

    # Split by semicolons to get individual statements
    # But be careful with multi-line INSERT VALUES
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

    if current:
        statements.append("\n".join(current))

    print(f"Total statements to execute: {len(statements)}")

    # Group small statements together, keep large ones separate
    groups = []
    current_group = []
    current_size = 0

    for stmt in statements:
        stmt_size = len(stmt)
        # Keep individual statements under 100KB per API call
        if current_size + stmt_size > 80000 and current_group:
            groups.append("\n".join(current_group))
            current_group = [stmt]
            current_size = stmt_size
        else:
            current_group.append(stmt)
            current_size += stmt_size

    if current_group:
        groups.append("\n".join(current_group))

    print(f"Grouped into {len(groups)} API calls")
    print()

    success = 0
    failed = 0
    for i, group in enumerate(groups):
        # Count INSERT statements for progress
        insert_count = group.count("INSERT INTO")
        label = f"Chunk {i+1}/{len(groups)}"
        if insert_count > 0:
            label += f" ({insert_count} INSERTs)"

        print(f"[{i+1}/{len(groups)}] Executing {len(group)} bytes... {label}")
        ok = execute_sql(group, label)
        if ok:
            success += 1
            print(f"  OK")
        else:
            failed += 1
            # Try individual statements in this group
            print(f"  Retrying individual statements...")
            sub_stmts = group.split(";")
            for j, sub in enumerate(sub_stmts):
                sub = sub.strip()
                if not sub or sub.startswith("--"):
                    continue
                ok2 = execute_sql(sub + ";", f"sub-{j}")
                if ok2:
                    print(f"    Sub-statement {j+1} OK")
                else:
                    print(f"    Sub-statement {j+1} FAILED")
                time.sleep(0.3)

        time.sleep(0.5)  # Rate limiting

    print()
    print(f"Done! {success} succeeded, {failed} failed out of {len(groups)} groups")


if __name__ == "__main__":
    main()
