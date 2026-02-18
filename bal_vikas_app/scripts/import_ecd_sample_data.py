#!/usr/bin/env python3
"""
Import ECD_sample_data_sets.xlsx into Supabase as a separate selectable dataset.

Creates a NEW hierarchy (district, project, sectors, AWCs) and imports 1000 children
with screening results, referrals, and intervention follow-ups.

Outputs: ecd_sample_import.sql — run in Supabase SQL Editor.

Usage:
  pip install openpyxl
  python import_ecd_sample_data.py
  # Then paste ecd_sample_import.sql content into Supabase SQL Editor
"""

import openpyxl
import random
from datetime import datetime

XLSX_PATH = "../../ECD_sample_data_sets.xlsx"
OUTPUT_PATH = "../supabase/ecd_sample_import.sql"

# Use high IDs to avoid conflicts with existing data
# Existing: state=1, district=1..5, project=1..8, sectors=1..15, AWCs=1..50
DISTRICT_BASE_ID = 200   # 200-203 for 4 districts
PROJECT_BASE_ID = 200    # 200-203 for 4 projects (1:1 with districts)
SECTOR_BASE_ID = 200     # 200-211 for 12 sectors (3 per project)
AWC_BASE_ID = 300        # Start at 300 to avoid overlap with sector IDs 200-211
CHILD_BASE_ID = 5000     # Well above existing children
SESSION_BASE_ID = 10000
RESULT_BASE_ID = 10000

# Legacy single-ID constants (kept for backward compat in non-hierarchy code)
DISTRICT_ID = DISTRICT_BASE_ID
PROJECT_ID = PROJECT_BASE_ID

# Telugu child names for generating names (Excel doesn't have names)
MALE_NAMES = [
    "Arjun", "Ravi", "Krishna", "Venkat", "Srinivas", "Mahesh", "Ganesh",
    "Kiran", "Mohan", "Gopal", "Pavan", "Charan", "Tarun", "Varun", "Sai",
    "Pranav", "Aarav", "Dhruv", "Ishaan", "Vivaan", "Aditya", "Arnav",
    "Kabir", "Shaurya", "Vihaan", "Omkar", "Tanish", "Rohan", "Yash",
    "Anirudh", "Tejas", "Vikram", "Rohit", "Ajay", "Vijay", "Ramesh",
    "Satish", "Naresh", "Suresh", "Rajesh", "Harish", "Manish", "Nihal",
]
FEMALE_NAMES = [
    "Priya", "Lakshmi", "Sravani", "Divya", "Keerthi", "Mounika", "Swathi",
    "Anusha", "Bhavani", "Chandini", "Deepika", "Gayathri", "Harika",
    "Kavya", "Lavanya", "Madhavi", "Nandini", "Padma", "Radhika", "Sahasra",
    "Akshara", "Ananya", "Diya", "Gowri", "Himaja", "Indu", "Kamala",
    "Meghana", "Niharika", "Pooja", "Sahiti", "Tanvi", "Varsha", "Anjali",
    "Bhargavi", "Durga", "Esha", "Manasa", "Neelima", "Jyothi", "Likhitha",
]
LAST_NAMES = [
    "Reddy", "Naidu", "Kumar", "Rao", "Sharma", "Babu", "Prasad", "Varma",
    "Chowdary", "Raju", "Swamy", "Gupta", "Patel", "Murthy", "Goud",
]

random.seed(42)


def load_excel():
    """Load all sheets from the Excel file."""
    wb = openpyxl.load_workbook(XLSX_PATH, read_only=True)
    data = {}
    sheets = [
        "Registration", "Developmental_Risk", "Neuro_Behavioral",
        "Nutrition", "Environment_Caregiving", "Developmental_Assessment",
        "Baseline_Risk_Output", "Referral_Action", "Intervention_FollowUp",
        "Outcomes_Impact", "Behaviour_indicators", "Risk_Classification",
    ]
    for name in sheets:
        ws = wb[name]
        rows = []
        headers = None
        for i, row in enumerate(ws.iter_rows(values_only=True)):
            if i == 0:
                headers = [h for h in row if h is not None]
                continue
            if row[0] is None:
                continue
            rows.append(dict(zip(headers, row[: len(headers)])))
        data[name] = rows
    wb.close()
    return data


def esc(val):
    if val is None:
        return "NULL"
    s = str(val).replace("'", "''")
    return f"'{s}'"


def bool_sql(val):
    if val is None:
        return "FALSE"
    if isinstance(val, bool):
        return "TRUE" if val else "FALSE"
    if isinstance(val, (int, float)):
        return "TRUE" if val >= 1 else "FALSE"
    if isinstance(val, str):
        return "TRUE" if val.lower() in ("yes", "true", "1") else "FALSE"
    return "FALSE"


def num_or_null(val):
    if val is None:
        return "NULL"
    try:
        return str(round(float(val), 2))
    except (ValueError, TypeError):
        return "NULL"


def int_or_default(val, default=0):
    if val is None:
        return str(default)
    try:
        return str(int(float(val)))
    except (ValueError, TypeError):
        return str(default)


def generate_name(gender, idx):
    """Generate a realistic Telugu name."""
    if gender == "F":
        first = FEMALE_NAMES[idx % len(FEMALE_NAMES)]
    else:
        first = MALE_NAMES[idx % len(MALE_NAMES)]
    last = LAST_NAMES[idx % len(LAST_NAMES)]
    return f"{first} {last}"


def map_overall_risk(baseline_cat, num_delays):
    """Map baseline category to overall_risk CHECK constraint values."""
    if baseline_cat == "High" or (num_delays is not None and int(float(num_delays)) >= 3):
        return "HIGH"
    if baseline_cat == "Medium" or (num_delays is not None and int(float(num_delays)) >= 1):
        return "MEDIUM"
    return "LOW"


def map_referral_type(val):
    """Map Excel referral_type to CHECK constraint values."""
    if val is None:
        return "NULL"
    v = str(val).strip()
    mapping = {
        "PHC": "PHC",
        "RBSK": "RBSK",
        "DEIC": "DEIC",
        "NRC": "NRC",
        "AWW Intervention": "AWW_INTERVENTION",
        "Parent Intervention": "PARENT_INTERVENTION",
    }
    return esc(mapping.get(v, "PHC"))


def map_referral_reason(val):
    """Map Excel referral_reason to CHECK constraint values."""
    if val is None:
        return "NULL"
    v = str(val).strip()
    mapping = {
        "GDD": "GDD",
        "ADHD": "ADHD",
        "AUTISM": "AUTISM",
        "Autism": "AUTISM",
        "Behaviour": "BEHAVIOUR",
        "Environment": "ENVIRONMENT",
        "Domain Delay": "DOMAIN_DELAY",
    }
    return esc(mapping.get(v, "GDD"))


def map_referral_status(val):
    """Map Excel referral_status to CHECK constraint values."""
    if val is None:
        return "'Pending'"
    v = str(val).strip()
    mapping = {
        "Pending": "Pending",
        "Completed": "Completed",
        "Under Treatment": "Under_Treatment",
        "Under_Treatment": "Under_Treatment",
    }
    return esc(mapping.get(v, "Pending"))


def map_improvement_status(val):
    """Map Excel improvement_status to CHECK constraint values."""
    if val is None:
        return "NULL"
    v = str(val).strip()
    mapping = {
        "Improved": "Improved",
        "Stable": "Same",
        "Same": "Same",
        "Needs more support": "Worsened",
        "Worsened": "Worsened",
    }
    return esc(mapping.get(v, "Same"))


def generate_sql():
    print("Loading Excel data...")
    data = load_excel()
    reg = data["Registration"]
    dev_risk = data["Developmental_Risk"]
    neuro = data["Neuro_Behavioral"]
    nutrition = data["Nutrition"]
    environment = data["Environment_Caregiving"]
    dev_assess = data["Developmental_Assessment"]
    baseline = data["Baseline_Risk_Output"]
    referral = data["Referral_Action"]
    followup = data["Intervention_FollowUp"]
    outcomes = data["Outcomes_Impact"]
    behaviour = data["Behaviour_indicators"]
    risk_class = data["Risk_Classification"]

    print(f"Loaded {len(reg)} children from Excel")

    # Index all sheets by child_id for easy lookup
    def index_by_child(rows):
        return {str(r["child_id"]): r for r in rows}

    dev_risk_idx = index_by_child(dev_risk)
    neuro_idx = index_by_child(neuro)
    nutrition_idx = index_by_child(nutrition)
    env_idx = index_by_child(environment)
    dev_assess_idx = index_by_child(dev_assess)
    baseline_idx = index_by_child(baseline)
    referral_idx = index_by_child(referral)
    followup_idx = index_by_child(followup)
    outcomes_idx = index_by_child(outcomes)
    behaviour_idx = index_by_child(behaviour)
    risk_class_idx = index_by_child(risk_class)

    lines = []
    lines.append("-- ============================================================")
    lines.append("-- ECD Sample Dataset Import (4 Districts)")
    lines.append("-- Generated from ECD_sample_data_sets.xlsx")
    lines.append("-- Creates a SEPARATE hierarchy (does NOT modify existing data)")
    lines.append("-- ============================================================")
    lines.append("")

    # --- 0. DETERMINE HIERARCHY FROM EXCEL ---
    # Extract unique districts and mandals from Registration sheet
    districts = sorted(set(str(r["district"]) for r in reg if r.get("district")))
    mandals = sorted(set(str(r["mandal"]) for r in reg if r.get("mandal")))

    print(f"Districts: {districts}")
    print(f"Mandals: {mandals}")

    # Build district → ID mapping
    district_to_id = {}
    for i, dist in enumerate(districts):
        district_to_id[dist] = DISTRICT_BASE_ID + i

    # Build (district, mandal) → sector_id mapping
    sector_key_to_id = {}
    sector_idx = 0
    for dist in districts:
        for mandal in mandals:
            sector_key_to_id[(dist, mandal)] = SECTOR_BASE_ID + sector_idx
            sector_idx += 1

    # Build (district, mandal, awc_code) → awc_id mapping
    awc_key_to_id = {}
    awc_next_id = AWC_BASE_ID
    for r in reg:
        dist = str(r.get("district", ""))
        mandal = str(r.get("mandal", ""))
        awc_code = str(int(float(r["awc_code"])))
        key = (dist, mandal, awc_code)
        if key not in awc_key_to_id:
            awc_key_to_id[key] = awc_next_id
            awc_next_id += 1

    max_awc_id = awc_next_id - 1
    max_sector_id = SECTOR_BASE_ID + sector_idx - 1
    max_district_id = DISTRICT_BASE_ID + len(districts) - 1
    max_project_id = PROJECT_BASE_ID + len(districts) - 1

    print(f"  {len(districts)} districts (IDs {DISTRICT_BASE_ID}-{max_district_id})")
    print(f"  {len(districts)} projects (IDs {PROJECT_BASE_ID}-{max_project_id})")
    print(f"  {sector_idx} sectors (IDs {SECTOR_BASE_ID}-{max_sector_id})")
    print(f"  {len(awc_key_to_id)} AWCs (IDs {AWC_BASE_ID}-{max_awc_id})")

    # --- 0a. CLEANUP OLD ECD DATA ---
    lines.append("-- 0a. ENSURE datasets table exists")
    lines.append("CREATE TABLE IF NOT EXISTS datasets (")
    lines.append("  id serial PRIMARY KEY,")
    lines.append("  name text NOT NULL,")
    lines.append("  name_te text,")
    lines.append("  project_id int REFERENCES projects(id),")
    lines.append("  district_id int REFERENCES districts(id),")
    lines.append("  state_id int REFERENCES states(id),")
    lines.append("  is_default boolean DEFAULT false,")
    lines.append("  district_ids int[] DEFAULT NULL,")
    lines.append("  created_at timestamptz DEFAULT now()")
    lines.append(");")
    lines.append("")
    lines.append("-- 0b. CLEANUP: remove previous ECD sample data")
    lines.append("--     Each DELETE is independent so one failure doesn't block others.")
    lines.append("")
    # Data tables first (foreign key order)
    lines.append(f"DO $$ BEGIN DELETE FROM environment_assessments WHERE id BETWEEN {RESULT_BASE_ID+1} AND {RESULT_BASE_ID+1100}; EXCEPTION WHEN OTHERS THEN NULL; END $$;")
    lines.append(f"DO $$ BEGIN DELETE FROM nutrition_assessments    WHERE id BETWEEN {RESULT_BASE_ID+1} AND {RESULT_BASE_ID+1100}; EXCEPTION WHEN OTHERS THEN NULL; END $$;")
    lines.append(f"DO $$ BEGIN DELETE FROM intervention_followups   WHERE id BETWEEN {RESULT_BASE_ID+1} AND {RESULT_BASE_ID+1100}; EXCEPTION WHEN OTHERS THEN NULL; END $$;")
    lines.append(f"DO $$ BEGIN DELETE FROM referrals                WHERE id BETWEEN {RESULT_BASE_ID+1} AND {RESULT_BASE_ID+1100}; EXCEPTION WHEN OTHERS THEN NULL; END $$;")
    lines.append(f"DO $$ BEGIN DELETE FROM screening_results        WHERE id BETWEEN {RESULT_BASE_ID} AND {RESULT_BASE_ID+1100}; EXCEPTION WHEN OTHERS THEN NULL; END $$;")
    lines.append(f"DO $$ BEGIN DELETE FROM screening_sessions       WHERE id BETWEEN {SESSION_BASE_ID} AND {SESSION_BASE_ID+1100}; EXCEPTION WHEN OTHERS THEN NULL; END $$;")
    lines.append("")
    lines.append("-- Cleanup by child_id range (catches any straggler rows)")
    lines.append(f"DO $$ BEGIN DELETE FROM screening_results  WHERE session_id IN (SELECT id FROM screening_sessions WHERE child_id BETWEEN {CHILD_BASE_ID} AND {CHILD_BASE_ID+1100}); EXCEPTION WHEN OTHERS THEN NULL; END $$;")
    lines.append(f"DO $$ BEGIN DELETE FROM screening_sessions WHERE child_id BETWEEN {CHILD_BASE_ID} AND {CHILD_BASE_ID+1100}; EXCEPTION WHEN OTHERS THEN NULL; END $$;")
    lines.append(f"DO $$ BEGIN DELETE FROM referrals          WHERE child_id BETWEEN {CHILD_BASE_ID} AND {CHILD_BASE_ID+1100}; EXCEPTION WHEN OTHERS THEN NULL; END $$;")
    lines.append("")
    lines.append(f"DO $$ BEGIN DELETE FROM children WHERE id BETWEEN {CHILD_BASE_ID} AND {CHILD_BASE_ID+1100}; EXCEPTION WHEN OTHERS THEN NULL; END $$;")
    lines.append("")
    lines.append("-- Cleanup by child_unique_id pattern (catches rows from previous imports with different IDs)")
    lines.append("DO $$ BEGIN DELETE FROM screening_results  WHERE session_id IN (SELECT ss.id FROM screening_sessions ss JOIN children c ON ss.child_id = c.id WHERE c.child_unique_id LIKE 'AP_ECD_%'); EXCEPTION WHEN OTHERS THEN NULL; END $$;")
    lines.append("DO $$ BEGIN DELETE FROM screening_sessions WHERE child_id IN (SELECT id FROM children WHERE child_unique_id LIKE 'AP_ECD_%'); EXCEPTION WHEN OTHERS THEN NULL; END $$;")
    lines.append("DO $$ BEGIN DELETE FROM referrals          WHERE child_id IN (SELECT id FROM children WHERE child_unique_id LIKE 'AP_ECD_%'); EXCEPTION WHEN OTHERS THEN NULL; END $$;")
    lines.append("DO $$ BEGIN DELETE FROM intervention_followups WHERE child_id IN (SELECT id FROM children WHERE child_unique_id LIKE 'AP_ECD_%'); EXCEPTION WHEN OTHERS THEN NULL; END $$;")
    lines.append("DO $$ BEGIN DELETE FROM nutrition_assessments  WHERE child_id IN (SELECT id FROM children WHERE child_unique_id LIKE 'AP_ECD_%'); EXCEPTION WHEN OTHERS THEN NULL; END $$;")
    lines.append("DO $$ BEGIN DELETE FROM environment_assessments WHERE child_id IN (SELECT id FROM children WHERE child_unique_id LIKE 'AP_ECD_%'); EXCEPTION WHEN OTHERS THEN NULL; END $$;")
    lines.append("DO $$ BEGIN DELETE FROM children WHERE child_unique_id LIKE 'AP_ECD_%'; EXCEPTION WHEN OTHERS THEN NULL; END $$;")
    lines.append("")
    lines.append(f"DO $$ BEGIN DELETE FROM anganwadi_centres WHERE id BETWEEN {AWC_BASE_ID} AND {max_awc_id + 100}; EXCEPTION WHEN OTHERS THEN NULL; END $$;")
    # Also clean old AWC range (200-398) from previous single-district import
    lines.append(f"DO $$ BEGIN DELETE FROM anganwadi_centres WHERE id BETWEEN 200 AND 398; EXCEPTION WHEN OTHERS THEN NULL; END $$;")
    lines.append(f"DO $$ BEGIN DELETE FROM sectors           WHERE id BETWEEN {SECTOR_BASE_ID} AND {max_sector_id + 10}; EXCEPTION WHEN OTHERS THEN NULL; END $$;")
    lines.append(f"DO $$ BEGIN DELETE FROM projects          WHERE id BETWEEN {PROJECT_BASE_ID} AND {max_project_id + 10}; EXCEPTION WHEN OTHERS THEN NULL; END $$;")
    lines.append(f"DO $$ BEGIN DELETE FROM districts         WHERE id BETWEEN {DISTRICT_BASE_ID} AND {max_district_id + 10}; EXCEPTION WHEN OTHERS THEN NULL; END $$;")
    lines.append(f"DO $$ BEGIN DELETE FROM datasets          WHERE id = 2; EXCEPTION WHEN OTHERS THEN NULL; END $$;")
    lines.append("")

    # --- 1. HIERARCHY ---
    lines.append("-- 1. HIERARCHY: State (reuse AP), 4 Districts, 4 Projects, 12 Sectors, AWCs")
    lines.append("")

    # Create districts
    lines.append("INSERT INTO districts (id, state_id, name, code) VALUES")
    dist_vals = []
    for dist in districts:
        did = district_to_id[dist]
        code = f"ECD_{dist.upper().replace(' ', '_')}"
        dist_vals.append(f"  ({did}, 1, {esc(dist)}, {esc(code)})")
    lines.append(",\n".join(dist_vals))
    lines.append("ON CONFLICT (id) DO UPDATE SET name = EXCLUDED.name, code = EXCLUDED.code;")
    lines.append("")

    # Create projects (1:1 with districts)
    lines.append("INSERT INTO projects (id, district_id, name, code) VALUES")
    proj_vals = []
    for dist in districts:
        did = district_to_id[dist]
        pid = did  # project ID = district ID for simplicity
        code = f"ECD_P_{dist.upper().replace(' ', '_')}"
        proj_vals.append(f"  ({pid}, {did}, {esc(f'ECD {dist}')}, {esc(code)})")
    lines.append(",\n".join(proj_vals))
    lines.append("ON CONFLICT (id) DO UPDATE SET name = EXCLUDED.name, district_id = EXCLUDED.district_id;")
    lines.append("")

    # Create sectors (3 per project, keyed by district+mandal)
    lines.append("INSERT INTO sectors (id, project_id, name, code) VALUES")
    sector_vals = []
    for dist in districts:
        pid = district_to_id[dist]
        for mandal in mandals:
            sid = sector_key_to_id[(dist, mandal)]
            code = f"ECD_S_{dist[:3].upper()}_{mandal[-1]}"
            sector_vals.append(f"  ({sid}, {pid}, {esc(mandal)}, {esc(code)})")
    lines.append(",\n".join(sector_vals))
    lines.append("ON CONFLICT (id) DO UPDATE SET name = EXCLUDED.name, project_id = EXCLUDED.project_id;")
    lines.append("")

    # Create AWCs
    lines.append("INSERT INTO anganwadi_centres (id, sector_id, centre_code, name, address) VALUES")
    awc_vals = []
    for key in sorted(awc_key_to_id.keys()):
        dist, mandal, awc_code = key
        awc_id = awc_key_to_id[key]
        sector_id = sector_key_to_id[(dist, mandal)]
        # centre_code must be unique — include district abbreviation + mandal suffix
        dist_abbr = dist[:3].upper()
        mandal_suffix = mandal[-1]  # A, B, or C
        centre_code = f"ECD_{dist_abbr}_{mandal_suffix}_{awc_code}"
        awc_vals.append(
            f"  ({awc_id}, {sector_id}, '{centre_code}', 'ECD AWC-{awc_code}', {esc(f'{mandal}, {dist}')})"
        )
    lines.append(",\n".join(awc_vals))
    lines.append("ON CONFLICT (id) DO UPDATE SET sector_id = EXCLUDED.sector_id, address = EXCLUDED.address;")
    lines.append("")

    print(f"Created {len(districts)} districts, {len(districts)} projects, {sector_idx} sectors, {len(awc_key_to_id)} AWCs")

    # --- 2. CHILDREN ---
    lines.append("-- 2. CHILDREN (1000)")
    lines.append("")

    # Map Excel child_id → our DB child_id
    child_id_map = {}  # "AP_ECD_000001" → 5000

    batch = []
    for i, r in enumerate(reg):
        cid = CHILD_BASE_ID + i
        excel_id = str(r["child_id"])
        child_id_map[excel_id] = cid

        dist = str(r.get("district", ""))
        mandal = str(r.get("mandal", ""))
        awc_code = str(int(float(r["awc_code"])))
        awc_id = awc_key_to_id.get((dist, mandal, awc_code), AWC_BASE_ID)
        gender = "female" if str(r.get("gender", "")).upper() in ("F", "FEMALE") else "male"
        name = generate_name(r.get("gender", "M"), i)

        # Parse DOB
        dob = r.get("dob")
        if dob is None:
            dob_str = "2022-01-01"
        elif isinstance(dob, datetime):
            dob_str = dob.strftime("%Y-%m-%d")
        else:
            dob_str = str(dob)[:10]

        batch.append(
            f"  ({cid}, '{excel_id}', {esc(name)}, '{dob_str}', '{gender}', {awc_id})"
        )

        # Write in batches of 100
        if len(batch) == 100 or i == len(reg) - 1:
            lines.append(
                "INSERT INTO children (id, child_unique_id, name, dob, gender, awc_id) VALUES"
            )
            lines.append(",\n".join(batch))
            lines.append("ON CONFLICT (id) DO NOTHING;")
            lines.append("")
            batch = []

    print(f"Generated {len(child_id_map)} children")

    # --- 3. SCREENING SESSIONS + RESULTS ---
    lines.append("-- 3. SCREENING SESSIONS + RESULTS")
    lines.append("")

    session_batch = []
    result_batch = []
    for i, r in enumerate(reg):
        excel_id = str(r["child_id"])
        cid = child_id_map[excel_id]
        session_id = SESSION_BASE_ID + i
        result_id = RESULT_BASE_ID + i

        age_months = int_or_default(r.get("age_months"), 24)
        cycle = str(r.get("assessment_cycle", "Baseline"))
        if cycle not in ("Baseline", "Follow-up", "Re-screen"):
            cycle = "Baseline"

        # DOB for assessment_date
        dob = r.get("dob")
        if isinstance(dob, datetime):
            assess_date = dob.strftime("%Y-%m-%d")
        else:
            assess_date = str(dob)[:10] if dob else "2024-01-15"

        session_batch.append(
            f"  ({session_id}, {cid}, '{assess_date}', {age_months}, 'completed')"
        )

        # Get data from other sheets
        dr = dev_risk_idx.get(excel_id, {})
        nr = neuro_idx.get(excel_id, {})
        da = dev_assess_idx.get(excel_id, {})
        bl = baseline_idx.get(excel_id, {})
        bh = behaviour_idx.get(excel_id, {})

        gm_dq = num_or_null(da.get("GM_DQ"))
        fm_dq = num_or_null(da.get("FM_DQ"))
        lc_dq = num_or_null(da.get("LC_DQ"))
        cog_dq = num_or_null(da.get("COG_DQ"))
        se_dq = num_or_null(da.get("SE_DQ"))
        composite_dq = num_or_null(da.get("Composite_DQ"))

        num_delays = int_or_default(dr.get("num_delays"), 0)
        baseline_score = int_or_default(bl.get("baseline_score"), 0)
        baseline_cat = str(bl.get("baseline_category", "Low"))
        if baseline_cat not in ("Low", "Medium", "High"):
            baseline_cat = "Low"

        overall_risk = map_overall_risk(baseline_cat, dr.get("num_delays"))

        autism_risk = str(nr.get("autism_risk", "Low"))
        if autism_risk not in ("Low", "Moderate", "High"):
            autism_risk = "Low"
        adhd_risk = str(nr.get("adhd_risk", "Low"))
        if adhd_risk not in ("Low", "Moderate", "High"):
            adhd_risk = "Low"
        behavior_risk = str(nr.get("behavior_risk", "Low"))
        if behavior_risk not in ("Low", "Moderate", "High"):
            behavior_risk = "Low"

        behavior_score = int_or_default(bh.get("behaviour_score"), 0)

        # Referral needed based on overall risk
        referral_needed = "TRUE" if overall_risk == "HIGH" else "FALSE"

        result_batch.append(
            f"  ({result_id}, {session_id}, {cid}, {esc(overall_risk)}, {referral_needed}, "
            f"{gm_dq}, {fm_dq}, {lc_dq}, {cog_dq}, {se_dq}, {composite_dq}, "
            f"11, 0, {esc(cycle)}, {baseline_score}, {esc(baseline_cat)}, {num_delays}, "
            f"{esc(autism_risk)}, {esc(adhd_risk)}, {esc(behavior_risk)}, {behavior_score})"
        )

        # Write batches
        if len(session_batch) == 100 or i == len(reg) - 1:
            lines.append(
                "INSERT INTO screening_sessions (id, child_id, assessment_date, child_age_months, status) VALUES"
            )
            lines.append(",\n".join(session_batch))
            lines.append("ON CONFLICT (id) DO NOTHING;")
            lines.append("")

            lines.append(
                "INSERT INTO screening_results (id, session_id, child_id, overall_risk, referral_needed, "
                "gm_dq, fm_dq, lc_dq, cog_dq, se_dq, composite_dq, "
                "tools_completed, tools_skipped, assessment_cycle, baseline_score, baseline_category, num_delays, "
                "autism_risk, adhd_risk, behavior_risk, behavior_score) VALUES"
            )
            lines.append(",\n".join(result_batch))
            lines.append("ON CONFLICT (id) DO NOTHING;")
            lines.append("")

            session_batch = []
            result_batch = []

    print("Generated screening sessions + results")

    # --- 4. REFERRALS ---
    lines.append("-- 4. REFERRALS")
    lines.append("")

    ref_batch = []
    ref_count = 0
    for i, r in enumerate(reg):
        excel_id = str(r["child_id"])
        cid = child_id_map[excel_id]
        ref_data = referral_idx.get(excel_id, {})

        triggered = ref_data.get("referral_triggered")
        if triggered and str(triggered).lower() in ("yes", "true", "1"):
            ref_count += 1
            ref_type = map_referral_type(ref_data.get("referral_type"))
            ref_reason = map_referral_reason(ref_data.get("referral_reason"))
            ref_status = map_referral_status(ref_data.get("referral_status"))

            ref_batch.append(
                f"  ({RESULT_BASE_ID + ref_count}, {cid}, {RESULT_BASE_ID + i}, "
                f"{SESSION_BASE_ID + i}, TRUE, {ref_type}, {ref_reason}, {ref_status})"
            )

            if len(ref_batch) == 100:
                lines.append(
                    "INSERT INTO referrals (id, child_id, screening_result_id, session_id, "
                    "referral_triggered, referral_type, referral_reason, referral_status) VALUES"
                )
                lines.append(",\n".join(ref_batch))
                lines.append("ON CONFLICT (id) DO NOTHING;")
                lines.append("")
                ref_batch = []

    if ref_batch:
        lines.append(
            "INSERT INTO referrals (id, child_id, screening_result_id, session_id, "
            "referral_triggered, referral_type, referral_reason, referral_status) VALUES"
        )
        lines.append(",\n".join(ref_batch))
        lines.append("ON CONFLICT (id) DO NOTHING;")
        lines.append("")

    print(f"Generated {ref_count} referrals")

    # --- 5. INTERVENTION FOLLOW-UPS ---
    lines.append("-- 5. INTERVENTION FOLLOW-UPS")
    lines.append("")

    fu_batch = []
    fu_count = 0
    for i, r in enumerate(reg):
        excel_id = str(r["child_id"])
        cid = child_id_map[excel_id]
        fu_data = followup_idx.get(excel_id, {})
        out_data = outcomes_idx.get(excel_id, {})

        plan_gen = bool_sql(fu_data.get("intervention_plan_generated"))
        activities = int_or_default(fu_data.get("home_activities_assigned"), 0)
        fu_conducted = bool_sql(fu_data.get("followup_conducted"))
        improvement = map_improvement_status(fu_data.get("improvement_status"))

        reduction = int_or_default(out_data.get("reduction_in_delay_months"), 0)
        domain_imp = bool_sql(out_data.get("domain_improvement"))
        autism_change = str(out_data.get("autism_risk_change", "Same"))
        if autism_change not in ("Improved", "Same", "Worsened"):
            autism_change = "Same"
        exit_hr = bool_sql(out_data.get("exit_high_risk"))

        fu_count += 1
        fu_batch.append(
            f"  ({RESULT_BASE_ID + fu_count}, {cid}, {RESULT_BASE_ID + i}, "
            f"{plan_gen}, {activities}, {fu_conducted}, {improvement}, "
            f"{reduction}, {domain_imp}, {esc(autism_change)}, {exit_hr})"
        )

        if len(fu_batch) == 100:
            lines.append(
                "INSERT INTO intervention_followups (id, child_id, screening_result_id, "
                "intervention_plan_generated, home_activities_assigned, followup_conducted, "
                "improvement_status, reduction_in_delay_months, domain_improvement, "
                "autism_risk_change, exit_high_risk) VALUES"
            )
            lines.append(",\n".join(fu_batch))
            lines.append("ON CONFLICT (id) DO NOTHING;")
            lines.append("")
            fu_batch = []

    if fu_batch:
        lines.append(
            "INSERT INTO intervention_followups (id, child_id, screening_result_id, "
            "intervention_plan_generated, home_activities_assigned, followup_conducted, "
            "improvement_status, reduction_in_delay_months, domain_improvement, "
            "autism_risk_change, exit_high_risk) VALUES"
        )
        lines.append(",\n".join(fu_batch))
        lines.append("ON CONFLICT (id) DO NOTHING;")
        lines.append("")

    print(f"Generated {fu_count} intervention follow-ups")

    # --- 6. NUTRITION ASSESSMENTS ---
    lines.append("-- 6. NUTRITION ASSESSMENTS")
    lines.append("")

    nut_batch = []
    nut_count = 0
    for i, r in enumerate(reg):
        excel_id = str(r["child_id"])
        cid = child_id_map[excel_id]
        nut_data = nutrition_idx.get(excel_id, {})

        if not nut_data:
            continue

        nut_count += 1
        underweight = bool_sql(nut_data.get("underweight"))
        stunting = bool_sql(nut_data.get("stunting"))
        wasting = bool_sql(nut_data.get("wasting"))
        anemia = bool_sql(nut_data.get("anemia"))
        nut_score = int_or_default(nut_data.get("nutrition_score"), 0)
        nut_risk = str(nut_data.get("nutrition_risk", "Low"))
        if nut_risk not in ("Low", "Moderate", "High"):
            nut_risk = "Low"

        nut_batch.append(
            f"  ({RESULT_BASE_ID + nut_count}, {cid}, {SESSION_BASE_ID + i}, "
            f"{underweight}, {stunting}, {wasting}, {anemia}, {nut_score}, {esc(nut_risk)})"
        )

        if len(nut_batch) == 100:
            lines.append(
                "INSERT INTO nutrition_assessments (id, child_id, session_id, "
                "underweight, stunting, wasting, anemia, nutrition_score, nutrition_risk) VALUES"
            )
            lines.append(",\n".join(nut_batch))
            lines.append("ON CONFLICT (id) DO NOTHING;")
            lines.append("")
            nut_batch = []

    if nut_batch:
        lines.append(
            "INSERT INTO nutrition_assessments (id, child_id, session_id, "
            "underweight, stunting, wasting, anemia, nutrition_score, nutrition_risk) VALUES"
        )
        lines.append(",\n".join(nut_batch))
        lines.append("ON CONFLICT (id) DO NOTHING;")
        lines.append("")

    print(f"Generated {nut_count} nutrition assessments")

    # --- 7. ENVIRONMENT ASSESSMENTS ---
    lines.append("-- 7. ENVIRONMENT ASSESSMENTS")
    lines.append("")

    env_batch = []
    env_count = 0
    for i, r in enumerate(reg):
        excel_id = str(r["child_id"])
        cid = child_id_map[excel_id]
        env_data = env_idx.get(excel_id, {})

        if not env_data:
            continue

        env_count += 1
        pci = int_or_default(env_data.get("parent_child_interaction_score"), 3)
        pmh = int_or_default(env_data.get("parent_mental_health_score"), 5)
        hs = int_or_default(env_data.get("home_stimulation_score"), 5)
        play = bool_sql(env_data.get("play_materials"))

        ce = str(env_data.get("caregiver_engagement", "Medium"))
        if ce not in ("Low", "Medium", "High"):
            ce = "Medium"
        le = str(env_data.get("language_exposure", "Adequate"))
        if le not in ("Adequate", "Inadequate"):
            le = "Adequate"
        sw = bool_sql(env_data.get("safe_water"))
        tf = bool_sql(env_data.get("toilet_facility"))

        env_batch.append(
            f"  ({RESULT_BASE_ID + env_count}, {cid}, {SESSION_BASE_ID + i}, "
            f"{pci}, {pmh}, {hs}, {play}, {esc(ce)}, {esc(le)}, {sw}, {tf})"
        )

        if len(env_batch) == 100:
            lines.append(
                "INSERT INTO environment_assessments (id, child_id, session_id, "
                "parent_child_interaction_score, parent_mental_health_score, "
                "home_stimulation_score, play_materials, caregiver_engagement, "
                "language_exposure, safe_water, toilet_facility) VALUES"
            )
            lines.append(",\n".join(env_batch))
            lines.append("ON CONFLICT (id) DO NOTHING;")
            lines.append("")
            env_batch = []

    if env_batch:
        lines.append(
            "INSERT INTO environment_assessments (id, child_id, session_id, "
            "parent_child_interaction_score, parent_mental_health_score, "
            "home_stimulation_score, play_materials, caregiver_engagement, "
            "language_exposure, safe_water, toilet_facility) VALUES"
        )
        lines.append(",\n".join(env_batch))
        lines.append("ON CONFLICT (id) DO NOTHING;")
        lines.append("")

    print(f"Generated {env_count} environment assessments")

    # --- 8. DATASETS TABLE + REGISTRATION ---
    lines.append("-- 8. DATASETS TABLE + REGISTRATION")
    lines.append("")
    lines.append("-- Add district_ids column if missing (table already created in section 0a)")
    lines.append("ALTER TABLE datasets ADD COLUMN IF NOT EXISTS district_ids int[] DEFAULT NULL;")
    lines.append("")
    lines.append("-- RLS for datasets")
    lines.append("ALTER TABLE datasets ENABLE ROW LEVEL SECURITY;")
    lines.append("DO $$ BEGIN")
    lines.append("  CREATE POLICY \"Anyone can read datasets\" ON datasets FOR SELECT USING (true);")
    lines.append("EXCEPTION WHEN duplicate_object THEN NULL;")
    lines.append("END $$;")
    lines.append("")

    # Register existing app data as default dataset (if not already registered)
    lines.append("-- Register existing App Data as default (if not exists)")
    lines.append("INSERT INTO datasets (id, name, name_te, project_id, district_id, state_id, is_default)")
    lines.append("SELECT 1, 'App Data', 'యాప్ డేటా', p.id, p.district_id, d.state_id, true")
    lines.append("FROM projects p JOIN districts d ON p.district_id = d.id")
    lines.append("WHERE p.id = (SELECT MIN(id) FROM projects WHERE id < 200)")
    lines.append("ON CONFLICT (id) DO NOTHING;")
    lines.append("")

    # Build district_ids array string: ARRAY[200,201,202,203]
    district_ids_list = sorted(district_to_id.values())
    district_ids_sql = "ARRAY[" + ",".join(str(d) for d in district_ids_list) + "]"

    # Register ECD Sample Data — use first project/district as primary, but store all district_ids
    first_project_id = PROJECT_BASE_ID
    first_district_id = DISTRICT_BASE_ID
    lines.append("-- Register ECD Sample Data (multi-district)")
    lines.append(f"INSERT INTO datasets (id, name, name_te, project_id, district_id, state_id, is_default, district_ids)")
    lines.append(f"VALUES (2, 'ECD Sample Data', 'ECD నమూనా డేటా', {first_project_id}, {first_district_id}, 1, false, '{{{','.join(str(d) for d in district_ids_list)}}}')")
    lines.append("ON CONFLICT (id) DO UPDATE SET project_id = EXCLUDED.project_id, district_id = EXCLUDED.district_id, district_ids = EXCLUDED.district_ids;")
    lines.append("")

    # Update sequences to avoid conflicts with new ID ranges
    lines.append("-- Update sequences to avoid conflicts")
    lines.append(f"SELECT setval('districts_id_seq', GREATEST((SELECT MAX(id) FROM districts), {max_district_id}));")
    lines.append(f"SELECT setval('projects_id_seq', GREATEST((SELECT MAX(id) FROM projects), {max_project_id}));")
    lines.append(f"SELECT setval('sectors_id_seq', GREATEST((SELECT MAX(id) FROM sectors), {max_sector_id}));")
    lines.append(f"SELECT setval('anganwadi_centres_id_seq', GREATEST((SELECT MAX(id) FROM anganwadi_centres), {max_awc_id}));")
    lines.append(f"SELECT setval('children_id_seq', GREATEST((SELECT MAX(id) FROM children), {CHILD_BASE_ID + 1100}));")
    lines.append(f"SELECT setval('screening_sessions_id_seq', GREATEST((SELECT MAX(id) FROM screening_sessions), {SESSION_BASE_ID + 1100}));")
    lines.append(f"SELECT setval('screening_results_id_seq', GREATEST((SELECT MAX(id) FROM screening_results), {RESULT_BASE_ID + 1100}));")
    lines.append("")

    lines.append("-- Done! ECD Sample Dataset imported successfully.")
    lines.append(f"-- Total: {len(reg)} children, {ref_count} referrals, {fu_count} follow-ups")

    # Write output
    sql = "\n".join(lines)
    with open(OUTPUT_PATH, "w") as f:
        f.write(sql)

    print(f"\nSQL written to {OUTPUT_PATH}")
    print(f"Run this SQL in Supabase SQL Editor to import the dataset.")


if __name__ == "__main__":
    generate_sql()
