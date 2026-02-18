import 'package:flutter/material.dart';
import '../models/screening_tool.dart';

final parentChildConfig = ScreeningToolConfig(
  type: ScreeningToolType.parentChildInteraction,
  id: 'parent_child_interaction',
  name: 'Parent-Child Interaction',
  nameTe: 'తల్లిదండ్రులు-బిడ్డ పరస్పర చర్య',
  description: 'Assesses quality of parent-child interaction - 24 items across 5 domains',
  descriptionTe: 'తల్లిదండ్రులు-బిడ్డ పరస్పర చర్య నాణ్యతను అంచనా వేస్తుంది - 5 రంగాలలో 24 అంశాలు',
  minAgeMonths: 0,
  maxAgeMonths: 72,
  responseFormat: ResponseFormat.yesNo,
  domains: ['responsiveness', 'affection', 'encouragement', 'teaching', 'structure'],
  icon: Icons.family_restroom,
  color: Color(0xFFE91E63),
  order: 8,
  questions: _parentChildQuestions,
);

const _parentChildQuestions = <ScreeningQuestion>[
  // Responsiveness (5 items)
  ScreeningQuestion(id: 'pci_r1', question: 'Does caregiver respond to child\'s vocalizations promptly?', questionTe: 'పోషకుడు బిడ్డ ధ్వనులకు వెంటనే స్పందిస్తారా?', domain: 'responsiveness', domainName: 'Responsiveness', domainNameTe: 'స్పందన'),
  ScreeningQuestion(id: 'pci_r2', question: 'Does caregiver acknowledge child\'s emotions?', questionTe: 'పోషకుడు బిడ్డ భావోద్వేగాలను గుర్తిస్తారా?', domain: 'responsiveness', domainName: 'Responsiveness', domainNameTe: 'స్పందన'),
  ScreeningQuestion(id: 'pci_r3', question: 'Does caregiver comfort child when distressed?', questionTe: 'బిడ్డ బాధలో ఉన్నప్పుడు పోషకుడు ఓదార్చుతారా?', domain: 'responsiveness', domainName: 'Responsiveness', domainNameTe: 'స్పందన'),
  ScreeningQuestion(id: 'pci_r4', question: 'Does caregiver follow child\'s lead in play?', questionTe: 'ఆటలో బిడ్డ నాయకత్వాన్ని పోషకుడు అనుసరిస్తారా?', domain: 'responsiveness', domainName: 'Responsiveness', domainNameTe: 'స్పందన'),
  ScreeningQuestion(id: 'pci_r5', question: 'Does caregiver respond to child\'s needs consistently?', questionTe: 'పోషకుడు బిడ్డ అవసరాలకు స్థిరంగా స్పందిస్తారా?', domain: 'responsiveness', domainName: 'Responsiveness', domainNameTe: 'స్పందన'),

  // Affection (5 items)
  ScreeningQuestion(id: 'pci_a1', question: 'Does caregiver show warmth and affection to child?', questionTe: 'పోషకుడు బిడ్డ పట్ల ప్రేమ మరియు ఆప్యాయత చూపిస్తారా?', domain: 'affection', domainName: 'Affection', domainNameTe: 'ఆప్యాయత'),
  ScreeningQuestion(id: 'pci_a2', question: 'Does caregiver use positive words with child?', questionTe: 'పోషకుడు బిడ్డతో సానుకూల పదాలు వాడతారా?', domain: 'affection', domainName: 'Affection', domainNameTe: 'ఆప్యాయత'),
  ScreeningQuestion(id: 'pci_a3', question: 'Does caregiver hug or hold child affectionately?', questionTe: 'పోషకుడు బిడ్డను ప్రేమగా కౌగిలించుకుంటారా?', domain: 'affection', domainName: 'Affection', domainNameTe: 'ఆప్యాయత'),
  ScreeningQuestion(id: 'pci_a4', question: 'Does caregiver smile at child frequently?', questionTe: 'పోషకుడు బిడ్డ వైపు తరచుగా నవ్వుతారా?', domain: 'affection', domainName: 'Affection', domainNameTe: 'ఆప్యాయత'),
  ScreeningQuestion(id: 'pci_a5', question: 'Does caregiver praise child\'s efforts?', questionTe: 'పోషకుడు బిడ్డ ప్రయత్నాలను మెచ్చుకుంటారా?', domain: 'affection', domainName: 'Affection', domainNameTe: 'ఆప్యాయత'),

  // Encouragement of Exploration (5 items)
  ScreeningQuestion(id: 'pci_ee1', question: 'Does caregiver encourage exploration and play?', questionTe: 'పోషకుడు అన్వేషణ మరియు ఆటను ప్రోత్సహిస్తారా?', domain: 'encouragement', domainName: 'Encouragement', domainNameTe: 'ప్రోత్సాహం'),
  ScreeningQuestion(id: 'pci_ee2', question: 'Does caregiver provide safe space for exploration?', questionTe: 'పోషకుడు అన్వేషణ కోసం సురక్షిత స్థలం అందిస్తారా?', domain: 'encouragement', domainName: 'Encouragement', domainNameTe: 'ప్రోత్సాహం'),
  ScreeningQuestion(id: 'pci_ee3', question: 'Does caregiver allow child to try things independently?', questionTe: 'పోషకుడు బిడ్డను స్వతంత్రంగా ప్రయత్నించనిస్తారా?', domain: 'encouragement', domainName: 'Encouragement', domainNameTe: 'ప్రోత్సాహం'),
  ScreeningQuestion(id: 'pci_ee4', question: 'Does caregiver support child when frustrated?', questionTe: 'బిడ్డ నిరాశగా ఉన్నప్పుడు పోషకుడు మద్దతు ఇస్తారా?', domain: 'encouragement', domainName: 'Encouragement', domainNameTe: 'ప్రోత్సాహం'),
  ScreeningQuestion(id: 'pci_ee5', question: 'Does caregiver celebrate child\'s achievements?', questionTe: 'పోషకుడు బిడ్డ విజయాలను ఆనందిస్తారా?', domain: 'encouragement', domainName: 'Encouragement', domainNameTe: 'ప్రోత్సాహం'),

  // Teaching & Learning (5 items)
  ScreeningQuestion(id: 'pci_t1', question: 'Does caregiver read to child or tell stories?', questionTe: 'పోషకుడు బిడ్డకు పుస్తకం చదువుతారా లేదా కథలు చెప్తారా?', domain: 'teaching', domainName: 'Teaching', domainNameTe: 'బోధన'),
  ScreeningQuestion(id: 'pci_t2', question: 'Does caregiver name objects and describe things?', questionTe: 'పోషకుడు వస్తువుల పేర్లు చెప్పి వివరిస్తారా?', domain: 'teaching', domainName: 'Teaching', domainNameTe: 'బోధన'),
  ScreeningQuestion(id: 'pci_t3', question: 'Does caregiver sing songs or rhymes with child?', questionTe: 'పోషకుడు బిడ్డతో పాటలు లేదా పద్యాలు పాడతారా?', domain: 'teaching', domainName: 'Teaching', domainNameTe: 'బోధన'),
  ScreeningQuestion(id: 'pci_t4', question: 'Does caregiver talk about daily activities with child?', questionTe: 'పోషకుడు రోజువారీ కార్యకలాపాల గురించి బిడ్డతో మాట్లాడతారా?', domain: 'teaching', domainName: 'Teaching', domainNameTe: 'బోధన'),
  ScreeningQuestion(id: 'pci_t5', question: 'Does caregiver count or teach colors/shapes?', questionTe: 'పోషకుడు లెక్కించడం లేదా రంగులు/ఆకారాలు నేర్పిస్తారా?', domain: 'teaching', domainName: 'Teaching', domainNameTe: 'బోధన'),

  // Structure & Routine (4 items)
  ScreeningQuestion(id: 'pci_s1', question: 'Does caregiver maintain daily routines (meals, sleep)?', questionTe: 'పోషకుడు రోజువారీ దినచర్యలను (భోజనం, నిద్ర) నిర్వహిస్తారా?', domain: 'structure', domainName: 'Structure', domainNameTe: 'నిర్మాణం'),
  ScreeningQuestion(id: 'pci_s2', question: 'Does caregiver set appropriate limits?', questionTe: 'పోషకుడు తగిన పరిమితులు ఏర్పాటు చేస్తారా?', domain: 'structure', domainName: 'Structure', domainNameTe: 'నిర్మాణం'),
  ScreeningQuestion(id: 'pci_s3', question: 'Does caregiver spend dedicated time daily with child?', questionTe: 'పోషకుడు రోజువారీ బిడ్డతో ప్రత్యేక సమయం గడుపుతారా?', domain: 'structure', domainName: 'Structure', domainNameTe: 'నిర్మాణం'),
  ScreeningQuestion(id: 'pci_s4', question: 'Does caregiver engage in play with child?', questionTe: 'పోషకుడు బిడ్డతో ఆడుకుంటారా?', domain: 'structure', domainName: 'Structure', domainNameTe: 'నిర్మాణం'),
];
