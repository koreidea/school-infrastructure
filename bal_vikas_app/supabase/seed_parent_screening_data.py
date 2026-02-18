#!/usr/bin/env python3
"""
Seed sample screening data for parent-linked children (IDs 1, 2, 3).
Creates: screening_sessions, screening_results, intervention_followups.
"""

import requests
import json

SQL_API_URL = "https://api.supabase.com/v1/projects/owfioycwviwjteviwkka/database/query"
HEADERS = {
    "Authorization": "Bearer sbp_573715d84de517dc89b7633fdef4225c73cf238a",
    "Content-Type": "application/json",
}

AWW_USER_ID = "10000000-0000-0000-0001-000000000001"


def run_sql(sql, label=""):
    resp = requests.post(SQL_API_URL, headers=HEADERS, json={"query": sql})
    if resp.status_code == 201:
        try:
            return True, resp.json()
        except Exception:
            return True, None
    else:
        print(f"  ERROR [{label}]: {resp.status_code} {resp.text}")
        return False, resp.text


# ============================================================
# Step 1: Create screening sessions
# ============================================================
print("=== Step 1: Creating screening sessions ===")

sessions_sql = f"""
INSERT INTO screening_sessions (child_id, conducted_by, assessment_date, child_age_months, status, completed_at)
VALUES
  (1, '{AWW_USER_ID}'::uuid, '2026-02-08', 8, 'completed', NOW()),
  (2, '{AWW_USER_ID}'::uuid, '2026-02-08', 10, 'completed', NOW()),
  (3, '{AWW_USER_ID}'::uuid, '2026-02-07', 60, 'completed', NOW())
RETURNING id, child_id;
"""

ok, result = run_sql(sessions_sql, "sessions")
if not ok:
    print("FAILED to create sessions. Aborting.")
    exit(1)

session_ids = {r["child_id"]: r["id"] for r in result}
print(f"  Created sessions: {session_ids}")

# ============================================================
# Step 2: Create screening results
# ============================================================
print("\n=== Step 2: Creating screening results ===")

# Child 1 (Keerthi, 8mo): MEDIUM risk, FM and LC delays
# Child 2 (Nikhil, 10mo): LOW risk, all on track
# Child 3 (Aditya, 60mo): HIGH risk, all 5 domains delayed

s1 = session_ids[1]
s2 = session_ids[2]
s3 = session_ids[3]

tool_results_1 = json.dumps({"cdc": {"risk": "MEDIUM"}, "rbsk": {"risk": "LOW"}})
concerns_1 = json.dumps(["Fine motor skills slightly delayed", "Language development needs attention"])
concerns_te_1 = json.dumps(["చిన్న మోటారు నైపుణ్యాలు కొంచెం ఆలస్యం", "భాషా అభివృద్ధికి శ్రద్ధ అవసరం"])

tool_results_2 = json.dumps({"cdc": {"risk": "LOW"}, "rbsk": {"risk": "LOW"}})
concerns_2 = json.dumps(["Development is on track"])
concerns_te_2 = json.dumps(["అభివృద్ధి సరైన దారిలో ఉంది"])

tool_results_3 = json.dumps({"cdc": {"risk": "HIGH"}, "rbsk": {"risk": "HIGH"}, "mchat": {"risk": "Moderate"}})
concerns_3 = json.dumps([
    "Significant delays across multiple domains",
    "Language and cognitive skills need immediate attention",
    "Fine motor skills below expected range",
])
concerns_te_3 = json.dumps([
    "అనేక డొమైన్లలో గణనీయమైన జాప్యాలు",
    "భాష మరియు అభిజ్ఞా నైపుణ్యాలకు తక్షణ శ్రద్ధ అవసరం",
    "చిన్న మోటారు నైపుణ్యాలు అంచనా పరిధి కంటే తక్కువ",
])

results_sql = f"""
INSERT INTO screening_results (
  session_id, child_id, overall_risk, overall_risk_te, referral_needed,
  gm_dq, fm_dq, lc_dq, cog_dq, se_dq, composite_dq,
  tool_results, concerns, concerns_te,
  tools_completed, tools_skipped,
  assessment_cycle, baseline_score, baseline_category,
  num_delays, autism_risk, adhd_risk, behavior_risk, behavior_score
)
VALUES
(
  {s1}, 1, 'MEDIUM', 'మధ్యస్థం', false,
  90.0, 72.0, 68.0, 88.0, 92.0, 82.0,
  '{tool_results_1}'::jsonb,
  '{concerns_1}'::jsonb,
  '{concerns_te_1}'::jsonb,
  3, 0,
  'Baseline', 14, 'Medium',
  2, 'Low', 'Low', 'Low', 2
),
(
  {s2}, 2, 'LOW', 'తక్కువ', false,
  95.0, 92.0, 88.0, 90.0, 94.0, 91.8,
  '{tool_results_2}'::jsonb,
  '{concerns_2}'::jsonb,
  '{concerns_te_2}'::jsonb,
  3, 0,
  'Baseline', 0, 'Low',
  0, 'Low', 'Low', 'Low', 0
),
(
  {s3}, 3, 'HIGH', 'అధికం', true,
  78.0, 65.0, 60.0, 72.0, 70.0, 69.0,
  '{tool_results_3}'::jsonb,
  '{concerns_3}'::jsonb,
  '{concerns_te_3}'::jsonb,
  5, 0,
  'Baseline', 33, 'High',
  5, 'Moderate', 'Moderate', 'High', 12
)
RETURNING id, child_id;
"""

ok2, result2 = run_sql(results_sql, "results")
if not ok2:
    print("FAILED to create results. Aborting.")
    exit(1)

result_ids = {r["child_id"]: r["id"] for r in result2}
print(f"  Created results: {result_ids}")

# ============================================================
# Step 3: Create intervention followups
# ============================================================
print("\n=== Step 3: Creating intervention followups ===")

r1 = result_ids[1]
r2 = result_ids[2]
r3 = result_ids[3]

followups_sql = f"""
INSERT INTO intervention_followups (
  child_id, screening_result_id,
  intervention_plan_generated, home_activities_assigned,
  followup_conducted, followup_date, next_followup_date,
  improvement_status, reduction_in_delay_months, domain_improvement,
  notes, created_by
)
VALUES
(
  1, {r1},
  true, 4,
  true, '2026-02-08', '2026-02-20',
  'Improving', 1, true,
  'FM and LC activities assigned. Parent actively participating.',
  '{AWW_USER_ID}'::uuid
),
(
  2, {r2},
  true, 3,
  true, '2026-02-08', '2026-02-25',
  'Stable', 0, false,
  'All domains on track. Continue age-appropriate activities.',
  '{AWW_USER_ID}'::uuid
),
(
  3, {r3},
  true, 6,
  true, '2026-02-07', '2026-02-14',
  'Needs more support', 0, false,
  'Multiple delays detected. Referral initiated. Intensive home activities assigned.',
  '{AWW_USER_ID}'::uuid
)
RETURNING id, child_id;
"""

ok3, result3 = run_sql(followups_sql, "followups")
if not ok3:
    print("FAILED to create followups.")
    exit(1)

followup_ids = {r["child_id"]: r["id"] for r in result3}
print(f"  Created followups: {followup_ids}")

# ============================================================
# Summary
# ============================================================
print("\n" + "=" * 60)
print("SEED DATA COMPLETE!")
print("=" * 60)
print(f"""
Children seeded:
  Child 1 (Keerthi Goud, 8mo):  MEDIUM risk, FM+LC delays
    DQ scores: GM=90, FM=72, LC=68, COG=88, SE=92, Composite=82
    Next followup: 2026-02-20, Status: Improving

  Child 2 (Nikhil Patel, 10mo): LOW risk, all on track
    DQ scores: GM=95, FM=92, LC=88, COG=90, SE=94, Composite=91.8
    Next followup: 2026-02-25, Status: Stable

  Child 3 (Aditya Rao, 60mo):   HIGH risk, all 5 domains delayed
    DQ scores: GM=78, FM=65, LC=60, COG=72, SE=70, Composite=69
    Next followup: 2026-02-14, Status: Needs more support
    Referral needed: YES
""")
