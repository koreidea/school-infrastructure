-- ============================================================
-- Bal Vikas ECD App — Seed Data for screening_config_schema
-- Run this AFTER screening_config_schema.sql
--
-- Idempotent: uses ON CONFLICT DO NOTHING throughout.
-- ============================================================

BEGIN;

-- ============================================================
-- 1. SCREENING TOOL CONFIGS (11 rows)
-- ============================================================

INSERT INTO screening_tool_configs (tool_type, tool_id, name, name_te, description, description_te, min_age_months, max_age_months, response_format, domains, icon_name, color_hex, sort_order, is_age_bracket_filtered)
VALUES
  ('cdcMilestones', 'cdc_milestones', 'CDC Developmental Milestones', 'CDC అభివృద్ధి మైలురాళ్ళు', 'Assesses developmental milestones across 5 domains based on CDC guidelines', 'CDC మార్గదర్శకాల ఆధారంగా 5 రంగాలలో అభివృద్ధి మైలురాళ్ళను అంచనా వేస్తుంది', 0, 72, 'yesNo', '["gm","fm","lc","cog","se"]', 'child_care', '#2196F3', 1, true),
  ('rbskTool', 'rbsk_tool', 'RBSK Developmental Tool', 'RBSK అభివృద్ధి సాధనం', 'Rashtriya Bal Swasthya Karyakram - 25 items across 5 developmental domains', 'రాష్ట్రీయ బాల్ స్వాస్థ్య కార్యక్రమం - 5 అభివృద్ధి రంగాలలో 25 అంశాలు', 36, 72, 'threePoint', '["motor","cognitive","language","social","adaptive"]', 'medical_services', '#009688', 2, false),
  ('mchatAutism', 'mchat_autism', 'M-CHAT Autism Screening', 'M-CHAT ఆటిజం స్క్రీనింగ్', 'Modified Checklist for Autism in Toddlers - 20 items with 6 critical items', 'చిన్న పిల్లలలో ఆటిజం కోసం సవరించిన చెక్‌లిస్ట్ - 6 క్లిష్టమైన అంశాలతో 20 అంశాలు', 16, 30, 'yesNo', '["autism_risk"]', 'psychology', '#9C27B0', 3, false),
  ('isaaAutism', 'isaa_autism', 'ISAA Autism Assessment', 'ISAA ఆటిజం అంచనా', 'Indian Scale for Assessment of Autism - 40 items across 6 domains (score range 40-200)', 'ఆటిజం అంచనా కోసం భారతీయ స్కేల్ - 6 రంగాలలో 40 అంశాలు (స్కోర్ పరిధి 40-200)', 36, 72, 'fivePoint', '["social","emotional","behavior","communication","sensory","cognitive"]', 'psychology_alt', '#673AB7', 4, false),
  ('adhdScreening', 'adhd_screening', 'ADHD Screening', 'ADHD స్క్రీనింగ్', 'Screens for Attention-Deficit/Hyperactivity Disorder - 10 items across 3 subscales', 'శ్రద్ధ-లోపం/హైపర్‌యాక్టివిటీ డిజార్డర్ కోసం స్క్రీన్ - 3 ఉపమానాలలో 10 అంశాలు', 36, 72, 'yesNo', '["inattention","hyperactivity","impulsivity"]', 'flash_on', '#FF5722', 5, false),
  ('rbskBehavioral', 'rbsk_behavioral', 'RBSK Behavioral Screening', 'RBSK ప్రవర్తన స్క్రీనింగ్', 'RBSK Behavioral checklist - 10 items for behavioral concerns', 'RBSK ప్రవర్తన చెక్‌లిస్ట్ - ప్రవర్తన సమస్యల కోసం 10 అంశాలు', 24, 72, 'yesNo', '["behavioral"]', 'warning_amber', '#FF9800', 6, false),
  ('sdqBehavioral', 'sdq_behavioral', 'SDQ Behavioral Assessment', 'SDQ ప్రవర్తన అంచనా', 'Strengths and Difficulties Questionnaire - 25 items + 8 impact items across 5 subscales', 'బలాలు మరియు కష్టాల ప్రశ్నాపత్రం - 5 ఉపమానాలలో 25 అంశాలు + 8 ప్రభావ అంశాలు', 24, 72, 'threePoint', '["emotional","conduct","hyperactivity","peer","prosocial"]', 'balance', '#795548', 7, false),
  ('parentChildInteraction', 'parent_child_interaction', 'Parent-Child Interaction', 'తల్లిదండ్రులు-బిడ్డ పరస్పర చర్య', 'Assesses quality of parent-child interaction - 24 items across 5 domains', 'తల్లిదండ్రులు-బిడ్డ పరస్పర చర్య నాణ్యతను అంచనా వేస్తుంది - 5 రంగాలలో 24 అంశాలు', 0, 72, 'yesNo', '["responsiveness","affection","encouragement","teaching","structure"]', 'family_restroom', '#E91E63', 8, false),
  ('parentMentalHealth', 'phq9_parent', 'Parent Mental Health (PHQ-9)', 'తల్లిదండ్రుల మానసిక ఆరోగ్యం (PHQ-9)', 'Patient Health Questionnaire-9 for caregiver depression screening (score range 0-27)', 'పోషకుడి నిరాశ స్క్రీనింగ్ కోసం రోగి ఆరోగ్య ప్రశ్నాపత్రం-9 (స్కోర్ పరిధి 0-27)', 0, 72, 'fourPoint', '["depression"]', 'favorite_border', '#607D8B', 9, false),
  ('homeStimulation', 'home_stimulation', 'Home Stimulation', 'ఇంటి ఉద్దీపన', 'Assesses home environment stimulation for child development - 22 items across 4 domains', 'పిల్లల అభివృద్ధి కోసం ఇంటి పరిసర ఉద్దీపనను అంచనా వేస్తుంది - 4 రంగాలలో 22 అంశాలు', 0, 72, 'yesNo', '["learning_materials","physical_environment","activities","safety"]', 'home', '#3F51B5', 10, false),
  ('nutritionAssessment', 'nutrition_assessment', 'Nutrition Assessment', 'పోషణ అంచనా', 'Assesses nutritional status through measurements and dietary questions', 'కొలతలు మరియు ఆహార ప్రశ్నల ద్వారా పోషణ స్థితిని అంచనా వేస్తుంది', 0, 72, 'mixed', '["measurements","dietary","signs"]', 'restaurant', '#8BC34A', 11, false),
  ('rbskBirthDefects', 'rbsk_birth_defects', 'RBSK Birth Defects Screening', 'RBSK పుట్టుకతో వచ్చే లోపాల స్క్రీనింగ్', 'Screening for congenital anomalies and birth defects (RBSK 4D — Defects at Birth)', 'పుట్టుకతో వచ్చే అసాధారణతలు మరియు లోపాల స్క్రీనింగ్ (RBSK 4D — పుట్టుకతో లోపాలు)', 0, 72, 'yesNo', '["neural","musculoskeletal","craniofacial","cardiac","sensory","other"]', 'child_care', '#E91E63', 13, false),
  ('rbskDiseases', 'rbsk_diseases', 'RBSK Disease Screening', 'RBSK వ్యాధుల స్క్రీనింగ్', 'Screening for childhood diseases and deficiencies (RBSK 4D — Diseases & Deficiencies)', 'బాల్య వ్యాధులు మరియు లోపాల స్క్రీనింగ్ (RBSK 4D — వ్యాధులు & లోపాలు)', 0, 72, 'yesNo', '["skin","ent","eye","dental","blood","deficiency"]', 'medical_services', '#9C27B0', 14, false)
ON CONFLICT (tool_type) DO NOTHING;

-- ============================================================
-- 2. RESPONSE OPTIONS
-- ============================================================

-- RBSK Tool (threePoint)
INSERT INTO response_options (tool_config_id, question_id, label_en, label_te, value, color_hex, sort_order)
VALUES
  ((SELECT id FROM screening_tool_configs WHERE tool_type = 'rbskTool'), NULL, 'High Extent', 'అధిక స్థాయి', '2', '#4CAF50', 0),
  ((SELECT id FROM screening_tool_configs WHERE tool_type = 'rbskTool'), NULL, 'Some Extent', 'కొంత స్థాయి', '1', '#FFC107', 1),
  ((SELECT id FROM screening_tool_configs WHERE tool_type = 'rbskTool'), NULL, 'Low Extent', 'తక్కువ స్థాయి', '0', '#F44336', 2)
ON CONFLICT DO NOTHING;

-- ISAA Autism (fivePoint)
INSERT INTO response_options (tool_config_id, question_id, label_en, label_te, value, color_hex, sort_order)
VALUES
  ((SELECT id FROM screening_tool_configs WHERE tool_type = 'isaaAutism'), NULL, 'Rarely', 'అరుదుగా', '1', '#4CAF50', 0),
  ((SELECT id FROM screening_tool_configs WHERE tool_type = 'isaaAutism'), NULL, 'Sometimes', 'కొన్నిసార్లు', '2', '#8BC34A', 1),
  ((SELECT id FROM screening_tool_configs WHERE tool_type = 'isaaAutism'), NULL, 'Frequently', 'తరచుగా', '3', '#FFC107', 2),
  ((SELECT id FROM screening_tool_configs WHERE tool_type = 'isaaAutism'), NULL, 'Mostly', 'చాలా వరకు', '4', '#FF9800', 3),
  ((SELECT id FROM screening_tool_configs WHERE tool_type = 'isaaAutism'), NULL, 'Always', 'ఎల్లప్పుడూ', '5', '#F44336', 4)
ON CONFLICT DO NOTHING;

-- SDQ Behavioral (threePoint - different labels)
INSERT INTO response_options (tool_config_id, question_id, label_en, label_te, value, color_hex, sort_order)
VALUES
  ((SELECT id FROM screening_tool_configs WHERE tool_type = 'sdqBehavioral'), NULL, 'Not True', 'నిజం కాదు', '0', '#4CAF50', 0),
  ((SELECT id FROM screening_tool_configs WHERE tool_type = 'sdqBehavioral'), NULL, 'Somewhat True', 'కొంత నిజం', '1', '#FFC107', 1),
  ((SELECT id FROM screening_tool_configs WHERE tool_type = 'sdqBehavioral'), NULL, 'Certainly True', 'ఖచ్చితంగా నిజం', '2', '#F44336', 2)
ON CONFLICT DO NOTHING;

-- PHQ-9 Parent Mental Health (fourPoint)
INSERT INTO response_options (tool_config_id, question_id, label_en, label_te, value, color_hex, sort_order)
VALUES
  ((SELECT id FROM screening_tool_configs WHERE tool_type = 'parentMentalHealth'), NULL, 'Not at all', 'అస్సలు కాదు', '0', '#4CAF50', 0),
  ((SELECT id FROM screening_tool_configs WHERE tool_type = 'parentMentalHealth'), NULL, 'Several days', 'కొన్ని రోజులు', '1', '#8BC34A', 1),
  ((SELECT id FROM screening_tool_configs WHERE tool_type = 'parentMentalHealth'), NULL, 'More than half the days', 'సగానికి పైగా రోజులు', '2', '#FF9800', 2),
  ((SELECT id FROM screening_tool_configs WHERE tool_type = 'parentMentalHealth'), NULL, 'Nearly every day', 'దాదాపు ప్రతిరోజూ', '3', '#F44336', 3)
ON CONFLICT DO NOTHING;

-- ============================================================
-- 3. QUESTIONS
-- ============================================================

-- ============================================================
-- 3A. CDC MILESTONES — Gross Motor (19 items)
-- ============================================================

INSERT INTO screening_questions (tool_config_id, code, text_en, text_te, domain, domain_name_en, domain_name_te, category, category_te, age_months, is_critical, is_red_flag, is_reverse_scored, unit, override_format, sort_order)
VALUES
  ((SELECT id FROM screening_tool_configs WHERE tool_type = 'cdcMilestones'), 'gm_2_1', 'Holds head up when on tummy', 'పొట్టపై ఉన్నప్పుడు తల పైకి ఎత్తగలరా?', 'gm', 'Gross Motor', 'స్థూల చలనం', NULL, NULL, 2, true, true, false, NULL, NULL, 1),
  ((SELECT id FROM screening_tool_configs WHERE tool_type = 'cdcMilestones'), 'gm_2_2', 'Moves both arms and both legs', 'రెండు చేతులు మరియు రెండు కాళ్ళు కదుపుతారా?', 'gm', 'Gross Motor', 'స్థూల చలనం', NULL, NULL, 2, true, false, false, NULL, NULL, 2),
  ((SELECT id FROM screening_tool_configs WHERE tool_type = 'cdcMilestones'), 'gm_4_1', 'Holds head steady without support when held', 'పట్టుకున్నప్పుడు మద్దతు లేకుండా తల స్థిరంగా ఉంచుతారా?', 'gm', 'Gross Motor', 'స్థూల చలనం', NULL, NULL, 4, true, true, false, NULL, NULL, 3),
  ((SELECT id FROM screening_tool_configs WHERE tool_type = 'cdcMilestones'), 'gm_4_2', 'Pushes up onto elbows/forearms when on tummy', 'పొట్టపై ఉన్నప్పుడు చేతులతో పైకి లేస్తారా?', 'gm', 'Gross Motor', 'స్థూల చలనం', NULL, NULL, 4, true, false, false, NULL, NULL, 4),
  ((SELECT id FROM screening_tool_configs WHERE tool_type = 'cdcMilestones'), 'gm_6_1', 'Rolls from tummy to back', 'పొట్ట నుండి వెనక్కి తిరగగలరా?', 'gm', 'Gross Motor', 'స్థూల చలనం', NULL, NULL, 6, true, false, false, NULL, NULL, 5),
  ((SELECT id FROM screening_tool_configs WHERE tool_type = 'cdcMilestones'), 'gm_6_2', 'Pushes up with straight arms when on tummy', 'పొట్టపై ఉన్నప్పుడు చేతులు నిటారుగా ఉంచి పైకి లేస్తారా?', 'gm', 'Gross Motor', 'స్థూల చలనం', NULL, NULL, 6, true, false, false, NULL, NULL, 6),
  ((SELECT id FROM screening_tool_configs WHERE tool_type = 'cdcMilestones'), 'gm_6_3', 'Leans on hands to support when sitting', 'కూర్చున్నప్పుడు చేతులపై ఆనుకుంటారా?', 'gm', 'Gross Motor', 'స్థూల చలనం', NULL, NULL, 6, true, false, false, NULL, NULL, 7),
  ((SELECT id FROM screening_tool_configs WHERE tool_type = 'cdcMilestones'), 'gm_9_1', 'Gets to sitting position by herself', 'తనంతట తాను కూర్చునే స్థితికి వస్తారా?', 'gm', 'Gross Motor', 'స్థూల చలనం', NULL, NULL, 9, true, false, false, NULL, NULL, 8),
  ((SELECT id FROM screening_tool_configs WHERE tool_type = 'cdcMilestones'), 'gm_9_2', 'Sits without support', 'మద్దతు లేకుండా కూర్చోగలరా?', 'gm', 'Gross Motor', 'స్థూల చలనం', NULL, NULL, 9, true, true, false, NULL, NULL, 9),
  ((SELECT id FROM screening_tool_configs WHERE tool_type = 'cdcMilestones'), 'gm_12_1', 'Pulls up to stand', 'నిలబడటానికి లేవగలరా?', 'gm', 'Gross Motor', 'స్థూల చలనం', NULL, NULL, 12, true, false, false, NULL, NULL, 10),
  ((SELECT id FROM screening_tool_configs WHERE tool_type = 'cdcMilestones'), 'gm_12_2', 'Walks, holding on to furniture', 'ఫర్నిచర్ పట్టుకుని నడవగలరా?', 'gm', 'Gross Motor', 'స్థూల చలనం', NULL, NULL, 12, true, false, false, NULL, NULL, 11),
  ((SELECT id FROM screening_tool_configs WHERE tool_type = 'cdcMilestones'), 'gm_18_1', 'Walks without holding on to anyone or anything', 'ఎవరినీ లేదా ఏదైనా పట్టుకోకుండా నడవగలరా?', 'gm', 'Gross Motor', 'స్థూల చలనం', NULL, NULL, 18, true, true, false, NULL, NULL, 12),
  ((SELECT id FROM screening_tool_configs WHERE tool_type = 'cdcMilestones'), 'gm_18_2', 'Climbs on and off couch or chair without help', 'సహాయం లేకుండా సోఫా లేదా కుర్చీ ఎక్కి దిగగలరా?', 'gm', 'Gross Motor', 'స్థూల చలనం', NULL, NULL, 18, true, false, false, NULL, NULL, 13),
  ((SELECT id FROM screening_tool_configs WHERE tool_type = 'cdcMilestones'), 'gm_24_1', 'Kicks a ball', 'బంతిని తన్నగలరా?', 'gm', 'Gross Motor', 'స్థూల చలనం', NULL, NULL, 24, true, false, false, NULL, NULL, 14),
  ((SELECT id FROM screening_tool_configs WHERE tool_type = 'cdcMilestones'), 'gm_24_2', 'Runs', 'పరుగెత్తగలరా?', 'gm', 'Gross Motor', 'స్థూల చలనం', NULL, NULL, 24, true, false, false, NULL, NULL, 15),
  ((SELECT id FROM screening_tool_configs WHERE tool_type = 'cdcMilestones'), 'gm_24_3', 'Walks (not climbs) up few stairs with/without help', 'సహాయంతో/లేకుండా మెట్లు ఎక్కగలరా?', 'gm', 'Gross Motor', 'స్థూల చలనం', NULL, NULL, 24, true, false, false, NULL, NULL, 16),
  ((SELECT id FROM screening_tool_configs WHERE tool_type = 'cdcMilestones'), 'gm_30_1', 'Jumps off ground with both feet', 'రెండు పాదాలతో నేల నుండి దూకగలరా?', 'gm', 'Gross Motor', 'స్థూల చలనం', NULL, NULL, 30, true, false, false, NULL, NULL, 17),
  ((SELECT id FROM screening_tool_configs WHERE tool_type = 'cdcMilestones'), 'gm_48_1', 'Catches a large ball most of the time', 'చాలా సార్లు పెద్ద బంతిని పట్టుకోగలరా?', 'gm', 'Gross Motor', 'స్థూల చలనం', NULL, NULL, 48, true, false, false, NULL, NULL, 18),
  ((SELECT id FROM screening_tool_configs WHERE tool_type = 'cdcMilestones'), 'gm_60_1', 'Hops on one foot', 'ఒక కాలిపై గెంతగలరా?', 'gm', 'Gross Motor', 'స్థూల చలనం', NULL, NULL, 60, true, false, false, NULL, NULL, 19)
ON CONFLICT (tool_config_id, code) DO NOTHING;

-- ============================================================
-- 3B. CDC MILESTONES — Fine Motor (23 items)
-- ============================================================

INSERT INTO screening_questions (tool_config_id, code, text_en, text_te, domain, domain_name_en, domain_name_te, category, category_te, age_months, is_critical, is_red_flag, is_reverse_scored, unit, override_format, sort_order)
VALUES
  ((SELECT id FROM screening_tool_configs WHERE tool_type = 'cdcMilestones'), 'fm_2_1', 'Opens hands briefly', 'చేతులు క్లుప్తంగా తెరుస్తారా?', 'fm', 'Fine Motor', 'సూక్ష్మ చలనం', NULL, NULL, 2, true, false, false, NULL, NULL, 20),
  ((SELECT id FROM screening_tool_configs WHERE tool_type = 'cdcMilestones'), 'fm_4_1', 'Holds a toy when you put it in his hand', 'చేతిలో బొమ్మ పెట్టినప్పుడు పట్టుకుంటారా?', 'fm', 'Fine Motor', 'సూక్ష్మ చలనం', NULL, NULL, 4, true, false, false, NULL, NULL, 21),
  ((SELECT id FROM screening_tool_configs WHERE tool_type = 'cdcMilestones'), 'fm_4_2', 'Uses her arm to swing at toys', 'బొమ్మలను కొట్టడానికి చేతిని ఊపుతారా?', 'fm', 'Fine Motor', 'సూక్ష్మ చలనం', NULL, NULL, 4, true, false, false, NULL, NULL, 22),
  ((SELECT id FROM screening_tool_configs WHERE tool_type = 'cdcMilestones'), 'fm_4_3', 'Brings hands to mouth', 'చేతులను నోటికి తీసుకువస్తారా?', 'fm', 'Fine Motor', 'సూక్ష్మ చలనం', NULL, NULL, 4, true, false, false, NULL, NULL, 23),
  ((SELECT id FROM screening_tool_configs WHERE tool_type = 'cdcMilestones'), 'fm_9_1', 'Moves things from one hand to other hand', 'ఒక చేతి నుండి మరొక చేతికి వస్తువులు మార్చగలరా?', 'fm', 'Fine Motor', 'సూక్ష్మ చలనం', NULL, NULL, 9, true, false, false, NULL, NULL, 24),
  ((SELECT id FROM screening_tool_configs WHERE tool_type = 'cdcMilestones'), 'fm_9_2', 'Uses fingers to rake food towards himself', 'వేళ్ళతో ఆహారాన్ని తన వైపు లాగుకుంటారా?', 'fm', 'Fine Motor', 'సూక్ష్మ చలనం', NULL, NULL, 9, true, false, false, NULL, NULL, 25),
  ((SELECT id FROM screening_tool_configs WHERE tool_type = 'cdcMilestones'), 'fm_12_1', 'Drinks from cup without lid, as you hold it', 'మీరు పట్టుకుంటే మూత లేని కప్పులో తాగగలరా?', 'fm', 'Fine Motor', 'సూక్ష్మ చలనం', NULL, NULL, 12, true, false, false, NULL, NULL, 26),
  ((SELECT id FROM screening_tool_configs WHERE tool_type = 'cdcMilestones'), 'fm_12_2', 'Picks things up between thumb and pointer finger', 'బొటనవేలు మరియు చూపుడు వేలు మధ్య వస్తువులు పట్టుకోగలరా?', 'fm', 'Fine Motor', 'సూక్ష్మ చలనం', NULL, NULL, 12, true, false, false, NULL, NULL, 27),
  ((SELECT id FROM screening_tool_configs WHERE tool_type = 'cdcMilestones'), 'fm_18_1', 'Scribbles', 'గీతలు గీయగలరా?', 'fm', 'Fine Motor', 'సూక్ష్మ చలనం', NULL, NULL, 18, true, false, false, NULL, NULL, 28),
  ((SELECT id FROM screening_tool_configs WHERE tool_type = 'cdcMilestones'), 'fm_18_2', 'Drinks from cup without lid (may spill)', 'మూత లేని కప్పులో తాగగలరా (చిందవచ్చు)?', 'fm', 'Fine Motor', 'సూక్ష్మ చలనం', NULL, NULL, 18, true, false, false, NULL, NULL, 29),
  ((SELECT id FROM screening_tool_configs WHERE tool_type = 'cdcMilestones'), 'fm_18_3', 'Feeds herself with fingers', 'వేళ్ళతో తానే తినగలరా?', 'fm', 'Fine Motor', 'సూక్ష్మ చలనం', NULL, NULL, 18, true, false, false, NULL, NULL, 30),
  ((SELECT id FROM screening_tool_configs WHERE tool_type = 'cdcMilestones'), 'fm_18_4', 'Tries to use spoon', 'చెంచాను వాడటానికి ప్రయత్నిస్తారా?', 'fm', 'Fine Motor', 'సూక్ష్మ చలనం', NULL, NULL, 18, true, false, false, NULL, NULL, 31),
  ((SELECT id FROM screening_tool_configs WHERE tool_type = 'cdcMilestones'), 'fm_24_1', 'Eats with a spoon', 'చెంచాతో తింటారా?', 'fm', 'Fine Motor', 'సూక్ష్మ చలనం', NULL, NULL, 24, true, false, false, NULL, NULL, 32),
  ((SELECT id FROM screening_tool_configs WHERE tool_type = 'cdcMilestones'), 'fm_30_1', 'Uses hands to twist things (doorknobs, lids)', 'తలుపు గుబ్బలు, మూతలు తిప్పడానికి చేతులు వాడతారా?', 'fm', 'Fine Motor', 'సూక్ష్మ చలనం', NULL, NULL, 30, true, false, false, NULL, NULL, 33),
  ((SELECT id FROM screening_tool_configs WHERE tool_type = 'cdcMilestones'), 'fm_30_2', 'Takes some clothes off by herself', 'తానే కొన్ని బట్టలు తీసేయగలరా?', 'fm', 'Fine Motor', 'సూక్ష్మ చలనం', NULL, NULL, 30, true, false, false, NULL, NULL, 34),
  ((SELECT id FROM screening_tool_configs WHERE tool_type = 'cdcMilestones'), 'fm_30_3', 'Turns book pages, one page at a time', 'పుస్తకం పేజీలు ఒక్కొక్కటిగా తిప్పగలరా?', 'fm', 'Fine Motor', 'సూక్ష్మ చలనం', NULL, NULL, 30, true, false, false, NULL, NULL, 35),
  ((SELECT id FROM screening_tool_configs WHERE tool_type = 'cdcMilestones'), 'fm_36_1', 'Strings items together (beads, macaroni)', 'పూసలు, మాకరోనీ వంటివి దారంలో గుచ్చగలరా?', 'fm', 'Fine Motor', 'సూక్ష్మ చలనం', NULL, NULL, 36, true, false, false, NULL, NULL, 36),
  ((SELECT id FROM screening_tool_configs WHERE tool_type = 'cdcMilestones'), 'fm_36_2', 'Puts on some clothes by herself', 'తానే కొన్ని బట్టలు వేసుకోగలరా?', 'fm', 'Fine Motor', 'సూక్ష్మ చలనం', NULL, NULL, 36, true, false, false, NULL, NULL, 37),
  ((SELECT id FROM screening_tool_configs WHERE tool_type = 'cdcMilestones'), 'fm_36_3', 'Uses a fork', 'ఫోర్క్ వాడగలరా?', 'fm', 'Fine Motor', 'సూక్ష్మ చలనం', NULL, NULL, 36, true, false, false, NULL, NULL, 38),
  ((SELECT id FROM screening_tool_configs WHERE tool_type = 'cdcMilestones'), 'fm_48_1', 'Serves self food or pours water with help', 'సహాయంతో తానే ఆహారం వడ్డించుకోగలరా లేదా నీరు పోయగలరా?', 'fm', 'Fine Motor', 'సూక్ష్మ చలనం', NULL, NULL, 48, true, false, false, NULL, NULL, 39),
  ((SELECT id FROM screening_tool_configs WHERE tool_type = 'cdcMilestones'), 'fm_48_2', 'Unbuttons some buttons', 'కొన్ని బటన్లు విప్పగలరా?', 'fm', 'Fine Motor', 'సూక్ష్మ చలనం', NULL, NULL, 48, true, false, false, NULL, NULL, 40),
  ((SELECT id FROM screening_tool_configs WHERE tool_type = 'cdcMilestones'), 'fm_48_3', 'Holds crayon between fingers and thumb', 'వేళ్ళు మరియు బొటనవేలు మధ్య క్రేయాన్ పట్టుకోగలరా?', 'fm', 'Fine Motor', 'సూక్ష్మ చలనం', NULL, NULL, 48, true, false, false, NULL, NULL, 41),
  ((SELECT id FROM screening_tool_configs WHERE tool_type = 'cdcMilestones'), 'fm_60_1', 'Buttons some buttons', 'కొన్ని బటన్లు పెట్టగలరా?', 'fm', 'Fine Motor', 'సూక్ష్మ చలనం', NULL, NULL, 60, true, false, false, NULL, NULL, 42)
ON CONFLICT (tool_config_id, code) DO NOTHING;

-- ============================================================
-- 3C. CDC MILESTONES — Language & Communication (36 items)
-- ============================================================

INSERT INTO screening_questions (tool_config_id, code, text_en, text_te, domain, domain_name_en, domain_name_te, category, category_te, age_months, is_critical, is_red_flag, is_reverse_scored, unit, override_format, sort_order)
VALUES
  ((SELECT id FROM screening_tool_configs WHERE tool_type = 'cdcMilestones'), 'lc_2_1', 'Makes sounds other than crying', 'ఏడుపు కాకుండా ఇతర శబ్దాలు చేస్తారా?', 'lc', 'Language & Communication', 'భాష & సంభాషణ', NULL, NULL, 2, true, true, false, NULL, NULL, 43),
  ((SELECT id FROM screening_tool_configs WHERE tool_type = 'cdcMilestones'), 'lc_2_2', 'Reacts to loud sounds', 'పెద్ద శబ్దాలకు స్పందిస్తారా?', 'lc', 'Language & Communication', 'భాష & సంభాషణ', NULL, NULL, 2, true, true, false, NULL, NULL, 44),
  ((SELECT id FROM screening_tool_configs WHERE tool_type = 'cdcMilestones'), 'lc_4_1', 'Makes sounds like ''oooo'', ''aahh'' (cooing)', '''ఊఊఊ'', ''ఆఆ'' వంటి శబ్దాలు చేస్తారా?', 'lc', 'Language & Communication', 'భాష & సంభాషణ', NULL, NULL, 4, true, false, false, NULL, NULL, 45),
  ((SELECT id FROM screening_tool_configs WHERE tool_type = 'cdcMilestones'), 'lc_4_2', 'Makes sounds back when you talk to him', 'మీరు మాట్లాడినప్పుడు తిరిగి శబ్దాలు చేస్తారా?', 'lc', 'Language & Communication', 'భాష & సంభాషణ', NULL, NULL, 4, true, false, false, NULL, NULL, 46),
  ((SELECT id FROM screening_tool_configs WHERE tool_type = 'cdcMilestones'), 'lc_4_3', 'Turns head towards the sound of your voice', 'మీ గొంతు వినిపించిన వైపు తల తిప్పుతారా?', 'lc', 'Language & Communication', 'భాష & సంభాషణ', NULL, NULL, 4, true, false, false, NULL, NULL, 47),
  ((SELECT id FROM screening_tool_configs WHERE tool_type = 'cdcMilestones'), 'lc_6_1', 'Takes turns making sounds with you', 'మీతో శబ్దాలు చేయడంలో వంతులు తీసుకుంటారా?', 'lc', 'Language & Communication', 'భాష & సంభాషణ', NULL, NULL, 6, true, false, false, NULL, NULL, 48),
  ((SELECT id FROM screening_tool_configs WHERE tool_type = 'cdcMilestones'), 'lc_6_2', 'Blows raspberries (sticks tongue out and blows)', 'నాలుక బయటపెట్టి ఊదుతారా?', 'lc', 'Language & Communication', 'భాష & సంభాషణ', NULL, NULL, 6, true, false, false, NULL, NULL, 49),
  ((SELECT id FROM screening_tool_configs WHERE tool_type = 'cdcMilestones'), 'lc_6_3', 'Makes squealing noises', 'కీచు శబ్దాలు చేస్తారా?', 'lc', 'Language & Communication', 'భాష & సంభాషణ', NULL, NULL, 6, true, false, false, NULL, NULL, 50),
  ((SELECT id FROM screening_tool_configs WHERE tool_type = 'cdcMilestones'), 'lc_9_1', 'Makes lots of different sounds like ''mamamama''', '''మమమ'' వంటి వివిధ శబ్దాలు చేస్తారా?', 'lc', 'Language & Communication', 'భాష & సంభాషణ', NULL, NULL, 9, true, true, false, NULL, NULL, 51),
  ((SELECT id FROM screening_tool_configs WHERE tool_type = 'cdcMilestones'), 'lc_9_2', 'Lifts arms up to be picked up', 'ఎత్తుకోమని చేతులు పైకి ఎత్తుతారా?', 'lc', 'Language & Communication', 'భాష & సంభాషణ', NULL, NULL, 9, true, false, false, NULL, NULL, 52),
  ((SELECT id FROM screening_tool_configs WHERE tool_type = 'cdcMilestones'), 'lc_12_1', 'Waves bye-bye', '''బై-బై'' చేయి ఊపుతారా?', 'lc', 'Language & Communication', 'భాష & సంభాషణ', NULL, NULL, 12, true, false, false, NULL, NULL, 53),
  ((SELECT id FROM screening_tool_configs WHERE tool_type = 'cdcMilestones'), 'lc_12_2', 'Calls parent mama or dada or special name', 'తల్లిదండ్రులను ''అమ్మ'' లేదా ''నాన్న'' అని పిలుస్తారా?', 'lc', 'Language & Communication', 'భాష & సంభాషణ', NULL, NULL, 12, true, true, false, NULL, NULL, 54),
  ((SELECT id FROM screening_tool_configs WHERE tool_type = 'cdcMilestones'), 'lc_12_3', 'Understands no (pauses or stops)', '''వద్దు'' అని అర్థం చేసుకుంటారా (ఆగుతారు)?', 'lc', 'Language & Communication', 'భాష & సంభాషణ', NULL, NULL, 12, true, false, false, NULL, NULL, 55),
  ((SELECT id FROM screening_tool_configs WHERE tool_type = 'cdcMilestones'), 'lc_18_1', 'Tries to say three or more words besides mama', '''అమ్మ'' కాకుండా మూడు లేదా అంతకంటే ఎక్కువ పదాలు చెప్పడానికి ప్రయత్నిస్తారా?', 'lc', 'Language & Communication', 'భాష & సంభాషణ', NULL, NULL, 18, true, true, false, NULL, NULL, 56),
  ((SELECT id FROM screening_tool_configs WHERE tool_type = 'cdcMilestones'), 'lc_18_2', 'Follows one-step directions without gestures', 'సైగలు లేకుండా ఒక దశ సూచనలను అనుసరిస్తారా?', 'lc', 'Language & Communication', 'భాష & సంభాషణ', NULL, NULL, 18, true, false, false, NULL, NULL, 57),
  ((SELECT id FROM screening_tool_configs WHERE tool_type = 'cdcMilestones'), 'lc_24_1', 'Points to things in a book when you ask', 'మీరు అడిగినప్పుడు పుస్తకంలో వస్తువులను చూపిస్తారా?', 'lc', 'Language & Communication', 'భాష & సంభాషణ', NULL, NULL, 24, true, false, false, NULL, NULL, 58),
  ((SELECT id FROM screening_tool_configs WHERE tool_type = 'cdcMilestones'), 'lc_24_2', 'Says at least two words together', 'కనీసం రెండు పదాలు కలిపి చెప్పగలరా?', 'lc', 'Language & Communication', 'భాష & సంభాషణ', NULL, NULL, 24, true, true, false, NULL, NULL, 59),
  ((SELECT id FROM screening_tool_configs WHERE tool_type = 'cdcMilestones'), 'lc_24_3', 'Points to at least 2 body parts when asked', 'అడిగినప్పుడు కనీసం 2 శరీర భాగాలను చూపిస్తారా?', 'lc', 'Language & Communication', 'భాష & సంభాషణ', NULL, NULL, 24, true, false, false, NULL, NULL, 60),
  ((SELECT id FROM screening_tool_configs WHERE tool_type = 'cdcMilestones'), 'lc_24_4', 'Uses more gestures (blowing kiss, nodding yes)', 'ఎక్కువ సైగలు వాడతారా (ముద్దు ఊదడం, అవును అని తల ఊపడం)?', 'lc', 'Language & Communication', 'భాష & సంభాషణ', NULL, NULL, 24, true, false, false, NULL, NULL, 61),
  ((SELECT id FROM screening_tool_configs WHERE tool_type = 'cdcMilestones'), 'lc_30_1', 'Says about 50 words', 'సుమారు 50 పదాలు చెప్పగలరా?', 'lc', 'Language & Communication', 'భాష & సంభాషణ', NULL, NULL, 30, true, true, false, NULL, NULL, 62),
  ((SELECT id FROM screening_tool_configs WHERE tool_type = 'cdcMilestones'), 'lc_30_2', 'Says two or more words with one action word', 'ఒక క్రియా పదంతో రెండు లేదా అంతకంటే ఎక్కువ పదాలు చెప్పగలరా?', 'lc', 'Language & Communication', 'భాష & సంభాషణ', NULL, NULL, 30, true, false, false, NULL, NULL, 63),
  ((SELECT id FROM screening_tool_configs WHERE tool_type = 'cdcMilestones'), 'lc_30_3', 'Names things in a book when you point and ask', 'మీరు చూపించి అడిగినప్పుడు పుస్తకంలో వస్తువుల పేర్లు చెప్పగలరా?', 'lc', 'Language & Communication', 'భాష & సంభాషణ', NULL, NULL, 30, true, false, false, NULL, NULL, 64),
  ((SELECT id FROM screening_tool_configs WHERE tool_type = 'cdcMilestones'), 'lc_30_4', 'Says words like I, me, or we', '''నేను'', ''నాకు'', ''మేము'' వంటి పదాలు వాడతారా?', 'lc', 'Language & Communication', 'భాష & సంభాషణ', NULL, NULL, 30, true, false, false, NULL, NULL, 65),
  ((SELECT id FROM screening_tool_configs WHERE tool_type = 'cdcMilestones'), 'lc_36_1', 'Talks with you in conversation (2+ exchanges)', 'మీతో సంభాషణలో మాట్లాడతారా (2+ మార్పిళ్ళు)?', 'lc', 'Language & Communication', 'భాష & సంభాషణ', NULL, NULL, 36, true, false, false, NULL, NULL, 66),
  ((SELECT id FROM screening_tool_configs WHERE tool_type = 'cdcMilestones'), 'lc_36_2', 'Asks who, what, where, why questions', '''ఎవరు'', ''ఏమిటి'', ''ఎక్కడ'', ''ఎందుకు'' ప్రశ్నలు అడుగుతారా?', 'lc', 'Language & Communication', 'భాష & సంభాషణ', NULL, NULL, 36, true, false, false, NULL, NULL, 67),
  ((SELECT id FROM screening_tool_configs WHERE tool_type = 'cdcMilestones'), 'lc_36_3', 'Says what action is happening in picture', 'చిత్రంలో ఏ చర్య జరుగుతుందో చెప్పగలరా?', 'lc', 'Language & Communication', 'భాష & సంభాషణ', NULL, NULL, 36, true, false, false, NULL, NULL, 68),
  ((SELECT id FROM screening_tool_configs WHERE tool_type = 'cdcMilestones'), 'lc_36_4', 'Says first name when asked', 'అడిగినప్పుడు తన పేరు చెప్పగలరా?', 'lc', 'Language & Communication', 'భాష & సంభాషణ', NULL, NULL, 36, true, true, false, NULL, NULL, 69),
  ((SELECT id FROM screening_tool_configs WHERE tool_type = 'cdcMilestones'), 'lc_36_5', 'Talks well enough for others to understand', 'ఇతరులు అర్థం చేసుకునేంత బాగా మాట్లాడగలరా?', 'lc', 'Language & Communication', 'భాష & సంభాషణ', NULL, NULL, 36, true, true, false, NULL, NULL, 70),
  ((SELECT id FROM screening_tool_configs WHERE tool_type = 'cdcMilestones'), 'lc_48_1', 'Says sentences with 4 or more words', '4 లేదా అంతకంటే ఎక్కువ పదాలతో వాక్యాలు చెప్పగలరా?', 'lc', 'Language & Communication', 'భాష & సంభాషణ', NULL, NULL, 48, true, false, false, NULL, NULL, 71),
  ((SELECT id FROM screening_tool_configs WHERE tool_type = 'cdcMilestones'), 'lc_48_2', 'Says some words from a song, story, or rhyme', 'పాట, కథ లేదా పద్యం నుండి కొన్ని పదాలు చెప్పగలరా?', 'lc', 'Language & Communication', 'భాష & సంభాషణ', NULL, NULL, 48, true, false, false, NULL, NULL, 72),
  ((SELECT id FROM screening_tool_configs WHERE tool_type = 'cdcMilestones'), 'lc_48_3', 'Talks about at least one thing that happened', 'జరిగిన కనీసం ఒక విషయం గురించి మాట్లాడగలరా?', 'lc', 'Language & Communication', 'భాష & సంభాషణ', NULL, NULL, 48, true, false, false, NULL, NULL, 73),
  ((SELECT id FROM screening_tool_configs WHERE tool_type = 'cdcMilestones'), 'lc_48_4', 'Answers simple questions like What is a coat for?', '''కోటు ఎందుకు?'' వంటి సాధారణ ప్రశ్నలకు సమాధానం చెప్పగలరా?', 'lc', 'Language & Communication', 'భాష & సంభాషణ', NULL, NULL, 48, true, false, false, NULL, NULL, 74),
  ((SELECT id FROM screening_tool_configs WHERE tool_type = 'cdcMilestones'), 'lc_60_1', 'Tells a story with at least 2 events', 'కనీసం 2 సంఘటనలతో కథ చెప్పగలరా?', 'lc', 'Language & Communication', 'భాష & సంభాషణ', NULL, NULL, 60, true, false, false, NULL, NULL, 75),
  ((SELECT id FROM screening_tool_configs WHERE tool_type = 'cdcMilestones'), 'lc_60_2', 'Answers simple questions about a book/story', 'పుస్తకం/కథ గురించి సాధారణ ప్రశ్నలకు సమాధానం చెప్పగలరా?', 'lc', 'Language & Communication', 'భాష & సంభాషణ', NULL, NULL, 60, true, false, false, NULL, NULL, 76),
  ((SELECT id FROM screening_tool_configs WHERE tool_type = 'cdcMilestones'), 'lc_60_3', 'Keeps a conversation going (3+ exchanges)', 'సంభాషణను కొనసాగించగలరా (3+ మార్పిళ్ళు)?', 'lc', 'Language & Communication', 'భాష & సంభాషణ', NULL, NULL, 60, true, false, false, NULL, NULL, 77),
  ((SELECT id FROM screening_tool_configs WHERE tool_type = 'cdcMilestones'), 'lc_60_4', 'Uses or recognizes simple rhymes', 'సాధారణ పద్యాలను వాడగలరా లేదా గుర్తించగలరా?', 'lc', 'Language & Communication', 'భాష & సంభాషణ', NULL, NULL, 60, true, false, false, NULL, NULL, 78)
ON CONFLICT (tool_config_id, code) DO NOTHING;

-- ============================================================
-- 3D. CDC MILESTONES — Cognitive (31 items)
-- ============================================================

INSERT INTO screening_questions (tool_config_id, code, text_en, text_te, domain, domain_name_en, domain_name_te, category, category_te, age_months, is_critical, is_red_flag, is_reverse_scored, unit, override_format, sort_order)
VALUES
  ((SELECT id FROM screening_tool_configs WHERE tool_type = 'cdcMilestones'), 'cog_2_1', 'Watches you as you move', 'మీరు కదిలినప్పుడు చూస్తారా?', 'cog', 'Cognitive', 'జ్ఞానాత్మకం', NULL, NULL, 2, true, false, false, NULL, NULL, 79),
  ((SELECT id FROM screening_tool_configs WHERE tool_type = 'cdcMilestones'), 'cog_2_2', 'Looks at a toy for several seconds', 'బొమ్మను కొన్ని సెకన్లు చూస్తారా?', 'cog', 'Cognitive', 'జ్ఞానాత్మకం', NULL, NULL, 2, true, false, false, NULL, NULL, 80),
  ((SELECT id FROM screening_tool_configs WHERE tool_type = 'cdcMilestones'), 'cog_4_1', 'If hungry, opens mouth when sees breast or bottle', 'ఆకలిగా ఉంటే, రొమ్ము లేదా బాటిల్ చూసినప్పుడు నోరు తెరుస్తారా?', 'cog', 'Cognitive', 'జ్ఞానాత్మకం', NULL, NULL, 4, true, false, false, NULL, NULL, 81),
  ((SELECT id FROM screening_tool_configs WHERE tool_type = 'cdcMilestones'), 'cog_4_2', 'Looks at his hands with interest', 'ఆసక్తిగా తన చేతులను చూసుకుంటారా?', 'cog', 'Cognitive', 'జ్ఞానాత్మకం', NULL, NULL, 4, true, false, false, NULL, NULL, 82),
  ((SELECT id FROM screening_tool_configs WHERE tool_type = 'cdcMilestones'), 'cog_6_1', 'Puts things in her mouth to explore them', 'వస్తువులను పరిశీలించడానికి నోటిలో పెట్టుకుంటారా?', 'cog', 'Cognitive', 'జ్ఞానాత్మకం', NULL, NULL, 6, true, false, false, NULL, NULL, 83),
  ((SELECT id FROM screening_tool_configs WHERE tool_type = 'cdcMilestones'), 'cog_6_2', 'Reaches to grab a toy he wants', 'కావలసిన బొమ్మను అందుకోవడానికి చేరుకుంటారా?', 'cog', 'Cognitive', 'జ్ఞానాత్మకం', NULL, NULL, 6, true, false, false, NULL, NULL, 84),
  ((SELECT id FROM screening_tool_configs WHERE tool_type = 'cdcMilestones'), 'cog_6_3', 'Closes lips to show doesn''t want more food', 'మరింత ఆహారం వద్దని పెదాలు మూసుకుంటారా?', 'cog', 'Cognitive', 'జ్ఞానాత్మకం', NULL, NULL, 6, true, false, false, NULL, NULL, 85),
  ((SELECT id FROM screening_tool_configs WHERE tool_type = 'cdcMilestones'), 'cog_9_1', 'Looks for objects when dropped out of sight', 'కనుమరుగైన వస్తువులను వెతుకుతారా?', 'cog', 'Cognitive', 'జ్ఞానాత్మకం', NULL, NULL, 9, true, false, false, NULL, NULL, 86),
  ((SELECT id FROM screening_tool_configs WHERE tool_type = 'cdcMilestones'), 'cog_9_2', 'Bangs two things together', 'రెండు వస్తువులను కొడతారా?', 'cog', 'Cognitive', 'జ్ఞానాత్మకం', NULL, NULL, 9, true, false, false, NULL, NULL, 87),
  ((SELECT id FROM screening_tool_configs WHERE tool_type = 'cdcMilestones'), 'cog_12_1', 'Puts something in container (block in cup)', 'కంటైనర్‌లో ఏదైనా పెడతారా (కప్పులో బ్లాక్)?', 'cog', 'Cognitive', 'జ్ఞానాత్మకం', NULL, NULL, 12, true, false, false, NULL, NULL, 88),
  ((SELECT id FROM screening_tool_configs WHERE tool_type = 'cdcMilestones'), 'cog_12_2', 'Looks for things he sees you hide', 'మీరు దాచిన వస్తువులను వెతుకుతారా?', 'cog', 'Cognitive', 'జ్ఞానాత్మకం', NULL, NULL, 12, true, false, false, NULL, NULL, 89),
  ((SELECT id FROM screening_tool_configs WHERE tool_type = 'cdcMilestones'), 'cog_18_1', 'Copies you doing chores (sweeping with broom)', 'మీరు చేసే పనులను అనుకరిస్తారా (చీపురుతో ఊడ్చడం)?', 'cog', 'Cognitive', 'జ్ఞానాత్మకం', NULL, NULL, 18, true, false, false, NULL, NULL, 90),
  ((SELECT id FROM screening_tool_configs WHERE tool_type = 'cdcMilestones'), 'cog_18_2', 'Plays with toys in simple way (pushes toy car)', 'సాధారణ పద్ధతిలో బొమ్మలతో ఆడతారా (బొమ్మ కారు నెడతారా)?', 'cog', 'Cognitive', 'జ్ఞానాత్మకం', NULL, NULL, 18, true, false, false, NULL, NULL, 91),
  ((SELECT id FROM screening_tool_configs WHERE tool_type = 'cdcMilestones'), 'cog_24_1', 'Holds something in one hand while using other', 'ఒక చేత్తో వస్తువు పట్టుకుని మరొక చేయి వాడతారా?', 'cog', 'Cognitive', 'జ్ఞానాత్మకం', NULL, NULL, 24, true, false, false, NULL, NULL, 92),
  ((SELECT id FROM screening_tool_configs WHERE tool_type = 'cdcMilestones'), 'cog_24_2', 'Tries to use switches, knobs, or buttons on toy', 'బొమ్మపై స్విచ్‌లు, నాబ్‌లు లేదా బటన్లు వాడటానికి ప్రయత్నిస్తారా?', 'cog', 'Cognitive', 'జ్ఞానాత్మకం', NULL, NULL, 24, true, false, false, NULL, NULL, 93),
  ((SELECT id FROM screening_tool_configs WHERE tool_type = 'cdcMilestones'), 'cog_24_3', 'Plays with more than one toy at same time', 'ఒకే సమయంలో ఒకటి కంటే ఎక్కువ బొమ్మలతో ఆడతారా?', 'cog', 'Cognitive', 'జ్ఞానాత్మకం', NULL, NULL, 24, true, false, false, NULL, NULL, 94),
  ((SELECT id FROM screening_tool_configs WHERE tool_type = 'cdcMilestones'), 'cog_30_1', 'Uses things to pretend (feeds block as food)', 'నటించడానికి వస్తువులను వాడతారా (బ్లాక్‌ను ఆహారంగా తినిపిస్తారా)?', 'cog', 'Cognitive', 'జ్ఞానాత్మకం', NULL, NULL, 30, true, false, false, NULL, NULL, 95),
  ((SELECT id FROM screening_tool_configs WHERE tool_type = 'cdcMilestones'), 'cog_30_2', 'Shows simple problem-solving skills', 'సాధారణ సమస్య పరిష్కార నైపుణ్యాలు చూపిస్తారా?', 'cog', 'Cognitive', 'జ్ఞానాత్మకం', NULL, NULL, 30, true, false, false, NULL, NULL, 96),
  ((SELECT id FROM screening_tool_configs WHERE tool_type = 'cdcMilestones'), 'cog_30_3', 'Follows two-step instructions', 'రెండు దశల సూచనలను అనుసరిస్తారా?', 'cog', 'Cognitive', 'జ్ఞానాత్మకం', NULL, NULL, 30, true, false, false, NULL, NULL, 97),
  ((SELECT id FROM screening_tool_configs WHERE tool_type = 'cdcMilestones'), 'cog_30_4', 'Knows at least one color', 'కనీసం ఒక రంగు తెలుసా?', 'cog', 'Cognitive', 'జ్ఞానాత్మకం', NULL, NULL, 30, true, false, false, NULL, NULL, 98),
  ((SELECT id FROM screening_tool_configs WHERE tool_type = 'cdcMilestones'), 'cog_36_1', 'Draws a circle when you show how', 'మీరు చూపించినప్పుడు వృత్తం గీయగలరా?', 'cog', 'Cognitive', 'జ్ఞానాత్మకం', NULL, NULL, 36, true, false, false, NULL, NULL, 99),
  ((SELECT id FROM screening_tool_configs WHERE tool_type = 'cdcMilestones'), 'cog_36_2', 'Avoids touching hot objects when warned', 'హెచ్చరించినప్పుడు వేడి వస్తువులను తాకకుండా ఉంటారా?', 'cog', 'Cognitive', 'జ్ఞానాత్మకం', NULL, NULL, 36, true, false, false, NULL, NULL, 100),
  ((SELECT id FROM screening_tool_configs WHERE tool_type = 'cdcMilestones'), 'cog_48_1', 'Names a few colors of items', 'వస్తువుల కొన్ని రంగుల పేర్లు చెప్పగలరా?', 'cog', 'Cognitive', 'జ్ఞానాత్మకం', NULL, NULL, 48, true, false, false, NULL, NULL, 101),
  ((SELECT id FROM screening_tool_configs WHERE tool_type = 'cdcMilestones'), 'cog_48_2', 'Tells what comes next in well-known story', 'బాగా తెలిసిన కథలో తర్వాత ఏమి వస్తుందో చెప్పగలరా?', 'cog', 'Cognitive', 'జ్ఞానాత్మకం', NULL, NULL, 48, true, false, false, NULL, NULL, 102),
  ((SELECT id FROM screening_tool_configs WHERE tool_type = 'cdcMilestones'), 'cog_48_3', 'Draws a person with 3 or more body parts', '3 లేదా అంతకంటే ఎక్కువ శరీర భాగాలతో మనిషిని గీయగలరా?', 'cog', 'Cognitive', 'జ్ఞానాత్మకం', NULL, NULL, 48, true, false, false, NULL, NULL, 103),
  ((SELECT id FROM screening_tool_configs WHERE tool_type = 'cdcMilestones'), 'cog_60_1', 'Counts to 10', '10 వరకు లెక్కించగలరా?', 'cog', 'Cognitive', 'జ్ఞానాత్మకం', NULL, NULL, 60, true, false, false, NULL, NULL, 104),
  ((SELECT id FROM screening_tool_configs WHERE tool_type = 'cdcMilestones'), 'cog_60_2', 'Names some numbers between 1 and 5 when pointed', 'చూపించినప్పుడు 1 నుండి 5 మధ్య కొన్ని సంఖ్యల పేర్లు చెప్పగలరా?', 'cog', 'Cognitive', 'జ్ఞానాత్మకం', NULL, NULL, 60, true, false, false, NULL, NULL, 105),
  ((SELECT id FROM screening_tool_configs WHERE tool_type = 'cdcMilestones'), 'cog_60_3', 'Uses words about time (yesterday, tomorrow)', 'సమయం గురించి పదాలు వాడతారా (నిన్న, రేపు)?', 'cog', 'Cognitive', 'జ్ఞానాత్మకం', NULL, NULL, 60, true, false, false, NULL, NULL, 106),
  ((SELECT id FROM screening_tool_configs WHERE tool_type = 'cdcMilestones'), 'cog_60_4', 'Pays attention for 5 to 10 minutes during activity', 'కార్యకలాపంలో 5 నుండి 10 నిమిషాలు శ్రద్ధ చూపిస్తారా?', 'cog', 'Cognitive', 'జ్ఞానాత్మకం', NULL, NULL, 60, true, false, false, NULL, NULL, 107),
  ((SELECT id FROM screening_tool_configs WHERE tool_type = 'cdcMilestones'), 'cog_60_5', 'Writes some letters in their name', 'తన పేరులో కొన్ని అక్షరాలు రాయగలరా?', 'cog', 'Cognitive', 'జ్ఞానాత్మకం', NULL, NULL, 60, true, false, false, NULL, NULL, 108),
  ((SELECT id FROM screening_tool_configs WHERE tool_type = 'cdcMilestones'), 'cog_60_6', 'Names some letters when you point to them', 'మీరు చూపించినప్పుడు కొన్ని అక్షరాల పేర్లు చెప్పగలరా?', 'cog', 'Cognitive', 'జ్ఞానాత్మకం', NULL, NULL, 60, true, false, false, NULL, NULL, 109)
ON CONFLICT (tool_config_id, code) DO NOTHING;

-- ============================================================
-- 3E. CDC MILESTONES — Social-Emotional (37 items)
-- ============================================================

INSERT INTO screening_questions (tool_config_id, code, text_en, text_te, domain, domain_name_en, domain_name_te, category, category_te, age_months, is_critical, is_red_flag, is_reverse_scored, unit, override_format, sort_order)
VALUES
  ((SELECT id FROM screening_tool_configs WHERE tool_type = 'cdcMilestones'), 'se_2_1', 'Calms down when spoken to or picked up', 'మాట్లాడినప్పుడు లేదా ఎత్తుకున్నప్పుడు శాంతిస్తారా?', 'se', 'Social-Emotional', 'సామాజిక-భావోద్వేగ', NULL, NULL, 2, true, false, false, NULL, NULL, 110),
  ((SELECT id FROM screening_tool_configs WHERE tool_type = 'cdcMilestones'), 'se_2_2', 'Looks at your face', 'మీ ముఖాన్ని చూస్తారా?', 'se', 'Social-Emotional', 'సామాజిక-భావోద్వేగ', NULL, NULL, 2, true, true, false, NULL, NULL, 111),
  ((SELECT id FROM screening_tool_configs WHERE tool_type = 'cdcMilestones'), 'se_2_3', 'Seems happy to see you when you walk up', 'మీరు దగ్గరకు వచ్చినప్పుడు సంతోషంగా కనిపిస్తారా?', 'se', 'Social-Emotional', 'సామాజిక-భావోద్వేగ', NULL, NULL, 2, true, false, false, NULL, NULL, 112),
  ((SELECT id FROM screening_tool_configs WHERE tool_type = 'cdcMilestones'), 'se_2_4', 'Smiles when you talk to or smile at her', 'మీరు మాట్లాడినప్పుడు లేదా నవ్వినప్పుడు నవ్వుతారా?', 'se', 'Social-Emotional', 'సామాజిక-భావోద్వేగ', NULL, NULL, 2, true, true, false, NULL, NULL, 113),
  ((SELECT id FROM screening_tool_configs WHERE tool_type = 'cdcMilestones'), 'se_4_1', 'Smiles on his own to get your attention', 'మీ దృష్టి ఆకర్షించడానికి తనంతట తాను నవ్వుతారా?', 'se', 'Social-Emotional', 'సామాజిక-భావోద్వేగ', NULL, NULL, 4, true, false, false, NULL, NULL, 114),
  ((SELECT id FROM screening_tool_configs WHERE tool_type = 'cdcMilestones'), 'se_4_2', 'Chuckles (not yet a full laugh)', 'కిలకిల నవ్వుతారా (పూర్తి నవ్వు కాదు)?', 'se', 'Social-Emotional', 'సామాజిక-భావోద్వేగ', NULL, NULL, 4, true, false, false, NULL, NULL, 115),
  ((SELECT id FROM screening_tool_configs WHERE tool_type = 'cdcMilestones'), 'se_4_3', 'Looks at you, moves, or makes sounds for attention', 'దృష్టి కోసం మిమ్మల్ని చూస్తారా, కదులుతారా లేదా శబ్దాలు చేస్తారా?', 'se', 'Social-Emotional', 'సామాజిక-భావోద్వేగ', NULL, NULL, 4, true, false, false, NULL, NULL, 116),
  ((SELECT id FROM screening_tool_configs WHERE tool_type = 'cdcMilestones'), 'se_6_1', 'Knows familiar people', 'పరిచిత వ్యక్తులను గుర్తిస్తారా?', 'se', 'Social-Emotional', 'సామాజిక-భావోద్వేగ', NULL, NULL, 6, true, false, false, NULL, NULL, 117),
  ((SELECT id FROM screening_tool_configs WHERE tool_type = 'cdcMilestones'), 'se_6_2', 'Likes to look at self in a mirror', 'అద్దంలో తనను తాను చూసుకోవడం ఇష్టపడతారా?', 'se', 'Social-Emotional', 'సామాజిక-భావోద్వేగ', NULL, NULL, 6, true, false, false, NULL, NULL, 118),
  ((SELECT id FROM screening_tool_configs WHERE tool_type = 'cdcMilestones'), 'se_6_3', 'Laughs', 'నవ్వుతారా?', 'se', 'Social-Emotional', 'సామాజిక-భావోద్వేగ', NULL, NULL, 6, true, false, false, NULL, NULL, 119),
  ((SELECT id FROM screening_tool_configs WHERE tool_type = 'cdcMilestones'), 'se_9_1', 'Is shy, clingy, or fearful around strangers', 'అపరిచితుల దగ్గర సిగ్గు, అతుక్కుపోవడం లేదా భయం చూపిస్తారా?', 'se', 'Social-Emotional', 'సామాజిక-భావోద్వేగ', NULL, NULL, 9, true, false, false, NULL, NULL, 120),
  ((SELECT id FROM screening_tool_configs WHERE tool_type = 'cdcMilestones'), 'se_9_2', 'Shows several facial expressions', 'అనేక ముఖ భావాలు చూపిస్తారా?', 'se', 'Social-Emotional', 'సామాజిక-భావోద్వేగ', NULL, NULL, 9, true, false, false, NULL, NULL, 121),
  ((SELECT id FROM screening_tool_configs WHERE tool_type = 'cdcMilestones'), 'se_9_3', 'Looks when you call her name', 'పేరు పిలిచినప్పుడు చూస్తారా?', 'se', 'Social-Emotional', 'సామాజిక-భావోద్వేగ', NULL, NULL, 9, true, true, false, NULL, NULL, 122),
  ((SELECT id FROM screening_tool_configs WHERE tool_type = 'cdcMilestones'), 'se_9_4', 'Reacts when you leave (looks, reaches, or cries)', 'మీరు వెళ్ళినప్పుడు స్పందిస్తారా (చూస్తారు, చేరుకుంటారు లేదా ఏడుస్తారు)?', 'se', 'Social-Emotional', 'సామాజిక-భావోద్వేగ', NULL, NULL, 9, true, false, false, NULL, NULL, 123),
  ((SELECT id FROM screening_tool_configs WHERE tool_type = 'cdcMilestones'), 'se_9_5', 'Smiles or laughs when you play peek-a-boo', 'దాగుడుమూతలు ఆడినప్పుడు నవ్వుతారా?', 'se', 'Social-Emotional', 'సామాజిక-భావోద్వేగ', NULL, NULL, 9, true, false, false, NULL, NULL, 124),
  ((SELECT id FROM screening_tool_configs WHERE tool_type = 'cdcMilestones'), 'se_12_1', 'Plays games with you, like pat-a-cake', 'మీతో ఆటలు ఆడతారా (చప్పట్ల ఆట)?', 'se', 'Social-Emotional', 'సామాజిక-భావోద్వేగ', NULL, NULL, 12, true, false, false, NULL, NULL, 125),
  ((SELECT id FROM screening_tool_configs WHERE tool_type = 'cdcMilestones'), 'se_18_1', 'Moves away from you but looks to make sure close', 'మీ నుండి దూరంగా వెళ్తారు కానీ దగ్గరలో ఉన్నారో చూస్తారా?', 'se', 'Social-Emotional', 'సామాజిక-భావోద్వేగ', NULL, NULL, 18, true, false, false, NULL, NULL, 126),
  ((SELECT id FROM screening_tool_configs WHERE tool_type = 'cdcMilestones'), 'se_18_2', 'Points to show you something interesting', 'ఆసక్తికరమైన విషయం చూపించడానికి చూపిస్తారా?', 'se', 'Social-Emotional', 'సామాజిక-భావోద్వేగ', NULL, NULL, 18, true, true, false, NULL, NULL, 127),
  ((SELECT id FROM screening_tool_configs WHERE tool_type = 'cdcMilestones'), 'se_18_3', 'Puts hands out for you to wash them', 'చేతులు కడగమని చేతులు చాపుతారా?', 'se', 'Social-Emotional', 'సామాజిక-భావోద్వేగ', NULL, NULL, 18, true, false, false, NULL, NULL, 128),
  ((SELECT id FROM screening_tool_configs WHERE tool_type = 'cdcMilestones'), 'se_18_4', 'Looks at a few pages with you', 'మీతో కొన్ని పేజీలు చూస్తారా?', 'se', 'Social-Emotional', 'సామాజిక-భావోద్వేగ', NULL, NULL, 18, true, false, false, NULL, NULL, 129),
  ((SELECT id FROM screening_tool_configs WHERE tool_type = 'cdcMilestones'), 'se_18_5', 'Helps dress by pushing arm through sleeve', 'చేతిని చేతికి తొడిగి బట్టలు వేసుకోవడంలో సహాయం చేస్తారా?', 'se', 'Social-Emotional', 'సామాజిక-భావోద్వేగ', NULL, NULL, 18, true, false, false, NULL, NULL, 130),
  ((SELECT id FROM screening_tool_configs WHERE tool_type = 'cdcMilestones'), 'se_24_1', 'Notices when others are hurt or upset', 'ఇతరులు గాయపడినప్పుడు లేదా బాధపడినప్పుడు గమనిస్తారా?', 'se', 'Social-Emotional', 'సామాజిక-భావోద్వేగ', NULL, NULL, 24, true, false, false, NULL, NULL, 131),
  ((SELECT id FROM screening_tool_configs WHERE tool_type = 'cdcMilestones'), 'se_24_2', 'Looks at your face to see reaction in new situation', 'కొత్త పరిస్థితిలో మీ ముఖ భావాన్ని చూస్తారా?', 'se', 'Social-Emotional', 'సామాజిక-భావోద్వేగ', NULL, NULL, 24, true, false, false, NULL, NULL, 132),
  ((SELECT id FROM screening_tool_configs WHERE tool_type = 'cdcMilestones'), 'se_30_1', 'Plays next to other children, sometimes with them', 'ఇతర పిల్లల పక్కన ఆడతారా, కొన్నిసార్లు వారితో ఆడతారా?', 'se', 'Social-Emotional', 'సామాజిక-భావోద్వేగ', NULL, NULL, 30, true, false, false, NULL, NULL, 133),
  ((SELECT id FROM screening_tool_configs WHERE tool_type = 'cdcMilestones'), 'se_30_2', 'Shows you what she can do (Look at me!)', 'తను ఏం చేయగలదో చూపిస్తారా (''నన్ను చూడు!'')?', 'se', 'Social-Emotional', 'సామాజిక-భావోద్వేగ', NULL, NULL, 30, true, false, false, NULL, NULL, 134),
  ((SELECT id FROM screening_tool_configs WHERE tool_type = 'cdcMilestones'), 'se_30_3', 'Follows simple routines when told', 'చెప్పినప్పుడు సాధారణ దినచర్యలను అనుసరిస్తారా?', 'se', 'Social-Emotional', 'సామాజిక-భావోద్వేగ', NULL, NULL, 30, true, false, false, NULL, NULL, 135),
  ((SELECT id FROM screening_tool_configs WHERE tool_type = 'cdcMilestones'), 'se_36_1', 'Calms within 10 minutes after you leave', 'మీరు వెళ్ళిన 10 నిమిషాలలో శాంతిస్తారా?', 'se', 'Social-Emotional', 'సామాజిక-భావోద్వేగ', NULL, NULL, 36, true, false, false, NULL, NULL, 136),
  ((SELECT id FROM screening_tool_configs WHERE tool_type = 'cdcMilestones'), 'se_36_2', 'Notices other children and joins them to play', 'ఇతర పిల్లలను గమనించి వారితో ఆడటానికి చేరతారా?', 'se', 'Social-Emotional', 'సామాజిక-భావోద్వేగ', NULL, NULL, 36, true, true, false, NULL, NULL, 137),
  ((SELECT id FROM screening_tool_configs WHERE tool_type = 'cdcMilestones'), 'se_48_1', 'Pretends to be something else (teacher, dog)', 'వేరొకరిగా నటిస్తారా (టీచర్, కుక్క)?', 'se', 'Social-Emotional', 'సామాజిక-భావోద్వేగ', NULL, NULL, 48, true, false, false, NULL, NULL, 138),
  ((SELECT id FROM screening_tool_configs WHERE tool_type = 'cdcMilestones'), 'se_48_2', 'Asks to go play with children if none around', 'చుట్టూ పిల్లలు లేకపోతే ఆడటానికి వెళ్ళమని అడుగుతారా?', 'se', 'Social-Emotional', 'సామాజిక-భావోద్వేగ', NULL, NULL, 48, true, false, false, NULL, NULL, 139),
  ((SELECT id FROM screening_tool_configs WHERE tool_type = 'cdcMilestones'), 'se_48_3', 'Comforts others who are hurt or sad', 'గాయపడిన లేదా బాధపడిన వారిని ఓదార్చుతారా?', 'se', 'Social-Emotional', 'సామాజిక-భావోద్వేగ', NULL, NULL, 48, true, false, false, NULL, NULL, 140),
  ((SELECT id FROM screening_tool_configs WHERE tool_type = 'cdcMilestones'), 'se_48_4', 'Avoids danger (doesn''t jump from heights)', 'ప్రమాదాన్ని నివారిస్తారా (ఎత్తుల నుండి దూకరు)?', 'se', 'Social-Emotional', 'సామాజిక-భావోద్వేగ', NULL, NULL, 48, true, false, false, NULL, NULL, 141),
  ((SELECT id FROM screening_tool_configs WHERE tool_type = 'cdcMilestones'), 'se_48_5', 'Likes to be a helper', '''సహాయకుడిగా'' ఉండటం ఇష్టపడతారా?', 'se', 'Social-Emotional', 'సామాజిక-భావోద్వేగ', NULL, NULL, 48, true, false, false, NULL, NULL, 142),
  ((SELECT id FROM screening_tool_configs WHERE tool_type = 'cdcMilestones'), 'se_48_6', 'Changes behavior based on location', 'ప్రదేశాన్ని బట్టి ప్రవర్తన మారుస్తారా?', 'se', 'Social-Emotional', 'సామాజిక-భావోద్వేగ', NULL, NULL, 48, true, false, false, NULL, NULL, 143),
  ((SELECT id FROM screening_tool_configs WHERE tool_type = 'cdcMilestones'), 'se_60_1', 'Follows rules or takes turns when playing games', 'ఆటల్లో నియమాలు పాటిస్తారా లేదా వంతులు తీసుకుంటారా?', 'se', 'Social-Emotional', 'సామాజిక-భావోద్వేగ', NULL, NULL, 60, true, false, false, NULL, NULL, 144),
  ((SELECT id FROM screening_tool_configs WHERE tool_type = 'cdcMilestones'), 'se_60_2', 'Sings, dances, or acts for you', 'మీ కోసం పాడతారా, నృత్యం చేస్తారా లేదా నటిస్తారా?', 'se', 'Social-Emotional', 'సామాజిక-భావోద్వేగ', NULL, NULL, 60, true, false, false, NULL, NULL, 145),
  ((SELECT id FROM screening_tool_configs WHERE tool_type = 'cdcMilestones'), 'se_60_3', 'Does simple chores at home', 'ఇంట్లో సాధారణ పనులు చేస్తారా?', 'se', 'Social-Emotional', 'సామాజిక-భావోద్వేగ', NULL, NULL, 60, true, false, false, NULL, NULL, 146)
ON CONFLICT (tool_config_id, code) DO NOTHING;

-- ============================================================
-- 3F. M-CHAT AUTISM SCREENING (20 items)
-- ============================================================

INSERT INTO screening_questions (tool_config_id, code, text_en, text_te, domain, domain_name_en, domain_name_te, category, category_te, age_months, is_critical, is_red_flag, is_reverse_scored, unit, override_format, sort_order)
VALUES
  ((SELECT id FROM screening_tool_configs WHERE tool_type = 'mchatAutism'), 'mchat_1', 'Does your child enjoy being swung, bounced on your knee, etc.?', 'మీ బిడ్డ ఊపడం, మోకాలిపై ఎగరడం వంటివి ఆనందిస్తారా?', 'autism_risk', 'Autism Risk', 'ఆటిజం ప్రమాదం', NULL, NULL, NULL, false, false, false, NULL, NULL, 1),
  ((SELECT id FROM screening_tool_configs WHERE tool_type = 'mchatAutism'), 'mchat_2', 'Does your child take an interest in other children?', 'మీ బిడ్డ ఇతర పిల్లలపై ఆసక్తి చూపిస్తారా?', 'autism_risk', 'Autism Risk', 'ఆటిజం ప్రమాదం', NULL, NULL, NULL, true, false, false, NULL, NULL, 2),
  ((SELECT id FROM screening_tool_configs WHERE tool_type = 'mchatAutism'), 'mchat_3', 'Does your child like climbing on things, such as stairs?', 'మీ బిడ్డ మెట్లు వంటి వాటిపై ఎక్కడం ఇష్టపడతారా?', 'autism_risk', 'Autism Risk', 'ఆటిజం ప్రమాదం', NULL, NULL, NULL, false, false, false, NULL, NULL, 3),
  ((SELECT id FROM screening_tool_configs WHERE tool_type = 'mchatAutism'), 'mchat_4', 'Does your child enjoy playing peek-a-boo/hide-and-seek?', 'మీ బిడ్డ దాగుడుమూతలు ఆడటం ఆనందిస్తారా?', 'autism_risk', 'Autism Risk', 'ఆటిజం ప్రమాదం', NULL, NULL, NULL, false, false, false, NULL, NULL, 4),
  ((SELECT id FROM screening_tool_configs WHERE tool_type = 'mchatAutism'), 'mchat_5', 'Does your child ever pretend, for example, to talk on phone or take care of a doll?', 'మీ బిడ్డ ఎప్పుడైనా నటిస్తారా, ఉదాహరణకు ఫోన్‌లో మాట్లాడటం లేదా బొమ్మను చూసుకోవడం?', 'autism_risk', 'Autism Risk', 'ఆటిజం ప్రమాదం', NULL, NULL, NULL, false, false, false, NULL, NULL, 5),
  ((SELECT id FROM screening_tool_configs WHERE tool_type = 'mchatAutism'), 'mchat_6', 'Does your child ever use his/her index finger to point, to ask for something?', 'మీ బిడ్డ ఏదైనా అడగడానికి చూపుడు వేలుతో చూపిస్తారా?', 'autism_risk', 'Autism Risk', 'ఆటిజం ప్రమాదం', NULL, NULL, NULL, false, false, false, NULL, NULL, 6),
  ((SELECT id FROM screening_tool_configs WHERE tool_type = 'mchatAutism'), 'mchat_7', 'Does your child ever use his/her index finger to point, to indicate interest?', 'మీ బిడ్డ ఆసక్తి చూపించడానికి చూపుడు వేలుతో చూపిస్తారా?', 'autism_risk', 'Autism Risk', 'ఆటిజం ప్రమాదం', NULL, NULL, NULL, true, false, false, NULL, NULL, 7),
  ((SELECT id FROM screening_tool_configs WHERE tool_type = 'mchatAutism'), 'mchat_8', 'Can your child play properly with small toys without mouthing, fiddling, or dropping them?', 'మీ బిడ్డ చిన్న బొమ్మలతో నోటిలో పెట్టకుండా, విరిచిపెట్టకుండా సరిగ్గా ఆడగలరా?', 'autism_risk', 'Autism Risk', 'ఆటిజం ప్రమాదం', NULL, NULL, NULL, false, false, false, NULL, NULL, 8),
  ((SELECT id FROM screening_tool_configs WHERE tool_type = 'mchatAutism'), 'mchat_9', 'Does your child ever bring objects over to you to show you?', 'మీ బిడ్డ ఎప్పుడైనా మీకు చూపించడానికి వస్తువులు తీసుకొస్తారా?', 'autism_risk', 'Autism Risk', 'ఆటిజం ప్రమాదం', NULL, NULL, NULL, true, false, false, NULL, NULL, 9),
  ((SELECT id FROM screening_tool_configs WHERE tool_type = 'mchatAutism'), 'mchat_10', 'Does your child look at you in the eye for more than a second or two?', 'మీ బిడ్డ ఒకటి లేదా రెండు సెకన్ల కంటే ఎక్కువ సేపు మీ కళ్ళలోకి చూస్తారా?', 'autism_risk', 'Autism Risk', 'ఆటిజం ప్రమాదం', NULL, NULL, NULL, false, false, false, NULL, NULL, 10),
  ((SELECT id FROM screening_tool_configs WHERE tool_type = 'mchatAutism'), 'mchat_11', 'Does your child ever seem oversensitive to noise?', 'మీ బిడ్డ ఎప్పుడైనా శబ్దానికి అతిగా సున్నితంగా కనిపిస్తారా?', 'autism_risk', 'Autism Risk', 'ఆటిజం ప్రమాదం', NULL, NULL, NULL, false, false, false, NULL, NULL, 11),
  ((SELECT id FROM screening_tool_configs WHERE tool_type = 'mchatAutism'), 'mchat_12', 'Does your child smile in response to your face or your smile?', 'మీ ముఖం లేదా మీ నవ్వుకు స్పందనగా మీ బిడ్డ నవ్వుతారా?', 'autism_risk', 'Autism Risk', 'ఆటిజం ప్రమాదం', NULL, NULL, NULL, false, false, false, NULL, NULL, 12),
  ((SELECT id FROM screening_tool_configs WHERE tool_type = 'mchatAutism'), 'mchat_13', 'Does your child imitate you (e.g., face expression)?', 'మీ బిడ్డ మిమ్మల్ని అనుకరిస్తారా (ఉదా: ముఖ భావాలు)?', 'autism_risk', 'Autism Risk', 'ఆటిజం ప్రమాదం', NULL, NULL, NULL, true, false, false, NULL, NULL, 13),
  ((SELECT id FROM screening_tool_configs WHERE tool_type = 'mchatAutism'), 'mchat_14', 'Does your child respond to his/her name when called?', 'పేరు పిలిచినప్పుడు మీ బిడ్డ స్పందిస్తారా?', 'autism_risk', 'Autism Risk', 'ఆటిజం ప్రమాదం', NULL, NULL, NULL, true, false, false, NULL, NULL, 14),
  ((SELECT id FROM screening_tool_configs WHERE tool_type = 'mchatAutism'), 'mchat_15', 'If you point at a toy across the room, does your child look at it?', 'గది అవతల బొమ్మను చూపిస్తే, మీ బిడ్డ దాన్ని చూస్తారా?', 'autism_risk', 'Autism Risk', 'ఆటిజం ప్రమాదం', NULL, NULL, NULL, true, false, false, NULL, NULL, 15),
  ((SELECT id FROM screening_tool_configs WHERE tool_type = 'mchatAutism'), 'mchat_16', 'Does your child walk?', 'మీ బిడ్డ నడవగలరా?', 'autism_risk', 'Autism Risk', 'ఆటిజం ప్రమాదం', NULL, NULL, NULL, false, false, false, NULL, NULL, 16),
  ((SELECT id FROM screening_tool_configs WHERE tool_type = 'mchatAutism'), 'mchat_17', 'Does your child look at things you are looking at?', 'మీరు చూస్తున్న వస్తువులను మీ బిడ్డ చూస్తారా?', 'autism_risk', 'Autism Risk', 'ఆటిజం ప్రమాదం', NULL, NULL, NULL, false, false, false, NULL, NULL, 17),
  ((SELECT id FROM screening_tool_configs WHERE tool_type = 'mchatAutism'), 'mchat_18', 'Does your child make unusual finger movements near his/her face?', 'మీ బిడ్డ ముఖం దగ్గర అసాధారణ వేలు కదలికలు చేస్తారా?', 'autism_risk', 'Autism Risk', 'ఆటిజం ప్రమాదం', NULL, NULL, NULL, false, false, false, NULL, NULL, 18),
  ((SELECT id FROM screening_tool_configs WHERE tool_type = 'mchatAutism'), 'mchat_19', 'Does your child try to attract your attention to his/her own activity?', 'మీ బిడ్డ తన కార్యకలాపంపై మీ దృష్టిని ఆకర్షించడానికి ప్రయత్నిస్తారా?', 'autism_risk', 'Autism Risk', 'ఆటిజం ప్రమాదం', NULL, NULL, NULL, false, false, false, NULL, NULL, 19),
  ((SELECT id FROM screening_tool_configs WHERE tool_type = 'mchatAutism'), 'mchat_20', 'Have you ever wondered if your child is deaf?', 'మీ బిడ్డ చెవిటివాడేమో అని మీకు ఎప్పుడైనా అనుమానం వచ్చిందా?', 'autism_risk', 'Autism Risk', 'ఆటిజం ప్రమాదం', NULL, NULL, NULL, false, false, false, NULL, NULL, 20)
ON CONFLICT (tool_config_id, code) DO NOTHING;

-- ============================================================
-- 3G. RBSK DEVELOPMENTAL TOOL (25 items)
-- ============================================================

INSERT INTO screening_questions (tool_config_id, code, text_en, text_te, domain, domain_name_en, domain_name_te, category, category_te, age_months, is_critical, is_red_flag, is_reverse_scored, unit, override_format, sort_order)
VALUES
  ((SELECT id FROM screening_tool_configs WHERE tool_type = 'rbskTool'), 'rbsk_m1', 'Can run and stop without losing balance', 'సమతుల్యత కోల్పోకుండా పరుగెత్తి ఆపగలరా?', 'motor', 'Motor Skills', 'చలన నైపుణ్యాలు', NULL, NULL, NULL, false, false, false, NULL, NULL, 1),
  ((SELECT id FROM screening_tool_configs WHERE tool_type = 'rbskTool'), 'rbsk_m2', 'Can climb stairs alternating feet', 'అడుగులు మారుస్తూ మెట్లు ఎక్కగలరా?', 'motor', 'Motor Skills', 'చలన నైపుణ్యాలు', NULL, NULL, NULL, false, false, false, NULL, NULL, 2),
  ((SELECT id FROM screening_tool_configs WHERE tool_type = 'rbskTool'), 'rbsk_m3', 'Can button and unbutton clothes', 'బట్టలకు బటన్లు పెట్టగలరా మరియు తీయగలరా?', 'motor', 'Motor Skills', 'చలన నైపుణ్యాలు', NULL, NULL, NULL, false, false, false, NULL, NULL, 3),
  ((SELECT id FROM screening_tool_configs WHERE tool_type = 'rbskTool'), 'rbsk_m4', 'Can draw recognizable shapes (circle, square)', 'గుర్తించగలిగే ఆకారాలు (వృత్తం, చతురస్రం) గీయగలరా?', 'motor', 'Motor Skills', 'చలన నైపుణ్యాలు', NULL, NULL, NULL, false, false, false, NULL, NULL, 4),
  ((SELECT id FROM screening_tool_configs WHERE tool_type = 'rbskTool'), 'rbsk_m5', 'Can catch and throw a ball', 'బంతిని పట్టుకోగలరా మరియు విసరగలరా?', 'motor', 'Motor Skills', 'చలన నైపుణ్యాలు', NULL, NULL, NULL, false, false, false, NULL, NULL, 5),
  ((SELECT id FROM screening_tool_configs WHERE tool_type = 'rbskTool'), 'rbsk_c1', 'Can sort objects by color or shape', 'రంగు లేదా ఆకారం ప్రకారం వస్తువులను వర్గీకరించగలరా?', 'cognitive', 'Cognitive', 'జ్ఞానాత్మకం', NULL, NULL, NULL, false, false, false, NULL, NULL, 6),
  ((SELECT id FROM screening_tool_configs WHERE tool_type = 'rbskTool'), 'rbsk_c2', 'Can count up to 10 objects', '10 వస్తువుల వరకు లెక్కించగలరా?', 'cognitive', 'Cognitive', 'జ్ఞానాత్మకం', NULL, NULL, NULL, false, false, false, NULL, NULL, 7),
  ((SELECT id FROM screening_tool_configs WHERE tool_type = 'rbskTool'), 'rbsk_c3', 'Understands concepts of same/different', 'ఒకేలా/వేరుగా అనే భావనలు అర్థం చేసుకుంటారా?', 'cognitive', 'Cognitive', 'జ్ఞానాత్మకం', NULL, NULL, NULL, false, false, false, NULL, NULL, 8),
  ((SELECT id FROM screening_tool_configs WHERE tool_type = 'rbskTool'), 'rbsk_c4', 'Can follow 3-step instructions', '3-దశల సూచనలను అనుసరించగలరా?', 'cognitive', 'Cognitive', 'జ్ఞానాత్మకం', NULL, NULL, NULL, false, false, false, NULL, NULL, 9),
  ((SELECT id FROM screening_tool_configs WHERE tool_type = 'rbskTool'), 'rbsk_c5', 'Shows curiosity and asks questions', 'ఉత్సుకత చూపిస్తారా మరియు ప్రశ్నలు అడుగుతారా?', 'cognitive', 'Cognitive', 'జ్ఞానాత్మకం', NULL, NULL, NULL, false, false, false, NULL, NULL, 10),
  ((SELECT id FROM screening_tool_configs WHERE tool_type = 'rbskTool'), 'rbsk_l1', 'Speaks in sentences of 4-5 words', '4-5 పదాల వాక్యాలలో మాట్లాడతారా?', 'language', 'Language', 'భాష', NULL, NULL, NULL, false, false, false, NULL, NULL, 11),
  ((SELECT id FROM screening_tool_configs WHERE tool_type = 'rbskTool'), 'rbsk_l2', 'Can tell a simple story', 'సాధారణ కథ చెప్పగలరా?', 'language', 'Language', 'భాష', NULL, NULL, NULL, false, false, false, NULL, NULL, 12),
  ((SELECT id FROM screening_tool_configs WHERE tool_type = 'rbskTool'), 'rbsk_l3', 'Understands and uses prepositions (in, on, under)', 'విభక్తులు అర్థం చేసుకుంటారా మరియు వాడతారా (లో, పై, కింద)?', 'language', 'Language', 'భాష', NULL, NULL, NULL, false, false, false, NULL, NULL, 13),
  ((SELECT id FROM screening_tool_configs WHERE tool_type = 'rbskTool'), 'rbsk_l4', 'Can name familiar objects and pictures', 'పరిచిత వస్తువులు మరియు చిత్రాల పేర్లు చెప్పగలరా?', 'language', 'Language', 'భాష', NULL, NULL, NULL, false, false, false, NULL, NULL, 14),
  ((SELECT id FROM screening_tool_configs WHERE tool_type = 'rbskTool'), 'rbsk_l5', 'Speech is understood by strangers', 'అపరిచితులు మాటలు అర్థం చేసుకోగలరా?', 'language', 'Language', 'భాష', NULL, NULL, NULL, false, false, false, NULL, NULL, 15),
  ((SELECT id FROM screening_tool_configs WHERE tool_type = 'rbskTool'), 'rbsk_s1', 'Plays cooperatively with other children', 'ఇతర పిల్లలతో సహకారంతో ఆడతారా?', 'social', 'Social', 'సామాజిక', NULL, NULL, NULL, false, false, false, NULL, NULL, 16),
  ((SELECT id FROM screening_tool_configs WHERE tool_type = 'rbskTool'), 'rbsk_s2', 'Shows empathy towards others', 'ఇతరుల పట్ల సానుభూతి చూపిస్తారా?', 'social', 'Social', 'సామాజిక', NULL, NULL, NULL, false, false, false, NULL, NULL, 17),
  ((SELECT id FROM screening_tool_configs WHERE tool_type = 'rbskTool'), 'rbsk_s3', 'Takes turns in activities', 'కార్యకలాపాలలో వంతులు తీసుకుంటారా?', 'social', 'Social', 'సామాజిక', NULL, NULL, NULL, false, false, false, NULL, NULL, 18),
  ((SELECT id FROM screening_tool_configs WHERE tool_type = 'rbskTool'), 'rbsk_s4', 'Expresses feelings with words', 'భావాలను మాటలతో వ్యక్తం చేస్తారా?', 'social', 'Social', 'సామాజిక', NULL, NULL, NULL, false, false, false, NULL, NULL, 19),
  ((SELECT id FROM screening_tool_configs WHERE tool_type = 'rbskTool'), 'rbsk_s5', 'Follows basic social rules', 'ప్రాథమిక సామాజిక నియమాలను పాటిస్తారా?', 'social', 'Social', 'సామాజిక', NULL, NULL, NULL, false, false, false, NULL, NULL, 20),
  ((SELECT id FROM screening_tool_configs WHERE tool_type = 'rbskTool'), 'rbsk_a1', 'Can feed self independently', 'స్వతంత్రంగా తినగలరా?', 'adaptive', 'Adaptive', 'అనుకూల', NULL, NULL, NULL, false, false, false, NULL, NULL, 21),
  ((SELECT id FROM screening_tool_configs WHERE tool_type = 'rbskTool'), 'rbsk_a2', 'Can use toilet with minimal help', 'కనీస సహాయంతో మరుగుదొడ్డి వాడగలరా?', 'adaptive', 'Adaptive', 'అనుకూల', NULL, NULL, NULL, false, false, false, NULL, NULL, 22),
  ((SELECT id FROM screening_tool_configs WHERE tool_type = 'rbskTool'), 'rbsk_a3', 'Can wash and dry hands', 'చేతులు కడిగి ఆరబెట్టుకోగలరా?', 'adaptive', 'Adaptive', 'అనుకూల', NULL, NULL, NULL, false, false, false, NULL, NULL, 23),
  ((SELECT id FROM screening_tool_configs WHERE tool_type = 'rbskTool'), 'rbsk_a4', 'Can dress/undress with some help', 'కొంత సహాయంతో బట్టలు వేసుకో/విప్పగలరా?', 'adaptive', 'Adaptive', 'అనుకూల', NULL, NULL, NULL, false, false, false, NULL, NULL, 24),
  ((SELECT id FROM screening_tool_configs WHERE tool_type = 'rbskTool'), 'rbsk_a5', 'Shows awareness of danger', 'ప్రమాదం పట్ల అవగాహన చూపిస్తారా?', 'adaptive', 'Adaptive', 'అనుకూల', NULL, NULL, NULL, false, false, false, NULL, NULL, 25)
ON CONFLICT (tool_config_id, code) DO NOTHING;

-- ============================================================
-- 3H. ISAA AUTISM ASSESSMENT (40 items)
-- ============================================================

INSERT INTO screening_questions (tool_config_id, code, text_en, text_te, domain, domain_name_en, domain_name_te, category, category_te, age_months, is_critical, is_red_flag, is_reverse_scored, unit, override_format, sort_order)
VALUES
  ((SELECT id FROM screening_tool_configs WHERE tool_type = 'isaaAutism'), 'isaa_s1', 'Has poor eye contact', 'కంటి సంబంధం బలహీనంగా ఉంది', 'social', 'Social Relationship', 'సామాజిక సంబంధం', NULL, NULL, NULL, false, false, false, NULL, NULL, 1),
  ((SELECT id FROM screening_tool_configs WHERE tool_type = 'isaaAutism'), 'isaa_s2', 'Lacks social smile', 'సామాజిక నవ్వు లేదు', 'social', 'Social Relationship', 'సామాజిక సంబంధం', NULL, NULL, NULL, false, false, false, NULL, NULL, 2),
  ((SELECT id FROM screening_tool_configs WHERE tool_type = 'isaaAutism'), 'isaa_s3', 'Remains aloof', 'దూరంగా ఉంటారు', 'social', 'Social Relationship', 'సామాజిక సంబంధం', NULL, NULL, NULL, false, false, false, NULL, NULL, 3),
  ((SELECT id FROM screening_tool_configs WHERE tool_type = 'isaaAutism'), 'isaa_s4', 'Does not reach out to others', 'ఇతరుల వద్దకు వెళ్ళరు', 'social', 'Social Relationship', 'సామాజిక సంబంధం', NULL, NULL, NULL, false, false, false, NULL, NULL, 4),
  ((SELECT id FROM screening_tool_configs WHERE tool_type = 'isaaAutism'), 'isaa_s5', 'Unable to relate to people', 'వ్యక్తులతో సంబంధం పెట్టుకోలేరు', 'social', 'Social Relationship', 'సామాజిక సంబంధం', NULL, NULL, NULL, false, false, false, NULL, NULL, 5),
  ((SELECT id FROM screening_tool_configs WHERE tool_type = 'isaaAutism'), 'isaa_s6', 'Unable to respond to social/environmental cues', 'సామాజిక/పర్యావరణ సంకేతాలకు స్పందించలేరు', 'social', 'Social Relationship', 'సామాజిక సంబంధం', NULL, NULL, NULL, false, false, false, NULL, NULL, 6),
  ((SELECT id FROM screening_tool_configs WHERE tool_type = 'isaaAutism'), 'isaa_s7', 'Engages in solitary and repetitive play activities', 'ఏకాంత మరియు పునరావృత ఆట కార్యకలాపాలలో పాల్గొంటారు', 'social', 'Social Relationship', 'సామాజిక సంబంధం', NULL, NULL, NULL, false, false, false, NULL, NULL, 7),
  ((SELECT id FROM screening_tool_configs WHERE tool_type = 'isaaAutism'), 'isaa_s8', 'Unable to take turns in social interaction', 'సామాజిక సంభాషణలో వంతులు తీసుకోలేరు', 'social', 'Social Relationship', 'సామాజిక సంబంధం', NULL, NULL, NULL, false, false, false, NULL, NULL, 8),
  ((SELECT id FROM screening_tool_configs WHERE tool_type = 'isaaAutism'), 'isaa_s9', 'Does not maintain peer relationships', 'తోటివారి సంబంధాలు నిర్వహించలేరు', 'social', 'Social Relationship', 'సామాజిక సంబంధం', NULL, NULL, NULL, false, false, false, NULL, NULL, 9),
  ((SELECT id FROM screening_tool_configs WHERE tool_type = 'isaaAutism'), 'isaa_s10', 'Shows no attachment to caregiver', 'పోషకుడి పట్ల అనుబంధం చూపించరు', 'social', 'Social Relationship', 'సామాజిక సంబంధం', NULL, NULL, NULL, false, false, false, NULL, NULL, 10),
  ((SELECT id FROM screening_tool_configs WHERE tool_type = 'isaaAutism'), 'isaa_e1', 'Shows inappropriate emotional response', 'అనుచితమైన భావోద్వేగ స్పందన చూపిస్తారు', 'emotional', 'Emotional Responsiveness', 'భావోద్వేగ స్పందన', NULL, NULL, NULL, false, false, false, NULL, NULL, 11),
  ((SELECT id FROM screening_tool_configs WHERE tool_type = 'isaaAutism'), 'isaa_e2', 'Shows exaggerated emotions', 'అతిశయోక్తి భావోద్వేగాలు చూపిస్తారు', 'emotional', 'Emotional Responsiveness', 'భావోద్వేగ స్పందన', NULL, NULL, NULL, false, false, false, NULL, NULL, 12),
  ((SELECT id FROM screening_tool_configs WHERE tool_type = 'isaaAutism'), 'isaa_e3', 'Engages in self-stimulating emotions', 'స్వీయ-ఉద్దీపన భావోద్వేగాలలో పాల్గొంటారు', 'emotional', 'Emotional Responsiveness', 'భావోద్వేగ స్పందన', NULL, NULL, NULL, false, false, false, NULL, NULL, 13),
  ((SELECT id FROM screening_tool_configs WHERE tool_type = 'isaaAutism'), 'isaa_e4', 'Lacks fear of danger', 'ప్రమాదం పట్ల భయం లేదు', 'emotional', 'Emotional Responsiveness', 'భావోద్వేగ స్పందన', NULL, NULL, NULL, false, false, false, NULL, NULL, 14),
  ((SELECT id FROM screening_tool_configs WHERE tool_type = 'isaaAutism'), 'isaa_e5', 'Excited or agitated for no apparent reason', 'స్పష్టమైన కారణం లేకుండా ఉత్సాహంగా లేదా ఆందోళనగా ఉంటారు', 'emotional', 'Emotional Responsiveness', 'భావోద్వేగ స్పందన', NULL, NULL, NULL, false, false, false, NULL, NULL, 15),
  ((SELECT id FROM screening_tool_configs WHERE tool_type = 'isaaAutism'), 'isaa_e6', 'Has flat/inappropriate affect', 'చదునైన/అనుచితమైన భావప్రకటన ఉంది', 'emotional', 'Emotional Responsiveness', 'భావోద్వేగ స్పందన', NULL, NULL, NULL, false, false, false, NULL, NULL, 16),
  ((SELECT id FROM screening_tool_configs WHERE tool_type = 'isaaAutism'), 'isaa_c1', 'Acquired speech and lost it', 'మాట నేర్చుకుని కోల్పోయారు', 'communication', 'Speech & Communication', 'మాట & సంభాషణ', NULL, NULL, NULL, false, false, false, NULL, NULL, 17),
  ((SELECT id FROM screening_tool_configs WHERE tool_type = 'isaaAutism'), 'isaa_c2', 'Has difficulty in using non-verbal language/gestures', 'అశాబ్దిక భాష/సైగలు వాడటంలో కష్టం', 'communication', 'Speech & Communication', 'మాట & సంభాషణ', NULL, NULL, NULL, false, false, false, NULL, NULL, 18),
  ((SELECT id FROM screening_tool_configs WHERE tool_type = 'isaaAutism'), 'isaa_c3', 'Echoes words or sentences', 'పదాలు లేదా వాక్యాలు ప్రతిధ్వనిస్తారు', 'communication', 'Speech & Communication', 'మాట & సంభాషణ', NULL, NULL, NULL, false, false, false, NULL, NULL, 19),
  ((SELECT id FROM screening_tool_configs WHERE tool_type = 'isaaAutism'), 'isaa_c4', 'Produces infantile squeals or unusual noises', 'శిశు కీచు శబ్దాలు లేదా అసాధారణ శబ్దాలు చేస్తారు', 'communication', 'Speech & Communication', 'మాట & సంభాషణ', NULL, NULL, NULL, false, false, false, NULL, NULL, 20),
  ((SELECT id FROM screening_tool_configs WHERE tool_type = 'isaaAutism'), 'isaa_c5', 'Unable to initiate or sustain conversation', 'సంభాషణ ప్రారంభించడం లేదా కొనసాగించడం చేయలేరు', 'communication', 'Speech & Communication', 'మాట & సంభాషణ', NULL, NULL, NULL, false, false, false, NULL, NULL, 21),
  ((SELECT id FROM screening_tool_configs WHERE tool_type = 'isaaAutism'), 'isaa_c6', 'Uses jargon or meaningless words', 'అర్థంలేని పదాలు లేదా పరిభాష వాడతారు', 'communication', 'Speech & Communication', 'మాట & సంభాషణ', NULL, NULL, NULL, false, false, false, NULL, NULL, 22),
  ((SELECT id FROM screening_tool_configs WHERE tool_type = 'isaaAutism'), 'isaa_c7', 'Uses pronoun reversals', 'సర్వనామాలను తారుమారు చేసి వాడతారు', 'communication', 'Speech & Communication', 'మాట & సంభాషణ', NULL, NULL, NULL, false, false, false, NULL, NULL, 23),
  ((SELECT id FROM screening_tool_configs WHERE tool_type = 'isaaAutism'), 'isaa_b1', 'Engages in stereotyped and repetitive motor mannerisms', 'మూసపోసిన మరియు పునరావృత చలన పద్ధతులలో పాల్గొంటారు', 'behavior', 'Behavior Patterns', 'ప్రవర్తన నమూనాలు', NULL, NULL, NULL, false, false, false, NULL, NULL, 24),
  ((SELECT id FROM screening_tool_configs WHERE tool_type = 'isaaAutism'), 'isaa_b2', 'Shows attachment to inanimate objects', 'నిర్జీవ వస్తువుల పట్ల అనుబంధం చూపిస్తారు', 'behavior', 'Behavior Patterns', 'ప్రవర్తన నమూనాలు', NULL, NULL, NULL, false, false, false, NULL, NULL, 25),
  ((SELECT id FROM screening_tool_configs WHERE tool_type = 'isaaAutism'), 'isaa_b3', 'Shows hyperactivity/restlessness', 'అతి చురుకుదనం/అశాంతి చూపిస్తారు', 'behavior', 'Behavior Patterns', 'ప్రవర్తన నమూనాలు', NULL, NULL, NULL, false, false, false, NULL, NULL, 26),
  ((SELECT id FROM screening_tool_configs WHERE tool_type = 'isaaAutism'), 'isaa_b4', 'Exhibits aggressive behavior', 'దూకుడు ప్రవర్తన చూపిస్తారు', 'behavior', 'Behavior Patterns', 'ప్రవర్తన నమూనాలు', NULL, NULL, NULL, false, false, false, NULL, NULL, 27),
  ((SELECT id FROM screening_tool_configs WHERE tool_type = 'isaaAutism'), 'isaa_b5', 'Throws temper tantrums', 'కోపం ప్రదర్శిస్తారు', 'behavior', 'Behavior Patterns', 'ప్రవర్తన నమూనాలు', NULL, NULL, NULL, false, false, false, NULL, NULL, 28),
  ((SELECT id FROM screening_tool_configs WHERE tool_type = 'isaaAutism'), 'isaa_b6', 'Engages in self-injurious behavior', 'స్వీయ-హాని ప్రవర్తనలో పాల్గొంటారు', 'behavior', 'Behavior Patterns', 'ప్రవర్తన నమూనాలు', NULL, NULL, NULL, false, false, false, NULL, NULL, 29),
  ((SELECT id FROM screening_tool_configs WHERE tool_type = 'isaaAutism'), 'isaa_b7', 'Insists on sameness/resists change', 'ఒకేలా ఉండాలని పట్టుబడతారు/మార్పును ప్రతిఘటిస్తారు', 'behavior', 'Behavior Patterns', 'ప్రవర్తన నమూనాలు', NULL, NULL, NULL, false, false, false, NULL, NULL, 30),
  ((SELECT id FROM screening_tool_configs WHERE tool_type = 'isaaAutism'), 'isaa_b8', 'Exhibits obsessive behavior', 'ఆబ్సెసివ్ ప్రవర్తన చూపిస్తారు', 'behavior', 'Behavior Patterns', 'ప్రవర్తన నమూనాలు', NULL, NULL, NULL, false, false, false, NULL, NULL, 31),
  ((SELECT id FROM screening_tool_configs WHERE tool_type = 'isaaAutism'), 'isaa_sn1', 'Unusual response to sensory stimuli', 'ఇంద్రియ ఉద్దీపనలకు అసాధారణ స్పందన', 'sensory', 'Sensory Aspects', 'ఇంద్రియ అంశాలు', NULL, NULL, NULL, false, false, false, NULL, NULL, 32),
  ((SELECT id FROM screening_tool_configs WHERE tool_type = 'isaaAutism'), 'isaa_sn2', 'Stares into space for long periods', 'చాలా సేపు శూన్యంలోకి చూస్తారు', 'sensory', 'Sensory Aspects', 'ఇంద్రియ అంశాలు', NULL, NULL, NULL, false, false, false, NULL, NULL, 33),
  ((SELECT id FROM screening_tool_configs WHERE tool_type = 'isaaAutism'), 'isaa_sn3', 'Has difficulty in tracking objects', 'వస్తువులను అనుసరించడంలో కష్టం', 'sensory', 'Sensory Aspects', 'ఇంద్రియ అంశాలు', NULL, NULL, NULL, false, false, false, NULL, NULL, 34),
  ((SELECT id FROM screening_tool_configs WHERE tool_type = 'isaaAutism'), 'isaa_sn4', 'Insensitive to pain', 'నొప్పి పట్ల సున్నితత్వం లేదు', 'sensory', 'Sensory Aspects', 'ఇంద్రియ అంశాలు', NULL, NULL, NULL, false, false, false, NULL, NULL, 35),
  ((SELECT id FROM screening_tool_configs WHERE tool_type = 'isaaAutism'), 'isaa_sn5', 'Responds to objects/people unusually by smelling, touching, or tasting', 'వాసన చూడడం, తాకడం లేదా రుచి చూడడం ద్వారా వస్తువులు/వ్యక్తులకు అసాధారణంగా స్పందిస్తారు', 'sensory', 'Sensory Aspects', 'ఇంద్రియ అంశాలు', NULL, NULL, NULL, false, false, false, NULL, NULL, 36),
  ((SELECT id FROM screening_tool_configs WHERE tool_type = 'isaaAutism'), 'isaa_cg1', 'Inconsistent attention and concentration', 'అస్థిరమైన శ్రద్ధ మరియు ఏకాగ్రత', 'cognitive', 'Cognitive Component', 'జ్ఞానాత్మక భాగం', NULL, NULL, NULL, false, false, false, NULL, NULL, 37),
  ((SELECT id FROM screening_tool_configs WHERE tool_type = 'isaaAutism'), 'isaa_cg2', 'Shows delay in responding', 'స్పందనలో ఆలస్యం చూపిస్తారు', 'cognitive', 'Cognitive Component', 'జ్ఞానాత్మక భాగం', NULL, NULL, NULL, false, false, false, NULL, NULL, 38),
  ((SELECT id FROM screening_tool_configs WHERE tool_type = 'isaaAutism'), 'isaa_cg3', 'Has unusual memory of certain things', 'కొన్ని విషయాలపై అసాధారణ జ్ఞాపకశక్తి ఉంది', 'cognitive', 'Cognitive Component', 'జ్ఞానాత్మక భాగం', NULL, NULL, NULL, false, false, false, NULL, NULL, 39),
  ((SELECT id FROM screening_tool_configs WHERE tool_type = 'isaaAutism'), 'isaa_cg4', 'Has difficulty in generalizing learned skills', 'నేర్చుకున్న నైపుణ్యాలను సాధారణీకరించడంలో కష్టం', 'cognitive', 'Cognitive Component', 'జ్ఞానాత్మక భాగం', NULL, NULL, NULL, false, false, false, NULL, NULL, 40)
ON CONFLICT (tool_config_id, code) DO NOTHING;

-- ============================================================
-- 3I. ADHD SCREENING (10 items)
-- ============================================================

INSERT INTO screening_questions (tool_config_id, code, text_en, text_te, domain, domain_name_en, domain_name_te, category, category_te, age_months, is_critical, is_red_flag, is_reverse_scored, unit, override_format, sort_order)
VALUES
  ((SELECT id FROM screening_tool_configs WHERE tool_type = 'adhdScreening'), 'adhd_in1', 'Has difficulty sustaining attention in tasks or play', 'పనులు లేదా ఆటలో శ్రద్ధ నిలుపుకోవడంలో కష్టం', 'inattention', 'Inattention', 'అశ్రద్ధ', NULL, NULL, NULL, false, false, false, NULL, NULL, 1),
  ((SELECT id FROM screening_tool_configs WHERE tool_type = 'adhdScreening'), 'adhd_in2', 'Does not seem to listen when spoken to directly', 'నేరుగా మాట్లాడినప్పుడు వినడం లేదని అనిపిస్తుంది', 'inattention', 'Inattention', 'అశ్రద్ధ', NULL, NULL, NULL, false, false, false, NULL, NULL, 2),
  ((SELECT id FROM screening_tool_configs WHERE tool_type = 'adhdScreening'), 'adhd_in3', 'Is easily distracted by outside stimuli', 'బయటి ఉద్దీపనల వల్ల సులభంగా దృష్టి మళ్ళుతుంది', 'inattention', 'Inattention', 'అశ్రద్ధ', NULL, NULL, NULL, false, false, false, NULL, NULL, 3),
  ((SELECT id FROM screening_tool_configs WHERE tool_type = 'adhdScreening'), 'adhd_in4', 'Has difficulty organizing tasks and activities', 'పనులు మరియు కార్యకలాపాలను వ్యవస్థీకరించడంలో కష్టం', 'inattention', 'Inattention', 'అశ్రద్ధ', NULL, NULL, NULL, false, false, false, NULL, NULL, 4),
  ((SELECT id FROM screening_tool_configs WHERE tool_type = 'adhdScreening'), 'adhd_hy1', 'Fidgets with hands or feet or squirms in seat', 'చేతులు లేదా కాళ్ళతో కదులుతూ ఉంటారు లేదా సీట్లో కదులుతారు', 'hyperactivity', 'Hyperactivity', 'అతి చురుకుదనం', NULL, NULL, NULL, false, false, false, NULL, NULL, 5),
  ((SELECT id FROM screening_tool_configs WHERE tool_type = 'adhdScreening'), 'adhd_hy2', 'Runs about or climbs excessively in inappropriate situations', 'అనుచితమైన పరిస్థితులలో అతిగా పరుగెత్తడం లేదా ఎక్కడం', 'hyperactivity', 'Hyperactivity', 'అతి చురుకుదనం', NULL, NULL, NULL, false, false, false, NULL, NULL, 6),
  ((SELECT id FROM screening_tool_configs WHERE tool_type = 'adhdScreening'), 'adhd_hy3', 'Is always on the go or acts as if driven by a motor', 'ఎప్పుడూ తిరుగుతూ ఉంటారు లేదా మోటార్ చేత నడిపించబడినట్లు ప్రవర్తిస్తారు', 'hyperactivity', 'Hyperactivity', 'అతి చురుకుదనం', NULL, NULL, NULL, false, false, false, NULL, NULL, 7),
  ((SELECT id FROM screening_tool_configs WHERE tool_type = 'adhdScreening'), 'adhd_im1', 'Blurts out answers before questions are completed', 'ప్రశ్నలు పూర్తి కాకముందే సమాధానాలు చెప్పేస్తారు', 'impulsivity', 'Impulsivity', 'ఆవేశపూరితం', NULL, NULL, NULL, false, false, false, NULL, NULL, 8),
  ((SELECT id FROM screening_tool_configs WHERE tool_type = 'adhdScreening'), 'adhd_im2', 'Has difficulty waiting for turn', 'వంతు కోసం ఎదురుచూడడంలో కష్టం', 'impulsivity', 'Impulsivity', 'ఆవేశపూరితం', NULL, NULL, NULL, false, false, false, NULL, NULL, 9),
  ((SELECT id FROM screening_tool_configs WHERE tool_type = 'adhdScreening'), 'adhd_im3', 'Interrupts or intrudes on others', 'ఇతరులను అడ్డుకుంటారు లేదా జోక్యం చేసుకుంటారు', 'impulsivity', 'Impulsivity', 'ఆవేశపూరితం', NULL, NULL, NULL, false, false, false, NULL, NULL, 10)
ON CONFLICT (tool_config_id, code) DO NOTHING;

-- ============================================================
-- 3J. RBSK BEHAVIORAL SCREENING (10 items)
-- ============================================================

INSERT INTO screening_questions (tool_config_id, code, text_en, text_te, domain, domain_name_en, domain_name_te, category, category_te, age_months, is_critical, is_red_flag, is_reverse_scored, unit, override_format, sort_order)
VALUES
  ((SELECT id FROM screening_tool_configs WHERE tool_type = 'rbskBehavioral'), 'rbsk_b1', 'Has frequent temper tantrums', 'తరచుగా కోపం ప్రదర్శిస్తారా?', 'behavioral', 'Behavioral', 'ప్రవర్తన', NULL, NULL, NULL, false, false, false, NULL, NULL, 1),
  ((SELECT id FROM screening_tool_configs WHERE tool_type = 'rbskBehavioral'), 'rbsk_b2', 'Is unusually aggressive towards others', 'ఇతరుల పట్ల అసాధారణంగా దూకుడుగా ఉంటారా?', 'behavioral', 'Behavioral', 'ప్రవర్తన', NULL, NULL, NULL, false, false, false, NULL, NULL, 2),
  ((SELECT id FROM screening_tool_configs WHERE tool_type = 'rbskBehavioral'), 'rbsk_b3', 'Shows extreme withdrawal or shyness', 'అతిగా ఏకాంతంగా లేదా సిగ్గుగా ఉంటారా?', 'behavioral', 'Behavioral', 'ప్రవర్తన', NULL, NULL, NULL, false, false, false, NULL, NULL, 3),
  ((SELECT id FROM screening_tool_configs WHERE tool_type = 'rbskBehavioral'), 'rbsk_b4', 'Has unusual repetitive behaviors or rituals', 'అసాధారణ పునరావృత ప్రవర్తనలు లేదా ఆచారాలు ఉన్నాయా?', 'behavioral', 'Behavioral', 'ప్రవర్తన', NULL, NULL, NULL, false, false, false, NULL, NULL, 4),
  ((SELECT id FROM screening_tool_configs WHERE tool_type = 'rbskBehavioral'), 'rbsk_b5', 'Has difficulty separating from caregiver', 'పోషకుడి నుండి వేరు కావడంలో కష్టం ఉందా?', 'behavioral', 'Behavioral', 'ప్రవర్తన', NULL, NULL, NULL, false, false, false, NULL, NULL, 5),
  ((SELECT id FROM screening_tool_configs WHERE tool_type = 'rbskBehavioral'), 'rbsk_b6', 'Shows significant sleep disturbances', 'గణనీయమైన నిద్ర సమస్యలు ఉన్నాయా?', 'behavioral', 'Behavioral', 'ప్రవర్తన', NULL, NULL, NULL, false, false, false, NULL, NULL, 6),
  ((SELECT id FROM screening_tool_configs WHERE tool_type = 'rbskBehavioral'), 'rbsk_b7', 'Has excessive fears or anxiety', 'అతిగా భయాలు లేదా ఆందోళన ఉందా?', 'behavioral', 'Behavioral', 'ప్రవర్తన', NULL, NULL, NULL, false, false, false, NULL, NULL, 7),
  ((SELECT id FROM screening_tool_configs WHERE tool_type = 'rbskBehavioral'), 'rbsk_b8', 'Engages in self-harming behavior', 'తనకు తాను హాని చేసుకునే ప్రవర్తన ఉందా?', 'behavioral', 'Behavioral', 'ప్రవర్తన', NULL, NULL, NULL, false, true, false, NULL, NULL, 8),
  ((SELECT id FROM screening_tool_configs WHERE tool_type = 'rbskBehavioral'), 'rbsk_b9', 'Shows regression in previously acquired skills', 'ఇంతకు ముందు నేర్చుకున్న నైపుణ్యాలలో తిరోగమనం కనిపిస్తుందా?', 'behavioral', 'Behavioral', 'ప్రవర్తన', NULL, NULL, NULL, false, true, false, NULL, NULL, 9),
  ((SELECT id FROM screening_tool_configs WHERE tool_type = 'rbskBehavioral'), 'rbsk_b10', 'Has persistent eating difficulties', 'నిరంతర తినడం సమస్యలు ఉన్నాయా?', 'behavioral', 'Behavioral', 'ప్రవర్తన', NULL, NULL, NULL, false, false, false, NULL, NULL, 10)
ON CONFLICT (tool_config_id, code) DO NOTHING;

-- ============================================================
-- 3K. SDQ BEHAVIORAL ASSESSMENT (33 items)
-- ============================================================

INSERT INTO screening_questions (tool_config_id, code, text_en, text_te, domain, domain_name_en, domain_name_te, category, category_te, age_months, is_critical, is_red_flag, is_reverse_scored, unit, override_format, sort_order)
VALUES
  ((SELECT id FROM screening_tool_configs WHERE tool_type = 'sdqBehavioral'), 'sdq_e1', 'Often complains of headaches, stomach-aches or sickness', 'తరచుగా తలనొప్పి, కడుపునొప్పి లేదా అనారోగ్యం గురించి ఫిర్యాదు చేస్తారు', 'emotional', 'Emotional Symptoms', 'భావోద్వేగ లక్షణాలు', NULL, NULL, NULL, false, false, false, NULL, NULL, 1),
  ((SELECT id FROM screening_tool_configs WHERE tool_type = 'sdqBehavioral'), 'sdq_e2', 'Has many worries, often seems worried', 'చాలా ఆందోళనలు ఉన్నాయి, తరచుగా ఆందోళనగా కనిపిస్తారు', 'emotional', 'Emotional Symptoms', 'భావోద్వేగ లక్షణాలు', NULL, NULL, NULL, false, false, false, NULL, NULL, 2),
  ((SELECT id FROM screening_tool_configs WHERE tool_type = 'sdqBehavioral'), 'sdq_e3', 'Often unhappy, down-hearted or tearful', 'తరచుగా అసంతృప్తిగా, నిరాశగా లేదా కన్నీళ్ళతో ఉంటారు', 'emotional', 'Emotional Symptoms', 'భావోద్వేగ లక్షణాలు', NULL, NULL, NULL, false, false, false, NULL, NULL, 3),
  ((SELECT id FROM screening_tool_configs WHERE tool_type = 'sdqBehavioral'), 'sdq_e4', 'Nervous or clingy in new situations', 'కొత్త పరిస్థితులలో నాడీగా లేదా అతుక్కుపోతారు', 'emotional', 'Emotional Symptoms', 'భావోద్వేగ లక్షణాలు', NULL, NULL, NULL, false, false, false, NULL, NULL, 4),
  ((SELECT id FROM screening_tool_configs WHERE tool_type = 'sdqBehavioral'), 'sdq_e5', 'Many fears, easily scared', 'చాలా భయాలు, సులభంగా భయపడతారు', 'emotional', 'Emotional Symptoms', 'భావోద్వేగ లక్షణాలు', NULL, NULL, NULL, false, false, false, NULL, NULL, 5),
  ((SELECT id FROM screening_tool_configs WHERE tool_type = 'sdqBehavioral'), 'sdq_c1', 'Often has temper tantrums or hot tempers', 'తరచుగా కోపం ప్రదర్శిస్తారు లేదా చిటపటలాడతారు', 'conduct', 'Conduct Problems', 'ప్రవర్తన సమస్యలు', NULL, NULL, NULL, false, false, false, NULL, NULL, 6),
  ((SELECT id FROM screening_tool_configs WHERE tool_type = 'sdqBehavioral'), 'sdq_c2', 'Generally obedient, usually does what adults request', 'సాధారణంగా విధేయులు, పెద్దలు కోరినది చేస్తారు', 'conduct', 'Conduct Problems', 'ప్రవర్తన సమస్యలు', NULL, NULL, NULL, false, false, true, NULL, NULL, 7),
  ((SELECT id FROM screening_tool_configs WHERE tool_type = 'sdqBehavioral'), 'sdq_c3', 'Often fights with other children or bullies them', 'తరచుగా ఇతర పిల్లలతో గొడవ చేస్తారు లేదా వారిని బెదిరిస్తారు', 'conduct', 'Conduct Problems', 'ప్రవర్తన సమస్యలు', NULL, NULL, NULL, false, false, false, NULL, NULL, 8),
  ((SELECT id FROM screening_tool_configs WHERE tool_type = 'sdqBehavioral'), 'sdq_c4', 'Often lies or cheats', 'తరచుగా అబద్ధాలు చెప్తారు లేదా మోసం చేస్తారు', 'conduct', 'Conduct Problems', 'ప్రవర్తన సమస్యలు', NULL, NULL, NULL, false, false, false, NULL, NULL, 9),
  ((SELECT id FROM screening_tool_configs WHERE tool_type = 'sdqBehavioral'), 'sdq_c5', 'Steals from home, school or elsewhere', 'ఇంటి నుండి, పాఠశాల నుండి లేదా ఇతర చోట్ల దొంగిలిస్తారు', 'conduct', 'Conduct Problems', 'ప్రవర్తన సమస్యలు', NULL, NULL, NULL, false, false, false, NULL, NULL, 10),
  ((SELECT id FROM screening_tool_configs WHERE tool_type = 'sdqBehavioral'), 'sdq_h1', 'Restless, overactive, cannot stay still for long', 'అశాంతిగా, అతి చురుకుగా, ఎక్కువ సేపు నిలబడలేరు', 'hyperactivity', 'Hyperactivity', 'అతి చురుకుదనం', NULL, NULL, NULL, false, false, false, NULL, NULL, 11),
  ((SELECT id FROM screening_tool_configs WHERE tool_type = 'sdqBehavioral'), 'sdq_h2', 'Constantly fidgeting or squirming', 'నిరంతరం కదులుతూ ఉంటారు', 'hyperactivity', 'Hyperactivity', 'అతి చురుకుదనం', NULL, NULL, NULL, false, false, false, NULL, NULL, 12),
  ((SELECT id FROM screening_tool_configs WHERE tool_type = 'sdqBehavioral'), 'sdq_h3', 'Easily distracted, concentration wanders', 'సులభంగా దృష్టి మళ్ళుతుంది, ఏకాగ్రత తగ్గుతుంది', 'hyperactivity', 'Hyperactivity', 'అతి చురుకుదనం', NULL, NULL, NULL, false, false, false, NULL, NULL, 13),
  ((SELECT id FROM screening_tool_configs WHERE tool_type = 'sdqBehavioral'), 'sdq_h4', 'Thinks things out before acting', 'చేయడానికి ముందు ఆలోచిస్తారు', 'hyperactivity', 'Hyperactivity', 'అతి చురుకుదనం', NULL, NULL, NULL, false, false, true, NULL, NULL, 14),
  ((SELECT id FROM screening_tool_configs WHERE tool_type = 'sdqBehavioral'), 'sdq_h5', 'Sees tasks through to the end, good attention span', 'పనులను చివరి వరకు చేస్తారు, మంచి శ్రద్ధ', 'hyperactivity', 'Hyperactivity', 'అతి చురుకుదనం', NULL, NULL, NULL, false, false, true, NULL, NULL, 15),
  ((SELECT id FROM screening_tool_configs WHERE tool_type = 'sdqBehavioral'), 'sdq_p1', 'Rather solitary, tends to play alone', 'ఏకాంతంగా, ఒంటరిగా ఆడటానికి ఇష్టపడతారు', 'peer', 'Peer Problems', 'తోటివారి సమస్యలు', NULL, NULL, NULL, false, false, false, NULL, NULL, 16),
  ((SELECT id FROM screening_tool_configs WHERE tool_type = 'sdqBehavioral'), 'sdq_p2', 'Has at least one good friend', 'కనీసం ఒక మంచి స్నేహితుడు ఉన్నారు', 'peer', 'Peer Problems', 'తోటివారి సమస్యలు', NULL, NULL, NULL, false, false, true, NULL, NULL, 17),
  ((SELECT id FROM screening_tool_configs WHERE tool_type = 'sdqBehavioral'), 'sdq_p3', 'Generally liked by other children', 'సాధారణంగా ఇతర పిల్లలు ఇష్టపడతారు', 'peer', 'Peer Problems', 'తోటివారి సమస్యలు', NULL, NULL, NULL, false, false, true, NULL, NULL, 18),
  ((SELECT id FROM screening_tool_configs WHERE tool_type = 'sdqBehavioral'), 'sdq_p4', 'Picked on or bullied by other children', 'ఇతర పిల్లలు ఎగతాళి చేస్తారు లేదా బెదిరిస్తారు', 'peer', 'Peer Problems', 'తోటివారి సమస్యలు', NULL, NULL, NULL, false, false, false, NULL, NULL, 19),
  ((SELECT id FROM screening_tool_configs WHERE tool_type = 'sdqBehavioral'), 'sdq_p5', 'Gets on better with adults than with other children', 'ఇతర పిల్లల కంటే పెద్దలతో బాగా కలిసిపోతారు', 'peer', 'Peer Problems', 'తోటివారి సమస్యలు', NULL, NULL, NULL, false, false, false, NULL, NULL, 20),
  ((SELECT id FROM screening_tool_configs WHERE tool_type = 'sdqBehavioral'), 'sdq_ps1', 'Considerate of other people''s feelings', 'ఇతరుల భావాలను పరిగణిస్తారు', 'prosocial', 'Prosocial Behavior', 'ప్రోసోషల్ ప్రవర్తన', NULL, NULL, NULL, false, false, false, NULL, NULL, 21),
  ((SELECT id FROM screening_tool_configs WHERE tool_type = 'sdqBehavioral'), 'sdq_ps2', 'Shares readily with other children', 'ఇతర పిల్లలతో సులభంగా పంచుకుంటారు', 'prosocial', 'Prosocial Behavior', 'ప్రోసోషల్ ప్రవర్తన', NULL, NULL, NULL, false, false, false, NULL, NULL, 22),
  ((SELECT id FROM screening_tool_configs WHERE tool_type = 'sdqBehavioral'), 'sdq_ps3', 'Helpful if someone is hurt, upset or feeling ill', 'ఎవరైనా గాయపడితే, బాధపడితే లేదా అనారోగ్యంగా ఉంటే సహాయం చేస్తారు', 'prosocial', 'Prosocial Behavior', 'ప్రోసోషల్ ప్రవర్తన', NULL, NULL, NULL, false, false, false, NULL, NULL, 23),
  ((SELECT id FROM screening_tool_configs WHERE tool_type = 'sdqBehavioral'), 'sdq_ps4', 'Kind to younger children', 'చిన్న పిల్లల పట్ల దయగా ఉంటారు', 'prosocial', 'Prosocial Behavior', 'ప్రోసోషల్ ప్రవర్తన', NULL, NULL, NULL, false, false, false, NULL, NULL, 24),
  ((SELECT id FROM screening_tool_configs WHERE tool_type = 'sdqBehavioral'), 'sdq_ps5', 'Often volunteers to help others', 'తరచుగా ఇతరులకు సహాయం చేయడానికి ముందుకు వస్తారు', 'prosocial', 'Prosocial Behavior', 'ప్రోసోషల్ ప్రవర్తన', NULL, NULL, NULL, false, false, false, NULL, NULL, 25),
  ((SELECT id FROM screening_tool_configs WHERE tool_type = 'sdqBehavioral'), 'sdq_i1', 'Overall, do you think your child has difficulties in emotions, concentration, behavior, or being able to get on with other people?', 'మొత్తంగా, మీ బిడ్డకు భావోద్వేగాలు, ఏకాగ్రత, ప్రవర్తన లేదా ఇతరులతో కలిసి ఉండటంలో కష్టాలు ఉన్నాయా?', 'impact', 'Impact', 'ప్రభావం', 'Impact', 'ప్రభావం', NULL, false, false, false, NULL, NULL, 26),
  ((SELECT id FROM screening_tool_configs WHERE tool_type = 'sdqBehavioral'), 'sdq_i2', 'Do the difficulties upset or distress your child?', 'ఈ కష్టాలు మీ బిడ్డను బాధపెడుతున్నాయా?', 'impact', 'Impact', 'ప్రభావం', NULL, NULL, NULL, false, false, false, NULL, NULL, 27),
  ((SELECT id FROM screening_tool_configs WHERE tool_type = 'sdqBehavioral'), 'sdq_i3', 'Do the difficulties interfere with child''s everyday life at home?', 'ఈ కష్టాలు ఇంట్లో బిడ్డ రోజువారీ జీవితాన్ని ప్రభావితం చేస్తున్నాయా?', 'impact', 'Impact', 'ప్రభావం', NULL, NULL, NULL, false, false, false, NULL, NULL, 28),
  ((SELECT id FROM screening_tool_configs WHERE tool_type = 'sdqBehavioral'), 'sdq_i4', 'Do the difficulties interfere with friendships?', 'ఈ కష్టాలు స్నేహాలను ప్రభావితం చేస్తున్నాయా?', 'impact', 'Impact', 'ప్రభావం', NULL, NULL, NULL, false, false, false, NULL, NULL, 29),
  ((SELECT id FROM screening_tool_configs WHERE tool_type = 'sdqBehavioral'), 'sdq_i5', 'Do the difficulties interfere with classroom learning?', 'ఈ కష్టాలు తరగతి గది అభ్యాసాన్ని ప్రభావితం చేస్తున్నాయా?', 'impact', 'Impact', 'ప్రభావం', NULL, NULL, NULL, false, false, false, NULL, NULL, 30),
  ((SELECT id FROM screening_tool_configs WHERE tool_type = 'sdqBehavioral'), 'sdq_i6', 'Do the difficulties interfere with leisure activities?', 'ఈ కష్టాలు వినోద కార్యకలాపాలను ప్రభావితం చేస్తున్నాయా?', 'impact', 'Impact', 'ప్రభావం', NULL, NULL, NULL, false, false, false, NULL, NULL, 31),
  ((SELECT id FROM screening_tool_configs WHERE tool_type = 'sdqBehavioral'), 'sdq_i7', 'Do the difficulties put a burden on you or the family?', 'ఈ కష్టాలు మీపై లేదా కుటుంబంపై భారం మోపుతున్నాయా?', 'impact', 'Impact', 'ప్రభావం', NULL, NULL, NULL, false, false, false, NULL, NULL, 32),
  ((SELECT id FROM screening_tool_configs WHERE tool_type = 'sdqBehavioral'), 'sdq_i8', 'Have the difficulties been going on for more than a month?', 'ఈ కష్టాలు ఒక నెల కంటే ఎక్కువ కాలంగా ఉన్నాయా?', 'impact', 'Impact', 'ప్రభావం', NULL, NULL, NULL, false, false, false, NULL, NULL, 33)
ON CONFLICT (tool_config_id, code) DO NOTHING;

-- ============================================================
-- 3L. PARENT-CHILD INTERACTION (24 items)
-- ============================================================

INSERT INTO screening_questions (tool_config_id, code, text_en, text_te, domain, domain_name_en, domain_name_te, category, category_te, age_months, is_critical, is_red_flag, is_reverse_scored, unit, override_format, sort_order)
VALUES
  ((SELECT id FROM screening_tool_configs WHERE tool_type = 'parentChildInteraction'), 'pci_r1', 'Does caregiver respond to child''s vocalizations promptly?', 'పోషకుడు బిడ్డ ధ్వనులకు వెంటనే స్పందిస్తారా?', 'responsiveness', 'Responsiveness', 'స్పందన', NULL, NULL, NULL, false, false, false, NULL, NULL, 1),
  ((SELECT id FROM screening_tool_configs WHERE tool_type = 'parentChildInteraction'), 'pci_r2', 'Does caregiver acknowledge child''s emotions?', 'పోషకుడు బిడ్డ భావోద్వేగాలను గుర్తిస్తారా?', 'responsiveness', 'Responsiveness', 'స్పందన', NULL, NULL, NULL, false, false, false, NULL, NULL, 2),
  ((SELECT id FROM screening_tool_configs WHERE tool_type = 'parentChildInteraction'), 'pci_r3', 'Does caregiver comfort child when distressed?', 'బిడ్డ బాధలో ఉన్నప్పుడు పోషకుడు ఓదార్చుతారా?', 'responsiveness', 'Responsiveness', 'స్పందన', NULL, NULL, NULL, false, false, false, NULL, NULL, 3),
  ((SELECT id FROM screening_tool_configs WHERE tool_type = 'parentChildInteraction'), 'pci_r4', 'Does caregiver follow child''s lead in play?', 'ఆటలో బిడ్డ నాయకత్వాన్ని పోషకుడు అనుసరిస్తారా?', 'responsiveness', 'Responsiveness', 'స్పందన', NULL, NULL, NULL, false, false, false, NULL, NULL, 4),
  ((SELECT id FROM screening_tool_configs WHERE tool_type = 'parentChildInteraction'), 'pci_r5', 'Does caregiver respond to child''s needs consistently?', 'పోషకుడు బిడ్డ అవసరాలకు స్థిరంగా స్పందిస్తారా?', 'responsiveness', 'Responsiveness', 'స్పందన', NULL, NULL, NULL, false, false, false, NULL, NULL, 5),
  ((SELECT id FROM screening_tool_configs WHERE tool_type = 'parentChildInteraction'), 'pci_a1', 'Does caregiver show warmth and affection to child?', 'పోషకుడు బిడ్డ పట్ల ప్రేమ మరియు ఆప్యాయత చూపిస్తారా?', 'affection', 'Affection', 'ఆప్యాయత', NULL, NULL, NULL, false, false, false, NULL, NULL, 6),
  ((SELECT id FROM screening_tool_configs WHERE tool_type = 'parentChildInteraction'), 'pci_a2', 'Does caregiver use positive words with child?', 'పోషకుడు బిడ్డతో సానుకూల పదాలు వాడతారా?', 'affection', 'Affection', 'ఆప్యాయత', NULL, NULL, NULL, false, false, false, NULL, NULL, 7),
  ((SELECT id FROM screening_tool_configs WHERE tool_type = 'parentChildInteraction'), 'pci_a3', 'Does caregiver hug or hold child affectionately?', 'పోషకుడు బిడ్డను ప్రేమగా కౌగిలించుకుంటారా?', 'affection', 'Affection', 'ఆప్యాయత', NULL, NULL, NULL, false, false, false, NULL, NULL, 8),
  ((SELECT id FROM screening_tool_configs WHERE tool_type = 'parentChildInteraction'), 'pci_a4', 'Does caregiver smile at child frequently?', 'పోషకుడు బిడ్డ వైపు తరచుగా నవ్వుతారా?', 'affection', 'Affection', 'ఆప్యాయత', NULL, NULL, NULL, false, false, false, NULL, NULL, 9),
  ((SELECT id FROM screening_tool_configs WHERE tool_type = 'parentChildInteraction'), 'pci_a5', 'Does caregiver praise child''s efforts?', 'పోషకుడు బిడ్డ ప్రయత్నాలను మెచ్చుకుంటారా?', 'affection', 'Affection', 'ఆప్యాయత', NULL, NULL, NULL, false, false, false, NULL, NULL, 10),
  ((SELECT id FROM screening_tool_configs WHERE tool_type = 'parentChildInteraction'), 'pci_ee1', 'Does caregiver encourage exploration and play?', 'పోషకుడు అన్వేషణ మరియు ఆటను ప్రోత్సహిస్తారా?', 'encouragement', 'Encouragement', 'ప్రోత్సాహం', NULL, NULL, NULL, false, false, false, NULL, NULL, 11),
  ((SELECT id FROM screening_tool_configs WHERE tool_type = 'parentChildInteraction'), 'pci_ee2', 'Does caregiver provide safe space for exploration?', 'పోషకుడు అన్వేషణ కోసం సురక్షిత స్థలం అందిస్తారా?', 'encouragement', 'Encouragement', 'ప్రోత్సాహం', NULL, NULL, NULL, false, false, false, NULL, NULL, 12),
  ((SELECT id FROM screening_tool_configs WHERE tool_type = 'parentChildInteraction'), 'pci_ee3', 'Does caregiver allow child to try things independently?', 'పోషకుడు బిడ్డను స్వతంత్రంగా ప్రయత్నించనిస్తారా?', 'encouragement', 'Encouragement', 'ప్రోత్సాహం', NULL, NULL, NULL, false, false, false, NULL, NULL, 13),
  ((SELECT id FROM screening_tool_configs WHERE tool_type = 'parentChildInteraction'), 'pci_ee4', 'Does caregiver support child when frustrated?', 'బిడ్డ నిరాశగా ఉన్నప్పుడు పోషకుడు మద్దతు ఇస్తారా?', 'encouragement', 'Encouragement', 'ప్రోత్సాహం', NULL, NULL, NULL, false, false, false, NULL, NULL, 14),
  ((SELECT id FROM screening_tool_configs WHERE tool_type = 'parentChildInteraction'), 'pci_ee5', 'Does caregiver celebrate child''s achievements?', 'పోషకుడు బిడ్డ విజయాలను ఆనందిస్తారా?', 'encouragement', 'Encouragement', 'ప్రోత్సాహం', NULL, NULL, NULL, false, false, false, NULL, NULL, 15),
  ((SELECT id FROM screening_tool_configs WHERE tool_type = 'parentChildInteraction'), 'pci_t1', 'Does caregiver read to child or tell stories?', 'పోషకుడు బిడ్డకు పుస్తకం చదువుతారా లేదా కథలు చెప్తారా?', 'teaching', 'Teaching', 'బోధన', NULL, NULL, NULL, false, false, false, NULL, NULL, 16),
  ((SELECT id FROM screening_tool_configs WHERE tool_type = 'parentChildInteraction'), 'pci_t2', 'Does caregiver name objects and describe things?', 'పోషకుడు వస్తువుల పేర్లు చెప్పి వివరిస్తారా?', 'teaching', 'Teaching', 'బోధన', NULL, NULL, NULL, false, false, false, NULL, NULL, 17),
  ((SELECT id FROM screening_tool_configs WHERE tool_type = 'parentChildInteraction'), 'pci_t3', 'Does caregiver sing songs or rhymes with child?', 'పోషకుడు బిడ్డతో పాటలు లేదా పద్యాలు పాడతారా?', 'teaching', 'Teaching', 'బోధన', NULL, NULL, NULL, false, false, false, NULL, NULL, 18),
  ((SELECT id FROM screening_tool_configs WHERE tool_type = 'parentChildInteraction'), 'pci_t4', 'Does caregiver talk about daily activities with child?', 'పోషకుడు రోజువారీ కార్యకలాపాల గురించి బిడ్డతో మాట్లాడతారా?', 'teaching', 'Teaching', 'బోధన', NULL, NULL, NULL, false, false, false, NULL, NULL, 19),
  ((SELECT id FROM screening_tool_configs WHERE tool_type = 'parentChildInteraction'), 'pci_t5', 'Does caregiver count or teach colors/shapes?', 'పోషకుడు లెక్కించడం లేదా రంగులు/ఆకారాలు నేర్పిస్తారా?', 'teaching', 'Teaching', 'బోధన', NULL, NULL, NULL, false, false, false, NULL, NULL, 20),
  ((SELECT id FROM screening_tool_configs WHERE tool_type = 'parentChildInteraction'), 'pci_s1', 'Does caregiver maintain daily routines (meals, sleep)?', 'పోషకుడు రోజువారీ దినచర్యలను (భోజనం, నిద్ర) నిర్వహిస్తారా?', 'structure', 'Structure', 'నిర్మాణం', NULL, NULL, NULL, false, false, false, NULL, NULL, 21),
  ((SELECT id FROM screening_tool_configs WHERE tool_type = 'parentChildInteraction'), 'pci_s2', 'Does caregiver set appropriate limits?', 'పోషకుడు తగిన పరిమితులు ఏర్పాటు చేస్తారా?', 'structure', 'Structure', 'నిర్మాణం', NULL, NULL, NULL, false, false, false, NULL, NULL, 22),
  ((SELECT id FROM screening_tool_configs WHERE tool_type = 'parentChildInteraction'), 'pci_s3', 'Does caregiver spend dedicated time daily with child?', 'పోషకుడు రోజువారీ బిడ్డతో ప్రత్యేక సమయం గడుపుతారా?', 'structure', 'Structure', 'నిర్మాణం', NULL, NULL, NULL, false, false, false, NULL, NULL, 23),
  ((SELECT id FROM screening_tool_configs WHERE tool_type = 'parentChildInteraction'), 'pci_s4', 'Does caregiver engage in play with child?', 'పోషకుడు బిడ్డతో ఆడుకుంటారా?', 'structure', 'Structure', 'నిర్మాణం', NULL, NULL, NULL, false, false, false, NULL, NULL, 24)
ON CONFLICT (tool_config_id, code) DO NOTHING;

-- ============================================================
-- 3M. PHQ-9 PARENT MENTAL HEALTH (10 items)
-- ============================================================

INSERT INTO screening_questions (tool_config_id, code, text_en, text_te, domain, domain_name_en, domain_name_te, category, category_te, age_months, is_critical, is_red_flag, is_reverse_scored, unit, override_format, sort_order)
VALUES
  ((SELECT id FROM screening_tool_configs WHERE tool_type = 'parentMentalHealth'), 'phq_1', 'Little interest or pleasure in doing things', 'పనులు చేయడంలో తక్కువ ఆసక్తి లేదా ఆనందం', 'depression', 'Depression', 'నిరాశ', 'Over the last 2 weeks', 'గత 2 వారాలలో', NULL, false, false, false, NULL, NULL, 1),
  ((SELECT id FROM screening_tool_configs WHERE tool_type = 'parentMentalHealth'), 'phq_2', 'Feeling down, depressed, or hopeless', 'నిరాశగా, డిప్రెషన్‌గా లేదా నిరాశగా అనిపించడం', 'depression', 'Depression', 'నిరాశ', 'Over the last 2 weeks', 'గత 2 వారాలలో', NULL, false, false, false, NULL, NULL, 2),
  ((SELECT id FROM screening_tool_configs WHERE tool_type = 'parentMentalHealth'), 'phq_3', 'Trouble falling or staying asleep, or sleeping too much', 'నిద్ర పట్టకపోవడం లేదా ఎక్కువగా నిద్రపోవడం', 'depression', 'Depression', 'నిరాశ', 'Over the last 2 weeks', 'గత 2 వారాలలో', NULL, false, false, false, NULL, NULL, 3),
  ((SELECT id FROM screening_tool_configs WHERE tool_type = 'parentMentalHealth'), 'phq_4', 'Feeling tired or having little energy', 'అలసటగా అనిపించడం లేదా తక్కువ శక్తి', 'depression', 'Depression', 'నిరాశ', 'Over the last 2 weeks', 'గత 2 వారాలలో', NULL, false, false, false, NULL, NULL, 4),
  ((SELECT id FROM screening_tool_configs WHERE tool_type = 'parentMentalHealth'), 'phq_5', 'Poor appetite or overeating', 'తక్కువ ఆకలి లేదా ఎక్కువగా తినడం', 'depression', 'Depression', 'నిరాశ', 'Over the last 2 weeks', 'గత 2 వారాలలో', NULL, false, false, false, NULL, NULL, 5),
  ((SELECT id FROM screening_tool_configs WHERE tool_type = 'parentMentalHealth'), 'phq_6', 'Feeling bad about yourself — or that you are a failure', 'మీ గురించి చెడుగా అనిపించడం — లేదా మీరు విఫలమయ్యారని', 'depression', 'Depression', 'నిరాశ', 'Over the last 2 weeks', 'గత 2 వారాలలో', NULL, false, false, false, NULL, NULL, 6),
  ((SELECT id FROM screening_tool_configs WHERE tool_type = 'parentMentalHealth'), 'phq_7', 'Trouble concentrating on things, such as reading or watching television', 'పుస్తకం చదవడం లేదా టీవీ చూడడం వంటి పనులపై ఏకాగ్రత కుదరకపోవడం', 'depression', 'Depression', 'నిరాశ', 'Over the last 2 weeks', 'గత 2 వారాలలో', NULL, false, false, false, NULL, NULL, 7),
  ((SELECT id FROM screening_tool_configs WHERE tool_type = 'parentMentalHealth'), 'phq_8', 'Moving or speaking so slowly that other people noticed — or being fidgety or restless', 'ఇతరులు గమనించేంత నెమ్మదిగా కదలడం/మాట్లాడటం — లేదా అశాంతిగా ఉండటం', 'depression', 'Depression', 'నిరాశ', 'Over the last 2 weeks', 'గత 2 వారాలలో', NULL, false, false, false, NULL, NULL, 8),
  ((SELECT id FROM screening_tool_configs WHERE tool_type = 'parentMentalHealth'), 'phq_9', 'Thoughts that you would be better off dead, or of hurting yourself', 'మీరు చనిపోతే మంచిదని లేదా మిమ్మల్ని మీరు హాని చేసుకోవాలని ఆలోచనలు', 'depression', 'Depression', 'నిరాశ', 'Over the last 2 weeks', 'గత 2 వారాలలో', NULL, false, true, false, NULL, NULL, 9),
  ((SELECT id FROM screening_tool_configs WHERE tool_type = 'parentMentalHealth'), 'phq_10', 'If you checked off any problems, how difficult have these problems made it for you to do your work, take care of things at home, or get along with other people?', 'మీరు ఏవైనా సమస్యలను గుర్తించినట్లయితే, ఈ సమస్యలు మీ పనులు చేయడం, ఇంటి విషయాలు చూసుకోవడం లేదా ఇతరులతో కలిసి ఉండటం ఎంత కష్టమైంది?', 'depression', 'Depression', 'నిరాశ', 'Functional Impact', 'కార్యాచరణ ప్రభావం', NULL, false, false, false, NULL, NULL, 10)
ON CONFLICT (tool_config_id, code) DO NOTHING;

-- ============================================================
-- 3N. HOME STIMULATION (22 items)
-- ============================================================

INSERT INTO screening_questions (tool_config_id, code, text_en, text_te, domain, domain_name_en, domain_name_te, category, category_te, age_months, is_critical, is_red_flag, is_reverse_scored, unit, override_format, sort_order)
VALUES
  ((SELECT id FROM screening_tool_configs WHERE tool_type = 'homeStimulation'), 'hs_lm1', 'Are there age-appropriate toys available?', 'వయసుకు తగిన బొమ్మలు అందుబాటులో ఉన్నాయా?', 'learning_materials', 'Learning Materials', 'అభ్యాస సామాగ్రి', NULL, NULL, NULL, false, false, false, NULL, NULL, 1),
  ((SELECT id FROM screening_tool_configs WHERE tool_type = 'homeStimulation'), 'hs_lm2', 'Are there picture books or story books?', 'చిత్ర పుస్తకాలు లేదా కథ పుస్తకాలు ఉన్నాయా?', 'learning_materials', 'Learning Materials', 'అభ్యాస సామాగ్రి', NULL, NULL, NULL, false, false, false, NULL, NULL, 2),
  ((SELECT id FROM screening_tool_configs WHERE tool_type = 'homeStimulation'), 'hs_lm3', 'Are there drawing/coloring materials?', 'గీతలు/రంగుల సామాగ్రి ఉన్నాయా?', 'learning_materials', 'Learning Materials', 'అభ్యాస సామాగ్రి', NULL, NULL, NULL, false, false, false, NULL, NULL, 3),
  ((SELECT id FROM screening_tool_configs WHERE tool_type = 'homeStimulation'), 'hs_lm4', 'Is there variety in toys and play materials?', 'బొమ్మలు మరియు ఆట సామాగ్రిలో వైవిధ్యం ఉందా?', 'learning_materials', 'Learning Materials', 'అభ్యాస సామాగ్రి', NULL, NULL, NULL, false, false, false, NULL, NULL, 4),
  ((SELECT id FROM screening_tool_configs WHERE tool_type = 'homeStimulation'), 'hs_lm5', 'Are there toys that encourage creativity (blocks, puzzles)?', 'సృజనాత్మకతను ప్రోత్సహించే బొమ్మలు (బ్లాక్‌లు, పజిల్స్) ఉన్నాయా?', 'learning_materials', 'Learning Materials', 'అభ్యాస సామాగ్రి', NULL, NULL, NULL, false, false, false, NULL, NULL, 5),
  ((SELECT id FROM screening_tool_configs WHERE tool_type = 'homeStimulation'), 'hs_lm6', 'Are there musical toys or instruments?', 'సంగీత బొమ్మలు లేదా వాయిద్యాలు ఉన్నాయా?', 'learning_materials', 'Learning Materials', 'అభ్యాస సామాగ్రి', NULL, NULL, NULL, false, false, false, NULL, NULL, 6),
  ((SELECT id FROM screening_tool_configs WHERE tool_type = 'homeStimulation'), 'hs_pe1', 'Does child have safe space to play?', 'బిడ్డకు సురక్షితంగా ఆడుకునే స్థలం ఉందా?', 'physical_environment', 'Physical Environment', 'భౌతిక పరిసరాలు', NULL, NULL, NULL, false, false, false, NULL, NULL, 7),
  ((SELECT id FROM screening_tool_configs WHERE tool_type = 'homeStimulation'), 'hs_pe2', 'Is there outdoor space for play?', 'ఆడుకోవడానికి బయటి స్థలం ఉందా?', 'physical_environment', 'Physical Environment', 'భౌతిక పరిసరాలు', NULL, NULL, NULL, false, false, false, NULL, NULL, 8),
  ((SELECT id FROM screening_tool_configs WHERE tool_type = 'homeStimulation'), 'hs_pe3', 'Is the home well-lit and ventilated?', 'ఇల్లు బాగా వెలుతురు మరియు గాలి ఉందా?', 'physical_environment', 'Physical Environment', 'భౌతిక పరిసరాలు', NULL, NULL, NULL, false, false, false, NULL, NULL, 9),
  ((SELECT id FROM screening_tool_configs WHERE tool_type = 'homeStimulation'), 'hs_pe4', 'Is there access to safe drinking water?', 'శుద్ధమైన తాగునీటి సౌకర్యం ఉందా?', 'physical_environment', 'Physical Environment', 'భౌతిక పరిసరాలు', NULL, NULL, NULL, false, false, false, NULL, NULL, 10),
  ((SELECT id FROM screening_tool_configs WHERE tool_type = 'homeStimulation'), 'hs_pe5', 'Is there toilet/sanitation facility?', 'మరుగుదొడ్డి/పారిశుద్ధ్య సౌకర్యం ఉందా?', 'physical_environment', 'Physical Environment', 'భౌతిక పరిసరాలు', NULL, NULL, NULL, false, false, false, NULL, NULL, 11),
  ((SELECT id FROM screening_tool_configs WHERE tool_type = 'homeStimulation'), 'hs_pe6', 'Is the home environment clean and hygienic?', 'ఇంటి పరిసరాలు శుభ్రంగా మరియు శుచిగా ఉన్నాయా?', 'physical_environment', 'Physical Environment', 'భౌతిక పరిసరాలు', NULL, NULL, NULL, false, false, false, NULL, NULL, 12),
  ((SELECT id FROM screening_tool_configs WHERE tool_type = 'homeStimulation'), 'hs_ai1', 'Does family eat meals together?', 'కుటుంబం కలిసి భోజనం చేస్తారా?', 'activities', 'Activities', 'కార్యకలాపాలు', NULL, NULL, NULL, false, false, false, NULL, NULL, 13),
  ((SELECT id FROM screening_tool_configs WHERE tool_type = 'homeStimulation'), 'hs_ai2', 'Is child taken outside home regularly?', 'బిడ్డను క్రమం తప్పకుండా ఇంటి బయటకు తీసుకెళ్తారా?', 'activities', 'Activities', 'కార్యకలాపాలు', NULL, NULL, NULL, false, false, false, NULL, NULL, 14),
  ((SELECT id FROM screening_tool_configs WHERE tool_type = 'homeStimulation'), 'hs_ai3', 'Does child interact with other children regularly?', 'బిడ్డ ఇతర పిల్లలతో క్రమం తప్పకుండా సంభాషిస్తారా?', 'activities', 'Activities', 'కార్యకలాపాలు', NULL, NULL, NULL, false, false, false, NULL, NULL, 15),
  ((SELECT id FROM screening_tool_configs WHERE tool_type = 'homeStimulation'), 'hs_ai4', 'Is child exposed to multiple languages?', 'బిడ్డకు అనేక భాషల పరిచయం ఉందా?', 'activities', 'Activities', 'కార్యకలాపాలు', NULL, NULL, NULL, false, false, false, NULL, NULL, 16),
  ((SELECT id FROM screening_tool_configs WHERE tool_type = 'homeStimulation'), 'hs_ai5', 'Does caregiver tell stories or sing songs daily?', 'పోషకుడు రోజూ కథలు చెప్తారా లేదా పాటలు పాడతారా?', 'activities', 'Activities', 'కార్యకలాపాలు', NULL, NULL, NULL, false, false, false, NULL, NULL, 17),
  ((SELECT id FROM screening_tool_configs WHERE tool_type = 'homeStimulation'), 'hs_ai6', 'Is child included in simple household activities?', 'బిడ్డను సాధారణ ఇంటి పనులలో చేర్చుతారా?', 'activities', 'Activities', 'కార్యకలాపాలు', NULL, NULL, NULL, false, false, false, NULL, NULL, 18),
  ((SELECT id FROM screening_tool_configs WHERE tool_type = 'homeStimulation'), 'hs_sf1', 'Are dangerous substances stored out of child''s reach?', 'ప్రమాదకరమైన పదార్థాలు బిడ్డకు అందనంత దూరంలో ఉంచారా?', 'safety', 'Safety', 'భద్రత', NULL, NULL, NULL, false, false, false, NULL, NULL, 19),
  ((SELECT id FROM screening_tool_configs WHERE tool_type = 'homeStimulation'), 'hs_sf2', 'Is child supervised during play?', 'ఆటలో బిడ్డపై నిఘా ఉందా?', 'safety', 'Safety', 'భద్రత', NULL, NULL, NULL, false, false, false, NULL, NULL, 20),
  ((SELECT id FROM screening_tool_configs WHERE tool_type = 'homeStimulation'), 'hs_sf3', 'Are electrical outlets and sharp objects secured?', 'విద్యుత్ ఔట్‌లెట్‌లు మరియు పదునైన వస్తువులు భద్రపరచారా?', 'safety', 'Safety', 'భద్రత', NULL, NULL, NULL, false, false, false, NULL, NULL, 21),
  ((SELECT id FROM screening_tool_configs WHERE tool_type = 'homeStimulation'), 'hs_sf4', 'Is child protected from extreme weather?', 'తీవ్ర వాతావరణం నుండి బిడ్డను రక్షిస్తారా?', 'safety', 'Safety', 'భద్రత', NULL, NULL, NULL, false, false, false, NULL, NULL, 22)
ON CONFLICT (tool_config_id, code) DO NOTHING;

-- ============================================================
-- 3O. NUTRITION ASSESSMENT (15 items)
-- ============================================================

INSERT INTO screening_questions (tool_config_id, code, text_en, text_te, domain, domain_name_en, domain_name_te, category, category_te, age_months, is_critical, is_red_flag, is_reverse_scored, unit, override_format, sort_order)
VALUES
  ((SELECT id FROM screening_tool_configs WHERE tool_type = 'nutritionAssessment'), 'nut_height', 'Height', 'ఎత్తు', 'measurements', 'Measurements', 'కొలతలు', NULL, NULL, NULL, false, false, false, 'cm', 'numericInput', 1),
  ((SELECT id FROM screening_tool_configs WHERE tool_type = 'nutritionAssessment'), 'nut_weight', 'Weight', 'బరువు', 'measurements', 'Measurements', 'కొలతలు', NULL, NULL, NULL, false, false, false, 'kg', 'numericInput', 2),
  ((SELECT id FROM screening_tool_configs WHERE tool_type = 'nutritionAssessment'), 'nut_head_circ', 'Head Circumference (optional)', 'తల చుట్టు కొలత (ఐచ్ఛికం)', 'measurements', 'Measurements', 'కొలతలు', NULL, NULL, NULL, false, false, false, 'cm', 'numericInput', 3),
  ((SELECT id FROM screening_tool_configs WHERE tool_type = 'nutritionAssessment'), 'nut_muac', 'Mid-Upper Arm Circumference (optional)', 'మధ్య-ఎగువ చేతి చుట్టు కొలత (ఐచ్ఛికం)', 'measurements', 'Measurements', 'కొలతలు', NULL, NULL, NULL, false, false, false, 'cm', 'numericInput', 4),
  ((SELECT id FROM screening_tool_configs WHERE tool_type = 'nutritionAssessment'), 'nut_d1', 'Is child currently being breastfed? (if under 24 months)', 'బిడ్డకు ప్రస్తుతం తల్లి పాలు ఇస్తున్నారా? (24 నెలల కంటే తక్కువ అయితే)', 'dietary', 'Dietary', 'ఆహారం', NULL, NULL, NULL, false, false, false, NULL, 'yesNo', 5),
  ((SELECT id FROM screening_tool_configs WHERE tool_type = 'nutritionAssessment'), 'nut_d2', 'Does child eat at least 3 meals a day?', 'బిడ్డ రోజుకు కనీసం 3 భోజనాలు తింటారా?', 'dietary', 'Dietary', 'ఆహారం', NULL, NULL, NULL, false, false, false, NULL, 'yesNo', 6),
  ((SELECT id FROM screening_tool_configs WHERE tool_type = 'nutritionAssessment'), 'nut_d3', 'Does child eat fruits and vegetables regularly?', 'బిడ్డ క్రమం తప్పకుండా పండ్లు మరియు కూరగాయలు తింటారా?', 'dietary', 'Dietary', 'ఆహారం', NULL, NULL, NULL, false, false, false, NULL, 'yesNo', 7),
  ((SELECT id FROM screening_tool_configs WHERE tool_type = 'nutritionAssessment'), 'nut_d4', 'Does child consume milk or dairy products daily?', 'బిడ్డ రోజూ పాలు లేదా పాల ఉత్పత్తులు తీసుకుంటారా?', 'dietary', 'Dietary', 'ఆహారం', NULL, NULL, NULL, false, false, false, NULL, 'yesNo', 8),
  ((SELECT id FROM screening_tool_configs WHERE tool_type = 'nutritionAssessment'), 'nut_d5', 'Does child eat protein sources (dal, eggs, meat, fish)?', 'బిడ్డ ప్రోటీన్ వనరులు (పప్పు, గుడ్లు, మాంసం, చేపలు) తింటారా?', 'dietary', 'Dietary', 'ఆహారం', NULL, NULL, NULL, false, false, false, NULL, 'yesNo', 9),
  ((SELECT id FROM screening_tool_configs WHERE tool_type = 'nutritionAssessment'), 'nut_d6', 'Does child take iron/vitamin supplements if prescribed?', 'సూచించినట్లయితే బిడ్డ ఇనుము/విటమిన్ సప్లిమెంట్లు తీసుకుంటారా?', 'dietary', 'Dietary', 'ఆహారం', NULL, NULL, NULL, false, false, false, NULL, 'yesNo', 10),
  ((SELECT id FROM screening_tool_configs WHERE tool_type = 'nutritionAssessment'), 'nut_s1', 'Does child appear visibly thin or wasted?', 'బిడ్డ కనిపించేంత సన్నగా లేదా క్షీణించినట్లు కనిపిస్తారా?', 'signs', 'Clinical Signs', 'వైద్య సంకేతాలు', NULL, NULL, NULL, false, false, false, NULL, 'yesNo', 11),
  ((SELECT id FROM screening_tool_configs WHERE tool_type = 'nutritionAssessment'), 'nut_s2', 'Does child have pale skin, nails, or conjunctiva (signs of anemia)?', 'బిడ్డకు పాలిపోయిన చర్మం, గోళ్ళు లేదా కనుకొలకు ఉన్నాయా (రక్తహీనత సంకేతాలు)?', 'signs', 'Clinical Signs', 'వైద్య సంకేతాలు', NULL, NULL, NULL, false, false, false, NULL, 'yesNo', 12),
  ((SELECT id FROM screening_tool_configs WHERE tool_type = 'nutritionAssessment'), 'nut_s3', 'Does child have swelling (edema) in feet or face?', 'బిడ్డ పాదాలు లేదా ముఖంలో వాపు (ఎడెమా) ఉందా?', 'signs', 'Clinical Signs', 'వైద్య సంకేతాలు', NULL, NULL, NULL, false, true, false, NULL, 'yesNo', 13),
  ((SELECT id FROM screening_tool_configs WHERE tool_type = 'nutritionAssessment'), 'nut_s4', 'Has child had frequent illnesses in last 3 months?', 'గత 3 నెలల్లో బిడ్డకు తరచుగా అనారోగ్యాలు వచ్చాయా?', 'signs', 'Clinical Signs', 'వైద్య సంకేతాలు', NULL, NULL, NULL, false, false, false, NULL, 'yesNo', 14),
  ((SELECT id FROM screening_tool_configs WHERE tool_type = 'nutritionAssessment'), 'nut_s5', 'Has child lost weight or failed to gain weight recently?', 'బిడ్డ ఇటీవల బరువు తగ్గారా లేదా బరువు పెరగలేదా?', 'signs', 'Clinical Signs', 'వైద్య సంకేతాలు', NULL, NULL, NULL, false, false, false, NULL, 'yesNo', 15)
ON CONFLICT (tool_config_id, code) DO NOTHING;

-- ============================================================
-- 3P. RBSK BIRTH DEFECTS SCREENING (17 items)
-- ============================================================

INSERT INTO screening_questions (tool_config_id, code, text_en, text_te, domain, domain_name_en, domain_name_te, category, category_te, age_months, is_critical, is_red_flag, is_reverse_scored, unit, override_format, sort_order)
VALUES
  ((SELECT id FROM screening_tool_configs WHERE tool_type = 'rbskBirthDefects'), 'bd_n1', 'Does the child have any visible spinal abnormality (e.g., swelling, dimple, or tuft of hair on lower back)?', 'పిల్లలకి వెన్నెముక అసాధారణత కనిపిస్తుందా (ఉదా., వాపు, గుంట, లేదా నడుము భాగంలో వెంట్రుకల గుత్తి)?', 'neural', 'Neural Tube', 'నరాల నాళం', NULL, NULL, NULL, false, true, false, NULL, NULL, 1),
  ((SELECT id FROM screening_tool_configs WHERE tool_type = 'rbskBirthDefects'), 'bd_n2', 'Does the child have an unusually large or small head for age?', 'పిల్లల తల వయసుకు అసాధారణంగా పెద్దదిగా లేదా చిన్నదిగా ఉందా?', 'neural', 'Neural Tube', 'నరాల నాళం', NULL, NULL, NULL, false, true, false, NULL, NULL, 2),
  ((SELECT id FROM screening_tool_configs WHERE tool_type = 'rbskBirthDefects'), 'bd_m1', 'Does the child have club foot (feet turned inward)?', 'పిల్లలకి క్లబ్ ఫుట్ ఉందా (పాదాలు లోపలికి తిరిగి ఉన్నాయా)?', 'musculoskeletal', 'Musculoskeletal', 'కండరాల-ఎముకల', NULL, NULL, NULL, false, false, false, NULL, NULL, 3),
  ((SELECT id FROM screening_tool_configs WHERE tool_type = 'rbskBirthDefects'), 'bd_m2', 'Does the child have any limb abnormality (missing, extra, or shortened fingers/toes/limbs)?', 'పిల్లలకి అవయవ అసాధారణత ఉందా (వేళ్ళు/కాళ్ళు తక్కువ, ఎక్కువ లేదా చిన్నవి)?', 'musculoskeletal', 'Musculoskeletal', 'కండరాల-ఎముకల', NULL, NULL, NULL, false, false, false, NULL, NULL, 4),
  ((SELECT id FROM screening_tool_configs WHERE tool_type = 'rbskBirthDefects'), 'bd_m3', 'Does the child have congenital hip dislocation (unequal leg lengths or difficulty moving legs)?', 'పిల్లలకి పుట్టుకతో తుంటి చీలిక ఉందా (కాళ్ళ పొడవు సమానంగా లేకపోవడం లేదా కాళ్ళు కదపడంలో ఇబ్బంది)?', 'musculoskeletal', 'Musculoskeletal', 'కండరాల-ఎముకల', NULL, NULL, NULL, false, false, false, NULL, NULL, 5),
  ((SELECT id FROM screening_tool_configs WHERE tool_type = 'rbskBirthDefects'), 'bd_c1', 'Does the child have cleft lip (split in upper lip)?', 'పిల్లలకి చీలిన పెదవి ఉందా (పై పెదవిలో చీలిక)?', 'craniofacial', 'Craniofacial', 'ముఖ-కపాల', NULL, NULL, NULL, false, true, false, NULL, NULL, 6),
  ((SELECT id FROM screening_tool_configs WHERE tool_type = 'rbskBirthDefects'), 'bd_c2', 'Does the child have cleft palate (opening in roof of mouth)?', 'పిల్లలకి చీలిన అంగిలి ఉందా (నోటి పై భాగంలో రంధ్రం)?', 'craniofacial', 'Craniofacial', 'ముఖ-కపాల', NULL, NULL, NULL, false, true, false, NULL, NULL, 7),
  ((SELECT id FROM screening_tool_configs WHERE tool_type = 'rbskBirthDefects'), 'bd_c3', 'Does the child have features suggestive of Down syndrome (flat face, upslanting eyes, single palmar crease)?', 'పిల్లలకి డౌన్ సిండ్రోమ్ లక్షణాలు ఉన్నాయా (చదునైన ముఖం, పైకి వాలిన కళ్ళు, అరచేతిలో ఒకే గీత)?', 'craniofacial', 'Craniofacial', 'ముఖ-కపాల', NULL, NULL, NULL, false, true, false, NULL, NULL, 8),
  ((SELECT id FROM screening_tool_configs WHERE tool_type = 'rbskBirthDefects'), 'bd_h1', 'Does the child have bluish discoloration of lips, nails, or skin (cyanosis)?', 'పిల్లల పెదవులు, గోళ్ళు లేదా చర్మం నీలం రంగులోకి మారుతుందా (సయనోసిస్)?', 'cardiac', 'Cardiac', 'గుండె', NULL, NULL, NULL, false, true, false, NULL, NULL, 9),
  ((SELECT id FROM screening_tool_configs WHERE tool_type = 'rbskBirthDefects'), 'bd_h2', 'Does the child have difficulty breathing or get tired easily during feeding/activity?', 'పిల్లలకి శ్వాస తీసుకోవడంలో ఇబ్బంది ఉందా లేదా ఆహారం/కార్యకలాపాల సమయంలో త్వరగా అలసిపోతారా?', 'cardiac', 'Cardiac', 'గుండె', NULL, NULL, NULL, false, false, false, NULL, NULL, 10),
  ((SELECT id FROM screening_tool_configs WHERE tool_type = 'rbskBirthDefects'), 'bd_h3', 'Has the child been diagnosed with or suspected of having a heart murmur?', 'పిల్లలకి గుండె గొణుగుడు ఉన్నట్లు నిర్ధారించబడిందా లేదా అనుమానించబడిందా?', 'cardiac', 'Cardiac', 'గుండె', NULL, NULL, NULL, false, false, false, NULL, NULL, 11),
  ((SELECT id FROM screening_tool_configs WHERE tool_type = 'rbskBirthDefects'), 'bd_s1', 'Does the child have congenital cataract (white reflex in the pupil)?', 'పిల్లలకి పుట్టుకతో కంటి శుక్లం ఉందా (నల్లగుడ్డులో తెల్లని ప్రతిబింబం)?', 'sensory', 'Sensory', 'ఇంద్రియ', NULL, NULL, NULL, false, true, false, NULL, NULL, 12),
  ((SELECT id FROM screening_tool_configs WHERE tool_type = 'rbskBirthDefects'), 'bd_s2', 'Does the child not respond to sounds or startle to loud noises?', 'పిల్లలు శబ్దాలకు స్పందించరా లేదా పెద్ద శబ్దాలకు ఉలిక్కిపడరా?', 'sensory', 'Sensory', 'ఇంద్రియ', NULL, NULL, NULL, false, true, false, NULL, NULL, 13),
  ((SELECT id FROM screening_tool_configs WHERE tool_type = 'rbskBirthDefects'), 'bd_s3', 'Does the child have abnormally shaped or positioned ears?', 'పిల్లల చెవులు అసాధారణ ఆకారంలో లేదా స్థానంలో ఉన్నాయా?', 'sensory', 'Sensory', 'ఇంద్రియ', NULL, NULL, NULL, false, false, false, NULL, NULL, 14),
  ((SELECT id FROM screening_tool_configs WHERE tool_type = 'rbskBirthDefects'), 'bd_o1', 'Does the child have an abdominal wall defect (umbilical hernia, omphalocele)?', 'పిల్లలకి ఉదర గోడ లోపం ఉందా (బొడ్డు హెర్నియా)?', 'other', 'Other Congenital', 'ఇతర పుట్టుక', NULL, NULL, NULL, false, false, false, NULL, NULL, 15),
  ((SELECT id FROM screening_tool_configs WHERE tool_type = 'rbskBirthDefects'), 'bd_o2', 'Does the child have undescended testes (for boys)?', 'పిల్లలకి దిగని వృషణాలు ఉన్నాయా (అబ్బాయిలకు)?', 'other', 'Other Congenital', 'ఇతర పుట్టుక', NULL, NULL, NULL, false, false, false, NULL, NULL, 16),
  ((SELECT id FROM screening_tool_configs WHERE tool_type = 'rbskBirthDefects'), 'bd_o3', 'Does the child have any visible birthmarks or skin abnormalities present since birth?', 'పుట్టినప్పటి నుండి పిల్లలకి ఏదైనా కనిపించే పుట్టుమచ్చలు లేదా చర్మ అసాధారణతలు ఉన్నాయా?', 'other', 'Other Congenital', 'ఇతర పుట్టుక', NULL, NULL, NULL, false, false, false, NULL, NULL, 17)
ON CONFLICT (tool_config_id, code) DO NOTHING;

-- ============================================================
-- 3Q. RBSK DISEASE SCREENING (17 items)
-- ============================================================

INSERT INTO screening_questions (tool_config_id, code, text_en, text_te, domain, domain_name_en, domain_name_te, category, category_te, age_months, is_critical, is_red_flag, is_reverse_scored, unit, override_format, sort_order)
VALUES
  ((SELECT id FROM screening_tool_configs WHERE tool_type = 'rbskDiseases'), 'ds_sk1', 'Does the child have persistent skin rashes, eczema, or scabies?', 'పిల్లలకి నిరంతర చర్మ దద్దుర్లు, ఎగ్జిమా లేదా గజ్జి ఉందా?', 'skin', 'Skin', 'చర్మం', NULL, NULL, NULL, false, false, false, NULL, NULL, 1),
  ((SELECT id FROM screening_tool_configs WHERE tool_type = 'rbskDiseases'), 'ds_sk2', 'Does the child have fungal infections (ringworm, white patches)?', 'పిల్లలకి ఫంగల్ ఇన్ఫెక్షన్లు ఉన్నాయా (రింగ్‌వార్మ్, తెల్లని మచ్చలు)?', 'skin', 'Skin', 'చర్మం', NULL, NULL, NULL, false, false, false, NULL, NULL, 2),
  ((SELECT id FROM screening_tool_configs WHERE tool_type = 'rbskDiseases'), 'ds_sk3', 'Does the child have boils, impetigo, or recurrent skin infections?', 'పిల్లలకి పుళ్ళు, ఇంపెటిగో లేదా పునరావృత చర్మ ఇన్ఫెక్షన్లు ఉన్నాయా?', 'skin', 'Skin', 'చర్మం', NULL, NULL, NULL, false, false, false, NULL, NULL, 3),
  ((SELECT id FROM screening_tool_configs WHERE tool_type = 'rbskDiseases'), 'ds_e1', 'Does the child have chronic ear discharge or recurrent ear infections?', 'పిల్లలకి దీర్ఘకాలిక చెవి స్రావం లేదా పునరావృత చెవి ఇన్ఫెక్షన్లు ఉన్నాయా?', 'ent', 'ENT', 'చెవి-ముక్కు-గొంతు', NULL, NULL, NULL, false, true, false, NULL, NULL, 4),
  ((SELECT id FROM screening_tool_configs WHERE tool_type = 'rbskDiseases'), 'ds_e2', 'Does the child have enlarged tonsils or frequent sore throat?', 'పిల్లలకి పెద్దవైన టాన్సిల్స్ లేదా తరచుగా గొంతు నొప్పి ఉందా?', 'ent', 'ENT', 'చెవి-ముక్కు-గొంతు', NULL, NULL, NULL, false, false, false, NULL, NULL, 5),
  ((SELECT id FROM screening_tool_configs WHERE tool_type = 'rbskDiseases'), 'ds_e3', 'Does the child breathe through the mouth or snore excessively?', 'పిల్లలు నోటితో శ్వాస తీసుకుంటారా లేదా అతిగా గురకపెడతారా?', 'ent', 'ENT', 'చెవి-ముక్కు-గొంతు', NULL, NULL, NULL, false, false, false, NULL, NULL, 6),
  ((SELECT id FROM screening_tool_configs WHERE tool_type = 'rbskDiseases'), 'ds_ey1', 'Does the child have squinting (cross-eyes) or abnormal eye alignment?', 'పిల్లలకి మెల్లకన్ను లేదా అసాధారణ కంటి సమలేఖనం ఉందా?', 'eye', 'Eye', 'కన్ను', NULL, NULL, NULL, false, false, false, NULL, NULL, 7),
  ((SELECT id FROM screening_tool_configs WHERE tool_type = 'rbskDiseases'), 'ds_ey2', 'Does the child have difficulty seeing objects or holds things very close to the eyes?', 'పిల్లలకి వస్తువులను చూడటంలో ఇబ్బంది ఉందా లేదా వస్తువులను కళ్ళకు చాలా దగ్గరగా పట్టుకుంటారా?', 'eye', 'Eye', 'కన్ను', NULL, NULL, NULL, false, false, false, NULL, NULL, 8),
  ((SELECT id FROM screening_tool_configs WHERE tool_type = 'rbskDiseases'), 'ds_ey3', 'Does the child have night blindness or Bitot spots (white foamy patches on eyes)?', 'పిల్లలకి రాత్రి అంధత్వం లేదా బిటాట్ మచ్చలు (కళ్ళపై తెల్లని నురుగు మచ్చలు) ఉన్నాయా?', 'eye', 'Eye', 'కన్ను', NULL, NULL, NULL, false, true, false, NULL, NULL, 9),
  ((SELECT id FROM screening_tool_configs WHERE tool_type = 'rbskDiseases'), 'ds_d1', 'Does the child have dental caries (tooth decay) or black/damaged teeth?', 'పిల్లలకి దంత క్షయం (పళ్ళు పాడవడం) లేదా నల్లని/దెబ్బతిన్న పళ్ళు ఉన్నాయా?', 'dental', 'Dental', 'దంతాల', NULL, NULL, NULL, false, false, false, NULL, NULL, 10),
  ((SELECT id FROM screening_tool_configs WHERE tool_type = 'rbskDiseases'), 'ds_d2', 'Does the child have swollen, bleeding, or painful gums?', 'పిల్లలకి వాపు, రక్తస్రావం లేదా నొప్పిగల చిగుళ్ళు ఉన్నాయా?', 'dental', 'Dental', 'దంతాల', NULL, NULL, NULL, false, false, false, NULL, NULL, 11),
  ((SELECT id FROM screening_tool_configs WHERE tool_type = 'rbskDiseases'), 'ds_bl1', 'Does the child look unusually pale (palms, nails, conjunctiva)?', 'పిల్లలు అసాధారణంగా లేతగా కనిపిస్తారా (అరచేతులు, గోళ్ళు, కంటి రెప్ప లోపలి భాగం)?', 'blood', 'Blood Disorders', 'రక్త సమస్యలు', NULL, NULL, NULL, false, true, false, NULL, NULL, 12),
  ((SELECT id FROM screening_tool_configs WHERE tool_type = 'rbskDiseases'), 'ds_bl2', 'Does the child have recurrent jaundice or yellowing of eyes/skin?', 'పిల్లలకి పునరావృత కామెర్లు లేదా కళ్ళు/చర్మం పసుపు రంగులోకి మారడం ఉందా?', 'blood', 'Blood Disorders', 'రక్త సమస్యలు', NULL, NULL, NULL, false, true, false, NULL, NULL, 13),
  ((SELECT id FROM screening_tool_configs WHERE tool_type = 'rbskDiseases'), 'ds_bl3', 'Does the child have a family history of sickle cell disease or thalassemia?', 'పిల్లల కుటుంబంలో సికిల్ సెల్ వ్యాధి లేదా థలసీమియా చరిత్ర ఉందా?', 'blood', 'Blood Disorders', 'రక్త సమస్యలు', NULL, NULL, NULL, false, false, false, NULL, NULL, 14),
  ((SELECT id FROM screening_tool_configs WHERE tool_type = 'rbskDiseases'), 'ds_df1', 'Does the child have signs of Vitamin D deficiency (bowed legs, knock knees, delayed fontanelle closure)?', 'పిల్లలకి విటమిన్ D లోపం లక్షణాలు ఉన్నాయా (వంగిన కాళ్ళు, ముడుచుకున్న మోకాళ్ళు, నెత్తిబొడిపె ఆలస్యంగా మూసుకోవడం)?', 'deficiency', 'Deficiencies', 'లోపాలు', NULL, NULL, NULL, false, false, false, NULL, NULL, 15),
  ((SELECT id FROM screening_tool_configs WHERE tool_type = 'rbskDiseases'), 'ds_df2', 'Does the child have signs of iodine deficiency (goiter/neck swelling)?', 'పిల్లలకి అయోడిన్ లోపం లక్షణాలు ఉన్నాయా (గాయిటర్/మెడ వాపు)?', 'deficiency', 'Deficiencies', 'లోపాలు', NULL, NULL, NULL, false, false, false, NULL, NULL, 16),
  ((SELECT id FROM screening_tool_configs WHERE tool_type = 'rbskDiseases'), 'ds_df3', 'Does the child have signs of severe acute malnutrition (very thin, swelling of feet, skin peeling)?', 'పిల్లలకి తీవ్ర పోషకాహార లోపం లక్షణాలు ఉన్నాయా (చాలా సన్నగా, పాదాల వాపు, చర్మం ఒలవడం)?', 'deficiency', 'Deficiencies', 'లోపాలు', NULL, NULL, NULL, false, true, false, NULL, NULL, 17)
ON CONFLICT (tool_config_id, code) DO NOTHING;

-- ============================================================
-- 4. SCORING RULES
-- ============================================================

-- CDC Milestones
INSERT INTO scoring_rules (tool_config_id, rule_type, domain, parameter_name, parameter_value, description) VALUES
  ((SELECT id FROM screening_tool_configs WHERE tool_type = 'cdcMilestones'), 'threshold', NULL, 'dq_threshold', '85', 'DQ below this indicates delay'),
  ((SELECT id FROM screening_tool_configs WHERE tool_type = 'cdcMilestones'), 'threshold', NULL, 'referral_dq', '70', 'DQ below this triggers referral'),
  ((SELECT id FROM screening_tool_configs WHERE tool_type = 'cdcMilestones'), 'classification', NULL, 'high_max_dq', '70', 'DQ at or below this = HIGH risk'),
  ((SELECT id FROM screening_tool_configs WHERE tool_type = 'cdcMilestones'), 'classification', NULL, 'medium_max_dq', '85', 'DQ at or below this = MEDIUM risk')
ON CONFLICT (tool_config_id, rule_type, (COALESCE(domain, '__overall__')), parameter_name) DO NOTHING;

-- RBSK Tool
INSERT INTO scoring_rules (tool_config_id, rule_type, domain, parameter_name, parameter_value, description) VALUES
  ((SELECT id FROM screening_tool_configs WHERE tool_type = 'rbskTool'), 'threshold', NULL, 'low_extent_referral_count', '3', 'Number of Low Extent items triggering referral'),
  ((SELECT id FROM screening_tool_configs WHERE tool_type = 'rbskTool'), 'threshold', NULL, 'medium_risk_score_pct', '0.6', 'Score percentage below this = medium risk')
ON CONFLICT (tool_config_id, rule_type, (COALESCE(domain, '__overall__')), parameter_name) DO NOTHING;

-- M-CHAT
INSERT INTO scoring_rules (tool_config_id, rule_type, domain, parameter_name, parameter_value, description) VALUES
  ((SELECT id FROM screening_tool_configs WHERE tool_type = 'mchatAutism'), 'cutoff', NULL, 'low_risk_max', '2', 'Max score for low risk'),
  ((SELECT id FROM screening_tool_configs WHERE tool_type = 'mchatAutism'), 'cutoff', NULL, 'medium_risk_max', '7', 'Max score for medium risk'),
  ((SELECT id FROM screening_tool_configs WHERE tool_type = 'mchatAutism'), 'cutoff', NULL, 'high_risk_min', '8', 'Min score for high risk'),
  ((SELECT id FROM screening_tool_configs WHERE tool_type = 'mchatAutism'), 'cutoff', NULL, 'critical_referral_count', '3', 'Number of critical items failed triggering referral'),
  ((SELECT id FROM screening_tool_configs WHERE tool_type = 'mchatAutism'), 'special', NULL, 'reverse_items', '["mchat_11","mchat_18","mchat_20"]', 'Items where Yes=risk (reverse scored)')
ON CONFLICT (tool_config_id, rule_type, (COALESCE(domain, '__overall__')), parameter_name) DO NOTHING;

-- ISAA
INSERT INTO scoring_rules (tool_config_id, rule_type, domain, parameter_name, parameter_value, description) VALUES
  ((SELECT id FROM screening_tool_configs WHERE tool_type = 'isaaAutism'), 'cutoff', NULL, 'mild_min', '70', 'Min score for mild autism'),
  ((SELECT id FROM screening_tool_configs WHERE tool_type = 'isaaAutism'), 'cutoff', NULL, 'moderate_min', '107', 'Min score for moderate autism'),
  ((SELECT id FROM screening_tool_configs WHERE tool_type = 'isaaAutism'), 'cutoff', NULL, 'max_score', '200', 'Maximum possible score')
ON CONFLICT (tool_config_id, rule_type, (COALESCE(domain, '__overall__')), parameter_name) DO NOTHING;

-- ADHD
INSERT INTO scoring_rules (tool_config_id, rule_type, domain, parameter_name, parameter_value, description) VALUES
  ((SELECT id FROM screening_tool_configs WHERE tool_type = 'adhdScreening'), 'cutoff', NULL, 'medium_min', '4', 'Min score for medium risk'),
  ((SELECT id FROM screening_tool_configs WHERE tool_type = 'adhdScreening'), 'cutoff', NULL, 'high_min', '6', 'Min score for high risk')
ON CONFLICT (tool_config_id, rule_type, (COALESCE(domain, '__overall__')), parameter_name) DO NOTHING;

-- RBSK Behavioral
INSERT INTO scoring_rules (tool_config_id, rule_type, domain, parameter_name, parameter_value, description) VALUES
  ((SELECT id FROM screening_tool_configs WHERE tool_type = 'rbskBehavioral'), 'cutoff', NULL, 'medium_min', '1', 'Min score for medium risk'),
  ((SELECT id FROM screening_tool_configs WHERE tool_type = 'rbskBehavioral'), 'cutoff', NULL, 'high_min', '3', 'Min score for high risk')
ON CONFLICT (tool_config_id, rule_type, (COALESCE(domain, '__overall__')), parameter_name) DO NOTHING;

-- SDQ
INSERT INTO scoring_rules (tool_config_id, rule_type, domain, parameter_name, parameter_value, description) VALUES
  ((SELECT id FROM screening_tool_configs WHERE tool_type = 'sdqBehavioral'), 'cutoff', NULL, 'medium_min', '14', 'Min total difficulties score for medium risk'),
  ((SELECT id FROM screening_tool_configs WHERE tool_type = 'sdqBehavioral'), 'cutoff', NULL, 'high_min', '17', 'Min total difficulties score for high risk'),
  ((SELECT id FROM screening_tool_configs WHERE tool_type = 'sdqBehavioral'), 'cutoff', NULL, 'max_score', '40', 'Maximum total difficulties score'),
  ((SELECT id FROM screening_tool_configs WHERE tool_type = 'sdqBehavioral'), 'special', NULL, 'reverse_score_max', '2', 'Max value for reverse scoring calculation')
ON CONFLICT (tool_config_id, rule_type, (COALESCE(domain, '__overall__')), parameter_name) DO NOTHING;

-- Parent-Child Interaction
INSERT INTO scoring_rules (tool_config_id, rule_type, domain, parameter_name, parameter_value, description) VALUES
  ((SELECT id FROM screening_tool_configs WHERE tool_type = 'parentChildInteraction'), 'cutoff', NULL, 'high_risk_max', '8', 'Score at or below this = high risk'),
  ((SELECT id FROM screening_tool_configs WHERE tool_type = 'parentChildInteraction'), 'cutoff', NULL, 'medium_risk_max', '16', 'Score at or below this = medium risk'),
  ((SELECT id FROM screening_tool_configs WHERE tool_type = 'parentChildInteraction'), 'cutoff', NULL, 'max_score', '24', 'Maximum possible score')
ON CONFLICT (tool_config_id, rule_type, (COALESCE(domain, '__overall__')), parameter_name) DO NOTHING;

-- PHQ-9
INSERT INTO scoring_rules (tool_config_id, rule_type, domain, parameter_name, parameter_value, description) VALUES
  ((SELECT id FROM screening_tool_configs WHERE tool_type = 'parentMentalHealth'), 'cutoff', NULL, 'mild_min', '5', 'Min score for mild depression'),
  ((SELECT id FROM screening_tool_configs WHERE tool_type = 'parentMentalHealth'), 'cutoff', NULL, 'moderate_min', '10', 'Min score for moderate depression'),
  ((SELECT id FROM screening_tool_configs WHERE tool_type = 'parentMentalHealth'), 'cutoff', NULL, 'severe_min', '15', 'Min score for severe depression'),
  ((SELECT id FROM screening_tool_configs WHERE tool_type = 'parentMentalHealth'), 'cutoff', NULL, 'max_score', '27', 'Maximum possible score'),
  ((SELECT id FROM screening_tool_configs WHERE tool_type = 'parentMentalHealth'), 'special', NULL, 'skip_item', '"phq_10"', 'Item excluded from score calculation'),
  ((SELECT id FROM screening_tool_configs WHERE tool_type = 'parentMentalHealth'), 'special', NULL, 'suicidal_item', '"phq_9"', 'Item flagging suicidal ideation')
ON CONFLICT (tool_config_id, rule_type, (COALESCE(domain, '__overall__')), parameter_name) DO NOTHING;

-- Home Stimulation
INSERT INTO scoring_rules (tool_config_id, rule_type, domain, parameter_name, parameter_value, description) VALUES
  ((SELECT id FROM screening_tool_configs WHERE tool_type = 'homeStimulation'), 'cutoff', NULL, 'high_risk_max', '7', 'Score at or below this = high risk'),
  ((SELECT id FROM screening_tool_configs WHERE tool_type = 'homeStimulation'), 'cutoff', NULL, 'medium_risk_max', '15', 'Score at or below this = medium risk'),
  ((SELECT id FROM screening_tool_configs WHERE tool_type = 'homeStimulation'), 'cutoff', NULL, 'max_score', '22', 'Maximum possible score')
ON CONFLICT (tool_config_id, rule_type, (COALESCE(domain, '__overall__')), parameter_name) DO NOTHING;

-- Nutrition
INSERT INTO scoring_rules (tool_config_id, rule_type, domain, parameter_name, parameter_value, description) VALUES
  ((SELECT id FROM screening_tool_configs WHERE tool_type = 'nutritionAssessment'), 'cutoff', NULL, 'medium_risk_min', '1', 'Min risk indicators for medium risk'),
  ((SELECT id FROM screening_tool_configs WHERE tool_type = 'nutritionAssessment'), 'cutoff', NULL, 'high_risk_min', '3', 'Min risk indicators for high risk'),
  ((SELECT id FROM screening_tool_configs WHERE tool_type = 'nutritionAssessment'), 'special', NULL, 'dietary_no_threshold', '3', 'Number of No dietary answers triggering concern')
ON CONFLICT (tool_config_id, rule_type, (COALESCE(domain, '__overall__')), parameter_name) DO NOTHING;

-- ============================================================
-- 5. ACTIVITIES (30 activities)
-- ============================================================

INSERT INTO activities (activity_code, domain, title_en, title_te, description_en, description_te, materials_en, materials_te, duration_minutes, min_age_months, max_age_months, risk_level, has_video)
VALUES
  ('GM_001', 'gm', 'Tummy Time Play', 'పొట్టపై ఆడుకోవడం', 'Place baby on tummy for 10-15 minutes several times a day. Use colorful toys to encourage lifting head and reaching.', 'రోజుకు కొన్నిసార్లు 10-15 నిమిషాల పాటు బాబును పొట్టపై ఉంచండి. తల పైకి ఎత్తడం మరియు చేరడం ప్రోత్సహించడానికి రంగురంగుల బొమ్మలను ఉపయోగించండి.', 'Soft mat, colorful toys, mirror', 'మెత్తని పరుపు, రంగురంగుల బొమ్మలు, అద్దం', 15, 0, 6, 'medium', true),
  ('GM_002', 'gm', 'Ball Games', 'బంతి ఆటలు', 'Roll a ball back and forth with the child. Progress to throwing, catching, and kicking as they develop.', 'బిడ్డతో బంతిని ముందుకు వెనక్కి రోల్ చేయండి. వారు అభివృద్ధి చెందినప్పుడు ఎగరేయడం, పట్టుకోవడం మరియు కొట్టడానికి పురోగతి సాధించండి.', 'Soft ball, open space', 'మృదువైన బంతి, ఖాళీ స్థలం', 20, 12, 60, 'low', true),
  ('GM_003', 'gm', 'Jumping Exercises', 'దుముకు వ్యాయామాలు', 'Practice jumping on the spot, then progress to jumping forward, over lines, and from small heights.', 'అదే స్థలంలో దుమకడం అభ్యాసం చేయండి, తర్వాత ముందుకు, గీతలపై నుండి మరియు చిన్న ఎత్తు నుండి దుమకడానికి పురోగతి సాధించండి.', 'Soft surface, chalk for lines', 'మృదువైన ఉపరితలం, గీతల కోసం చాక్', 15, 24, 60, 'medium', true),
  ('GM_004', 'gm', 'Obstacle Course', 'అడ్డంకి మార్గం', 'Create a simple obstacle course with cushions, chairs, and toys to climb over, crawl under, and walk around.', 'దాటవేయడం, కింద నడక మరియు చుట్టూ నడవడానికి దిండులు, కుర్చీలు మరియు బొమ్మలతో ఒక సాధారణ అడ్డంకి మార్గాన్ని సృష్టించండి.', 'Cushions, chairs, soft toys', 'దిండులు, కుర్చీలు, మృదువైన బొమ్మలు', 20, 18, 60, 'medium', true),
  ('GM_005', 'gm', 'Crawling Practice', 'పాకడం అభ్యాసం', 'Encourage crawling by placing toys just out of reach. Create tunnels with boxes for fun.', 'అందుబాటులో లేని బొమ్మలను ఉంచడం ద్వారా పాకడం ప్రోత్సహించండి. సరదా కోసం పెట్టెలతో టన్నెల్స్ సృష్టించండి.', 'Toys, cardboard boxes', 'బొమ్మలు, కార్డ్‌బోర్డ్ పెట్టెలు', 15, 6, 18, 'medium', true),
  ('GM_006', 'gm', 'Walking Support', 'నడక మద్దతు', 'Hold child''s hands and help them walk. Use push toys for independent practice.', 'బిడ్డ చేతులు పట్టుకుని నడవడంలో సహాయపడండి. స్వతంత్ర అభ్యాసం కోసం పుష్ బొమ్మలను ఉపయోగించండి.', 'Push toy, furniture for support', 'పుష్ బొమ్మ, మద్దతు కోసం ఫర్నిచర్', 15, 9, 18, 'high', true),
  ('FM_001', 'fm', 'Block Stacking', 'బ్లాకులు అగ్గి పెట్టడం', 'Show child how to stack blocks. Start with 2-3 blocks and progress to taller towers.', 'బ్లాకులు అగ్గి పెట్టడం ఎలాగో చూపించండి. 2-3 బ్లాకులతో ప్రారంభించి పొడవైన టవర్లకు పురోగతి సాధించండి.', 'Wooden blocks or soft blocks', 'లోహపు లేదా మృదువైన బ్లాకులు', 15, 12, 36, 'low', true),
  ('FM_002', 'fm', 'Drawing and Coloring', 'గీయడం మరియు రంగులు వేయడం', 'Provide crayons and paper. Start with scribbling and progress to shapes and pictures.', 'క్రేయాన్లు మరియు కాగితం అందించండి. గీకడంతో ప్రారంభించి ఆకారాలు మరియు చిత్రాలకు పురోగతి సాధించండి.', 'Crayons, paper, coloring books', 'క్రేయాన్లు, కాగితం, రంగుల పుస్తకాలు', 20, 18, 60, 'low', true),
  ('FM_003', 'fm', 'Puzzle Solving', 'పజిల్ పరిష్కరణ', 'Start with simple shape puzzles and progress to more complex picture puzzles.', 'సాధారణ ఆకార పజిల్స్ తో ప్రారంభించి మరింత సంక్లిష్టమైన చిత్ర పజిల్స్ కు పురోగతి సాధించండి.', 'Age-appropriate puzzles', 'వయసుకు తగిన పజిల్స్', 20, 24, 60, 'medium', true),
  ('FM_004', 'fm', 'Play Dough', 'పిండి ఆట', 'Use play dough to squeeze, roll, pinch, and create shapes. Great for finger strength.', 'పిండిని పిండడం, రోల్ చేయడం, పించ్ చేయడం మరియు ఆకారాలు సృష్టించడానికి ఉపయోగించండి. వేలు బలం కోసం గొప్పది.', 'Play dough, rolling pin, cookie cutters', 'ప్లే డో, రోలింగ్ పిన్, కుకీ కట్టర్స్', 25, 18, 60, 'low', true),
  ('FM_005', 'fm', 'Bead Threading', 'ముక్కలు త్రిప్పడం', 'Thread large beads onto a string. Progress to smaller beads as skills improve.', 'పెద్ద ముక్కలను దారంలోకి త్రిప్పండి. నైపుణ్యాలు మెరుగైనప్పుడు చిన్న ముక్కలకు పురోగతి సాధించండి.', 'Large beads, thick string, shoelace', 'పెద్ద ముక్కలు, మందపాటి దారం, షూ‌లేస్', 15, 24, 48, 'medium', true),
  ('FM_006', 'fm', 'Scissor Practice', 'కత్తిరించే కత్తుల అభ్యాసం', 'Practice cutting straight lines, then curves and shapes with child-safe scissors.', 'నేరుగా గీతలను కత్తిరించడం అభ్యాసం చేయండి, తర్వాత బిడ్డ-సురక్షిత కత్తులతో వంపులు మరియు ఆకారాలు.', 'Child-safe scissors, paper', 'బిడ్డ-సురక్షిత కత్తులు, కాగితం', 15, 36, 60, 'medium', true),
  ('LC_001', 'lc', 'Picture Book Reading', 'బొమ్మల పుస్తకం చదవడం', 'Read picture books daily. Point to pictures, name objects, and ask questions.', 'రోజువారీగా బొమ్మల పుస్తకాలు చదవండి. బొమ్మలను చూపించి, వస్తువుల పేర్లు చెప్పండి మరియు ప్రశ్నలు అడగండి.', 'Picture books, comfortable seating', 'బొమ్మల పుస్తకాలు, సౌకర్యవంతమైన కూర్చోడం', 20, 6, 60, 'high', true),
  ('LC_002', 'lc', 'Storytelling Time', 'కథ చెప్పే సమయం', 'Tell simple stories using puppets or toys. Encourage child to repeat or continue the story.', 'పప్పెట్లు లేదా బొమ్మలను ఉపయోగించి సాధారణ కథలు చెప్పండి. కథను పునరావృతం చేయడం లేదా కొనసాగించడం ప్రోత్సహించండి.', 'Puppets, stuffed animals, story books', 'పప్పెట్లు, స్టఫ్డ్ జంతువులు, కథా పుస్తకాలు', 20, 24, 60, 'high', true),
  ('LC_003', 'lc', 'Word Games', 'పదాల ఆటలు', 'Play rhyming games, naming games, and simple word associations.', 'యమకాల ఆటలు, పేర్లు చెప్పే ఆటలు మరియు సాధారణ పద సంబంధాలు ఆడండి.', 'Flash cards, picture cards', 'ఫ్లాష్ కార్డులు, చిత్ర కార్డులు', 15, 36, 60, 'medium', true),
  ('LC_004', 'lc', 'Nursery Rhymes', 'పాటలు మరియు పద్యాలు', 'Sing nursery rhymes together. Use actions and encourage child to sing along.', 'కలిసి పాటలు పాడండి. చర్యలను ఉపయోగించి బిడ్డ కలిసి పాడటం ప్రోత్సహించండి.', 'No materials needed', 'సామాగ్రి అవసరం లేదు', 15, 12, 48, 'medium', true),
  ('LC_005', 'lc', 'Daily Conversation', 'రోజువారీ సంభాషణ', 'Talk about daily activities, ask open-ended questions, and wait for responses.', 'రోజువారీ కార్యకలాపాల గురించి మాట్లాడండి, ఓపెన్-ఎండెడ్ ప్రశ్నలు అడగండి మరియు స్పందనల కోసం వేచి ఉండండి.', 'No materials needed', 'సామాగ్రి అవసరం లేదు', 30, 18, 60, 'high', false),
  ('LC_006', 'lc', 'Name Labeling', 'పేర్లు లేబులింగ్', 'Label objects around the house. Point and name them regularly.', 'ఇంటి చుట్టూ ఉన్న వస్తువులకు లేబుల్స్ వేయండి. నియమితంగా చూపించి పేర్లు చెప్పండి.', 'Labels, markers', 'లేబుల్స్, మార్కర్లు', 15, 18, 36, 'medium', false),
  ('COG_001', 'cog', 'Sorting Games', 'వర్గీకరణ ఆటలు', 'Sort objects by color, shape, or size. Start with 2 categories and add more.', 'రంగు, ఆకారం లేదా పరిమాణం ప్రకారం వస్తువులను వర్గీకరించండి. 2 వర్గాలతో ప్రారంభించి మరింత చేర్చండి.', 'Colorful objects, bowls for sorting', 'రంగురంగుల వస్తువులు, వర్గీకరణ కోసం గిన్నెలు', 15, 24, 48, 'medium', true),
  ('COG_002', 'cog', 'Pretend Play', 'నటనా ఆట', 'Engage in pretend play like cooking, shopping, or doctor visits with toys.', 'బొమ్మలతో వంట, షాపింగ్, లేదా డాక్టర్ సందర్శనల వంటి నటనా ఆటలో పాల్గొనండి.', 'Play kitchen, toy food, dolls', 'ప్లే కిచెన్, బొమ్మ ఆహారం, బొమ్మలు', 30, 24, 60, 'low', true),
  ('COG_003', 'cog', 'Matching Games', 'జతపరచే ఆటలు', 'Match identical pictures, shapes, or objects. Progress to memory games.', 'ఒకే విధమైన చిత్రాలు, ఆకారాలు లేదా వస్తువులను జతపరచండి. మెమరీ ఆటలకు పురోగతి సాధించండి.', 'Matching cards, memory game sets', 'జతపరచే కార్డులు, మెమరీ గేమ్ సెట్లు', 15, 24, 60, 'low', true),
  ('COG_004', 'cog', 'Hide and Seek', 'దాచుకొని వెతకడం', 'Hide toys and ask child to find them. Helps develop object permanence.', 'బొమ్మలను దాచి బిడ్డ వాటిని కనుగొనమని అడగండి. ఆబ్జెక్ట్ పర్మనెన్స్ అభివృద్ధి చెందడానికి సహాయపడుతుంది.', 'Toys to hide, blanket', 'దాచడానికి బొమ్మలు, బ్లాంకెట్', 15, 9, 36, 'low', true),
  ('COG_005', 'cog', 'Counting Games', 'లెక్కింపు ఆటలు', 'Count objects during daily activities. Use fingers, toys, or steps.', 'రోజువారీ కార్యకలాపాలలో వస్తువులను లెక్కించండి. వేళ్లు, బొమ్మలు లేదా మెట్లను ఉపయోగించండి.', 'Objects to count', 'లెక్కించడానికి వస్తువులు', 15, 30, 60, 'medium', false),
  ('COG_006', 'cog', 'Building with Blocks', 'బ్లాకులతో నిర్మాణం', 'Build structures together. Discuss shapes, sizes, and balance.', 'కలిసి నిర్మాణాలు కట్టండి. ఆకారాలు, పరిమాణాలు మరియు సమతుల్యత గురించి చర్చించండి.', 'Building blocks, LEGO (age-appropriate)', 'బిల్డింగ్ బ్లాకులు, లెగో (వయసుకు తగిన)', 25, 24, 60, 'low', true),
  ('SE_001', 'se', 'Play Dates', 'స్నేహితులతో ఆట', 'Arrange play dates with other children. Supervise and guide interactions.', 'ఇతర పిల్లలతో ప్లే డేట్స్ ఏర్పాటు చేయండి. పరస్పర చర్యలను పర్యవేక్షించి మార్గనిర్దేశం చేయండి.', 'Toys for sharing, snacks', 'పంచుకోవడానికి బొమ్మలు, స్నాక్స్', 60, 24, 60, 'high', false),
  ('SE_002', 'se', 'Sharing Activities', 'పంచుకోవడం కార్యకలాపాలు', 'Practice taking turns and sharing toys. Use timer if needed.', 'వారీలు తీసుకోవడం మరియు బొమ్మలను పంచుకోవడం అభ్యాసం చేయండి. అవసరమైతే టైమర్ ఉపయోగించండి.', 'Toys to share, timer', 'పంచుకోవడానికి బొమ్మలు, టైమర్', 20, 24, 48, 'high', true),
  ('SE_003', 'se', 'Emotion Recognition', 'భావోద్వేగాల గుర్తింపు', 'Use emotion cards or mirror to practice making and recognizing different facial expressions.', 'వివిధ ముఖ కవళికలను చేయడం మరియు గుర్తించడం అభ్యాసం చేయడానికి ఎమోషన్ కార్డులు లేదా అద్దాన్ని ఉపయోగించండి.', 'Emotion cards, mirror', 'ఎమోషన్ కార్డులు, అద్దం', 15, 24, 60, 'medium', true),
  ('SE_004', 'se', 'Role Play', 'పాత్ర నటన', 'Act out different social situations like greeting, sharing, or apologizing.', 'శుభాకాంక్షలు, పంచుకోవడం, లేదా క్షమాపణలు వంటి వివిధ సామాజిక పరిస్థితులను నటించండి.', 'Puppets, dress-up clothes', 'పప్పెట్లు, డ్రెస్-అప్ బట్టలు', 20, 30, 60, 'medium', true),
  ('SE_005', 'se', 'Cooperative Games', 'సహకార ఆటలు', 'Play games that require working together rather than competing.', 'పోటీ కాకుండా కలిసి పనిచేయడం అవసరమైన ఆటలను ఆడండి.', 'Ball, parachute, building materials', 'బంతి, పారాషూట్, నిర్మాణ సామగ్రి', 20, 36, 60, 'medium', true),
  ('SE_006', 'se', 'Daily Routines', 'రోజువారీ కార్యక్రమాలు', 'Establish consistent daily routines. Use visual schedules to help child understand what comes next.', 'స్థిరమైన రోజువారీ కార్యక్రమాలను ఏర్పాటు చేయండి. తర్వాత ఏమి వస్తుందో అర్థం చేసుకోవడంలో బిడ్డకు సహాయపడటానికి దృశ్యమాన షెడ్యూల్‌లను ఉపయోగించండి.', 'Visual schedule cards, chart', 'దృశ్యమాన షెడ్యూల్ కార్డులు, చార్ట్', 30, 18, 60, 'low', false)
ON CONFLICT (activity_code) DO NOTHING;

-- ============================================================
-- DONE
-- ============================================================

COMMIT;
