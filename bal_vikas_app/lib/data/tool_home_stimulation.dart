import 'package:flutter/material.dart';
import '../models/screening_tool.dart';

final homeStimulationConfig = ScreeningToolConfig(
  type: ScreeningToolType.homeStimulation,
  id: 'home_stimulation',
  name: 'Home Stimulation',
  nameTe: 'ఇంటి ఉద్దీపన',
  description: 'Assesses home environment stimulation for child development - 22 items across 4 domains',
  descriptionTe: 'పిల్లల అభివృద్ధి కోసం ఇంటి పరిసర ఉద్దీపనను అంచనా వేస్తుంది - 4 రంగాలలో 22 అంశాలు',
  minAgeMonths: 0,
  maxAgeMonths: 72,
  responseFormat: ResponseFormat.yesNo,
  domains: ['learning_materials', 'physical_environment', 'activities', 'safety'],
  icon: Icons.home,
  color: Color(0xFF3F51B5),
  order: 10,
  questions: _homeStimQuestions,
);

const _homeStimQuestions = <ScreeningQuestion>[
  // Learning Materials (6 items)
  ScreeningQuestion(id: 'hs_lm1', question: 'Are there age-appropriate toys available?', questionTe: 'వయసుకు తగిన బొమ్మలు అందుబాటులో ఉన్నాయా?', domain: 'learning_materials', domainName: 'Learning Materials', domainNameTe: 'అభ్యాస సామాగ్రి'),
  ScreeningQuestion(id: 'hs_lm2', question: 'Are there picture books or story books?', questionTe: 'చిత్ర పుస్తకాలు లేదా కథ పుస్తకాలు ఉన్నాయా?', domain: 'learning_materials', domainName: 'Learning Materials', domainNameTe: 'అభ్యాస సామాగ్రి'),
  ScreeningQuestion(id: 'hs_lm3', question: 'Are there drawing/coloring materials?', questionTe: 'గీతలు/రంగుల సామాగ్రి ఉన్నాయా?', domain: 'learning_materials', domainName: 'Learning Materials', domainNameTe: 'అభ్యాస సామాగ్రి'),
  ScreeningQuestion(id: 'hs_lm4', question: 'Is there variety in toys and play materials?', questionTe: 'బొమ్మలు మరియు ఆట సామాగ్రిలో వైవిధ్యం ఉందా?', domain: 'learning_materials', domainName: 'Learning Materials', domainNameTe: 'అభ్యాస సామాగ్రి'),
  ScreeningQuestion(id: 'hs_lm5', question: 'Are there toys that encourage creativity (blocks, puzzles)?', questionTe: 'సృజనాత్మకతను ప్రోత్సహించే బొమ్మలు (బ్లాక్‌లు, పజిల్స్) ఉన్నాయా?', domain: 'learning_materials', domainName: 'Learning Materials', domainNameTe: 'అభ్యాస సామాగ్రి'),
  ScreeningQuestion(id: 'hs_lm6', question: 'Are there musical toys or instruments?', questionTe: 'సంగీత బొమ్మలు లేదా వాయిద్యాలు ఉన్నాయా?', domain: 'learning_materials', domainName: 'Learning Materials', domainNameTe: 'అభ్యాస సామాగ్రి'),

  // Physical Environment (6 items)
  ScreeningQuestion(id: 'hs_pe1', question: 'Does child have safe space to play?', questionTe: 'బిడ్డకు సురక్షితంగా ఆడుకునే స్థలం ఉందా?', domain: 'physical_environment', domainName: 'Physical Environment', domainNameTe: 'భౌతిక పరిసరాలు'),
  ScreeningQuestion(id: 'hs_pe2', question: 'Is there outdoor space for play?', questionTe: 'ఆడుకోవడానికి బయటి స్థలం ఉందా?', domain: 'physical_environment', domainName: 'Physical Environment', domainNameTe: 'భౌతిక పరిసరాలు'),
  ScreeningQuestion(id: 'hs_pe3', question: 'Is the home well-lit and ventilated?', questionTe: 'ఇల్లు బాగా వెలుతురు మరియు గాలి ఉందా?', domain: 'physical_environment', domainName: 'Physical Environment', domainNameTe: 'భౌతిక పరిసరాలు'),
  ScreeningQuestion(id: 'hs_pe4', question: 'Is there access to safe drinking water?', questionTe: 'శుద్ధమైన తాగునీటి సౌకర్యం ఉందా?', domain: 'physical_environment', domainName: 'Physical Environment', domainNameTe: 'భౌతిక పరిసరాలు'),
  ScreeningQuestion(id: 'hs_pe5', question: 'Is there toilet/sanitation facility?', questionTe: 'మరుగుదొడ్డి/పారిశుద్ధ్య సౌకర్యం ఉందా?', domain: 'physical_environment', domainName: 'Physical Environment', domainNameTe: 'భౌతిక పరిసరాలు'),
  ScreeningQuestion(id: 'hs_pe6', question: 'Is the home environment clean and hygienic?', questionTe: 'ఇంటి పరిసరాలు శుభ్రంగా మరియు శుచిగా ఉన్నాయా?', domain: 'physical_environment', domainName: 'Physical Environment', domainNameTe: 'భౌతిక పరిసరాలు'),

  // Activities & Interactions (6 items)
  ScreeningQuestion(id: 'hs_ai1', question: 'Does family eat meals together?', questionTe: 'కుటుంబం కలిసి భోజనం చేస్తారా?', domain: 'activities', domainName: 'Activities', domainNameTe: 'కార్యకలాపాలు'),
  ScreeningQuestion(id: 'hs_ai2', question: 'Is child taken outside home regularly?', questionTe: 'బిడ్డను క్రమం తప్పకుండా ఇంటి బయటకు తీసుకెళ్తారా?', domain: 'activities', domainName: 'Activities', domainNameTe: 'కార్యకలాపాలు'),
  ScreeningQuestion(id: 'hs_ai3', question: 'Does child interact with other children regularly?', questionTe: 'బిడ్డ ఇతర పిల్లలతో క్రమం తప్పకుండా సంభాషిస్తారా?', domain: 'activities', domainName: 'Activities', domainNameTe: 'కార్యకలాపాలు'),
  ScreeningQuestion(id: 'hs_ai4', question: 'Is child exposed to multiple languages?', questionTe: 'బిడ్డకు అనేక భాషల పరిచయం ఉందా?', domain: 'activities', domainName: 'Activities', domainNameTe: 'కార్యకలాపాలు'),
  ScreeningQuestion(id: 'hs_ai5', question: 'Does caregiver tell stories or sing songs daily?', questionTe: 'పోషకుడు రోజూ కథలు చెప్తారా లేదా పాటలు పాడతారా?', domain: 'activities', domainName: 'Activities', domainNameTe: 'కార్యకలాపాలు'),
  ScreeningQuestion(id: 'hs_ai6', question: 'Is child included in simple household activities?', questionTe: 'బిడ్డను సాధారణ ఇంటి పనులలో చేర్చుతారా?', domain: 'activities', domainName: 'Activities', domainNameTe: 'కార్యకలాపాలు'),

  // Safety (4 items)
  ScreeningQuestion(id: 'hs_sf1', question: 'Are dangerous substances stored out of child\'s reach?', questionTe: 'ప్రమాదకరమైన పదార్థాలు బిడ్డకు అందనంత దూరంలో ఉంచారా?', domain: 'safety', domainName: 'Safety', domainNameTe: 'భద్రత'),
  ScreeningQuestion(id: 'hs_sf2', question: 'Is child supervised during play?', questionTe: 'ఆటలో బిడ్డపై నిఘా ఉందా?', domain: 'safety', domainName: 'Safety', domainNameTe: 'భద్రత'),
  ScreeningQuestion(id: 'hs_sf3', question: 'Are electrical outlets and sharp objects secured?', questionTe: 'విద్యుత్ ఔట్‌లెట్‌లు మరియు పదునైన వస్తువులు భద్రపరచారా?', domain: 'safety', domainName: 'Safety', domainNameTe: 'భద్రత'),
  ScreeningQuestion(id: 'hs_sf4', question: 'Is child protected from extreme weather?', questionTe: 'తీవ్ర వాతావరణం నుండి బిడ్డను రక్షిస్తారా?', domain: 'safety', domainName: 'Safety', domainNameTe: 'భద్రత'),
];
