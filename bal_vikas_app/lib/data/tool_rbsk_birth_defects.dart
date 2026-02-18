import 'package:flutter/material.dart';
import '../models/screening_tool.dart';

final rbskBirthDefectsConfig = ScreeningToolConfig(
  type: ScreeningToolType.rbskBirthDefects,
  id: 'rbsk_birth_defects',
  name: 'RBSK Birth Defects Screening',
  nameTe: 'RBSK పుట్టుకతో వచ్చే లోపాల స్క్రీనింగ్',
  description: 'Screening for congenital anomalies and birth defects (RBSK 4D — Defects at Birth)',
  descriptionTe: 'పుట్టుకతో వచ్చే అసాధారణతలు మరియు లోపాల స్క్రీనింగ్ (RBSK 4D — పుట్టుకతో లోపాలు)',
  minAgeMonths: 0,
  maxAgeMonths: 72,
  responseFormat: ResponseFormat.yesNo,
  domains: ['neural', 'musculoskeletal', 'craniofacial', 'cardiac', 'sensory', 'other'],
  icon: Icons.child_care,
  color: Color(0xFFE91E63),
  order: 13,
  questions: _birthDefectQuestions,
);

const _birthDefectQuestions = <ScreeningQuestion>[
  // Neural Tube Defects
  ScreeningQuestion(
    id: 'bd_n1', question: 'Does the child have any visible spinal abnormality (e.g., swelling, dimple, or tuft of hair on lower back)?',
    questionTe: 'పిల్లలకి వెన్నెముక అసాధారణత కనిపిస్తుందా (ఉదా., వాపు, గుంట, లేదా నడుము భాగంలో వెంట్రుకల గుత్తి)?',
    domain: 'neural', domainName: 'Neural Tube', domainNameTe: 'నరాల నాళం', isRedFlag: true,
  ),
  ScreeningQuestion(
    id: 'bd_n2', question: 'Does the child have an unusually large or small head for age?',
    questionTe: 'పిల్లల తల వయసుకు అసాధారణంగా పెద్దదిగా లేదా చిన్నదిగా ఉందా?',
    domain: 'neural', domainName: 'Neural Tube', domainNameTe: 'నరాల నాళం', isRedFlag: true,
  ),

  // Musculoskeletal
  ScreeningQuestion(
    id: 'bd_m1', question: 'Does the child have club foot (feet turned inward)?',
    questionTe: 'పిల్లలకి క్లబ్ ఫుట్ ఉందా (పాదాలు లోపలికి తిరిగి ఉన్నాయా)?',
    domain: 'musculoskeletal', domainName: 'Musculoskeletal', domainNameTe: 'కండరాల-ఎముకల',
  ),
  ScreeningQuestion(
    id: 'bd_m2', question: 'Does the child have any limb abnormality (missing, extra, or shortened fingers/toes/limbs)?',
    questionTe: 'పిల్లలకి అవయవ అసాధారణత ఉందా (వేళ్ళు/కాళ్ళు తక్కువ, ఎక్కువ లేదా చిన్నవి)?',
    domain: 'musculoskeletal', domainName: 'Musculoskeletal', domainNameTe: 'కండరాల-ఎముకల',
  ),
  ScreeningQuestion(
    id: 'bd_m3', question: 'Does the child have congenital hip dislocation (unequal leg lengths or difficulty moving legs)?',
    questionTe: 'పిల్లలకి పుట్టుకతో తుంటి చీలిక ఉందా (కాళ్ళ పొడవు సమానంగా లేకపోవడం లేదా కాళ్ళు కదపడంలో ఇబ్బంది)?',
    domain: 'musculoskeletal', domainName: 'Musculoskeletal', domainNameTe: 'కండరాల-ఎముకల',
  ),

  // Craniofacial
  ScreeningQuestion(
    id: 'bd_c1', question: 'Does the child have cleft lip (split in upper lip)?',
    questionTe: 'పిల్లలకి చీలిన పెదవి ఉందా (పై పెదవిలో చీలిక)?',
    domain: 'craniofacial', domainName: 'Craniofacial', domainNameTe: 'ముఖ-కపాల', isRedFlag: true,
  ),
  ScreeningQuestion(
    id: 'bd_c2', question: 'Does the child have cleft palate (opening in roof of mouth)?',
    questionTe: 'పిల్లలకి చీలిన అంగిలి ఉందా (నోటి పై భాగంలో రంధ్రం)?',
    domain: 'craniofacial', domainName: 'Craniofacial', domainNameTe: 'ముఖ-కపాల', isRedFlag: true,
  ),
  ScreeningQuestion(
    id: 'bd_c3', question: 'Does the child have features suggestive of Down syndrome (flat face, upslanting eyes, single palmar crease)?',
    questionTe: 'పిల్లలకి డౌన్ సిండ్రోమ్ లక్షణాలు ఉన్నాయా (చదునైన ముఖం, పైకి వాలిన కళ్ళు, అరచేతిలో ఒకే గీత)?',
    domain: 'craniofacial', domainName: 'Craniofacial', domainNameTe: 'ముఖ-కపాల', isRedFlag: true,
  ),

  // Cardiac
  ScreeningQuestion(
    id: 'bd_h1', question: 'Does the child have bluish discoloration of lips, nails, or skin (cyanosis)?',
    questionTe: 'పిల్లల పెదవులు, గోళ్ళు లేదా చర్మం నీలం రంగులోకి మారుతుందా (సయనోసిస్)?',
    domain: 'cardiac', domainName: 'Cardiac', domainNameTe: 'గుండె', isRedFlag: true,
  ),
  ScreeningQuestion(
    id: 'bd_h2', question: 'Does the child have difficulty breathing or get tired easily during feeding/activity?',
    questionTe: 'పిల్లలకి శ్వాస తీసుకోవడంలో ఇబ్బంది ఉందా లేదా ఆహారం/కార్యకలాపాల సమయంలో త్వరగా అలసిపోతారా?',
    domain: 'cardiac', domainName: 'Cardiac', domainNameTe: 'గుండె',
  ),
  ScreeningQuestion(
    id: 'bd_h3', question: 'Has the child been diagnosed with or suspected of having a heart murmur?',
    questionTe: 'పిల్లలకి గుండె గొణుగుడు ఉన్నట్లు నిర్ధారించబడిందా లేదా అనుమానించబడిందా?',
    domain: 'cardiac', domainName: 'Cardiac', domainNameTe: 'గుండె',
  ),

  // Sensory
  ScreeningQuestion(
    id: 'bd_s1', question: 'Does the child have congenital cataract (white reflex in the pupil)?',
    questionTe: 'పిల్లలకి పుట్టుకతో కంటి శుక్లం ఉందా (నల్లగుడ్డులో తెల్లని ప్రతిబింబం)?',
    domain: 'sensory', domainName: 'Sensory', domainNameTe: 'ఇంద్రియ', isRedFlag: true,
  ),
  ScreeningQuestion(
    id: 'bd_s2', question: 'Does the child not respond to sounds or startle to loud noises?',
    questionTe: 'పిల్లలు శబ్దాలకు స్పందించరా లేదా పెద్ద శబ్దాలకు ఉలిక్కిపడరా?',
    domain: 'sensory', domainName: 'Sensory', domainNameTe: 'ఇంద్రియ', isRedFlag: true,
  ),
  ScreeningQuestion(
    id: 'bd_s3', question: 'Does the child have abnormally shaped or positioned ears?',
    questionTe: 'పిల్లల చెవులు అసాధారణ ఆకారంలో లేదా స్థానంలో ఉన్నాయా?',
    domain: 'sensory', domainName: 'Sensory', domainNameTe: 'ఇంద్రియ',
  ),

  // Other congenital
  ScreeningQuestion(
    id: 'bd_o1', question: 'Does the child have an abdominal wall defect (umbilical hernia, omphalocele)?',
    questionTe: 'పిల్లలకి ఉదర గోడ లోపం ఉందా (బొడ్డు హెర్నియా)?',
    domain: 'other', domainName: 'Other Congenital', domainNameTe: 'ఇతర పుట్టుక',
  ),
  ScreeningQuestion(
    id: 'bd_o2', question: 'Does the child have undescended testes (for boys)?',
    questionTe: 'పిల్లలకి దిగని వృషణాలు ఉన్నాయా (అబ్బాయిలకు)?',
    domain: 'other', domainName: 'Other Congenital', domainNameTe: 'ఇతర పుట్టుక',
  ),
  ScreeningQuestion(
    id: 'bd_o3', question: 'Does the child have any visible birthmarks or skin abnormalities present since birth?',
    questionTe: 'పుట్టినప్పటి నుండి పిల్లలకి ఏదైనా కనిపించే పుట్టుమచ్చలు లేదా చర్మ అసాధారణతలు ఉన్నాయా?',
    domain: 'other', domainName: 'Other Congenital', domainNameTe: 'ఇతర పుట్టుక',
  ),
];
