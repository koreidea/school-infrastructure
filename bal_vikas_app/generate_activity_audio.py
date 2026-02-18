#!/usr/bin/env python3
"""Generate high-quality MP3 audio for all activities using Microsoft Edge TTS."""

import asyncio
import os
import edge_tts

OUTPUT_DIR = "assets/audio/activities"

# Edge TTS voices - high quality neural voices
VOICE_EN = "en-IN-NeerjaNeural"   # Indian English female - warm, clear
VOICE_TE = "te-IN-ShrutiNeural"   # Telugu female - natural

ACTIVITIES = {
    "GM_001": {
        "title_en": "Tummy Time Play",
        "title_te": "పొట్టపై ఆడుకోవడం",
        "desc_en": "Place baby on tummy for 10-15 minutes several times a day. Use colorful toys to encourage lifting head and reaching.",
        "desc_te": "రోజుకు కొన్నిసార్లు 10-15 నిమిషాల పాటు బాబును పొట్టపై ఉంచండి. తల పైకి ఎత్తడం మరియు చేరడం ప్రోత్సహించడానికి రంగురంగుల బొమ్మలను ఉపయోగించండి.",
        "steps_en": "1. Lay a soft mat on a flat surface\n2. Place baby on tummy gently\n3. Place a colorful toy in front at eye level\n4. Encourage baby to lift head by talking softly\n5. Gradually increase duration from 3 to 15 minutes",
        "steps_te": "1. చదునైన ఉపరితలం మీద మెత్తని పరుపు వేయండి\n2. బాబును మెల్లగా పొట్టపై ఉంచండి\n3. కంటి స్థాయిలో ముందు రంగురంగుల బొమ్మను ఉంచండి\n4. మెల్లగా మాట్లాడుతూ తల పైకి ఎత్తమని ప్రోత్సహించండి\n5. 3 నుండి 15 నిమిషాల వరకు క్రమంగా సమయం పెంచండి",
        "tips_en": "Always supervise during tummy time. Stop if baby cries excessively. Try after diaper changes when baby is alert.",
        "tips_te": "పొట్టపై ఆట సమయంలో ఎల్లప్పుడూ పర్యవేక్షించండి. బాబు ఎక్కువగా ఏడిస్తే ఆపండి. డైపర్ మార్చిన తర్వాత బాబు అప్రమత్తంగా ఉన్నప్పుడు ప్రయత్నించండి.",
    },
    "GM_002": {
        "title_en": "Ball Games",
        "title_te": "బంతి ఆటలు",
        "desc_en": "Roll a ball back and forth with the child. Progress to throwing, catching, and kicking as they develop.",
        "desc_te": "బిడ్డతో బంతిని ముందుకు వెనక్కి రోల్ చేయండి. వారు అభివృద్ధి చెందినప్పుడు ఎగరేయడం, పట్టుకోవడం మరియు కొట్టడానికి పురోగతి సాధించండి.",
        "steps_en": "1. Sit across from the child on the floor\n2. Roll a soft ball gently towards the child\n3. Encourage the child to roll it back\n4. Progress to bouncing and catching\n5. Try gentle kicking when the child is ready",
        "steps_te": "1. నేలపై బిడ్డ ఎదురుగా కూర్చోండి\n2. మృదువైన బంతిని మెల్లగా బిడ్డ వైపు రోల్ చేయండి\n3. తిరిగి రోల్ చేయమని బిడ్డను ప్రోత్సహించండి\n4. బౌన్సింగ్ మరియు క్యాచింగ్‌కు పురోగతి సాధించండి\n5. బిడ్డ సిద్ధంగా ఉన్నప్పుడు మెల్లగా కిక్కింగ్ ప్రయత్నించండి",
        "tips_en": "Use a lightweight ball that is easy to grip. Play in a safe open space. Praise every attempt.",
        "tips_te": "పట్టుకోవడం సులభమైన తేలికపాటి బంతిని ఉపయోగించండి. సురక్షితమైన ఖాళీ ప్రదేశంలో ఆడండి. ప్రతి ప్రయత్నాన్ని మెచ్చుకోండి.",
    },
    "GM_003": {
        "title_en": "Jumping Exercises",
        "title_te": "దుముకు వ్యాయామాలు",
        "desc_en": "Practice jumping on the spot, then progress to jumping forward, over lines, and from small heights.",
        "desc_te": "అదే స్థలంలో దుమకడం అభ్యాసం చేయండి, తర్వాత ముందుకు, గీతలపై నుండి మరియు చిన్న ఎత్తు నుండి దుమకడానికి పురోగతి సాధించండి.",
        "steps_en": "1. Stand in front of the child and demonstrate jumping\n2. Hold child's hands and help them jump\n3. Draw lines on the floor to jump over\n4. Create a hopping game with spots\n5. Celebrate each successful jump",
        "steps_te": "1. బిడ్డ ముందు నిలబడి దూకడం ప్రదర్శించండి\n2. బిడ్డ చేతులు పట్టుకుని దూకడంలో సహాయపడండి\n3. దూకడానికి నేలపై గీతలు గీయండి\n4. మచ్చలతో హాపింగ్ ఆటను సృష్టించండి\n5. ప్రతి విజయవంతమైన దూకడాన్ని ఆనందించండి",
        "tips_en": "Ensure soft landing surface. Start with small jumps. Never force the child. Make it a fun game.",
        "tips_te": "మెత్తని ల్యాండింగ్ ఉపరితలం ఉండేలా చూడండి. చిన్న దూకడాలతో ప్రారంభించండి. బిడ్డను ఎప్పుడూ బలవంతం చేయకండి. సరదా ఆటగా మార్చండి.",
    },
    "GM_004": {
        "title_en": "Obstacle Course",
        "title_te": "అడ్డంకి మార్గం",
        "desc_en": "Create a simple obstacle course with cushions, chairs, and toys to climb over, crawl under, and walk around.",
        "desc_te": "దాటవేయడం, కింద నడక మరియు చుట్టూ నడవడానికి దిండులు, కుర్చీలు మరియు బొమ్మలతో ఒక సాధారణ అడ్డంకి మార్గాన్ని సృష్టించండి.",
        "steps_en": "1. Arrange cushions in a line to climb over\n2. Place a chair to crawl under\n3. Set up a path to walk around objects\n4. Guide the child through the course\n5. Let the child try independently",
        "steps_te": "1. ఎక్కడానికి దిండులను వరుసగా అమర్చండి\n2. కింద నడవడానికి కుర్చీ ఉంచండి\n3. వస్తువుల చుట్టూ నడవడానికి మార్గం ఏర్పాటు చేయండి\n4. కోర్సు ద్వారా బిడ్డను మార్గనిర్దేశం చేయండి\n5. బిడ్డ స్వతంత్రంగా ప్రయత్నించనివ్వండి",
        "tips_en": "Remove sharp objects. Keep obstacles low and safe. Change the course layout to keep it interesting.",
        "tips_te": "పదునైన వస్తువులను తొలగించండి. అడ్డంకులను తక్కువగా మరియు సురక్షితంగా ఉంచండి. ఆసక్తికరంగా ఉంచడానికి కోర్సు రూపకల్పనను మార్చండి.",
    },
    "GM_005": {
        "title_en": "Crawling Practice",
        "title_te": "పాకడం అభ్యాసం",
        "desc_en": "Encourage crawling by placing toys just out of reach. Create tunnels with boxes for fun.",
        "desc_te": "అందుబాటులో లేని బొమ్మలను ఉంచడం ద్వారా పాకడం ప్రోత్సహించండి. సరదా కోసం పెట్టెలతో టన్నెల్స్ సృష్టించండి.",
        "steps_en": "1. Place favorite toy just out of reach\n2. Encourage baby to move towards the toy\n3. Create a cardboard box tunnel\n4. Place toys inside the tunnel as motivation\n5. Cheer and clap as baby crawls through",
        "steps_te": "1. ఇష్టమైన బొమ్మను అందుబాటులో లేని చోట ఉంచండి\n2. బొమ్మ వైపు కదలమని బాబును ప్రోత్సహించండి\n3. కార్డ్‌బోర్డ్ బాక్స్ టన్నెల్ సృష్టించండి\n4. ప్రేరణగా టన్నెల్ లోపల బొమ్మలు ఉంచండి\n5. బాబు పాకుతున్నప్పుడు చప్పట్లు కొట్టి ఉత్సాహపరచండి",
        "tips_en": "Ensure clean floor. Watch for small objects baby might put in mouth. Keep sessions short and fun.",
        "tips_te": "శుభ్రమైన నేల ఉండేలా చూడండి. బాబు నోటిలో పెట్టుకునే చిన్న వస్తువులను గమనించండి. సెషన్లను చిన్నగా మరియు సరదాగా ఉంచండి.",
    },
    "GM_006": {
        "title_en": "Walking Support",
        "title_te": "నడక మద్దతు",
        "desc_en": "Hold child's hands and help them walk. Use push toys for independent practice.",
        "desc_te": "బిడ్డ చేతులు పట్టుకుని నడవడంలో సహాయపడండి. స్వతంత్ర అభ్యాసం కోసం పుష్ బొమ్మలను ఉపయోగించండి.",
        "steps_en": "1. Hold child's hands while standing\n2. Walk slowly letting child take steps\n3. Offer push toy for support\n4. Use furniture edges for cruising\n5. Gradually reduce support as confidence grows",
        "steps_te": "1. నిలబడి ఉన్నప్పుడు బిడ్డ చేతులు పట్టుకోండి\n2. బిడ్డ అడుగులు వేయనిస్తూ మెల్లగా నడవండి\n3. మద్దతు కోసం పుష్ బొమ్మను అందించండి\n4. క్రూజింగ్ కోసం ఫర్నిచర్ అంచులను ఉపయోగించండి\n5. ఆత్మవిశ్వాసం పెరిగేకొద్దీ క్రమంగా మద్దతు తగ్గించండి",
        "tips_en": "Let child set the pace. Ensure safe environment with padded corners. Barefoot walking helps balance.",
        "tips_te": "బిడ్డ వేగాన్ని నిర్ణయించనివ్వండి. పాడెడ్ మూలలతో సురక్షిత వాతావరణం ఉండేలా చూడండి. నేరుగా కాళ్ళతో నడక సమతుల్యతకు సహాయపడుతుంది.",
    },
    "FM_001": {
        "title_en": "Block Stacking",
        "title_te": "బ్లాకులు అగ్గి పెట్టడం",
        "desc_en": "Show child how to stack blocks. Start with 2-3 blocks and progress to taller towers.",
        "desc_te": "బ్లాకులు అగ్గి పెట్టడం ఎలాగో చూపించండి. 2-3 బ్లాకులతో ప్రారంభించి పొడవైన టవర్లకు పురోగతి సాధించండి.",
        "steps_en": "1. Place 2-3 blocks in front of the child\n2. Demonstrate stacking one block on another\n3. Guide child's hand to place a block\n4. Let child try alone\n5. Increase number of blocks as skill improves",
        "steps_te": "1. బిడ్డ ముందు 2-3 బ్లాకులు ఉంచండి\n2. ఒక బ్లాక్ మీద మరొకటి పెట్టడం ప్రదర్శించండి\n3. బ్లాక్ ఉంచడానికి బిడ్డ చేతిని మార్గనిర్దేశం చేయండి\n4. బిడ్డ ఒంటరిగా ప్రయత్నించనివ్వండి\n5. నైపుణ్యం మెరుగుపడేకొద్దీ బ్లాకుల సంఖ్య పెంచండి",
        "tips_en": "Use large, easy-to-grip blocks first. Celebrate tower building AND tower knocking down. Both develop skills!",
        "tips_te": "మొదట పెద్ద, పట్టుకోవడం సులభమైన బ్లాకులు ఉపయోగించండి. టవర్ నిర్మాణం మరియు కూలగొట్టడం రెండింటినీ ఆనందించండి. రెండూ నైపుణ్యాలను అభివృద్ధి చేస్తాయి!",
    },
    "FM_002": {
        "title_en": "Drawing and Coloring",
        "title_te": "గీయడం మరియు రంగులు వేయడం",
        "desc_en": "Provide crayons and paper. Start with scribbling and progress to shapes and pictures.",
        "desc_te": "క్రేయాన్లు మరియు కాగితం అందించండి. గీకడంతో ప్రారంభించి ఆకారాలు మరియు చిత్రాలకు పురోగతి సాధించండి.",
        "steps_en": "1. Give child thick crayons and large paper\n2. Demonstrate scribbling\n3. Draw simple shapes for child to copy\n4. Name colors while drawing\n5. Progress to drawing people, houses, etc.",
        "steps_te": "1. బిడ్డకు మందపాటి క్రేయాన్లు మరియు పెద్ద కాగితం ఇవ్వండి\n2. గీకడం ప్రదర్శించండి\n3. బిడ్డ కాపీ చేయడానికి సాధారణ ఆకారాలు గీయండి\n4. గీస్తూ రంగుల పేర్లు చెప్పండి\n5. మనుషులు, ఇళ్ళు మొదలైనవి గీయడానికి పురోగతి సాధించండి",
        "tips_en": "Tape paper to table to prevent sliding. Let child choose colors. Display artwork to boost confidence.",
        "tips_te": "జారకుండా కాగితాన్ని టేబుల్‌కు టేప్ చేయండి. బిడ్డను రంగులు ఎంచుకోనివ్వండి. ఆత్మవిశ్వాసం పెంచడానికి కళాకృతిని ప్రదర్శించండి.",
    },
    "FM_003": {
        "title_en": "Puzzle Solving",
        "title_te": "పజిల్ పరిష్కరణ",
        "desc_en": "Start with simple shape puzzles and progress to more complex picture puzzles.",
        "desc_te": "సాధారణ ఆకార పజిల్స్ తో ప్రారంభించి మరింత సంక్లిష్టమైన చిత్ర పజిల్స్ కు పురోగతి సాధించండి.",
        "steps_en": "1. Start with 3-4 piece shape puzzles\n2. Show how pieces fit into holes\n3. Point to matching shapes\n4. Let child try inserting pieces\n5. Increase puzzle complexity gradually",
        "steps_te": "1. 3-4 ముక్కల ఆకార పజిల్స్ తో ప్రారంభించండి\n2. ముక్కలు రంధ్రాలలో ఎలా సరిపోతాయో చూపించండి\n3. సరిపోయే ఆకారాలను చూపించండి\n4. బిడ్డ ముక్కలను ఇన్సర్ట్ చేయడం ప్రయత్నించనివ్వండి\n5. క్రమంగా పజిల్ సంక్లిష్టతను పెంచండి",
        "tips_en": "Start with knob puzzles for easier grip. Help without doing it for the child. Praise effort, not just success.",
        "tips_te": "సులభంగా పట్టుకోవడానికి నాబ్ పజిల్స్ తో ప్రారంభించండి. బిడ్డ కోసం చేయకుండా సహాయపడండి. విజయాన్ని మాత్రమే కాకుండా ప్రయత్నాన్ని మెచ్చుకోండి.",
    },
    "FM_004": {
        "title_en": "Play Dough",
        "title_te": "పిండి ఆట",
        "desc_en": "Use play dough to squeeze, roll, pinch, and create shapes. Great for finger strength.",
        "desc_te": "పిండిని పిండడం, రోల్ చేయడం, పించ్ చేయడం మరియు ఆకారాలు సృష్టించడానికి ఉపయోగించండి. వేలు బలం కోసం గొప్పది.",
        "steps_en": "1. Give child a ball of play dough\n2. Show how to squeeze and pinch it\n3. Roll dough into snakes and balls\n4. Press cookie cutters into flat dough\n5. Create simple shapes and objects",
        "steps_te": "1. బిడ్డకు ప్లే డో ముద్ద ఇవ్వండి\n2. పిండడం మరియు పించ్ చేయడం ఎలాగో చూపించండి\n3. పాములు మరియు బంతుల్లా రోల్ చేయండి\n4. చదునైన పిండిలో కుకీ కట్టర్‌లను నొక్కండి\n5. సాధారణ ఆకారాలు మరియు వస్తువులను సృష్టించండి",
        "tips_en": "Homemade dough: flour, salt, water, oil. Supervise to prevent eating. Great activity for rainy days.",
        "tips_te": "ఇంట్లో తయారు చేసిన పిండి: పిండి, ఉప్పు, నీరు, నూనె. తినకుండా పర్యవేక్షించండి. వర్షపు రోజులకు గొప్ప కార్యకలాపం.",
    },
    "FM_005": {
        "title_en": "Bead Threading",
        "title_te": "ముక్కలు త్రిప్పడం",
        "desc_en": "Thread large beads onto a string. Progress to smaller beads as skills improve.",
        "desc_te": "పెద్ద ముక్కలను దారంలోకి త్రిప్పండి. నైపుణ్యాలు మెరుగైనప్పుడు చిన్న ముక్కలకు పురోగతి సాధించండి.",
        "steps_en": "1. Use large beads and thick string\n2. Show how to push the string through the bead hole\n3. Guide child's hands for the first few beads\n4. Let child continue independently\n5. Progress to smaller beads over time",
        "steps_te": "1. పెద్ద ముక్కలు మరియు మందపాటి దారం ఉపయోగించండి\n2. ముక్కల రంధ్రం ద్వారా దారాన్ని ఎలా పుష్ చేయాలో చూపించండి\n3. మొదటి కొన్ని ముక్కలకు బిడ్డ చేతులను మార్గనిర్దేశం చేయండి\n4. బిడ్డ స్వతంత్రంగా కొనసాగనివ్వండి\n5. కాలక్రమంలో చిన్న ముక్కలకు పురోగతి సాధించండి",
        "tips_en": "Tape one end of string to prevent beads from falling off. Count beads together for math practice.",
        "tips_te": "ముక్కలు జారిపోకుండా దారం ఒక చివర టేప్ చేయండి. గణిత అభ్యాసం కోసం కలిసి ముక్కలు లెక్కించండి.",
    },
    "FM_006": {
        "title_en": "Scissor Practice",
        "title_te": "కత్తిరించే కత్తుల అభ్యాసం",
        "desc_en": "Practice cutting straight lines, then curves and shapes with child-safe scissors.",
        "desc_te": "నేరుగా గీతలను కత్తిరించడం అభ్యాసం చేయండి, తర్వాత బిడ్డ-సురక్షిత కత్తులతో వంపులు మరియు ఆకారాలు.",
        "steps_en": "1. Teach safe scissor grip\n2. Practice opening and closing scissors\n3. Cut along a straight line drawn on paper\n4. Progress to curved lines\n5. Try cutting out simple shapes",
        "steps_te": "1. సురక్షిత కత్తిరి పట్టు నేర్పించండి\n2. కత్తిరి తెరవడం మరియు మూయడం అభ్యాసం చేయండి\n3. కాగితంపై గీసిన సరళ రేఖ వెంట కత్తిరించండి\n4. వంపు గీతలకు పురోగతి సాధించండి\n5. సాధారణ ఆకారాలను కత్తిరించడం ప్రయత్నించండి",
        "tips_en": "Always use child-safe scissors. Sit beside the child to guide. Cut thick paper or cardboard first as it is easier.",
        "tips_te": "ఎల్లప్పుడూ పిల్లల-సురక్షిత కత్తిరిని ఉపయోగించండి. మార్గనిర్దేశం చేయడానికి బిడ్డ పక్కన కూర్చోండి. సులభం కాబట్టి మొదట మందపాటి కాగితం లేదా కార్డ్‌బోర్డ్ కత్తిరించండి.",
    },
    "LC_001": {
        "title_en": "Picture Book Reading",
        "title_te": "బొమ్మల పుస్తకం చదవడం",
        "desc_en": "Read picture books daily. Point to pictures, name objects, and ask questions.",
        "desc_te": "రోజువారీగా బొమ్మల పుస్తకాలు చదవండి. బొమ్మలను చూపించి, వస్తువుల పేర్లు చెప్పండి మరియు ప్రశ్నలు అడగండి.",
        "steps_en": "1. Choose a colorful picture book\n2. Sit comfortably with child in your lap\n3. Point to pictures and name objects\n4. Ask What is this and wait\n5. Read expressively with different voices",
        "steps_te": "1. రంగురంగుల బొమ్మల పుస్తకం ఎంచుకోండి\n2. బిడ్డను ఒడిలో పెట్టుకుని సౌకర్యంగా కూర్చోండి\n3. బొమ్మలను చూపించి వస్తువుల పేర్లు చెప్పండి\n4. ఇది ఏమిటి అని అడిగి వేచి ఉండండి\n5. వివిధ గొంతుతో భావోద్వేగంగా చదవండి",
        "tips_en": "Read the same book multiple times. Repetition helps learning. Let child turn pages. Follow the child's interest.",
        "tips_te": "ఒకే పుస్తకాన్ని అనేక సార్లు చదవండి. పునరావృతం నేర్చుకోవడానికి సహాయపడుతుంది. బిడ్డ పేజీలు తిప్పనివ్వండి. బిడ్డ ఆసక్తిని అనుసరించండి.",
    },
    "LC_002": {
        "title_en": "Storytelling Time",
        "title_te": "కథ చెప్పే సమయం",
        "desc_en": "Tell simple stories using puppets or toys. Encourage child to repeat or continue the story.",
        "desc_te": "పప్పెట్లు లేదా బొమ్మలను ఉపయోగించి సాధారణ కథలు చెప్పండి. కథను పునరావృతం చేయడం లేదా కొనసాగించడం ప్రోత్సహించండి.",
        "steps_en": "1. Choose a simple story with repetition\n2. Use puppets or toys as characters\n3. Change your voice for different characters\n4. Pause and let child fill in words\n5. Ask child to retell the story",
        "steps_te": "1. పునరావృతంతో సాధారణ కథ ఎంచుకోండి\n2. పాత్రలుగా పప్పెట్లు లేదా బొమ్మలు ఉపయోగించండి\n3. వేర్వేరు పాత్రలకు మీ గొంతు మార్చండి\n4. ఆపి బిడ్డ పదాలు పూరించనివ్వండి\n5. కథ తిరిగి చెప్పమని బిడ్డను అడగండి",
        "tips_en": "Use local folk tales the child can relate to. Add sound effects for engagement. Make it interactive, not a lecture.",
        "tips_te": "బిడ్డ సంబంధించగల స్థానిక జానపద కథలు ఉపయోగించండి. నిమగ్నత కోసం శబ్ద ప్రభావాలు జోడించండి. ఉపన్యాసం కాకుండా సంభాషణాత్మకంగా చేయండి.",
    },
    "LC_003": {
        "title_en": "Word Games",
        "title_te": "పదాల ఆటలు",
        "desc_en": "Play rhyming games, naming games, and simple word associations.",
        "desc_te": "యమకాల ఆటలు, పేర్లు చెప్పే ఆటలు మరియు సాధారణ పద సంబంధాలు ఆడండి.",
        "steps_en": "1. Show picture cards one at a time\n2. Name the object and ask child to repeat\n3. Play I spy with objects in the room\n4. Say a word and ask child to rhyme\n5. Play What starts with sound game",
        "steps_te": "1. ఒక్కొక్కటిగా చిత్ర కార్డులు చూపించండి\n2. వస్తువు పేరు చెప్పి బిడ్డను పునరావృతం చేయమని అడగండి\n3. గదిలోని వస్తువులతో నేను చూస్తున్నాను ఆడండి\n4. ఒక పదం చెప్పి బిడ్డను యమకం చేయమని అడగండి\n5. దేనితో మొదలవుతుంది శబ్ద ఆట ఆడండి",
        "tips_en": "Accept approximate pronunciations. Expand on child's words. For example, when child says Dog, you can say Yes, a big brown dog!",
        "tips_te": "సుమారు ఉచ్చారణలను అంగీకరించండి. బిడ్డ పదాలను విస్తరించండి.",
    },
    "LC_004": {
        "title_en": "Nursery Rhymes",
        "title_te": "పాటలు మరియు పద్యాలు",
        "desc_en": "Sing nursery rhymes together. Use actions and encourage child to sing along.",
        "desc_te": "కలిసి పాటలు పాడండి. చర్యలను ఉపయోగించి బిడ్డ కలిసి పాడటం ప్రోత్సహించండి.",
        "steps_en": "1. Choose familiar rhymes\n2. Sing slowly with actions\n3. Repeat the same rhyme several times\n4. Pause and let child complete lines\n5. Add hand clapping or body movements",
        "steps_te": "1. తెలిసిన పద్యాలు ఎంచుకోండి\n2. చర్యలతో నెమ్మదిగా పాడండి\n3. ఒకే పద్యాన్ని అనేక సార్లు పునరావృతం చేయండి\n4. ఆపి బిడ్డ పంక్తులు పూర్తి చేయనివ్వండి\n5. చేతి చప్పట్లు లేదా శరీర కదలికలు జోడించండి",
        "tips_en": "Telugu nursery rhymes like Chinnari chitti work well. Sing during bath time and meal time too.",
        "tips_te": "చిన్నారి చిట్టి వంటి తెలుగు పద్యాలు బాగా పనిచేస్తాయి. స్నానం మరియు భోజన సమయంలో కూడా పాడండి.",
    },
    "LC_005": {
        "title_en": "Daily Conversation",
        "title_te": "రోజువారీ సంభాషణ",
        "desc_en": "Talk about daily activities, ask open-ended questions, and wait for responses.",
        "desc_te": "రోజువారీ కార్యకలాపాల గురించి మాట్లాడండి, ఓపెన్-ఎండెడ్ ప్రశ్నలు అడగండి మరియు స్పందనల కోసం వేచి ఉండండి.",
        "steps_en": "1. Talk about what you are doing throughout the day\n2. Ask simple questions about daily activities\n3. Wait patiently for the child to respond\n4. Expand on what the child says\n5. Use mealtimes and walks for conversation",
        "steps_te": "1. రోజంతా మీరు ఏమి చేస్తున్నారో మాట్లాడండి\n2. రోజువారీ కార్యకలాపాల గురించి సాధారణ ప్రశ్నలు అడగండి\n3. బిడ్డ స్పందించడానికి ఓపికగా వేచి ఉండండి\n4. బిడ్డ చెప్పేదాన్ని విస్తరించండి\n5. సంభాషణ కోసం భోజన సమయాలు మరియు నడకలు ఉపయోగించండి",
        "tips_en": "Avoid baby talk. Use real words. Do not correct grammar. Just model correct usage naturally.",
        "tips_te": "శిశు భాష ఉపయోగించకండి. నిజమైన పదాలు ఉపయోగించండి. వ్యాకరణాన్ని సరిదిద్దకండి. సహజంగా సరైన వాడకాన్ని ప్రదర్శించండి.",
    },
    "LC_006": {
        "title_en": "Name Labeling",
        "title_te": "పేర్లు లేబులింగ్",
        "desc_en": "Label objects around the house. Point and name them regularly.",
        "desc_te": "ఇంటి చుట్టూ ఉన్న వస్తువులకు లేబుల్స్ వేయండి. నియమితంగా చూపించి పేర్లు చెప్పండి.",
        "steps_en": "1. Write object names on sticky notes\n2. Stick labels on objects like table, door, chair\n3. Point to label and say the word\n4. Ask child Where is the table\n5. Add new labels as child learns words",
        "steps_te": "1. స్టిక్కీ నోట్స్ పై వస్తువుల పేర్లు రాయండి\n2. వస్తువులపై లేబుల్స్ అతికించండి\n3. లేబుల్ చూపించి పదం చెప్పండి\n4. బిడ్డను టేబుల్ ఎక్కడ అని అడగండి\n5. బిడ్డ పదాలు నేర్చుకునేకొద్దీ కొత్త లేబుల్స్ జోడించండి",
        "tips_en": "Use both Telugu and English labels. Include body parts, family members, and food items.",
        "tips_te": "తెలుగు మరియు ఆంగ్లం రెండు లేబుల్స్ ఉపయోగించండి. శరీర భాగాలు, కుటుంబ సభ్యులు మరియు ఆహార పదార్థాలను చేర్చండి.",
    },
    "COG_001": {
        "title_en": "Sorting Games",
        "title_te": "వర్గీకరణ ఆటలు",
        "desc_en": "Sort objects by color, shape, or size. Start with 2 categories and add more.",
        "desc_te": "రంగు, ఆకారం లేదా పరిమాణం ప్రకారం వస్తువులను వర్గీకరించండి. 2 వర్గాలతో ప్రారంభించి మరింత చేర్చండి.",
        "steps_en": "1. Gather objects of 2-3 different colors\n2. Place colored bowls as sorting containers\n3. Demonstrate putting red objects in the red bowl\n4. Let child sort independently\n5. Add shape and size sorting as skill grows",
        "steps_te": "1. 2-3 వేర్వేరు రంగుల వస్తువులను సేకరించండి\n2. వర్గీకరణ కంటైనర్లుగా రంగు గిన్నెలు ఉంచండి\n3. ఎరుపు వస్తువులను ఎరుపు గిన్నెలో పెట్టడం ప్రదర్శించండి\n4. బిడ్డ స్వతంత్రంగా వర్గీకరించనివ్వండి\n5. నైపుణ్యం పెరిగేకొద్దీ ఆకారం మరియు పరిమాణ వర్గీకరణ జోడించండి",
        "tips_en": "Use everyday items like spoons, lids, fruits. Make it a clean-up game.",
        "tips_te": "చెంచాలు, మూతలు, పండ్లు వంటి రోజువారీ వస్తువులు ఉపయోగించండి. శుభ్రం చేసే ఆటగా మార్చండి.",
    },
    "COG_002": {
        "title_en": "Pretend Play",
        "title_te": "నటనా ఆట",
        "desc_en": "Engage in pretend play like cooking, shopping, or doctor visits with toys.",
        "desc_te": "బొమ్మలతో వంట, షాపింగ్, లేదా డాక్టర్ సందర్శనల వంటి నటనా ఆటలో పాల్గొనండి.",
        "steps_en": "1. Set up a play kitchen or shop\n2. Take on a role like customer or patient\n3. Use toy food, dishes, or tools\n4. Follow the child's lead in play\n5. Introduce new scenarios gradually",
        "steps_te": "1. ప్లే కిచెన్ లేదా షాప్ ఏర్పాటు చేయండి\n2. పాత్ర పోషించండి\n3. బొమ్మ ఆహారం, గిన్నెలు లేదా పరికరాలు ఉపయోగించండి\n4. ఆటలో బిడ్డ నాయకత్వాన్ని అనుసరించండి\n5. క్రమంగా కొత్త సన్నివేశాలను పరిచయం చేయండి",
        "tips_en": "Pretend play builds imagination, language, and social skills together. Join the play, don't direct it.",
        "tips_te": "నటనా ఆట ఊహాశక్తి, భాష మరియు సామాజిక నైపుణ్యాలను కలిపి నిర్మిస్తుంది. ఆటలో చేరండి, దర్శకత్వం చేయకండి.",
    },
    "COG_003": {
        "title_en": "Matching Games",
        "title_te": "జతపరచే ఆటలు",
        "desc_en": "Match identical pictures, shapes, or objects. Progress to memory games.",
        "desc_te": "ఒకే విధమైన చిత్రాలు, ఆకారాలు లేదా వస్తువులను జతపరచండి. మెమరీ ఆటలకు పురోగతి సాధించండి.",
        "steps_en": "1. Start with 3-4 pairs of matching cards\n2. Place cards face up first\n3. Find matching pairs together\n4. Turn cards face down for memory challenge\n5. Take turns flipping two cards at a time",
        "steps_te": "1. 3-4 జతల జతపరచే కార్డులతో ప్రారంభించండి\n2. మొదట కార్డులను ముఖం పైకి ఉంచండి\n3. కలిసి జతపరచే జతలను కనుగొనండి\n4. మెమరీ సవాలు కోసం కార్డులను ముఖం కిందికి తిప్పండి\n5. ఒక్కొక్కరు రెండు కార్డులను తిప్పడం ఆడండి",
        "tips_en": "Make your own cards with drawings or photos. Start easy, increase pairs gradually.",
        "tips_te": "డ్రాయింగ్‌లు లేదా ఫోటోలతో మీ స్వంత కార్డులు తయారు చేయండి. సులభంగా ప్రారంభించండి, క్రమంగా జతలను పెంచండి.",
    },
    "COG_004": {
        "title_en": "Hide and Seek",
        "title_te": "దాచుకొని వెతకడం",
        "desc_en": "Hide toys and ask child to find them. Helps develop object permanence.",
        "desc_te": "బొమ్మలను దాచి బిడ్డ వాటిని కనుగొనమని అడగండి. ఆబ్జెక్ట్ పర్మనెన్స్ అభివృద్ధి చెందడానికి సహాయపడుతుంది.",
        "steps_en": "1. Show child a favorite toy\n2. Hide it under a blanket while child watches\n3. Ask Where is the toy\n4. Celebrate when child finds it\n5. Progress to hiding in harder spots",
        "steps_te": "1. బిడ్డకు ఇష్టమైన బొమ్మ చూపించండి\n2. బిడ్డ చూస్తుండగా బ్లాంకెట్ కింద దాచండి\n3. బొమ్మ ఎక్కడ అని అడగండి\n4. బిడ్డ కనుగొన్నప్పుడు ఆనందించండి\n5. కష్టమైన ప్రదేశాలలో దాచడానికి పురోగతి సాధించండి",
        "tips_en": "This game teaches object permanence. That things exist even when hidden. A critical cognitive milestone!",
        "tips_te": "ఈ ఆట ఆబ్జెక్ట్ పర్మనెన్స్ నేర్పిస్తుంది. దాచినా వస్తువులు ఉన్నాయని. క్లిష్టమైన జ్ఞానాత్మక మైలురాయి!",
    },
    "COG_005": {
        "title_en": "Counting Games",
        "title_te": "లెక్కింపు ఆటలు",
        "desc_en": "Count objects during daily activities. Use fingers, toys, or steps.",
        "desc_te": "రోజువారీ కార్యకలాపాలలో వస్తువులను లెక్కించండి. వేళ్లు, బొమ్మలు లేదా మెట్లను ఉపయోగించండి.",
        "steps_en": "1. Count objects during meals\n2. Count steps while climbing stairs\n3. Count fingers and toes together\n4. Use counting songs\n5. Count items during grocery shopping",
        "steps_te": "1. భోజన సమయంలో వస్తువులను లెక్కించండి\n2. మెట్లు ఎక్కుతూ అడుగులు లెక్కించండి\n3. కలిసి వేళ్ళు మరియు కాలి వేళ్ళు లెక్కించండి\n4. లెక్కించే పాటలు ఉపయోగించండి\n5. కిరాణా షాపింగ్ సమయంలో వస్తువులు లెక్కించండి",
        "tips_en": "Counting in daily life is more effective than drilling numbers. Use Telugu numbers first, then English.",
        "tips_te": "రోజువారీ జీవితంలో లెక్కించడం సంఖ్యలు బట్టీ పట్టడం కంటే ఎక్కువ ప్రభావవంతం. మొదట తెలుగు సంఖ్యలు, తర్వాత ఆంగ్లం ఉపయోగించండి.",
    },
    "COG_006": {
        "title_en": "Building with Blocks",
        "title_te": "బ్లాకులతో నిర్మాణం",
        "desc_en": "Build structures together. Discuss shapes, sizes, and balance.",
        "desc_te": "కలిసి నిర్మాణాలు కట్టండి. ఆకారాలు, పరిమాణాలు మరియు సమతుల్యత గురించి చర్చించండి.",
        "steps_en": "1. Start with a few blocks and build a simple tower\n2. Build a house or bridge together\n3. Talk about which block goes where\n4. Discuss big small tall short concepts\n5. Let child design their own structures",
        "steps_te": "1. కొన్ని బ్లాకులతో ప్రారంభించి సాధారణ టవర్ నిర్మించండి\n2. కలిసి ఇల్లు లేదా వంతెన నిర్మించండి\n3. ఏ బ్లాక్ ఎక్కడ ఉంచాలో మాట్లాడండి\n4. పెద్ద చిన్న పొడవు పొట్టి భావనలు చర్చించండి\n5. బిడ్డ వారి స్వంత నిర్మాణాలను రూపొందించనివ్వండి",
        "tips_en": "Don't worry about correct buildings. Creative exploration matters more than following instructions.",
        "tips_te": "సరైన భవనాల గురించి ఆందోళన పడకండి. సూచనలను అనుసరించడం కంటే సృజనాత్మక అన్వేషణ ఎక్కువ ముఖ్యం.",
    },
    "SE_001": {
        "title_en": "Play Dates",
        "title_te": "స్నేహితులతో ఆట",
        "desc_en": "Arrange play dates with other children. Supervise and guide interactions.",
        "desc_te": "ఇతర పిల్లలతో ప్లే డేట్స్ ఏర్పాటు చేయండి. పరస్పర చర్యలను పర్యవేక్షించి మార్గనిర్దేశం చేయండి.",
        "steps_en": "1. Invite one child over for a short play date\n2. Prepare a few shared toys\n3. Stay nearby to supervise\n4. Guide sharing and turn-taking\n5. Keep sessions short, 30 to 60 minutes",
        "steps_te": "1. చిన్న ప్లే డేట్ కోసం ఒక బిడ్డను ఆహ్వానించండి\n2. కొన్ని పంచుకునే బొమ్మలు సిద్ధం చేయండి\n3. పర్యవేక్షించడానికి దగ్గరలో ఉండండి\n4. పంచుకోవడం మరియు వారీ తీసుకోవడం మార్గనిర్దేశం చేయండి\n5. సెషన్లను చిన్నగా ఉంచండి, 30 నుండి 60 నిమిషాలు",
        "tips_en": "Don't force sharing. Guide gently. Conflicts are learning opportunities. Keep first play dates short.",
        "tips_te": "పంచుకోవడానికి బలవంతం చేయకండి. మెల్లగా మార్గనిర్దేశం చేయండి. సంఘర్షణలు నేర్చుకునే అవకాశాలు. మొదటి ప్లే డేట్‌లను చిన్నగా ఉంచండి.",
    },
    "SE_002": {
        "title_en": "Sharing Activities",
        "title_te": "పంచుకోవడం కార్యకలాపాలు",
        "desc_en": "Practice taking turns and sharing toys. Use timer if needed.",
        "desc_te": "వారీలు తీసుకోవడం మరియు బొమ్మలను పంచుకోవడం అభ్యాసం చేయండి. అవసరమైతే టైమర్ ఉపయోగించండి.",
        "steps_en": "1. Explain taking turns with a toy\n2. Use a timer. Your turn for 2 minutes.\n3. Model sharing with another adult\n4. Praise when child shares voluntarily\n5. Practice with siblings or playmates",
        "steps_te": "1. బొమ్మతో వారీలు తీసుకోవడం వివరించండి\n2. టైమర్ ఉపయోగించండి. 2 నిమిషాలు మీ వారీ.\n3. మరొక పెద్దవారితో పంచుకోవడం నమూనా చూపించండి\n4. బిడ్డ స్వచ్ఛందంగా పంచుకున్నప్పుడు మెచ్చుకోండి\n5. తోబుట్టువులు లేదా ఆటగాళ్ళతో అభ్యాసం చేయండి",
        "tips_en": "Visual timers work better than verbal ones. First you, then me is easier to understand than share.",
        "tips_te": "దృశ్యమాన టైమర్లు మాటల కంటే బాగా పనిచేస్తాయి. మొదట నువ్వు, తర్వాత నేను అనేది పంచుకో కంటే అర్థం చేసుకోవడం సులభం.",
    },
    "SE_003": {
        "title_en": "Emotion Recognition",
        "title_te": "భావోద్వేగాల గుర్తింపు",
        "desc_en": "Use emotion cards or mirror to practice making and recognizing different facial expressions.",
        "desc_te": "వివిధ ముఖ కవళికలను చేయడం మరియు గుర్తించడం అభ్యాసం చేయడానికి ఎమోషన్ కార్డులు లేదా అద్దాన్ని ఉపయోగించండి.",
        "steps_en": "1. Show emotion cards: happy, sad, angry, scared\n2. Make the face and name the emotion\n3. Ask child to copy the expression\n4. Talk about when they feel that way\n5. Use stories to discuss character emotions",
        "steps_te": "1. ఎమోషన్ కార్డులు చూపించండి: ఆనందం, బాధ, కోపం, భయం\n2. ముఖం చేసి భావోద్వేగం పేరు చెప్పండి\n3. బిడ్డను కవళిక కాపీ చేయమని అడగండి\n4. వారు ఆ విధంగా ఎప్పుడు అనుభవిస్తారో మాట్లాడండి\n5. పాత్ర భావోద్వేగాలను చర్చించడానికి కథలు ఉపయోగించండి",
        "tips_en": "Validate all emotions. It's okay to feel angry. Help name feelings throughout the day.",
        "tips_te": "అన్ని భావోద్వేగాలను ధ్రువీకరించండి. కోపంగా అనిపించడం సరే. రోజంతా భావాలకు పేరు పెట్టడంలో సహాయపడండి.",
    },
    "SE_004": {
        "title_en": "Role Play",
        "title_te": "పాత్ర నటన",
        "desc_en": "Act out different social situations like greeting, sharing, or apologizing.",
        "desc_te": "శుభాకాంక్షలు, పంచుకోవడం, లేదా క్షమాపణలు వంటి వివిధ సామాజిక పరిస్థితులను నటించండి.",
        "steps_en": "1. Choose a social scenario like going to shop or meeting a friend\n2. Assign roles, you and the child\n3. Act out greeting, requesting, thanking\n4. Switch roles\n5. Discuss what felt comfortable or difficult",
        "steps_te": "1. సామాజిక సన్నివేశం ఎంచుకోండి\n2. పాత్రలు కేటాయించండి, మీరు మరియు బిడ్డ\n3. శుభాకాంక్షలు, అభ్యర్థించడం, ధన్యవాదాలు నటించండి\n4. పాత్రలు మారండి\n5. ఏది సౌకర్యంగా లేదా కష్టంగా అనిపించిందో చర్చించండి",
        "tips_en": "Practice greetings in Telugu: Namaskaram, Baagunnara. Real-life practice reinforces role play.",
        "tips_te": "తెలుగులో శుభాకాంక్షలు అభ్యాసం చేయండి: నమస్కారం, బాగున్నారా. నిజ జీవిత అభ్యాసం పాత్ర నటనను బలపరుస్తుంది.",
    },
    "SE_005": {
        "title_en": "Cooperative Games",
        "title_te": "సహకార ఆటలు",
        "desc_en": "Play games that require working together rather than competing.",
        "desc_te": "పోటీ కాకుండా కలిసి పనిచేయడం అవసరమైన ఆటలను ఆడండి.",
        "steps_en": "1. Choose a game requiring teamwork\n2. Explain the goal: We win together\n3. Play parachute or ball passing games\n4. Build something together as a team\n5. Celebrate group achievements",
        "steps_te": "1. జట్టు పనిని అవసరమయ్యే ఆటను ఎంచుకోండి\n2. లక్ష్యం వివరించండి: మనం కలిసి గెలుస్తాం\n3. పారాషూట్ లేదా బంతి పాస్ చేసే ఆటలు ఆడండి\n4. జట్టుగా కలిసి ఏదైనా నిర్మించండి\n5. సమూహ విజయాలను ఆనందించండి",
        "tips_en": "Avoid competitive games for children who struggle socially. Cooperative games build confidence first.",
        "tips_te": "సామాజికంగా కష్టపడే పిల్లలకు పోటీ ఆటలు నివారించండి. సహకార ఆటలు మొదట ఆత్మవిశ్వాసాన్ని పెంచుతాయి.",
    },
    "SE_006": {
        "title_en": "Daily Routines",
        "title_te": "రోజువారీ కార్యక్రమాలు",
        "desc_en": "Establish consistent daily routines. Use visual schedules to help child understand what comes next.",
        "desc_te": "స్థిరమైన రోజువారీ కార్యక్రమాలను ఏర్పాటు చేయండి. తర్వాత ఏమి వస్తుందో అర్థం చేసుకోవడంలో బిడ్డకు సహాయపడటానికి దృశ్యమాన షెడ్యూల్‌లను ఉపయోగించండి.",
        "steps_en": "1. Create a visual daily schedule with pictures\n2. Show morning routine: wake up, brush, breakfast\n3. Post the schedule where child can see it\n4. Follow the routine consistently\n5. Let child check off completed tasks",
        "steps_te": "1. బొమ్మలతో దృశ్యమాన రోజువారీ షెడ్యూల్ సృష్టించండి\n2. ఉదయ దినచర్య చూపించండి: నిద్ర లేవడం, పళ్ళు తోముకోవడం, అల్పాహారం\n3. బిడ్డ చూడగలిగే చోట షెడ్యూల్ ఉంచండి\n4. దినచర్యను స్థిరంగా అనుసరించండి\n5. పూర్తయిన పనులను బిడ్డ చెక్ ఆఫ్ చేయనివ్వండి",
        "tips_en": "Routines reduce anxiety and build independence. Be consistent but flexible when needed.",
        "tips_te": "దినచర్యలు ఆందోళనను తగ్గించి స్వాతంత్ర్యాన్ని నిర్మిస్తాయి. స్థిరంగా ఉండండి కానీ అవసరమైనప్పుడు అనువైనంగా ఉండండి.",
    },
}


def compose_text(activity, lang):
    """Compose the full narration text for TTS."""
    suffix = f"_{lang}"
    title = activity[f"title_{lang}"]
    desc = activity[f"desc_{lang}"]
    steps = activity.get(f"steps_{lang}", "")
    tips = activity.get(f"tips_{lang}", "")

    parts = [f"{title}.\n\n{desc}"]

    if steps:
        intro = "దశల వారీ సూచనలు." if lang == "te" else "Step by step instructions."
        parts.append(f"\n\n{intro}\n{steps}")

    if tips:
        intro = "చిట్కాలు." if lang == "te" else "Some helpful tips."
        parts.append(f"\n\n{intro}\n{tips}")

    return "".join(parts)


async def generate_audio(code, activity):
    """Generate EN and TE audio files for one activity."""
    for lang, voice in [("en", VOICE_EN), ("te", VOICE_TE)]:
        text = compose_text(activity, lang)
        output_path = os.path.join(OUTPUT_DIR, f"{code}_{lang}.mp3")

        communicate = edge_tts.Communicate(text, voice, rate="-10%", pitch="+0Hz")
        await communicate.save(output_path)
        print(f"  {output_path}")


async def main():
    os.makedirs(OUTPUT_DIR, exist_ok=True)
    print(f"Generating audio for {len(ACTIVITIES)} activities (EN + TE)...")
    print(f"English voice: {VOICE_EN}")
    print(f"Telugu voice: {VOICE_TE}")
    print()

    for code, activity in ACTIVITIES.items():
        print(f"[{code}]")
        await generate_audio(code, activity)

    total_files = len(ACTIVITIES) * 2
    print(f"\nDone! {total_files} audio files saved to {OUTPUT_DIR}/")


if __name__ == "__main__":
    asyncio.run(main())
