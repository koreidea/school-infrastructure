import 'package:flutter/material.dart';
import '../models/screening_tool.dart';

final nutritionConfig = ScreeningToolConfig(
  type: ScreeningToolType.nutritionAssessment,
  id: 'nutrition_assessment',
  name: 'Nutrition Assessment',
  nameTe: 'పోషణ అంచనా',
  description: 'Assesses nutritional status through measurements and dietary questions',
  descriptionTe: 'కొలతలు మరియు ఆహార ప్రశ్నల ద్వారా పోషణ స్థితిని అంచనా వేస్తుంది',
  minAgeMonths: 0,
  maxAgeMonths: 72,
  responseFormat: ResponseFormat.mixed,
  domains: ['measurements', 'dietary', 'signs'],
  icon: Icons.restaurant,
  color: Color(0xFF8BC34A),
  order: 11,
  questions: _nutritionQuestions,
);

const _nutritionQuestions = <ScreeningQuestion>[
  // Measurements (numeric input)
  ScreeningQuestion(id: 'nut_height', question: 'Height', questionTe: 'ఎత్తు', domain: 'measurements', domainName: 'Measurements', domainNameTe: 'కొలతలు', unit: 'cm', overrideFormat: ResponseFormat.numericInput),
  ScreeningQuestion(id: 'nut_weight', question: 'Weight', questionTe: 'బరువు', domain: 'measurements', domainName: 'Measurements', domainNameTe: 'కొలతలు', unit: 'kg', overrideFormat: ResponseFormat.numericInput),
  ScreeningQuestion(id: 'nut_head_circ', question: 'Head Circumference (optional)', questionTe: 'తల చుట్టు కొలత (ఐచ్ఛికం)', domain: 'measurements', domainName: 'Measurements', domainNameTe: 'కొలతలు', unit: 'cm', overrideFormat: ResponseFormat.numericInput),
  ScreeningQuestion(id: 'nut_muac', question: 'Mid-Upper Arm Circumference (optional)', questionTe: 'మధ్య-ఎగువ చేతి చుట్టు కొలత (ఐచ్ఛికం)', domain: 'measurements', domainName: 'Measurements', domainNameTe: 'కొలతలు', unit: 'cm', overrideFormat: ResponseFormat.numericInput),

  // Dietary Questions (Yes/No)
  ScreeningQuestion(id: 'nut_d1', question: 'Is child currently being breastfed? (if under 24 months)', questionTe: 'బిడ్డకు ప్రస్తుతం తల్లి పాలు ఇస్తున్నారా? (24 నెలల కంటే తక్కువ అయితే)', domain: 'dietary', domainName: 'Dietary', domainNameTe: 'ఆహారం', overrideFormat: ResponseFormat.yesNo),
  ScreeningQuestion(id: 'nut_d2', question: 'Does child eat at least 3 meals a day?', questionTe: 'బిడ్డ రోజుకు కనీసం 3 భోజనాలు తింటారా?', domain: 'dietary', domainName: 'Dietary', domainNameTe: 'ఆహారం', overrideFormat: ResponseFormat.yesNo),
  ScreeningQuestion(id: 'nut_d3', question: 'Does child eat fruits and vegetables regularly?', questionTe: 'బిడ్డ క్రమం తప్పకుండా పండ్లు మరియు కూరగాయలు తింటారా?', domain: 'dietary', domainName: 'Dietary', domainNameTe: 'ఆహారం', overrideFormat: ResponseFormat.yesNo),
  ScreeningQuestion(id: 'nut_d4', question: 'Does child consume milk or dairy products daily?', questionTe: 'బిడ్డ రోజూ పాలు లేదా పాల ఉత్పత్తులు తీసుకుంటారా?', domain: 'dietary', domainName: 'Dietary', domainNameTe: 'ఆహారం', overrideFormat: ResponseFormat.yesNo),
  ScreeningQuestion(id: 'nut_d5', question: 'Does child eat protein sources (dal, eggs, meat, fish)?', questionTe: 'బిడ్డ ప్రోటీన్ వనరులు (పప్పు, గుడ్లు, మాంసం, చేపలు) తింటారా?', domain: 'dietary', domainName: 'Dietary', domainNameTe: 'ఆహారం', overrideFormat: ResponseFormat.yesNo),
  ScreeningQuestion(id: 'nut_d6', question: 'Does child take iron/vitamin supplements if prescribed?', questionTe: 'సూచించినట్లయితే బిడ్డ ఇనుము/విటమిన్ సప్లిమెంట్లు తీసుకుంటారా?', domain: 'dietary', domainName: 'Dietary', domainNameTe: 'ఆహారం', overrideFormat: ResponseFormat.yesNo),

  // Clinical Signs (Yes/No - positive means risk)
  ScreeningQuestion(id: 'nut_s1', question: 'Does child appear visibly thin or wasted?', questionTe: 'బిడ్డ కనిపించేంత సన్నగా లేదా క్షీణించినట్లు కనిపిస్తారా?', domain: 'signs', domainName: 'Clinical Signs', domainNameTe: 'వైద్య సంకేతాలు', overrideFormat: ResponseFormat.yesNo),
  ScreeningQuestion(id: 'nut_s2', question: 'Does child have pale skin, nails, or conjunctiva (signs of anemia)?', questionTe: 'బిడ్డకు పాలిపోయిన చర్మం, గోళ్ళు లేదా కనుకొలకు ఉన్నాయా (రక్తహీనత సంకేతాలు)?', domain: 'signs', domainName: 'Clinical Signs', domainNameTe: 'వైద్య సంకేతాలు', overrideFormat: ResponseFormat.yesNo),
  ScreeningQuestion(id: 'nut_s3', question: 'Does child have swelling (edema) in feet or face?', questionTe: 'బిడ్డ పాదాలు లేదా ముఖంలో వాపు (ఎడెమా) ఉందా?', domain: 'signs', domainName: 'Clinical Signs', domainNameTe: 'వైద్య సంకేతాలు', overrideFormat: ResponseFormat.yesNo, isRedFlag: true),
  ScreeningQuestion(id: 'nut_s4', question: 'Has child had frequent illnesses in last 3 months?', questionTe: 'గత 3 నెలల్లో బిడ్డకు తరచుగా అనారోగ్యాలు వచ్చాయా?', domain: 'signs', domainName: 'Clinical Signs', domainNameTe: 'వైద్య సంకేతాలు', overrideFormat: ResponseFormat.yesNo),
  ScreeningQuestion(id: 'nut_s5', question: 'Has child lost weight or failed to gain weight recently?', questionTe: 'బిడ్డ ఇటీవల బరువు తగ్గారా లేదా బరువు పెరగలేదా?', domain: 'signs', domainName: 'Clinical Signs', domainNameTe: 'వైద్య సంకేతాలు', overrideFormat: ResponseFormat.yesNo),
];
