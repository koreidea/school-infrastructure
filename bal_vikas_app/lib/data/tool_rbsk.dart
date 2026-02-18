import 'package:flutter/material.dart';
import '../models/screening_tool.dart';

const _threePointOptions = [
  ResponseOption(value: 2, label: 'High Extent', labelTe: 'అధిక స్థాయి', color: Color(0xFF4CAF50)),
  ResponseOption(value: 1, label: 'Some Extent', labelTe: 'కొంత స్థాయి', color: Color(0xFFFFC107)),
  ResponseOption(value: 0, label: 'Low Extent', labelTe: 'తక్కువ స్థాయి', color: Color(0xFFF44336)),
];

final rbskConfig = ScreeningToolConfig(
  type: ScreeningToolType.rbskTool,
  id: 'rbsk_tool',
  name: 'RBSK Developmental Tool',
  nameTe: 'RBSK అభివృద్ధి సాధనం',
  description: 'Rashtriya Bal Swasthya Karyakram - 25 items across 5 developmental domains',
  descriptionTe: 'రాష్ట్రీయ బాల్ స్వాస్థ్య కార్యక్రమం - 5 అభివృద్ధి రంగాలలో 25 అంశాలు',
  minAgeMonths: 36,
  maxAgeMonths: 72,
  responseFormat: ResponseFormat.threePoint,
  domains: ['motor', 'cognitive', 'language', 'social', 'adaptive'],
  icon: Icons.medical_services,
  color: Color(0xFF009688),
  order: 2,
  questions: _rbskQuestions,
);

const _rbskQuestions = <ScreeningQuestion>[
  // Motor Domain (5 items)
  ScreeningQuestion(id: 'rbsk_m1', question: 'Can run and stop without losing balance', questionTe: 'సమతుల్యత కోల్పోకుండా పరుగెత్తి ఆపగలరా?', domain: 'motor', domainName: 'Motor Skills', domainNameTe: 'చలన నైపుణ్యాలు', responseOptions: _threePointOptions),
  ScreeningQuestion(id: 'rbsk_m2', question: 'Can climb stairs alternating feet', questionTe: 'అడుగులు మారుస్తూ మెట్లు ఎక్కగలరా?', domain: 'motor', domainName: 'Motor Skills', domainNameTe: 'చలన నైపుణ్యాలు', responseOptions: _threePointOptions),
  ScreeningQuestion(id: 'rbsk_m3', question: 'Can button and unbutton clothes', questionTe: 'బట్టలకు బటన్లు పెట్టగలరా మరియు తీయగలరా?', domain: 'motor', domainName: 'Motor Skills', domainNameTe: 'చలన నైపుణ్యాలు', responseOptions: _threePointOptions),
  ScreeningQuestion(id: 'rbsk_m4', question: 'Can draw recognizable shapes (circle, square)', questionTe: 'గుర్తించగలిగే ఆకారాలు (వృత్తం, చతురస్రం) గీయగలరా?', domain: 'motor', domainName: 'Motor Skills', domainNameTe: 'చలన నైపుణ్యాలు', responseOptions: _threePointOptions),
  ScreeningQuestion(id: 'rbsk_m5', question: 'Can catch and throw a ball', questionTe: 'బంతిని పట్టుకోగలరా మరియు విసరగలరా?', domain: 'motor', domainName: 'Motor Skills', domainNameTe: 'చలన నైపుణ్యాలు', responseOptions: _threePointOptions),

  // Cognitive Domain (5 items)
  ScreeningQuestion(id: 'rbsk_c1', question: 'Can sort objects by color or shape', questionTe: 'రంగు లేదా ఆకారం ప్రకారం వస్తువులను వర్గీకరించగలరా?', domain: 'cognitive', domainName: 'Cognitive', domainNameTe: 'జ్ఞానాత్మకం', responseOptions: _threePointOptions),
  ScreeningQuestion(id: 'rbsk_c2', question: 'Can count up to 10 objects', questionTe: '10 వస్తువుల వరకు లెక్కించగలరా?', domain: 'cognitive', domainName: 'Cognitive', domainNameTe: 'జ్ఞానాత్మకం', responseOptions: _threePointOptions),
  ScreeningQuestion(id: 'rbsk_c3', question: 'Understands concepts of same/different', questionTe: 'ఒకేలా/వేరుగా అనే భావనలు అర్థం చేసుకుంటారా?', domain: 'cognitive', domainName: 'Cognitive', domainNameTe: 'జ్ఞానాత్మకం', responseOptions: _threePointOptions),
  ScreeningQuestion(id: 'rbsk_c4', question: 'Can follow 3-step instructions', questionTe: '3-దశల సూచనలను అనుసరించగలరా?', domain: 'cognitive', domainName: 'Cognitive', domainNameTe: 'జ్ఞానాత్మకం', responseOptions: _threePointOptions),
  ScreeningQuestion(id: 'rbsk_c5', question: 'Shows curiosity and asks questions', questionTe: 'ఉత్సుకత చూపిస్తారా మరియు ప్రశ్నలు అడుగుతారా?', domain: 'cognitive', domainName: 'Cognitive', domainNameTe: 'జ్ఞానాత్మకం', responseOptions: _threePointOptions),

  // Language Domain (5 items)
  ScreeningQuestion(id: 'rbsk_l1', question: 'Speaks in sentences of 4-5 words', questionTe: '4-5 పదాల వాక్యాలలో మాట్లాడతారా?', domain: 'language', domainName: 'Language', domainNameTe: 'భాష', responseOptions: _threePointOptions),
  ScreeningQuestion(id: 'rbsk_l2', question: 'Can tell a simple story', questionTe: 'సాధారణ కథ చెప్పగలరా?', domain: 'language', domainName: 'Language', domainNameTe: 'భాష', responseOptions: _threePointOptions),
  ScreeningQuestion(id: 'rbsk_l3', question: 'Understands and uses prepositions (in, on, under)', questionTe: 'విభక్తులు అర్థం చేసుకుంటారా మరియు వాడతారా (లో, పై, కింద)?', domain: 'language', domainName: 'Language', domainNameTe: 'భాష', responseOptions: _threePointOptions),
  ScreeningQuestion(id: 'rbsk_l4', question: 'Can name familiar objects and pictures', questionTe: 'పరిచిత వస్తువులు మరియు చిత్రాల పేర్లు చెప్పగలరా?', domain: 'language', domainName: 'Language', domainNameTe: 'భాష', responseOptions: _threePointOptions),
  ScreeningQuestion(id: 'rbsk_l5', question: 'Speech is understood by strangers', questionTe: 'అపరిచితులు మాటలు అర్థం చేసుకోగలరా?', domain: 'language', domainName: 'Language', domainNameTe: 'భాష', responseOptions: _threePointOptions),

  // Social Domain (5 items)
  ScreeningQuestion(id: 'rbsk_s1', question: 'Plays cooperatively with other children', questionTe: 'ఇతర పిల్లలతో సహకారంతో ఆడతారా?', domain: 'social', domainName: 'Social', domainNameTe: 'సామాజిక', responseOptions: _threePointOptions),
  ScreeningQuestion(id: 'rbsk_s2', question: 'Shows empathy towards others', questionTe: 'ఇతరుల పట్ల సానుభూతి చూపిస్తారా?', domain: 'social', domainName: 'Social', domainNameTe: 'సామాజిక', responseOptions: _threePointOptions),
  ScreeningQuestion(id: 'rbsk_s3', question: 'Takes turns in activities', questionTe: 'కార్యకలాపాలలో వంతులు తీసుకుంటారా?', domain: 'social', domainName: 'Social', domainNameTe: 'సామాజిక', responseOptions: _threePointOptions),
  ScreeningQuestion(id: 'rbsk_s4', question: 'Expresses feelings with words', questionTe: 'భావాలను మాటలతో వ్యక్తం చేస్తారా?', domain: 'social', domainName: 'Social', domainNameTe: 'సామాజిక', responseOptions: _threePointOptions),
  ScreeningQuestion(id: 'rbsk_s5', question: 'Follows basic social rules', questionTe: 'ప్రాథమిక సామాజిక నియమాలను పాటిస్తారా?', domain: 'social', domainName: 'Social', domainNameTe: 'సామాజిక', responseOptions: _threePointOptions),

  // Adaptive Domain (5 items)
  ScreeningQuestion(id: 'rbsk_a1', question: 'Can feed self independently', questionTe: 'స్వతంత్రంగా తినగలరా?', domain: 'adaptive', domainName: 'Adaptive', domainNameTe: 'అనుకూల', responseOptions: _threePointOptions),
  ScreeningQuestion(id: 'rbsk_a2', question: 'Can use toilet with minimal help', questionTe: 'కనీస సహాయంతో మరుగుదొడ్డి వాడగలరా?', domain: 'adaptive', domainName: 'Adaptive', domainNameTe: 'అనుకూల', responseOptions: _threePointOptions),
  ScreeningQuestion(id: 'rbsk_a3', question: 'Can wash and dry hands', questionTe: 'చేతులు కడిగి ఆరబెట్టుకోగలరా?', domain: 'adaptive', domainName: 'Adaptive', domainNameTe: 'అనుకూల', responseOptions: _threePointOptions),
  ScreeningQuestion(id: 'rbsk_a4', question: 'Can dress/undress with some help', questionTe: 'కొంత సహాయంతో బట్టలు వేసుకో/విప్పగలరా?', domain: 'adaptive', domainName: 'Adaptive', domainNameTe: 'అనుకూల', responseOptions: _threePointOptions),
  ScreeningQuestion(id: 'rbsk_a5', question: 'Shows awareness of danger', questionTe: 'ప్రమాదం పట్ల అవగాహన చూపిస్తారా?', domain: 'adaptive', domainName: 'Adaptive', domainNameTe: 'అనుకూల', responseOptions: _threePointOptions),
];
