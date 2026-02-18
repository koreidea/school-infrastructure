import 'package:flutter_riverpod/flutter_riverpod.dart';

// Environment & Caregiving questions provider
final environmentQuestionsProvider = Provider<List<Map<String, dynamic>>>((ref) {
  return [
    {
      'id': 'ec_interaction_1',
      'category': 'Parent-Child Interaction',
      'category_te': 'తల్లిదండ్రులు-బిడ్డ పరస్పర చర్య',
      'question': 'Does caregiver respond to child\'s vocalizations?',
      'question_te': 'పోషకుడు బిడ్డ ధ్వనులకు స్పందిస్తారా?',
    },
    {
      'id': 'ec_interaction_2',
      'category': 'Parent-Child Interaction',
      'category_te': 'తల్లిదండ్రులు-బిడ్డ పరస్పర చర్య',
      'question': 'Does caregiver encourage exploration and play?',
      'question_te': 'పోషకుడు అన్వేషణ మరియు ఆటను ప్రోత్సహిస్తారా?',
    },
    {
      'id': 'ec_interaction_3',
      'category': 'Parent-Child Interaction',
      'category_te': 'తల్లిదండ్రులు-బిడ్డ పరస్పర చర్య',
      'question': 'Does caregiver show warmth and affection?',
      'question_te': 'పోషకుడు ప్రేమను మరియు ఆప్యాయతను చూపిస్తారా?',
    },
    {
      'id': 'ec_stimulation_1',
      'category': 'Home Stimulation',
      'category_te': 'ఇంటి పరిసరాలు',
      'question': 'Are there age-appropriate learning materials?',
      'question_te': 'వయసుకు తగిన అభ్యాస సామాగ్రి ఉన్నాయా?',
    },
    {
      'id': 'ec_stimulation_2',
      'category': 'Home Stimulation',
      'category_te': 'ఇంటి పరిసరాలు',
      'question': 'Is there variety in toys and play activities?',
      'question_te': 'బొమ్మలు మరియు ఆటలలో వైవిధ్యం ఉందా?',
    },
    {
      'id': 'ec_stimulation_3',
      'category': 'Home Stimulation',
      'category_te': 'ఇంటి పరిసరాలు',
      'question': 'Does child have safe space to play?',
      'question_te': 'బిడ్డకు సురక్షితంగా ఆడుకునే స్థలం ఉందా?',
    },
    {
      'id': 'ec_materials_1',
      'category': 'Play Materials',
      'category_te': 'ఆట సామాగ్రి',
      'question': 'Are there age-appropriate toys available?',
      'question_te': 'వయసుకు తగిన బొమ్మలు అందుబాటులో ఉన్నాయా?',
    },
    {
      'id': 'ec_materials_2',
      'category': 'Play Materials',
      'category_te': 'ఆట సామాగ్రి',
      'question': 'Are there picture books available?',
      'question_te': 'చిత్రాలతో కూడిన పుస్తకాలు అందుబాటులో ఉన్నాయా?',
    },
    {
      'id': 'ec_materials_3',
      'category': 'Play Materials',
      'category_te': 'ఆట సామాగ్రి',
      'question': 'Are there drawing/colouring materials?',
      'question_te': 'గీతలు/రంగుల సామాగ్రి ఉన్నాయా?',
    },
    {
      'id': 'ec_engagement_1',
      'category': 'Caregiver Engagement',
      'category_te': 'పోషకుడు బాధ్యత',
      'question': 'Does caregiver spend dedicated time with child daily?',
      'question_te': 'పోషకుడు రోజువారీ బిడ్డతో ప్రత్యేక సమయం గడుపుతారా?',
    },
    {
      'id': 'ec_engagement_2',
      'category': 'Caregiver Engagement',
      'category_te': 'పోషకుడు బాధ్యత',
      'question': 'Does caregiver talk to child during daily activities?',
      'question_te': 'పోషకుడు రోజువారీ పనులలో బిడ్డతో మాట్లాడతారా?',
    },
    {
      'id': 'ec_engagement_3',
      'category': 'Caregiver Engagement',
      'category_te': 'పోషకుడు బాధ్యత',
      'question': 'Does caregiver engage in play with child?',
      'question_te': 'పోషకుడు బిడ్డతో ఆడుకుంటారా?',
    },
    {
      'id': 'ec_language_1',
      'category': 'Language Exposure',
      'category_te': 'భాష పరిచయం',
      'question': 'Does caregiver read to child?',
      'question_te': 'పోషకుడు బిడ్డకు పుస్తకం చదువుతారా?',
    },
    {
      'id': 'ec_language_2',
      'category': 'Language Exposure',
      'category_te': 'భాష పరిచయం',
      'question': 'Is child exposed to multiple languages?',
      'question_te': 'బిడ్డకు అనేక భాషల పరిచయం ఉందా?',
    },
    {
      'id': 'ec_language_3',
      'category': 'Language Exposure',
      'category_te': 'భాష పరిచయం',
      'question': 'Does caregiver tell stories or sing songs?',
      'question_te': 'పోషకుడు కథలు చెప్పతారా లేదా పాటలు పాడతారా?',
    },
    {
      'id': 'ec_amenities_1',
      'category': 'Basic Amenities',
      'category_te': 'ప్రాథమిక సౌకర్యాలు',
      'question': 'Is there access to safe drinking water?',
      'question_te': 'శుద్ధమైన తాగునీటి సౌకర్యం ఉందా?',
    },
    {
      'id': 'ec_amenities_2',
      'category': 'Basic Amenities',
      'category_te': 'ప్రాథమిక సౌకర్యాలు',
      'question': 'Is there toilet facility available?',
      'question_te': 'మరుగుదొడ్ల సౌకర్యం ఉందా?',
    },
    {
      'id': 'ec_amenities_3',
      'category': 'Basic Amenities',
      'category_te': 'ప్రాథమిక సౌకర్యాలు',
      'question': 'Is the home environment clean and hygienic?',
      'question_te': 'ఇంటి పరిసరాలు శుభ్రంగా మరియు శుచిగా ఉన్నాయా?',
    },
  ];
});

// Questionnaire provider
final questionnaireProvider = FutureProvider<Map<String, dynamic>?>((ref) async {
  try {
    // Return mock questionnaire data
    await Future.delayed(const Duration(milliseconds: 500));
    
    return {
      'version_id': 2,
      'version_number': '2.0-cdc-reference',
      'questionnaire_data': {
        'version': '2.0',
        'source': 'CDC Learn the Signs. Act Early + ECD_Complete_Questionnaire_Reference',
        'domains': [
          {
            'code': 'gm',
            'name': 'Gross Motor',
            'name_te': 'స్థూల చలనం',
            'milestones': [
              {'age': 2, 'id': 'gm_2_1', 'question': 'Holds head up when on tummy', 'question_te': 'పొట్టపై ఉన్నప్పుడు తల పైకి ఎత్తగలరా?', 'critical': true, 'red_flag': true},
              {'age': 2, 'id': 'gm_2_2', 'question': 'Moves both arms and both legs', 'question_te': 'రెండు చేతులు మరియు రెండు కాళ్ళు కదుపుతారా?', 'critical': true, 'red_flag': false},
              {'age': 4, 'id': 'gm_4_1', 'question': 'Holds head steady without support when held', 'question_te': 'పట్టుకున్నప్పుడు మద్దతు లేకుండా తల స్థిరంగా ఉంచుతారా?', 'critical': true, 'red_flag': true},
              {'age': 4, 'id': 'gm_4_2', 'question': 'Pushes up onto elbows/forearms when on tummy', 'question_te': 'పొట్టపై ఉన్నప్పుడు చేతులతో పైకి లేస్తారా?', 'critical': true, 'red_flag': false},
              {'age': 6, 'id': 'gm_6_1', 'question': 'Rolls from tummy to back', 'question_te': 'పొట్ట నుండి వెనక్కి తిరగగలరా?', 'critical': true, 'red_flag': false},
              {'age': 6, 'id': 'gm_6_2', 'question': 'Pushes up with straight arms when on tummy', 'question_te': 'పొట్టపై ఉన్నప్పుడు చేతులు నిటారుగా ఉంచి పైకి లేస్తారా?', 'critical': true, 'red_flag': false},
              {'age': 6, 'id': 'gm_6_3', 'question': 'Leans on hands to support when sitting', 'question_te': 'కూర్చున్నప్పుడు చేతులపై ఆనుకుంటారా?', 'critical': true, 'red_flag': false},
              {'age': 9, 'id': 'gm_9_1', 'question': 'Gets to sitting position by herself', 'question_te': 'తనంతట తాను కూర్చునే స్థితికి వస్తారా?', 'critical': true, 'red_flag': false},
              {'age': 9, 'id': 'gm_9_2', 'question': 'Sits without support', 'question_te': 'మద్దతు లేకుండా కూర్చోగలరా?', 'critical': true, 'red_flag': true},
              {'age': 12, 'id': 'gm_12_1', 'question': 'Pulls up to stand', 'question_te': 'నిలబడటానికి లేవగలరా?', 'critical': true, 'red_flag': false},
              {'age': 12, 'id': 'gm_12_2', 'question': 'Walks, holding on to furniture', 'question_te': 'ఫర్నిచర్ పట్టుకుని నడవగలరా?', 'critical': true, 'red_flag': false},
              {'age': 18, 'id': 'gm_18_1', 'question': 'Walks without holding on to anyone or anything', 'question_te': 'ఎవరినీ లేదా ఏదైనా పట్టుకోకుండా నడవగలరా?', 'critical': true, 'red_flag': true},
              {'age': 18, 'id': 'gm_18_2', 'question': 'Climbs on and off couch or chair without help', 'question_te': 'సహాయం లేకుండా సోఫా లేదా కుర్చీ ఎక్కి దిగగలరా?', 'critical': true, 'red_flag': false},
              {'age': 24, 'id': 'gm_24_1', 'question': 'Kicks a ball', 'question_te': 'బంతిని తన్నగలరా?', 'critical': true, 'red_flag': false},
              {'age': 24, 'id': 'gm_24_2', 'question': 'Runs', 'question_te': 'పరుగెత్తగలరా?', 'critical': true, 'red_flag': false},
              {'age': 24, 'id': 'gm_24_3', 'question': 'Walks (not climbs) up few stairs with/without help', 'question_te': 'సహాయంతో/లేకుండా మెట్లు ఎక్కగలరా?', 'critical': true, 'red_flag': false},
              {'age': 30, 'id': 'gm_30_1', 'question': 'Jumps off ground with both feet', 'question_te': 'రెండు పాదాలతో నేల నుండి దూకగలరా?', 'critical': true, 'red_flag': false},
              {'age': 48, 'id': 'gm_48_1', 'question': 'Catches a large ball most of the time', 'question_te': 'చాలా సార్లు పెద్ద బంతిని పట్టుకోగలరా?', 'critical': true, 'red_flag': false},
              {'age': 60, 'id': 'gm_60_1', 'question': 'Hops on one foot', 'question_te': 'ఒక కాలిపై గెంతగలరా?', 'critical': true, 'red_flag': false},
            ]
          },
          {
            'code': 'fm',
            'name': 'Fine Motor',
            'name_te': 'సూక్ష్మ చలనం',
            'milestones': [
              {'age': 2, 'id': 'fm_2_1', 'question': 'Opens hands briefly', 'question_te': 'చేతులు క్లుప్తంగా తెరుస్తారా?', 'critical': true, 'red_flag': false},
              {'age': 4, 'id': 'fm_4_1', 'question': 'Holds a toy when you put it in his hand', 'question_te': 'చేతిలో బొమ్మ పెట్టినప్పుడు పట్టుకుంటారా?', 'critical': true, 'red_flag': false},
              {'age': 4, 'id': 'fm_4_2', 'question': 'Uses her arm to swing at toys', 'question_te': 'బొమ్మలను కొట్టడానికి చేతిని ఊపుతారా?', 'critical': true, 'red_flag': false},
              {'age': 4, 'id': 'fm_4_3', 'question': 'Brings hands to mouth', 'question_te': 'చేతులను నోటికి తీసుకువస్తారా?', 'critical': true, 'red_flag': false},
              {'age': 9, 'id': 'fm_9_1', 'question': 'Moves things from one hand to other hand', 'question_te': 'ఒక చేతి నుండి మరొక చేతికి వస్తువులు మార్చగలరా?', 'critical': true, 'red_flag': false},
              {'age': 9, 'id': 'fm_9_2', 'question': 'Uses fingers to \'rake\' food towards himself', 'question_te': 'వేళ్ళతో ఆహారాన్ని తన వైపు లాగుకుంటారా?', 'critical': true, 'red_flag': false},
              {'age': 12, 'id': 'fm_12_1', 'question': 'Drinks from cup without lid, as you hold it', 'question_te': 'మీరు పట్టుకుంటే మూత లేని కప్పులో తాగగలరా?', 'critical': true, 'red_flag': false},
              {'age': 12, 'id': 'fm_12_2', 'question': 'Picks things up between thumb and pointer finger', 'question_te': 'బొటనవేలు మరియు చూపుడు వేలు మధ్య వస్తువులు పట్టుకోగలరా?', 'critical': true, 'red_flag': false},
              {'age': 18, 'id': 'fm_18_1', 'question': 'Scribbles', 'question_te': 'గీతలు గీయగలరా?', 'critical': true, 'red_flag': false},
              {'age': 18, 'id': 'fm_18_2', 'question': 'Drinks from cup without lid (may spill)', 'question_te': 'మూత లేని కప్పులో తాగగలరా (చిందవచ్చు)?', 'critical': true, 'red_flag': false},
              {'age': 18, 'id': 'fm_18_3', 'question': 'Feeds herself with fingers', 'question_te': 'వేళ్ళతో తానే తినగలరా?', 'critical': true, 'red_flag': false},
              {'age': 18, 'id': 'fm_18_4', 'question': 'Tries to use spoon', 'question_te': 'చెంచాను వాడటానికి ప్రయత్నిస్తారా?', 'critical': true, 'red_flag': false},
              {'age': 24, 'id': 'fm_24_1', 'question': 'Eats with a spoon', 'question_te': 'చెంచాతో తింటారా?', 'critical': true, 'red_flag': false},
              {'age': 30, 'id': 'fm_30_1', 'question': 'Uses hands to twist things (doorknobs, lids)', 'question_te': 'తలుపు గుబ్బలు, మూతలు తిప్పడానికి చేతులు వాడతారా?', 'critical': true, 'red_flag': false},
              {'age': 30, 'id': 'fm_30_2', 'question': 'Takes some clothes off by herself', 'question_te': 'తానే కొన్ని బట్టలు తీసేయగలరా?', 'critical': true, 'red_flag': false},
              {'age': 30, 'id': 'fm_30_3', 'question': 'Turns book pages, one page at a time', 'question_te': 'పుస్తకం పేజీలు ఒక్కొక్కటిగా తిప్పగలరా?', 'critical': true, 'red_flag': false},
              {'age': 36, 'id': 'fm_36_1', 'question': 'Strings items together (beads, macaroni)', 'question_te': 'పూసలు, మాకరోనీ వంటివి దారంలో గుచ్చగలరా?', 'critical': true, 'red_flag': false},
              {'age': 36, 'id': 'fm_36_2', 'question': 'Puts on some clothes by herself', 'question_te': 'తానే కొన్ని బట్టలు వేసుకోగలరా?', 'critical': true, 'red_flag': false},
              {'age': 36, 'id': 'fm_36_3', 'question': 'Uses a fork', 'question_te': 'ఫోర్క్ వాడగలరా?', 'critical': true, 'red_flag': false},
              {'age': 48, 'id': 'fm_48_1', 'question': 'Serves self food or pours water with help', 'question_te': 'సహాయంతో తానే ఆహారం వడ్డించుకోగలరా లేదా నీరు పోయగలరా?', 'critical': true, 'red_flag': false},
              {'age': 48, 'id': 'fm_48_2', 'question': 'Unbuttons some buttons', 'question_te': 'కొన్ని బటన్లు విప్పగలరా?', 'critical': true, 'red_flag': false},
              {'age': 48, 'id': 'fm_48_3', 'question': 'Holds crayon between fingers and thumb', 'question_te': 'వేళ్ళు మరియు బొటనవేలు మధ్య క్రేయాన్ పట్టుకోగలరా?', 'critical': true, 'red_flag': false},
              {'age': 60, 'id': 'fm_60_1', 'question': 'Buttons some buttons', 'question_te': 'కొన్ని బటన్లు పెట్టగలరా?', 'critical': true, 'red_flag': false},
            ]
          },
          {
            'code': 'lc',
            'name': 'Language & Communication',
            'name_te': 'భాష & సంభాషణ',
            'milestones': [
              {'age': 2, 'id': 'lc_2_1', 'question': 'Makes sounds other than crying', 'question_te': 'ఏడుపు కాకుండా ఇతర శబ్దాలు చేస్తారా?', 'critical': true, 'red_flag': true},
              {'age': 2, 'id': 'lc_2_2', 'question': 'Reacts to loud sounds', 'question_te': 'పెద్ద శబ్దాలకు స్పందిస్తారా?', 'critical': true, 'red_flag': true},
              {'age': 4, 'id': 'lc_4_1', 'question': 'Makes sounds like \'oooo\', \'aahh\' (cooing)', 'question_te': '\'ఊఊఊ\', \'ఆఆ\' వంటి శబ్దాలు చేస్తారా?', 'critical': true, 'red_flag': false},
              {'age': 4, 'id': 'lc_4_2', 'question': 'Makes sounds back when you talk to him', 'question_te': 'మీరు మాట్లాడినప్పుడు తిరిగి శబ్దాలు చేస్తారా?', 'critical': true, 'red_flag': false},
              {'age': 4, 'id': 'lc_4_3', 'question': 'Turns head towards the sound of your voice', 'question_te': 'మీ గొంతు వినిపించిన వైపు తల తిప్పుతారా?', 'critical': true, 'red_flag': false},
              {'age': 6, 'id': 'lc_6_1', 'question': 'Takes turns making sounds with you', 'question_te': 'మీతో శబ్దాలు చేయడంలో వంతులు తీసుకుంటారా?', 'critical': true, 'red_flag': false},
              {'age': 6, 'id': 'lc_6_2', 'question': 'Blows \'raspberries\' (sticks tongue out and blows)', 'question_te': 'నాలుక బయటపెట్టి ఊదుతారా?', 'critical': true, 'red_flag': false},
              {'age': 6, 'id': 'lc_6_3', 'question': 'Makes squealing noises', 'question_te': 'కీచు శబ్దాలు చేస్తారా?', 'critical': true, 'red_flag': false},
              {'age': 9, 'id': 'lc_9_1', 'question': 'Makes lots of different sounds like \'mamamama\'', 'question_te': '\'మమమ\' వంటి వివిధ శబ్దాలు చేస్తారా?', 'critical': true, 'red_flag': true},
              {'age': 9, 'id': 'lc_9_2', 'question': 'Lifts arms up to be picked up', 'question_te': 'ఎత్తుకోమని చేతులు పైకి ఎత్తుతారా?', 'critical': true, 'red_flag': false},
              {'age': 12, 'id': 'lc_12_1', 'question': 'Waves \'bye-bye\'', 'question_te': '\'బై-బై\' చేయి ఊపుతారా?', 'critical': true, 'red_flag': false},
              {'age': 12, 'id': 'lc_12_2', 'question': 'Calls parent \'mama\' or \'dada\' or special name', 'question_te': 'తల్లిదండ్రులను \'అమ్మ\' లేదా \'నాన్న\' అని పిలుస్తారా?', 'critical': true, 'red_flag': true},
              {'age': 12, 'id': 'lc_12_3', 'question': 'Understands \'no\' (pauses or stops)', 'question_te': '\'వద్దు\' అని అర్థం చేసుకుంటారా (ఆగుతారు)?', 'critical': true, 'red_flag': false},
              {'age': 18, 'id': 'lc_18_1', 'question': 'Tries to say three or more words besides \'mama\'', 'question_te': '\'అమ్మ\' కాకుండా మూడు లేదా అంతకంటే ఎక్కువ పదాలు చెప్పడానికి ప్రయత్నిస్తారా?', 'critical': true, 'red_flag': true},
              {'age': 18, 'id': 'lc_18_2', 'question': 'Follows one-step directions without gestures', 'question_te': 'సైగలు లేకుండా ఒక దశ సూచనలను అనుసరిస్తారా?', 'critical': true, 'red_flag': false},
              {'age': 24, 'id': 'lc_24_1', 'question': 'Points to things in a book when you ask', 'question_te': 'మీరు అడిగినప్పుడు పుస్తకంలో వస్తువులను చూపిస్తారా?', 'critical': true, 'red_flag': false},
              {'age': 24, 'id': 'lc_24_2', 'question': 'Says at least two words together', 'question_te': 'కనీసం రెండు పదాలు కలిపి చెప్పగలరా?', 'critical': true, 'red_flag': true},
              {'age': 24, 'id': 'lc_24_3', 'question': 'Points to at least 2 body parts when asked', 'question_te': 'అడిగినప్పుడు కనీసం 2 శరీర భాగాలను చూపిస్తారా?', 'critical': true, 'red_flag': false},
              {'age': 24, 'id': 'lc_24_4', 'question': 'Uses more gestures (blowing kiss, nodding yes)', 'question_te': 'ఎక్కువ సైగలు వాడతారా (ముద్దు ఊదడం, అవును అని తల ఊపడం)?', 'critical': true, 'red_flag': false},
              {'age': 30, 'id': 'lc_30_1', 'question': 'Says about 50 words', 'question_te': 'సుమారు 50 పదాలు చెప్పగలరా?', 'critical': true, 'red_flag': true},
              {'age': 30, 'id': 'lc_30_2', 'question': 'Says two or more words with one action word', 'question_te': 'ఒక క్రియా పదంతో రెండు లేదా అంతకంటే ఎక్కువ పదాలు చెప్పగలరా?', 'critical': true, 'red_flag': false},
              {'age': 30, 'id': 'lc_30_3', 'question': 'Names things in a book when you point and ask', 'question_te': 'మీరు చూపించి అడిగినప్పుడు పుస్తకంలో వస్తువుల పేర్లు చెప్పగలరా?', 'critical': true, 'red_flag': false},
              {'age': 30, 'id': 'lc_30_4', 'question': 'Says words like \'I\', \'me\', or \'we\'', 'question_te': '\'నేను\', \'నాకు\', \'మేము\' వంటి పదాలు వాడతారా?', 'critical': true, 'red_flag': false},
              {'age': 36, 'id': 'lc_36_1', 'question': 'Talks with you in conversation (2+ exchanges)', 'question_te': 'మీతో సంభాషణలో మాట్లాడతారా (2+ మార్పిళ్ళు)?', 'critical': true, 'red_flag': false},
              {'age': 36, 'id': 'lc_36_2', 'question': 'Asks \'who\', \'what\', \'where\', \'why\' questions', 'question_te': '\'ఎవరు\', \'ఏమిటి\', \'ఎక్కడ\', \'ఎందుకు\' ప్రశ్నలు అడుగుతారా?', 'critical': true, 'red_flag': false},
              {'age': 36, 'id': 'lc_36_3', 'question': 'Says what action is happening in picture', 'question_te': 'చిత్రంలో ఏ చర్య జరుగుతుందో చెప్పగలరా?', 'critical': true, 'red_flag': false},
              {'age': 36, 'id': 'lc_36_4', 'question': 'Says first name when asked', 'question_te': 'అడిగినప్పుడు తన పేరు చెప్పగలరా?', 'critical': true, 'red_flag': true},
              {'age': 36, 'id': 'lc_36_5', 'question': 'Talks well enough for others to understand', 'question_te': 'ఇతరులు అర్థం చేసుకునేంత బాగా మాట్లాడగలరా?', 'critical': true, 'red_flag': true},
              {'age': 48, 'id': 'lc_48_1', 'question': 'Says sentences with 4 or more words', 'question_te': '4 లేదా అంతకంటే ఎక్కువ పదాలతో వాక్యాలు చెప్పగలరా?', 'critical': true, 'red_flag': false},
              {'age': 48, 'id': 'lc_48_2', 'question': 'Says some words from a song, story, or rhyme', 'question_te': 'పాట, కథ లేదా పద్యం నుండి కొన్ని పదాలు చెప్పగలరా?', 'critical': true, 'red_flag': false},
              {'age': 48, 'id': 'lc_48_3', 'question': 'Talks about at least one thing that happened', 'question_te': 'జరిగిన కనీసం ఒక విషయం గురించి మాట్లాడగలరా?', 'critical': true, 'red_flag': false},
              {'age': 48, 'id': 'lc_48_4', 'question': 'Answers simple questions like \'What is a coat for?\'', 'question_te': '\'కోటు ఎందుకు?\' వంటి సాధారణ ప్రశ్నలకు సమాధానం చెప్పగలరా?', 'critical': true, 'red_flag': false},
              {'age': 60, 'id': 'lc_60_1', 'question': 'Tells a story with at least 2 events', 'question_te': 'కనీసం 2 సంఘటనలతో కథ చెప్పగలరా?', 'critical': true, 'red_flag': false},
              {'age': 60, 'id': 'lc_60_2', 'question': 'Answers simple questions about a book/story', 'question_te': 'పుస్తకం/కథ గురించి సాధారణ ప్రశ్నలకు సమాధానం చెప్పగలరా?', 'critical': true, 'red_flag': false},
              {'age': 60, 'id': 'lc_60_3', 'question': 'Keeps a conversation going (3+ exchanges)', 'question_te': 'సంభాషణను కొనసాగించగలరా (3+ మార్పిళ్ళు)?', 'critical': true, 'red_flag': false},
              {'age': 60, 'id': 'lc_60_4', 'question': 'Uses or recognizes simple rhymes', 'question_te': 'సాధారణ పద్యాలను వాడగలరా లేదా గుర్తించగలరా?', 'critical': true, 'red_flag': false},
            ]
          },
          {
            'code': 'cog',
            'name': 'Cognitive',
            'name_te': 'జ్ఞానాత్మకం',
            'milestones': [
              {'age': 2, 'id': 'cog_2_1', 'question': 'Watches you as you move', 'question_te': 'మీరు కదిలినప్పుడు చూస్తారా?', 'critical': true, 'red_flag': false},
              {'age': 2, 'id': 'cog_2_2', 'question': 'Looks at a toy for several seconds', 'question_te': 'బొమ్మను కొన్ని సెకన్లు చూస్తారా?', 'critical': true, 'red_flag': false},
              {'age': 4, 'id': 'cog_4_1', 'question': 'If hungry, opens mouth when sees breast or bottle', 'question_te': 'ఆకలిగా ఉంటే, రొమ్ము లేదా బాటిల్ చూసినప్పుడు నోరు తెరుస్తారా?', 'critical': true, 'red_flag': false},
              {'age': 4, 'id': 'cog_4_2', 'question': 'Looks at his hands with interest', 'question_te': 'ఆసక్తిగా తన చేతులను చూసుకుంటారా?', 'critical': true, 'red_flag': false},
              {'age': 6, 'id': 'cog_6_1', 'question': 'Puts things in her mouth to explore them', 'question_te': 'వస్తువులను పరిశీలించడానికి నోటిలో పెట్టుకుంటారా?', 'critical': true, 'red_flag': false},
              {'age': 6, 'id': 'cog_6_2', 'question': 'Reaches to grab a toy he wants', 'question_te': 'కావలసిన బొమ్మను అందుకోవడానికి చేరుకుంటారా?', 'critical': true, 'red_flag': false},
              {'age': 6, 'id': 'cog_6_3', 'question': 'Closes lips to show doesn\'t want more food', 'question_te': 'మరింత ఆహారం వద్దని పెదాలు మూసుకుంటారా?', 'critical': true, 'red_flag': false},
              {'age': 9, 'id': 'cog_9_1', 'question': 'Looks for objects when dropped out of sight', 'question_te': 'కనుమరుగైన వస్తువులను వెతుకుతారా?', 'critical': true, 'red_flag': false},
              {'age': 9, 'id': 'cog_9_2', 'question': 'Bangs two things together', 'question_te': 'రెండు వస్తువులను కొడతారా?', 'critical': true, 'red_flag': false},
              {'age': 12, 'id': 'cog_12_1', 'question': 'Puts something in container (block in cup)', 'question_te': 'కంటైనర్‌లో ఏదైనా పెడతారా (కప్పులో బ్లాక్)?', 'critical': true, 'red_flag': false},
              {'age': 12, 'id': 'cog_12_2', 'question': 'Looks for things he sees you hide', 'question_te': 'మీరు దాచిన వస్తువులను వెతుకుతారా?', 'critical': true, 'red_flag': false},
              {'age': 18, 'id': 'cog_18_1', 'question': 'Copies you doing chores (sweeping with broom)', 'question_te': 'మీరు చేసే పనులను అనుకరిస్తారా (చీపురుతో ఊడ్చడం)?', 'critical': true, 'red_flag': false},
              {'age': 18, 'id': 'cog_18_2', 'question': 'Plays with toys in simple way (pushes toy car)', 'question_te': 'సాధారణ పద్ధతిలో బొమ్మలతో ఆడతారా (బొమ్మ కారు నెడతారా)?', 'critical': true, 'red_flag': false},
              {'age': 24, 'id': 'cog_24_1', 'question': 'Holds something in one hand while using other', 'question_te': 'ఒక చేత్తో వస్తువు పట్టుకుని మరొక చేయి వాడతారా?', 'critical': true, 'red_flag': false},
              {'age': 24, 'id': 'cog_24_2', 'question': 'Tries to use switches, knobs, or buttons on toy', 'question_te': 'బొమ్మపై స్విచ్‌లు, నాబ్‌లు లేదా బటన్లు వాడటానికి ప్రయత్నిస్తారా?', 'critical': true, 'red_flag': false},
              {'age': 24, 'id': 'cog_24_3', 'question': 'Plays with more than one toy at same time', 'question_te': 'ఒకే సమయంలో ఒకటి కంటే ఎక్కువ బొమ్మలతో ఆడతారా?', 'critical': true, 'red_flag': false},
              {'age': 30, 'id': 'cog_30_1', 'question': 'Uses things to pretend (feeds block as food)', 'question_te': 'నటించడానికి వస్తువులను వాడతారా (బ్లాక్‌ను ఆహారంగా తినిపిస్తారా)?', 'critical': true, 'red_flag': false},
              {'age': 30, 'id': 'cog_30_2', 'question': 'Shows simple problem-solving skills', 'question_te': 'సాధారణ సమస్య పరిష్కార నైపుణ్యాలు చూపిస్తారా?', 'critical': true, 'red_flag': false},
              {'age': 30, 'id': 'cog_30_3', 'question': 'Follows two-step instructions', 'question_te': 'రెండు దశల సూచనలను అనుసరిస్తారా?', 'critical': true, 'red_flag': false},
              {'age': 30, 'id': 'cog_30_4', 'question': 'Knows at least one color', 'question_te': 'కనీసం ఒక రంగు తెలుసా?', 'critical': true, 'red_flag': false},
              {'age': 36, 'id': 'cog_36_1', 'question': 'Draws a circle when you show how', 'question_te': 'మీరు చూపించినప్పుడు వృత్తం గీయగలరా?', 'critical': true, 'red_flag': false},
              {'age': 36, 'id': 'cog_36_2', 'question': 'Avoids touching hot objects when warned', 'question_te': 'హెచ్చరించినప్పుడు వేడి వస్తువులను తాకకుండా ఉంటారా?', 'critical': true, 'red_flag': false},
              {'age': 48, 'id': 'cog_48_1', 'question': 'Names a few colors of items', 'question_te': 'వస్తువుల కొన్ని రంగుల పేర్లు చెప్పగలరా?', 'critical': true, 'red_flag': false},
              {'age': 48, 'id': 'cog_48_2', 'question': 'Tells what comes next in well-known story', 'question_te': 'బాగా తెలిసిన కథలో తర్వాత ఏమి వస్తుందో చెప్పగలరా?', 'critical': true, 'red_flag': false},
              {'age': 48, 'id': 'cog_48_3', 'question': 'Draws a person with 3 or more body parts', 'question_te': '3 లేదా అంతకంటే ఎక్కువ శరీర భాగాలతో మనిషిని గీయగలరా?', 'critical': true, 'red_flag': false},
              {'age': 60, 'id': 'cog_60_1', 'question': 'Counts to 10', 'question_te': '10 వరకు లెక్కించగలరా?', 'critical': true, 'red_flag': false},
              {'age': 60, 'id': 'cog_60_2', 'question': 'Names some numbers between 1 and 5 when pointed', 'question_te': 'చూపించినప్పుడు 1 నుండి 5 మధ్య కొన్ని సంఖ్యల పేర్లు చెప్పగలరా?', 'critical': true, 'red_flag': false},
              {'age': 60, 'id': 'cog_60_3', 'question': 'Uses words about time (yesterday, tomorrow)', 'question_te': 'సమయం గురించి పదాలు వాడతారా (నిన్న, రేపు)?', 'critical': true, 'red_flag': false},
              {'age': 60, 'id': 'cog_60_4', 'question': 'Pays attention for 5 to 10 minutes during activity', 'question_te': 'కార్యకలాపంలో 5 నుండి 10 నిమిషాలు శ్రద్ధ చూపిస్తారా?', 'critical': true, 'red_flag': false},
              {'age': 60, 'id': 'cog_60_5', 'question': 'Writes some letters in their name', 'question_te': 'తన పేరులో కొన్ని అక్షరాలు రాయగలరా?', 'critical': true, 'red_flag': false},
              {'age': 60, 'id': 'cog_60_6', 'question': 'Names some letters when you point to them', 'question_te': 'మీరు చూపించినప్పుడు కొన్ని అక్షరాల పేర్లు చెప్పగలరా?', 'critical': true, 'red_flag': false},
            ]
          },
          {
            'code': 'se',
            'name': 'Social-Emotional',
            'name_te': 'సామాజిక-భావోద్వేగ',
            'milestones': [
              {'age': 2, 'id': 'se_2_1', 'question': 'Calms down when spoken to or picked up', 'question_te': 'మాట్లాడినప్పుడు లేదా ఎత్తుకున్నప్పుడు శాంతిస్తారా?', 'critical': true, 'red_flag': false},
              {'age': 2, 'id': 'se_2_2', 'question': 'Looks at your face', 'question_te': 'మీ ముఖాన్ని చూస్తారా?', 'critical': true, 'red_flag': true},
              {'age': 2, 'id': 'se_2_3', 'question': 'Seems happy to see you when you walk up', 'question_te': 'మీరు దగ్గరకు వచ్చినప్పుడు సంతోషంగా కనిపిస్తారా?', 'critical': true, 'red_flag': false},
              {'age': 2, 'id': 'se_2_4', 'question': 'Smiles when you talk to or smile at her', 'question_te': 'మీరు మాట్లాడినప్పుడు లేదా నవ్వినప్పుడు నవ్వుతారా?', 'critical': true, 'red_flag': true},
              {'age': 4, 'id': 'se_4_1', 'question': 'Smiles on his own to get your attention', 'question_te': 'మీ దృష్టి ఆకర్షించడానికి తనంతట తాను నవ్వుతారా?', 'critical': true, 'red_flag': false},
              {'age': 4, 'id': 'se_4_2', 'question': 'Chuckles (not yet a full laugh)', 'question_te': 'కిలకిల నవ్వుతారా (పూర్తి నవ్వు కాదు)?', 'critical': true, 'red_flag': false},
              {'age': 4, 'id': 'se_4_3', 'question': 'Looks at you, moves, or makes sounds for attention', 'question_te': 'దృష్టి కోసం మిమ్మల్ని చూస్తారా, కదులుతారా లేదా శబ్దాలు చేస్తారా?', 'critical': true, 'red_flag': false},
              {'age': 6, 'id': 'se_6_1', 'question': 'Knows familiar people', 'question_te': 'పరిచిత వ్యక్తులను గుర్తిస్తారా?', 'critical': true, 'red_flag': false},
              {'age': 6, 'id': 'se_6_2', 'question': 'Likes to look at self in a mirror', 'question_te': 'అద్దంలో తనను తాను చూసుకోవడం ఇష్టపడతారా?', 'critical': true, 'red_flag': false},
              {'age': 6, 'id': 'se_6_3', 'question': 'Laughs', 'question_te': 'నవ్వుతారా?', 'critical': true, 'red_flag': false},
              {'age': 9, 'id': 'se_9_1', 'question': 'Is shy, clingy, or fearful around strangers', 'question_te': 'అపరిచితుల దగ్గర సిగ్గు, అతుక్కుపోవడం లేదా భయం చూపిస్తారా?', 'critical': true, 'red_flag': false},
              {'age': 9, 'id': 'se_9_2', 'question': 'Shows several facial expressions', 'question_te': 'అనేక ముఖ భావాలు చూపిస్తారా?', 'critical': true, 'red_flag': false},
              {'age': 9, 'id': 'se_9_3', 'question': 'Looks when you call her name', 'question_te': 'పేరు పిలిచినప్పుడు చూస్తారా?', 'critical': true, 'red_flag': true},
              {'age': 9, 'id': 'se_9_4', 'question': 'Reacts when you leave (looks, reaches, or cries)', 'question_te': 'మీరు వెళ్ళినప్పుడు స్పందిస్తారా (చూస్తారు, చేరుకుంటారు లేదా ఏడుస్తారు)?', 'critical': true, 'red_flag': false},
              {'age': 9, 'id': 'se_9_5', 'question': 'Smiles or laughs when you play peek-a-boo', 'question_te': 'దాగుడుమూతలు ఆడినప్పుడు నవ్వుతారా?', 'critical': true, 'red_flag': false},
              {'age': 12, 'id': 'se_12_1', 'question': 'Plays games with you, like pat-a-cake', 'question_te': 'మీతో ఆటలు ఆడతారా (చప్పట్ల ఆట)?', 'critical': true, 'red_flag': false},
              {'age': 18, 'id': 'se_18_1', 'question': 'Moves away from you but looks to make sure close', 'question_te': 'మీ నుండి దూరంగా వెళ్తారు కానీ దగ్గరలో ఉన్నారో చూస్తారా?', 'critical': true, 'red_flag': false},
              {'age': 18, 'id': 'se_18_2', 'question': 'Points to show you something interesting', 'question_te': 'ఆసక్తికరమైన విషయం చూపించడానికి చూపిస్తారా?', 'critical': true, 'red_flag': true},
              {'age': 18, 'id': 'se_18_3', 'question': 'Puts hands out for you to wash them', 'question_te': 'చేతులు కడగమని చేతులు చాపుతారా?', 'critical': true, 'red_flag': false},
              {'age': 18, 'id': 'se_18_4', 'question': 'Looks at a few pages with you', 'question_te': 'మీతో కొన్ని పేజీలు చూస్తారా?', 'critical': true, 'red_flag': false},
              {'age': 18, 'id': 'se_18_5', 'question': 'Helps dress by pushing arm through sleeve', 'question_te': 'చేతిని చేతికి తొడిగి బట్టలు వేసుకోవడంలో సహాయం చేస్తారా?', 'critical': true, 'red_flag': false},
              {'age': 24, 'id': 'se_24_1', 'question': 'Notices when others are hurt or upset', 'question_te': 'ఇతరులు గాయపడినప్పుడు లేదా బాధపడినప్పుడు గమనిస్తారా?', 'critical': true, 'red_flag': false},
              {'age': 24, 'id': 'se_24_2', 'question': 'Looks at your face to see reaction in new situation', 'question_te': 'కొత్త పరిస్థితిలో మీ ముఖ భావాన్ని చూస్తారా?', 'critical': true, 'red_flag': false},
              {'age': 30, 'id': 'se_30_1', 'question': 'Plays next to other children, sometimes with them', 'question_te': 'ఇతర పిల్లల పక్కన ఆడతారా, కొన్నిసార్లు వారితో ఆడతారా?', 'critical': true, 'red_flag': false},
              {'age': 30, 'id': 'se_30_2', 'question': 'Shows you what she can do (\'Look at me!\')', 'question_te': 'తను ఏం చేయగలదో చూపిస్తారా (\'నన్ను చూడు!\')?', 'critical': true, 'red_flag': false},
              {'age': 30, 'id': 'se_30_3', 'question': 'Follows simple routines when told', 'question_te': 'చెప్పినప్పుడు సాధారణ దినచర్యలను అనుసరిస్తారా?', 'critical': true, 'red_flag': false},
              {'age': 36, 'id': 'se_36_1', 'question': 'Calms within 10 minutes after you leave', 'question_te': 'మీరు వెళ్ళిన 10 నిమిషాలలో శాంతిస్తారా?', 'critical': true, 'red_flag': false},
              {'age': 36, 'id': 'se_36_2', 'question': 'Notices other children and joins them to play', 'question_te': 'ఇతర పిల్లలను గమనించి వారితో ఆడటానికి చేరతారా?', 'critical': true, 'red_flag': true},
              {'age': 48, 'id': 'se_48_1', 'question': 'Pretends to be something else (teacher, dog)', 'question_te': 'వేరొకరిగా నటిస్తారా (టీచర్, కుక్క)?', 'critical': true, 'red_flag': false},
              {'age': 48, 'id': 'se_48_2', 'question': 'Asks to go play with children if none around', 'question_te': 'చుట్టూ పిల్లలు లేకపోతే ఆడటానికి వెళ్ళమని అడుగుతారా?', 'critical': true, 'red_flag': false},
              {'age': 48, 'id': 'se_48_3', 'question': 'Comforts others who are hurt or sad', 'question_te': 'గాయపడిన లేదా బాధపడిన వారిని ఓదార్చుతారా?', 'critical': true, 'red_flag': false},
              {'age': 48, 'id': 'se_48_4', 'question': 'Avoids danger (doesn\'t jump from heights)', 'question_te': 'ప్రమాదాన్ని నివారిస్తారా (ఎత్తుల నుండి దూకరు)?', 'critical': true, 'red_flag': false},
              {'age': 48, 'id': 'se_48_5', 'question': 'Likes to be a \'helper\'', 'question_te': '\'సహాయకుడిగా\' ఉండటం ఇష్టపడతారా?', 'critical': true, 'red_flag': false},
              {'age': 48, 'id': 'se_48_6', 'question': 'Changes behavior based on location', 'question_te': 'ప్రదేశాన్ని బట్టి ప్రవర్తన మారుస్తారా?', 'critical': true, 'red_flag': false},
              {'age': 60, 'id': 'se_60_1', 'question': 'Follows rules or takes turns when playing games', 'question_te': 'ఆటల్లో నియమాలు పాటిస్తారా లేదా వంతులు తీసుకుంటారా?', 'critical': true, 'red_flag': false},
              {'age': 60, 'id': 'se_60_2', 'question': 'Sings, dances, or acts for you', 'question_te': 'మీ కోసం పాడతారా, నృత్యం చేస్తారా లేదా నటిస్తారా?', 'critical': true, 'red_flag': false},
              {'age': 60, 'id': 'se_60_3', 'question': 'Does simple chores at home', 'question_te': 'ఇంట్లో సాధారణ పనులు చేస్తారా?', 'critical': true, 'red_flag': false},
            ]
          },
        ]
      }
    };
  } catch (e) {
    return null;
  }
});

// Screening session
class ScreeningSessionNotifier extends Notifier<Map<String, dynamic>?> {
  @override
  Map<String, dynamic>? build() => null;
  
  void set(Map<String, dynamic>? session) => state = session;
}

final screeningSessionProvider = NotifierProvider<ScreeningSessionNotifier, Map<String, dynamic>?>(() {
  return ScreeningSessionNotifier();
});

// Screening responses
class ScreeningResponsesNotifier extends Notifier<Map<String, dynamic>> {
  @override
  Map<String, dynamic> build() => {};
  
  void set(Map<String, dynamic> responses) => state = responses;
  void update(Map<String, dynamic> responses) => state = {...state, ...responses};
}

final screeningResponsesProvider = NotifierProvider<ScreeningResponsesNotifier, Map<String, dynamic>>(() {
  return ScreeningResponsesNotifier();
});

// Current question index
class CurrentQuestionIndexNotifier extends Notifier<int> {
  @override
  int build() => 0;
  
  void set(int index) => state = index;
  void increment() => state++;
}

final currentQuestionIndexProvider = NotifierProvider<CurrentQuestionIndexNotifier, int>(() {
  return CurrentQuestionIndexNotifier();
});

// Screening measurements
class ScreeningMeasurementsNotifier extends Notifier<Map<String, dynamic>> {
  @override
  Map<String, dynamic> build() => {};
  
  void set(Map<String, dynamic> measurements) => state = measurements;
  void update(Map<String, dynamic> measurements) => state = {...state, ...measurements};
}

final screeningMeasurementsProvider = NotifierProvider<ScreeningMeasurementsNotifier, Map<String, dynamic>>(() {
  return ScreeningMeasurementsNotifier();
});

// Screening result provider
final screeningResultProvider = FutureProvider.family<Map<String, dynamic>?, int>((ref, sessionId) async {
  try {
    await Future.delayed(const Duration(milliseconds: 500));
    
    // Mock result for Arjun (30 months) - MEDIUM risk
    if (sessionId == 1) {
      return {
        'session': {
          'session_id': 1,
          'child_id': 1,
          'assessment_date': '2025-02-01',
          'child_age_months': 30,
          'status': 'completed',
        },
        'assessment': {
          'developmental': {
            'gm_dq': 100.0,
            'fm_dq': 80.0,
            'lc_dq': 50.0,
            'cog_dq': 100.0,
            'se_dq': 100.0,
            'composite_dq': 86.0,
          },
          'risk': {
            'gm_delay': false,
            'fm_delay': true,
            'lc_delay': true,
            'cog_delay': false,
            'se_delay': false,
            'num_delays': 2,
          },
          'nutrition': {
            'height_cm': 92.5,
            'weight_kg': 13.2,
            'height_z_score': -0.5,
            'weight_z_score': -0.8,
            'nutrition_risk': 'Low',
          },
          'baseline_risk': {
            'overall_risk_category': 'MEDIUM',
            'referral_needed': false,
            'intervention_priority': 'MODERATE',
            'primary_concern': 'Language delay',
          },
          'environment_caregiving': {
            'total_score': 75,
            'max_score': 90,
            'percentage': 83.3,
            'risk_level': 'Low',
            'interaction_score': 10,
            'stimulation_score': 8,
            'materials_score': 8,
            'engagement_score': 10,
            'language_score': 9,
            'amenities_score': 9,
            'components': {
              'Parent-Child Interaction': {'score': 10, 'max': 9, 'status': 'Adequate'},
              'Home Stimulation': {'score': 8, 'max': 9, 'status': 'Adequate'},
              'Play Materials': {'score': 8, 'max': 9, 'status': 'Adequate'},
              'Caregiver Engagement': {'score': 10, 'max': 9, 'status': 'Adequate'},
              'Language Exposure': {'score': 9, 'max': 9, 'status': 'Adequate'},
              'Basic Amenities': {'score': 9, 'max': 9, 'status': 'Adequate'},
            }
          }
        }
      };
    }
    
    // Mock result for Meera (54 months) - LOW risk
    if (sessionId == 2) {
      return {
        'session': {
          'session_id': 2,
          'child_id': 2,
          'assessment_date': '2025-02-05',
          'child_age_months': 54,
          'status': 'completed',
        },
        'assessment': {
          'developmental': {
            'gm_dq': 100.0,
            'fm_dq': 100.0,
            'lc_dq': 90.0,
            'cog_dq': 90.0,
            'se_dq': 90.0,
            'composite_dq': 94.0,
          },
          'risk': {
            'gm_delay': false,
            'fm_delay': false,
            'lc_delay': false,
            'cog_delay': false,
            'se_delay': false,
            'num_delays': 0,
          },
          'nutrition': {
            'height_cm': 110.0,
            'weight_kg': 18.5,
            'height_z_score': 0.2,
            'weight_z_score': 0.1,
            'nutrition_risk': 'Low',
          },
          'baseline_risk': {
            'overall_risk_category': 'LOW',
            'referral_needed': false,
            'intervention_priority': 'LOW',
            'primary_concern': 'None',
          },
          'environment_caregiving': {
            'total_score': 82,
            'max_score': 90,
            'percentage': 91.1,
            'risk_level': 'Low',
            'interaction_score': 9,
            'stimulation_score': 9,
            'materials_score': 9,
            'engagement_score': 9,
            'language_score': 9,
            'amenities_score': 9,
            'components': {
              'Parent-Child Interaction': {'score': 9, 'max': 9, 'status': 'Adequate'},
              'Home Stimulation': {'score': 9, 'max': 9, 'status': 'Adequate'},
              'Play Materials': {'score': 9, 'max': 9, 'status': 'Adequate'},
              'Caregiver Engagement': {'score': 9, 'max': 9, 'status': 'Adequate'},
              'Language Exposure': {'score': 9, 'max': 9, 'status': 'Adequate'},
              'Basic Amenities': {'score': 9, 'max': 9, 'status': 'Adequate'},
            }
          }
        }
      };
    }
    
    // Default mock result for any other session ID - MEDIUM risk
    return {
      'session': {
        'session_id': sessionId,
        'child_id': sessionId,
        'assessment_date': DateTime.now().toIso8601String().split('T')[0],
        'child_age_months': 30,
        'status': 'completed',
      },
      'assessment': {
        'developmental': {
          'gm_dq': 95.0,
          'fm_dq': 90.0,
          'lc_dq': 75.0,
          'cog_dq': 85.0,
          'se_dq': 90.0,
          'composite_dq': 87.0,
        },
        'risk': {
          'gm_delay': false,
          'fm_delay': false,
          'lc_delay': true,
          'cog_delay': false,
          'se_delay': false,
          'num_delays': 1,
        },
        'nutrition': {
          'height_cm': 90.0,
          'weight_kg': 12.5,
          'height_z_score': -0.3,
          'weight_z_score': -0.5,
          'nutrition_risk': 'Low',
        },
        'baseline_risk': {
          'overall_risk_category': 'MEDIUM',
          'referral_needed': false,
          'intervention_priority': 'MODERATE',
          'primary_concern': 'Language delay',
        }
      }
    };
  } catch (e) {
    return null;
  }
});
