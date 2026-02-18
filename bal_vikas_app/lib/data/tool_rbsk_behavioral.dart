import 'package:flutter/material.dart';
import '../models/screening_tool.dart';

final rbskBehavioralConfig = ScreeningToolConfig(
  type: ScreeningToolType.rbskBehavioral,
  id: 'rbsk_behavioral',
  name: 'RBSK Behavioral Screening',
  nameTe: 'RBSK ప్రవర్తన స్క్రీనింగ్',
  description: 'RBSK Behavioral checklist - 10 items for behavioral concerns',
  descriptionTe: 'RBSK ప్రవర్తన చెక్‌లిస్ట్ - ప్రవర్తన సమస్యల కోసం 10 అంశాలు',
  minAgeMonths: 24,
  maxAgeMonths: 72,
  responseFormat: ResponseFormat.yesNo,
  domains: ['behavioral'],
  icon: Icons.warning_amber,
  color: Color(0xFFFF9800),
  order: 6,
  questions: _rbskBehavioralQuestions,
);

const _rbskBehavioralQuestions = <ScreeningQuestion>[
  ScreeningQuestion(id: 'rbsk_b1', question: 'Has frequent temper tantrums', questionTe: 'తరచుగా కోపం ప్రదర్శిస్తారా?', domain: 'behavioral', domainName: 'Behavioral', domainNameTe: 'ప్రవర్తన'),
  ScreeningQuestion(id: 'rbsk_b2', question: 'Is unusually aggressive towards others', questionTe: 'ఇతరుల పట్ల అసాధారణంగా దూకుడుగా ఉంటారా?', domain: 'behavioral', domainName: 'Behavioral', domainNameTe: 'ప్రవర్తన'),
  ScreeningQuestion(id: 'rbsk_b3', question: 'Shows extreme withdrawal or shyness', questionTe: 'అతిగా ఏకాంతంగా లేదా సిగ్గుగా ఉంటారా?', domain: 'behavioral', domainName: 'Behavioral', domainNameTe: 'ప్రవర్తన'),
  ScreeningQuestion(id: 'rbsk_b4', question: 'Has unusual repetitive behaviors or rituals', questionTe: 'అసాధారణ పునరావృత ప్రవర్తనలు లేదా ఆచారాలు ఉన్నాయా?', domain: 'behavioral', domainName: 'Behavioral', domainNameTe: 'ప్రవర్తన'),
  ScreeningQuestion(id: 'rbsk_b5', question: 'Has difficulty separating from caregiver', questionTe: 'పోషకుడి నుండి వేరు కావడంలో కష్టం ఉందా?', domain: 'behavioral', domainName: 'Behavioral', domainNameTe: 'ప్రవర్తన'),
  ScreeningQuestion(id: 'rbsk_b6', question: 'Shows significant sleep disturbances', questionTe: 'గణనీయమైన నిద్ర సమస్యలు ఉన్నాయా?', domain: 'behavioral', domainName: 'Behavioral', domainNameTe: 'ప్రవర్తన'),
  ScreeningQuestion(id: 'rbsk_b7', question: 'Has excessive fears or anxiety', questionTe: 'అతిగా భయాలు లేదా ఆందోళన ఉందా?', domain: 'behavioral', domainName: 'Behavioral', domainNameTe: 'ప్రవర్తన'),
  ScreeningQuestion(id: 'rbsk_b8', question: 'Engages in self-harming behavior', questionTe: 'తనకు తాను హాని చేసుకునే ప్రవర్తన ఉందా?', domain: 'behavioral', domainName: 'Behavioral', domainNameTe: 'ప్రవర్తన', isRedFlag: true),
  ScreeningQuestion(id: 'rbsk_b9', question: 'Shows regression in previously acquired skills', questionTe: 'ఇంతకు ముందు నేర్చుకున్న నైపుణ్యాలలో తిరోగమనం కనిపిస్తుందా?', domain: 'behavioral', domainName: 'Behavioral', domainNameTe: 'ప్రవర్తన', isRedFlag: true),
  ScreeningQuestion(id: 'rbsk_b10', question: 'Has persistent eating difficulties', questionTe: 'నిరంతర తినడం సమస్యలు ఉన్నాయా?', domain: 'behavioral', domainName: 'Behavioral', domainNameTe: 'ప్రవర్తన'),
];
