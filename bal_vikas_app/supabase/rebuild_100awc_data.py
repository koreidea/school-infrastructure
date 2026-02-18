#!/usr/bin/env python3
"""
Rebuild Bal Vikas demo data with:
- 5 Districts in AP
- 8 Projects
- 15 Sectors (mandals)
- 50 AWCs
- ~1000 children (18-25 per AWC)
- ~30% children with NO screening (pending)
- Proper officials per hierarchy level
"""

import random
import json
import requests
import time
import math

random.seed(42)

SUPABASE_TOKEN = "sbp_573715d84de517dc89b7633fdef4225c73cf238a"
PROJECT_REF = "owfioycwviwjteviwkka"
API_URL = f"https://api.supabase.com/v1/projects/{PROJECT_REF}/database/query"
HEADERS = {
    "Authorization": f"Bearer {SUPABASE_TOKEN}",
    "Content-Type": "application/json",
}


def execute_sql(sql, label=""):
    resp = requests.post(API_URL, headers=HEADERS, json={"query": sql})
    if resp.status_code == 201:
        return True
    else:
        print(f"  ERROR ({resp.status_code}): {resp.text[:500]}")
        return False


# ============================================================
# HIERARCHY DEFINITION
# ============================================================

HIERARCHY = {
    "state": {"name": "Andhra Pradesh", "code": "AP"},
    "districts": [
        {
            "name": "Visakhapatnam", "code": "VSP",
            "projects": [
                {
                    "name": "Visakhapatnam Urban", "code": "VSP_URB",
                    "sectors": [
                        {"name": "Gajuwaka", "code": "S_GAJ", "awcs": [
                            "Gajuwaka Ward-1", "Gajuwaka Ward-2", "Gajuwaka Ward-3", "Gajuwaka Ward-4"]},
                        {"name": "Pedagantyada", "code": "S_PED", "awcs": [
                            "Pedagantyada Main", "Pedagantyada Colony", "Pedagantyada East"]},
                    ]
                },
                {
                    "name": "Anakapalli", "code": "ANKP",
                    "sectors": [
                        {"name": "Anakapalli Town", "code": "S_ANK", "awcs": [
                            "Anakapalli Ward-1", "Anakapalli Ward-2", "Anakapalli Ward-3"]},
                    ]
                },
            ]
        },
        {
            "name": "Srikakulam", "code": "SKLM",
            "projects": [
                {
                    "name": "Srikakulam Urban", "code": "SKLM_URB",
                    "sectors": [
                        {"name": "Srikakulam Town", "code": "S_SKT", "awcs": [
                            "Srikakulam Ward-1", "Srikakulam Ward-2", "Srikakulam Ward-3", "Srikakulam Ward-4"]},
                        {"name": "Etcherla", "code": "S_ECH", "awcs": [
                            "Etcherla Main", "Etcherla Village", "Etcherla Colony", "Etcherla East"]},
                    ]
                },
            ]
        },
        {
            "name": "Vizianagaram", "code": "VZM",
            "projects": [
                {
                    "name": "Vizianagaram Urban", "code": "VZM_URB",
                    "sectors": [
                        {"name": "Vizianagaram Town", "code": "S_VZT", "awcs": [
                            "Vizianagaram Ward-1", "Vizianagaram Ward-2", "Vizianagaram Ward-3", "Vizianagaram Ward-4"]},
                        {"name": "Bobbili", "code": "S_BOB", "awcs": [
                            "Bobbili Main", "Bobbili Colony", "Bobbili Rural"]},
                    ]
                },
                {
                    "name": "Parvathipuram", "code": "PARV",
                    "sectors": [
                        {"name": "Parvathipuram Town", "code": "S_PAR", "awcs": [
                            "Parvathipuram Ward-1", "Parvathipuram Ward-2", "Parvathipuram Ward-3"]},
                    ]
                },
            ]
        },
        {
            "name": "East Godavari", "code": "EG",
            "projects": [
                {
                    "name": "Kakinada", "code": "KAKN",
                    "sectors": [
                        {"name": "Kakinada Urban", "code": "S_KKU", "awcs": [
                            "Kakinada Ward-1", "Kakinada Ward-2", "Kakinada Ward-3"]},
                        {"name": "Peddapuram", "code": "S_PDP", "awcs": [
                            "Peddapuram Main", "Peddapuram Colony", "Peddapuram Rural"]},
                    ]
                },
                {
                    "name": "Rajahmundry", "code": "RJHM",
                    "sectors": [
                        {"name": "Rajahmundry Urban", "code": "S_RJU", "awcs": [
                            "Rajahmundry Ward-1", "Rajahmundry Ward-2", "Rajahmundry Ward-3"]},
                        {"name": "Kadiam", "code": "S_KDM", "awcs": [
                            "Kadiam Main", "Kadiam Nursery", "Kadiam Village"]},
                    ]
                },
            ]
        },
        {
            "name": "Krishna", "code": "KRS",
            "projects": [
                {
                    "name": "Vijayawada", "code": "VJWD",
                    "sectors": [
                        {"name": "Vijayawada Central", "code": "S_VJC", "awcs": [
                            "Vijayawada Ward-1", "Vijayawada Ward-2", "Vijayawada Ward-3", "Vijayawada Ward-4"]},
                        {"name": "Benz Circle", "code": "S_BNZ", "awcs": [
                            "Benz Circle Main", "Benz Circle North", "Benz Circle South"]},
                        {"name": "Gunadala", "code": "S_GUN", "awcs": [
                            "Gunadala Centre", "Gunadala Hill", "Gunadala Village"]},
                    ]
                },
            ]
        },
    ]
}

# ============================================================
# NAME POOLS
# ============================================================
CHILD_MALE_NAMES = [
    "Aarav", "Advaith", "Ajay", "Akshay", "Arjun", "Arnav", "Atharv",
    "Bharath", "Charan", "Dhruv", "Ganesh", "Gopal", "Hari", "Ishaan",
    "Karthik", "Kiran", "Krishna", "Lokesh", "Manish", "Mohan",
    "Naga", "Nikhil", "Om", "Pavan", "Pranav", "Rahul", "Raju",
    "Ram", "Rohit", "Rudra", "Sai", "Samarth", "Satish", "Shiva",
    "Sri", "Suresh", "Tanish", "Varun", "Venkat", "Vivaan",
    "Yaswanth", "Aditya", "Anand", "Ashwin", "Balu", "Chandra",
    "Dinesh", "Eswar", "Gopi", "Harsha", "Jagadeesh", "Kalyan",
    "Lakshman", "Mahesh", "Naresh", "Prabhas", "Rajesh", "Sandeep",
    "Teja", "Uday", "Vamsi", "Yashwanth", "Arun", "Bhanu",
]

CHILD_FEMALE_NAMES = [
    "Aadhya", "Akshara", "Ananya", "Anjali", "Anusha", "Bhavana",
    "Charitha", "Deepika", "Diya", "Durga", "Gayathri", "Gowri",
    "Himaja", "Indu", "Jyothi", "Kamala", "Kavya", "Keerthi",
    "Lakshmi", "Lavanya", "Manasa", "Meghana", "Mounika", "Neelima",
    "Niharika", "Padma", "Priya", "Ramya", "Sahiti", "Sahasra",
    "Sravani", "Swathi", "Uma", "Vaishnavi", "Varsha", "Yamini",
    "Anuradha", "Bhavani", "Fatima", "Hemalatha", "Janaki",
    "Pushpalatha", "Radha", "Sarojini", "Sunitha", "Vijaya",
    "Annapurna", "Manga", "Kameshwari", "Tulasi", "Sridevi",
]

SURNAMES = [
    "Reddy", "Rao", "Kumar", "Naidu", "Devi", "Prasad", "Babu",
    "Varma", "Murthy", "Iyer", "Sharma", "Gupta", "Chowdary",
    "Pillai", "Goud", "Raju", "Swamy", "Patel", "Shetty", "Nair",
]

AWW_FEMALE_NAMES = [
    "Lakshmi Devi", "Padma Kumari", "Sridevi Rani", "Anuradha Devi",
    "Kavitha Kumari", "Sunitha Devi", "Radha Kumari", "Vijaya Lakshmi",
    "Manga Devi", "Durga Bhavani", "Sita Mahalakshmi", "Tulasi Rani",
    "Saraswathi Devi", "Kamala Kumari", "Annapurna Rani", "Bhavani Devi",
    "Parvathi Kumari", "Gowri Rani", "Savithri Devi", "Jaya Lakshmi",
    "Varalakshmi Devi", "Suseela Kumari", "Pushpa Rani", "Hemalatha Devi",
    "Padmavathi Kumari", "Manjula Rani", "Kalyani Devi", "Ratnamma Kumari",
    "Vimala Rani", "Nagamani Devi", "Sulochana Kumari", "Revathi Rani",
    "Vasantha Devi", "Bharathi Kumari", "Kameshwari Rani", "Janaki Devi",
    "Lalitha Kumari", "Sarojini Rani", "Swarnalatha Devi", "Bhanumathi Kumari",
    "Chandra Kumari", "Dhanalakshmi Rani", "Eswari Devi", "Girija Kumari",
    "Hymavathi Rani", "Indira Devi", "Jayanthi Kumari", "Krishnaveni Rani",
    "Madhavi Devi", "Niranjani Kumari", "Omkaramma Rani", "Prabhavathi Devi",
    "Ratnamala Kumari", "Shyamala Rani", "Triveni Devi", "Usharani Kumari",
    "Vasudha Rani", "Waheeda Devi", "Xaviera Kumari", "Yashodha Rani",
    "Zareena Devi", "Amruthavalli Kumari", "Bangaramma Rani", "Chandrakala Devi",
    "Damayanthi Kumari", "Eashwaramma Rani", "Fathimunnisa Devi", "Gangamma Kumari",
    "Hanumayamma Rani", "Iyyalaramma Devi", "Jagadamba Kumari", "Kameswari Rani",
    "Lakshmidevi Kumari", "Maheshwari Rani", "Narasamma Devi", "Obulamma Kumari",
    "Papamma Rani", "Rangamma Devi", "Seshamma Kumari", "Thulasamma Rani",
    "Ushamma Devi", "Venkatamma Kumari", "Wajeedunnisa Rani", "Yerramma Devi",
    "Zulekha Kumari", "Akkamma Rani", "Buchamma Devi", "Chinnamma Kumari",
    "Durgamma Rani", "Ellamma Devi", "Gajjelamma Kumari", "Hanumayyamma Rani",
    "Ijjamma Devi", "Jogiamma Kumari", "Kattamma Rani", "Lachamma Devi",
    "Maddilamma Kumari", "Nagamma Rani", "Odelu Ammma Devi", "Peddamma Kumari",
]

PARENT_MALE_NAMES = [
    "Ramesh", "Suresh", "Rajesh", "Nagaraju", "Srikanth", "Venkatesh",
    "Prasad", "Ravi", "Gopal", "Srinivas", "Krishna", "Mohan",
    "Satish", "Harish", "Kiran", "Anil", "Manoj", "Vijay",
    "Ashok", "Bhaskar", "Chandra", "Damodar", "Eswar", "Ganesh",
]

PARENT_FEMALE_NAMES = [
    "Sumalatha", "Pushpalatha", "Annapurna", "Sarojini", "Kamala",
    "Jyothi", "Hemalatha", "Padma", "Lakshmi", "Bhavani",
    "Priya", "Kavya", "Sravani", "Meghana", "Keerthi",
    "Deepika", "Lavanya", "Niharika", "Gayathri", "Mounika",
]


def random_child_name(gender):
    pool = CHILD_MALE_NAMES if gender == "male" else CHILD_FEMALE_NAMES
    return f"{random.choice(pool)} {random.choice(SURNAMES)}"


def random_parent_name():
    if random.random() < 0.5:
        return f"{random.choice(PARENT_MALE_NAMES)} {random.choice(SURNAMES)}", "male"
    else:
        return f"{random.choice(PARENT_FEMALE_NAMES)} {random.choice(SURNAMES)}", "female"


def random_dob():
    """Random DOB for 0-72 months age range."""
    # Children should be born between 2020-01-01 and 2025-10-01
    year = random.randint(2020, 2025)
    month = random.randint(1, 12)
    day = random.randint(1, 28)
    if year == 2025 and month > 10:
        month = random.randint(1, 10)
    return f"{year:04d}-{month:02d}-{day:02d}"


def age_months_from_dob(dob_str):
    """Calculate age in months from DOB string."""
    parts = dob_str.split("-")
    y, m, d = int(parts[0]), int(parts[1]), int(parts[2])
    # Reference date: ~2026-02-10
    months = (2026 - y) * 12 + (2 - m)
    if 10 < d:
        months -= 1
    return max(0, months)


def random_assessment_date():
    """Random date in the last 3 months."""
    month = random.choice([12, 1, 2])
    day = random.randint(1, 28)
    year = 2025 if month == 12 else 2026
    return f"{year:04d}-{month:02d}-{day:02d}"


def random_dq():
    """Random DQ score 50-140 with mean ~90."""
    return round(random.gauss(90, 20), 2)


def clamp_dq(v):
    return max(30.0, min(150.0, v))


def compute_risk(composite_dq, num_delays, baseline_score):
    """Determine risk level."""
    if baseline_score > 25:
        return "HIGH"
    elif baseline_score > 10:
        return "MEDIUM"
    else:
        return "LOW"


# ============================================================
# BUILD DATA STRUCTURES
# ============================================================

print("Building hierarchy...")

state_id = 1
district_id = 0
project_id = 0
sector_id = 0
awc_id = 0

districts_data = []
projects_data = []
sectors_data = []
awcs_data = []
awc_to_sector = {}
awc_to_district = {}

for district in HIERARCHY["districts"]:
    district_id += 1
    d = {"id": district_id, "state_id": state_id, "name": district["name"], "code": district["code"]}
    districts_data.append(d)

    for project in district["projects"]:
        project_id += 1
        p = {"id": project_id, "district_id": district_id, "name": project["name"], "code": project["code"]}
        projects_data.append(p)

        for sector in project["sectors"]:
            sector_id += 1
            s = {"id": sector_id, "project_id": project_id, "name": sector["name"], "code": sector["code"]}
            sectors_data.append(s)

            for awc_name in sector["awcs"]:
                awc_id += 1
                centre_code = f"{awc_id:04d}"
                a = {
                    "id": awc_id, "sector_id": sector_id,
                    "centre_code": centre_code, "name": awc_name,
                    "address": f"{awc_name}, {sector['name']}, {district['name']}"
                }
                awcs_data.append(a)
                awc_to_sector[awc_id] = sector_id
                awc_to_district[awc_id] = district_id

total_awcs = len(awcs_data)
print(f"Districts: {len(districts_data)}, Projects: {len(projects_data)}, "
      f"Sectors: {len(sectors_data)}, AWCs: {total_awcs}")

# ============================================================
# DISTRIBUTE CHILDREN ACROSS AWCs (18-25 per AWC)
# ============================================================

print("Distributing children...")

awc_child_counts = {}
total_children = 0
for awc in awcs_data:
    count = random.randint(18, 25)
    awc_child_counts[awc["id"]] = count
    total_children += count

print(f"Total children to create: {total_children}")

# Generate children
children_data = []
parents_data = []
child_id = 0
parent_id = 0

for awc in awcs_data:
    n = awc_child_counts[awc["id"]]
    for i in range(n):
        child_id += 1
        parent_id += 1
        gender = random.choice(["male", "female"])
        name = random_child_name(gender)
        dob = random_dob()
        unique_id = f"AP_ECD_{child_id:06d}"

        parent_name, parent_gender = random_parent_name()
        parent_uuid = f"20000000-0000-0000-0002-{parent_id:012d}"
        parent_phone = f"9002{parent_id:06d}"

        parents_data.append({
            "id": parent_uuid,
            "phone": parent_phone,
            "name": parent_name,
            "gender": parent_gender,
        })

        aww_uuid = f"10000000-0000-0000-0001-{awc['id']:012d}"
        children_data.append({
            "id": child_id,
            "child_unique_id": unique_id,
            "name": name,
            "dob": dob,
            "gender": gender,
            "awc_id": awc["id"],
            "parent_id": parent_uuid,
            "aww_id": aww_uuid,
        })

print(f"Children: {len(children_data)}, Parents: {len(parents_data)}")

# ============================================================
# DECIDE WHICH CHILDREN GET SCREENING (70% screened, 30% pending)
# ============================================================

screened_children = random.sample(children_data, int(len(children_data) * 0.70))
screened_child_ids = {c["id"] for c in screened_children}
print(f"Screened: {len(screened_children)}, Pending: {len(children_data) - len(screened_children)}")

# Generate screening sessions + results
sessions_data = []
results_data = []
session_id = 0

for child in screened_children:
    session_id += 1
    dob = child["dob"]
    age = age_months_from_dob(dob)
    assess_date = random_assessment_date()

    sessions_data.append({
        "id": session_id,
        "child_id": child["id"],
        "conducted_by": child["aww_id"],
        "assessment_date": assess_date,
        "child_age_months": max(1, age),
        "status": "completed",
    })

    # Generate risk scores
    gm_dq = clamp_dq(random_dq())
    fm_dq = clamp_dq(random_dq())
    lc_dq = clamp_dq(random_dq())
    cog_dq = clamp_dq(random_dq())
    se_dq = clamp_dq(random_dq())
    composite_dq = round((gm_dq + fm_dq + lc_dq + cog_dq + se_dq) / 5, 2)

    num_delays = sum(1 for dq in [gm_dq, fm_dq, lc_dq, cog_dq, se_dq] if dq < 85)
    autism_risk = random.choices(["Low", "Moderate", "High"], weights=[70, 20, 10])[0]
    adhd_risk = random.choices(["Low", "Moderate", "High"], weights=[70, 20, 10])[0]
    behavior_risk = random.choices(["Low", "High"], weights=[80, 20])[0]
    behavior_score = random.randint(0, 20)

    score = num_delays * 5
    score += {"Low": 0, "Moderate": 8, "High": 15}[autism_risk]
    score += {"Low": 0, "Moderate": 4, "High": 8}[adhd_risk]
    score += {"Low": 0, "High": 7}[behavior_risk]

    baseline_cat = "Low" if score <= 10 else ("Medium" if score <= 25 else "High")
    overall_risk = compute_risk(composite_dq, num_delays, score)
    referral = overall_risk == "HIGH"
    cycle = random.choices(["Baseline", "Follow-up"], weights=[60, 40])[0]

    results_data.append({
        "id": session_id,
        "session_id": session_id,
        "child_id": child["id"],
        "overall_risk": overall_risk,
        "referral_needed": referral,
        "gm_dq": gm_dq, "fm_dq": fm_dq, "lc_dq": lc_dq,
        "cog_dq": cog_dq, "se_dq": se_dq, "composite_dq": composite_dq,
        "assessment_cycle": cycle,
        "baseline_score": score,
        "baseline_category": baseline_cat,
        "num_delays": num_delays,
        "autism_risk": autism_risk,
        "adhd_risk": adhd_risk,
        "behavior_risk": behavior_risk,
        "behavior_score": behavior_score,
    })

print(f"Sessions: {len(sessions_data)}, Results: {len(results_data)}")

# Count risk distribution
risk_dist = {"LOW": 0, "MEDIUM": 0, "HIGH": 0}
for r in results_data:
    risk_dist[r["overall_risk"]] += 1
print(f"Risk distribution: {risk_dist}")

# ============================================================
# GENERATE REFERRALS for HIGH risk children
# ============================================================

referral_types = ["PHC", "RBSK", "DEIC", "NRC", "AWW_INTERVENTION", "PARENT_INTERVENTION"]
referral_reasons = ["GDD", "ADHD", "AUTISM", "BEHAVIOUR", "DOMAIN_DELAY"]
referral_statuses = ["Pending", "Completed", "Under_Treatment"]

referrals_data = []
ref_id = 0
for r in results_data:
    if r["overall_risk"] == "HIGH" or (r["overall_risk"] == "MEDIUM" and random.random() < 0.3):
        ref_id += 1
        referrals_data.append({
            "id": ref_id,
            "child_id": r["child_id"],
            "screening_result_id": r["id"],
            "session_id": r["session_id"],
            "referral_triggered": True,
            "referral_type": random.choice(referral_types),
            "referral_reason": random.choice(referral_reasons),
            "referral_status": random.choices(referral_statuses, weights=[40, 35, 25])[0],
            "referred_date": random_assessment_date(),
        })
print(f"Referrals: {len(referrals_data)}")

# ============================================================
# GENERATE INTERVENTION FOLLOWUPS for some screened children
# ============================================================

followups_data = []
fu_id = 0
for r in results_data:
    if random.random() < 0.25:  # 25% have follow-up data
        fu_id += 1
        imp_status = random.choices(["Improved", "Same", "Worsened"], weights=[50, 35, 15])[0]
        followups_data.append({
            "id": fu_id,
            "child_id": r["child_id"],
            "screening_result_id": r["id"],
            "followup_conducted": True,
            "improvement_status": imp_status,
            "domain_improvement": imp_status == "Improved",
            "exit_high_risk": imp_status == "Improved" and r["overall_risk"] == "HIGH",
            "reduction_in_delay_months": random.randint(0, 3) if imp_status == "Improved" else 0,
        })
print(f"Followups: {len(followups_data)}")

# ============================================================
# BUILD AWW USERS (1 per AWC)
# ============================================================

aww_users = []
for i, awc in enumerate(awcs_data):
    aww_uuid = f"10000000-0000-0000-0001-{awc['id']:012d}"
    phone = f"700{awc['id']:07d}"
    name = AWW_FEMALE_NAMES[i % len(AWW_FEMALE_NAMES)]
    aww_users.append({
        "id": aww_uuid,
        "phone": phone,
        "name": name,
        "role": "AWW",
        "gender": "female",
        "awc_id": awc["id"],
    })

# ============================================================
# BUILD SUPERVISOR USERS (1 per sector)
# ============================================================

supervisor_users = []
sv_names = [
    "Saraswathi Kumari", "Bhavani Prasad", "Padmaja Reddy", "Anitha Rani",
    "Vijayalakshmi Devi", "Sumithra Kumari", "Jayashree Rao", "Meenakshi Devi",
    "Usha Rani", "Prameela Kumari", "Vasantha Devi", "Indira Kumari",
    "Sarala Rani", "Kamala Devi", "Nirmala Kumari", "Shantha Devi",
    "Bharathi Kumari", "Lalitha Devi", "Radhika Kumari", "Sujatha Devi",
    "Sarojini Kumari", "Parvathi Devi", "Geetha Kumari", "Amrutha Devi",
    "Susheela Rani",
]

for i, sector in enumerate(sectors_data):
    sv_uuid = f"00000000-0000-0000-0001-{sector['id']:012d}"
    phone = f"800{sector['id']:07d}"
    name = sv_names[i % len(sv_names)]
    supervisor_users.append({
        "id": sv_uuid,
        "phone": phone,
        "name": name,
        "role": "SUPERVISOR",
        "gender": "female",
        "sector_id": sector["id"],
    })

# ============================================================
# BUILD CDPO/CW/EO USERS (1 each per project)
# ============================================================

cdpo_users = []
cdpo_names = [
    "Rajeshwari Devi", "Varalakshmi Reddy", "Suseelamma Naidu",
    "Padmavathi Rao", "Srilakshmi Sharma", "Kameshwari Kumari",
    "Ratnamala Devi", "Parvathamma Reddy", "Bhavani Rao",
    "Janaki Devi", "Lalitha Kumari",
]

project_official_idx = 0
for i, proj in enumerate(projects_data):
    project_official_idx += 1
    # CDPO
    cdpo_uuid = f"00000000-0000-0000-0002-{proj['id']:012d}"
    cdpo_phone = f"801{proj['id']:07d}"
    cdpo_users.append({
        "id": cdpo_uuid,
        "phone": cdpo_phone,
        "name": cdpo_names[i % len(cdpo_names)],
        "role": "CDPO",
        "gender": "female",
        "project_id": proj["id"],
    })

# ============================================================
# BUILD DW USERS (1 per district)
# ============================================================

dw_users = []
dw_names = ["Venkata Lakshmi", "Sarada Devi", "Jhansi Rani", "Nagamani Kumari", "Kalyani Devi"]

for i, dist in enumerate(districts_data):
    dw_uuid = f"00000000-0000-0000-0003-{dist['id']:012d}"
    dw_phone = f"802{dist['id']:07d}"
    dw_users.append({
        "id": dw_uuid,
        "phone": dw_phone,
        "name": dw_names[i % len(dw_names)],
        "role": "DW",
        "gender": "female",
        "district_id": dist["id"],
    })

# Senior Official (state level)
senior_official = {
    "id": "00000000-0000-0000-0004-000000000001",
    "phone": "8030000001",
    "name": "Ramachandra Murthy",
    "role": "SENIOR_OFFICIAL",
    "gender": "male",
    "state_id": 1,
}


# ============================================================
# GENERATE SQL
# ============================================================

def esc(s):
    """Escape single quotes for SQL."""
    if s is None:
        return "NULL"
    return str(s).replace("'", "''")


def sql_val(v):
    if v is None:
        return "NULL"
    if isinstance(v, bool):
        return "TRUE" if v else "FALSE"
    if isinstance(v, (int, float)):
        return str(v)
    return f"'{esc(v)}'"


print("\nGenerating SQL...")

sql_parts = []

# Part 1: CLEANUP
sql_parts.append("""
-- ============================================================
-- CLEANUP: Remove all existing data
-- ============================================================
DELETE FROM intervention_followups;
DELETE FROM environment_assessments;
DELETE FROM nutrition_assessments;
DELETE FROM referrals;
DELETE FROM screening_results;
DELETE FROM screening_responses;
DELETE FROM screening_sessions;
DELETE FROM children;
DELETE FROM users WHERE role != 'ADMIN';
DELETE FROM anganwadi_centres;
DELETE FROM sectors;
DELETE FROM projects;
DELETE FROM districts;
DELETE FROM states;
""")

# Part 2: SEQUENCES RESET
sql_parts.append("""
SELECT setval('states_id_seq', 1, false);
SELECT setval('districts_id_seq', 1, false);
SELECT setval('projects_id_seq', 1, false);
SELECT setval('sectors_id_seq', 1, false);
SELECT setval('anganwadi_centres_id_seq', 1, false);
SELECT setval('children_id_seq', 1, false);
SELECT setval('screening_sessions_id_seq', 1, false);
SELECT setval('screening_results_id_seq', 1, false);
SELECT setval('referrals_id_seq', 1, false);
SELECT setval('intervention_followups_id_seq', 1, false);
""")

# Part 3: STATE
sql_parts.append(f"INSERT INTO states (id, name, code) VALUES (1, 'Andhra Pradesh', 'AP');")

# Part 4: DISTRICTS
vals = ", ".join(
    f"({d['id']}, {d['state_id']}, '{esc(d['name'])}', '{esc(d['code'])}')"
    for d in districts_data
)
sql_parts.append(f"INSERT INTO districts (id, state_id, name, code) VALUES {vals};")

# Part 5: PROJECTS
vals = ", ".join(
    f"({p['id']}, {p['district_id']}, '{esc(p['name'])}', '{esc(p['code'])}')"
    for p in projects_data
)
sql_parts.append(f"INSERT INTO projects (id, district_id, name, code) VALUES {vals};")

# Part 6: SECTORS
vals = ", ".join(
    f"({s['id']}, {s['project_id']}, '{esc(s['name'])}', '{esc(s['code'])}')"
    for s in sectors_data
)
sql_parts.append(f"INSERT INTO sectors (id, project_id, name, code) VALUES {vals};")

# Part 7: AWCs
vals = ", ".join(
    f"({a['id']}, {a['sector_id']}, '{esc(a['centre_code'])}', '{esc(a['name'])}', '{esc(a['address'])}')"
    for a in awcs_data
)
sql_parts.append(f"INSERT INTO anganwadi_centres (id, sector_id, centre_code, name, address) VALUES {vals};")

# Part 8: OFFICIALS
# Senior Official
so = senior_official
sql_parts.append(
    f"INSERT INTO users (id, phone, name, role, gender, state_id, preferred_language) VALUES "
    f"('{so['id']}', '{so['phone']}', '{esc(so['name'])}', '{so['role']}', '{so['gender']}', {so['state_id']}, 'te');"
)

# DWs
for dw in dw_users:
    sql_parts.append(
        f"INSERT INTO users (id, phone, name, role, gender, district_id, preferred_language) VALUES "
        f"('{dw['id']}', '{dw['phone']}', '{esc(dw['name'])}', 'DW', '{dw['gender']}', {dw['district_id']}, 'te');"
    )

# CDPOs
for c in cdpo_users:
    sql_parts.append(
        f"INSERT INTO users (id, phone, name, role, gender, project_id, preferred_language) VALUES "
        f"('{c['id']}', '{c['phone']}', '{esc(c['name'])}', 'CDPO', '{c['gender']}', {c['project_id']}, 'te');"
    )

# Supervisors
for sv in supervisor_users:
    sql_parts.append(
        f"INSERT INTO users (id, phone, name, role, gender, sector_id, preferred_language) VALUES "
        f"('{sv['id']}', '{sv['phone']}', '{esc(sv['name'])}', 'SUPERVISOR', '{sv['gender']}', {sv['sector_id']}, 'te');"
    )

# AWWs — batch in groups of 20
for batch_start in range(0, len(aww_users), 20):
    batch = aww_users[batch_start:batch_start + 20]
    vals = ", ".join(
        f"('{a['id']}', '{a['phone']}', '{esc(a['name'])}', 'AWW', 'female', {a['awc_id']}, 'te')"
        for a in batch
    )
    sql_parts.append(
        f"INSERT INTO users (id, phone, name, role, gender, awc_id, preferred_language) VALUES {vals};"
    )

# Parents — batch in groups of 50
for batch_start in range(0, len(parents_data), 50):
    batch = parents_data[batch_start:batch_start + 50]
    vals = ", ".join(
        f"('{p['id']}', '{p['phone']}', '{esc(p['name'])}', 'PARENT', '{p['gender']}', 'te')"
        for p in batch
    )
    sql_parts.append(
        f"INSERT INTO users (id, phone, name, role, gender, preferred_language) VALUES {vals};"
    )

# Children — batch in groups of 50
for batch_start in range(0, len(children_data), 50):
    batch = children_data[batch_start:batch_start + 50]
    vals = ", ".join(
        f"({c['id']}, '{c['child_unique_id']}', '{esc(c['name'])}', '{c['dob']}', "
        f"'{c['gender']}', {c['awc_id']}, '{c['parent_id']}', '{c['aww_id']}')"
        for c in batch
    )
    sql_parts.append(
        f"INSERT INTO children (id, child_unique_id, name, dob, gender, awc_id, parent_id, aww_id) VALUES {vals};"
    )

# Screening sessions — batch in groups of 50
for batch_start in range(0, len(sessions_data), 50):
    batch = sessions_data[batch_start:batch_start + 50]
    vals = ", ".join(
        f"({s['id']}, {s['child_id']}, '{s['conducted_by']}', '{s['assessment_date']}', "
        f"{s['child_age_months']}, 'completed', NOW(), NOW())"
        for s in batch
    )
    sql_parts.append(
        f"INSERT INTO screening_sessions (id, child_id, conducted_by, assessment_date, "
        f"child_age_months, status, created_at, completed_at) VALUES {vals};"
    )

# Screening results — batch in groups of 50
for batch_start in range(0, len(results_data), 50):
    batch = results_data[batch_start:batch_start + 50]
    vals = ", ".join(
        f"({r['id']}, {r['session_id']}, {r['child_id']}, '{r['overall_risk']}', "
        f"{'TRUE' if r['referral_needed'] else 'FALSE'}, "
        f"{r['gm_dq']}, {r['fm_dq']}, {r['lc_dq']}, {r['cog_dq']}, {r['se_dq']}, {r['composite_dq']}, "
        f"'{r['assessment_cycle']}', {r['baseline_score']}, '{r['baseline_category']}', "
        f"{r['num_delays']}, '{r['autism_risk']}', '{r['adhd_risk']}', '{r['behavior_risk']}', {r['behavior_score']})"
        for r in batch
    )
    sql_parts.append(
        f"INSERT INTO screening_results (id, session_id, child_id, overall_risk, referral_needed, "
        f"gm_dq, fm_dq, lc_dq, cog_dq, se_dq, composite_dq, "
        f"assessment_cycle, baseline_score, baseline_category, num_delays, "
        f"autism_risk, adhd_risk, behavior_risk, behavior_score) VALUES {vals};"
    )

# Referrals — batch in groups of 50
for batch_start in range(0, len(referrals_data), 50):
    batch = referrals_data[batch_start:batch_start + 50]
    vals = ", ".join(
        f"({r['id']}, {r['child_id']}, {r['screening_result_id']}, {r['session_id']}, "
        f"TRUE, '{r['referral_type']}', '{r['referral_reason']}', '{r['referral_status']}', "
        f"'{r['referred_date']}')"
        for r in batch
    )
    sql_parts.append(
        f"INSERT INTO referrals (id, child_id, screening_result_id, session_id, "
        f"referral_triggered, referral_type, referral_reason, referral_status, referred_date) VALUES {vals};"
    )

# Intervention followups — batch in groups of 50
for batch_start in range(0, len(followups_data), 50):
    batch = followups_data[batch_start:batch_start + 50]
    vals = ", ".join(
        f"({f['id']}, {f['child_id']}, {f['screening_result_id']}, "
        f"TRUE, '{f['improvement_status']}', "
        f"{'TRUE' if f['domain_improvement'] else 'FALSE'}, "
        f"{'TRUE' if f['exit_high_risk'] else 'FALSE'}, "
        f"{f['reduction_in_delay_months']})"
        for f in batch
    )
    sql_parts.append(
        f"INSERT INTO intervention_followups (id, child_id, screening_result_id, "
        f"followup_conducted, improvement_status, domain_improvement, exit_high_risk, "
        f"reduction_in_delay_months) VALUES {vals};"
    )

# Sequence resets at end
sql_parts.append(f"SELECT setval('children_id_seq', {len(children_data)}, true);")
sql_parts.append(f"SELECT setval('screening_sessions_id_seq', {len(sessions_data)}, true);")
sql_parts.append(f"SELECT setval('screening_results_id_seq', {len(results_data)}, true);")
sql_parts.append(f"SELECT setval('referrals_id_seq', {len(referrals_data)}, true);")
sql_parts.append(f"SELECT setval('intervention_followups_id_seq', {len(followups_data)}, true);")
sql_parts.append(f"SELECT setval('states_id_seq', 1, true);")
sql_parts.append(f"SELECT setval('districts_id_seq', {len(districts_data)}, true);")
sql_parts.append(f"SELECT setval('projects_id_seq', {len(projects_data)}, true);")
sql_parts.append(f"SELECT setval('sectors_id_seq', {len(sectors_data)}, true);")
sql_parts.append(f"SELECT setval('anganwadi_centres_id_seq', {total_awcs}, true);")

# ============================================================
# EXECUTE SQL
# ============================================================

print(f"\nTotal SQL statements: {len(sql_parts)}")
print("Executing on Supabase...")

# Group small statements together
groups = []
current_group = []
current_size = 0

for stmt in sql_parts:
    stmt_size = len(stmt)
    if current_size + stmt_size > 60000 and current_group:
        groups.append("\n".join(current_group))
        current_group = [stmt]
        current_size = stmt_size
    else:
        current_group.append(stmt)
        current_size += stmt_size

if current_group:
    groups.append("\n".join(current_group))

print(f"Grouped into {len(groups)} API calls\n")

success = 0
failed = 0
for i, group in enumerate(groups):
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
        # Retry individual statements
        print(f"  Retrying individual statements...")
        sub_stmts = group.split(";")
        for j, sub in enumerate(sub_stmts):
            sub = sub.strip()
            if not sub or sub.startswith("--"):
                continue
            ok2 = execute_sql(sub + ";", f"sub-{j}")
            if ok2:
                print(f"    Sub-{j+1} OK")
            else:
                print(f"    Sub-{j+1} FAILED")
            time.sleep(0.3)

    time.sleep(0.5)

print(f"\n{'='*60}")
print(f"Done! {success} succeeded, {failed} failed out of {len(groups)} groups")
print(f"\nData Summary:")
print(f"  State: 1 (Andhra Pradesh)")
print(f"  Districts: {len(districts_data)}")
print(f"  Projects: {len(projects_data)}")
print(f"  Sectors: {len(sectors_data)}")
print(f"  AWCs: {total_awcs}")
print(f"  AWW Users: {len(aww_users)}")
print(f"  Supervisor Users: {len(supervisor_users)}")
print(f"  CDPO Users: {len(cdpo_users)}")
print(f"  DW Users: {len(dw_users)}")
print(f"  Senior Official: 1")
print(f"  Parents: {len(parents_data)}")
print(f"  Children: {len(children_data)}")
print(f"  Screened: {len(screened_children)} ({len(screened_children)*100//len(children_data)}%)")
print(f"  Pending (no screening): {len(children_data) - len(screened_children)}")
print(f"  Referrals: {len(referrals_data)}")
print(f"  Followups: {len(followups_data)}")
print(f"  Risk: LOW={risk_dist['LOW']}, MEDIUM={risk_dist['MEDIUM']}, HIGH={risk_dist['HIGH']}")
print(f"\nLogin phones:")
print(f"  Senior Official: 8030000001")
print(f"  DW (Visakhapatnam): 8020000001")
print(f"  DW (Srikakulam): 8020000002")
print(f"  CDPO (VSP Urban): 8010000001")
print(f"  Supervisor (Gajuwaka): 8000000001")
print(f"  AWW (AWC #1): 7000000001")
print(f"  Password for all: pilot123456")
