import 'package:flutter/material.dart';
import '../models/screening_tool.dart';

final rbskDiseasesConfig = ScreeningToolConfig(
  type: ScreeningToolType.rbskDiseases,
  id: 'rbsk_diseases',
  name: 'RBSK Disease Screening',
  nameTe: 'RBSK వ్యాధుల స్క్రీనింగ్',
  description: 'Screening for childhood diseases and deficiencies (RBSK 4D — Diseases & Deficiencies)',
  descriptionTe: 'బాల్య వ్యాధులు మరియు లోపాల స్క్రీనింగ్ (RBSK 4D — వ్యాధులు & లోపాలు)',
  minAgeMonths: 0,
  maxAgeMonths: 72,
  responseFormat: ResponseFormat.yesNo,
  domains: ['skin', 'ent', 'eye', 'dental', 'blood', 'deficiency'],
  icon: Icons.medical_services,
  color: Color(0xFF9C27B0),
  order: 14,
  questions: _diseaseQuestions,
);

const _diseaseQuestions = <ScreeningQuestion>[
  // Skin conditions
  ScreeningQuestion(
    id: 'ds_sk1', question: 'Does the child have persistent skin rashes, eczema, or scabies?',
    questionTe: 'పిల్లలకి నిరంతర చర్మ దద్దుర్లు, ఎగ్జిమా లేదా గజ్జి ఉందా?',
    domain: 'skin', domainName: 'Skin', domainNameTe: 'చర్మం',
  ),
  ScreeningQuestion(
    id: 'ds_sk2', question: 'Does the child have fungal infections (ringworm, white patches)?',
    questionTe: 'పిల్లలకి ఫంగల్ ఇన్ఫెక్షన్లు ఉన్నాయా (రింగ్‌వార్మ్, తెల్లని మచ్చలు)?',
    domain: 'skin', domainName: 'Skin', domainNameTe: 'చర్మం',
  ),
  ScreeningQuestion(
    id: 'ds_sk3', question: 'Does the child have boils, impetigo, or recurrent skin infections?',
    questionTe: 'పిల్లలకి పుళ్ళు, ఇంపెటిగో లేదా పునరావృత చర్మ ఇన్ఫెక్షన్లు ఉన్నాయా?',
    domain: 'skin', domainName: 'Skin', domainNameTe: 'చర్మం',
  ),

  // ENT conditions
  ScreeningQuestion(
    id: 'ds_e1', question: 'Does the child have chronic ear discharge or recurrent ear infections?',
    questionTe: 'పిల్లలకి దీర్ఘకాలిక చెవి స్రావం లేదా పునరావృత చెవి ఇన్ఫెక్షన్లు ఉన్నాయా?',
    domain: 'ent', domainName: 'ENT', domainNameTe: 'చెవి-ముక్కు-గొంతు', isRedFlag: true,
  ),
  ScreeningQuestion(
    id: 'ds_e2', question: 'Does the child have enlarged tonsils or frequent sore throat?',
    questionTe: 'పిల్లలకి పెద్దవైన టాన్సిల్స్ లేదా తరచుగా గొంతు నొప్పి ఉందా?',
    domain: 'ent', domainName: 'ENT', domainNameTe: 'చెవి-ముక్కు-గొంతు',
  ),
  ScreeningQuestion(
    id: 'ds_e3', question: 'Does the child breathe through the mouth or snore excessively?',
    questionTe: 'పిల్లలు నోటితో శ్వాస తీసుకుంటారా లేదా అతిగా గురకపెడతారా?',
    domain: 'ent', domainName: 'ENT', domainNameTe: 'చెవి-ముక్కు-గొంతు',
  ),

  // Eye conditions
  ScreeningQuestion(
    id: 'ds_ey1', question: 'Does the child have squinting (cross-eyes) or abnormal eye alignment?',
    questionTe: 'పిల్లలకి మెల్లకన్ను లేదా అసాధారణ కంటి సమలేఖనం ఉందా?',
    domain: 'eye', domainName: 'Eye', domainNameTe: 'కన్ను',
  ),
  ScreeningQuestion(
    id: 'ds_ey2', question: 'Does the child have difficulty seeing objects or holds things very close to the eyes?',
    questionTe: 'పిల్లలకి వస్తువులను చూడటంలో ఇబ్బంది ఉందా లేదా వస్తువులను కళ్ళకు చాలా దగ్గరగా పట్టుకుంటారా?',
    domain: 'eye', domainName: 'Eye', domainNameTe: 'కన్ను',
  ),
  ScreeningQuestion(
    id: 'ds_ey3', question: 'Does the child have night blindness or Bitot spots (white foamy patches on eyes)?',
    questionTe: 'పిల్లలకి రాత్రి అంధత్వం లేదా బిటాట్ మచ్చలు (కళ్ళపై తెల్లని నురుగు మచ్చలు) ఉన్నాయా?',
    domain: 'eye', domainName: 'Eye', domainNameTe: 'కన్ను', isRedFlag: true,
  ),

  // Dental conditions
  ScreeningQuestion(
    id: 'ds_d1', question: 'Does the child have dental caries (tooth decay) or black/damaged teeth?',
    questionTe: 'పిల్లలకి దంత క్షయం (పళ్ళు పాడవడం) లేదా నల్లని/దెబ్బతిన్న పళ్ళు ఉన్నాయా?',
    domain: 'dental', domainName: 'Dental', domainNameTe: 'దంతాల',
  ),
  ScreeningQuestion(
    id: 'ds_d2', question: 'Does the child have swollen, bleeding, or painful gums?',
    questionTe: 'పిల్లలకి వాపు, రక్తస్రావం లేదా నొప్పిగల చిగుళ్ళు ఉన్నాయా?',
    domain: 'dental', domainName: 'Dental', domainNameTe: 'దంతాల',
  ),

  // Blood disorders
  ScreeningQuestion(
    id: 'ds_bl1', question: 'Does the child look unusually pale (palms, nails, conjunctiva)?',
    questionTe: 'పిల్లలు అసాధారణంగా లేతగా కనిపిస్తారా (అరచేతులు, గోళ్ళు, కంటి రెప్ప లోపలి భాగం)?',
    domain: 'blood', domainName: 'Blood Disorders', domainNameTe: 'రక్త సమస్యలు', isRedFlag: true,
  ),
  ScreeningQuestion(
    id: 'ds_bl2', question: 'Does the child have recurrent jaundice or yellowing of eyes/skin?',
    questionTe: 'పిల్లలకి పునరావృత కామెర్లు లేదా కళ్ళు/చర్మం పసుపు రంగులోకి మారడం ఉందా?',
    domain: 'blood', domainName: 'Blood Disorders', domainNameTe: 'రక్త సమస్యలు', isRedFlag: true,
  ),
  ScreeningQuestion(
    id: 'ds_bl3', question: 'Does the child have a family history of sickle cell disease or thalassemia?',
    questionTe: 'పిల్లల కుటుంబంలో సికిల్ సెల్ వ్యాధి లేదా థలసీమియా చరిత్ర ఉందా?',
    domain: 'blood', domainName: 'Blood Disorders', domainNameTe: 'రక్త సమస్యలు',
  ),

  // Deficiencies
  ScreeningQuestion(
    id: 'ds_df1', question: 'Does the child have signs of Vitamin D deficiency (bowed legs, knock knees, delayed fontanelle closure)?',
    questionTe: 'పిల్లలకి విటమిన్ D లోపం లక్షణాలు ఉన్నాయా (వంగిన కాళ్ళు, ముడుచుకున్న మోకాళ్ళు, నెత్తిబొడిపె ఆలస్యంగా మూసుకోవడం)?',
    domain: 'deficiency', domainName: 'Deficiencies', domainNameTe: 'లోపాలు',
  ),
  ScreeningQuestion(
    id: 'ds_df2', question: 'Does the child have signs of iodine deficiency (goiter/neck swelling)?',
    questionTe: 'పిల్లలకి అయోడిన్ లోపం లక్షణాలు ఉన్నాయా (గాయిటర్/మెడ వాపు)?',
    domain: 'deficiency', domainName: 'Deficiencies', domainNameTe: 'లోపాలు',
  ),
  ScreeningQuestion(
    id: 'ds_df3', question: 'Does the child have signs of severe acute malnutrition (very thin, swelling of feet, skin peeling)?',
    questionTe: 'పిల్లలకి తీవ్ర పోషకాహార లోపం లక్షణాలు ఉన్నాయా (చాలా సన్నగా, పాదాల వాపు, చర్మం ఒలవడం)?',
    domain: 'deficiency', domainName: 'Deficiencies', domainNameTe: 'లోపాలు', isRedFlag: true,
  ),
];
