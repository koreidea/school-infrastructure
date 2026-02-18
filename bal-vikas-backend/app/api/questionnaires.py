from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from typing import Dict, Any, List, Optional

from app.database import get_db
from app.models import QuestionnaireVersion

router = APIRouter()


# ============================================================================
# COMPLETE QUESTIONNAIRE DATA BASED ON CDC MILESTONES & SCREENING TOOLS
# ============================================================================

# CDC Developmental Milestones (0-72 months) - Complete data from Excel
CDC_MILESTONES = {
    "version": "2.0",
    "age_range_months": [0, 72],
    "source": "CDC Learn the Signs. Act Early",
    "domains": [
        {
            "code": "gm",
            "name": "Gross Motor",
            "name_te": "స్థూల చలనం",
            "description": "Large muscle movements and physical activity",
            "milestones": [
                # 2 months
                {"age": 2, "id": "gm_2_1", "question": "Holds head up when on tummy?", "question_te": "పొట్టపై ఉన్నప్పుడు తల పైకి పట్టుకుంటారా?", "critical": True},
                {"age": 2, "id": "gm_2_2", "question": "Moves both arms and both legs?", "question_te": "రెండు చేతులను మరియు రెండు కాళ్లను కదుపుతారా?", "critical": False},
                {"age": 2, "id": "gm_2_3", "question": "Opens hands briefly?", "question_te": "చేతులను కొద్దిసేపు తెరుస్తారా?", "critical": False},
                # 4 months
                {"age": 4, "id": "gm_4_1", "question": "Holds head steady without support when held?", "question_te": "పట్టుకున్నప్పుడు మద్దతు లేకుండా తలను స్థిరంగా పట్టుకుంటారా?", "critical": True},
                {"age": 4, "id": "gm_4_2", "question": "Holds a toy when you put it in his hand?", "question_te": "చేతిలో బొమ్మ పెడితే పట్టుకుంటారా?", "critical": False},
                {"age": 4, "id": "gm_4_3", "question": "Pushes up onto elbows/forearms when on tummy?", "question_te": "పొట్టపై ఉన్నప్పుడు మోచేతులపై పైకి లేస్తారా?", "critical": False},
                # 6 months
                {"age": 6, "id": "gm_6_1", "question": "Rolls from tummy to back?", "question_te": "పొట్ట నుండి వెనక్కి తిరుగుతారా?", "critical": True},
                {"age": 6, "id": "gm_6_2", "question": "Leans on hands to support when sitting?", "question_te": "కూర్చున్నప్పుడు చేతులపై ఆధారపడతారా?", "critical": False},
                # 9 months
                {"age": 9, "id": "gm_9_1", "question": "Sits without support?", "question_te": "మద్దతు లేకుండా కూర్చుంటారా?", "critical": True},
                {"age": 9, "id": "gm_9_2", "question": "Gets to sitting position by herself?", "question_te": "స్వయంగా కూర్చునే స్థితికి వస్తారా?", "critical": False},
                # 12 months
                {"age": 12, "id": "gm_12_1", "question": "Pulls up to stand?", "question_te": "పట్టుకుని నిలబడటానికి లేస్తారా?", "critical": True},
                {"age": 12, "id": "gm_12_2", "question": "Walks, holding on to furniture?", "question_te": "ఫర్నిచర్ పట్టుకుని నడుస్తారా?", "critical": False},
                # 18 months
                {"age": 18, "id": "gm_18_1", "question": "Walks without holding on to anyone or anything?", "question_te": "ఎవరినీ లేదా ఏదీ పట్టుకోకుండా నడుస్తారా?", "critical": True},
                {"age": 18, "id": "gm_18_2", "question": "Scribbles?", "question_te": "గీతలు గీస్తారా?", "critical": False},
                {"age": 18, "id": "gm_18_3", "question": "Climbs on and off couch or chair without help?", "question_te": "సహాయం లేకుండా సోఫా లేదా కుర్చీ ఎక్కి దిగుతారా?", "critical": False},
                # 24 months
                {"age": 24, "id": "gm_24_1", "question": "Kicks a ball?", "question_te": "బంతిని కొడతారా?", "critical": False},
                {"age": 24, "id": "gm_24_2", "question": "Runs?", "question_te": "పరుగెడతారా?", "critical": False},
                {"age": 24, "id": "gm_24_3", "question": "Walks up few stairs with/without help?", "question_te": "కొన్ని మెట్లు ఎక్కుతారా?", "critical": False},
                # 30 months
                {"age": 30, "id": "gm_30_1", "question": "Jumps off ground with both feet?", "question_te": "రెండు పాదాలతో భూమి నుండి దుముతారా?", "critical": False},
                {"age": 30, "id": "gm_30_2", "question": "Turns book pages, one page at a time?", "question_te": "పుస్తకం పేజీలను ఒక్కొక్కటిగా తిప్పుతారా?", "critical": False},
                # 36 months (3 years)
                {"age": 36, "id": "gm_36_1", "question": "Puts on some clothes by herself?", "question_te": "కొన్ని దుస్తులను స్వయంగా ధరిస్తారా?", "critical": False},
                {"age": 36, "id": "gm_36_2", "question": "Uses a fork?", "question_te": "ఫోర్క్ ఉపయోగిస్తారా?", "critical": False},
                # 48 months (4 years)
                {"age": 48, "id": "gm_48_1", "question": "Catches a large ball most of the time?", "question_te": "పెద్ద బంతిని చాలాసార్లు పట్టుకుంటారా?", "critical": False},
                {"age": 48, "id": "gm_48_2", "question": "Serves self food or pours water with help?", "question_te": "సహాయంతో స్వయంగా ఆహారం తీసుకుంటారా?", "critical": False},
                {"age": 48, "id": "gm_48_3", "question": "Unbuttons some buttons?", "question_te": "కొన్ని బటన్లను విపుతారా?", "critical": False},
                # 60 months (5 years)
                {"age": 60, "id": "gm_60_1", "question": "Buttons some buttons?", "question_te": "కొన్ని బటన్లను కడతారా?", "critical": False},
                {"age": 60, "id": "gm_60_2", "question": "Hops on one foot?", "question_te": "ఒక పాదంతో దుముతారా?", "critical": False},
            ]
        },
        {
            "code": "fm",
            "name": "Fine Motor",
            "name_te": "సూక్ష్మ చలనం",
            "description": "Small muscle movements and hand-eye coordination",
            "milestones": [
                {"age": 4, "id": "fm_4_1", "question": "Brings hands to mouth?", "question_te": "చేతులను నోటికి తీసుకువస్తారా?", "critical": False},
                {"age": 6, "id": "fm_6_1", "question": "Reaches to grab a toy?", "question_te": "బొమ్మను చేరుకుని పట్టుకుంటారా?", "critical": False},
                {"age": 9, "id": "fm_9_1", "question": "Passes object from hand to hand?", "question_te": "వస్తువును చేతి నుండి చేతికి ఇస్తారా?", "critical": False},
                {"age": 12, "id": "fm_12_1", "question": "Picks things up between thumb and pointer?", "question_te": "అంగుళం మరియు చూపుడు వేలతో వస్తువులు పట్టుకుంటారా?", "critical": False},
                {"age": 18, "id": "fm_18_1", "question": "Holds something in one hand while using other?", "question_te": "ఒక చేతిలో వస్తువు పట్టుకుని మరొకటి ఉపయోగిస్తారా?", "critical": False},
                {"age": 24, "id": "fm_24_1", "question": "Plays with more than one toy at same time?", "question_te": "ఒకేసారి ఒకటి కంటే ఎక్కువ బొమ్మలతో ఆడుకుంటారా?", "critical": False},
                {"age": 30, "id": "fm_30_1", "question": "Uses hands to twist things (doorknobs, lids)?", "question_te": "వస్తువులను తిప్పడానికి చేతులు ఉపయోగిస్తారా?", "critical": False},
                {"age": 36, "id": "fm_36_1", "question": "Draws a circle when you show how?", "question_te": "మీరు చూపిస్తే వృత్తం గీస్తారా?", "critical": False},
                {"age": 48, "id": "fm_48_1", "question": "Draws a person with 3 or more body parts?", "question_te": "3 లేదా అంతకంటే ఎక్కువ శరీర భాగాలతో మనిషిని గీస్తారా?", "critical": False},
                {"age": 60, "id": "fm_60_1", "question": "Writes some letters in their name?", "question_te": "తమ పేరులో కొన్ని అక్షరాలు రాస్తారా?", "critical": False},
                {"age": 60, "id": "fm_60_2", "question": "Names some letters when you point to them?", "question_te": "మీరు చూపిస్తే కొన్ని అక్షరాల పేర్లు చెబుతారా?", "critical": False},
            ]
        },
        {
            "code": "lc",
            "name": "Language & Communication",
            "name_te": "భాష & సంభాషణ",
            "description": "Speech, language understanding and communication skills",
            "milestones": [
                {"age": 2, "id": "lc_2_1", "question": "Makes sounds other than crying?", "question_te": "ఏడవడం కాకుండా ఇతర శబ్దాలు చేస్తారా?", "critical": True},
                {"age": 2, "id": "lc_2_2", "question": "Reacts to loud sounds?", "question_te": "బిగ్గర శబ్దాలకు స్పందిస్తారా?", "critical": True},
                {"age": 4, "id": "lc_4_1", "question": "Makes sounds like 'oooo', 'aahh' (cooing)?", "question_te": "'ఊఊఊ', 'ఆఆఆ' వంటి శబ్దాలు చేస్తారా?", "critical": False},
                {"age": 6, "id": "lc_6_1", "question": "Looks when you call her name?", "question_te": "పేరు పిలిస్తే చూస్తారా?", "critical": True},
                {"age": 9, "id": "lc_9_1", "question": "Makes lots of different sounds like 'mamamama'?", "question_te": "'మమమమ' వంటి వివిధ శబ్దాలు చేస్తారా?", "critical": True},
                {"age": 12, "id": "lc_12_1", "question": "Waves 'bye-bye'?", "question_te": "'బాయ్' అని చేతులు ఊపుతారా?", "critical": False},
                {"age": 12, "id": "lc_12_2", "question": "Calls parent 'mama' or 'dada' specifically?", "question_te": "తల్లిదండ్రులను 'అమ్మ' లేదా 'నాన్న' అని పిలుస్తారా?", "critical": True},
                {"age": 18, "id": "lc_18_1", "question": "Tries to say three or more words besides 'mama' or 'dada'?", "question_te": "'అమ్మ' 'నాన్న' కాకుండా మరో మూడు పదాలు అనడానికి ప్రయత్నిస్తారా?", "critical": True},
                {"age": 24, "id": "lc_24_1", "question": "Points to things in a book when you ask?", "question_te": "అడిగినప్పుడు పుస్తకంలోని వాటిని చూపిస్తారా?", "critical": False},
                {"age": 24, "id": "lc_24_2", "question": "Says at least two words together?", "question_te": "కనీసం రెండు పదాలు కలిపి అంటారా?", "critical": True},
                {"age": 30, "id": "lc_30_1", "question": "Says about 50 words?", "question_te": "సుమారు 50 పదాలు అంటారా?", "critical": True},
                {"age": 36, "id": "lc_36_1", "question": "Says first name when asked?", "question_te": "అడిగినప్పుడు తమ పేరు చెబుతారా?", "critical": True},
                {"age": 36, "id": "lc_36_2", "question": "Talks well enough for others to understand?", "question_te": "ఇతరులకు అర్థమయ్యేలా మాట్లాడతారా?", "critical": True},
                {"age": 48, "id": "lc_48_1", "question": "Says sentences with 4 or more words?", "question_te": "4 లేదా అంతకంటే ఎక్కువ పదాలతో వాక్యాలు అంటారా?", "critical": False},
                {"age": 60, "id": "lc_60_1", "question": "Tells a story with at least 2 events?", "question_te": "కనీసం 2 సంఘటనలతో కథ చెబుతారా?", "critical": False},
                {"age": 60, "id": "lc_60_2", "question": "Keeps a conversation going (3+ exchanges)?", "question_te": "సంభాషణను కొనసాగిస్తారా?", "critical": False},
            ]
        },
        {
            "code": "cog",
            "name": "Cognitive",
            "name_te": "జ్ఞానాత్మకం",
            "description": "Thinking, learning, and problem-solving abilities",
            "milestones": [
                {"age": 2, "id": "cog_2_1", "question": "Watches you as you move?", "question_te": "మీరు కదులుతున్నప్పుడు చూస్తారా?", "critical": False},
                {"age": 4, "id": "cog_4_1", "question": "Looks at his hands with interest?", "question_te": "ఆసక్తిగా తన చేతులను చూస్తారా?", "critical": False},
                {"age": 6, "id": "cog_6_1", "question": "Puts things in her mouth to explore them?", "question_te": "వాటిని పరిశీలించడానికి నోట్లో పెడతారా?", "critical": False},
                {"age": 9, "id": "cog_9_1", "question": "Looks for objects when dropped out of sight?", "question_te": "వస్తువులు కనబడకుండా పడిపోతే వెతుకుతారా?", "critical": False},
                {"age": 12, "id": "cog_12_1", "question": "Looks for things he sees you hide?", "question_te": "మీరు దాచిన వస్తువులను వెతుకుతారా?", "critical": False},
                {"age": 18, "id": "cog_18_1", "question": "Knows what ordinary things are for?", "question_te": "సాధారణ వస్తువుల ఉపయోగం తెలుసా?", "critical": False},
                {"age": 24, "id": "cog_24_1", "question": "Shows simple problem-solving skills?", "question_te": "సరళమైన సమస్య పరిష్కార నైపుణ్యాలను చూపిస్తారా?", "critical": False},
                {"age": 30, "id": "cog_30_1", "question": "Follows two-step instructions?", "question_te": "రెండు అడుగుల సూచనలను అనుసరిస్తారా?", "critical": False},
                {"age": 36, "id": "cog_36_1", "question": "Plays make-believe?", "question_te": "నటన ఆడుతారా?", "critical": False},
                {"age": 48, "id": "cog_48_1", "question": "Names a few colors of items?", "question_te": "కొన్ని వస్తువుల రంగుల పేర్లు చెబుతారా?", "critical": False},
                {"age": 60, "id": "cog_60_1", "question": "Counts to 10?", "question_te": "10 వరకు లెక్కిస్తారా?", "critical": False},
                {"age": 60, "id": "cog_60_2", "question": "Writes some letters in their name?", "question_te": "తమ పేరులో కొన్ని అక్షరాలు రాస్తారా?", "critical": False},
            ]
        },
        {
            "code": "se",
            "name": "Social-Emotional",
            "name_te": "సామాజిక-భావోద్వేగ",
            "description": "Interacting with others and expressing emotions",
            "milestones": [
                {"age": 2, "id": "se_2_1", "question": "Calms down when spoken to or picked up?", "question_te": "మాట్లాడినప్పుడు లేదా పట్టుకున్నప్పుడు శాంతిస్తారా?", "critical": True},
                {"age": 2, "id": "se_2_2", "question": "Looks at your face?", "question_te": "మీ ముఖాన్ని చూస్తారా?", "critical": True},
                {"age": 2, "id": "se_2_3", "question": "Smiles when you talk to or smile at her?", "question_te": "మీరు మాట్లాడినప్పుడు లేదా నవ్వినప్పుడు నవ్వుతారా?", "critical": True},
                {"age": 4, "id": "se_4_1", "question": "Smiles on his own to get your attention?", "question_te": "మీ శ్రద్ధ పొందడానికి స్వయంగా నవ్వుతారా?", "critical": False},
                {"age": 6, "id": "se_6_1", "question": "Knows familiar people?", "question_te": "పరిచిత వ్యక్తులను గుర్తిస్తారా?", "critical": False},
                {"age": 9, "id": "se_9_1", "question": "Is shy, clingy, or fearful around strangers?", "question_te": "అపరిచితుల మధ్య సిగ్గుగా లేదా భయపడేలా ఉంటారా?", "critical": False},
                {"age": 12, "id": "se_12_1", "question": "Plays games with you, like pat-a-cake?", "question_te": "మీతో క్లాప్-క్లాప్ వంటి ఆటలు ఆడుతారా?", "critical": False},
                {"age": 18, "id": "se_18_1", "question": "Points to show you something interesting?", "question_te": "ఆసక్తికరమైన వాటిని చూపించడానికి చూపుస్తారా?", "critical": True},
                {"age": 24, "id": "se_24_1", "question": "Notices when others are hurt or upset?", "question_te": "ఇతరులు గాయపడితే లేదా బాధపడితే గమనిస్తారా?", "critical": False},
                {"age": 30, "id": "se_30_1", "question": "Plays next to other children?", "question_te": "ఇతర పిల్లల పక్కన ఆడుతారా?", "critical": False},
                {"age": 36, "id": "se_36_1", "question": "Notices other children and joins them to play?", "question_te": "ఇతర పిల్లలను గమనించి వారితో ఆడటానికి చేరతారా?", "critical": True},
                {"age": 48, "id": "se_48_1", "question": "Pretends to be something else (teacher, dog)?", "question_te": "ఇంకేదో అవ్వటానికి నటిస్తారా?", "critical": False},
                {"age": 60, "id": "se_60_1", "question": "Follows rules or takes turns when playing games?", "question_te": "ఆటలాడేటప్పుడు నియమాలను పాటిస్తారా?", "critical": False},
                {"age": 60, "id": "se_60_2", "question": "Does simple chores at home?", "question_te": "ఇంట్లో సరళమైన పనులు చేస్తారా?", "critical": False},
            ]
        }
    ]
}


# ============================================================================
# M-CHAT-R/F: AUTISM SCREENING (16-30 Months)
# ============================================================================
MCHAT_QUESTIONNAIRE = {
    "tool_code": "mchat",
    "tool_name": "M-CHAT-R/F Autism Screening",
    "tool_name_te": "M-CHAT-R/F ఆటిజం స్క్రీనింగ్",
    "age_range_months": [16, 30],
    "description": "Modified Checklist for Autism in Toddlers - Revised with Follow-up",
    "scoring_info": {
        "method": "Count failed items (score 1)",
        "critical_items": [2, 5, 7, 9, 13, 15],
        "risk_threshold": 3,
        "high_risk_threshold": 7
    },
    "questions": [
        {"id": "mchat_1", "item_number": 1, "question": "If you point at something across the room, does your child look at it?", "question_te": "మీరు గదిలో ఏదైనా చూపిస్తే, మీ బిడ్డ దాని వైపు చూస్తారా?", "response_options": ["Yes", "No"], "scoring": {"Yes": 0, "No": 1}, "at_risk_if": "No", "critical": False},
        {"id": "mchat_2", "item_number": 2, "question": "Have you ever wondered if your child might be deaf?", "question_te": "మీ బిడ్డ చెవిటివారు కావచ్చని ఎప్పుడైనా ఆలోచించారా?", "response_options": ["Yes", "No"], "scoring": {"Yes": 1, "No": 0}, "at_risk_if": "Yes", "critical": True},
        {"id": "mchat_3", "item_number": 3, "question": "Does your child play pretend or make-believe?", "question_te": "మీ బిడ్డ నటన ఆడుతారా?", "response_options": ["Yes", "No"], "scoring": {"Yes": 0, "No": 1}, "at_risk_if": "No", "critical": False},
        {"id": "mchat_4", "item_number": 4, "question": "Does your child like climbing on things?", "question_te": "మీ బిడ్డ వస్తువుల ఎక్కడానికి ఇష్టపడతారా?", "response_options": ["Yes", "No"], "scoring": {"Yes": 0, "No": 1}, "at_risk_if": "No", "critical": False},
        {"id": "mchat_5", "item_number": 5, "question": "Does your child make unusual finger movements near his or her eyes?", "question_te": "మీ బిడ్డ కళ్ల దగ్గర అసాధారణ వేలి కదలికలు చేస్తారా?", "response_options": ["Yes", "No"], "scoring": {"Yes": 1, "No": 0}, "at_risk_if": "Yes", "critical": True},
        {"id": "mchat_6", "item_number": 6, "question": "Does your child point with one finger to ask for something?", "question_te": "మీ బిడ్డ ఏదైనా అడగడానికి ఒక వేలితో చూపిస్తారా?", "response_options": ["Yes", "No"], "scoring": {"Yes": 0, "No": 1}, "at_risk_if": "No", "critical": False},
        {"id": "mchat_7", "item_number": 7, "question": "Does your child point with one finger to show you something interesting?", "question_te": "మీకు ఏదైనా ఆసక్తికరమైనది చూపించడానికి ఒక వేలితో చూపిస్తారా?", "response_options": ["Yes", "No"], "scoring": {"Yes": 0, "No": 1}, "at_risk_if": "No", "critical": True},
        {"id": "mchat_8", "item_number": 8, "question": "Is your child interested in other children?", "question_te": "మీ బిడ్డకు ఇతర పిల్లలపై ఆసక్తి ఉందా?", "response_options": ["Yes", "No"], "scoring": {"Yes": 0, "No": 1}, "at_risk_if": "No", "critical": False},
        {"id": "mchat_9", "item_number": 9, "question": "Does your child show you things by bringing them to you - just to share?", "question_te": "మీతో పంచుకోవడానికి మాత్రమే వస్తువులను మీ దగ్గరకు తెస్తారా?", "response_options": ["Yes", "No"], "scoring": {"Yes": 0, "No": 1}, "at_risk_if": "No", "critical": True},
        {"id": "mchat_10", "item_number": 10, "question": "Does your child respond when you call his or her name?", "question_te": "మీరు పేరు పిలిస్తే మీ బిడ్డ స్పందిస్తారా?", "response_options": ["Yes", "No"], "scoring": {"Yes": 0, "No": 1}, "at_risk_if": "No", "critical": False},
        {"id": "mchat_11", "item_number": 11, "question": "When you smile at your child, does he or she smile back?", "question_te": "మీరు నవ్వినప్పుడు మీ బిడ్డ తిరిగి నవ్వుతారా?", "response_options": ["Yes", "No"], "scoring": {"Yes": 0, "No": 1}, "at_risk_if": "No", "critical": False},
        {"id": "mchat_12", "item_number": 12, "question": "Does your child get upset by everyday noises?", "question_te": "మీ బిడ్డ రోజువారీ శబ్దాలకు బాధపడతారా?", "response_options": ["Yes", "No"], "scoring": {"Yes": 1, "No": 0}, "at_risk_if": "Yes", "critical": False},
        {"id": "mchat_13", "item_number": 13, "question": "Does your child walk?", "question_te": "మీ బిడ్డ నడుస్తారా?", "response_options": ["Yes", "No"], "scoring": {"Yes": 0, "No": 1}, "at_risk_if": "No", "critical": True},
        {"id": "mchat_14", "item_number": 14, "question": "Does your child look you in the eye when talking or playing?", "question_te": "మాట్లాడినప్పుడు లేదా ఆడినప్పుడు మీ కళ్లలోకి చూస్తారా?", "response_options": ["Yes", "No"], "scoring": {"Yes": 0, "No": 1}, "at_risk_if": "No", "critical": False},
        {"id": "mchat_15", "item_number": 15, "question": "Does your child try to copy what you do?", "question_te": "మీరు చేసినది కాపీ చేయడానికి ప్రయత్నిస్తారా?", "response_options": ["Yes", "No"], "scoring": {"Yes": 0, "No": 1}, "at_risk_if": "No", "critical": True},
        {"id": "mchat_16", "item_number": 16, "question": "If you turn your head to look at something, does your child look too?", "question_te": "మీరు తల తిప్పి చూస్తే, మీ బిడ్డ కూడా చూస్తారా?", "response_options": ["Yes", "No"], "scoring": {"Yes": 0, "No": 1}, "at_risk_if": "No", "critical": False},
        {"id": "mchat_17", "item_number": 17, "question": "Does your child try to get you to watch him or her?", "question_te": "మీ బిడ్డ మిమ్మల్ని చూడమని ప్రయత్నిస్తారా?", "response_options": ["Yes", "No"], "scoring": {"Yes": 0, "No": 1}, "at_risk_if": "No", "critical": False},
        {"id": "mchat_18", "item_number": 18, "question": "Does your child understand when you tell him or her to do something?", "question_te": "మీరు ఏదైనా చేయమని చెప్పినప్పుడు అర్థం చేసుకుంటారా?", "response_options": ["Yes", "No"], "scoring": {"Yes": 0, "No": 1}, "at_risk_if": "No", "critical": False},
        {"id": "mchat_19", "item_number": 19, "question": "If something new happens, does your child look at your face?", "question_te": "ఏదైనా కొత్తది జరిగినప్పుడు మీ ముఖాన్ని చూస్తారా?", "response_options": ["Yes", "No"], "scoring": {"Yes": 0, "No": 1}, "at_risk_if": "No", "critical": False},
        {"id": "mchat_20", "item_number": 20, "question": "Does your child like movement activities?", "question_te": "మీ బిడ్డ కదలిక కార్యక్రమాలను ఇష్టపడతారా?", "response_options": ["Yes", "No"], "scoring": {"Yes": 0, "No": 1}, "at_risk_if": "No", "critical": False},
    ]
}


# ============================================================================
# ISAA: INDIAN SCALE FOR ASSESSMENT OF AUTISM (36-72 Months)
# ============================================================================
ISAA_QUESTIONNAIRE = {
    "tool_code": "isaa",
    "tool_name": "ISAA - Indian Scale for Assessment of Autism",
    "tool_name_te": "ISAA - ఆటిజం మూల్యాంకనం కోసం భారతీయ స్కేల్",
    "age_range_months": [36, 72],
    "description": "Comprehensive autism assessment tool for children 3-6 years",
    "source": "NIMHANS Bangalore",
    "scoring_info": {
        "method": "Sum all items (range 40-200)",
        "response_scale": "1=Rarely, 2=Sometimes, 3=Frequently, 4=Mostly, 5=Always",
        "cutoff_scores": {"normal": 70, "mild": 106, "moderate": 153, "severe": 200},
        "interpretation": "Higher score = more concern"
    },
    "questions": [
        # Social Relationship & Reciprocity
        {"id": "isaa_1", "item_number": 1, "domain": "Social Relationship & Reciprocity", "domain_te": "సామాజిక సంబంధం & పరస్పర చర్య", "question": "Has poor eye contact", "question_te": "బలహీనమైన కన్ను సంపర్కం కలిగి ఉంటారు"},
        {"id": "isaa_2", "item_number": 2, "domain": "Social Relationship & Reciprocity", "domain_te": "సామాజిక సంబంధం & పరస్పర చర్య", "question": "Lacks social smile", "question_te": "సామాజిక నవ్వు లేదు"},
        {"id": "isaa_3", "item_number": 3, "domain": "Social Relationship & Reciprocity", "domain_te": "సామాజిక సంబంధం & పరస్పర చర్య", "question": "Remains aloof", "question_te": "దూరంగా ఉంటారు"},
        {"id": "isaa_4", "item_number": 4, "domain": "Social Relationship & Reciprocity", "domain_te": "సామాజిక సంబంధం & పరస్పర చర్య", "question": "Does not reach out to others", "question_te": "ఇతరుల వైపు చేతులు చాడరు"},
        {"id": "isaa_5", "item_number": 5, "domain": "Social Relationship & Reciprocity", "domain_te": "సామాజిక సంబంధం & పరస్పర చర్య", "question": "Unable to relate to people", "question_te": "ప్రజలతో సంబంధం కలిగించుకోలేరు"},
        {"id": "isaa_6", "item_number": 6, "domain": "Social Relationship & Reciprocity", "domain_te": "సామాజిక సంబంధం & పరస్పర చర్య", "question": "Unable to respond to social/environmental cues", "question_te": "సామాజిక/పర్యావరణ సంకేతాలకు స్పందించలేరు"},
        {"id": "isaa_7", "item_number": 7, "domain": "Social Relationship & Reciprocity", "domain_te": "సామాజిక సంబంధం & పరస్పర చర్య", "question": "Engages in solitary and repetitive play activities", "question_te": "ఒంటరిగా మరియు పునరావృత ఆట కార్యకలాపాలలో పాల్గొంటారు"},
        {"id": "isaa_8", "item_number": 8, "domain": "Social Relationship & Reciprocity", "domain_te": "సామాజిక సంబంధం & పరస్పర చర్య", "question": "Unable to take turns in social interaction", "question_te": "సామాజిక పరస్పర చర్యలో మారు మారు రాలేరు"},
        {"id": "isaa_9", "item_number": 9, "domain": "Social Relationship & Reciprocity", "domain_te": "సామాజిక సంబంధం & పరస్పర చర్య", "question": "Does not maintain peer relationships", "question_te": "సమవయస్కుల సంబంధాలను నిర్వహించరు"},
        # Emotional Responsiveness
        {"id": "isaa_10", "item_number": 10, "domain": "Emotional Responsiveness", "domain_te": "భావోద్వేగ స్పందన", "question": "Shows inappropriate emotional response", "question_te": "అనుచిత భావోద్వేగ స్పందనను చూపిస్తారు"},
        {"id": "isaa_11", "item_number": 11, "domain": "Emotional Responsiveness", "domain_te": "భావోద్వేగ స్పందన", "question": "Shows exaggerated emotions", "question_te": "అతిశయోక్తి భావోద్వేగాలను చూపిస్తారు"},
        {"id": "isaa_12", "item_number": 12, "domain": "Emotional Responsiveness", "domain_te": "భావోద్వేగ స్పందన", "question": "Engages in self-stimulating emotions", "question_te": "స్వయం ప్రేరేపిత భావోద్వేగాలలో పాల్గొంటారు"},
        {"id": "isaa_13", "item_number": 13, "domain": "Emotional Responsiveness", "domain_te": "భావోద్వేగ స్పందన", "question": "Lacks fear of danger", "question_te": "అపాయ భయం లేదు"},
        {"id": "isaa_14", "item_number": 14, "domain": "Emotional Responsiveness", "domain_te": "భావోద్వేగ స్పందన", "question": "Excited or agitated for no apparent reason", "question_te": "స్పష్టమైన కారణం లేకుండా ఉత్సాహంగా లేదా ఆందోళన చెందుతారు"},
        {"id": "isaa_15", "item_number": 15, "domain": "Emotional Responsiveness", "domain_te": "భావోద్వేగ స్పందన", "question": "Lacks emotional attachment with parents/caregivers", "question_te": "తల్లిదండ్రులు/పోషకులతో భావోద్వేగ అనుబంధం లేదు"},
        # Speech-Language & Communication
        {"id": "isaa_16", "item_number": 16, "domain": "Speech-Language & Communication", "domain_te": "వాక్చాతుర్యం & సంభాషణ", "question": "Acquired speech then lost it", "question_te": "మాట వచ్చింది తర్వాత పోయింది"},
        {"id": "isaa_17", "item_number": 17, "domain": "Speech-Language & Communication", "domain_te": "వాక్చాతుర్యం & సంభాషణ", "question": "Has difficulty in using non-verbal language/gestures", "question_te": "అలిఖిత భాష/సంజెలను ఉపయోగించడంలో ఇబ్బంది"},
        {"id": "isaa_18", "item_number": 18, "domain": "Speech-Language & Communication", "domain_te": "వాక్చాతుర్యం & సంభాషణ", "question": "Engages in stereotyped and repetitive use of language", "question_te": "స్టీరియోటైప్ మరియు పునరావృత భాషా ఉపయోగంలో పాల్గొంటారు"},
        {"id": "isaa_19", "item_number": 19, "domain": "Speech-Language & Communication", "domain_te": "వాక్చాతుర్యం & సంభాషణ", "question": "Engages in echolalic speech", "question_te": "ప్రతిధ్వని మాటలలో పాల్గొంటారు"},
        {"id": "isaa_20", "item_number": 20, "domain": "Speech-Language & Communication", "domain_te": "వాక్చాతుర్యం & సంభాషణ", "question": "Produces infantile squeals/unusual noises", "question_te": "శిశు శబ్దాలు/అసాధారణ శబ్దాలు చేస్తారు"},
        {"id": "isaa_21", "item_number": 21, "domain": "Speech-Language & Communication", "domain_te": "వాక్చాతుర్యం & సంభాషణ", "question": "Unable to initiate or sustain conversation", "question_te": "సంభాషణను ప్రారంభించలేరు లేదా కొనసాగించలేరు"},
        {"id": "isaa_22", "item_number": 22, "domain": "Speech-Language & Communication", "domain_te": "వాక్చాతుర్యం & సంభాషణ", "question": "Uses jargon or meaningless words", "question_te": "పదజాలం లేదా అర్థంలేని పదాలను ఉపయోగిస్తారు"},
        {"id": "isaa_23", "item_number": 23, "domain": "Speech-Language & Communication", "domain_te": "వాక్చాతుర్యం & సంభాషణ", "question": "Uses pronoun reversals", "question_te": "సర్వనామాలను తిప్పి ఉపయోగిస్తారు"},
        {"id": "isaa_24", "item_number": 24, "domain": "Speech-Language & Communication", "domain_te": "వాక్చాతుర్యం & సంభాషణ", "question": "Unable to grasp pragmatics of communication", "question_te": "సంభాషణ ప్రాగ్ధత్వాన్ని అర్థం చేసుకోలేరు"},
        # Behavioral Patterns
        {"id": "isaa_25", "item_number": 25, "domain": "Behavioral Patterns", "domain_te": "ప్రవర్తనా నమూనాలు", "question": "Engages in stereotyped and repetitive motor mannerisms", "question_te": "స్టీరియోటైప్ మరియు పునరావృత మోటారు మర్యాదలలో పాల్గొంటారు"},
        {"id": "isaa_26", "item_number": 26, "domain": "Behavioral Patterns", "domain_te": "ప్రవర్తనా నమూనాలు", "question": "Shows attachment to inanimate objects", "question_te": "జడ వస్తువులపై అనుబంధం చూపిస్తారు"},
        {"id": "isaa_27", "item_number": 27, "domain": "Behavioral Patterns", "domain_te": "ప్రవర్తనా నమూనాలు", "question": "Shows hyperactivity/restlessness", "question_te": "అతిసక్రియత/అశాంతిని చూపిస్తారు"},
        {"id": "isaa_28", "item_number": 28, "domain": "Behavioral Patterns", "domain_te": "ప్రవర్తనా నమూనాలు", "question": "Exhibits aggressive behavior", "question_te": "దాడి ప్రవర్తనను ప్రదర్శిస్తారు"},
        {"id": "isaa_29", "item_number": 29, "domain": "Behavioral Patterns", "domain_te": "ప్రవర్తనా నమూనాలు", "question": "Throws temper tantrums", "question_te": "కోపం ప్రదర్శిస్తారు"},
        {"id": "isaa_30", "item_number": 30, "domain": "Behavioral Patterns", "domain_te": "ప్రవర్తనా నమూనాలు", "question": "Engages in self-injurious behavior", "question_te": "స్వయం గాయ ప్రవర్తనలో పాల్గొంటారు"},
        {"id": "isaa_31", "item_number": 31, "domain": "Behavioral Patterns", "domain_te": "ప్రవర్తనా నమూనాలు", "question": "Insists on sameness", "question_te": "ఒకే విధంగా ఉండాలని బలవంతం చేస్తారు"},
        {"id": "isaa_32", "item_number": 32, "domain": "Behavioral Patterns", "domain_te": "ప్రవర్తనా నమూనాలు", "question": "Gets obsessed with certain actions/routines", "question_te": "కొన్ని చర్యలు/పద్ధతులపై మక్కువ చూపిస్తారు"},
        # Sensory Aspects
        {"id": "isaa_33", "item_number": 33, "domain": "Sensory Aspects", "domain_te": "ఇంద్రియ అంశాలు", "question": "Unusually sensitive to sensory stimuli", "question_te": "ఇంద్రియ ప్రేరణలకు అసాధారణంగా సున్నితంగా ఉంటారు"},
        {"id": "isaa_34", "item_number": 34, "domain": "Sensory Aspects", "domain_te": "ఇంద్రియ అంశాలు", "question": "Stares into space for long periods", "question_te": "దీర్ఘకాలం పాటు అంతరిక్షంలోకి చూస్తారు"},
        {"id": "isaa_35", "item_number": 35, "domain": "Sensory Aspects", "domain_te": "ఇంద్రియ అంశాలు", "question": "Has difficulty in tracking objects", "question_te": "వస్తువులను ట్రాక్ చేయడంలో ఇబ్బంది"},
        {"id": "isaa_36", "item_number": 36, "domain": "Sensory Aspects", "domain_te": "ఇంద్రియ అంశాలు", "question": "Has unusual vision", "question_te": "అసాధారణమైన దృష్టి కలిగి ఉంటారు"},
        {"id": "isaa_37", "item_number": 37, "domain": "Sensory Aspects", "domain_te": "ఇంద్రియ అంశాలు", "question": "Insensitive to pain", "question_te": "నొప్పికి అసున్నితంగా ఉంటారు"},
        # Cognitive Component
        {"id": "isaa_38", "item_number": 38, "domain": "Cognitive Component", "domain_te": "జ్ఞానాత్మక అంశం", "question": "Inconsistent attention and concentration", "question_te": "అసమాన శ్రద్ధ మరియు ఏకాగ్రత"},
        {"id": "isaa_39", "item_number": 39, "domain": "Cognitive Component", "domain_te": "జ్ఞానాత్మక అంశం", "question": "Shows delay in responding", "question_te": "స్పందించడంలో ఆలస్యం చూపిస్తారు"},
        {"id": "isaa_40", "item_number": 40, "domain": "Cognitive Component", "domain_te": "జ్ఞానాత్మక అంశం", "question": "Has unusual memory of some kind", "question_te": "ఏదైనా అసాధారణమైన జ్ఞాపకశక్తి కలిగి ఉంటారు"},
    ]
}


# ============================================================================
# ADHD QUICK SCREENING (36-72 Months)
# ============================================================================
ADHD_QUESTIONNAIRE = {
    "tool_code": "adhd",
    "tool_name": "ADHD Quick Screening",
    "tool_name_te": "ADHD త్వరిత స్క్రీనింగ్",
    "age_range_months": [36, 72],
    "description": "Quick screening tool for Attention Deficit Hyperactivity Disorder",
    "scoring_info": {
        "method": "Count 'Yes' responses",
        "max_score": 10,
        "risk_threshold": 5,
        "high_risk_threshold": 7
    },
    "questions": [
        {"id": "adhd_1", "item_number": 1, "domain": "Hyperactivity", "domain_te": "అతిసక్రియత", "question": "Does your child have trouble sitting still during meals or story time?", "question_te": "ఆహారం లేదా కథ సమయంలో ప్రశాంతంగా కూర్చోవడంలో ఇబ్బంది పడతారా?", "response_options": ["Yes", "No"], "scoring": {"Yes": 1, "No": 0}},
        {"id": "adhd_2", "item_number": 2, "domain": "Hyperactivity", "domain_te": "అతిసక్రియత", "question": "Does your child seem to be 'always on the go'?", "question_te": "మీ బిడ్డ 'ఎల్లప్పుడూ కదులుతూ' ఉన్నట్లు అనిపిస్తుందా?", "response_options": ["Yes", "No"], "scoring": {"Yes": 1, "No": 0}},
        {"id": "adhd_3", "item_number": 3, "domain": "Impulsivity", "domain_te": "ఆవేగశీలత", "question": "Does your child have difficulty waiting for their turn?", "question_te": "మీ బిడ్డ వారి మారు వచ్చేంతవరకు ఎదురుచూడటంలో ఇబ్బంది పడతారా?", "response_options": ["Yes", "No"], "scoring": {"Yes": 1, "No": 0}},
        {"id": "adhd_4", "item_number": 4, "domain": "Impulsivity", "domain_te": "ఆవేగశీలత", "question": "Does your child interrupt others frequently?", "question_te": "మీ బిడ్డ తరచుగా ఇతరుల మాటల్లో కలత చేస్తారా?", "response_options": ["Yes", "No"], "scoring": {"Yes": 1, "No": 0}},
        {"id": "adhd_5", "item_number": 5, "domain": "Inattention", "domain_te": "అశ్రద్ధ", "question": "Does your child have trouble following simple 2-3 step directions?", "question_te": "సరళమైన 2-3 అడుగుల సూచనలను అనుసరించడంలో ఇబ్బంది పడతారా?", "response_options": ["Yes", "No"], "scoring": {"Yes": 1, "No": 0}},
        {"id": "adhd_6", "item_number": 6, "domain": "Inattention", "domain_te": "అశ్రద్ధ", "question": "Does your child get distracted easily during play?", "question_te": "ఆడుతున్నప్పుడు మీ బిడ్డ సులభంగా శ్రద్త కోల్పోతారా?", "response_options": ["Yes", "No"], "scoring": {"Yes": 1, "No": 0}},
        {"id": "adhd_7", "item_number": 7, "domain": "Inattention", "domain_te": "అశ్రద్ధ", "question": "Does your child lose toys or belongings often?", "question_te": "మీ బిడ్డ తరచుగా బొమ్మలు లేదా వస్తువులను పోగొట్టుకుంటారా?", "response_options": ["Yes", "No"], "scoring": {"Yes": 1, "No": 0}},
        {"id": "adhd_8", "item_number": 8, "domain": "Hyperactivity", "domain_te": "అతిసక్రియత", "question": "Does your child have difficulty playing quietly?", "question_te": "మీ బిడ్డ ప్రశాంతంగా ఆడటంలో ఇబ్బంది పడతారా?", "response_options": ["Yes", "No"], "scoring": {"Yes": 1, "No": 0}},
        {"id": "adhd_9", "item_number": 9, "domain": "Hyperactivity", "domain_te": "అతిసక్రియత", "question": "Does your child talk excessively?", "question_te": "మీ బిడ్డ అత్యధికంగా మాట్లాడతారా?", "response_options": ["Yes", "No"], "scoring": {"Yes": 1, "No": 0}},
        {"id": "adhd_10", "item_number": 10, "domain": "Impulsivity", "domain_te": "ఆవేగశీలత", "question": "Does your child act without thinking about consequences?", "question_te": "మీ బిడ్డ పరిణామాల గురించి ఆలోచించకుండా ప్రవర్తిస్తారా?", "response_options": ["Yes", "No"], "scoring": {"Yes": 1, "No": 0}},
    ]
}


# ============================================================================
# SDQ: STRENGTHS & DIFFICULTIES QUESTIONNAIRE (24-72 Months)
# ============================================================================
SDQ_QUESTIONNAIRE = {
    "tool_code": "sdq",
    "tool_name": "SDQ - Strengths & Difficulties Questionnaire",
    "tool_name_te": "SDQ - బలాలు & ఇబ్బందుల ప్రశ్నావళి",
    "age_range_months": [24, 72],
    "description": "WHO-aligned behavioral screening tool",
    "scoring_info": {
        "response_scale": "0=Not True, 1=Somewhat True, 2=Certainly True",
        "subscales": {
            "emotional": [1, 2, 3, 4, 5],
            "conduct": [6, 7, 8, 9, 10],
            "hyperactivity": [11, 12, 13, 14, 15],
            "peer_problems": [16, 17, 18, 19, 20],
            "prosocial": [21, 22, 23, 24, 25]
        },
        "reverse_scored": [7, 14, 15, 17, 18]
    },
    "questions": [
        # Emotional Symptoms
        {"id": "sdq_1", "item_number": 1, "domain": "Emotional Symptoms", "domain_te": "భావోద్వేగ లక్షణాలు", "question": "Often complains of headaches, stomach-aches or sickness", "question_te": "తరచుగా తలనొప్పి, కడుపునొప్పి లేదా అనారోగ్యం ఫిర్యాదు చేస్తారు", "reverse": False},
        {"id": "sdq_2", "item_number": 2, "domain": "Emotional Symptoms", "domain_te": "భావోద్వేగ లక్షణాలు", "question": "Many worries, often seems worried", "question_te": "అనేక ఆందోళనలు, తరచుగా ఆందోళనగా కనిపిస్తారు", "reverse": False},
        {"id": "sdq_3", "item_number": 3, "domain": "Emotional Symptoms", "domain_te": "భావోద్వేగ లక్షణాలు", "question": "Often unhappy, down-hearted or tearful", "question_te": "తరచుగా అసంతృప్తిగా, నిరుత్సాహంగా లేదా కన్నీళ్లుగా ఉంటారు", "reverse": False},
        {"id": "sdq_4", "item_number": 4, "domain": "Emotional Symptoms", "domain_te": "భావోద్వేగ లక్షణాలు", "question": "Nervous or clingy in new situations, easily loses confidence", "question_te": "కొత్త పరిస్థితులలో నర్వస్ గా లేదా అంటిపడేలా, సులభంగా ఆత్మవిశ్వాసం కోల్పోతారు", "reverse": False},
        {"id": "sdq_5", "item_number": 5, "domain": "Emotional Symptoms", "domain_te": "భావోద్వేగ లక్షణాలు", "question": "Many fears, easily scared", "question_te": "అనేక భయాలు, సులభంగా భయపడతారు", "reverse": False},
        # Conduct Problems
        {"id": "sdq_6", "item_number": 6, "domain": "Conduct Problems", "domain_te": "నిర్వహణ సమస్యలు", "question": "Often has temper tantrums or hot tempers", "question_te": "తరచుగా కోపం ప్రదర్శిస్తారు", "reverse": False},
        {"id": "sdq_7", "item_number": 7, "domain": "Conduct Problems", "domain_te": "నిర్వహణ సమస్యలు", "question": "Generally obedient, usually does what adults request", "question_te": "సాధారణంగా విధేయులు, సాధారణంగా పెద్దలు అడిగినది చేస్తారు", "reverse": True},
        {"id": "sdq_8", "item_number": 8, "domain": "Conduct Problems", "domain_te": "నిర్వహణ సమస్యలు", "question": "Often fights with other children or bullies them", "question_te": "తరచుగా ఇతర పిల్లలతో కొట్టుకుంటారు లేదా బెదిరిస్తారు", "reverse": False},
        {"id": "sdq_9", "item_number": 9, "domain": "Conduct Problems", "domain_te": "నిర్వహణ సమస్యలు", "question": "Often lies or cheats", "question_te": "తరచుగా అబద్ధాలు చెబుతారు లేదా మోసం చేస్తారు", "reverse": False},
        {"id": "sdq_10", "item_number": 10, "domain": "Conduct Problems", "domain_te": "నిర్వహణ సమస్యలు", "question": "Steals from home, school or elsewhere", "question_te": "ఇంటి నుండి, పాఠశాల నుండి లేదా ఇతరచోట్ల దొంగిలిస్తారు", "reverse": False},
        # Hyperactivity
        {"id": "sdq_11", "item_number": 11, "domain": "Hyperactivity", "domain_te": "అతిసక్రియత", "question": "Restless, overactive, cannot stay still for long", "question_te": "అశాంతంగా, అతిసక్రియంగా, దీర్ఘకాలం ప్రశాంతంగా ఉండలేరు", "reverse": False},
        {"id": "sdq_12", "item_number": 12, "domain": "Hyperactivity", "domain_te": "అతిసక్రియత", "question": "Constantly fidgeting or squirming", "question_te": "నిరంతరం కదులుతూ లేదా వంగుతూ ఉంటారు", "reverse": False},
        {"id": "sdq_13", "item_number": 13, "domain": "Hyperactivity", "domain_te": "అతిసక్రియత", "question": "Easily distracted, concentration wanders", "question_te": "సులభంగా శ్రద్త కోల్పోతారు, ఏకాగ్రత తప్పుతుంది", "reverse": False},
        {"id": "sdq_14", "item_number": 14, "domain": "Hyperactivity", "domain_te": "అతిసక్రియత", "question": "Thinks things out before acting", "question_te": "చర్య తీసుకునే ముందు విషయాలను ఆలోచిస్తారు", "reverse": True},
        {"id": "sdq_15", "item_number": 15, "domain": "Hyperactivity", "domain_te": "అతిసక్రియత", "question": "Sees tasks through to the end, good attention span", "question_te": "పనులను చివరి వరకు చేస్తారు, మంచి ఏకాగ్రత కాలం", "reverse": True},
        # Peer Problems
        {"id": "sdq_16", "item_number": 16, "domain": "Peer Problems", "domain_te": "సమవయస్కుల సమస్యలు", "question": "Rather solitary, tends to play alone", "question_te": "ఒంటరిగా ఉంటారు, ఒంటరిగా ఆడటానికి ఇష్టపడతారు", "reverse": False},
        {"id": "sdq_17", "item_number": 17, "domain": "Peer Problems", "domain_te": "సమవయస్కుల సమస్యలు", "question": "Has at least one good friend", "question_te": "కనీసం ఒక మంచి స్నేహితుడు ఉన్నాడు", "reverse": True},
        {"id": "sdq_18", "item_number": 18, "domain": "Peer Problems", "domain_te": "సమవయస్కుల సమస్యలు", "question": "Generally liked by other children", "question_te": "సాధారణంగా ఇతర పిల్లలచే ఇష్టపడబడతారు", "reverse": True},
        {"id": "sdq_19", "item_number": 19, "domain": "Peer Problems", "domain_te": "సమవయస్కుల సమస్యలు", "question": "Picked on or bullied by other children", "question_te": "ఇతర పిల్లలచే ఇబ్బంది పెట్టబడతారు లేదా బెదిరించబడతారు", "reverse": False},
        {"id": "sdq_20", "item_number": 20, "domain": "Peer Problems", "domain_te": "సమవయస్కుల సమస్యలు", "question": "Gets on better with adults than other children", "question_te": "ఇతర పిల్లల కంటే పెద్దలతో మెరుగ్గా ఉంటారు", "reverse": False},
        # Prosocial Behavior
        {"id": "sdq_21", "item_number": 21, "domain": "Prosocial Behavior", "domain_te": "ప్రోసోషల్ ప్రవర్తన", "question": "Considerate of other people's feelings", "question_te": "ఇతరుల భావోద్వేగాలను పరిగణనలోకి తీసుకుంటారు", "reverse": False},
        {"id": "sdq_22", "item_number": 22, "domain": "Prosocial Behavior", "domain_te": "ప్రోసోషల్ ప్రవర్తన", "question": "Shares readily with other children", "question_te": "ఇతర పిల్లలతో సిద్ధంగా పంచుకుంటారు", "reverse": False},
        {"id": "sdq_23", "item_number": 23, "domain": "Prosocial Behavior", "domain_te": "ప్రోసోషల్ ప్రవర్తన", "question": "Helpful if someone is hurt, upset or feeling ill", "question_te": "ఎవరైనా గాయపడితే, బాధపడితే లేదా అనారోగ్యంగా ఉంటే సహాయం చేస్తారు", "reverse": False},
        {"id": "sdq_24", "item_number": 24, "domain": "Prosocial Behavior", "domain_te": "ప్రోసోషల్ ప్రవర్తన", "question": "Kind to younger children", "question_te": "చిన్న పిల్లలపై దయగా ఉంటారు", "reverse": False},
        {"id": "sdq_25", "item_number": 25, "domain": "Prosocial Behavior", "domain_te": "ప్రోసోషల్ ప్రవర్తన", "question": "Often volunteers to help others", "question_te": "తరచుగా ఇతరులకు సహాయం చేయడానికి ముందుకు వస్తారు", "reverse": False},
        # Impact Supplement
        {"id": "sdq_26", "item_number": 26, "domain": "Impact Supplement", "domain_te": "ప్రభావ పూరకం", "question": "Overall, do you think your child has difficulties?", "question_te": "మొత్తంమీద, మీ బిడ్డకు ఇబ్బందులు ఉన్నాయని అనుకుంటున్నారా?", "type": "categorical"},
        {"id": "sdq_27", "item_number": 27, "domain": "Impact Supplement", "domain_te": "ప్రభావ పూరకం", "question": "How long have these difficulties been present?", "question_te": "ఈ ఇబ్బందులు ఎంతకాలం ఉన్నాయి?", "type": "categorical"},
    ]
}


# ============================================================================
# RBSK DEVELOPMENTAL SCREENING (36-72 Months)
# ============================================================================
RBSK_QUESTIONNAIRE = {
    "tool_code": "rbsk",
    "tool_name": "RBSK Developmental Screening",
    "tool_name_te": "RBSK అభివృద్ధి స్క్రీనింగ్",
    "age_range_months": [36, 72],
    "description": "Rashtriya Bal Swasthya Karyakram - Government of India developmental screening tool",
    "source": "RBSK - Government of India",
    "scoring_info": {
        "response_scale": "To High Extent (3), To Some Extent (2), To Low Extent/Not at All (1)",
        "interpretation": {
            "age_appropriate": "At least 3 out of 5 items 'To High Extent' in each domain",
            "needs_inputs": "At least 3 out of 5 items 'To Some Extent'",
            "refer_tertiary": "At least 2 out of 5 items 'To Low Extent/Not at All'"
        }
    },
    "questions": [
        {"id": "rbsk_1", "item_number": 1, "domain": "Motor Skills", "domain_te": "మోటార్ నైపుణ్యాలు", "question": "Throws a ball", "question_te": "బంతిని విసురుతారు"},
        {"id": "rbsk_2", "item_number": 2, "domain": "Motor Skills", "domain_te": "మోటార్ నైపుణ్యాలు", "question": "Jumps in place", "question_te": "ఒకే చోట దుముతారు"},
        {"id": "rbsk_3", "item_number": 3, "domain": "Motor Skills", "domain_te": "మోటార్ నైపుణ్యాలు", "question": "Holds pencil to scribble/draw", "question_te": "గీయడానికి పెన్సిల్ పట్టుకుంటారు"},
        {"id": "rbsk_4", "item_number": 4, "domain": "Motor Skills", "domain_te": "మోటార్ నైపుణ్యాలు", "question": "Folds paper in half in imitation", "question_te": "అనుకరణలో కాగితాన్ని సగానికి మడుస్తారు"},
        {"id": "rbsk_5", "item_number": 5, "domain": "Motor Skills", "domain_te": "మోటార్ నైపుణ్యాలు", "question": "Takes out small objects from container", "question_te": "పాత్ర నుండి చిన్న వస్తువులను తీస్తారు"},
        {"id": "rbsk_6", "item_number": 6, "domain": "Speech & Language", "domain_te": "వాక్ & భాష", "question": "Does child ask 'What is this'", "question_te": "బిడ్డ 'ఇది ఏమిటి' అని అడుగుతారా"},
        {"id": "rbsk_7", "item_number": 7, "domain": "Speech & Language", "domain_te": "వాక్ & భాష", "question": "Combine 2-3 different words to convey need", "question_te": "అవసరం తెలుపడానికి 2-3 వేర్వేరు పదాలను కలుపుతారు"},
        {"id": "rbsk_8", "item_number": 8, "domain": "Speech & Language", "domain_te": "వాక్ & భాష", "question": "Names 3 common objects if pointed to", "question_te": "మీరు చూపిస్తే 3 సాధారణ వస్తువుల పేర్లు చెబుతారు"},
        {"id": "rbsk_9", "item_number": 9, "domain": "Speech & Language", "domain_te": "వాక్ & భాష", "question": "Can recite simple 2-3 line nursery rhyme", "question_te": "సరళమైన 2-3 వరుసల నర్సరీ రైమ్ చెబుతారు"},
        {"id": "rbsk_10", "item_number": 10, "domain": "Speech & Language", "domain_te": "వాక్ & భాష", "question": "States action being performed when picture shown", "question_te": "చిత్రం చూపించినప్పుడు చేస్తున్న చర్యను చెబుతారు"},
        {"id": "rbsk_11", "item_number": 11, "domain": "Cognitive", "domain_te": "జ్ఞానాత్మకం", "question": "Able to sit in one place for 15 minutes", "question_te": "ఒకే చోట 15 నిమిషాలు కూర్చోగలరు"},
        {"id": "rbsk_12", "item_number": 12, "domain": "Cognitive", "domain_te": "జ్ఞానాత్మకం", "question": "Comprehends and executes simple instructions", "question_te": "సరళమైన సూచనలను అర్థం చేసుకుని అమలు చేస్తారు"},
        {"id": "rbsk_13", "item_number": 13, "domain": "Cognitive", "domain_te": "జ్ఞానాత్మకం", "question": "Identifies sizes/age (big-small, younger-older)", "question_te": "పరిమాణాలు/వయసును గుర్తిస్తారు"},
        {"id": "rbsk_14", "item_number": 14, "domain": "Cognitive", "domain_te": "జ్ఞానాత్మకం", "question": "Identifies functions of objects", "question_te": "వస్తువుల స్వభావాలను గుర్తిస్తారు"},
        {"id": "rbsk_15", "item_number": 15, "domain": "Cognitive", "domain_te": "జ్ఞానాత్మకం", "question": "Identifies at least 5 body parts", "question_te": "కనీసం 5 శరీర భాగాలను గుర్తిస్తారు"},
        {"id": "rbsk_16", "item_number": 16, "domain": "Social Skills", "domain_te": "సామాజిక నైపుణ్యాలు", "question": "Recognizes family/familiar people like teacher", "question_te": "కుటుంబ/పరిచిత వ్యక్తులను గుర్తిస్తారు"},
        {"id": "rbsk_17", "item_number": 17, "domain": "Social Skills", "domain_te": "సామాజిక నైపుణ్యాలు", "question": "Recognizes spaces and their function", "question_te": "స్థలాలను మరియు వాటి స్వభావాలను గుర్తిస్తారు"},
        {"id": "rbsk_18", "item_number": 18, "domain": "Social Skills", "domain_te": "సామాజిక నైపుణ్యాలు", "question": "Understands rules of simple games", "question_te": "సరళమైన ఆటల నియమాలను అర్థం చేసుకుంటారు"},
        {"id": "rbsk_19", "item_number": 19, "domain": "Social Skills", "domain_te": "సామాజిక నైపుణ్యాలు", "question": "Interacts/plays & talks with other children", "question_te": "ఇతర పిల్లలతో పరస్పర చర్య/ఆడుతారు & మాట్లాడతారు"},
        {"id": "rbsk_20", "item_number": 20, "domain": "Social Skills", "domain_te": "సామాజిక నైపుణ్యాలు", "question": "Can enumerate routine/daily activities", "question_te": "రోజువారీ కార్యక్రమాలను లెక్కించగలరు"},
        {"id": "rbsk_21", "item_number": 21, "domain": "Emotional Skills", "domain_te": "భావోద్వేగ నైపుణ్యాలు", "question": "Can recognize common emotions (pictures)", "question_te": "సాధారణ భావోద్వేగాలను గుర్తించగలరు"},
        {"id": "rbsk_22", "item_number": 22, "domain": "Emotional Skills", "domain_te": "భావోద్వేగ నైపుణ్యాలు", "question": "When upset, can be easily comforted", "question_te": "బాధపడినప్పుడు, సులభంగా ఓదార్చబడతారు"},
        {"id": "rbsk_23", "item_number": 23, "domain": "Emotional Skills", "domain_te": "భావోద్వేగ నైపుణ్యాలు", "question": "Is explorative and curious", "question_te": "అన్వేషణాత్మకంగా మరియు ఆసక్తిగా ఉంటారు"},
        {"id": "rbsk_24", "item_number": 24, "domain": "Emotional Skills", "domain_te": "భావోద్వేగ నైపుణ్యాలు", "question": "Comfortable when mother/caregiver away", "question_te": "తల్లి/పోషకుడు లేనప్పుడు సౌకర్యవంతంగా ఉంటారు"},
        {"id": "rbsk_25", "item_number": 25, "domain": "Emotional Skills", "domain_te": "భావోద్వేగ నైపుణ్యాలు", "question": "Helpful and caring of other children", "question_te": "ఇతర పిల్లలకు సహాయకరంగా మరియు శ్రద్ధగా ఉంటారు"},
    ]
}


# ============================================================================
# RBSK QUICK BEHAVIORAL SCREENING (24-72 Months)
# ============================================================================
RBSK_BEHAVIORAL_QUESTIONNAIRE = {
    "tool_code": "rbsk_behavioral",
    "tool_name": "RBSK Quick Behavioral Screening",
    "tool_name_te": "RBSK త్వరిత ప్రవర్తనా స్క్రీనింగ్",
    "age_range_months": [24, 72],
    "description": "Quick behavioral screening for emotional regulation and social concerns",
    "scoring_info": {
        "method": "Count 'Yes' responses",
        "max_score": 10,
        "risk_threshold": 3
    },
    "questions": [
        {"id": "rbsk_beh_1", "item_number": 1, "domain": "Emotional Regulation", "domain_te": "భావోద్వేగ నియంత్రణ", "question": "Does child have frequent temper tantrums (more than 3-4 times daily)?", "question_te": "బిడ్డ తరచుగా కోపం ప్రదర్శిస్తారా?", "response_options": ["Yes", "No"]},
        {"id": "rbsk_beh_2", "item_number": 2, "domain": "Emotional Regulation", "domain_te": "భావోద్వేగ నియంత్రణ", "question": "Does child cry for long periods without clear reason?", "question_te": "బిడ్డ స్పష్టమైన కారణం లేకుండా దీర్ఘకాలం పాటు ఏడుస్తారా?", "response_options": ["Yes", "No"]},
        {"id": "rbsk_beh_3", "item_number": 3, "domain": "Emotional Regulation", "domain_te": "భావోద్వేగ నియంత్రణ", "question": "Is child excessively fearful or anxious?", "question_te": "బిడ్డ అత్యధికంగా భయపడేలా లేదా ఆందోళన చెందుతారా?", "response_options": ["Yes", "No"]},
        {"id": "rbsk_beh_4", "item_number": 4, "domain": "Social Behavior", "domain_te": "సామాజిక ప్రవర్తన", "question": "Does child avoid playing with other children?", "question_te": "బిడ్డ ఇతర పిల్లలతో ఆడటం తప్పించుకుంటారా?", "response_options": ["Yes", "No"]},
        {"id": "rbsk_beh_5", "item_number": 5, "domain": "Social Behavior", "domain_te": "సామాజిక ప్రవర్తన", "question": "Does child show aggression toward others (hitting, biting)?", "question_te": "బిడ్డ ఇతరులపై దాడి ప్రవర్తనను చూపిస్తారా?", "response_options": ["Yes", "No"]},
        {"id": "rbsk_beh_6", "item_number": 6, "domain": "Social Behavior", "domain_te": "సామాజిక ప్రవర్తన", "question": "Does child refuse to follow simple instructions consistently?", "question_te": "బిడ్డ సరళమైన సూచనలను నిరంతరం అనుసరించడానికి నిరాకరిస్తారా?", "response_options": ["Yes", "No"]},
        {"id": "rbsk_beh_7", "item_number": 7, "domain": "Self-Regulation", "domain_te": "స్వీయ నియంత్రణ", "question": "Does child have extreme difficulty with changes in routine?", "question_te": "బిడ్డ పద్ధతులలో మార్పులతో అత్యధిక ఇబ్బంది పడతారా?", "response_options": ["Yes", "No"]},
        {"id": "rbsk_beh_8", "item_number": 8, "domain": "Self-Regulation", "domain_te": "స్వీయ నియంత్రణ", "question": "Does child harm themselves (head-banging, scratching)?", "question_te": "బిడ్డ స్వయంగా గాయం చేసుకుంటారా?", "response_options": ["Yes", "No"]},
        {"id": "rbsk_beh_9", "item_number": 9, "domain": "Sleep & Eating", "domain_te": "నిద్ర & ఆహారం", "question": "Does child have severe sleep problems?", "question_te": "బిడ్డకు తీవ్రమైన నిద్ర సమస్యలు ఉన్నాయా?", "response_options": ["Yes", "No"]},
        {"id": "rbsk_beh_10", "item_number": 10, "domain": "Sleep & Eating", "domain_te": "నిద్ర & ఆహారం", "question": "Does child have severe eating problems?", "question_te": "బిడ్డకు తీవ్రమైన ఆహార సమస్యలు ఉన్నాయా?", "response_options": ["Yes", "No"]},
    ]
}


# ============================================================================
# ENVIRONMENT & CAREGIVING ASSESSMENT (0-72 Months)
# ============================================================================
ENVIRONMENT_CAREGIVING_QUESTIONNAIRE = {
    "tool_code": "environment",
    "tool_name": "Environment & Caregiving Assessment",
    "tool_name_te": "పర్యావరణం & శుశ్రూష మూల్యాంకనం",
    "age_range_months": [0, 72],
    "description": "Comprehensive assessment of home environment and caregiving quality",
    "scoring_info": {
        "total_items": 22,
        "score_range": [0, 22],
        "interpretation": {
            "low": {"max": 7, "code": 3},
            "medium": {"min": 8, "max": 15, "code": 6},
            "high": {"min": 16, "code": 9}
        }
    },
    "questions": [
        # Play Materials
        {"id": "hm_1", "item_code": "HM1", "domain": "Play Materials", "domain_te": "ఆట సామాగ్రి", "question": "Child has toys to push or pull (cars, animals, etc.)", "question_te": "బిడ్డకు నెట్టడానికి లేదా లాగడానికి బొమ్మలు ఉన్నాయి"},
        {"id": "hm_2", "item_code": "HM2", "domain": "Play Materials", "domain_te": "ఆట సామాగ్రి", "question": "Child has ball or similar toy for active play", "question_te": "బిడ్డకు బంతి లేదా సక్రియ ఆటకు ఇదే వంటి బొమ్మ ఉంది"},
        {"id": "hm_3", "item_code": "HM3", "domain": "Play Materials", "domain_te": "ఆట సామాగ్రి", "question": "Child has toys for pretend play (dolls, kitchen set, etc.)", "question_te": "బిడ్డకు నటన ఆటకు బొమ్మలు ఉన్నాయి"},
        {"id": "hm_4", "item_code": "HM4", "domain": "Play Materials", "domain_te": "ఆట సామాగ్రి", "question": "Child has toys for learning shapes and colors", "question_te": "బిడ్డకు ఆకారాలు మరియు రంగులు నేర్చుకోవడానికి బొమ్మలు ఉన్నాయి"},
        {"id": "hm_5", "item_code": "HM5", "domain": "Play Materials", "domain_te": "ఆట సామాగ్రి", "question": "Child has building toys (blocks, legos, etc.)", "question_te": "బిడ్డకు నిర్మాణ బొమ్మలు ఉన్నాయి"},
        {"id": "hm_6", "item_code": "HM6", "domain": "Play Materials", "domain_te": "ఆట సామాగ్రి", "question": "Child has toys for fine motor skills (puzzles, beads, etc.)", "question_te": "బిడ్డకు సూక్ష్మ మోటార్ నైపుణ్యాల కోసం బొమ్మలు ఉన్నాయి"},
        {"id": "hm_7", "item_code": "HM7", "domain": "Play Materials", "domain_te": "ఆట సామాగ్రి", "question": "Child has at least 3 children's books", "question_te": "బిడ్డకు కనీసం 3 పిల్లల పుస్తకాలు ఉన్నాయి"},
        {"id": "hm_8", "item_code": "HM8", "domain": "Play Materials", "domain_te": "ఆట సామాగ్రి", "question": "Child has materials for drawing/coloring", "question_te": "బిడ్డకు గీయడం/రంగులు వేయడానికి సామగ్రి ఉంది"},
        {"id": "hm_9", "item_code": "HM9", "domain": "Play Materials", "domain_te": "ఆట సామాగ్రి", "question": "Child has access to music (instruments, songs)", "question_te": "బిడ్డకు సంగీతం (వాయిద్యాలు, పాటలు) అందుబాటులో ఉంది"},
        # Language & Literacy Environment
        {"id": "hm_10", "item_code": "HM10", "domain": "Language & Literacy", "domain_te": "భాష & అక్షరాస్యత", "question": "Family has at least 3 books (adult or children)", "question_te": "కుటుంబానికి కనీసం 3 పుస్తకాలు ఉన్నాయి"},
        {"id": "hm_11", "item_code": "HM11", "domain": "Language & Literacy", "domain_te": "భాష & అక్షరాస్యత", "question": "Parent reads to child at least 3x per week", "question_te": "పోషకుడు వారానికి కనీసం 3 సార్లు బిడ్డకు చదువుతారు"},
        {"id": "hm_12", "item_code": "HM12", "domain": "Language & Literacy", "domain_te": "భాష & అక్షరాస్యత", "question": "Child is told stories at least 3x per week", "question_te": "బిడ్డకు వారానికి కనీసం 3 సార్లు కథలు చెబుతారు"},
        {"id": "hm_13", "item_code": "HM13", "domain": "Language & Literacy", "domain_te": "భాష & అక్షరాస్యత", "question": "Parent sings songs with child", "question_te": "పోషకుడు బిడ్డతో పాటలు పాడతారు"},
        {"id": "hm_14", "item_code": "HM14", "domain": "Language & Literacy", "domain_te": "భాష & అక్షరాస్యత", "question": "Parent points to and names objects for child", "question_te": "పోషకుడు బిడ్డకు వస్తువులను చూపించి పేర్లు చెబుతారు"},
        # Caregiver Engagement
        {"id": "hm_15", "item_code": "HM15", "domain": "Caregiver Engagement", "domain_te": "పోషకుడు బాధ్యత", "question": "Parent engages in at least 4 activities with child in last 3 days", "question_te": "పోషకుడు గత 3 రోజుల్లో కనీసం 4 కార్యక్రమాలలో బిడ్డతో పాల్గొన్నారు"},
        {"id": "hm_16", "item_code": "HM16", "domain": "Caregiver Engagement", "domain_te": "పోషకుడు బాధ్యత", "question": "At least 2 household members engage with child", "question_te": "కనీసం 2 ఇంటి సభ్యులు బిడ్డతో పాల్గొంటారు"},
        {"id": "hm_17", "item_code": "HM17", "domain": "Caregiver Engagement", "domain_te": "పోషకుడు బాధ్యత", "question": "Child has regular playtime scheduled daily", "question_te": "బిడ్డకు రోజువారీ క్రమపద్ధతిలో ఆట సమయం ఉంది"},
        {"id": "hm_18", "item_code": "HM18", "domain": "Caregiver Engagement", "domain_te": "పోషకుడు బాధ్యత", "question": "Parent responds when child seeks attention", "question_te": "బిడ్డ శ్రద్ధ కోరినప్పుడు పోషకుడు స్పందిస్తారు"},
        # Home Safety & Environment
        {"id": "hm_19", "item_code": "HM19", "domain": "Home Safety", "domain_te": "ఇంటి భద్రత", "question": "Home has safe drinking water", "question_te": "ఇంటికి శుద్ధమైన తాగునీరు ఉంది"},
        {"id": "hm_20", "item_code": "HM20", "domain": "Home Safety", "domain_te": "ఇంటి భద్రత", "question": "Home has toilet facility (flush/pit/latrine)", "question_te": "ఇంటికి మరుగుదొడ్ల సౌకర్యం ఉంది"},
        {"id": "hm_21", "item_code": "HM21", "domain": "Home Safety", "domain_te": "ఇంటి భద్రత", "question": "Home is reasonably clean and safe for child", "question_te": "ఇల్లు బిడ్డకు సమీకృతంగా శుభ్రంగా మరియు సురక్షితంగా ఉంది"},
        {"id": "hm_22", "item_code": "HM22", "domain": "Home Safety", "domain_te": "ఇంటి భద్రత", "question": "Child has safe place to play at home", "question_te": "బిడ్డకు ఇంట్లో సురక్షితంగా ఆడుకునే స్థలం ఉంది"},
    ]
}


# ============================================================================
# COMPLETE QUESTIONNAIRE DATA AGGREGATION
# ============================================================================

# Main questionnaire data structure
COMPLETE_QUESTIONNAIRE = {
    "version": "2.0",
    "version_name": "Complete ECD Assessment",
    "version_name_te": "పూర్తి ECD మూల్యాంకనం",
    "age_range_months": [0, 72],
    "updated_at": "2025-02-07",
    "source": "WHO | CDC | NIMHANS | RBSK",
    "tools": {
        "cdc_milestones": CDC_MILESTONES,
        "mchat": MCHAT_QUESTIONNAIRE,
        "isaa": ISAA_QUESTIONNAIRE,
        "adhd": ADHD_QUESTIONNAIRE,
        "sdq": SDQ_QUESTIONNAIRE,
        "rbsk": RBSK_QUESTIONNAIRE,
        "rbsk_behavioral": RBSK_BEHAVIORAL_QUESTIONNAIRE,
        "environment": ENVIRONMENT_CAREGIVING_QUESTIONNAIRE,
    }
}


# Demo questionnaire for backward compatibility
DEMO_QUESTIONNAIRE = CDC_MILESTONES


# ============================================================================
# API ENDPOINTS
# ============================================================================

@router.get("/latest")
def get_latest_questionnaire(db: Session = Depends(get_db)):
    """Get the latest active questionnaire with complete data"""
    questionnaire = db.query(QuestionnaireVersion).filter(
        QuestionnaireVersion.is_active == True
    ).order_by(QuestionnaireVersion.created_at.desc()).first()
    
    if not questionnaire:
        # Return complete questionnaire
        return {
            "version_id": 0,
            "version_number": "2.0-complete",
            "questionnaire_data": COMPLETE_QUESTIONNAIRE,
            "is_active": True
        }
    
    return {
        "version_id": questionnaire.version_id,
        "version_number": questionnaire.version_number,
        "questionnaire_data": questionnaire.questionnaire_data,
        "is_active": questionnaire.is_active
    }


@router.get("/{version_id}")
def get_questionnaire_by_id(version_id: int, db: Session = Depends(get_db)):
    """Get a specific questionnaire version"""
    questionnaire = db.query(QuestionnaireVersion).filter(
        QuestionnaireVersion.version_id == version_id
    ).first()
    
    if not questionnaire:
        # Return demo/complete questionnaire for version 0
        if version_id == 0:
            return {
                "version_id": 0,
                "version_number": "2.0-complete",
                "questionnaire_data": COMPLETE_QUESTIONNAIRE,
                "is_active": True
            }
        raise HTTPException(status_code=404, detail="Questionnaire not found")
    
    return {
        "version_id": questionnaire.version_id,
        "version_number": questionnaire.version_number,
        "questionnaire_data": questionnaire.questionnaire_data,
        "is_active": questionnaire.is_active
    }


@router.get("/by-age/{age_months}")
def get_questionnaire_by_age(age_months: int, db: Session = Depends(get_db)):
    """
    Get age-appropriate questionnaire content.
    Returns CDC milestones and applicable screening tools based on child's age.
    """
    if age_months < 0 or age_months > 72:
        raise HTTPException(
            status_code=400, 
            detail="Age must be between 0 and 72 months"
        )
    
    # Filter CDC milestones by age
    age_appropriate_domains = []
    for domain in CDC_MILESTONES["domains"]:
        age_milestones = [
            m for m in domain["milestones"] 
            if m["age"] <= age_months
        ]
        if age_milestones:
            age_appropriate_domains.append({
                "code": domain["code"],
                "name": domain["name"],
                "name_te": domain["name_te"],
                "description": domain.get("description", ""),
                "milestones": age_milestones
            })
    
    # Determine which screening tools are applicable
    applicable_tools = []
    
    # M-CHAT: 16-30 months
    if 16 <= age_months <= 30:
        applicable_tools.append({
            "tool_code": MCHAT_QUESTIONNAIRE["tool_code"],
            "tool_name": MCHAT_QUESTIONNAIRE["tool_name"],
            "tool_name_te": MCHAT_QUESTIONNAIRE["tool_name_te"],
            "description": MCHAT_QUESTIONNAIRE["description"],
            "num_questions": len(MCHAT_QUESTIONNAIRE["questions"]),
            "critical_items": MCHAT_QUESTIONNAIRE["scoring_info"]["critical_items"]
        })
    
    # ISAA: 36-72 months
    if 36 <= age_months <= 72:
        applicable_tools.append({
            "tool_code": ISAA_QUESTIONNAIRE["tool_code"],
            "tool_name": ISAA_QUESTIONNAIRE["tool_name"],
            "tool_name_te": ISAA_QUESTIONNAIRE["tool_name_te"],
            "description": ISAA_QUESTIONNAIRE["description"],
            "num_questions": len(ISAA_QUESTIONNAIRE["questions"]),
            "num_domains": len(set(q["domain"] for q in ISAA_QUESTIONNAIRE["questions"]))
        })
    
    # ADHD: 36-72 months
    if 36 <= age_months <= 72:
        applicable_tools.append({
            "tool_code": ADHD_QUESTIONNAIRE["tool_code"],
            "tool_name": ADHD_QUESTIONNAIRE["tool_name"],
            "tool_name_te": ADHD_QUESTIONNAIRE["tool_name_te"],
            "description": ADHD_QUESTIONNAIRE["description"],
            "num_questions": len(ADHD_QUESTIONNAIRE["questions"]),
            "domains": list(set(q["domain"] for q in ADHD_QUESTIONNAIRE["questions"]))
        })
    
    # SDQ: 24-72 months
    if 24 <= age_months <= 72:
        applicable_tools.append({
            "tool_code": SDQ_QUESTIONNAIRE["tool_code"],
            "tool_name": SDQ_QUESTIONNAIRE["tool_name"],
            "tool_name_te": SDQ_QUESTIONNAIRE["tool_name_te"],
            "description": SDQ_QUESTIONNAIRE["description"],
            "num_questions": len([q for q in SDQ_QUESTIONNAIRE["questions"] if "type" not in q]),
            "subscales": list(SDQ_QUESTIONNAIRE["scoring_info"]["subscales"].keys())
        })
    
    # RBSK: 36-72 months
    if 36 <= age_months <= 72:
        applicable_tools.append({
            "tool_code": RBSK_QUESTIONNAIRE["tool_code"],
            "tool_name": RBSK_QUESTIONNAIRE["tool_name"],
            "tool_name_te": RBSK_QUESTIONNAIRE["tool_name_te"],
            "description": RBSK_QUESTIONNAIRE["description"],
            "num_questions": len(RBSK_QUESTIONNAIRE["questions"]),
            "domains": list(set(q["domain"] for q in RBSK_QUESTIONNAIRE["questions"]))
        })
    
    # RBSK Behavioral: 24-72 months
    if 24 <= age_months <= 72:
        applicable_tools.append({
            "tool_code": RBSK_BEHAVIORAL_QUESTIONNAIRE["tool_code"],
            "tool_name": RBSK_BEHAVIORAL_QUESTIONNAIRE["tool_name"],
            "tool_name_te": RBSK_BEHAVIORAL_QUESTIONNAIRE["tool_name_te"],
            "description": RBSK_BEHAVIORAL_QUESTIONNAIRE["description"],
            "num_questions": len(RBSK_BEHAVIORAL_QUESTIONNAIRE["questions"]),
            "domains": list(set(q["domain"] for q in RBSK_BEHAVIORAL_QUESTIONNAIRE["questions"]))
        })
    
    # Environment & Caregiving: All ages
    applicable_tools.append({
        "tool_code": ENVIRONMENT_CAREGIVING_QUESTIONNAIRE["tool_code"],
        "tool_name": ENVIRONMENT_CAREGIVING_QUESTIONNAIRE["tool_name"],
        "tool_name_te": ENVIRONMENT_CAREGIVING_QUESTIONNAIRE["tool_name_te"],
        "description": ENVIRONMENT_CAREGIVING_QUESTIONNAIRE["description"],
        "num_questions": len(ENVIRONMENT_CAREGIVING_QUESTIONNAIRE["questions"]),
        "domains": list(set(q["domain"] for q in ENVIRONMENT_CAREGIVING_QUESTIONNAIRE["questions"]))
    })
    
    return {
        "child_age_months": age_months,
        "cdc_milestones": {
            "version": CDC_MILESTONES["version"],
            "domains": age_appropriate_domains
        },
        "applicable_screening_tools": applicable_tools,
        "total_milestones": sum(len(d["milestones"]) for d in age_appropriate_domains),
        "total_screening_questions": sum(t.get("num_questions", 0) for t in applicable_tools)
    }


@router.get("/tool/{tool_code}")
def get_screening_tool(tool_code: str):
    """
    Get complete questions for a specific screening tool.
    Tool codes: mchat, isaa, adhd, sdq, rbsk, rbsk_behavioral, environment
    """
    tools_map = {
        "mchat": MCHAT_QUESTIONNAIRE,
        "isaa": ISAA_QUESTIONNAIRE,
        "adhd": ADHD_QUESTIONNAIRE,
        "sdq": SDQ_QUESTIONNAIRE,
        "rbsk": RBSK_QUESTIONNAIRE,
        "rbsk_behavioral": RBSK_BEHAVIORAL_QUESTIONNAIRE,
        "environment": ENVIRONMENT_CAREGIVING_QUESTIONNAIRE,
        "cdc_milestones": CDC_MILESTONES,
    }
    
    tool = tools_map.get(tool_code.lower())
    if not tool:
        raise HTTPException(
            status_code=404, 
            detail=f"Tool '{tool_code}' not found. Available tools: {list(tools_map.keys())}"
        )
    
    return tool


@router.get("/tools/list")
def list_available_tools():
    """List all available screening tools with basic info"""
    tools = [
        {
            "tool_code": CDC_MILESTONES["domains"][0].get("code", "cdc"),
            "tool_name": "CDC Developmental Milestones",
            "tool_name_te": "CDC అభివృద్ధి మైలురాళ్లు",
            "age_range_months": CDC_MILESTONES["age_range_months"],
            "description": "CDC Learn the Signs. Act Early - Developmental milestones",
            "num_domains": len(CDC_MILESTONES["domains"])
        },
        {
            "tool_code": MCHAT_QUESTIONNAIRE["tool_code"],
            "tool_name": MCHAT_QUESTIONNAIRE["tool_name"],
            "tool_name_te": MCHAT_QUESTIONNAIRE["tool_name_te"],
            "age_range_months": MCHAT_QUESTIONNAIRE["age_range_months"],
            "description": MCHAT_QUESTIONNAIRE["description"],
            "num_questions": len(MCHAT_QUESTIONNAIRE["questions"])
        },
        {
            "tool_code": ISAA_QUESTIONNAIRE["tool_code"],
            "tool_name": ISAA_QUESTIONNAIRE["tool_name"],
            "tool_name_te": ISAA_QUESTIONNAIRE["tool_name_te"],
            "age_range_months": ISAA_QUESTIONNAIRE["age_range_months"],
            "description": ISAA_QUESTIONNAIRE["description"],
            "num_questions": len(ISAA_QUESTIONNAIRE["questions"])
        },
        {
            "tool_code": ADHD_QUESTIONNAIRE["tool_code"],
            "tool_name": ADHD_QUESTIONNAIRE["tool_name"],
            "tool_name_te": ADHD_QUESTIONNAIRE["tool_name_te"],
            "age_range_months": ADHD_QUESTIONNAIRE["age_range_months"],
            "description": ADHD_QUESTIONNAIRE["description"],
            "num_questions": len(ADHD_QUESTIONNAIRE["questions"])
        },
        {
            "tool_code": SDQ_QUESTIONNAIRE["tool_code"],
            "tool_name": SDQ_QUESTIONNAIRE["tool_name"],
            "tool_name_te": SDQ_QUESTIONNAIRE["tool_name_te"],
            "age_range_months": SDQ_QUESTIONNAIRE["age_range_months"],
            "description": SDQ_QUESTIONNAIRE["description"],
            "num_questions": len([q for q in SDQ_QUESTIONNAIRE["questions"] if "type" not in q])
        },
        {
            "tool_code": RBSK_QUESTIONNAIRE["tool_code"],
            "tool_name": RBSK_QUESTIONNAIRE["tool_name"],
            "tool_name_te": RBSK_QUESTIONNAIRE["tool_name_te"],
            "age_range_months": RBSK_QUESTIONNAIRE["age_range_months"],
            "description": RBSK_QUESTIONNAIRE["description"],
            "num_questions": len(RBSK_QUESTIONNAIRE["questions"])
        },
        {
            "tool_code": RBSK_BEHAVIORAL_QUESTIONNAIRE["tool_code"],
            "tool_name": RBSK_BEHAVIORAL_QUESTIONNAIRE["tool_name"],
            "tool_name_te": RBSK_BEHAVIORAL_QUESTIONNAIRE["tool_name_te"],
            "age_range_months": RBSK_BEHAVIORAL_QUESTIONNAIRE["age_range_months"],
            "description": RBSK_BEHAVIORAL_QUESTIONNAIRE["description"],
            "num_questions": len(RBSK_BEHAVIORAL_QUESTIONNAIRE["questions"])
        },
        {
            "tool_code": ENVIRONMENT_CAREGIVING_QUESTIONNAIRE["tool_code"],
            "tool_name": ENVIRONMENT_CAREGIVING_QUESTIONNAIRE["tool_name"],
            "tool_name_te": ENVIRONMENT_CAREGIVING_QUESTIONNAIRE["tool_name_te"],
            "age_range_months": ENVIRONMENT_CAREGIVING_QUESTIONNAIRE["age_range_months"],
            "description": ENVIRONMENT_CAREGIVING_QUESTIONNAIRE["description"],
            "num_questions": len(ENVIRONMENT_CAREGIVING_QUESTIONNAIRE["questions"])
        },
    ]
    
    return {
        "total_tools": len(tools),
        "tools": tools
    }


@router.post("/seed")
def seed_questionnaire(db: Session = Depends(get_db)):
    """Seed the complete questionnaire into the database"""
    existing = db.query(QuestionnaireVersion).filter(
        QuestionnaireVersion.version_number == "2.0-complete"
    ).first()
    
    if existing:
        return {"message": "Complete questionnaire already exists", "version_id": existing.version_id}
    
    questionnaire = QuestionnaireVersion(
        version_number="2.0-complete",
        questionnaire_data=COMPLETE_QUESTIONNAIRE,
        is_active=True
    )
    
    db.add(questionnaire)
    db.commit()
    db.refresh(questionnaire)
    
    return {
        "message": "Complete questionnaire seeded successfully",
        "version_id": questionnaire.version_id,
        "version_number": questionnaire.version_number
    }
