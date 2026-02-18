import 'package:flutter/material.dart';
import '../models/screening_tool.dart';

const _fivePointOptions = [
  ResponseOption(value: 1, label: 'Rarely', labelTe: 'అరుదుగా', color: Color(0xFF4CAF50)),
  ResponseOption(value: 2, label: 'Sometimes', labelTe: 'కొన్నిసార్లు', color: Color(0xFF8BC34A)),
  ResponseOption(value: 3, label: 'Frequently', labelTe: 'తరచుగా', color: Color(0xFFFFC107)),
  ResponseOption(value: 4, label: 'Mostly', labelTe: 'చాలా వరకు', color: Color(0xFFFF9800)),
  ResponseOption(value: 5, label: 'Always', labelTe: 'ఎల్లప్పుడూ', color: Color(0xFFF44336)),
];

final isaaConfig = ScreeningToolConfig(
  type: ScreeningToolType.isaaAutism,
  id: 'isaa_autism',
  name: 'ISAA Autism Assessment',
  nameTe: 'ISAA ఆటిజం అంచనా',
  description: 'Indian Scale for Assessment of Autism - 40 items across 6 domains (score range 40-200)',
  descriptionTe: 'ఆటిజం అంచనా కోసం భారతీయ స్కేల్ - 6 రంగాలలో 40 అంశాలు (స్కోర్ పరిధి 40-200)',
  minAgeMonths: 36,
  maxAgeMonths: 72,
  responseFormat: ResponseFormat.fivePoint,
  domains: ['social', 'emotional', 'behavior', 'communication', 'sensory', 'cognitive'],
  icon: Icons.psychology_alt,
  color: Color(0xFF673AB7),
  order: 4,
  questions: _isaaQuestions,
);

const _isaaQuestions = <ScreeningQuestion>[
  // Social Relationship & Reciprocity (10 items)
  ScreeningQuestion(id: 'isaa_s1', question: 'Has poor eye contact', questionTe: 'కంటి సంబంధం బలహీనంగా ఉంది', domain: 'social', domainName: 'Social Relationship', domainNameTe: 'సామాజిక సంబంధం', responseOptions: _fivePointOptions),
  ScreeningQuestion(id: 'isaa_s2', question: 'Lacks social smile', questionTe: 'సామాజిక నవ్వు లేదు', domain: 'social', domainName: 'Social Relationship', domainNameTe: 'సామాజిక సంబంధం', responseOptions: _fivePointOptions),
  ScreeningQuestion(id: 'isaa_s3', question: 'Remains aloof', questionTe: 'దూరంగా ఉంటారు', domain: 'social', domainName: 'Social Relationship', domainNameTe: 'సామాజిక సంబంధం', responseOptions: _fivePointOptions),
  ScreeningQuestion(id: 'isaa_s4', question: 'Does not reach out to others', questionTe: 'ఇతరుల వద్దకు వెళ్ళరు', domain: 'social', domainName: 'Social Relationship', domainNameTe: 'సామాజిక సంబంధం', responseOptions: _fivePointOptions),
  ScreeningQuestion(id: 'isaa_s5', question: 'Unable to relate to people', questionTe: 'వ్యక్తులతో సంబంధం పెట్టుకోలేరు', domain: 'social', domainName: 'Social Relationship', domainNameTe: 'సామాజిక సంబంధం', responseOptions: _fivePointOptions),
  ScreeningQuestion(id: 'isaa_s6', question: 'Unable to respond to social/environmental cues', questionTe: 'సామాజిక/పర్యావరణ సంకేతాలకు స్పందించలేరు', domain: 'social', domainName: 'Social Relationship', domainNameTe: 'సామాజిక సంబంధం', responseOptions: _fivePointOptions),
  ScreeningQuestion(id: 'isaa_s7', question: 'Engages in solitary and repetitive play activities', questionTe: 'ఏకాంత మరియు పునరావృత ఆట కార్యకలాపాలలో పాల్గొంటారు', domain: 'social', domainName: 'Social Relationship', domainNameTe: 'సామాజిక సంబంధం', responseOptions: _fivePointOptions),
  ScreeningQuestion(id: 'isaa_s8', question: 'Unable to take turns in social interaction', questionTe: 'సామాజిక సంభాషణలో వంతులు తీసుకోలేరు', domain: 'social', domainName: 'Social Relationship', domainNameTe: 'సామాజిక సంబంధం', responseOptions: _fivePointOptions),
  ScreeningQuestion(id: 'isaa_s9', question: 'Does not maintain peer relationships', questionTe: 'తోటివారి సంబంధాలు నిర్వహించలేరు', domain: 'social', domainName: 'Social Relationship', domainNameTe: 'సామాజిక సంబంధం', responseOptions: _fivePointOptions),
  ScreeningQuestion(id: 'isaa_s10', question: 'Shows no attachment to caregiver', questionTe: 'పోషకుడి పట్ల అనుబంధం చూపించరు', domain: 'social', domainName: 'Social Relationship', domainNameTe: 'సామాజిక సంబంధం', responseOptions: _fivePointOptions),

  // Emotional Responsiveness (6 items)
  ScreeningQuestion(id: 'isaa_e1', question: 'Shows inappropriate emotional response', questionTe: 'అనుచితమైన భావోద్వేగ స్పందన చూపిస్తారు', domain: 'emotional', domainName: 'Emotional Responsiveness', domainNameTe: 'భావోద్వేగ స్పందన', responseOptions: _fivePointOptions),
  ScreeningQuestion(id: 'isaa_e2', question: 'Shows exaggerated emotions', questionTe: 'అతిశయోక్తి భావోద్వేగాలు చూపిస్తారు', domain: 'emotional', domainName: 'Emotional Responsiveness', domainNameTe: 'భావోద్వేగ స్పందన', responseOptions: _fivePointOptions),
  ScreeningQuestion(id: 'isaa_e3', question: 'Engages in self-stimulating emotions', questionTe: 'స్వీయ-ఉద్దీపన భావోద్వేగాలలో పాల్గొంటారు', domain: 'emotional', domainName: 'Emotional Responsiveness', domainNameTe: 'భావోద్వేగ స్పందన', responseOptions: _fivePointOptions),
  ScreeningQuestion(id: 'isaa_e4', question: 'Lacks fear of danger', questionTe: 'ప్రమాదం పట్ల భయం లేదు', domain: 'emotional', domainName: 'Emotional Responsiveness', domainNameTe: 'భావోద్వేగ స్పందన', responseOptions: _fivePointOptions),
  ScreeningQuestion(id: 'isaa_e5', question: 'Excited or agitated for no apparent reason', questionTe: 'స్పష్టమైన కారణం లేకుండా ఉత్సాహంగా లేదా ఆందోళనగా ఉంటారు', domain: 'emotional', domainName: 'Emotional Responsiveness', domainNameTe: 'భావోద్వేగ స్పందన', responseOptions: _fivePointOptions),
  ScreeningQuestion(id: 'isaa_e6', question: 'Has flat/inappropriate affect', questionTe: 'చదునైన/అనుచితమైన భావప్రకటన ఉంది', domain: 'emotional', domainName: 'Emotional Responsiveness', domainNameTe: 'భావోద్వేగ స్పందన', responseOptions: _fivePointOptions),

  // Speech, Language & Communication (7 items)
  ScreeningQuestion(id: 'isaa_c1', question: 'Acquired speech and lost it', questionTe: 'మాట నేర్చుకుని కోల్పోయారు', domain: 'communication', domainName: 'Speech & Communication', domainNameTe: 'మాట & సంభాషణ', responseOptions: _fivePointOptions),
  ScreeningQuestion(id: 'isaa_c2', question: 'Has difficulty in using non-verbal language/gestures', questionTe: 'అశాబ్దిక భాష/సైగలు వాడటంలో కష్టం', domain: 'communication', domainName: 'Speech & Communication', domainNameTe: 'మాట & సంభాషణ', responseOptions: _fivePointOptions),
  ScreeningQuestion(id: 'isaa_c3', question: 'Echoes words or sentences', questionTe: 'పదాలు లేదా వాక్యాలు ప్రతిధ్వనిస్తారు', domain: 'communication', domainName: 'Speech & Communication', domainNameTe: 'మాట & సంభాషణ', responseOptions: _fivePointOptions),
  ScreeningQuestion(id: 'isaa_c4', question: 'Produces infantile squeals or unusual noises', questionTe: 'శిశు కీచు శబ్దాలు లేదా అసాధారణ శబ్దాలు చేస్తారు', domain: 'communication', domainName: 'Speech & Communication', domainNameTe: 'మాట & సంభాషణ', responseOptions: _fivePointOptions),
  ScreeningQuestion(id: 'isaa_c5', question: 'Unable to initiate or sustain conversation', questionTe: 'సంభాషణ ప్రారంభించడం లేదా కొనసాగించడం చేయలేరు', domain: 'communication', domainName: 'Speech & Communication', domainNameTe: 'మాట & సంభాషణ', responseOptions: _fivePointOptions),
  ScreeningQuestion(id: 'isaa_c6', question: 'Uses jargon or meaningless words', questionTe: 'అర్థంలేని పదాలు లేదా పరిభాష వాడతారు', domain: 'communication', domainName: 'Speech & Communication', domainNameTe: 'మాట & సంభాషణ', responseOptions: _fivePointOptions),
  ScreeningQuestion(id: 'isaa_c7', question: 'Uses pronoun reversals', questionTe: 'సర్వనామాలను తారుమారు చేసి వాడతారు', domain: 'communication', domainName: 'Speech & Communication', domainNameTe: 'మాట & సంభాషణ', responseOptions: _fivePointOptions),

  // Behavior Patterns (8 items)
  ScreeningQuestion(id: 'isaa_b1', question: 'Engages in stereotyped and repetitive motor mannerisms', questionTe: 'మూసపోసిన మరియు పునరావృత చలన పద్ధతులలో పాల్గొంటారు', domain: 'behavior', domainName: 'Behavior Patterns', domainNameTe: 'ప్రవర్తన నమూనాలు', responseOptions: _fivePointOptions),
  ScreeningQuestion(id: 'isaa_b2', question: 'Shows attachment to inanimate objects', questionTe: 'నిర్జీవ వస్తువుల పట్ల అనుబంధం చూపిస్తారు', domain: 'behavior', domainName: 'Behavior Patterns', domainNameTe: 'ప్రవర్తన నమూనాలు', responseOptions: _fivePointOptions),
  ScreeningQuestion(id: 'isaa_b3', question: 'Shows hyperactivity/restlessness', questionTe: 'అతి చురుకుదనం/అశాంతి చూపిస్తారు', domain: 'behavior', domainName: 'Behavior Patterns', domainNameTe: 'ప్రవర్తన నమూనాలు', responseOptions: _fivePointOptions),
  ScreeningQuestion(id: 'isaa_b4', question: 'Exhibits aggressive behavior', questionTe: 'దూకుడు ప్రవర్తన చూపిస్తారు', domain: 'behavior', domainName: 'Behavior Patterns', domainNameTe: 'ప్రవర్తన నమూనాలు', responseOptions: _fivePointOptions),
  ScreeningQuestion(id: 'isaa_b5', question: 'Throws temper tantrums', questionTe: 'కోపం ప్రదర్శిస్తారు', domain: 'behavior', domainName: 'Behavior Patterns', domainNameTe: 'ప్రవర్తన నమూనాలు', responseOptions: _fivePointOptions),
  ScreeningQuestion(id: 'isaa_b6', question: 'Engages in self-injurious behavior', questionTe: 'స్వీయ-హాని ప్రవర్తనలో పాల్గొంటారు', domain: 'behavior', domainName: 'Behavior Patterns', domainNameTe: 'ప్రవర్తన నమూనాలు', responseOptions: _fivePointOptions),
  ScreeningQuestion(id: 'isaa_b7', question: 'Insists on sameness/resists change', questionTe: 'ఒకేలా ఉండాలని పట్టుబడతారు/మార్పును ప్రతిఘటిస్తారు', domain: 'behavior', domainName: 'Behavior Patterns', domainNameTe: 'ప్రవర్తన నమూనాలు', responseOptions: _fivePointOptions),
  ScreeningQuestion(id: 'isaa_b8', question: 'Exhibits obsessive behavior', questionTe: 'ఆబ్సెసివ్ ప్రవర్తన చూపిస్తారు', domain: 'behavior', domainName: 'Behavior Patterns', domainNameTe: 'ప్రవర్తన నమూనాలు', responseOptions: _fivePointOptions),

  // Sensory Aspects (5 items)
  ScreeningQuestion(id: 'isaa_sn1', question: 'Unusual response to sensory stimuli', questionTe: 'ఇంద్రియ ఉద్దీపనలకు అసాధారణ స్పందన', domain: 'sensory', domainName: 'Sensory Aspects', domainNameTe: 'ఇంద్రియ అంశాలు', responseOptions: _fivePointOptions),
  ScreeningQuestion(id: 'isaa_sn2', question: 'Stares into space for long periods', questionTe: 'చాలా సేపు శూన్యంలోకి చూస్తారు', domain: 'sensory', domainName: 'Sensory Aspects', domainNameTe: 'ఇంద్రియ అంశాలు', responseOptions: _fivePointOptions),
  ScreeningQuestion(id: 'isaa_sn3', question: 'Has difficulty in tracking objects', questionTe: 'వస్తువులను అనుసరించడంలో కష్టం', domain: 'sensory', domainName: 'Sensory Aspects', domainNameTe: 'ఇంద్రియ అంశాలు', responseOptions: _fivePointOptions),
  ScreeningQuestion(id: 'isaa_sn4', question: 'Insensitive to pain', questionTe: 'నొప్పి పట్ల సున్నితత్వం లేదు', domain: 'sensory', domainName: 'Sensory Aspects', domainNameTe: 'ఇంద్రియ అంశాలు', responseOptions: _fivePointOptions),
  ScreeningQuestion(id: 'isaa_sn5', question: 'Responds to objects/people unusually by smelling, touching, or tasting', questionTe: 'వాసన చూడడం, తాకడం లేదా రుచి చూడడం ద్వారా వస్తువులు/వ్యక్తులకు అసాధారణంగా స్పందిస్తారు', domain: 'sensory', domainName: 'Sensory Aspects', domainNameTe: 'ఇంద్రియ అంశాలు', responseOptions: _fivePointOptions),

  // Cognitive Component (4 items)
  ScreeningQuestion(id: 'isaa_cg1', question: 'Inconsistent attention and concentration', questionTe: 'అస్థిరమైన శ్రద్ధ మరియు ఏకాగ్రత', domain: 'cognitive', domainName: 'Cognitive Component', domainNameTe: 'జ్ఞానాత్మక భాగం', responseOptions: _fivePointOptions),
  ScreeningQuestion(id: 'isaa_cg2', question: 'Shows delay in responding', questionTe: 'స్పందనలో ఆలస్యం చూపిస్తారు', domain: 'cognitive', domainName: 'Cognitive Component', domainNameTe: 'జ్ఞానాత్మక భాగం', responseOptions: _fivePointOptions),
  ScreeningQuestion(id: 'isaa_cg3', question: 'Has unusual memory of certain things', questionTe: 'కొన్ని విషయాలపై అసాధారణ జ్ఞాపకశక్తి ఉంది', domain: 'cognitive', domainName: 'Cognitive Component', domainNameTe: 'జ్ఞానాత్మక భాగం', responseOptions: _fivePointOptions),
  ScreeningQuestion(id: 'isaa_cg4', question: 'Has difficulty in generalizing learned skills', questionTe: 'నేర్చుకున్న నైపుణ్యాలను సాధారణీకరించడంలో కష్టం', domain: 'cognitive', domainName: 'Cognitive Component', domainNameTe: 'జ్ఞానాత్మక భాగం', responseOptions: _fivePointOptions),
];
