"""
Seed script: Parse Excel datasets and insert into Supabase.

Usage:
    pip install openpyxl pandas supabase
    export SUPABASE_SERVICE_KEY='your-service-role-key'
    python seed_data.py

Expects these Excel files in ../Reference / folder:
  - "Sample Demand Plan Data for 2025.xlsx"
  - "School Enrolment for Sample Data.xlsx"
"""

import os
import sys
import pandas as pd
from supabase import create_client, Client

# ---------------------------------------------------------------------------
# Configuration
# ---------------------------------------------------------------------------
SUPABASE_URL = os.environ.get("SUPABASE_URL", "https://yiihjrxfupuohxzubusv.supabase.co")
SUPABASE_KEY = os.environ.get("SUPABASE_SERVICE_KEY", "")

if not SUPABASE_KEY:
    print("ERROR: Set SUPABASE_SERVICE_KEY environment variable")
    print("  export SUPABASE_SERVICE_KEY='your-service-role-key'")
    sys.exit(1)

supabase: Client = create_client(SUPABASE_URL, SUPABASE_KEY)

# Paths
BASE_DIR = os.path.dirname(os.path.abspath(__file__))
PARENT_DIR = os.path.dirname(os.path.dirname(BASE_DIR))
REF_DIR = os.path.join(PARENT_DIR, "Reference ")  # Note: trailing space in folder name

DEMAND_FILE = os.path.join(REF_DIR, "Sample Demand Plan Data for 2025.xlsx")
ENROLMENT_FILE = os.path.join(REF_DIR, "School Enrolment for Sample Data.xlsx")

# Fallback
if not os.path.exists(DEMAND_FILE):
    DEMAND_FILE = os.path.join(BASE_DIR, "Sample Demand Plan Data for 2025.xlsx")
if not os.path.exists(ENROLMENT_FILE):
    ENROLMENT_FILE = os.path.join(BASE_DIR, "School Enrolment for Sample Data.xlsx")

# ---------------------------------------------------------------------------
# Actual column mappings from Excel
# ---------------------------------------------------------------------------

# Demand Plan infra columns (index-based pairs: Physical column, Financial column)
# Row 0 is sub-header with "Physical"/"Financial" — skip it
# Col 9: "Establishment of Resource Room for CWSN" (Physical) | Col 10: Unnamed:10 (Financial)
# Col 11: "CWSN Toilets" (Physical) | Col 12: Unnamed:12 (Financial)
# Col 13: "Drinking Water" (Physical) | Col 14: Unnamed:14 (Financial)
# Col 15: "Electrification" (Physical) | Col 16: Unnamed:16 (Financial)
# Col 17: "Ramps and Handrails" (Physical) | Col 18: Unnamed:18 (Financial)

INFRA_COL_PAIRS = [
    # (physical_col_index, financial_col_index, infra_type_enum)
    (9, 10, "CWSN_RESOURCE_ROOM"),
    (11, 12, "CWSN_TOILET"),
    (13, 14, "DRINKING_WATER"),
    (15, 16, "ELECTRIFICATION"),
    (17, 18, "RAMPS"),
]

# Enrolment grade columns: prefix -> (boys_suffix, girls_suffix, total_suffix)
ENROLMENT_GRADES = {
    "PP3": ("PP3_B", "PP3_G", "PP3_T"),
    "PP2": ("PP2_B", "PP2_G", "PP2_T"),
    "PP1": ("PP1_B", "PP1_G", "PP1_T"),
    "C1": ("C1B", "C1G", "C1T"),
    "C2": ("C2B", "C2G", "C2T"),
    "C3": ("C3B", "C3G", "C3T"),
    "C4": ("C4B", "C4G", "C4T"),
    "C5": ("C5B", "C5G", "C5T"),
    "C6": ("C6B", "C6G", "C6T"),
    "C7": ("C7B", "C7G", "C7T"),
    "C8": ("C8B", "C8G", "C8T"),
    "C9": ("C9B", "C9G", "C9T"),
    "C10": ("C10B", "C10G", "C10T"),
    "C11": ("C11B", "C11G", "C11T"),
    "C12": ("C12B", "C12G", "C12T"),
}


# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------

def safe_int(val, default=0):
    """Safely convert a value to int."""
    if pd.isna(val):
        return default
    try:
        return int(float(val))
    except (ValueError, TypeError):
        return default


def safe_float(val, default=0.0):
    """Safely convert a value to float."""
    if pd.isna(val):
        return default
    try:
        return float(val)
    except (ValueError, TypeError):
        return default


def safe_str(val, default=""):
    """Safely convert to stripped string."""
    if pd.isna(val):
        return default
    return str(val).strip()


def extract_name(val):
    """Extract name from 'name & code' format like 'ANANTAPUR-0501'."""
    s = safe_str(val)
    if not s:
        return ""
    # Split on '-' or '&' and take the name part
    # Format is like "ANANTAPUR-0501" or "ANANTAPUR & 0501"
    if " & " in s:
        return s.split(" & ")[0].strip()
    # Could be "DISTRICT_NAME-CODE" — split on last hyphen
    parts = s.rsplit("-", 1)
    return parts[0].strip()


# ---------------------------------------------------------------------------
# Seed functions
# ---------------------------------------------------------------------------

def seed_state():
    """Ensure AP state exists and return its ID."""
    result = supabase.table("si_states").select("id").eq("state_name", "Andhra Pradesh").execute()
    if result.data:
        return result.data[0]["id"]
    result = supabase.table("si_states").insert({
        "state_name": "Andhra Pradesh",
        "state_code": "AP"
    }).execute()
    return result.data[0]["id"]


def seed_districts_and_mandals(state_id, demand_df, enrolment_df):
    """Extract and seed unique districts and mandals from both files."""
    district_cache = {}  # name -> id
    mandal_cache = {}    # (district_name, mandal_name) -> id

    # --- From Demand Plan: "District Name" and "Mandal" columns ---
    districts_demand = demand_df["District Name"].dropna().unique()
    for d_raw in districts_demand:
        d_name = safe_str(d_raw)
        if not d_name or d_name in district_cache:
            continue
        result = supabase.table("si_districts").select("id").eq("district_name", d_name).eq("state_id", state_id).execute()
        if result.data:
            district_cache[d_name] = result.data[0]["id"]
        else:
            result = supabase.table("si_districts").insert({
                "state_id": state_id,
                "district_name": d_name,
            }).execute()
            district_cache[d_name] = result.data[0]["id"]
        print(f"  District (demand): {d_name} -> ID {district_cache[d_name]}")

    # Mandals from demand plan
    if "Mandal" in demand_df.columns:
        for _, row in demand_df[["District Name", "Mandal"]].drop_duplicates().iterrows():
            d_name = safe_str(row["District Name"])
            m_name = safe_str(row["Mandal"])
            if not d_name or not m_name or d_name not in district_cache:
                continue
            key = (d_name, m_name)
            if key in mandal_cache:
                continue
            district_id = district_cache[d_name]
            result = supabase.table("si_mandals").select("id").eq("mandal_name", m_name).eq("district_id", district_id).execute()
            if result.data:
                mandal_cache[key] = result.data[0]["id"]
            else:
                result = supabase.table("si_mandals").insert({
                    "district_id": district_id,
                    "mandal_name": m_name,
                }).execute()
                mandal_cache[key] = result.data[0]["id"]

    # --- From Enrolment: "district_name & code" and "block_name & code" ---
    if "district_name & code" in enrolment_df.columns:
        for d_raw in enrolment_df["district_name & code"].dropna().unique():
            d_name = extract_name(d_raw)
            if not d_name or d_name in district_cache:
                continue
            result = supabase.table("si_districts").select("id").eq("district_name", d_name).eq("state_id", state_id).execute()
            if result.data:
                district_cache[d_name] = result.data[0]["id"]
            else:
                result = supabase.table("si_districts").insert({
                    "state_id": state_id,
                    "district_name": d_name,
                }).execute()
                district_cache[d_name] = result.data[0]["id"]
            print(f"  District (enrolment): {d_name} -> ID {district_cache[d_name]}")

    if "block_name & code" in enrolment_df.columns and "district_name & code" in enrolment_df.columns:
        for _, row in enrolment_df[["district_name & code", "block_name & code"]].drop_duplicates().iterrows():
            d_name = extract_name(row["district_name & code"])
            m_name = extract_name(row["block_name & code"])
            if not d_name or not m_name or d_name not in district_cache:
                continue
            key = (d_name, m_name)
            if key in mandal_cache:
                continue
            district_id = district_cache[d_name]
            result = supabase.table("si_mandals").select("id").eq("mandal_name", m_name).eq("district_id", district_id).execute()
            if result.data:
                mandal_cache[key] = result.data[0]["id"]
            else:
                result = supabase.table("si_mandals").insert({
                    "district_id": district_id,
                    "mandal_name": m_name,
                }).execute()
                mandal_cache[key] = result.data[0]["id"]

    print(f"  Total districts: {len(district_cache)}, mandals: {len(mandal_cache)}")
    return district_cache, mandal_cache


def seed_demand_plans(demand_df, district_cache, mandal_cache):
    """Parse demand plan Excel and seed schools + demand plans.

    The demand plan Excel has a sub-header row at index 0 with Physical/Financial labels.
    Real data starts at index 1.
    """
    print("\n--- Seeding Schools & Demand Plans ---")

    # Skip the sub-header row (row 0 has "Physical"/"Financial" labels)
    df = demand_df.iloc[1:].reset_index(drop=True)
    col_names = list(demand_df.columns)
    print(f"  Data rows: {len(df)}, Columns: {len(col_names)}")

    school_cache = {}  # udise_code -> school_id

    for idx, row in df.iterrows():
        # School Code is in column "School Code" (may be float like 2.82214e+10)
        udise = safe_int(row.get("School Code"))
        if udise == 0:
            continue

        school_name = safe_str(row.get("School Name"), f"School {udise}")
        district_name = safe_str(row.get("District Name"))
        mandal_name = safe_str(row.get("Mandal"))
        management = safe_str(row.get("School Management"))
        # Note: "School category " has trailing space in Excel
        category = safe_str(row.get("School category ", row.get("School category", "")))
        lat = safe_float(row.get("Latitude")) if pd.notna(row.get("Latitude")) else None
        lon = safe_float(row.get("Longitude")) if pd.notna(row.get("Longitude")) else None

        district_id = district_cache.get(district_name)
        mandal_key = (district_name, mandal_name)
        mandal_id = mandal_cache.get(mandal_key)

        # Upsert school
        if udise not in school_cache:
            result = supabase.table("si_schools").select("id").eq("udise_code", udise).execute()
            if result.data:
                school_cache[udise] = result.data[0]["id"]
            else:
                school_data = {
                    "udise_code": udise,
                    "school_name": school_name,
                    "district_id": district_id,
                    "mandal_id": mandal_id,
                    "school_management": management or None,
                    "school_category": category or None,
                    "latitude": lat,
                    "longitude": lon,
                }
                result = supabase.table("si_schools").insert(school_data).execute()
                school_cache[udise] = result.data[0]["id"]

        school_id = school_cache[udise]

        # Insert demand plans using column index pairs
        for phys_idx, fin_idx, infra_type in INFRA_COL_PAIRS:
            if phys_idx >= len(col_names) or fin_idx >= len(col_names):
                continue
            phys_col = col_names[phys_idx]
            fin_col = col_names[fin_idx]

            phys_count = safe_int(row.iloc[phys_idx] if phys_idx < len(row) else 0)
            fin_amount = safe_float(row.iloc[fin_idx] if fin_idx < len(row) else 0)

            if phys_count > 0 or fin_amount > 0:
                try:
                    supabase.table("si_demand_plans").insert({
                        "school_id": school_id,
                        "plan_year": 2025,
                        "infra_type": infra_type,
                        "physical_count": phys_count,
                        "financial_amount": fin_amount,
                        "validation_status": "PENDING",
                    }).execute()
                except Exception as e:
                    print(f"    Warning: demand plan insert failed for school {udise}, {infra_type}: {e}")

        if (idx + 1) % 50 == 0:
            print(f"  Processed {idx + 1} schools...")

    print(f"  Done. Total schools from demand plan: {len(school_cache)}")
    return school_cache


def seed_enrolment(enrolment_df, district_cache, mandal_cache, school_cache):
    """Parse enrolment Excel and seed enrolment_history.

    Enrolment data is in semi-long format:
    - One row per school per academic year (956 rows ≈ 319 schools × 3 years)
    - Grade columns are wide: PP3_B, PP3_G, PP3_T, C1B, C1G, C1T, ... C12B, C12G, C12T
    """
    print("\n--- Seeding Enrolment Data ---")
    df = enrolment_df
    print(f"  Rows: {len(df)}")

    new_schools = 0

    for idx, row in df.iterrows():
        udise = safe_int(row.get("UDISE_Code"))
        if udise == 0:
            continue

        academic_year = safe_str(row.get("Academic_Year"))
        if not academic_year:
            continue

        # Find or create school
        if udise not in school_cache:
            result = supabase.table("si_schools").select("id").eq("udise_code", udise).execute()
            if result.data:
                school_cache[udise] = result.data[0]["id"]
            else:
                school_name = safe_str(row.get("School_Name"), f"School {udise}")
                d_name = extract_name(row.get("district_name & code", ""))
                m_name = extract_name(row.get("block_name & code", ""))
                district_id = district_cache.get(d_name)
                mandal_id = mandal_cache.get((d_name, m_name))

                result = supabase.table("si_schools").insert({
                    "udise_code": udise,
                    "school_name": school_name,
                    "district_id": district_id,
                    "mandal_id": mandal_id,
                }).execute()
                school_cache[udise] = result.data[0]["id"]
                new_schools += 1

        school_id = school_cache[udise]

        # Insert enrolment for each grade
        for grade_label, (boys_col, girls_col, total_col) in ENROLMENT_GRADES.items():
            boys = safe_int(row.get(boys_col))
            girls = safe_int(row.get(girls_col))
            total = safe_int(row.get(total_col))
            if total == 0:
                total = boys + girls
            if total == 0:
                continue

            try:
                supabase.table("si_enrolment_history").upsert({
                    "school_id": school_id,
                    "academic_year": academic_year,
                    "grade": grade_label,
                    "boys": boys,
                    "girls": girls,
                    "total": total,
                }, on_conflict="school_id,academic_year,grade").execute()
            except Exception as e:
                print(f"    Warning: enrolment upsert failed for school {udise}, {academic_year}, {grade_label}: {e}")

        if (idx + 1) % 100 == 0:
            print(f"  Processed {idx + 1} enrolment rows...")

    print(f"  Done. New schools from enrolment: {new_schools}")
    print(f"  Total schools overall: {len(school_cache)}")


def main():
    print("=== School Infrastructure Data Seeder ===")
    print(f"  Supabase URL: {SUPABASE_URL}")
    print(f"  Demand file:  {DEMAND_FILE}")
    print(f"  Enrolment file: {ENROLMENT_FILE}")

    if not os.path.exists(DEMAND_FILE):
        print(f"ERROR: Demand plan file not found: {DEMAND_FILE}")
        sys.exit(1)
    if not os.path.exists(ENROLMENT_FILE):
        print(f"ERROR: Enrolment file not found: {ENROLMENT_FILE}")
        sys.exit(1)

    # Step 1: Seed AP state
    print("\n--- Step 1: Seed State ---")
    state_id = seed_state()
    print(f"  State ID: {state_id}")

    # Step 2: Load both files
    print("\n--- Step 2: Load Excel Files ---")
    demand_df = pd.read_excel(DEMAND_FILE)
    enrolment_df = pd.read_excel(ENROLMENT_FILE)
    print(f"  Demand plan: {demand_df.shape[0]} rows x {demand_df.shape[1]} cols")
    print(f"  Enrolment:   {enrolment_df.shape[0]} rows x {enrolment_df.shape[1]} cols")

    # Step 3: Seed districts & mandals from both files
    print("\n--- Step 3: Seed Districts & Mandals ---")
    district_cache, mandal_cache = seed_districts_and_mandals(state_id, demand_df, enrolment_df)

    # Step 4: Seed schools + demand plans
    school_cache = seed_demand_plans(demand_df, district_cache, mandal_cache)

    # Step 5: Seed enrolment history
    seed_enrolment(enrolment_df, district_cache, mandal_cache, school_cache)

    # Summary
    print("\n=== Seeding Complete ===")
    print(f"  Districts: {len(district_cache)}")
    print(f"  Mandals:   {len(mandal_cache)}")
    print(f"  Schools:   {len(school_cache)}")


if __name__ == "__main__":
    main()
