import 'package:flutter/material.dart';
import '../models/screening_tool.dart';

final adhdConfig = ScreeningToolConfig(
  type: ScreeningToolType.adhdScreening,
  id: 'adhd_screening',
  name: 'ADHD Screening',
  nameTe: 'ADHD స్క్రీనింగ్',
  description: 'Screens for Attention-Deficit/Hyperactivity Disorder - 10 items across 3 subscales',
  descriptionTe: 'శ్రద్ధ-లోపం/హైపర్‌యాక్టివిటీ డిజార్డర్ కోసం స్క్రీన్ - 3 ఉపమానాలలో 10 అంశాలు',
  minAgeMonths: 36,
  maxAgeMonths: 72,
  responseFormat: ResponseFormat.yesNo,
  domains: ['inattention', 'hyperactivity', 'impulsivity'],
  icon: Icons.flash_on,
  color: Color(0xFFFF5722),
  order: 5,
  questions: _adhdQuestions,
);

const _adhdQuestions = <ScreeningQuestion>[
  // Inattention (4 items)
  ScreeningQuestion(id: 'adhd_in1', question: 'Has difficulty sustaining attention in tasks or play', questionTe: 'పనులు లేదా ఆటలో శ్రద్ధ నిలుపుకోవడంలో కష్టం', domain: 'inattention', domainName: 'Inattention', domainNameTe: 'అశ్రద్ధ'),
  ScreeningQuestion(id: 'adhd_in2', question: 'Does not seem to listen when spoken to directly', questionTe: 'నేరుగా మాట్లాడినప్పుడు వినడం లేదని అనిపిస్తుంది', domain: 'inattention', domainName: 'Inattention', domainNameTe: 'అశ్రద్ధ'),
  ScreeningQuestion(id: 'adhd_in3', question: 'Is easily distracted by outside stimuli', questionTe: 'బయటి ఉద్దీపనల వల్ల సులభంగా దృష్టి మళ్ళుతుంది', domain: 'inattention', domainName: 'Inattention', domainNameTe: 'అశ్రద్ధ'),
  ScreeningQuestion(id: 'adhd_in4', question: 'Has difficulty organizing tasks and activities', questionTe: 'పనులు మరియు కార్యకలాపాలను వ్యవస్థీకరించడంలో కష్టం', domain: 'inattention', domainName: 'Inattention', domainNameTe: 'అశ్రద్ధ'),

  // Hyperactivity (3 items)
  ScreeningQuestion(id: 'adhd_hy1', question: 'Fidgets with hands or feet or squirms in seat', questionTe: 'చేతులు లేదా కాళ్ళతో కదులుతూ ఉంటారు లేదా సీట్లో కదులుతారు', domain: 'hyperactivity', domainName: 'Hyperactivity', domainNameTe: 'అతి చురుకుదనం'),
  ScreeningQuestion(id: 'adhd_hy2', question: 'Runs about or climbs excessively in inappropriate situations', questionTe: 'అనుచితమైన పరిస్థితులలో అతిగా పరుగెత్తడం లేదా ఎక్కడం', domain: 'hyperactivity', domainName: 'Hyperactivity', domainNameTe: 'అతి చురుకుదనం'),
  ScreeningQuestion(id: 'adhd_hy3', question: 'Is always on the go or acts as if driven by a motor', questionTe: 'ఎప్పుడూ తిరుగుతూ ఉంటారు లేదా మోటార్ చేత నడిపించబడినట్లు ప్రవర్తిస్తారు', domain: 'hyperactivity', domainName: 'Hyperactivity', domainNameTe: 'అతి చురుకుదనం'),

  // Impulsivity (3 items)
  ScreeningQuestion(id: 'adhd_im1', question: 'Blurts out answers before questions are completed', questionTe: 'ప్రశ్నలు పూర్తి కాకముందే సమాధానాలు చెప్పేస్తారు', domain: 'impulsivity', domainName: 'Impulsivity', domainNameTe: 'ఆవేశపూరితం'),
  ScreeningQuestion(id: 'adhd_im2', question: 'Has difficulty waiting for turn', questionTe: 'వంతు కోసం ఎదురుచూడడంలో కష్టం', domain: 'impulsivity', domainName: 'Impulsivity', domainNameTe: 'ఆవేశపూరితం'),
  ScreeningQuestion(id: 'adhd_im3', question: 'Interrupts or intrudes on others', questionTe: 'ఇతరులను అడ్డుకుంటారు లేదా జోక్యం చేసుకుంటారు', domain: 'impulsivity', domainName: 'Impulsivity', domainNameTe: 'ఆవేశపూరితం'),
];
