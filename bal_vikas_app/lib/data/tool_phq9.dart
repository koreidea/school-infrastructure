import 'package:flutter/material.dart';
import '../models/screening_tool.dart';

const _phq9Options = [
  ResponseOption(value: 0, label: 'Not at all', labelTe: 'అస్సలు కాదు', color: Color(0xFF4CAF50)),
  ResponseOption(value: 1, label: 'Several days', labelTe: 'కొన్ని రోజులు', color: Color(0xFF8BC34A)),
  ResponseOption(value: 2, label: 'More than half the days', labelTe: 'సగానికి పైగా రోజులు', color: Color(0xFFFF9800)),
  ResponseOption(value: 3, label: 'Nearly every day', labelTe: 'దాదాపు ప్రతిరోజూ', color: Color(0xFFF44336)),
];

final phq9Config = ScreeningToolConfig(
  type: ScreeningToolType.parentMentalHealth,
  id: 'phq9_parent',
  name: 'Parent Mental Health (PHQ-9)',
  nameTe: 'తల్లిదండ్రుల మానసిక ఆరోగ్యం (PHQ-9)',
  description: 'Patient Health Questionnaire-9 for caregiver depression screening (score range 0-27)',
  descriptionTe: 'పోషకుడి నిరాశ స్క్రీనింగ్ కోసం రోగి ఆరోగ్య ప్రశ్నాపత్రం-9 (స్కోర్ పరిధి 0-27)',
  minAgeMonths: 0,
  maxAgeMonths: 72,
  responseFormat: ResponseFormat.fourPoint,
  domains: ['depression'],
  icon: Icons.favorite_border,
  color: Color(0xFF607D8B),
  order: 9,
  questions: _phq9Questions,
);

const _phq9Questions = <ScreeningQuestion>[
  ScreeningQuestion(id: 'phq_1', question: 'Little interest or pleasure in doing things', questionTe: 'పనులు చేయడంలో తక్కువ ఆసక్తి లేదా ఆనందం', domain: 'depression', domainName: 'Depression', domainNameTe: 'నిరాశ', category: 'Over the last 2 weeks', categoryTe: 'గత 2 వారాలలో', responseOptions: _phq9Options),
  ScreeningQuestion(id: 'phq_2', question: 'Feeling down, depressed, or hopeless', questionTe: 'నిరాశగా, డిప్రెషన్‌గా లేదా నిరాశగా అనిపించడం', domain: 'depression', domainName: 'Depression', domainNameTe: 'నిరాశ', category: 'Over the last 2 weeks', categoryTe: 'గత 2 వారాలలో', responseOptions: _phq9Options),
  ScreeningQuestion(id: 'phq_3', question: 'Trouble falling or staying asleep, or sleeping too much', questionTe: 'నిద్ర పట్టకపోవడం లేదా ఎక్కువగా నిద్రపోవడం', domain: 'depression', domainName: 'Depression', domainNameTe: 'నిరాశ', category: 'Over the last 2 weeks', categoryTe: 'గత 2 వారాలలో', responseOptions: _phq9Options),
  ScreeningQuestion(id: 'phq_4', question: 'Feeling tired or having little energy', questionTe: 'అలసటగా అనిపించడం లేదా తక్కువ శక్తి', domain: 'depression', domainName: 'Depression', domainNameTe: 'నిరాశ', category: 'Over the last 2 weeks', categoryTe: 'గత 2 వారాలలో', responseOptions: _phq9Options),
  ScreeningQuestion(id: 'phq_5', question: 'Poor appetite or overeating', questionTe: 'తక్కువ ఆకలి లేదా ఎక్కువగా తినడం', domain: 'depression', domainName: 'Depression', domainNameTe: 'నిరాశ', category: 'Over the last 2 weeks', categoryTe: 'గత 2 వారాలలో', responseOptions: _phq9Options),
  ScreeningQuestion(id: 'phq_6', question: 'Feeling bad about yourself — or that you are a failure', questionTe: 'మీ గురించి చెడుగా అనిపించడం — లేదా మీరు విఫలమయ్యారని', domain: 'depression', domainName: 'Depression', domainNameTe: 'నిరాశ', category: 'Over the last 2 weeks', categoryTe: 'గత 2 వారాలలో', responseOptions: _phq9Options),
  ScreeningQuestion(id: 'phq_7', question: 'Trouble concentrating on things, such as reading or watching television', questionTe: 'పుస్తకం చదవడం లేదా టీవీ చూడడం వంటి పనులపై ఏకాగ్రత కుదరకపోవడం', domain: 'depression', domainName: 'Depression', domainNameTe: 'నిరాశ', category: 'Over the last 2 weeks', categoryTe: 'గత 2 వారాలలో', responseOptions: _phq9Options),
  ScreeningQuestion(id: 'phq_8', question: 'Moving or speaking so slowly that other people noticed — or being fidgety or restless', questionTe: 'ఇతరులు గమనించేంత నెమ్మదిగా కదలడం/మాట్లాడటం — లేదా అశాంతిగా ఉండటం', domain: 'depression', domainName: 'Depression', domainNameTe: 'నిరాశ', category: 'Over the last 2 weeks', categoryTe: 'గత 2 వారాలలో', responseOptions: _phq9Options),
  ScreeningQuestion(id: 'phq_9', question: 'Thoughts that you would be better off dead, or of hurting yourself', questionTe: 'మీరు చనిపోతే మంచిదని లేదా మిమ్మల్ని మీరు హాని చేసుకోవాలని ఆలోచనలు', domain: 'depression', domainName: 'Depression', domainNameTe: 'నిరాశ', category: 'Over the last 2 weeks', categoryTe: 'గత 2 వారాలలో', responseOptions: _phq9Options, isRedFlag: true),
  ScreeningQuestion(id: 'phq_10', question: 'If you checked off any problems, how difficult have these problems made it for you to do your work, take care of things at home, or get along with other people?', questionTe: 'మీరు ఏవైనా సమస్యలను గుర్తించినట్లయితే, ఈ సమస్యలు మీ పనులు చేయడం, ఇంటి విషయాలు చూసుకోవడం లేదా ఇతరులతో కలిసి ఉండటం ఎంత కష్టమైంది?', domain: 'depression', domainName: 'Depression', domainNameTe: 'నిరాశ', category: 'Functional Impact', categoryTe: 'కార్యాచరణ ప్రభావం', responseOptions: _phq9Options),
];
