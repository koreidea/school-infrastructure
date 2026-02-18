#!/usr/bin/env python3
"""
Generate SQL for 1000-child demo dataset from ECD_sample_data_sets.xlsx.
Outputs a single SQL file that can be executed on Supabase.

Reads: ECD_sample_data_sets.xlsx (in parent dir)
Writes: demo_1000_data.sql (in current dir)
"""

import openpyxl
import random
import math
from datetime import datetime, timedelta

XLSX_PATH = "../../ECD_sample_data_sets.xlsx"
OUTPUT_PATH = "demo_1000_data.sql"

# Existing AWC IDs from mock_data.sql: 1-10
# We'll distribute 1000 children across 10 AWCs (100 per AWC)
# AWC 1-5: Sector 1 (Gajuwaka), AWC 6-10: Sector 2 (Pendurthi)
# Existing children are 1-200, we'll start new children at 201

# AWW UUIDs from mock_data.sql
AWW_UUIDS = [
    f"10000000-0000-0000-0000-{str(i).zfill(12)}" for i in range(1, 11)
]

# Telugu child names
MALE_FIRST = [
    "Arjun", "Ravi", "Krishna", "Venkat", "Srinivas", "Naresh", "Suresh",
    "Mahesh", "Ganesh", "Rajesh", "Kiran", "Anil", "Mohan", "Gopal",
    "Harish", "Pavan", "Charan", "Tarun", "Varun", "Sai", "Pranav",
    "Aarav", "Dhruv", "Ishaan", "Reyansh", "Vivaan", "Aditya", "Arnav",
    "Kabir", "Shaurya", "Vihaan", "Advaith", "Atharv", "Rudra", "Ayaan",
    "Omkar", "Tanish", "Nihal", "Rohan", "Yash", "Anirudh", "Samarth",
    "Tejas", "Vikram", "Manish", "Rohit", "Ajay", "Vijay", "Ramesh", "Satish",
]

FEMALE_FIRST = [
    "Priya", "Lakshmi", "Sravani", "Divya", "Keerthi", "Mounika", "Swathi",
    "Anusha", "Bhavani", "Chandini", "Deepika", "Gayathri", "Harika",
    "Jyothi", "Kavya", "Lavanya", "Madhavi", "Nandini", "Padma", "Radhika",
    "Sahasra", "Teja", "Uma", "Vaishnavi", "Yamini", "Akshara", "Ananya",
    "Diya", "Eshwari", "Fatima", "Gowri", "Himaja", "Indu", "Janaki",
    "Kamala", "Likhitha", "Meghana", "Niharika", "Oviya", "Pooja",
    "Sahiti", "Tanvi", "Varsha", "Anjali", "Bhargavi", "Charitha",
    "Durga", "Esha", "Manasa", "Neelima",
]

LAST_NAMES = [
    "Reddy", "Naidu", "Kumar", "Rao", "Sharma", "Babu", "Devi",
    "Prasad", "Varma", "Chowdary", "Raju", "Swamy", "Gupta",
    "Patel", "Murthy", "Shetty", "Nair", "Pillai", "Iyer", "Goud",
]


def load_excel():
    """Load all sheets from the Excel file."""
    wb = openpyxl.load_workbook(XLSX_PATH, read_only=True)
    data = {}

    sheets = [
        "Registration", "Developmental_Risk", "Neuro_Behavioral",
        "Nutrition", "Environment_Caregiving", "Developmental_Assessment",
        "Baseline_Risk_Output", "Referral_Action", "Intervention_FollowUp",
        "Outcomes_Impact", "Behaviour_indicators",
    ]

    for name in sheets:
        ws = wb[name]
        rows = []
        headers = None
        for i, row in enumerate(ws.iter_rows(values_only=True)):
            # Filter out None-padded columns
            if i == 0:
                headers = [h for h in row if h is not None]
                continue
            if row[0] is None:
                continue
            rows.append(dict(zip(headers, row[:len(headers)])))
        data[name] = rows

    wb.close()
    return data


def esc(val):
    """Escape a string value for SQL."""
    if val is None:
        return "NULL"
    s = str(val).replace("'", "''")
    return f"'{s}'"


def bool_sql(val):
    """Convert to SQL boolean."""
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
    """Convert to number or NULL."""
    if val is None:
        return "NULL"
    try:
        return str(round(float(val), 2))
    except (ValueError, TypeError):
        return "NULL"


def int_or_null(val):
    """Convert to int or NULL."""
    if val is None:
        return "0"
    try:
        return str(int(float(val)))
    except (ValueError, TypeError):
        return "0"


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

    print(f"Loaded {len(reg)} children from Excel")

    lines = []
    lines.append("-- ============================================================")
    lines.append("-- Bal Vikas ECD App — 1000 Child Demo Dataset")
    lines.append("-- Generated from ECD_sample_data_sets.xlsx")
    lines.append("-- ============================================================")
    lines.append("")

    # First: Delete existing demo data (children > 200, sessions, results, etc.)
    lines.append("-- Clean up any existing demo data (keep original 200)")
    lines.append("DELETE FROM intervention_followups WHERE child_id > 200;")
    lines.append("DELETE FROM environment_assessments WHERE child_id > 200;")
    lines.append("DELETE FROM nutrition_assessments WHERE child_id > 200;")
    lines.append("DELETE FROM referrals WHERE child_id > 200;")
    lines.append("DELETE FROM screening_results WHERE child_id > 200;")
    lines.append("DELETE FROM screening_responses WHERE session_id IN (SELECT id FROM screening_sessions WHERE child_id > 200);")
    lines.append("DELETE FROM screening_sessions WHERE child_id > 200;")
    lines.append("DELETE FROM children WHERE id > 200;")
    lines.append("DELETE FROM users WHERE phone LIKE '9001%';")  # New parent phones
    lines.append("")

    # Also clean up existing results for children 1-200 to avoid duplicates
    lines.append("-- Clean results for first 200 children to regenerate with challenge fields")
    lines.append("DELETE FROM intervention_followups WHERE child_id <= 200;")
    lines.append("DELETE FROM environment_assessments WHERE child_id <= 200;")
    lines.append("DELETE FROM nutrition_assessments WHERE child_id <= 200;")
    lines.append("DELETE FROM referrals WHERE child_id <= 200;")
    lines.append("DELETE FROM screening_results WHERE child_id <= 200;")
    lines.append("DELETE FROM screening_responses WHERE session_id IN (SELECT id FROM screening_sessions WHERE child_id <= 200);")
    lines.append("DELETE FROM screening_sessions WHERE child_id <= 200;")
    lines.append("")

    # Reset sequences
    lines.append("SELECT setval('children_id_seq', 200, true);")
    lines.append("SELECT setval('screening_sessions_id_seq', 1, false);")
    lines.append("SELECT setval('screening_results_id_seq', 1, false);")
    lines.append("")

    # ============================================================
    # PARENTS + CHILDREN (for children 201-1000)
    # First 200 children already exist in mock_data.sql
    # ============================================================
    lines.append("-- ============================================================")
    lines.append("-- PARENTS for new children (201-1000)")
    lines.append("-- ============================================================")
    lines.append("")

    random.seed(42)  # Reproducible

    # Generate parents for children 201-1000 (800 new parents)
    parent_inserts = []
    for i in range(201, 1001):
        phone = f"9001{str(i).zfill(6)}"
        uuid = f"20000000-0000-0000-0001-{str(i).zfill(12)}"
        gender = "female" if random.random() < 0.6 else "male"
        if gender == "female":
            name = f"{random.choice(FEMALE_FIRST)} {random.choice(LAST_NAMES)}"
        else:
            name = f"{random.choice(MALE_FIRST)} {random.choice(LAST_NAMES)}"
        parent_inserts.append(
            f"  ('{uuid}', '{phone}', {esc(name)}, 'PARENT', '{gender}', 'te')"
        )

    # Batch insert parents in groups of 100
    for batch_start in range(0, len(parent_inserts), 100):
        batch = parent_inserts[batch_start:batch_start + 100]
        lines.append(
            "INSERT INTO users (id, phone, name, role, gender, preferred_language) VALUES"
        )
        lines.append(",\n".join(batch) + ";")
        lines.append("")

    # ============================================================
    # CHILDREN 201-1000
    # ============================================================
    lines.append("-- ============================================================")
    lines.append("-- CHILDREN 201-1000 (distributed across 10 AWCs)")
    lines.append("-- ============================================================")
    lines.append("")

    child_inserts = []
    for idx in range(200, 1000):
        i = idx + 1  # child_id = 201..1000
        r = reg[idx]  # Excel row (0-indexed, so idx=200 is child 201)

        # Parse fields from Excel
        gender_char = r.get("gender", "M")
        gender = "female" if gender_char == "F" else "male"

        dob = r.get("dob")
        if isinstance(dob, datetime):
            dob_str = dob.strftime("%Y-%m-%d")
        else:
            dob_str = "2023-06-15"  # fallback

        # Map AWC code from Excel to our AWC IDs (1-10)
        awc_code = int(float(r.get("awc_code", 1001)))
        awc_id = ((i - 1) % 10) + 1  # Distribute evenly: 1-10

        # AWW for this AWC
        aww_uuid = AWW_UUIDS[awc_id - 1]
        parent_uuid = f"20000000-0000-0000-0001-{str(i).zfill(12)}"

        child_unique_id = f"AP_ECD_{str(i).zfill(6)}"

        # Generate name
        if gender == "female":
            name = f"{random.choice(FEMALE_FIRST)} {random.choice(LAST_NAMES)}"
        else:
            name = f"{random.choice(MALE_FIRST)} {random.choice(LAST_NAMES)}"

        child_inserts.append(
            f"  ({i}, '{child_unique_id}', {esc(name)}, '{dob_str}', '{gender}', "
            f"{awc_id}, '{parent_uuid}', '{aww_uuid}')"
        )

    # Batch insert children in groups of 100
    for batch_start in range(0, len(child_inserts), 100):
        batch = child_inserts[batch_start:batch_start + 100]
        lines.append(
            "INSERT INTO children (id, child_unique_id, name, dob, gender, awc_id, parent_id, aww_id) VALUES"
        )
        lines.append(",\n".join(batch) + ";")
        lines.append("")

    lines.append("SELECT setval('children_id_seq', 1000, true);")
    lines.append("")

    # ============================================================
    # SCREENING SESSIONS + RESULTS for ALL 1000 children
    # ============================================================
    lines.append("-- ============================================================")
    lines.append("-- SCREENING SESSIONS & RESULTS for all 1000 children")
    lines.append("-- ============================================================")
    lines.append("")

    # For child_id 1-200: already exist, use them
    # For child_id 201-1000: just created above
    # Excel rows map 1:1: row[0] → child_id 1, row[999] → child_id 1000
    # But we need to adjust: for existing children (1-200), map Excel row to child_id

    # Map: Excel rows in order → child_id 1..1000
    # First 200 children already exist, children 201-1000 just created

    session_inserts = []
    result_inserts = []
    referral_inserts = []
    nutrition_inserts = []
    environment_inserts = []
    followup_inserts = []

    for idx in range(1000):
        child_id = idx + 1  # 1..1000
        r = reg[idx]
        dr = dev_risk[idx]
        nb = neuro[idx]
        nut = nutrition[idx]
        env = environment[idx]
        da = dev_assess[idx]
        bl = baseline[idx]
        ref = referral[idx]
        fu = followup[idx]
        out = outcomes[idx]
        beh = behaviour[idx]

        # AWC assignment
        if child_id <= 200:
            awc_id = ((child_id - 1) % 10) + 1
        else:
            awc_id = ((child_id - 1) % 10) + 1

        aww_uuid = AWW_UUIDS[awc_id - 1]

        # Child age
        age_months = int(float(r.get("age_months", 24) or 24))

        # Assessment cycle
        assessment_cycle = r.get("assessment_cycle", "Baseline") or "Baseline"

        # DQ scores
        gm_dq = num_or_null(da.get("GM_DQ"))
        fm_dq = num_or_null(da.get("FM_DQ"))
        lc_dq = num_or_null(da.get("LC_DQ"))
        cog_dq = num_or_null(da.get("COG_DQ"))
        se_dq = num_or_null(da.get("SE_DQ"))
        composite_dq = num_or_null(da.get("Composite_DQ"))

        # Delays
        gm_delay = int(float(dr.get("GM_delay", 0) or 0))
        fm_delay = int(float(dr.get("FM_delay", 0) or 0))
        lc_delay = int(float(dr.get("LC_delay", 0) or 0))
        cog_delay = int(float(dr.get("COG_delay", 0) or 0))
        se_delay = int(float(dr.get("SE_delay", 0) or 0))
        num_delays = int(float(dr.get("num_delays", 0) or 0))

        # Neuro-behavioral
        autism_risk = nb.get("autism_risk", "Low") or "Low"
        adhd_risk = nb.get("adhd_risk", "Low") or "Low"
        behavior_risk = nb.get("behavior_risk", "Low") or "Low"

        # Baseline
        baseline_score = int(float(bl.get("baseline_score", 0) or 0))
        baseline_category = bl.get("baseline_category", "Low") or "Low"

        # Behaviour
        behavior_score = int(float(beh.get("behaviour_score", 0) or 0))

        # Overall risk mapping
        if baseline_category == "High":
            overall_risk = "HIGH"
        elif baseline_category == "Medium":
            overall_risk = "MEDIUM"
        else:
            overall_risk = "LOW"

        referral_needed = baseline_category == "High"

        # Assessment date: spread across last 2 months
        days_ago = random.randint(0, 60)
        assess_date = (datetime.now() - timedelta(days=days_ago)).strftime("%Y-%m-%d")

        # Session
        session_inserts.append(
            f"  ({idx + 1}, {child_id}, '{aww_uuid}', '{assess_date}', {age_months}, "
            f"'completed', NOW(), NOW())"
        )

        # Result with challenge fields
        result_inserts.append(
            f"  ({idx + 1}, {idx + 1}, {child_id}, '{overall_risk}', "
            f"{'TRUE' if referral_needed else 'FALSE'}, "
            f"{gm_dq}, {fm_dq}, {lc_dq}, {cog_dq}, {se_dq}, {composite_dq}, "
            f"'{assessment_cycle}', {baseline_score}, '{baseline_category}', "
            f"{num_delays}, '{autism_risk}', '{adhd_risk}', '{behavior_risk}', "
            f"{behavior_score})"
        )

        # Referral
        ref_triggered = ref.get("referral_triggered", "No") or "No"
        ref_type_raw = ref.get("referral_type", "PHC") or "PHC"
        ref_reason = ref.get("referral_reason", "GDD") or "GDD"
        ref_status = ref.get("referral_status", "Pending") or "Pending"

        # Map referral types to valid enum values
        type_map = {
            "PHC": "PHC",
            "RBSK": "RBSK",
            "DEIC": "DEIC",
            "NRC": "NRC",
            "AWW Intervention": "AWW_INTERVENTION",
            "Parent Intervention": "PARENT_INTERVENTION",
            "AWW_INTERVENTION": "AWW_INTERVENTION",
            "PARENT_INTERVENTION": "PARENT_INTERVENTION",
        }
        ref_type = type_map.get(ref_type_raw, "PHC")

        # Map referral reasons
        reason_map = {
            "GDD": "GDD",
            "ADHD": "ADHD",
            "AUTISM": "AUTISM",
            "Autism": "AUTISM",
            "BEHAVIOUR": "BEHAVIOUR",
            "Behaviour": "BEHAVIOUR",
            "ENVIRONMENT": "ENVIRONMENT",
            "DOMAIN_DELAY": "DOMAIN_DELAY",
            "Domain Delay": "DOMAIN_DELAY",
        }
        ref_reason = reason_map.get(ref_reason, "GDD")

        # Map referral status
        status_map = {
            "Pending": "Pending",
            "Completed": "Completed",
            "Under Treatment": "Under_Treatment",
            "Under_Treatment": "Under_Treatment",
        }
        ref_status = status_map.get(ref_status, "Pending")

        # Always create a referral record for demo completeness
        ref_date = assess_date
        completed_date = "NULL"
        if ref_status == "Completed":
            cd = datetime.strptime(assess_date, "%Y-%m-%d") + timedelta(days=random.randint(5, 30))
            completed_date = f"'{cd.strftime('%Y-%m-%d')}'"

        referral_inserts.append(
            f"  ({child_id}, {idx + 1}, {idx + 1}, "
            f"{'TRUE' if ref_triggered == 'Yes' or baseline_category == 'High' else 'FALSE'}, "
            f"'{ref_type}', '{ref_reason}', '{ref_status}', "
            f"'{aww_uuid}', '{ref_date}', {completed_date})"
        )

        # Nutrition
        nut_underweight = bool_sql(nut.get("underweight", 0))
        nut_stunting = bool_sql(nut.get("stunting", 0))
        nut_wasting = bool_sql(nut.get("wasting", 0))
        nut_anemia = bool_sql(nut.get("anemia", 0))
        nut_score = int_or_null(nut.get("nutrition_score", 0))
        nut_risk = nut.get("nutrition_risk", "Low") or "Low"

        # Generate plausible height/weight/muac based on age
        if age_months <= 12:
            height = round(random.uniform(65, 78), 1)
            weight = round(random.uniform(5, 10), 1)
        elif age_months <= 24:
            height = round(random.uniform(75, 90), 1)
            weight = round(random.uniform(8, 13), 1)
        elif age_months <= 36:
            height = round(random.uniform(85, 100), 1)
            weight = round(random.uniform(10, 16), 1)
        elif age_months <= 48:
            height = round(random.uniform(92, 108), 1)
            weight = round(random.uniform(12, 18), 1)
        else:
            height = round(random.uniform(98, 115), 1)
            weight = round(random.uniform(14, 22), 1)
        muac = round(random.uniform(11.0, 16.5), 1)

        nutrition_inserts.append(
            f"  ({child_id}, {idx + 1}, {height}, {weight}, {muac}, "
            f"{nut_underweight}, {nut_stunting}, {nut_wasting}, {nut_anemia}, "
            f"{nut_score}, '{nut_risk}', '{assess_date}')"
        )

        # Environment
        pci = int(float(env.get("parent_child_interaction_score", 3) or 3))
        pmh = int(float(env.get("parent_mental_health_score", 5) or 5))
        hs = int(float(env.get("home_stimulation_score", 5) or 5))
        play = bool_sql(env.get("play_materials", "No"))
        caregiver = env.get("caregiver_engagement", "Medium") or "Medium"
        lang_exp = env.get("language_exposure", "Adequate") or "Adequate"
        water = bool_sql(env.get("safe_water", "No"))
        toilet = bool_sql(env.get("toilet_facility", "No"))

        # Clamp scores to valid ranges
        pci = max(1, min(5, pci))
        pmh = max(1, min(10, pmh))
        hs = max(1, min(10, hs))

        environment_inserts.append(
            f"  ({child_id}, {idx + 1}, {pci}, {pmh}, {hs}, "
            f"{play}, '{caregiver}', '{lang_exp}', {water}, {toilet})"
        )

        # Intervention follow-up
        fu_plan = bool_sql(fu.get("intervention_plan_generated", "No"))
        fu_activities = int_or_null(fu.get("home_activities_assigned", 0))
        fu_conducted = bool_sql(fu.get("followup_conducted", "No"))
        fu_status = fu.get("improvement_status", "Same") or "Same"

        out_reduction = int_or_null(out.get("reduction_in_delay_months", 0))
        out_domain = bool_sql(out.get("domain_improvement", "No"))
        out_autism_change = out.get("autism_risk_change", "Same") or "Same"
        out_exit = bool_sql(out.get("exit_high_risk", "No"))

        # Follow-up date
        fu_date = (datetime.strptime(assess_date, "%Y-%m-%d") + timedelta(days=random.randint(14, 45))).strftime("%Y-%m-%d")
        next_fu_date = (datetime.strptime(fu_date, "%Y-%m-%d") + timedelta(days=30)).strftime("%Y-%m-%d")

        followup_inserts.append(
            f"  ({child_id}, {idx + 1}, {fu_plan}, {fu_activities}, "
            f"{fu_conducted}, '{fu_date}', '{next_fu_date}', '{fu_status}', "
            f"{out_reduction}, {out_domain}, '{out_autism_change}', {out_exit}, "
            f"'{aww_uuid}')"
        )

    # Write session inserts in batches
    lines.append("-- Screening Sessions")
    for batch_start in range(0, len(session_inserts), 100):
        batch = session_inserts[batch_start:batch_start + 100]
        lines.append(
            "INSERT INTO screening_sessions "
            "(id, child_id, conducted_by, assessment_date, child_age_months, "
            "status, created_at, completed_at) VALUES"
        )
        lines.append(",\n".join(batch) + ";")
        lines.append("")

    lines.append("SELECT setval('screening_sessions_id_seq', 1000, true);")
    lines.append("")

    # Write result inserts in batches
    lines.append("-- Screening Results with challenge fields")
    for batch_start in range(0, len(result_inserts), 100):
        batch = result_inserts[batch_start:batch_start + 100]
        lines.append(
            "INSERT INTO screening_results "
            "(id, session_id, child_id, overall_risk, referral_needed, "
            "gm_dq, fm_dq, lc_dq, cog_dq, se_dq, composite_dq, "
            "assessment_cycle, baseline_score, baseline_category, "
            "num_delays, autism_risk, adhd_risk, behavior_risk, "
            "behavior_score) VALUES"
        )
        lines.append(",\n".join(batch) + ";")
        lines.append("")

    lines.append("SELECT setval('screening_results_id_seq', 1000, true);")
    lines.append("")

    # Referrals
    lines.append("-- Referrals")
    for batch_start in range(0, len(referral_inserts), 100):
        batch = referral_inserts[batch_start:batch_start + 100]
        lines.append(
            "INSERT INTO referrals "
            "(child_id, screening_result_id, session_id, "
            "referral_triggered, referral_type, referral_reason, "
            "referral_status, referred_by, referred_date, completed_date) VALUES"
        )
        lines.append(",\n".join(batch) + ";")
        lines.append("")

    # Nutrition
    lines.append("-- Nutrition Assessments")
    for batch_start in range(0, len(nutrition_inserts), 100):
        batch = nutrition_inserts[batch_start:batch_start + 100]
        lines.append(
            "INSERT INTO nutrition_assessments "
            "(child_id, session_id, height_cm, weight_kg, muac_cm, "
            "underweight, stunting, wasting, anemia, "
            "nutrition_score, nutrition_risk, assessed_date) VALUES"
        )
        lines.append(",\n".join(batch) + ";")
        lines.append("")

    # Environment
    lines.append("-- Environment Assessments")
    for batch_start in range(0, len(environment_inserts), 100):
        batch = environment_inserts[batch_start:batch_start + 100]
        lines.append(
            "INSERT INTO environment_assessments "
            "(child_id, session_id, parent_child_interaction_score, "
            "parent_mental_health_score, home_stimulation_score, "
            "play_materials, caregiver_engagement, language_exposure, "
            "safe_water, toilet_facility) VALUES"
        )
        lines.append(",\n".join(batch) + ";")
        lines.append("")

    # Follow-ups
    lines.append("-- Intervention Follow-ups")
    for batch_start in range(0, len(followup_inserts), 100):
        batch = followup_inserts[batch_start:batch_start + 100]
        lines.append(
            "INSERT INTO intervention_followups "
            "(child_id, screening_result_id, intervention_plan_generated, "
            "home_activities_assigned, followup_conducted, followup_date, "
            "next_followup_date, improvement_status, "
            "reduction_in_delay_months, domain_improvement, "
            "autism_risk_change, exit_high_risk, created_by) VALUES"
        )
        lines.append(",\n".join(batch) + ";")
        lines.append("")

    # Summary
    lines.append("-- ============================================================")
    lines.append("-- DONE! Summary:")
    lines.append("-- 800 new parents (201-1000)")
    lines.append("-- 800 new children (201-1000)")
    lines.append("-- 1000 screening sessions")
    lines.append("-- 1000 screening results with challenge fields")
    lines.append("-- 1000 referrals")
    lines.append("-- 1000 nutrition assessments")
    lines.append("-- 1000 environment assessments")
    lines.append("-- 1000 intervention follow-ups")
    lines.append("-- ============================================================")

    sql = "\n".join(lines)
    with open(OUTPUT_PATH, "w") as f:
        f.write(sql)
    print(f"Written {len(lines)} lines to {OUTPUT_PATH}")
    print(f"File size: {len(sql)} bytes")


if __name__ == "__main__":
    generate_sql()
