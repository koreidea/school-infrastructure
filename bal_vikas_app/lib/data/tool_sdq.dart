import 'package:flutter/material.dart';
import '../models/screening_tool.dart';

const _sdqOptions = [
  ResponseOption(value: 0, label: 'Not True', labelTe: 'నిజం కాదు', color: Color(0xFF4CAF50)),
  ResponseOption(value: 1, label: 'Somewhat True', labelTe: 'కొంత నిజం', color: Color(0xFFFFC107)),
  ResponseOption(value: 2, label: 'Certainly True', labelTe: 'ఖచ్చితంగా నిజం', color: Color(0xFFF44336)),
];

final sdqConfig = ScreeningToolConfig(
  type: ScreeningToolType.sdqBehavioral,
  id: 'sdq_behavioral',
  name: 'SDQ Behavioral Assessment',
  nameTe: 'SDQ ప్రవర్తన అంచనా',
  description: 'Strengths and Difficulties Questionnaire - 25 items + 8 impact items across 5 subscales',
  descriptionTe: 'బలాలు మరియు కష్టాల ప్రశ్నాపత్రం - 5 ఉపమానాలలో 25 అంశాలు + 8 ప్రభావ అంశాలు',
  minAgeMonths: 24,
  maxAgeMonths: 72,
  responseFormat: ResponseFormat.threePoint,
  domains: ['emotional', 'conduct', 'hyperactivity', 'peer', 'prosocial'],
  icon: Icons.balance,
  color: Color(0xFF795548),
  order: 7,
  questions: _sdqQuestions,
);

const _sdqQuestions = <ScreeningQuestion>[
  // Emotional Symptoms (5 items)
  ScreeningQuestion(id: 'sdq_e1', question: 'Often complains of headaches, stomach-aches or sickness', questionTe: 'తరచుగా తలనొప్పి, కడుపునొప్పి లేదా అనారోగ్యం గురించి ఫిర్యాదు చేస్తారు', domain: 'emotional', domainName: 'Emotional Symptoms', domainNameTe: 'భావోద్వేగ లక్షణాలు', responseOptions: _sdqOptions),
  ScreeningQuestion(id: 'sdq_e2', question: 'Has many worries, often seems worried', questionTe: 'చాలా ఆందోళనలు ఉన్నాయి, తరచుగా ఆందోళనగా కనిపిస్తారు', domain: 'emotional', domainName: 'Emotional Symptoms', domainNameTe: 'భావోద్వేగ లక్షణాలు', responseOptions: _sdqOptions),
  ScreeningQuestion(id: 'sdq_e3', question: 'Often unhappy, down-hearted or tearful', questionTe: 'తరచుగా అసంతృప్తిగా, నిరాశగా లేదా కన్నీళ్ళతో ఉంటారు', domain: 'emotional', domainName: 'Emotional Symptoms', domainNameTe: 'భావోద్వేగ లక్షణాలు', responseOptions: _sdqOptions),
  ScreeningQuestion(id: 'sdq_e4', question: 'Nervous or clingy in new situations', questionTe: 'కొత్త పరిస్థితులలో నాడీగా లేదా అతుక్కుపోతారు', domain: 'emotional', domainName: 'Emotional Symptoms', domainNameTe: 'భావోద్వేగ లక్షణాలు', responseOptions: _sdqOptions),
  ScreeningQuestion(id: 'sdq_e5', question: 'Many fears, easily scared', questionTe: 'చాలా భయాలు, సులభంగా భయపడతారు', domain: 'emotional', domainName: 'Emotional Symptoms', domainNameTe: 'భావోద్వేగ లక్షణాలు', responseOptions: _sdqOptions),

  // Conduct Problems (5 items)
  ScreeningQuestion(id: 'sdq_c1', question: 'Often has temper tantrums or hot tempers', questionTe: 'తరచుగా కోపం ప్రదర్శిస్తారు లేదా చిటపటలాడతారు', domain: 'conduct', domainName: 'Conduct Problems', domainNameTe: 'ప్రవర్తన సమస్యలు', responseOptions: _sdqOptions),
  ScreeningQuestion(id: 'sdq_c2', question: 'Generally obedient, usually does what adults request', questionTe: 'సాధారణంగా విధేయులు, పెద్దలు కోరినది చేస్తారు', domain: 'conduct', domainName: 'Conduct Problems', domainNameTe: 'ప్రవర్తన సమస్యలు', responseOptions: _sdqOptions, isReverseScored: true),
  ScreeningQuestion(id: 'sdq_c3', question: 'Often fights with other children or bullies them', questionTe: 'తరచుగా ఇతర పిల్లలతో గొడవ చేస్తారు లేదా వారిని బెదిరిస్తారు', domain: 'conduct', domainName: 'Conduct Problems', domainNameTe: 'ప్రవర్తన సమస్యలు', responseOptions: _sdqOptions),
  ScreeningQuestion(id: 'sdq_c4', question: 'Often lies or cheats', questionTe: 'తరచుగా అబద్ధాలు చెప్తారు లేదా మోసం చేస్తారు', domain: 'conduct', domainName: 'Conduct Problems', domainNameTe: 'ప్రవర్తన సమస్యలు', responseOptions: _sdqOptions),
  ScreeningQuestion(id: 'sdq_c5', question: 'Steals from home, school or elsewhere', questionTe: 'ఇంటి నుండి, పాఠశాల నుండి లేదా ఇతర చోట్ల దొంగిలిస్తారు', domain: 'conduct', domainName: 'Conduct Problems', domainNameTe: 'ప్రవర్తన సమస్యలు', responseOptions: _sdqOptions),

  // Hyperactivity/Inattention (5 items)
  ScreeningQuestion(id: 'sdq_h1', question: 'Restless, overactive, cannot stay still for long', questionTe: 'అశాంతిగా, అతి చురుకుగా, ఎక్కువ సేపు నిలబడలేరు', domain: 'hyperactivity', domainName: 'Hyperactivity', domainNameTe: 'అతి చురుకుదనం', responseOptions: _sdqOptions),
  ScreeningQuestion(id: 'sdq_h2', question: 'Constantly fidgeting or squirming', questionTe: 'నిరంతరం కదులుతూ ఉంటారు', domain: 'hyperactivity', domainName: 'Hyperactivity', domainNameTe: 'అతి చురుకుదనం', responseOptions: _sdqOptions),
  ScreeningQuestion(id: 'sdq_h3', question: 'Easily distracted, concentration wanders', questionTe: 'సులభంగా దృష్టి మళ్ళుతుంది, ఏకాగ్రత తగ్గుతుంది', domain: 'hyperactivity', domainName: 'Hyperactivity', domainNameTe: 'అతి చురుకుదనం', responseOptions: _sdqOptions),
  ScreeningQuestion(id: 'sdq_h4', question: 'Thinks things out before acting', questionTe: 'చేయడానికి ముందు ఆలోచిస్తారు', domain: 'hyperactivity', domainName: 'Hyperactivity', domainNameTe: 'అతి చురుకుదనం', responseOptions: _sdqOptions, isReverseScored: true),
  ScreeningQuestion(id: 'sdq_h5', question: 'Sees tasks through to the end, good attention span', questionTe: 'పనులను చివరి వరకు చేస్తారు, మంచి శ్రద్ధ', domain: 'hyperactivity', domainName: 'Hyperactivity', domainNameTe: 'అతి చురుకుదనం', responseOptions: _sdqOptions, isReverseScored: true),

  // Peer Relationship Problems (5 items)
  ScreeningQuestion(id: 'sdq_p1', question: 'Rather solitary, tends to play alone', questionTe: 'ఏకాంతంగా, ఒంటరిగా ఆడటానికి ఇష్టపడతారు', domain: 'peer', domainName: 'Peer Problems', domainNameTe: 'తోటివారి సమస్యలు', responseOptions: _sdqOptions),
  ScreeningQuestion(id: 'sdq_p2', question: 'Has at least one good friend', questionTe: 'కనీసం ఒక మంచి స్నేహితుడు ఉన్నారు', domain: 'peer', domainName: 'Peer Problems', domainNameTe: 'తోటివారి సమస్యలు', responseOptions: _sdqOptions, isReverseScored: true),
  ScreeningQuestion(id: 'sdq_p3', question: 'Generally liked by other children', questionTe: 'సాధారణంగా ఇతర పిల్లలు ఇష్టపడతారు', domain: 'peer', domainName: 'Peer Problems', domainNameTe: 'తోటివారి సమస్యలు', responseOptions: _sdqOptions, isReverseScored: true),
  ScreeningQuestion(id: 'sdq_p4', question: 'Picked on or bullied by other children', questionTe: 'ఇతర పిల్లలు ఎగతాళి చేస్తారు లేదా బెదిరిస్తారు', domain: 'peer', domainName: 'Peer Problems', domainNameTe: 'తోటివారి సమస్యలు', responseOptions: _sdqOptions),
  ScreeningQuestion(id: 'sdq_p5', question: 'Gets on better with adults than with other children', questionTe: 'ఇతర పిల్లల కంటే పెద్దలతో బాగా కలిసిపోతారు', domain: 'peer', domainName: 'Peer Problems', domainNameTe: 'తోటివారి సమస్యలు', responseOptions: _sdqOptions),

  // Prosocial Behavior (5 items)
  ScreeningQuestion(id: 'sdq_ps1', question: 'Considerate of other people\'s feelings', questionTe: 'ఇతరుల భావాలను పరిగణిస్తారు', domain: 'prosocial', domainName: 'Prosocial Behavior', domainNameTe: 'ప్రోసోషల్ ప్రవర్తన', responseOptions: _sdqOptions),
  ScreeningQuestion(id: 'sdq_ps2', question: 'Shares readily with other children', questionTe: 'ఇతర పిల్లలతో సులభంగా పంచుకుంటారు', domain: 'prosocial', domainName: 'Prosocial Behavior', domainNameTe: 'ప్రోసోషల్ ప్రవర్తన', responseOptions: _sdqOptions),
  ScreeningQuestion(id: 'sdq_ps3', question: 'Helpful if someone is hurt, upset or feeling ill', questionTe: 'ఎవరైనా గాయపడితే, బాధపడితే లేదా అనారోగ్యంగా ఉంటే సహాయం చేస్తారు', domain: 'prosocial', domainName: 'Prosocial Behavior', domainNameTe: 'ప్రోసోషల్ ప్రవర్తన', responseOptions: _sdqOptions),
  ScreeningQuestion(id: 'sdq_ps4', question: 'Kind to younger children', questionTe: 'చిన్న పిల్లల పట్ల దయగా ఉంటారు', domain: 'prosocial', domainName: 'Prosocial Behavior', domainNameTe: 'ప్రోసోషల్ ప్రవర్తన', responseOptions: _sdqOptions),
  ScreeningQuestion(id: 'sdq_ps5', question: 'Often volunteers to help others', questionTe: 'తరచుగా ఇతరులకు సహాయం చేయడానికి ముందుకు వస్తారు', domain: 'prosocial', domainName: 'Prosocial Behavior', domainNameTe: 'ప్రోసోషల్ ప్రవర్తన', responseOptions: _sdqOptions),

  // Impact Supplement (8 items)
  ScreeningQuestion(id: 'sdq_i1', question: 'Overall, do you think your child has difficulties in emotions, concentration, behavior, or being able to get on with other people?', questionTe: 'మొత్తంగా, మీ బిడ్డకు భావోద్వేగాలు, ఏకాగ్రత, ప్రవర్తన లేదా ఇతరులతో కలిసి ఉండటంలో కష్టాలు ఉన్నాయా?', domain: 'impact', domainName: 'Impact', domainNameTe: 'ప్రభావం', category: 'Impact', categoryTe: 'ప్రభావం', responseOptions: _sdqOptions),
  ScreeningQuestion(id: 'sdq_i2', question: 'Do the difficulties upset or distress your child?', questionTe: 'ఈ కష్టాలు మీ బిడ్డను బాధపెడుతున్నాయా?', domain: 'impact', domainName: 'Impact', domainNameTe: 'ప్రభావం', responseOptions: _sdqOptions),
  ScreeningQuestion(id: 'sdq_i3', question: 'Do the difficulties interfere with child\'s everyday life at home?', questionTe: 'ఈ కష్టాలు ఇంట్లో బిడ్డ రోజువారీ జీవితాన్ని ప్రభావితం చేస్తున్నాయా?', domain: 'impact', domainName: 'Impact', domainNameTe: 'ప్రభావం', responseOptions: _sdqOptions),
  ScreeningQuestion(id: 'sdq_i4', question: 'Do the difficulties interfere with friendships?', questionTe: 'ఈ కష్టాలు స్నేహాలను ప్రభావితం చేస్తున్నాయా?', domain: 'impact', domainName: 'Impact', domainNameTe: 'ప్రభావం', responseOptions: _sdqOptions),
  ScreeningQuestion(id: 'sdq_i5', question: 'Do the difficulties interfere with classroom learning?', questionTe: 'ఈ కష్టాలు తరగతి గది అభ్యాసాన్ని ప్రభావితం చేస్తున్నాయా?', domain: 'impact', domainName: 'Impact', domainNameTe: 'ప్రభావం', responseOptions: _sdqOptions),
  ScreeningQuestion(id: 'sdq_i6', question: 'Do the difficulties interfere with leisure activities?', questionTe: 'ఈ కష్టాలు వినోద కార్యకలాపాలను ప్రభావితం చేస్తున్నాయా?', domain: 'impact', domainName: 'Impact', domainNameTe: 'ప్రభావం', responseOptions: _sdqOptions),
  ScreeningQuestion(id: 'sdq_i7', question: 'Do the difficulties put a burden on you or the family?', questionTe: 'ఈ కష్టాలు మీపై లేదా కుటుంబంపై భారం మోపుతున్నాయా?', domain: 'impact', domainName: 'Impact', domainNameTe: 'ప్రభావం', responseOptions: _sdqOptions),
  ScreeningQuestion(id: 'sdq_i8', question: 'Have the difficulties been going on for more than a month?', questionTe: 'ఈ కష్టాలు ఒక నెల కంటే ఎక్కువ కాలంగా ఉన్నాయా?', domain: 'impact', domainName: 'Impact', domainNameTe: 'ప్రభావం', responseOptions: _sdqOptions),
];
