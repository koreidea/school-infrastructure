import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'screening_provider.dart';
import 'screening_results_storage.dart';
import 'children_provider.dart';
import '../services/admin_supabase_service.dart';
import '../services/database_service.dart';

/// Domain codes for developmental domains
class DomainCodes {
  static const String gm = 'gm'; // Gross Motor
  static const String fm = 'fm'; // Fine Motor
  static const String lc = 'lc'; // Language & Communication
  static const String cog = 'cog'; // Cognitive
  static const String se = 'se'; // Social-Emotional
}

/// Domain display names
final domainNames = {
  DomainCodes.gm: {'en': 'Gross Motor', 'te': 'స్థూల చలనం'},
  DomainCodes.fm: {'en': 'Fine Motor', 'te': 'సూక్ష్మ చలనం'},
  DomainCodes.lc: {'en': 'Language', 'te': 'భాష'},
  DomainCodes.cog: {'en': 'Cognitive', 'te': 'జ్ఞానాత్మకం'},
  DomainCodes.se: {'en': 'Social-Emotional', 'te': 'సామాజిక-భావోద్వేగ'},
};

/// Risk level display names
final riskLevelNames = {
  'HIGH': {'en': 'High Priority', 'te': 'అధిక ప్రాధాన్యత'},
  'MEDIUM': {'en': 'Medium Priority', 'te': 'మధ్యస్థ ప్రాధాన్యత'},
  'LOW': {'en': 'Low Priority', 'te': 'తక్కువ ప్రాధాన్యత'},
};

/// Complete activity database with all activities
final allActivities = [
  // ==========================================================================
  // GROSS MOTOR (GM) ACTIVITIES
  // ==========================================================================
  {
    'activity_code': 'GM_001',
    'domain': DomainCodes.gm,
    'activity_title': 'Tummy Time Play',
    'activity_title_te': 'పొట్టపై ఆడుకోవడం',
    'activity_description': 'Place baby on tummy for 10-15 minutes several times a day. Use colorful toys to encourage lifting head and reaching.',
    'activity_description_te': 'రోజుకు కొన్నిసార్లు 10-15 నిమిషాల పాటు బాబును పొట్టపై ఉంచండి. తల పైకి ఎత్తడం మరియు చేరడం ప్రోత్సహించడానికి రంగురంగుల బొమ్మలను ఉపయోగించండి.',
    'materials_needed': 'Soft mat, colorful toys, mirror',
    'materials_needed_te': 'మెత్తని పరుపు, రంగురంగుల బొమ్మలు, అద్దం',
    'duration_minutes': 15,
    'min_age_months': 0,
    'max_age_months': 6,
    'has_video': true,
    'risk_level': 'MEDIUM',
  },
  {
    'activity_code': 'GM_002',
    'domain': DomainCodes.gm,
    'activity_title': 'Ball Games',
    'activity_title_te': 'బంతి ఆటలు',
    'activity_description': 'Roll a ball back and forth with the child. Progress to throwing, catching, and kicking as they develop.',
    'activity_description_te': 'బిడ్డతో బంతిని ముందుకు వెనక్కి రోల్ చేయండి. వారు అభివృద్ధి చెందినప్పుడు ఎగరేయడం, పట్టుకోవడం మరియు కొట్టడానికి పురోగతి సాధించండి.',
    'materials_needed': 'Soft ball, open space',
    'materials_needed_te': 'మృదువైన బంతి, ఖాళీ స్థలం',
    'duration_minutes': 20,
    'min_age_months': 12,
    'max_age_months': 60,
    'has_video': true,
    'risk_level': 'LOW',
  },
  {
    'activity_code': 'GM_003',
    'domain': DomainCodes.gm,
    'activity_title': 'Jumping Exercises',
    'activity_title_te': 'దుముకు వ్యాయామాలు',
    'activity_description': 'Practice jumping on the spot, then progress to jumping forward, over lines, and from small heights.',
    'activity_description_te': 'అదే స్థలంలో దుమకడం అభ్యాసం చేయండి, తర్వాత ముందుకు, గీతలపై నుండి మరియు చిన్న ఎత్తు నుండి దుమకడానికి పురోగతి సాధించండి.',
    'materials_needed': 'Soft surface, chalk for lines',
    'materials_needed_te': 'మృదువైన ఉపరితలం, గీతల కోసం చాక్',
    'duration_minutes': 15,
    'min_age_months': 24,
    'max_age_months': 60,
    'has_video': true,
    'risk_level': 'MEDIUM',
  },
  {
    'activity_code': 'GM_004',
    'domain': DomainCodes.gm,
    'activity_title': 'Obstacle Course',
    'activity_title_te': 'అడ్డంకి మార్గం',
    'activity_description': 'Create a simple obstacle course with cushions, chairs, and toys to climb over, crawl under, and walk around.',
    'activity_description_te': 'దాటవేయడం, కింద నడక మరియు చుట్టూ నడవడానికి దిండులు, కుర్చీలు మరియు బొమ్మలతో ఒక సాధారణ అడ్డంకి మార్గాన్ని సృష్టించండి.',
    'materials_needed': 'Cushions, chairs, soft toys',
    'materials_needed_te': 'దిండులు, కుర్చీలు, మృదువైన బొమ్మలు',
    'duration_minutes': 20,
    'min_age_months': 18,
    'max_age_months': 60,
    'has_video': true,
    'risk_level': 'MEDIUM',
  },
  {
    'activity_code': 'GM_005',
    'domain': DomainCodes.gm,
    'activity_title': 'Crawling Practice',
    'activity_title_te': 'పాకడం అభ్యాసం',
    'activity_description': 'Encourage crawling by placing toys just out of reach. Create tunnels with boxes for fun.',
    'activity_description_te': 'అందుబాటులో లేని బొమ్మలను ఉంచడం ద్వారా పాకడం ప్రోత్సహించండి. సరదా కోసం పెట్టెలతో టన్నెల్స్ సృష్టించండి.',
    'materials_needed': 'Toys, cardboard boxes',
    'materials_needed_te': 'బొమ్మలు, కార్డ్‌బోర్డ్ పెట్టెలు',
    'duration_minutes': 15,
    'min_age_months': 6,
    'max_age_months': 18,
    'has_video': true,
    'risk_level': 'MEDIUM',
  },
  {
    'activity_code': 'GM_006',
    'domain': DomainCodes.gm,
    'activity_title': 'Walking Support',
    'activity_title_te': 'నడక మద్దతు',
    'activity_description': 'Hold child\'s hands and help them walk. Use push toys for independent practice.',
    'activity_description_te': 'బిడ్డ చేతులు పట్టుకుని నడవడంలో సహాయపడండి. స్వతంత్ర అభ్యాసం కోసం పుష్ బొమ్మలను ఉపయోగించండి.',
    'materials_needed': 'Push toy, furniture for support',
    'materials_needed_te': 'పుష్ బొమ్మ, మద్దతు కోసం ఫర్నిచర్',
    'duration_minutes': 15,
    'min_age_months': 9,
    'max_age_months': 18,
    'has_video': true,
    'risk_level': 'HIGH',
  },
  
  // ==========================================================================
  // FINE MOTOR (FM) ACTIVITIES
  // ==========================================================================
  {
    'activity_code': 'FM_001',
    'domain': DomainCodes.fm,
    'activity_title': 'Block Stacking',
    'activity_title_te': 'బ్లాకులు అగ్గి పెట్టడం',
    'activity_description': 'Show child how to stack blocks. Start with 2-3 blocks and progress to taller towers.',
    'activity_description_te': 'బ్లాకులు అగ్గి పెట్టడం ఎలాగో చూపించండి. 2-3 బ్లాకులతో ప్రారంభించి పొడవైన టవర్లకు పురోగతి సాధించండి.',
    'materials_needed': 'Wooden blocks or soft blocks',
    'materials_needed_te': 'లోహపు లేదా మృదువైన బ్లాకులు',
    'duration_minutes': 15,
    'min_age_months': 12,
    'max_age_months': 36,
    'has_video': true,
    'risk_level': 'LOW',
  },
  {
    'activity_code': 'FM_002',
    'domain': DomainCodes.fm,
    'activity_title': 'Drawing and Coloring',
    'activity_title_te': 'గీయడం మరియు రంగులు వేయడం',
    'activity_description': 'Provide crayons and paper. Start with scribbling and progress to shapes and pictures.',
    'activity_description_te': 'క్రేయాన్లు మరియు కాగితం అందించండి. గీకడంతో ప్రారంభించి ఆకారాలు మరియు చిత్రాలకు పురోగతి సాధించండి.',
    'materials_needed': 'Crayons, paper, coloring books',
    'materials_needed_te': 'క్రేయాన్లు, కాగితం, రంగుల పుస్తకాలు',
    'duration_minutes': 20,
    'min_age_months': 18,
    'max_age_months': 60,
    'has_video': true,
    'risk_level': 'LOW',
  },
  {
    'activity_code': 'FM_003',
    'domain': DomainCodes.fm,
    'activity_title': 'Puzzle Solving',
    'activity_title_te': 'పజిల్ పరిష్కరణ',
    'activity_description': 'Start with simple shape puzzles and progress to more complex picture puzzles.',
    'activity_description_te': 'సాధారణ ఆకార పజిల్స్ తో ప్రారంభించి మరింత సంక్లిష్టమైన చిత్ర పజిల్స్ కు పురోగతి సాధించండి.',
    'materials_needed': 'Age-appropriate puzzles',
    'materials_needed_te': 'వయసుకు తగిన పజిల్స్',
    'duration_minutes': 20,
    'min_age_months': 24,
    'max_age_months': 60,
    'has_video': true,
    'risk_level': 'MEDIUM',
  },
  {
    'activity_code': 'FM_004',
    'domain': DomainCodes.fm,
    'activity_title': 'Play Dough',
    'activity_title_te': 'పిండి ఆట',
    'activity_description': 'Use play dough to squeeze, roll, pinch, and create shapes. Great for finger strength.',
    'activity_description_te': 'పిండిని పిండడం, రోల్ చేయడం, పించ్ చేయడం మరియు ఆకారాలు సృష్టించడానికి ఉపయోగించండి. వేలు బలం కోసం గొప్పది.',
    'materials_needed': 'Play dough, rolling pin, cookie cutters',
    'materials_needed_te': 'ప్లే డో, రోలింగ్ పిన్, కుకీ కట్టర్స్',
    'duration_minutes': 25,
    'min_age_months': 18,
    'max_age_months': 60,
    'has_video': true,
    'risk_level': 'LOW',
  },
  {
    'activity_code': 'FM_005',
    'domain': DomainCodes.fm,
    'activity_title': 'Bead Threading',
    'activity_title_te': 'ముక్కలు త్రిప్పడం',
    'activity_description': 'Thread large beads onto a string. Progress to smaller beads as skills improve.',
    'activity_description_te': 'పెద్ద ముక్కలను దారంలోకి త్రిప్పండి. నైపుణ్యాలు మెరుగైనప్పుడు చిన్న ముక్కలకు పురోగతి సాధించండి.',
    'materials_needed': 'Large beads, thick string, shoelace',
    'materials_needed_te': 'పెద్ద ముక్కలు, మందపాటి దారం, షూ‌లేస్',
    'duration_minutes': 15,
    'min_age_months': 24,
    'max_age_months': 48,
    'has_video': true,
    'risk_level': 'MEDIUM',
  },
  {
    'activity_code': 'FM_006',
    'domain': DomainCodes.fm,
    'activity_title': 'Scissor Practice',
    'activity_title_te': 'కత్తిరించే కత్తుల అభ్యాసం',
    'activity_description': 'Practice cutting straight lines, then curves and shapes with child-safe scissors.',
    'activity_description_te': 'నేరుగా గీతలను కత్తిరించడం అభ్యాసం చేయండి, తర్వాత బిడ్డ-సురక్షిత కత్తులతో వంపులు మరియు ఆకారాలు.',
    'materials_needed': 'Child-safe scissors, paper',
    'materials_needed_te': 'బిడ్డ-సురక్షిత కత్తులు, కాగితం',
    'duration_minutes': 15,
    'min_age_months': 36,
    'max_age_months': 60,
    'has_video': true,
    'risk_level': 'MEDIUM',
  },
  
  // ==========================================================================
  // LANGUAGE & COMMUNICATION (LC) ACTIVITIES
  // ==========================================================================
  {
    'activity_code': 'LC_001',
    'domain': DomainCodes.lc,
    'activity_title': 'Picture Book Reading',
    'activity_title_te': 'బొమ్మల పుస్తకం చదవడం',
    'activity_description': 'Read picture books daily. Point to pictures, name objects, and ask questions.',
    'activity_description_te': 'రోజువారీగా బొమ్మల పుస్తకాలు చదవండి. బొమ్మలను చూపించి, వస్తువుల పేర్లు చెప్పండి మరియు ప్రశ్నలు అడగండి.',
    'materials_needed': 'Picture books, comfortable seating',
    'materials_needed_te': 'బొమ్మల పుస్తకాలు, సౌకర్యవంతమైన కూర్చోడం',
    'duration_minutes': 20,
    'min_age_months': 6,
    'max_age_months': 60,
    'has_video': true,
    'risk_level': 'HIGH',
  },
  {
    'activity_code': 'LC_002',
    'domain': DomainCodes.lc,
    'activity_title': 'Storytelling Time',
    'activity_title_te': 'కథ చెప్పే సమయం',
    'activity_description': 'Tell simple stories using puppets or toys. Encourage child to repeat or continue the story.',
    'activity_description_te': 'పప్పెట్లు లేదా బొమ్మలను ఉపయోగించి సాధారణ కథలు చెప్పండి. కథను పునరావృతం చేయడం లేదా కొనసాగించడం ప్రోత్సహించండి.',
    'materials_needed': 'Puppets, stuffed animals, story books',
    'materials_needed_te': 'పప్పెట్లు, స్టఫ్డ్ జంతువులు, కథా పుస్తకాలు',
    'duration_minutes': 20,
    'min_age_months': 24,
    'max_age_months': 60,
    'has_video': true,
    'risk_level': 'HIGH',
  },
  {
    'activity_code': 'LC_003',
    'domain': DomainCodes.lc,
    'activity_title': 'Word Games',
    'activity_title_te': 'పదాల ఆటలు',
    'activity_description': 'Play rhyming games, naming games, and simple word associations.',
    'activity_description_te': 'యమకాల ఆటలు, పేర్లు చెప్పే ఆటలు మరియు సాధారణ పద సంబంధాలు ఆడండి.',
    'materials_needed': 'Flash cards, picture cards',
    'materials_needed_te': 'ఫ్లాష్ కార్డులు, చిత్ర కార్డులు',
    'duration_minutes': 15,
    'min_age_months': 36,
    'max_age_months': 60,
    'has_video': true,
    'risk_level': 'MEDIUM',
  },
  {
    'activity_code': 'LC_004',
    'domain': DomainCodes.lc,
    'activity_title': 'Nursery Rhymes',
    'activity_title_te': 'పాటలు మరియు పద్యాలు',
    'activity_description': 'Sing nursery rhymes together. Use actions and encourage child to sing along.',
    'activity_description_te': 'కలిసి పాటలు పాడండి. చర్యలను ఉపయోగించి బిడ్డ కలిసి పాడటం ప్రోత్సహించండి.',
    'materials_needed': 'No materials needed',
    'materials_needed_te': 'సామాగ్రి అవసరం లేదు',
    'duration_minutes': 15,
    'min_age_months': 12,
    'max_age_months': 48,
    'has_video': true,
    'risk_level': 'MEDIUM',
  },
  {
    'activity_code': 'LC_005',
    'domain': DomainCodes.lc,
    'activity_title': 'Daily Conversation',
    'activity_title_te': 'రోజువారీ సంభాషణ',
    'activity_description': 'Talk about daily activities, ask open-ended questions, and wait for responses.',
    'activity_description_te': 'రోజువారీ కార్యకలాపాల గురించి మాట్లాడండి, ఓపెన్-ఎండెడ్ ప్రశ్నలు అడగండి మరియు స్పందనల కోసం వేచి ఉండండి.',
    'materials_needed': 'No materials needed',
    'materials_needed_te': 'సామాగ్రి అవసరం లేదు',
    'duration_minutes': 30,
    'min_age_months': 18,
    'max_age_months': 60,
    'has_video': false,
    'risk_level': 'HIGH',
  },
  {
    'activity_code': 'LC_006',
    'domain': DomainCodes.lc,
    'activity_title': 'Name Labeling',
    'activity_title_te': 'పేర్లు లేబులింగ్',
    'activity_description': 'Label objects around the house. Point and name them regularly.',
    'activity_description_te': 'ఇంటి చుట్టూ ఉన్న వస్తువులకు లేబుల్స్ వేయండి. నియమితంగా చూపించి పేర్లు చెప్పండి.',
    'materials_needed': 'Labels, markers',
    'materials_needed_te': 'లేబుల్స్, మార్కర్లు',
    'duration_minutes': 15,
    'min_age_months': 18,
    'max_age_months': 36,
    'has_video': false,
    'risk_level': 'MEDIUM',
  },
  
  // ==========================================================================
  // COGNITIVE (COG) ACTIVITIES
  // ==========================================================================
  {
    'activity_code': 'COG_001',
    'domain': DomainCodes.cog,
    'activity_title': 'Sorting Games',
    'activity_title_te': 'వర్గీకరణ ఆటలు',
    'activity_description': 'Sort objects by color, shape, or size. Start with 2 categories and add more.',
    'activity_description_te': 'రంగు, ఆకారం లేదా పరిమాణం ప్రకారం వస్తువులను వర్గీకరించండి. 2 వర్గాలతో ప్రారంభించి మరింత చేర్చండి.',
    'materials_needed': 'Colorful objects, bowls for sorting',
    'materials_needed_te': 'రంగురంగుల వస్తువులు, వర్గీకరణ కోసం గిన్నెలు',
    'duration_minutes': 15,
    'min_age_months': 24,
    'max_age_months': 48,
    'has_video': true,
    'risk_level': 'MEDIUM',
  },
  {
    'activity_code': 'COG_002',
    'domain': DomainCodes.cog,
    'activity_title': 'Pretend Play',
    'activity_title_te': 'నటనా ఆట',
    'activity_description': 'Engage in pretend play like cooking, shopping, or doctor visits with toys.',
    'activity_description_te': 'బొమ్మలతో వంట, షాపింగ్, లేదా డాక్టర్ సందర్శనల వంటి నటనా ఆటలో పాల్గొనండి.',
    'materials_needed': 'Play kitchen, toy food, dolls',
    'materials_needed_te': 'ప్లే కిచెన్, బొమ్మ ఆహారం, బొమ్మలు',
    'duration_minutes': 30,
    'min_age_months': 24,
    'max_age_months': 60,
    'has_video': true,
    'risk_level': 'LOW',
  },
  {
    'activity_code': 'COG_003',
    'domain': DomainCodes.cog,
    'activity_title': 'Matching Games',
    'activity_title_te': 'జతపరచే ఆటలు',
    'activity_description': 'Match identical pictures, shapes, or objects. Progress to memory games.',
    'activity_description_te': 'ఒకే విధమైన చిత్రాలు, ఆకారాలు లేదా వస్తువులను జతపరచండి. మెమరీ ఆటలకు పురోగతి సాధించండి.',
    'materials_needed': 'Matching cards, memory game sets',
    'materials_needed_te': 'జతపరచే కార్డులు, మెమరీ గేమ్ సెట్లు',
    'duration_minutes': 15,
    'min_age_months': 24,
    'max_age_months': 60,
    'has_video': true,
    'risk_level': 'LOW',
  },
  {
    'activity_code': 'COG_004',
    'domain': DomainCodes.cog,
    'activity_title': 'Hide and Seek',
    'activity_title_te': 'దాచుకొని వెతకడం',
    'activity_description': 'Hide toys and ask child to find them. Helps develop object permanence.',
    'activity_description_te': 'బొమ్మలను దాచి బిడ్డ వాటిని కనుగొనమని అడగండి. ఆబ్జెక్ట్ పర్మనెన్స్ అభివృద్ధి చెందడానికి సహాయపడుతుంది.',
    'materials_needed': 'Toys to hide, blanket',
    'materials_needed_te': 'దాచడానికి బొమ్మలు, బ్లాంకెట్',
    'duration_minutes': 15,
    'min_age_months': 9,
    'max_age_months': 36,
    'has_video': true,
    'risk_level': 'LOW',
  },
  {
    'activity_code': 'COG_005',
    'domain': DomainCodes.cog,
    'activity_title': 'Counting Games',
    'activity_title_te': 'లెక్కింపు ఆటలు',
    'activity_description': 'Count objects during daily activities. Use fingers, toys, or steps.',
    'activity_description_te': 'రోజువారీ కార్యకలాపాలలో వస్తువులను లెక్కించండి. వేళ్లు, బొమ్మలు లేదా మెట్లను ఉపయోగించండి.',
    'materials_needed': 'Objects to count',
    'materials_needed_te': 'లెక్కించడానికి వస్తువులు',
    'duration_minutes': 15,
    'min_age_months': 30,
    'max_age_months': 60,
    'has_video': false,
    'risk_level': 'MEDIUM',
  },
  {
    'activity_code': 'COG_006',
    'domain': DomainCodes.cog,
    'activity_title': 'Building with Blocks',
    'activity_title_te': 'బ్లాకులతో నిర్మాణం',
    'activity_description': 'Build structures together. Discuss shapes, sizes, and balance.',
    'activity_description_te': 'కలిసి నిర్మాణాలు కట్టండి. ఆకారాలు, పరిమాణాలు మరియు సమతుల్యత గురించి చర్చించండి.',
    'materials_needed': 'Building blocks, LEGO (age-appropriate)',
    'materials_needed_te': 'బిల్డింగ్ బ్లాకులు, లెగో (వయసుకు తగిన)',
    'duration_minutes': 25,
    'min_age_months': 24,
    'max_age_months': 60,
    'has_video': true,
    'risk_level': 'LOW',
  },
  
  // ==========================================================================
  // SOCIAL-EMOTIONAL (SE) ACTIVITIES
  // ==========================================================================
  {
    'activity_code': 'SE_001',
    'domain': DomainCodes.se,
    'activity_title': 'Play Dates',
    'activity_title_te': 'స్నేహితులతో ఆట',
    'activity_description': 'Arrange play dates with other children. Supervise and guide interactions.',
    'activity_description_te': 'ఇతర పిల్లలతో ప్లే డేట్స్ ఏర్పాటు చేయండి. పరస్పర చర్యలను పర్యవేక్షించి మార్గనిర్దేశం చేయండి.',
    'materials_needed': 'Toys for sharing, snacks',
    'materials_needed_te': 'పంచుకోవడానికి బొమ్మలు, స్నాక్స్',
    'duration_minutes': 60,
    'min_age_months': 24,
    'max_age_months': 60,
    'has_video': false,
    'risk_level': 'HIGH',
  },
  {
    'activity_code': 'SE_002',
    'domain': DomainCodes.se,
    'activity_title': 'Sharing Activities',
    'activity_title_te': 'పంచుకోవడం కార్యకలాపాలు',
    'activity_description': 'Practice taking turns and sharing toys. Use timer if needed.',
    'activity_description_te': 'వారీలు తీసుకోవడం మరియు బొమ్మలను పంచుకోవడం అభ్యాసం చేయండి. అవసరమైతే టైమర్ ఉపయోగించండి.',
    'materials_needed': 'Toys to share, timer',
    'materials_needed_te': 'పంచుకోవడానికి బొమ్మలు, టైమర్',
    'duration_minutes': 20,
    'min_age_months': 24,
    'max_age_months': 48,
    'has_video': true,
    'risk_level': 'HIGH',
  },
  {
    'activity_code': 'SE_003',
    'domain': DomainCodes.se,
    'activity_title': 'Emotion Recognition',
    'activity_title_te': 'భావోద్వేగాల గుర్తింపు',
    'activity_description': 'Use emotion cards or mirror to practice making and recognizing different facial expressions.',
    'activity_description_te': 'వివిధ ముఖ కవళికలను చేయడం మరియు గుర్తించడం అభ్యాసం చేయడానికి ఎమోషన్ కార్డులు లేదా అద్దాన్ని ఉపయోగించండి.',
    'materials_needed': 'Emotion cards, mirror',
    'materials_needed_te': 'ఎమోషన్ కార్డులు, అద్దం',
    'duration_minutes': 15,
    'min_age_months': 24,
    'max_age_months': 60,
    'has_video': true,
    'risk_level': 'MEDIUM',
  },
  {
    'activity_code': 'SE_004',
    'domain': DomainCodes.se,
    'activity_title': 'Role Play',
    'activity_title_te': 'పాత్ర నటన',
    'activity_description': 'Act out different social situations like greeting, sharing, or apologizing.',
    'activity_description_te': 'శుభాకాంక్షలు, పంచుకోవడం, లేదా క్షమాపణలు వంటి వివిధ సామాజిక పరిస్థితులను నటించండి.',
    'materials_needed': 'Puppets, dress-up clothes',
    'materials_needed_te': 'పప్పెట్లు, డ్రెస్-అప్ బట్టలు',
    'duration_minutes': 20,
    'min_age_months': 30,
    'max_age_months': 60,
    'has_video': true,
    'risk_level': 'MEDIUM',
  },
  {
    'activity_code': 'SE_005',
    'domain': DomainCodes.se,
    'activity_title': 'Cooperative Games',
    'activity_title_te': 'సహకార ఆటలు',
    'activity_description': 'Play games that require working together rather than competing.',
    'activity_description_te': 'పోటీ కాకుండా కలిసి పనిచేయడం అవసరమైన ఆటలను ఆడండి.',
    'materials_needed': 'Ball, parachute, building materials',
    'materials_needed_te': 'బంతి, పారాషూట్, నిర్మాణ సామగ్రి',
    'duration_minutes': 20,
    'min_age_months': 36,
    'max_age_months': 60,
    'has_video': true,
    'risk_level': 'MEDIUM',
  },
  {
    'activity_code': 'SE_006',
    'domain': DomainCodes.se,
    'activity_title': 'Daily Routines',
    'activity_title_te': 'రోజువారీ కార్యక్రమాలు',
    'activity_description': 'Establish consistent daily routines. Use visual schedules to help child understand what comes next.',
    'activity_description_te': 'స్థిరమైన రోజువారీ కార్యక్రమాలను ఏర్పాటు చేయండి. తర్వాత ఏమి వస్తుందో అర్థం చేసుకోవడంలో బిడ్డకు సహాయపడటానికి దృశ్యమాన షెడ్యూల్‌లను ఉపయోగించండి.',
    'materials_needed': 'Visual schedule cards, chart',
    'materials_needed_te': 'దృశ్యమాన షెడ్యూల్ కార్డులు, చార్ట్',
    'duration_minutes': 30,
    'min_age_months': 18,
    'max_age_months': 60,
    'has_video': false,
    'risk_level': 'LOW',
  },
];

/// Step-by-step instructions and tips for each activity (bilingual)
final activityGuidance = <String, Map<String, String>>{
  // ─── GROSS MOTOR ───
  'GM_001': {
    'steps': '1. Lay a soft mat on a flat surface\n2. Place baby on tummy gently\n3. Place a colorful toy in front at eye level\n4. Encourage baby to lift head by talking softly\n5. Gradually increase duration from 3 to 15 minutes',
    'steps_te': '1. చదునైన ఉపరితలం మీద మెత్తని పరుపు వేయండి\n2. బాబును మెల్లగా పొట్టపై ఉంచండి\n3. కంటి స్థాయిలో ముందు రంగురంగుల బొమ్మను ఉంచండి\n4. మెల్లగా మాట్లాడుతూ తల పైకి ఎత్తమని ప్రోత్సహించండి\n5. 3 నుండి 15 నిమిషాల వరకు క్రమంగా సమయం పెంచండి',
    'tips': 'Always supervise during tummy time. Stop if baby cries excessively. Try after diaper changes when baby is alert.',
    'tips_te': 'పొట్టపై ఆట సమయంలో ఎల్లప్పుడూ పర్యవేక్షించండి. బాబు ఎక్కువగా ఏడిస్తే ఆపండి. డైపర్ మార్చిన తర్వాత బాబు అప్రమత్తంగా ఉన్నప్పుడు ప్రయత్నించండి.',
  },
  'GM_002': {
    'steps': '1. Sit across from the child on the floor\n2. Roll a soft ball gently towards the child\n3. Encourage the child to roll it back\n4. Progress to bouncing and catching\n5. Try gentle kicking when the child is ready',
    'steps_te': '1. నేలపై బిడ్డ ఎదురుగా కూర్చోండి\n2. మృదువైన బంతిని మెల్లగా బిడ్డ వైపు రోల్ చేయండి\n3. తిరిగి రోల్ చేయమని బిడ్డను ప్రోత్సహించండి\n4. బౌన్సింగ్ మరియు క్యాచింగ్‌కు పురోగతి సాధించండి\n5. బిడ్డ సిద్ధంగా ఉన్నప్పుడు మెల్లగా కిక్కింగ్ ప్రయత్నించండి',
    'tips': 'Use a lightweight ball that is easy to grip. Play in a safe open space. Praise every attempt.',
    'tips_te': 'పట్టుకోవడం సులభమైన తేలికపాటి బంతిని ఉపయోగించండి. సురక్షితమైన ఖాళీ ప్రదేశంలో ఆడండి. ప్రతి ప్రయత్నాన్ని మెచ్చుకోండి.',
  },
  'GM_003': {
    'steps': '1. Stand in front of the child and demonstrate jumping\n2. Hold child\'s hands and help them jump\n3. Draw lines on the floor to jump over\n4. Create a hopping game with spots\n5. Celebrate each successful jump',
    'steps_te': '1. బిడ్డ ముందు నిలబడి దూకడం ప్రదర్శించండి\n2. బిడ్డ చేతులు పట్టుకుని దూకడంలో సహాయపడండి\n3. దూకడానికి నేలపై గీతలు గీయండి\n4. మచ్చలతో హాపింగ్ ఆటను సృష్టించండి\n5. ప్రతి విజయవంతమైన దూకడాన్ని ఆనందించండి',
    'tips': 'Ensure soft landing surface. Start with small jumps. Never force the child. Make it a fun game.',
    'tips_te': 'మెత్తని ల్యాండింగ్ ఉపరితలం ఉండేలా చూడండి. చిన్న దూకడాలతో ప్రారంభించండి. బిడ్డను ఎప్పుడూ బలవంతం చేయకండి. సరదా ఆటగా మార్చండి.',
  },
  'GM_004': {
    'steps': '1. Arrange cushions in a line to climb over\n2. Place a chair to crawl under\n3. Set up a path to walk around objects\n4. Guide the child through the course\n5. Let the child try independently',
    'steps_te': '1. ఎక్కడానికి దిండులను వరుసగా అమర్చండి\n2. కింద నడవడానికి కుర్చీ ఉంచండి\n3. వస్తువుల చుట్టూ నడవడానికి మార్గం ఏర్పాటు చేయండి\n4. కోర్సు ద్వారా బిడ్డను మార్గనిర్దేశం చేయండి\n5. బిడ్డ స్వతంత్రంగా ప్రయత్నించనివ్వండి',
    'tips': 'Remove sharp objects. Keep obstacles low and safe. Change the course layout to keep it interesting.',
    'tips_te': 'పదునైన వస్తువులను తొలగించండి. అడ్డంకులను తక్కువగా మరియు సురక్షితంగా ఉంచండి. ఆసక్తికరంగా ఉంచడానికి కోర్సు రూపకల్పనను మార్చండి.',
  },
  'GM_005': {
    'steps': '1. Place favorite toy just out of reach\n2. Encourage baby to move towards the toy\n3. Create a cardboard box tunnel\n4. Place toys inside the tunnel as motivation\n5. Cheer and clap as baby crawls through',
    'steps_te': '1. ఇష్టమైన బొమ్మను అందుబాటులో లేని చోట ఉంచండి\n2. బొమ్మ వైపు కదలమని బాబును ప్రోత్సహించండి\n3. కార్డ్‌బోర్డ్ బాక్స్ టన్నెల్ సృష్టించండి\n4. ప్రేరణగా టన్నెల్ లోపల బొమ్మలు ఉంచండి\n5. బాబు పాకుతున్నప్పుడు చప్పట్లు కొట్టి ఉత్సాహపరచండి',
    'tips': 'Ensure clean floor. Watch for small objects baby might put in mouth. Keep sessions short and fun.',
    'tips_te': 'శుభ్రమైన నేల ఉండేలా చూడండి. బాబు నోటిలో పెట్టుకునే చిన్న వస్తువులను గమనించండి. సెషన్లను చిన్నగా మరియు సరదాగా ఉంచండి.',
  },
  'GM_006': {
    'steps': '1. Hold child\'s hands while standing\n2. Walk slowly letting child take steps\n3. Offer push toy for support\n4. Use furniture edges for cruising\n5. Gradually reduce support as confidence grows',
    'steps_te': '1. నిలబడి ఉన్నప్పుడు బిడ్డ చేతులు పట్టుకోండి\n2. బిడ్డ అడుగులు వేయనిస్తూ మెల్లగా నడవండి\n3. మద్దతు కోసం పుష్ బొమ్మను అందించండి\n4. క్రూజింగ్ కోసం ఫర్నిచర్ అంచులను ఉపయోగించండి\n5. ఆత్మవిశ్వాసం పెరిగేకొద్దీ క్రమంగా మద్దతు తగ్గించండి',
    'tips': 'Let child set the pace. Ensure safe environment with padded corners. Barefoot walking helps balance.',
    'tips_te': 'బిడ్డ వేగాన్ని నిర్ణయించనివ్వండి. పాడెడ్ మూలలతో సురక్షిత వాతావరణం ఉండేలా చూడండి. నేరుగా కాళ్ళతో నడక సమతుల్యతకు సహాయపడుతుంది.',
  },

  // ─── FINE MOTOR ───
  'FM_001': {
    'steps': '1. Place 2-3 blocks in front of the child\n2. Demonstrate stacking one block on another\n3. Guide child\'s hand to place a block\n4. Let child try alone\n5. Increase number of blocks as skill improves',
    'steps_te': '1. బిడ్డ ముందు 2-3 బ్లాకులు ఉంచండి\n2. ఒక బ్లాక్ మీద మరొకటి పెట్టడం ప్రదర్శించండి\n3. బ్లాక్ ఉంచడానికి బిడ్డ చేతిని మార్గనిర్దేశం చేయండి\n4. బిడ్డ ఒంటరిగా ప్రయత్నించనివ్వండి\n5. నైపుణ్యం మెరుగుపడేకొద్దీ బ్లాకుల సంఖ్య పెంచండి',
    'tips': 'Use large, easy-to-grip blocks first. Celebrate tower building AND tower knocking down. Both develop skills!',
    'tips_te': 'మొదట పెద్ద, పట్టుకోవడం సులభమైన బ్లాకులు ఉపయోగించండి. టవర్ నిర్మాణం మరియు కూలగొట్టడం రెండింటినీ ఆనందించండి. రెండూ నైపుణ్యాలను అభివృద్ధి చేస్తాయి!',
  },
  'FM_002': {
    'steps': '1. Give child thick crayons and large paper\n2. Demonstrate scribbling\n3. Draw simple shapes for child to copy\n4. Name colors while drawing\n5. Progress to drawing people, houses, etc.',
    'steps_te': '1. బిడ్డకు మందపాటి క్రేయాన్లు మరియు పెద్ద కాగితం ఇవ్వండి\n2. గీకడం ప్రదర్శించండి\n3. బిడ్డ కాపీ చేయడానికి సాధారణ ఆకారాలు గీయండి\n4. గీస్తూ రంగుల పేర్లు చెప్పండి\n5. మనుషులు, ఇళ్ళు మొదలైనవి గీయడానికి పురోగతి సాధించండి',
    'tips': 'Tape paper to table to prevent sliding. Let child choose colors. Display artwork to boost confidence.',
    'tips_te': 'జారకుండా కాగితాన్ని టేబుల్‌కు టేప్ చేయండి. బిడ్డను రంగులు ఎంచుకోనివ్వండి. ఆత్మవిశ్వాసం పెంచడానికి కళాకృతిని ప్రదర్శించండి.',
  },
  'FM_003': {
    'steps': '1. Start with 3-4 piece shape puzzles\n2. Show how pieces fit into holes\n3. Point to matching shapes\n4. Let child try inserting pieces\n5. Increase puzzle complexity gradually',
    'steps_te': '1. 3-4 ముక్కల ఆకార పజిల్స్ తో ప్రారంభించండి\n2. ముక్కలు రంధ్రాలలో ఎలా సరిపోతాయో చూపించండి\n3. సరిపోయే ఆకారాలను చూపించండి\n4. బిడ్డ ముక్కలను ఇన్సర్ట్ చేయడం ప్రయత్నించనివ్వండి\n5. క్రమంగా పజిల్ సంక్లిష్టతను పెంచండి',
    'tips': 'Start with knob puzzles for easier grip. Help without doing it for the child. Praise effort, not just success.',
    'tips_te': 'సులభంగా పట్టుకోవడానికి నాబ్ పజిల్స్ తో ప్రారంభించండి. బిడ్డ కోసం చేయకుండా సహాయపడండి. విజయాన్ని మాత్రమే కాకుండా ప్రయత్నాన్ని మెచ్చుకోండి.',
  },
  'FM_004': {
    'steps': '1. Give child a ball of play dough\n2. Show how to squeeze and pinch it\n3. Roll dough into snakes and balls\n4. Press cookie cutters into flat dough\n5. Create simple shapes and objects',
    'steps_te': '1. బిడ్డకు ప్లే డో ముద్ద ఇవ్వండి\n2. పిండడం మరియు పించ్ చేయడం ఎలాగో చూపించండి\n3. పాములు మరియు బంతుల్లా రోల్ చేయండి\n4. చదునైన పిండిలో కుకీ కట్టర్‌లను నొక్కండి\n5. సాధారణ ఆకారాలు మరియు వస్తువులను సృష్టించండి',
    'tips': 'Homemade dough: flour, salt, water, oil. Supervise to prevent eating. Great activity for rainy days.',
    'tips_te': 'ఇంట్లో తయారు చేసిన పిండి: పిండి, ఉప్పు, నీరు, నూనె. తినకుండా పర్యవేక్షించండి. వర్షపు రోజులకు గొప్ప కార్యకలాపం.',
  },
  'FM_005': {
    'steps': '1. Use large beads and thick string/shoelace\n2. Show how to push the string through the bead hole\n3. Guide child\'s hands for the first few beads\n4. Let child continue independently\n5. Progress to smaller beads over time',
    'steps_te': '1. పెద్ద ముక్కలు మరియు మందపాటి దారం/షూ లేస్ ఉపయోగించండి\n2. ముక్కల రంధ్రం ద్వారా దారాన్ని ఎలా పుష్ చేయాలో చూపించండి\n3. మొదటి కొన్ని ముక్కలకు బిడ్డ చేతులను మార్గనిర్దేశం చేయండి\n4. బిడ్డ స్వతంత్రంగా కొనసాగనివ్వండి\n5. కాలక్రమంలో చిన్న ముక్కలకు పురోగతి సాధించండి',
    'tips': 'Tape one end of string to prevent beads from falling off. Count beads together for math practice.',
    'tips_te': 'ముక్కలు జారిపోకుండా దారం ఒక చివర టేప్ చేయండి. గణిత అభ్యాసం కోసం కలిసి ముక్కలు లెక్కించండి.',
  },
  'FM_006': {
    'steps': '1. Teach safe scissor grip (thumb on top)\n2. Practice opening and closing scissors\n3. Cut along a straight line drawn on paper\n4. Progress to curved lines\n5. Try cutting out simple shapes',
    'steps_te': '1. సురక్షిత కత్తిరి పట్టు నేర్పించండి (బొటనవేలు పైన)\n2. కత్తిరి తెరవడం మరియు మూయడం అభ్యాసం చేయండి\n3. కాగితంపై గీసిన సరళ రేఖ వెంట కత్తిరించండి\n4. వంపు గీతలకు పురోగతి సాధించండి\n5. సాధారణ ఆకారాలను కత్తిరించడం ప్రయత్నించండి',
    'tips': 'Always use child-safe scissors. Sit beside the child to guide. Cut thick paper or cardboard first as it is easier.',
    'tips_te': 'ఎల్లప్పుడూ పిల్లల-సురక్షిత కత్తిరిని ఉపయోగించండి. మార్గనిర్దేశం చేయడానికి బిడ్డ పక్కన కూర్చోండి. సులభం కాబట్టి మొదట మందపాటి కాగితం లేదా కార్డ్‌బోర్డ్ కత్తిరించండి.',
  },

  // ─── LANGUAGE & COMMUNICATION ───
  'LC_001': {
    'steps': '1. Choose a colorful picture book\n2. Sit comfortably with child in your lap\n3. Point to pictures and name objects\n4. Ask "What is this?" and wait\n5. Read expressively with different voices',
    'steps_te': '1. రంగురంగుల బొమ్మల పుస్తకం ఎంచుకోండి\n2. బిడ్డను ఒడిలో పెట్టుకుని సౌకర్యంగా కూర్చోండి\n3. బొమ్మలను చూపించి వస్తువుల పేర్లు చెప్పండి\n4. "ఇది ఏమిటి?" అని అడిగి వేచి ఉండండి\n5. వివిధ గొంతుతో భావోద్వేగంగా చదవండి',
    'tips': 'Read the same book multiple times — repetition helps learning. Let child turn pages. Follow the child\'s interest.',
    'tips_te': 'ఒకే పుస్తకాన్ని అనేక సార్లు చదవండి — పునరావృతం నేర్చుకోవడానికి సహాయపడుతుంది. బిడ్డ పేజీలు తిప్పనివ్వండి. బిడ్డ ఆసక్తిని అనుసరించండి.',
  },
  'LC_002': {
    'steps': '1. Choose a simple story with repetition\n2. Use puppets or toys as characters\n3. Change your voice for different characters\n4. Pause and let child fill in words\n5. Ask child to retell the story',
    'steps_te': '1. పునరావృతంతో సాధారణ కథ ఎంచుకోండి\n2. పాత్రలుగా పప్పెట్లు లేదా బొమ్మలు ఉపయోగించండి\n3. వేర్వేరు పాత్రలకు మీ గొంతు మార్చండి\n4. ఆపి బిడ్డ పదాలు పూరించనివ్వండి\n5. కథ తిరిగి చెప్పమని బిడ్డను అడగండి',
    'tips': 'Use local folk tales the child can relate to. Add sound effects for engagement. Make it interactive, not a lecture.',
    'tips_te': 'బిడ్డ సంబంధించగల స్థానిక జానపద కథలు ఉపయోగించండి. నిమగ్నత కోసం శబ్ద ప్రభావాలు జోడించండి. ఉపన్యాసం కాకుండా సంభాషణాత్మకంగా చేయండి.',
  },
  'LC_003': {
    'steps': '1. Show picture cards one at a time\n2. Name the object and ask child to repeat\n3. Play "I spy" with objects in the room\n4. Say a word and ask child to rhyme\n5. Play "What starts with..." sound game',
    'steps_te': '1. ఒక్కొక్కటిగా చిత్ర కార్డులు చూపించండి\n2. వస్తువు పేరు చెప్పి బిడ్డను పునరావృతం చేయమని అడగండి\n3. గదిలోని వస్తువులతో "నేను చూస్తున్నాను" ఆడండి\n4. ఒక పదం చెప్పి బిడ్డను యమకం చేయమని అడగండి\n5. "దేనితో మొదలవుతుంది..." శబ్ద ఆట ఆడండి',
    'tips': 'Accept approximate pronunciations. Expand on child\'s words ("Dog!" → "Yes, a big brown dog!").',
    'tips_te': 'సుమారు ఉచ్చారణలను అంగీకరించండి. బిడ్డ పదాలను విస్తరించండి ("కుక్క!" → "అవును, పెద్ద గోధుమ రంగు కుక్క!").',
  },
  'LC_004': {
    'steps': '1. Choose familiar rhymes\n2. Sing slowly with actions\n3. Repeat the same rhyme several times\n4. Pause and let child complete lines\n5. Add hand clapping or body movements',
    'steps_te': '1. తెలిసిన పద్యాలు ఎంచుకోండి\n2. చర్యలతో నెమ్మదిగా పాడండి\n3. ఒకే పద్యాన్ని అనేక సార్లు పునరావృతం చేయండి\n4. ఆపి బిడ్డ పంక్తులు పూర్తి చేయనివ్వండి\n5. చేతి చప్పట్లు లేదా శరీర కదలికలు జోడించండి',
    'tips': 'Telugu nursery rhymes like "Chinnari chitti" work well. Sing during bath time and meal time too.',
    'tips_te': '"చిన్నారి చిట్టి" వంటి తెలుగు పద్యాలు బాగా పనిచేస్తాయి. స్నానం మరియు భోజన సమయంలో కూడా పాడండి.',
  },
  'LC_005': {
    'steps': '1. Talk about what you are doing throughout the day\n2. Ask simple questions about daily activities\n3. Wait patiently for the child to respond\n4. Expand on what the child says\n5. Use mealtimes and walks for conversation',
    'steps_te': '1. రోజంతా మీరు ఏమి చేస్తున్నారో మాట్లాడండి\n2. రోజువారీ కార్యకలాపాల గురించి సాధారణ ప్రశ్నలు అడగండి\n3. బిడ్డ స్పందించడానికి ఓపికగా వేచి ఉండండి\n4. బిడ్డ చెప్పేదాన్ని విస్తరించండి\n5. సంభాషణ కోసం భోజన సమయాలు మరియు నడకలు ఉపయోగించండి',
    'tips': 'Avoid baby talk. Use real words. Do not correct grammar — just model correct usage naturally.',
    'tips_te': 'శిశు భాష ఉపయోగించకండి. నిజమైన పదాలు ఉపయోగించండి. వ్యాకరణాన్ని సరిదిద్దకండి — సహజంగా సరైన వాడకాన్ని ప్రదర్శించండి.',
  },
  'LC_006': {
    'steps': '1. Write object names on sticky notes\n2. Stick labels on objects (table, door, chair)\n3. Point to label and say the word\n4. Ask child "Where is the ___?"\n5. Add new labels as child learns words',
    'steps_te': '1. స్టిక్కీ నోట్స్ పై వస్తువుల పేర్లు రాయండి\n2. వస్తువులపై లేబుల్స్ అతికించండి (టేబుల్, తలుపు, కుర్చీ)\n3. లేబుల్ చూపించి పదం చెప్పండి\n4. బిడ్డను "___ ఎక్కడ?" అని అడగండి\n5. బిడ్డ పదాలు నేర్చుకునేకొద్దీ కొత్త లేబుల్స్ జోడించండి',
    'tips': 'Use both Telugu and English labels. Include body parts, family members, and food items.',
    'tips_te': 'తెలుగు మరియు ఆంగ్లం రెండు లేబుల్స్ ఉపయోగించండి. శరీర భాగాలు, కుటుంబ సభ్యులు మరియు ఆహార పదార్థాలను చేర్చండి.',
  },

  // ─── COGNITIVE ───
  'COG_001': {
    'steps': '1. Gather objects of 2-3 different colors\n2. Place colored bowls as sorting containers\n3. Demonstrate putting red objects in the red bowl\n4. Let child sort independently\n5. Add shape and size sorting as skill grows',
    'steps_te': '1. 2-3 వేర్వేరు రంగుల వస్తువులను సేకరించండి\n2. వర్గీకరణ కంటైనర్లుగా రంగు గిన్నెలు ఉంచండి\n3. ఎరుపు వస్తువులను ఎరుపు గిన్నెలో పెట్టడం ప్రదర్శించండి\n4. బిడ్డ స్వతంత్రంగా వర్గీకరించనివ్వండి\n5. నైపుణ్యం పెరిగేకొద్దీ ఆకారం మరియు పరిమాణ వర్గీకరణ జోడించండి',
    'tips': 'Use everyday items like spoons, lids, fruits. Make it a clean-up game. "Let\'s put all the red toys away!"',
    'tips_te': 'చెంచాలు, మూతలు, పండ్లు వంటి రోజువారీ వస్తువులు ఉపయోగించండి. శుభ్రం చేసే ఆటగా మార్చండి. "అన్ని ఎరుపు బొమ్మలు పెట్టేద్దాం!"',
  },
  'COG_002': {
    'steps': '1. Set up a play kitchen or shop\n2. Take on a role (customer, patient, etc.)\n3. Use toy food, dishes, or tools\n4. Follow the child\'s lead in play\n5. Introduce new scenarios gradually',
    'steps_te': '1. ప్లే కిచెన్ లేదా షాప్ ఏర్పాటు చేయండి\n2. పాత్ర పోషించండి (కస్టమర్, రోగి, మొదలైనవి)\n3. బొమ్మ ఆహారం, గిన్నెలు లేదా పరికరాలు ఉపయోగించండి\n4. ఆటలో బిడ్డ నాయకత్వాన్ని అనుసరించండి\n5. క్రమంగా కొత్త సన్నివేశాలను పరిచయం చేయండి',
    'tips': 'Pretend play builds imagination, language, and social skills together. Join the play, don\'t direct it.',
    'tips_te': 'నటనా ఆట ఊహాశక్తి, భాష మరియు సామాజిక నైపుణ్యాలను కలిపి నిర్మిస్తుంది. ఆటలో చేరండి, దర్శకత్వం చేయకండి.',
  },
  'COG_003': {
    'steps': '1. Start with 3-4 pairs of matching cards\n2. Place cards face up first\n3. Find matching pairs together\n4. Turn cards face down for memory challenge\n5. Take turns flipping two cards at a time',
    'steps_te': '1. 3-4 జతల జతపరచే కార్డులతో ప్రారంభించండి\n2. మొదట కార్డులను ముఖం పైకి ఉంచండి\n3. కలిసి జతపరచే జతలను కనుగొనండి\n4. మెమరీ సవాలు కోసం కార్డులను ముఖం కిందికి తిప్పండి\n5. ఒక్కొక్కరు రెండు కార్డులను తిప్పడం ఆడండి',
    'tips': 'Make your own cards with drawings or photos. Start easy, increase pairs gradually.',
    'tips_te': 'డ్రాయింగ్‌లు లేదా ఫోటోలతో మీ స్వంత కార్డులు తయారు చేయండి. సులభంగా ప్రారంభించండి, క్రమంగా జతలను పెంచండి.',
  },
  'COG_004': {
    'steps': '1. Show child a favorite toy\n2. Hide it under a blanket while child watches\n3. Ask "Where is the toy?"\n4. Celebrate when child finds it\n5. Progress to hiding in harder spots',
    'steps_te': '1. బిడ్డకు ఇష్టమైన బొమ్మ చూపించండి\n2. బిడ్డ చూస్తుండగా బ్లాంకెట్ కింద దాచండి\n3. "బొమ్మ ఎక్కడ?" అని అడగండి\n4. బిడ్డ కనుగొన్నప్పుడు ఆనందించండి\n5. కష్టమైన ప్రదేశాలలో దాచడానికి పురోగతి సాధించండి',
    'tips': 'This game teaches object permanence — that things exist even when hidden. Critical cognitive milestone!',
    'tips_te': 'ఈ ఆట ఆబ్జెక్ట్ పర్మనెన్స్ నేర్పిస్తుంది — దాచినా వస్తువులు ఉన్నాయని. క్లిష్టమైన జ్ఞానాత్మక మైలురాయి!',
  },
  'COG_005': {
    'steps': '1. Count objects during meals (1 roti, 2 rotis...)\n2. Count steps while climbing stairs\n3. Count fingers and toes together\n4. Use counting songs\n5. Count items during grocery shopping',
    'steps_te': '1. భోజన సమయంలో వస్తువులను లెక్కించండి (1 రోటీ, 2 రోటీలు...)\n2. మెట్లు ఎక్కుతూ అడుగులు లెక్కించండి\n3. కలిసి వేళ్ళు మరియు కాలి వేళ్ళు లెక్కించండి\n4. లెక్కించే పాటలు ఉపయోగించండి\n5. కిరాణా షాపింగ్ సమయంలో వస్తువులు లెక్కించండి',
    'tips': 'Counting in daily life is more effective than drilling numbers. Use Telugu numbers first, then English.',
    'tips_te': 'రోజువారీ జీవితంలో లెక్కించడం సంఖ్యలు బట్టీ పట్టడం కంటే ఎక్కువ ప్రభావవంతం. మొదట తెలుగు సంఖ్యలు, తర్వాత ఆంగ్లం ఉపయోగించండి.',
  },
  'COG_006': {
    'steps': '1. Start with a few blocks and build a simple tower\n2. Build a house or bridge together\n3. Talk about which block goes where\n4. Discuss big/small, tall/short concepts\n5. Let child design their own structures',
    'steps_te': '1. కొన్ని బ్లాకులతో ప్రారంభించి సాధారణ టవర్ నిర్మించండి\n2. కలిసి ఇల్లు లేదా వంతెన నిర్మించండి\n3. ఏ బ్లాక్ ఎక్కడ ఉంచాలో మాట్లాడండి\n4. పెద్ద/చిన్న, పొడవు/పొట్టి భావనలు చర్చించండి\n5. బిడ్డ వారి స్వంత నిర్మాణాలను రూపొందించనివ్వండి',
    'tips': 'Don\'t worry about "correct" buildings. Creative exploration matters more than following instructions.',
    'tips_te': '"సరైన" భవనాల గురించి ఆందోళన పడకండి. సూచనలను అనుసరించడం కంటే సృజనాత్మక అన్వేషణ ఎక్కువ ముఖ్యం.',
  },

  // ─── SOCIAL-EMOTIONAL ───
  'SE_001': {
    'steps': '1. Invite one child over for a short play date\n2. Prepare a few shared toys\n3. Stay nearby to supervise\n4. Guide sharing and turn-taking\n5. Keep sessions short (30-60 minutes)',
    'steps_te': '1. చిన్న ప్లే డేట్ కోసం ఒక బిడ్డను ఆహ్వానించండి\n2. కొన్ని పంచుకునే బొమ్మలు సిద్ధం చేయండి\n3. పర్యవేక్షించడానికి దగ్గరలో ఉండండి\n4. పంచుకోవడం మరియు వారీ తీసుకోవడం మార్గనిర్దేశం చేయండి\n5. సెషన్లను చిన్నగా ఉంచండి (30-60 నిమిషాలు)',
    'tips': 'Don\'t force sharing — guide gently. Conflicts are learning opportunities. Keep first play dates short.',
    'tips_te': 'పంచుకోవడానికి బలవంతం చేయకండి — మెల్లగా మార్గనిర్దేశం చేయండి. సంఘర్షణలు నేర్చుకునే అవకాశాలు. మొదటి ప్లే డేట్‌లను చిన్నగా ఉంచండి.',
  },
  'SE_002': {
    'steps': '1. Explain "taking turns" with a toy\n2. Use a timer: "Your turn for 2 minutes"\n3. Model sharing with another adult\n4. Praise when child shares voluntarily\n5. Practice with siblings or playmates',
    'steps_te': '1. బొమ్మతో "వారీలు తీసుకోవడం" వివరించండి\n2. టైమర్ ఉపయోగించండి: "2 నిమిషాలు మీ వారీ"\n3. మరొక పెద్దవారితో పంచుకోవడం నమూనా చూపించండి\n4. బిడ్డ స్వచ్ఛందంగా పంచుకున్నప్పుడు మెచ్చుకోండి\n5. తోబుట్టువులు లేదా ఆటగాళ్ళతో అభ్యాసం చేయండి',
    'tips': 'Visual timers work better than verbal ones. "First you, then me" is easier to understand than "share".',
    'tips_te': 'దృశ్యమాన టైమర్లు మాటల కంటే బాగా పనిచేస్తాయి. "మొదట నువ్వు, తర్వాత నేను" అనేది "పంచుకో" కంటే అర్థం చేసుకోవడం సులభం.',
  },
  'SE_003': {
    'steps': '1. Show emotion cards (happy, sad, angry, scared)\n2. Make the face and name the emotion\n3. Ask child to copy the expression\n4. Talk about when they feel that way\n5. Use stories to discuss character emotions',
    'steps_te': '1. ఎమోషన్ కార్డులు చూపించండి (ఆనందం, బాధ, కోపం, భయం)\n2. ముఖం చేసి భావోద్వేగం పేరు చెప్పండి\n3. బిడ్డను కవళిక కాపీ చేయమని అడగండి\n4. వారు ఆ విధంగా ఎప్పుడు అనుభవిస్తారో మాట్లాడండి\n5. పాత్ర భావోద్వేగాలను చర్చించడానికి కథలు ఉపయోగించండి',
    'tips': 'Validate all emotions: "It\'s okay to feel angry." Help name feelings throughout the day.',
    'tips_te': 'అన్ని భావోద్వేగాలను ధ్రువీకరించండి: "కోపంగా అనిపించడం సరే." రోజంతా భావాలకు పేరు పెట్టడంలో సహాయపడండి.',
  },
  'SE_004': {
    'steps': '1. Choose a social scenario (going to shop, meeting a friend)\n2. Assign roles (you and the child)\n3. Act out greeting, requesting, thanking\n4. Switch roles\n5. Discuss what felt comfortable or difficult',
    'steps_te': '1. సామాజిక సన్నివేశం ఎంచుకోండి (షాపుకు వెళ్ళడం, స్నేహితుడిని కలవడం)\n2. పాత్రలు కేటాయించండి (మీరు మరియు బిడ్డ)\n3. శుభాకాంక్షలు, అభ్యర్థించడం, ధన్యవాదాలు నటించండి\n4. పాత్రలు మారండి\n5. ఏది సౌకర్యంగా లేదా కష్టంగా అనిపించిందో చర్చించండి',
    'tips': 'Practice greetings in Telugu: "Namaskaram", "Baagunnara?". Real-life practice reinforces role play.',
    'tips_te': 'తెలుగులో శుభాకాంక్షలు అభ్యాసం చేయండి: "నమస్కారం", "బాగున్నారా?". నిజ జీవిత అభ్యాసం పాత్ర నటనను బలపరుస్తుంది.',
  },
  'SE_005': {
    'steps': '1. Choose a game requiring teamwork\n2. Explain the goal: "We win together"\n3. Play parachute or ball passing games\n4. Build something together as a team\n5. Celebrate group achievements',
    'steps_te': '1. జట్టు పనిని అవసరమయ్యే ఆటను ఎంచుకోండి\n2. లక్ష్యం వివరించండి: "మనం కలిసి గెలుస్తాం"\n3. పారాషూట్ లేదా బంతి పాస్ చేసే ఆటలు ఆడండి\n4. జట్టుగా కలిసి ఏదైనా నిర్మించండి\n5. సమూహ విజయాలను ఆనందించండి',
    'tips': 'Avoid competitive games for children who struggle socially. Cooperative games build confidence first.',
    'tips_te': 'సామాజికంగా కష్టపడే పిల్లలకు పోటీ ఆటలు నివారించండి. సహకార ఆటలు మొదట ఆత్మవిశ్వాసాన్ని పెంచుతాయి.',
  },
  'SE_006': {
    'steps': '1. Create a visual daily schedule with pictures\n2. Show morning routine: wake up → brush → breakfast\n3. Post the schedule where child can see it\n4. Follow the routine consistently\n5. Let child check off completed tasks',
    'steps_te': '1. బొమ్మలతో దృశ్యమాన రోజువారీ షెడ్యూల్ సృష్టించండి\n2. ఉదయ దినచర్య చూపించండి: నిద్ర లేవడం → పళ్ళు తోముకోవడం → అల్పాహారం\n3. బిడ్డ చూడగలిగే చోట షెడ్యూల్ ఉంచండి\n4. దినచర్యను స్థిరంగా అనుసరించండి\n5. పూర్తయిన పనులను బిడ్డ చెక్ ఆఫ్ చేయనివ్వండి',
    'tips': 'Routines reduce anxiety and build independence. Be consistent but flexible when needed.',
    'tips_te': 'దినచర్యలు ఆందోళనను తగ్గించి స్వాతంత్ర్యాన్ని నిర్మిస్తాయి. స్థిరంగా ఉండండి కానీ అవసరమైనప్పుడు అనువైనంగా ఉండండి.',
  },
};

/// Get guidance content for an activity
Map<String, String>? getActivityGuidance(String activityCode) {
  return activityGuidance[activityCode];
}

/// DB-backed activities provider: loads from Supabase (web), Drift (mobile),
/// falls back to hardcoded allActivities.
final dbActivitiesProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  // On web, try Supabase directly (no Drift)
  if (kIsWeb) {
    try {
      final rows = await AdminSupabaseService.getActivities();
      if (rows.isNotEmpty) return rows;
    } catch (_) {
      // Supabase unavailable — fall through to hardcoded
    }
    return allActivities;
  }

  try {
    final db = DatabaseService.db;
    final dbActivities = await db.screeningConfigDao.getAllActiveActivities();

    if (dbActivities.isEmpty) return allActivities;

    return dbActivities.map((a) => {
      'activity_code': a.activityCode,
      'domain': a.domain,
      'activity_title': a.titleEn,
      'activity_title_te': a.titleTe,
      'activity_description': a.descriptionEn,
      'activity_description_te': a.descriptionTe,
      'materials_needed': a.materialsEn,
      'materials_needed_te': a.materialsTe,
      'duration_minutes': a.durationMinutes,
      'min_age_months': a.minAgeMonths,
      'max_age_months': a.maxAgeMonths,
      'has_video': a.hasVideo,
      'risk_level': a.riskLevel,
    }).toList();
  } catch (_) {
    return allActivities;
  }
});

/// Get activities filtered by child's delays and age (from a given source list)
List<Map<String, dynamic>> getRecommendedActivitiesFrom({
  required List<Map<String, dynamic>> activities,
  required int childAgeMonths,
  required Map<String, dynamic> delays,
  required String overallRisk,
}) {
  return _filterActivities(
    activities: activities,
    childAgeMonths: childAgeMonths,
    delays: delays,
    overallRisk: overallRisk,
  );
}

/// Get activities filtered by child's delays and age (uses hardcoded allActivities)
List<Map<String, dynamic>> getRecommendedActivities({
  required int childAgeMonths,
  required Map<String, dynamic> delays,
  required String overallRisk,
}) {
  return _filterActivities(
    activities: allActivities,
    childAgeMonths: childAgeMonths,
    delays: delays,
    overallRisk: overallRisk,
  );
}

List<Map<String, dynamic>> _filterActivities({
  required List<Map<String, dynamic>> activities,
  required int childAgeMonths,
  required Map<String, dynamic> delays,
  required String overallRisk,
}) {
  // Extract delay flags
  final gmDelay = delays['gm_delay'] ?? false;
  final fmDelay = delays['fm_delay'] ?? false;
  final lcDelay = delays['lc_delay'] ?? false;
  final cogDelay = delays['cog_delay'] ?? false;
  final seDelay = delays['se_delay'] ?? false;
  
  // Build list of domains with delays
  final domainsWithDelays = <String>[];
  if (gmDelay) domainsWithDelays.add(DomainCodes.gm);
  if (fmDelay) domainsWithDelays.add(DomainCodes.fm);
  if (lcDelay) domainsWithDelays.add(DomainCodes.lc);
  if (cogDelay) domainsWithDelays.add(DomainCodes.cog);
  if (seDelay) domainsWithDelays.add(DomainCodes.se);
  
  // If no delays, return age-appropriate activities from all domains
  if (domainsWithDelays.isEmpty) {
    return activities
      .where((a) =>
        childAgeMonths >= (a['min_age_months'] as int) &&
        childAgeMonths <= (a['max_age_months'] as int))
      .take(6)
      .toList();
  }
  
  // Filter activities by:
  // 1. Domain has delay OR activity is general development
  // 2. Age is appropriate
  // 3. Priority: activities matching delayed domains first
  final recommended = activities.where((activity) {
    final minAge = activity['min_age_months'] as int;
    final maxAge = activity['max_age_months'] as int;
    final activityDomain = activity['domain'] as String;
    // final activityRisk = activity['risk_level'] as String;
    
    // Check age appropriateness
    if (childAgeMonths < minAge || childAgeMonths > maxAge) {
      return false;
    }
    
    // For high/medium risk, focus on delay domains
    // For low risk, include all age-appropriate activities
    if (overallRisk == 'HIGH' || overallRisk == 'MEDIUM') {
      // Prioritize activities for domains with delays
      if (domainsWithDelays.contains(activityDomain)) {
        return true;
      }
      // Include some general activities if few delay-specific ones
      return false;
    }
    
    return true;
  }).toList();
  
  // Sort: delay domain activities first, then by risk level
  recommended.sort((a, b) {
    final aDomain = a['domain'] as String;
    final bDomain = b['domain'] as String;
    final aInDelay = domainsWithDelays.contains(aDomain) ? 0 : 1;
    final bInDelay = domainsWithDelays.contains(bDomain) ? 0 : 1;
    
    if (aInDelay != bInDelay) {
      return aInDelay - bInDelay;
    }
    
    // Then by risk level (HIGH first for delayed domains)
    final riskOrder = {'HIGH': 0, 'MEDIUM': 1, 'LOW': 2};
    return (riskOrder[a['risk_level']] ?? 3) - (riskOrder[b['risk_level']] ?? 3);
  });
  
  return recommended;
}

/// Provider for recommended activities based on screening results
/// Family key: (childId, ageMonths, sessionId) - uses Dart record for value equality
final recommendedActivitiesProvider = FutureProvider.family<List<Map<String, dynamic>>, (int, int, int?)>((ref, params) async {
  final (childId, childAgeMonths, sessionId) = params;

  // Check local screening results first
  final localResults = ref.watch(screeningResultsStorageProvider);
  final savedResult = localResults[childId];

  Map<String, dynamic> delays;
  String overallRisk;

  if (savedResult != null) {
    // Use locally saved screening results
    delays = Map<String, dynamic>.from(savedResult.domainDelays);
    overallRisk = savedResult.overallRisk;

    // Proactive intervention: if predicted HIGH but current LOW/MEDIUM,
    // add predicted risk factor domains as delayed so activities target them
    if (savedResult.predictedRiskScore != null &&
        savedResult.predictedRiskScore! > 50 &&
        overallRisk != 'HIGH' &&
        savedResult.topRiskFactors != null) {
      for (final factor in savedResult.topRiskFactors!) {
        final fl = factor.toLowerCase();
        if (fl.contains('language') || fl.contains('భాష')) {
          delays['lc_delay'] = true;
        }
        if (fl.contains('motor') && fl.contains('gross')) {
          delays['gm_delay'] = true;
        }
        if (fl.contains('motor') && fl.contains('fine')) {
          delays['fm_delay'] = true;
        }
        if (fl.contains('cognitive') || fl.contains('జ్ఞాన')) {
          delays['cog_delay'] = true;
        }
        if (fl.contains('social') || fl.contains('సామాజిక')) {
          delays['se_delay'] = true;
        }
      }
    }
  } else if (sessionId != null) {
    // Fall back to backend results
    delays = {};
    overallRisk = 'LOW';
    try {
      final result = await ref.watch(screeningResultProvider(sessionId).future);
      if (result != null) {
        final assessment = result['assessment'] as Map<String, dynamic>?;
        delays = assessment?['risk'] as Map<String, dynamic>? ?? {};
        final baseline = assessment?['baseline_risk'] as Map<String, dynamic>?;
        overallRisk = baseline?['overall_risk_category'] ?? 'LOW';
      }
    } catch (_) {
      // Backend unavailable, use defaults
    }
  } else {
    delays = {};
    overallRisk = 'LOW';
  }

  // If no screening results, assume no delays
  if (delays.isEmpty) {
    delays = {
      'gm_delay': false,
      'fm_delay': false,
      'lc_delay': false,
      'cog_delay': false,
      'se_delay': false,
    };
  }

  // Load activities from DB (falls back to hardcoded)
  final activitiesSource = await ref.watch(dbActivitiesProvider.future);

  return getRecommendedActivitiesFrom(
    activities: activitiesSource,
    childAgeMonths: childAgeMonths,
    delays: delays,
    overallRisk: overallRisk,
  );
});

/// Legacy interventions provider (kept for compatibility)
final interventionsProvider = FutureProvider.family<List<Map<String, dynamic>>, int>((ref, childId) async {
  // Mock intervention activities
  await Future.delayed(const Duration(milliseconds: 500));
  
  return [
    {
      'activity_code': 'GM_001',
      'domain': 'gm',
      'activity_title': 'Tummy Time Play',
      'activity_title_te': 'పొట్టపై ఆడుకోవడం',
      'activity_description': 'Place baby on tummy for 10-15 minutes several times a day.',
      'activity_description_te': 'రోజుకు కొన్నిసార్లు 10-15 నిమిషాల పాటు బాబును పొట్టపై ఉంచండి.',
      'duration_minutes': 15,
    },
    {
      'activity_code': 'LC_001',
      'domain': 'lc',
      'activity_title': 'Picture Book Reading',
      'activity_title_te': 'బొమ్మల పుస్తకం చదవడం',
      'activity_description': 'Read picture books daily. Point to pictures and name them.',
      'activity_description_te': 'రోజువారీగా బొమ్మల పుస్తకాలు చదవండి. బొమ్మలను చూపించి పేర్లు చెప్పండి.',
      'duration_minutes': 20,
    },
    {
      'activity_code': 'FM_001',
      'domain': 'fm',
      'activity_title': 'Block Stacking',
      'activity_title_te': 'బ్లాకులు అగ్గి పెట్టడం',
      'activity_description': 'Show child how to stack blocks. Start with 2-3 blocks.',
      'activity_description_te': 'బ్లాకులు అగ్గి పెట్టడం ఎలాగో చూపించండి. 2-3 బ్లాకులతో ప్రారంభించండి.',
      'duration_minutes': 15,
    },
  ];
});

/// Selected activity provider
class SelectedActivityNotifier extends Notifier<Map<String, dynamic>?> {
  @override
  Map<String, dynamic>? build() => null;
  
  void set(Map<String, dynamic>? activity) => state = activity;
  void clear() => state = null;
}

final selectedActivityProvider = NotifierProvider<SelectedActivityNotifier, Map<String, dynamic>?>(() {
  return SelectedActivityNotifier();
});

/// Provider for child's delays and risk information
final childDelaysProvider = FutureProvider.family<Map<String, dynamic>?, int>((ref, childId) async {
  try {
    // Get child's screenings to find the latest session
    final screeningsAsync = await ref.watch(childScreeningsProvider(childId).future);
    
    if (screeningsAsync.isEmpty) {
      return null;
    }
    
    final latestScreening = screeningsAsync.first;
    final sessionId = latestScreening['session_id'] as int;
    
    // Get the screening result
    final result = await ref.watch(screeningResultProvider(sessionId).future);
    
    if (result == null) {
      return null;
    }
    
    final assessment = result['assessment'] as Map<String, dynamic>?;
    if (assessment == null) {
      return null;
    }
    
    final risk = assessment['risk'] as Map<String, dynamic>?;
    final baselineRisk = assessment['baseline_risk'] as Map<String, dynamic>?;
    final developmental = assessment['developmental'] as Map<String, dynamic>?;
    
    return {
      'child_id': childId,
      'session_id': sessionId,
      'delays': {
        'gm_delay': risk?['gm_delay'] ?? false,
        'fm_delay': risk?['fm_delay'] ?? false,
        'lc_delay': risk?['lc_delay'] ?? false,
        'cog_delay': risk?['cog_delay'] ?? false,
        'se_delay': risk?['se_delay'] ?? false,
      },
      'domain_scores': {
        'gm_dq': developmental?['gm_dq'] ?? 100.0,
        'fm_dq': developmental?['fm_dq'] ?? 100.0,
        'lc_dq': developmental?['lc_dq'] ?? 100.0,
        'cog_dq': developmental?['cog_dq'] ?? 100.0,
        'se_dq': developmental?['se_dq'] ?? 100.0,
      },
      'overall_risk': baselineRisk?['overall_risk_category'] ?? 'LOW',
      'primary_concern': baselineRisk?['primary_concern'] ?? 'None',
      'num_delays': risk?['num_delays'] ?? 0,
    };
  } catch (e) {
    return null;
  }
});

/// Get activities grouped by domain
Map<String, List<Map<String, dynamic>>> getActivitiesByDomain(List<Map<String, dynamic>> activities) {
  final grouped = <String, List<Map<String, dynamic>>>{};
  
  for (final domain in [DomainCodes.gm, DomainCodes.fm, DomainCodes.lc, DomainCodes.cog, DomainCodes.se]) {
    grouped[domain] = activities.where((a) => a['domain'] == domain).toList();
  }
  
  return grouped;
}

/// Get domain color helper
Color getDomainColor(String domain) {
  switch (domain) {
    case DomainCodes.gm:
      return const Color(0xFF2196F3); // Blue
    case DomainCodes.fm:
      return const Color(0xFF4CAF50); // Green
    case DomainCodes.lc:
      return const Color(0xFFFF9800); // Orange
    case DomainCodes.cog:
      return const Color(0xFF9C27B0); // Purple
    case DomainCodes.se:
      return const Color(0xFFE91E63); // Pink
    default:
      return const Color(0xFF1976D2);
  }
}

/// Get domain icon helper
IconData getDomainIcon(String domain) {
  switch (domain) {
    case DomainCodes.gm:
      return Icons.directions_run;
    case DomainCodes.fm:
      return Icons.back_hand;
    case DomainCodes.lc:
      return Icons.record_voice_over;
    case DomainCodes.cog:
      return Icons.psychology;
    case DomainCodes.se:
      return Icons.people;
    default:
      return Icons.fitness_center;
  }
}

/// Get domain display name
String getDomainDisplayName(String domain, bool isTelugu) {
  final names = domainNames[domain];
  if (names == null) return domain.toUpperCase();
  return isTelugu ? (names['te'] ?? names['en']!) : names['en']!;
}

/// Activity completion tracker provider
class ActivityCompletionNotifier extends Notifier<Map<String, bool>> {
  @override
  Map<String, bool> build() => {};
  
  void toggle(String activityCode) {
    state = {
      ...state,
      activityCode: !(state[activityCode] ?? false),
    };
  }
  
  void setComplete(String activityCode, bool complete) {
    state = {
      ...state,
      activityCode: complete,
    };
  }
  
  bool isCompleted(String activityCode) => state[activityCode] ?? false;
  
  int getCompletedCount() => state.values.where((v) => v).length;
  
  void clear() => state = {};
}

final activityCompletionProvider = NotifierProvider<ActivityCompletionNotifier, Map<String, bool>>(() {
  return ActivityCompletionNotifier();
});
