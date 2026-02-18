import 'package:flutter/material.dart';
import '../models/screening_tool.dart';

final mchatConfig = ScreeningToolConfig(
  type: ScreeningToolType.mchatAutism,
  id: 'mchat_autism',
  name: 'M-CHAT Autism Screening',
  nameTe: 'M-CHAT ఆటిజం స్క్రీనింగ్',
  description: 'Modified Checklist for Autism in Toddlers - 20 items with 6 critical items',
  descriptionTe: 'చిన్న పిల్లలలో ఆటిజం కోసం సవరించిన చెక్‌లిస్ట్ - 6 క్లిష్టమైన అంశాలతో 20 అంశాలు',
  minAgeMonths: 16,
  maxAgeMonths: 30,
  responseFormat: ResponseFormat.yesNo,
  domains: ['autism_risk'],
  icon: Icons.psychology,
  color: Color(0xFF9C27B0),
  order: 3,
  questions: _mchatQuestions,
);

const _mchatQuestions = <ScreeningQuestion>[
  ScreeningQuestion(id: 'mchat_1', question: 'Does your child enjoy being swung, bounced on your knee, etc.?', questionTe: 'మీ బిడ్డ ఊపడం, మోకాలిపై ఎగరడం వంటివి ఆనందిస్తారా?', domain: 'autism_risk'),
  ScreeningQuestion(id: 'mchat_2', question: 'Does your child take an interest in other children?', questionTe: 'మీ బిడ్డ ఇతర పిల్లలపై ఆసక్తి చూపిస్తారా?', domain: 'autism_risk', isCritical: true),
  ScreeningQuestion(id: 'mchat_3', question: 'Does your child like climbing on things, such as stairs?', questionTe: 'మీ బిడ్డ మెట్లు వంటి వాటిపై ఎక్కడం ఇష్టపడతారా?', domain: 'autism_risk'),
  ScreeningQuestion(id: 'mchat_4', question: 'Does your child enjoy playing peek-a-boo/hide-and-seek?', questionTe: 'మీ బిడ్డ దాగుడుమూతలు ఆడటం ఆనందిస్తారా?', domain: 'autism_risk'),
  ScreeningQuestion(id: 'mchat_5', question: 'Does your child ever pretend, for example, to talk on phone or take care of a doll?', questionTe: 'మీ బిడ్డ ఎప్పుడైనా నటిస్తారా, ఉదాహరణకు ఫోన్‌లో మాట్లాడటం లేదా బొమ్మను చూసుకోవడం?', domain: 'autism_risk'),
  ScreeningQuestion(id: 'mchat_6', question: 'Does your child ever use his/her index finger to point, to ask for something?', questionTe: 'మీ బిడ్డ ఏదైనా అడగడానికి చూపుడు వేలుతో చూపిస్తారా?', domain: 'autism_risk'),
  ScreeningQuestion(id: 'mchat_7', question: 'Does your child ever use his/her index finger to point, to indicate interest?', questionTe: 'మీ బిడ్డ ఆసక్తి చూపించడానికి చూపుడు వేలుతో చూపిస్తారా?', domain: 'autism_risk', isCritical: true),
  ScreeningQuestion(id: 'mchat_8', question: 'Can your child play properly with small toys without mouthing, fiddling, or dropping them?', questionTe: 'మీ బిడ్డ చిన్న బొమ్మలతో నోటిలో పెట్టకుండా, విరిచిపెట్టకుండా సరిగ్గా ఆడగలరా?', domain: 'autism_risk'),
  ScreeningQuestion(id: 'mchat_9', question: 'Does your child ever bring objects over to you to show you?', questionTe: 'మీ బిడ్డ ఎప్పుడైనా మీకు చూపించడానికి వస్తువులు తీసుకొస్తారా?', domain: 'autism_risk', isCritical: true),
  ScreeningQuestion(id: 'mchat_10', question: 'Does your child look at you in the eye for more than a second or two?', questionTe: 'మీ బిడ్డ ఒకటి లేదా రెండు సెకన్ల కంటే ఎక్కువ సేపు మీ కళ్ళలోకి చూస్తారా?', domain: 'autism_risk'),
  ScreeningQuestion(id: 'mchat_11', question: 'Does your child ever seem oversensitive to noise?', questionTe: 'మీ బిడ్డ ఎప్పుడైనా శబ్దానికి అతిగా సున్నితంగా కనిపిస్తారా?', domain: 'autism_risk'),
  ScreeningQuestion(id: 'mchat_12', question: 'Does your child smile in response to your face or your smile?', questionTe: 'మీ ముఖం లేదా మీ నవ్వుకు స్పందనగా మీ బిడ్డ నవ్వుతారా?', domain: 'autism_risk'),
  ScreeningQuestion(id: 'mchat_13', question: 'Does your child imitate you (e.g., face expression)?', questionTe: 'మీ బిడ్డ మిమ్మల్ని అనుకరిస్తారా (ఉదా: ముఖ భావాలు)?', domain: 'autism_risk', isCritical: true),
  ScreeningQuestion(id: 'mchat_14', question: 'Does your child respond to his/her name when called?', questionTe: 'పేరు పిలిచినప్పుడు మీ బిడ్డ స్పందిస్తారా?', domain: 'autism_risk', isCritical: true),
  ScreeningQuestion(id: 'mchat_15', question: 'If you point at a toy across the room, does your child look at it?', questionTe: 'గది అవతల బొమ్మను చూపిస్తే, మీ బిడ్డ దాన్ని చూస్తారా?', domain: 'autism_risk', isCritical: true),
  ScreeningQuestion(id: 'mchat_16', question: 'Does your child walk?', questionTe: 'మీ బిడ్డ నడవగలరా?', domain: 'autism_risk'),
  ScreeningQuestion(id: 'mchat_17', question: 'Does your child look at things you are looking at?', questionTe: 'మీరు చూస్తున్న వస్తువులను మీ బిడ్డ చూస్తారా?', domain: 'autism_risk'),
  ScreeningQuestion(id: 'mchat_18', question: 'Does your child make unusual finger movements near his/her face?', questionTe: 'మీ బిడ్డ ముఖం దగ్గర అసాధారణ వేలు కదలికలు చేస్తారా?', domain: 'autism_risk'),
  ScreeningQuestion(id: 'mchat_19', question: 'Does your child try to attract your attention to his/her own activity?', questionTe: 'మీ బిడ్డ తన కార్యకలాపంపై మీ దృష్టిని ఆకర్షించడానికి ప్రయత్నిస్తారా?', domain: 'autism_risk'),
  ScreeningQuestion(id: 'mchat_20', question: 'Have you ever wondered if your child is deaf?', questionTe: 'మీ బిడ్డ చెవిటివాడేమో అని మీకు ఎప్పుడైనా అనుమానం వచ్చిందా?', domain: 'autism_risk'),
];
