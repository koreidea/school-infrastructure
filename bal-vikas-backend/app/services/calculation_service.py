from typing import List, Dict, Any, Optional
from datetime import date
import math


class CalculationService:
    """Service for calculating DQ scores, z-scores, and risk classifications"""
    
    # WHO LMS parameters for India (simplified - load full tables in production)
    WHO_LMS_TABLES = {
        "hfa_boys": {
            # age_months: [L, M, S]
            0: [1, 49.9, 0.0379], 1: [1, 54.7, 0.0375], 2: [1, 58.4, 0.0371],
            3: [1, 61.4, 0.0368], 6: [1.01, 67.6, 0.0364], 9: [1.02, 72.3, 0.0362],
            12: [1.03, 76.1, 0.0361], 15: [1.03, 79.5, 0.036], 18: [1.03, 82.7, 0.036],
            21: [1.03, 85.6, 0.036], 24: [1.03, 87.1, 0.0363], 27: [1.02, 89.0, 0.0362],
            30: [1.02, 92.0, 0.0361], 33: [1.01, 94.1, 0.036], 36: [1.01, 96.1, 0.036],
            42: [1.0, 99.9, 0.0359], 48: [0.99, 103.3, 0.0359], 54: [0.98, 106.5, 0.0359],
            60: [0.97, 109.5, 0.036], 66: [0.96, 112.4, 0.0361], 72: [0.95, 115.2, 0.0362]
        },
        "hfa_girls": {
            0: [1, 49.1, 0.0379], 1: [1, 53.7, 0.0375], 2: [1, 57.1, 0.0371],
            3: [1, 59.8, 0.0368], 6: [1.01, 65.7, 0.0364], 9: [1.02, 70.4, 0.0362],
            12: [1.02, 74.0, 0.0361], 15: [1.02, 77.3, 0.036], 18: [1.02, 80.4, 0.036],
            21: [1.02, 83.2, 0.036], 24: [1.02, 85.7, 0.0364], 27: [1.01, 88.0, 0.0363],
            30: [1.01, 90.7, 0.0362], 33: [1.0, 92.9, 0.0361], 36: [1.0, 94.9, 0.0361],
            42: [0.99, 98.8, 0.036], 48: [0.98, 102.4, 0.036], 54: [0.97, 105.8, 0.036],
            60: [0.96, 109.0, 0.0361], 66: [0.95, 112.0, 0.0362], 72: [0.94, 114.9, 0.0363]
        },
        "wfa_boys": {
            0: [0.1738, 3.5, 0.152], 1: [0.078, 4.5, 0.125], 2: [0.039, 5.6, 0.112],
            3: [0.017, 6.4, 0.105], 6: [0.012, 7.9, 0.098], 9: [0.015, 8.9, 0.094],
            12: [0.021, 9.6, 0.091], 15: [0.032, 10.3, 0.088], 18: [0.045, 10.9, 0.087],
            21: [0.056, 11.5, 0.086], 24: [0.08, 12.2, 0.09], 27: [0.07, 12.9, 0.089],
            30: [0.06, 13.3, 0.089], 33: [0.05, 13.8, 0.088], 36: [0.04, 14.3, 0.088],
            42: [0.02, 15.3, 0.087], 48: [0.0, 16.3, 0.086], 54: [-0.02, 17.3, 0.085],
            60: [-0.04, 18.3, 0.084], 66: [-0.06, 19.3, 0.083], 72: [-0.08, 20.3, 0.082]
        },
        "wfa_girls": {
            0: [0.167, 3.4, 0.152], 1: [0.075, 4.2, 0.125], 2: [0.037, 5.1, 0.112],
            3: [0.015, 5.8, 0.105], 6: [0.01, 7.3, 0.098], 9: [0.013, 8.2, 0.094],
            12: [0.019, 8.9, 0.091], 15: [0.03, 9.6, 0.088], 18: [0.042, 10.2, 0.087],
            21: [0.053, 10.8, 0.086], 24: [0.08, 11.5, 0.09], 27: [0.07, 12.1, 0.089],
            30: [0.06, 12.7, 0.089], 33: [0.05, 13.3, 0.088], 36: [0.04, 13.9, 0.088],
            42: [0.02, 15.0, 0.087], 48: [0.0, 16.1, 0.086], 54: [-0.02, 17.2, 0.085],
            60: [-0.04, 18.2, 0.084], 66: [-0.06, 19.3, 0.083], 72: [-0.08, 20.3, 0.082]
        }
    }
    
    # M-CHAT critical items (1-indexed as per standard M-CHAT)
    MCHAT_CRITICAL_ITEMS = [2, 5, 7, 9, 13, 14, 15, 23]
    
    # SDQ Category mappings
    SDQ_CATEGORIES = {
        'sdq_1': 'emotional', 'sdq_2': 'emotional',
        'sdq_3': 'conduct', 'sdq_4': 'conduct', 'sdq_5': 'conduct',
        'sdq_6': 'hyperactivity', 'sdq_7': 'hyperactivity', 'sdq_8': 'hyperactivity',
        'sdq_9': 'peer', 'sdq_10': 'peer', 'sdq_11': 'peer',
        'sdq_12': 'prosocial', 'sdq_13': 'prosocial', 'sdq_14': 'prosocial'
    }
    
    # Environment question weights
    ENVIRONMENT_WEIGHTS = {
        'env_1': 2, 'env_2': 2, 'env_3': 2, 'env_4': 2,
        'env_5': 2, 'env_6': 2, 'env_7': 1, 'env_8': 2,
        'env_9': 2, 'env_10': 2, 'env_11': 2, 'env_12': 2,
        'env_13': 1, 'env_14': 1, 'env_15': 2
    }
    
    @staticmethod
    def calculate_domain_dq(chronological_age_months: int, milestones: List[Dict[str, Any]], responses: Dict[str, Any]) -> float:
        """
        Calculate DQ for a specific domain
        DQ = (Developmental Age / Chronological Age) × 100
        """
        # Find the highest age where child passes ALL milestones
        developmental_age_months = 0
        
        for age in range(2, chronological_age_months + 1):
            age_group_milestones = [m for m in milestones if m.get('age_months') == age]
            
            if not age_group_milestones:
                continue
                
            passed_all = True
            for milestone in age_group_milestones:
                question_id = milestone.get('question_id')
                if not responses.get(question_id, False):
                    passed_all = False
                    break
            
            if passed_all:
                developmental_age_months = age
            else:
                break
        
        if chronological_age_months == 0:
            return 0.0
            
        dq = (developmental_age_months / chronological_age_months) * 100
        return round(dq, 2)
    
    @staticmethod
    def calculate_composite_dq(domain_dqs: Dict[str, float]) -> float:
        """Calculate composite DQ from all 5 domains"""
        values = [
            domain_dqs.get('gm_dq', 0),
            domain_dqs.get('fm_dq', 0),
            domain_dqs.get('lc_dq', 0),
            domain_dqs.get('cog_dq', 0),
            domain_dqs.get('se_dq', 0)
        ]
        composite = sum(values) / len([v for v in values if v > 0]) if any(v > 0 for v in values) else 0
        return round(composite, 2)
    
    @staticmethod
    def is_delayed(dq: float, threshold: float = 85.0) -> bool:
        """Check if DQ indicates delay"""
        return dq < threshold
    
    @staticmethod
    def get_delay_category(dq: float) -> str:
        """Get delay category"""
        if dq >= 85:
            return "On Track"
        elif dq >= 70:
            return "Mild Delay"
        return "Significant Delay"
    
    @staticmethod
    def calculate_z_score(indicator: str, gender: str, age_months: int, measurement: float) -> float:
        """Calculate WHO z-score using LMS method"""
        key = f"{indicator}_{'boys' if gender.lower() == 'male' else 'girls'}"
        lms_table = CalculationService.WHO_LMS_TABLES.get(key, {})
        
        # Find closest age
        ages = sorted(lms_table.keys())
        if not ages:
            return 0.0
            
        closest_age = min(ages, key=lambda x: abs(x - age_months))
        
        lms = lms_table.get(closest_age)
        if not lms:
            return 0.0
        
        L, M, S = lms
        
        # Z-score = ((Y/M)^L - 1) / (L × S)
        if L != 0:
            z_score = (pow(measurement / M, L) - 1) / (L * S)
        else:
            z_score = math.log(measurement / M) / S
        
        return round(z_score, 2)
    
    @staticmethod
    def classify_underweight(z_score: float) -> int:
        """Classify underweight status"""
        if z_score < -3:
            return 2  # Severe
        elif z_score < -2:
            return 1  # Moderate
        return 0  # Normal
    
    @staticmethod
    def classify_stunting(z_score: float) -> int:
        """Classify stunting status"""
        if z_score < -3:
            return 2
        elif z_score < -2:
            return 1
        return 0
    
    @staticmethod
    def classify_wasting(z_score: float) -> int:
        """Classify wasting status"""
        if z_score < -3:
            return 2
        elif z_score < -2:
            return 1
        return 0
    
    @staticmethod
    def calculate_nutrition_score(underweight: int, stunting: int, wasting: int, anemia: int) -> int:
        """Calculate overall nutrition score"""
        return (underweight * 2) + (stunting * 3) + (wasting * 2) + (anemia * 1)
    
    @staticmethod
    def classify_nutrition_risk(score: int) -> str:
        """Classify nutrition risk"""
        if score == 0:
            return "Low"
        elif score <= 3:
            return "Medium"
        return "High"
    
    @staticmethod
    def calculate_mchat_risk(responses: Dict[int, bool]) -> str:
        """
        Calculate M-CHAT autism risk based on failed items
        
        M-CHAT Scoring:
        - Total Score: Number of items failed (typically answered 'No' to positive items)
        - Critical Items: 2, 5, 7, 9, 13, 14, 15, 23
        
        Risk Levels:
        - High Risk: Total >= 8 fails OR >= 3 critical fails
        - Medium Risk: Total >= 3 fails OR >= 2 critical fails
        - Low Risk: Below medium thresholds
        """
        if not responses:
            return "Low"
        
        critical_items = CalculationService.MCHAT_CRITICAL_ITEMS
        
        # Count total failures (True indicates at-risk response)
        total_fail = sum(1 for v in responses.values() if v)
        
        # Count critical item failures
        critical_fail = sum(1 for item in critical_items if responses.get(item, False))
        
        # Determine risk level
        if total_fail >= 8 or critical_fail >= 3:
            return "High"
        elif total_fail >= 3 or critical_fail >= 2:
            return "Medium"
        return "Low"
    
    @staticmethod
    def calculate_mchat_score(responses: Dict[int, bool]) -> Dict[str, Any]:
        """Calculate detailed M-CHAT score breakdown"""
        if not responses:
            return {
                "total_score": 0,
                "critical_score": 0,
                "risk_level": "Low",
                "failed_items": [],
                "failed_critical_items": []
            }
        
        critical_items = CalculationService.MCHAT_CRITICAL_ITEMS
        
        failed_items = [item for item, failed in responses.items() if failed]
        failed_critical = [item for item in failed_items if item in critical_items]
        
        total_score = len(failed_items)
        critical_score = len(failed_critical)
        risk_level = CalculationService.calculate_mchat_risk(responses)
        
        return {
            "total_score": total_score,
            "critical_score": critical_score,
            "risk_level": risk_level,
            "failed_items": failed_items,
            "failed_critical_items": failed_critical
        }
    
    @staticmethod
    def calculate_isaa_risk(responses: List[int]) -> str:
        """Calculate ISAA autism risk"""
        if not responses:
            return "Low"
        total = sum(responses)
        if total >= 106:
            return "High"
        elif total >= 70:
            return "Medium"
        return "Low"
    
    @staticmethod
    def calculate_sdq_scores(responses: Dict[str, int]) -> Dict[str, Any]:
        """
        Calculate SDQ (Strengths and Difficulties Questionnaire) scores
        
        Categories:
        - Emotional Symptoms: Items 1, 2
        - Conduct Problems: Items 3, 4 (reversed), 5
        - Hyperactivity: Items 6, 7, 8
        - Peer Problems: Items 9, 10 (reversed), 11 (reversed)
        - Prosocial Behavior: Items 12, 13, 14 (reversed scoring - higher is better)
        
        Returns scores and risk classifications for each subscale
        """
        if not responses:
            return {
                "emotional": 0,
                "conduct": 0,
                "hyperactivity": 0,
                "peer": 0,
                "prosocial": 0,
                "total_difficulties": 0,
                "risk_level": "Low"
            }
        
        # Calculate subscale scores
        # Emotional (items 1-2): Higher is worse
        emotional = responses.get('sdq_1', 0) + responses.get('sdq_2', 0)
        
        # Conduct (items 3, 4, 5): Item 4 is reversed (higher is better)
        conduct = (responses.get('sdq_3', 0) + 
                   (2 - responses.get('sdq_4', 1)) +  # Reversed
                   responses.get('sdq_5', 0))
        
        # Hyperactivity (items 6-8): Higher is worse
        hyperactivity = (responses.get('sdq_6', 0) + 
                        responses.get('sdq_7', 0) + 
                        responses.get('sdq_8', 0))
        
        # Peer (items 9, 10, 11): Items 10, 11 are reversed
        peer = (responses.get('sdq_9', 0) + 
                (2 - responses.get('sdq_10', 1)) +  # Reversed
                (2 - responses.get('sdq_11', 1)))   # Reversed
        
        # Prosocial (items 12-14): Higher is better, reversed for total difficulties
        prosocial = (responses.get('sdq_12', 0) + 
                     responses.get('sdq_13', 0) + 
                     responses.get('sdq_14', 0))
        
        # Total Difficulties Score (0-20 for the difficulty scales)
        # Excludes prosocial which is a strength scale
        total_difficulties = emotional + conduct + hyperactivity + peer
        
        # Determine overall risk level based on total difficulties
        # Thresholds for 3-4 year olds (approximate)
        if total_difficulties >= 17:
            risk_level = "High"
        elif total_difficulties >= 14:
            risk_level = "Medium-High"
        elif total_difficulties >= 11:
            risk_level = "Medium"
        else:
            risk_level = "Low"
        
        return {
            "emotional": emotional,
            "conduct": conduct,
            "hyperactivity": hyperactivity,
            "peer": peer,
            "prosocial": prosocial,
            "total_difficulties": total_difficulties,
            "risk_level": risk_level,
            "subscale_interpretation": {
                "emotional": CalculationService._interpret_sdq_subscale(emotional, "emotional"),
                "conduct": CalculationService._interpret_sdq_subscale(conduct, "conduct"),
                "hyperactivity": CalculationService._interpret_sdq_subscale(hyperactivity, "hyperactivity"),
                "peer": CalculationService._interpret_sdq_subscale(peer, "peer"),
                "prosocial": CalculationService._interpret_sdq_subscale(prosocial, "prosocial")
            }
        }
    
    @staticmethod
    def _interpret_sdq_subscale(score: int, subscale: str) -> str:
        """Interpret individual SDQ subscale score"""
        # Normal/Abnormal thresholds (simplified for young children)
        thresholds = {
            "emotional": {"normal": 3, "borderline": 4},
            "conduct": {"normal": 2, "borderline": 3},
            "hyperactivity": {"normal": 5, "borderline": 6},
            "peer": {"normal": 2, "borderline": 3},
            "prosocial": {"normal": 6, "borderline": 5}  # Reversed - higher is better
        }
        
        thresh = thresholds.get(subscale, {"normal": 3, "borderline": 4})
        
        if subscale == "prosocial":
            # For prosocial, higher scores are better
            if score >= thresh["normal"]:
                return "Normal"
            elif score >= thresh["borderline"]:
                return "Borderline"
            return "Abnormal"
        else:
            # For difficulty scales, lower scores are better
            if score <= thresh["normal"]:
                return "Normal"
            elif score <= thresh["borderline"]:
                return "Borderline"
            return "Abnormal"
    
    @staticmethod
    def calculate_environment_score(responses: Dict[str, bool]) -> Dict[str, Any]:
        """
        Calculate Environment & Caregiving assessment score
        
        Categories:
        - Parent-Child Interaction (env_1-4): Weight 2 each, max 8
        - Home Stimulation (env_5-8): Weight varies, max 7
        - Caregiver Engagement (env_9-10): Weight 2 each, max 4
        - Language Exposure (env_11-12): Weight 2 each, max 4
        - Basic Needs (env_13-15): Weight varies, max 4
        
        Max total score: 27
        """
        if not responses:
            return {
                "total": 0,
                "max": 25,
                "percentage": 0,
                "parent_child_interaction": 0,
                "home_stimulation": 0,
                "caregiver_engagement": 0,
                "language_exposure": 0,
                "basic_needs": 0,
                "caregiver_engagement_level": "Low",
                "language_exposure_level": "Low",
                "risk_level": "High"
            }
        
        weights = CalculationService.ENVIRONMENT_WEIGHTS
        
        # Calculate weighted scores for each category
        parent_child = sum(weights.get(qid, 2) for qid in ['env_1', 'env_2', 'env_3', 'env_4'] if responses.get(qid, False))
        home_stim = sum(weights.get(qid, 2) for qid in ['env_5', 'env_6', 'env_7', 'env_8'] if responses.get(qid, False))
        caregiver_eng = sum(weights.get(qid, 2) for qid in ['env_9', 'env_10'] if responses.get(qid, False))
        language_exp = sum(weights.get(qid, 2) for qid in ['env_11', 'env_12'] if responses.get(qid, False))
        basic_needs = sum(weights.get(qid, 1) for qid in ['env_13', 'env_14', 'env_15'] if responses.get(qid, False))
        
        total_score = parent_child + home_stim + caregiver_eng + language_exp + basic_needs
        max_score = sum(weights.values())  # Should be 25
        percentage = round((total_score / max_score) * 100, 2) if max_score > 0 else 0
        
        # Determine levels
        caregiver_engagement_level = "High" if caregiver_eng >= 3 else "Medium" if caregiver_eng >= 2 else "Low"
        language_exposure_level = "High" if language_exp >= 3 else "Medium" if language_exp >= 2 else "Low"
        
        # Overall risk level
        if percentage >= 80:
            risk_level = "Low"
        elif percentage >= 60:
            risk_level = "Medium"
        elif percentage >= 40:
            risk_level = "Medium-High"
        else:
            risk_level = "High"
        
        return {
            "total": total_score,
            "max": max_score,
            "percentage": percentage,
            "parent_child_interaction": parent_child,
            "home_stimulation": home_stim,
            "caregiver_engagement": caregiver_eng,
            "language_exposure": language_exp,
            "basic_needs": basic_needs,
            "caregiver_engagement_level": caregiver_engagement_level,
            "language_exposure_level": language_exposure_level,
            "risk_level": risk_level
        }
    
    @staticmethod
    def calculate_rbsk_findings(responses: Dict[str, bool]) -> Dict[str, Any]:
        """
        Process RBSK screening findings
        
        Categories:
        - Vision: rbsk_1, rbsk_2
        - Hearing: rbsk_3, rbsk_4
        - Development: rbsk_5, rbsk_6, rbsk_7
        - Dental: rbsk_8, rbsk_9
        - Nutrition: rbsk_10, rbsk_11
        - Congenital: rbsk_12
        - Neuro: rbsk_13, rbsk_14
        """
        if not responses:
            return {
                "total_findings": 0,
                "findings_by_category": {},
                "requires_referral": False,
                "categories_flagged": []
            }
        
        category_mapping = {
            'rbsk_1': 'vision', 'rbsk_2': 'vision',
            'rbsk_3': 'hearing', 'rbsk_4': 'hearing',
            'rbsk_5': 'development', 'rbsk_6': 'development', 'rbsk_7': 'development',
            'rbsk_8': 'dental', 'rbsk_9': 'dental',
            'rbsk_10': 'nutrition', 'rbsk_11': 'nutrition',
            'rbsk_12': 'congenital',
            'rbsk_13': 'neuro', 'rbsk_14': 'neuro'
        }
        
        findings = []
        findings_by_category = {}
        
        for qid, flagged in responses.items():
            if flagged:
                category = category_mapping.get(qid, 'other')
                findings.append({
                    'question_id': qid,
                    'category': category
                })
                if category not in findings_by_category:
                    findings_by_category[category] = []
                findings_by_category[category].append(qid)
        
        # Determine if referral needed (any finding in development, neuro, congenital, vision, or hearing)
        referral_categories = ['development', 'neuro', 'congenital', 'vision', 'hearing']
        requires_referral = any(cat in findings_by_category for cat in referral_categories)
        
        return {
            "total_findings": len(findings),
            "findings_by_category": findings_by_category,
            "findings_list": findings,
            "requires_referral": requires_referral,
            "categories_flagged": list(findings_by_category.keys())
        }
    
    @staticmethod
    def classify_overall_risk(
        num_delays: int,
        autism_risk: str,
        behavior_risk: str,
        nutrition_risk: str
    ) -> str:
        """Classify overall risk category"""
        if num_delays >= 3:
            return "HIGH"
        if autism_risk == "High" or behavior_risk == "High":
            return "HIGH"
        
        if num_delays == 2:
            return "MEDIUM-HIGH"
        if autism_risk == "Medium" and num_delays >= 1:
            return "MEDIUM-HIGH"
        
        if num_delays == 1:
            return "MEDIUM"
        if behavior_risk == "Medium" or nutrition_risk == "High":
            return "MEDIUM"
        
        return "LOW"
    
    @staticmethod
    def needs_referral(risk_category: str) -> bool:
        """Check if referral is needed"""
        return risk_category in ["HIGH", "MEDIUM-HIGH"]
    
    @staticmethod
    def get_intervention_priority(risk_category: str) -> str:
        """Get intervention priority"""
        if risk_category == "HIGH":
            return "URGENT"
        elif risk_category == "MEDIUM-HIGH":
            return "HIGH"
        elif risk_category == "MEDIUM":
            return "MODERATE"
        return "LOW"
