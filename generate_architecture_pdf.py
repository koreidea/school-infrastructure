#!/usr/bin/env python3
"""
Vidya Nirmaan — Architecture & Design Document Generator
For IndiaAI Innovation Challenge (AIkosh) Problem Statement 5
Generates a professional ~14-page PDF with architecture diagrams, flowcharts, and ER diagrams.
"""

import os
import tempfile
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
from matplotlib.patches import FancyBboxPatch, FancyArrowPatch
import numpy as np

from reportlab.lib import colors as rl_colors
from reportlab.lib.pagesizes import A4
from reportlab.lib.styles import getSampleStyleSheet, ParagraphStyle
from reportlab.lib.units import inch, mm, cm
from reportlab.lib.enums import TA_CENTER, TA_LEFT, TA_RIGHT, TA_JUSTIFY
from reportlab.platypus import (
    SimpleDocTemplate, Paragraph, Spacer, Image, Table, TableStyle,
    PageBreak, KeepTogether, HRFlowable
)
from reportlab.lib.utils import ImageReader
from reportlab.pdfgen import canvas

# ─── Color Palette (from AppColors) ───
PRIMARY = '#1565C0'
PRIMARY_DARK = '#0D47A1'
ACCENT = '#00897B'
SUPABASE_GREEN = '#388E3C'
FASTAPI_ORANGE = '#F57C00'
ML_PURPLE = '#7B1FA2'
HIVE_TEAL = '#00897B'
CRITICAL_RED = '#D32F2F'
HIGH_ORANGE = '#F57C00'
MEDIUM_AMBER = '#F9A825'
LOW_GREEN = '#4CAF50'
BG_LIGHT = '#F5F5F5'
TEXT_PRIMARY = '#212121'
TEXT_SECONDARY = '#757575'
WHITE = '#FFFFFF'
LIGHT_BLUE = '#E3F2FD'
LIGHT_GREEN = '#E8F5E9'
LIGHT_ORANGE = '#FFF3E0'
LIGHT_PURPLE = '#F3E5F5'
LIGHT_TEAL = '#E0F2F1'

W, H = A4  # 595.27, 841.89

def hex_to_rgb(h):
    h = h.lstrip('#')
    return tuple(int(h[i:i+2], 16)/255.0 for i in (0, 2, 4))

def hex_to_rl(h):
    r, g, b = hex_to_rgb(h)
    return rl_colors.Color(r, g, b)

TEMP_DIR = tempfile.mkdtemp()

# ─── Matplotlib Diagram Generators ───

def draw_rounded_box(ax, x, y, w, h, label, sublabels=None, color='#1565C0', text_color='white', fontsize=11, header_ratio=0.35):
    """Draw a rounded box with a colored header and white body."""
    header_h = h * header_ratio
    body_h = h - header_h
    # Body
    body = FancyBboxPatch((x, y), w, body_h, boxstyle="round,pad=0.02",
                           facecolor='white', edgecolor=color, linewidth=1.5)
    ax.add_patch(body)
    # Header
    header = FancyBboxPatch((x, y + body_h), w, header_h, boxstyle="round,pad=0.02",
                             facecolor=color, edgecolor=color, linewidth=1.5)
    ax.add_patch(header)
    # Header text
    ax.text(x + w/2, y + body_h + header_h/2, label, ha='center', va='center',
            fontsize=fontsize, fontweight='bold', color=text_color, zorder=5)
    # Sub-labels in body
    if sublabels:
        line_h = body_h / (len(sublabels) + 1)
        for i, sl in enumerate(sublabels):
            ax.text(x + w/2, y + body_h - line_h * (i + 1), sl, ha='center', va='center',
                    fontsize=8, color='#333333', zorder=5)

def draw_arrow(ax, start, end, color='#555555', style='->', lw=1.5):
    ax.annotate('', xy=end, xytext=start,
                arrowprops=dict(arrowstyle=style, lw=lw, color=color))

def draw_label_arrow(ax, start, end, label, color='#555555', fontsize=7):
    draw_arrow(ax, start, end, color)
    mid_x = (start[0] + end[0]) / 2
    mid_y = (start[1] + end[1]) / 2
    ax.text(mid_x + 0.1, mid_y, label, fontsize=fontsize, color=color, style='italic')


def generate_system_architecture():
    """Generate the 3-tier system architecture diagram."""
    fig, ax = plt.subplots(figsize=(12, 9))
    ax.set_xlim(0, 12)
    ax.set_ylim(0, 9)
    ax.axis('off')
    ax.set_facecolor('white')
    fig.patch.set_facecolor('white')

    # Title
    ax.text(6, 8.7, 'System Architecture — Vidya Nirmaan', ha='center', va='center',
            fontsize=16, fontweight='bold', color=hex_to_rgb(PRIMARY_DARK))

    # Layer 1: Flutter Frontend (top)
    draw_rounded_box(ax, 1, 6.2, 10, 2.0, 'Flutter Mobile Application',
                     ['Riverpod 3.x State Management  |  fl_chart  |  flutter_map',
                      '6 Screens: Auth, Dashboard, Schools, Inspection, Validation, Analytics',
                      '5 Roles: State Official, District Officer, Block Officer, Inspector, HM',
                      'English + Telugu (BiLingual)  |  Material Design 3'],
                     color=PRIMARY)

    # Layer 2a: Supabase (left)
    draw_rounded_box(ax, 0.5, 3.0, 5, 2.4, 'Supabase Backend',
                     ['PostgreSQL + Row Level Security',
                      '9 Tables (si_* prefix) + 2 Views',
                      '319 Schools | 57 Districts | 707 Mandals',
                      '799 Demand Plans | 4,638 Enrolment Records',
                      'Real-time Subscriptions + Auth'],
                     color=SUPABASE_GREEN)

    # Layer 2b: FastAPI ML (right)
    draw_rounded_box(ax, 6.5, 3.0, 5, 2.4, 'FastAPI ML Backend',
                     ['Railway Cloud Deployment',
                      'Linear Regression + Cohort Progression',
                      'Isolation Forest Anomaly Detection',
                      'scikit-learn 1.4+ | NumPy | Pandas',
                      '3 API Routers: Forecast, Validate, Analytics'],
                     color=FASTAPI_ORANGE)

    # Layer 3: Hive Offline (bottom)
    draw_rounded_box(ax, 2.5, 0.3, 7, 1.8, 'Hive Local Storage (Offline-First)',
                     ['5 Boxes: schools_cache, demands_cache, assessments_queue, demands_queue, cache_meta',
                      'Auto-sync on Reconnect  |  Graceful Fallback  |  Queue & Retry'],
                     color=HIVE_TEAL)

    # Arrows
    # Flutter -> Supabase
    draw_label_arrow(ax, (4, 6.2), (3, 5.4), 'HTTPS / REST', PRIMARY)
    # Flutter -> FastAPI
    draw_label_arrow(ax, (8, 6.2), (9, 5.4), 'HTTPS / REST', FASTAPI_ORANGE)
    # Flutter -> Hive
    draw_label_arrow(ax, (6, 6.2), (6, 2.1), 'Local I/O', HIVE_TEAL)
    # Supabase <-> FastAPI
    draw_label_arrow(ax, (5.5, 4.2), (6.5, 4.2), 'SQL Queries', TEXT_SECONDARY)

    # Legend boxes
    legend_items = [
        ('Flutter Frontend', PRIMARY), ('Supabase (PostgreSQL)', SUPABASE_GREEN),
        ('FastAPI ML Backend', FASTAPI_ORANGE), ('Hive Offline Cache', HIVE_TEAL)
    ]
    for i, (label, color) in enumerate(legend_items):
        ax.add_patch(FancyBboxPatch((0.3 + i*3, -0.1), 0.3, 0.2,
                                     boxstyle="round,pad=0.02", facecolor=color, edgecolor=color))
        ax.text(0.8 + i*3, 0.0, label, fontsize=7, va='center', color='#333')

    path = os.path.join(TEMP_DIR, 'system_architecture.png')
    fig.savefig(path, dpi=200, bbox_inches='tight', facecolor='white')
    plt.close(fig)
    return path


def generate_er_diagram():
    """Generate the database ER diagram."""
    fig, ax = plt.subplots(figsize=(13, 9))
    ax.set_xlim(0, 13)
    ax.set_ylim(0, 9)
    ax.axis('off')
    fig.patch.set_facecolor('white')

    ax.text(6.5, 8.7, 'Database Schema (Entity-Relationship Diagram)', ha='center',
            fontsize=15, fontweight='bold', color=hex_to_rgb(PRIMARY_DARK))

    def entity_box(x, y, w, h, name, fields, pk=None, fk=None, color=PRIMARY):
        rgb = hex_to_rgb(color)
        # Border
        rect = FancyBboxPatch((x, y), w, h, boxstyle="round,pad=0.02",
                               facecolor='white', edgecolor=rgb, linewidth=1.5)
        ax.add_patch(rect)
        # Header bar
        hdr = FancyBboxPatch((x, y+h-0.4), w, 0.4, boxstyle="round,pad=0.02",
                              facecolor=rgb, edgecolor=rgb, linewidth=1)
        ax.add_patch(hdr)
        ax.text(x+w/2, y+h-0.2, name, ha='center', va='center',
                fontsize=8.5, fontweight='bold', color='white')
        # Fields
        for i, f in enumerate(fields):
            prefix = ''
            fc = '#333'
            if pk and f == pk:
                prefix = 'PK '
                fc = CRITICAL_RED
            elif fk and f in fk:
                prefix = 'FK '
                fc = PRIMARY
            ax.text(x+0.08, y+h-0.6-i*0.22, f'{prefix}{f}', fontsize=6.5, color=fc, va='center', family='monospace')

    # Districts
    entity_box(0.2, 6.5, 2.4, 1.8, 'si_districts (57)',
               ['id', 'state_id', 'district_name', 'district_code', 'created_at'],
               pk='id', fk=['state_id'], color=PRIMARY)

    # Mandals
    entity_box(0.2, 3.8, 2.4, 2.0, 'si_mandals (707)',
               ['id', 'district_id', 'mandal_name', 'mandal_code', 'latitude', 'longitude'],
               pk='id', fk=['district_id'], color=PRIMARY)

    # Schools
    entity_box(3.5, 4.5, 3.0, 2.8, 'si_schools (319)',
               ['id', 'udise_code (BIGINT)', 'school_name', 'district_id', 'mandal_id',
                'school_category', 'school_management', 'latitude', 'longitude',
                'total_enrolment', 'created_at'],
               pk='id', fk=['district_id', 'mandal_id'], color=SUPABASE_GREEN)

    # Demand Plans
    entity_box(7.3, 6.0, 3.0, 2.6, 'si_demand_plans (799)',
               ['id', 'school_id', 'plan_year', 'infra_type', 'physical_count',
                'financial_amount', 'validation_status', 'validation_score',
                'officer_status', 'officer_name', 'assessment_id'],
               pk='id', fk=['school_id', 'assessment_id'], color=FASTAPI_ORANGE)

    # Enrolment History
    entity_box(7.3, 3.2, 2.8, 2.2, 'si_enrolment_history (4638)',
               ['id', 'school_id', 'academic_year', 'grade', 'boys', 'girls',
                'total', 'created_at'],
               pk='id', fk=['school_id'], color=ML_PURPLE)

    # Infra Assessments
    entity_box(0.2, 0.5, 3.2, 2.6, 'si_infra_assessments',
               ['id', 'school_id', 'inspector_name', 'assessment_date',
                'existing_classrooms', 'cwsn_toilet_available',
                'drinking_water_available', 'electrification_status',
                'ramp_available', '... (50+ fields)'],
               pk='id', fk=['school_id'], color=HIVE_TEAL)

    # Priority Scores
    entity_box(4.0, 0.5, 3.0, 2.6, 'si_school_priority_scores',
               ['id', 'school_id', 'composite_score (0-100)', 'priority_level',
                'enrolment_score', 'infra_gap_score', 'cwsn_need_score',
                'accessibility_score', 'score_breakdown (JSONB)'],
               pk='id', fk=['school_id'], color=CRITICAL_RED)

    # Enrolment Forecasts
    entity_box(7.5, 0.5, 2.8, 2.2, 'si_enrolment_forecasts',
               ['id', 'school_id', 'forecast_year', 'grade',
                'predicted_total', 'confidence', 'model_used'],
               pk='id', fk=['school_id'], color=ML_PURPLE)

    # Users
    entity_box(10.6, 4.5, 2.2, 2.8, 'si_users',
               ['id', 'auth_uid', 'name', 'email', 'role',
                'district_id', 'mandal_id', 'school_id',
                'phone', 'is_active', 'created_at'],
               pk='id', fk=['district_id', 'mandal_id', 'school_id'], color=TEXT_SECONDARY)

    # Relationship arrows
    # Districts -> Mandals (1:N)
    draw_arrow(ax, (1.4, 6.5), (1.4, 5.8))
    ax.text(1.55, 6.1, '1:N', fontsize=7, color=PRIMARY)

    # Mandals -> Schools
    draw_arrow(ax, (2.6, 4.8), (3.5, 5.5))
    ax.text(2.7, 5.25, '1:N', fontsize=7, color=PRIMARY)

    # Schools -> Demands
    draw_arrow(ax, (6.5, 6.5), (7.3, 7.0))
    ax.text(6.6, 6.9, '1:N', fontsize=7, color=FASTAPI_ORANGE)

    # Schools -> Enrolment
    draw_arrow(ax, (6.5, 5.2), (7.3, 4.5))
    ax.text(6.6, 4.9, '1:N', fontsize=7, color=ML_PURPLE)

    # Schools -> Assessments
    draw_arrow(ax, (4.0, 4.5), (3.0, 3.1))
    ax.text(3.1, 3.9, '1:N', fontsize=7, color=HIVE_TEAL)

    # Schools -> Priority Scores
    draw_arrow(ax, (5.0, 4.5), (5.5, 3.1))
    ax.text(4.9, 3.8, '1:1', fontsize=7, color=CRITICAL_RED)

    # Schools -> Forecasts
    draw_arrow(ax, (6.2, 4.5), (8.5, 2.7))
    ax.text(7.2, 3.7, '1:N', fontsize=7, color=ML_PURPLE)

    path = os.path.join(TEMP_DIR, 'er_diagram.png')
    fig.savefig(path, dpi=200, bbox_inches='tight', facecolor='white')
    plt.close(fig)
    return path


def generate_priority_scoring():
    """Generate the AI Priority Scoring flowchart."""
    fig, ax = plt.subplots(figsize=(12, 8))
    ax.set_xlim(0, 12)
    ax.set_ylim(0, 8)
    ax.axis('off')
    fig.patch.set_facecolor('white')

    ax.text(6, 7.7, 'AI Priority Scoring Pipeline', ha='center',
            fontsize=15, fontweight='bold', color=hex_to_rgb(PRIMARY_DARK))

    # Input Data Sources (top row)
    inputs = [
        ('School\nMaster Data', 1.2), ('Enrolment\nRecords', 4.0),
        ('Demand\nPlans', 7.0), ('Infrastructure\nAssessments', 10.0)
    ]
    for label, x in inputs:
        box = FancyBboxPatch((x-0.7, 6.8), 1.8, 0.7, boxstyle="round,pad=0.05",
                              facecolor=hex_to_rgb(LIGHT_BLUE), edgecolor=hex_to_rgb(PRIMARY), linewidth=1)
        ax.add_patch(box)
        ax.text(x+0.2, 7.15, label, ha='center', va='center', fontsize=8, fontweight='bold', color=hex_to_rgb(PRIMARY))

    # Arrows from inputs to processor
    for _, x in inputs:
        draw_arrow(ax, (x+0.2, 6.8), (6, 6.35), color=PRIMARY)

    # Central processor
    proc = FancyBboxPatch((3.5, 5.8), 5, 0.55, boxstyle="round,pad=0.05",
                           facecolor=hex_to_rgb(ML_PURPLE), edgecolor=hex_to_rgb(ML_PURPLE), linewidth=1.5)
    ax.add_patch(proc)
    ax.text(6, 6.08, 'Weighted Composite Score Calculator (0-100)', ha='center', va='center',
            fontsize=10, fontweight='bold', color='white')

    # 4 Factor boxes
    factors = [
        ('Enrolment\nPressure', '30%', 'Growth Rate (0-50)\nStudent:Classroom Ratio (0-50)\nNorms: PS=30:1, Sec=35:1', PRIMARY),
        ('Infrastructure\nGap', '30%', 'Demand Diversity (0-60)\nPhysical Volume (0-40)\nMissing Facilities Boost', FASTAPI_ORANGE),
        ('CWSN\nNeeds', '20%', 'CWSN Room (+35)\nCWSN Toilet (+35)\nRamp Demand (+30)', ML_PURPLE),
        ('Accessibility', '20%', 'Drinking Water (+35)\nElectrification (+35)\nRamp Access (+30)', HIVE_TEAL),
    ]

    for i, (name, weight, details, color) in enumerate(factors):
        x = 0.3 + i * 3
        # Factor header
        hdr = FancyBboxPatch((x, 4.4), 2.7, 0.6, boxstyle="round,pad=0.03",
                              facecolor=hex_to_rgb(color), edgecolor=hex_to_rgb(color), linewidth=1)
        ax.add_patch(hdr)
        ax.text(x+1.35, 4.7, f'{name} ({weight})', ha='center', va='center',
                fontsize=9, fontweight='bold', color='white')
        # Details body
        body = FancyBboxPatch((x, 3.2), 2.7, 1.2, boxstyle="round,pad=0.03",
                               facecolor='white', edgecolor=hex_to_rgb(color), linewidth=1)
        ax.add_patch(body)
        lines = details.split('\n')
        for j, line in enumerate(lines):
            ax.text(x+0.15, 4.15 - j*0.3, line, fontsize=7, color='#333', va='center')

        draw_arrow(ax, (x+1.35, 5.0), (x+1.35, 5.8), color=color, style='<-')

    # Formula box
    formula = FancyBboxPatch((2, 2.2), 8, 0.7, boxstyle="round,pad=0.05",
                              facecolor=hex_to_rgb(LIGHT_PURPLE), edgecolor=hex_to_rgb(ML_PURPLE), linewidth=1)
    ax.add_patch(formula)
    ax.text(6, 2.55, 'Score = (Enrolment x 0.30) + (InfraGap x 0.30) + (CWSN x 0.20) + (Accessibility x 0.20)',
            ha='center', va='center', fontsize=9, fontweight='bold', color=hex_to_rgb(ML_PURPLE))

    # Output boxes from factors
    for i in range(4):
        x = 0.3 + i * 3
        draw_arrow(ax, (x+1.35, 3.2), (x+1.35, 2.9), color='#555')

    # Classification output
    levels = [
        ('CRITICAL', '>80', CRITICAL_RED), ('HIGH', '60-80', HIGH_ORANGE),
        ('MEDIUM', '40-60', MEDIUM_AMBER), ('LOW', '<=40', LOW_GREEN)
    ]
    for i, (label, rng, color) in enumerate(levels):
        x = 1.5 + i * 2.5
        box = FancyBboxPatch((x, 0.8), 2.0, 0.9, boxstyle="round,pad=0.05",
                              facecolor=hex_to_rgb(color), edgecolor=hex_to_rgb(color), linewidth=1.5)
        ax.add_patch(box)
        ax.text(x+1.0, 1.35, label, ha='center', va='center', fontsize=10, fontweight='bold', color='white')
        ax.text(x+1.0, 1.05, f'Score {rng}', ha='center', va='center', fontsize=8, color='white')

    draw_arrow(ax, (6, 2.2), (6, 1.7), color=ML_PURPLE)
    ax.text(6.2, 1.95, 'classify', fontsize=7, color=ML_PURPLE, style='italic')

    # Store label
    ax.text(6, 0.4, 'Stored in: si_school_priority_scores table  |  Displayed on Dashboard Overview (Pie Chart)',
            ha='center', va='center', fontsize=8, color=TEXT_SECONDARY, style='italic')

    path = os.path.join(TEMP_DIR, 'priority_scoring.png')
    fig.savefig(path, dpi=200, bbox_inches='tight', facecolor='white')
    plt.close(fig)
    return path


def generate_validation_pipeline():
    """Generate the Demand Validation pipeline diagram."""
    fig, ax = plt.subplots(figsize=(12, 9))
    ax.set_xlim(0, 12)
    ax.set_ylim(0, 9)
    ax.axis('off')
    fig.patch.set_facecolor('white')

    ax.text(6, 8.7, 'AI Demand Validation Pipeline', ha='center',
            fontsize=15, fontweight='bold', color=hex_to_rgb(PRIMARY_DARK))

    # Input
    inp = FancyBboxPatch((4, 7.8), 4, 0.6, boxstyle="round,pad=0.05",
                          facecolor=hex_to_rgb(LIGHT_BLUE), edgecolor=hex_to_rgb(PRIMARY), linewidth=1.5)
    ax.add_patch(inp)
    ax.text(6, 8.1, 'Demand Plan Input (school_id, infra_type, qty, amount)', ha='center', va='center',
            fontsize=9, fontweight='bold', color=hex_to_rgb(PRIMARY))

    draw_arrow(ax, (6, 7.8), (6, 7.4), color=PRIMARY)

    # Rule Engine Box
    re_box = FancyBboxPatch((0.5, 3.8), 5.5, 3.5, boxstyle="round,pad=0.05",
                             facecolor='white', edgecolor=hex_to_rgb(FASTAPI_ORANGE), linewidth=2)
    ax.add_patch(re_box)
    re_hdr = FancyBboxPatch((0.5, 6.8), 5.5, 0.5, boxstyle="round,pad=0.05",
                             facecolor=hex_to_rgb(FASTAPI_ORANGE), edgecolor=hex_to_rgb(FASTAPI_ORANGE))
    ax.add_patch(re_hdr)
    ax.text(3.25, 7.05, 'Rule-Based Engine (Client-Side)', ha='center', va='center',
            fontsize=10, fontweight='bold', color='white')

    rules = [
        ('1. Unit Cost Check', 'Deviation > 20% from Samagra norms  (-25 pts)'),
        ('2. Duplicate Detection', 'Same infra_type + plan_year  (-30 pts)'),
        ('3. Enrolment Correlation', 'Students < 20 but qty > 2  (-20 pts)'),
        ('4. Peer Comparison', 'Qty > 3x mandal average  (-15 pts)'),
        ('5. Zero-Value Check', 'Count or amount = 0  (-40 pts)'),
        ('6. Existing Infra', 'Already available per inspection  (-20 pts)'),
        ('7. Over-Reporting', '>= 4 types + > 50 Lakhs total  (-15 pts)'),
    ]
    for i, (name, desc) in enumerate(rules):
        y = 6.5 - i * 0.37
        ax.text(0.8, y, name, fontsize=8, fontweight='bold', color='#333', va='center')
        ax.text(3.0, y, desc, fontsize=7, color='#666', va='center')

    ax.text(3.25, 4.05, 'Score starts at 100, deductions per violation', ha='center',
            fontsize=7.5, color=FASTAPI_ORANGE, style='italic', fontweight='bold')

    # ML Engine Box
    ml_box = FancyBboxPatch((6.5, 4.5), 5.2, 2.8, boxstyle="round,pad=0.05",
                             facecolor='white', edgecolor=hex_to_rgb(ML_PURPLE), linewidth=2)
    ax.add_patch(ml_box)
    ml_hdr = FancyBboxPatch((6.5, 6.8), 5.2, 0.5, boxstyle="round,pad=0.05",
                             facecolor=hex_to_rgb(ML_PURPLE), edgecolor=hex_to_rgb(ML_PURPLE))
    ax.add_patch(ml_hdr)
    ax.text(9.1, 7.05, 'ML Anomaly Detection (Backend)', ha='center', va='center',
            fontsize=10, fontweight='bold', color='white')

    ml_details = [
        'Isolation Forest (scikit-learn)',
        'contamination = 0.15 | n_estimators = 100',
        '',
        '5-Dimensional Feature Vector:',
        '  [physical_count, financial_amount,',
        '   unit_cost, cost_per_student, enrolment]',
        '',
        'Anomaly detected -> Downgrade status',
        'APPROVED -> FLAGGED (confidence -0.20)',
    ]
    for i, line in enumerate(ml_details):
        ax.text(6.8, 6.5 - i * 0.25, line, fontsize=7.5, color='#333', va='center',
                fontweight='bold' if 'Feature' in line or 'Isolation' in line else 'normal')

    # Arrow from input to both
    draw_arrow(ax, (4.5, 7.8), (3.25, 7.35), color=FASTAPI_ORANGE)
    draw_arrow(ax, (7.5, 7.8), (9.1, 7.35), color=ML_PURPLE)

    # Merge arrow
    draw_arrow(ax, (3.25, 3.8), (6, 3.2), color=FASTAPI_ORANGE)
    draw_arrow(ax, (9.1, 4.5), (6, 3.2), color=ML_PURPLE)

    # Score determination
    score_box = FancyBboxPatch((3.5, 2.4), 5, 0.7, boxstyle="round,pad=0.05",
                                facecolor=hex_to_rgb(BG_LIGHT), edgecolor='#555', linewidth=1.5)
    ax.add_patch(score_box)
    ax.text(6, 2.75, 'Combined Score (0-100) = Rule Score + ML Adjustment',
            ha='center', va='center', fontsize=9, fontweight='bold', color='#333')

    draw_arrow(ax, (6, 2.4), (6, 1.9), color='#555')

    # Output statuses
    statuses = [
        ('APPROVED', '>= 80', LOW_GREEN), ('FLAGGED', '50-79', HIGH_ORANGE), ('REJECTED', '< 50', CRITICAL_RED)
    ]
    for i, (label, rng, color) in enumerate(statuses):
        x = 1.5 + i * 3.5
        box = FancyBboxPatch((x, 0.8), 2.8, 0.9, boxstyle="round,pad=0.05",
                              facecolor=hex_to_rgb(color), edgecolor=hex_to_rgb(color), linewidth=1.5)
        ax.add_patch(box)
        ax.text(x+1.4, 1.35, label, ha='center', va='center', fontsize=11, fontweight='bold', color='white')
        ax.text(x+1.4, 1.05, f'Score {rng}', ha='center', va='center', fontsize=8, color='white')

    ax.text(6, 0.4, 'Stored: si_demand_plans.validation_status, validation_score, validation_flags[]',
            ha='center', fontsize=8, color=TEXT_SECONDARY, style='italic')

    path = os.path.join(TEMP_DIR, 'validation_pipeline.png')
    fig.savefig(path, dpi=200, bbox_inches='tight', facecolor='white')
    plt.close(fig)
    return path


def generate_forecasting():
    """Generate the Enrolment Forecasting pipeline diagram."""
    fig, ax = plt.subplots(figsize=(12, 8))
    ax.set_xlim(0, 12)
    ax.set_ylim(0, 8)
    ax.axis('off')
    fig.patch.set_facecolor('white')

    ax.text(6, 7.7, 'Enrolment Forecasting Pipeline (Dual Model)', ha='center',
            fontsize=15, fontweight='bold', color=hex_to_rgb(PRIMARY_DARK))

    # Input
    inp = FancyBboxPatch((3.5, 6.8), 5, 0.6, boxstyle="round,pad=0.05",
                          facecolor=hex_to_rgb(LIGHT_BLUE), edgecolor=hex_to_rgb(PRIMARY), linewidth=1.5)
    ax.add_patch(inp)
    ax.text(6, 7.1, 'Historical Enrolment Data (4,638 records, 5+ years)', ha='center',
            fontsize=9, fontweight='bold', color=hex_to_rgb(PRIMARY))

    draw_arrow(ax, (4.5, 6.8), (2.5, 6.3), color=ML_PURPLE)
    draw_arrow(ax, (7.5, 6.8), (9.5, 6.3), color=FASTAPI_ORANGE)

    # Model 1: Linear Regression
    m1 = FancyBboxPatch((0.5, 4.3), 4.5, 2.0, boxstyle="round,pad=0.05",
                          facecolor='white', edgecolor=hex_to_rgb(ML_PURPLE), linewidth=2)
    ax.add_patch(m1)
    m1h = FancyBboxPatch((0.5, 5.8), 4.5, 0.5, boxstyle="round,pad=0.05",
                           facecolor=hex_to_rgb(ML_PURPLE), edgecolor=hex_to_rgb(ML_PURPLE))
    ax.add_patch(m1h)
    ax.text(2.75, 6.05, 'Model 1: Linear Regression', ha='center', va='center',
            fontsize=9, fontweight='bold', color='white')
    m1_details = [
        'X = year_index [0,1,2...], y = total_enrolment',
        'Separate models: total, boys, girls',
        'R-squared score as model_fit (0.5-0.98)',
        'Trend extrapolation for 3 years',
    ]
    for i, d in enumerate(m1_details):
        ax.text(0.8, 5.5 - i*0.28, d, fontsize=7.5, color='#333', va='center')

    # Model 2: Cohort Progression
    m2 = FancyBboxPatch((6, 4.3), 5.5, 2.0, boxstyle="round,pad=0.05",
                          facecolor='white', edgecolor=hex_to_rgb(FASTAPI_ORANGE), linewidth=2)
    ax.add_patch(m2)
    m2h = FancyBboxPatch((6, 5.8), 5.5, 0.5, boxstyle="round,pad=0.05",
                           facecolor=hex_to_rgb(FASTAPI_ORANGE), edgecolor=hex_to_rgb(FASTAPI_ORANGE))
    ax.add_patch(m2h)
    ax.text(8.75, 6.05, 'Model 2: Cohort Progression', ha='center', va='center',
            fontsize=9, fontweight='bold', color='white')
    m2_details = [
        'Track student flow: Grade N -> Grade N+1',
        'Progression rate = next_grade / prev_grade',
        'Average across all year-pairs',
        'Default rate: 95% if insufficient data',
    ]
    for i, d in enumerate(m2_details):
        ax.text(6.3, 5.5 - i*0.28, d, fontsize=7.5, color='#333', va='center')

    # Confidence Engine
    draw_arrow(ax, (2.75, 4.3), (6, 3.6), color=ML_PURPLE)
    draw_arrow(ax, (8.75, 4.3), (6, 3.6), color=FASTAPI_ORANGE)

    conf = FancyBboxPatch((2.5, 2.2), 7, 1.3, boxstyle="round,pad=0.05",
                           facecolor=hex_to_rgb(LIGHT_PURPLE), edgecolor=hex_to_rgb(ML_PURPLE), linewidth=1.5)
    ax.add_patch(conf)
    ax.text(6, 3.25, 'Confidence = model_fit x data_quality x horizon_decay x volatility_factor',
            ha='center', fontsize=9, fontweight='bold', color=hex_to_rgb(ML_PURPLE))
    conf_items = [
        'data_quality: 2yr=0.75, 3yr=0.82, 4yr=0.88, 5yr+=0.93',
        'horizon_decay: Y1=1.00, Y2=0.92, Y3=0.82    |    volatility: >25% swing = 0.85 penalty',
    ]
    for i, c in enumerate(conf_items):
        ax.text(6, 2.85 - i*0.28, c, ha='center', fontsize=7.5, color='#555')

    # Output
    draw_arrow(ax, (6, 2.2), (6, 1.7), color=ML_PURPLE)

    out = FancyBboxPatch((2, 0.7), 8, 0.85, boxstyle="round,pad=0.05",
                          facecolor=hex_to_rgb(LOW_GREEN), edgecolor=hex_to_rgb(LOW_GREEN), linewidth=1.5)
    ax.add_patch(out)
    ax.text(6, 1.25, '3-Year Forecast with Confidence Intervals', ha='center',
            fontsize=10, fontweight='bold', color='white')
    ax.text(6, 0.95, 'Year 1: ~93% conf  |  Year 2: ~85% conf  |  Year 3: ~76% conf',
            ha='center', fontsize=8, color='white')

    ax.text(6, 0.35, 'Backend-first strategy: tries FastAPI, falls back to client-side linear extrapolation if offline',
            ha='center', fontsize=7.5, color=TEXT_SECONDARY, style='italic')

    path = os.path.join(TEMP_DIR, 'forecasting.png')
    fig.savefig(path, dpi=200, bbox_inches='tight', facecolor='white')
    plt.close(fig)
    return path


def generate_three_stage_pipeline():
    """Generate the 3-Stage Approval Pipeline diagram."""
    fig, ax = plt.subplots(figsize=(12, 7))
    ax.set_xlim(0, 12)
    ax.set_ylim(0, 7)
    ax.axis('off')
    fig.patch.set_facecolor('white')

    ax.text(6, 6.7, '3-Stage Demand Approval Pipeline', ha='center',
            fontsize=15, fontweight='bold', color=hex_to_rgb(PRIMARY_DARK))

    # Stage 0: HM Raises Demand
    s0 = FancyBboxPatch((0.3, 4.5), 2.2, 1.5, boxstyle="round,pad=0.05",
                          facecolor=hex_to_rgb(PRIMARY), edgecolor=hex_to_rgb(PRIMARY), linewidth=1.5)
    ax.add_patch(s0)
    ax.text(1.4, 5.5, 'School HM', ha='center', fontsize=10, fontweight='bold', color='white')
    ax.text(1.4, 5.15, 'Raises Demand', ha='center', fontsize=8, color='white')
    ax.text(1.4, 4.85, 'infra_type, qty,', ha='center', fontsize=7, color=hex_to_rgb(LIGHT_BLUE))
    ax.text(1.4, 4.65, 'amount, year', ha='center', fontsize=7, color=hex_to_rgb(LIGHT_BLUE))

    # Stage 1: AI Validation
    s1 = FancyBboxPatch((3.2, 4.5), 2.2, 1.5, boxstyle="round,pad=0.05",
                          facecolor=hex_to_rgb(ML_PURPLE), edgecolor=hex_to_rgb(ML_PURPLE), linewidth=1.5)
    ax.add_patch(s1)
    ax.text(4.3, 5.5, 'Stage 1: AI', ha='center', fontsize=10, fontweight='bold', color='white')
    ax.text(4.3, 5.15, '7 Rules + ML', ha='center', fontsize=8, color='white')
    ax.text(4.3, 4.85, 'Isolation Forest', ha='center', fontsize=7, color=hex_to_rgb(LIGHT_PURPLE))
    ax.text(4.3, 4.65, 'Score 0-100', ha='center', fontsize=7, color=hex_to_rgb(LIGHT_PURPLE))

    # Stage 2: Field Assessment
    s2 = FancyBboxPatch((6.1, 4.5), 2.4, 1.5, boxstyle="round,pad=0.05",
                          facecolor=hex_to_rgb(HIVE_TEAL), edgecolor=hex_to_rgb(HIVE_TEAL), linewidth=1.5)
    ax.add_patch(s2)
    ax.text(7.3, 5.5, 'Stage 2: Field', ha='center', fontsize=10, fontweight='bold', color='white')
    ax.text(7.3, 5.15, 'Assessment', ha='center', fontsize=8, color='white')
    ax.text(7.3, 4.85, '50+ data points', ha='center', fontsize=7, color=hex_to_rgb(LIGHT_TEAL))
    ax.text(7.3, 4.65, 'GPS verified', ha='center', fontsize=7, color=hex_to_rgb(LIGHT_TEAL))

    # Stage 3: Officer Decision
    s3 = FancyBboxPatch((9.2, 4.5), 2.4, 1.5, boxstyle="round,pad=0.05",
                          facecolor=hex_to_rgb(FASTAPI_ORANGE), edgecolor=hex_to_rgb(FASTAPI_ORANGE), linewidth=1.5)
    ax.add_patch(s3)
    ax.text(10.4, 5.5, 'Stage 3: Officer', ha='center', fontsize=10, fontweight='bold', color='white')
    ax.text(10.4, 5.15, 'Decision', ha='center', fontsize=8, color='white')
    ax.text(10.4, 4.85, 'APPROVE / FLAG', ha='center', fontsize=7, color=hex_to_rgb(LIGHT_ORANGE))
    ax.text(10.4, 4.65, '/ REJECT', ha='center', fontsize=7, color=hex_to_rgb(LIGHT_ORANGE))

    # Arrows between stages
    draw_arrow(ax, (2.5, 5.25), (3.2, 5.25), color='#333', lw=2)
    draw_arrow(ax, (5.4, 5.25), (6.1, 5.25), color='#333', lw=2)
    draw_arrow(ax, (8.5, 5.25), (9.2, 5.25), color='#333', lw=2)

    # Hard gate indicator
    gate = FancyBboxPatch((7.8, 3.5), 2.8, 0.7, boxstyle="round,pad=0.05",
                           facecolor=hex_to_rgb(CRITICAL_RED), edgecolor=hex_to_rgb(CRITICAL_RED), linewidth=1)
    ax.add_patch(gate)
    ax.text(9.2, 3.85, 'HARD GATE: Must have field', ha='center', fontsize=8, fontweight='bold', color='white')
    ax.text(9.2, 3.6, 'assessment before officer approval', ha='center', fontsize=7, color='white')
    draw_arrow(ax, (9.2, 4.2), (9.2, 4.5), color=CRITICAL_RED, lw=1.5)

    # Output boxes
    outcomes = [
        ('APPROVED', 'Funds allocated', LOW_GREEN, 2.5),
        ('FLAGGED', 'Needs review', HIGH_ORANGE, 5.5),
        ('REJECTED', 'Denied with reason', CRITICAL_RED, 8.5),
    ]
    for label, desc, color, x in outcomes:
        box = FancyBboxPatch((x-1, 1.5), 2.2, 0.8, boxstyle="round,pad=0.05",
                              facecolor=hex_to_rgb(color), edgecolor=hex_to_rgb(color), linewidth=1.5)
        ax.add_patch(box)
        ax.text(x+0.1, 2.05, label, ha='center', fontsize=9, fontweight='bold', color='white')
        ax.text(x+0.1, 1.75, desc, ha='center', fontsize=7, color='white')

    draw_arrow(ax, (10.4, 4.5), (3.5, 2.3), color='#555', lw=1)
    draw_arrow(ax, (10.4, 4.5), (5.6, 2.3), color='#555', lw=1)
    draw_arrow(ax, (10.4, 4.5), (8.6, 2.3), color='#555', lw=1)

    # Bottom note
    ax.text(6, 0.9, 'Stored: si_demand_plans → validation_status, validation_score, officer_status, officer_name, officer_notes',
            ha='center', fontsize=7.5, color=TEXT_SECONDARY, style='italic')
    ax.text(6, 0.55, 'Each stage is independently tracked with timestamps (validated_at, assessment_date, officer_reviewed_at)',
            ha='center', fontsize=7.5, color=TEXT_SECONDARY, style='italic')

    path = os.path.join(TEMP_DIR, 'three_stage_pipeline.png')
    fig.savefig(path, dpi=200, bbox_inches='tight', facecolor='white')
    plt.close(fig)
    return path


def generate_offline_architecture():
    """Generate the Offline-First Architecture diagram."""
    fig, ax = plt.subplots(figsize=(12, 8))
    ax.set_xlim(0, 12)
    ax.set_ylim(0, 8)
    ax.axis('off')
    fig.patch.set_facecolor('white')

    ax.text(6, 7.7, 'Offline-First Architecture', ha='center',
            fontsize=15, fontweight='bold', color=hex_to_rgb(PRIMARY_DARK))

    # Flutter App outer box
    app = FancyBboxPatch((0.3, 2.5), 7.0, 4.8, boxstyle="round,pad=0.05",
                          facecolor=hex_to_rgb('#FAFAFA'), edgecolor=hex_to_rgb(PRIMARY), linewidth=2)
    ax.add_patch(app)
    ax.text(3.8, 7.1, 'Flutter Application Layer', fontsize=11, fontweight='bold', color=hex_to_rgb(PRIMARY))

    # Provider Layer
    prov = FancyBboxPatch((0.6, 5.8), 3.0, 1.2, boxstyle="round,pad=0.03",
                           facecolor=hex_to_rgb(LIGHT_BLUE), edgecolor=hex_to_rgb(PRIMARY), linewidth=1)
    ax.add_patch(prov)
    ax.text(2.1, 6.75, 'Riverpod Providers', fontsize=9, fontweight='bold', color=hex_to_rgb(PRIMARY))
    ax.text(2.1, 6.45, 'schoolsProvider', fontsize=7.5, color='#333')
    ax.text(2.1, 6.2, 'demandPlansProvider', fontsize=7.5, color='#333')
    ax.text(2.1, 5.95, 'priorityScoresProvider', fontsize=7.5, color='#333')

    # Decision diamond (simplified as box)
    dec = FancyBboxPatch((4.0, 5.8), 3.0, 1.2, boxstyle="round,pad=0.03",
                          facecolor=hex_to_rgb(LIGHT_ORANGE), edgecolor=hex_to_rgb(FASTAPI_ORANGE), linewidth=1)
    ax.add_patch(dec)
    ax.text(5.5, 6.7, 'Network Available?', fontsize=9, fontweight='bold', color=hex_to_rgb(FASTAPI_ORANGE))
    ax.text(5.5, 6.35, 'YES -> Fetch from Supabase', fontsize=7.5, color=LOW_GREEN)
    ax.text(5.5, 6.05, 'NO -> Fallback to Hive cache', fontsize=7.5, color=CRITICAL_RED)

    draw_arrow(ax, (3.6, 6.4), (4.0, 6.4), color='#555')

    # Hive Boxes
    boxes = [
        ('schools_cache', 'School master data\n319 schools (JSON)', HIVE_TEAL),
        ('demands_cache', 'Demand plans\n799 plans (JSON)', HIVE_TEAL),
        ('assessments_queue', 'Pending inspections\nWrite-ahead log', FASTAPI_ORANGE),
        ('demands_queue', 'HM offline demands\nQueue & retry', FASTAPI_ORANGE),
        ('cache_meta', 'Sync timestamps\nlast_sync_*', TEXT_SECONDARY),
    ]
    for i, (name, desc, color) in enumerate(boxes):
        x = 0.6
        y = 4.8 - i * 0.45
        box = FancyBboxPatch((x, y), 6.4, 0.4, boxstyle="round,pad=0.02",
                              facecolor='white', edgecolor=hex_to_rgb(color), linewidth=1)
        ax.add_patch(box)
        ax.text(x+0.15, y+0.2, f'  {name}', fontsize=7.5, fontweight='bold', color=hex_to_rgb(color), va='center')
        ax.text(x+3.2, y+0.2, desc.replace('\n', '  |  '), fontsize=6.5, color='#555', va='center')

    ax.text(3.8, 5.5, 'Hive Local Storage (5 Boxes)', fontsize=9, fontweight='bold', color=hex_to_rgb(HIVE_TEAL))

    # Sync label
    ax.text(3.8, 2.7, 'Auto-sync on reconnection  |  Queue pending writes  |  Graceful degradation',
            fontsize=7.5, color=hex_to_rgb(HIVE_TEAL), style='italic')

    # Supabase (right side)
    supa = FancyBboxPatch((8.0, 4.5), 3.5, 2.8, boxstyle="round,pad=0.05",
                           facecolor='white', edgecolor=hex_to_rgb(SUPABASE_GREEN), linewidth=2)
    ax.add_patch(supa)
    supa_h = FancyBboxPatch((8.0, 6.8), 3.5, 0.5, boxstyle="round,pad=0.05",
                              facecolor=hex_to_rgb(SUPABASE_GREEN), edgecolor=hex_to_rgb(SUPABASE_GREEN))
    ax.add_patch(supa_h)
    ax.text(9.75, 7.05, 'Supabase (Primary)', ha='center', fontsize=10, fontweight='bold', color='white')
    supa_items = [
        'PostgreSQL + RLS', '9 si_* tables', 'Source of truth',
        'Auth + JWT tokens', 'Real-time subscriptions',
    ]
    for i, item in enumerate(supa_items):
        ax.text(8.3, 6.4 - i*0.35, item, fontsize=8, color='#333')

    # FastAPI (right bottom)
    fast = FancyBboxPatch((8.0, 2.0), 3.5, 2.0, boxstyle="round,pad=0.05",
                           facecolor='white', edgecolor=hex_to_rgb(FASTAPI_ORANGE), linewidth=2)
    ax.add_patch(fast)
    fast_h = FancyBboxPatch((8.0, 3.5), 3.5, 0.5, boxstyle="round,pad=0.05",
                              facecolor=hex_to_rgb(FASTAPI_ORANGE), edgecolor=hex_to_rgb(FASTAPI_ORANGE))
    ax.add_patch(fast_h)
    ax.text(9.75, 3.75, 'FastAPI ML (Optional)', ha='center', fontsize=10, fontweight='bold', color='white')
    fast_items = ['Backend-first strategy', 'Client-side fallback', 'Graceful degradation']
    for i, item in enumerate(fast_items):
        ax.text(8.3, 3.2 - i*0.35, item, fontsize=8, color='#333')

    # Arrows Flutter <-> Supabase
    draw_label_arrow(ax, (7.3, 6.0), (8.0, 6.0), 'HTTPS', SUPABASE_GREEN)
    draw_label_arrow(ax, (7.3, 3.5), (8.0, 3.0), 'REST', FASTAPI_ORANGE)

    # Sync arrows
    draw_label_arrow(ax, (5.5, 2.5), (8.0, 5.0), 'Sync queues\non reconnect', HIVE_TEAL, fontsize=6)

    # Flow description at bottom
    flow_text = [
        'Data Flow: Provider -> Try Supabase -> On success: Cache to Hive -> Return data',
        'Offline Flow: Provider -> Supabase fails -> Load from Hive cache -> Return cached data',
        'Write Flow: Submit -> Try Supabase -> On fail: Queue in Hive -> Auto-sync on reconnect',
    ]
    for i, ft in enumerate(flow_text):
        ax.text(6, 1.6 - i*0.35, ft, ha='center', fontsize=7.5, color='#444')

    path = os.path.join(TEMP_DIR, 'offline_architecture.png')
    fig.savefig(path, dpi=200, bbox_inches='tight', facecolor='white')
    plt.close(fig)
    return path


def generate_screen_navigation():
    """Generate the Screen Navigation Flow diagram."""
    fig, ax = plt.subplots(figsize=(12, 9))
    ax.set_xlim(0, 12)
    ax.set_ylim(0, 9)
    ax.axis('off')
    fig.patch.set_facecolor('white')

    ax.text(6, 8.7, 'Screen Navigation & User Flow', ha='center',
            fontsize=15, fontweight='bold', color=hex_to_rgb(PRIMARY_DARK))

    # Role Selection
    rs = FancyBboxPatch((4, 7.8), 4, 0.6, boxstyle="round,pad=0.05",
                         facecolor=hex_to_rgb(PRIMARY), edgecolor=hex_to_rgb(PRIMARY), linewidth=2)
    ax.add_patch(rs)
    ax.text(6, 8.1, 'Role Selection Screen (5 Roles)', ha='center', fontsize=10, fontweight='bold', color='white')

    # Role branches
    roles = [
        ('State Official /\nDistrict Officer', PRIMARY, 1.5, 6),
        ('Block Officer /\nField Inspector', HIVE_TEAL, 5.5, 6),
        ('School HM', FASTAPI_ORANGE, 9.5, 6),
    ]

    for label, color, x, y in roles:
        box = FancyBboxPatch((x-1.2, y), 2.8, 0.9, boxstyle="round,pad=0.05",
                              facecolor=hex_to_rgb(color), edgecolor=hex_to_rgb(color), linewidth=1.5)
        ax.add_patch(box)
        ax.text(x+0.2, y+0.45, label, ha='center', va='center', fontsize=8, fontweight='bold', color='white')

    # Arrows from role selection
    draw_arrow(ax, (5, 7.8), (1.7, 6.9), color=PRIMARY, lw=1.5)
    draw_arrow(ax, (6, 7.8), (5.7, 6.9), color=HIVE_TEAL, lw=1.5)
    draw_arrow(ax, (7, 7.8), (9.7, 6.9), color=FASTAPI_ORANGE, lw=1.5)

    # Dashboard tabs for State/District
    tabs1 = [
        ('Overview Tab', 'Stats, Priority Pie, Summary', PRIMARY),
        ('Schools Tab', 'Filterable List, Search', SUPABASE_GREEN),
        ('Map Tab', 'flutter_map, Priority Markers', HIVE_TEAL),
        ('Validation Tab', 'AI + Officer Review', ML_PURPLE),
        ('Analytics Tab', 'Charts, Distributions', FASTAPI_ORANGE),
    ]
    for i, (name, desc, color) in enumerate(tabs1):
        y = 5.3 - i * 0.55
        box = FancyBboxPatch((0.2, y), 3.0, 0.45, boxstyle="round,pad=0.02",
                              facecolor='white', edgecolor=hex_to_rgb(color), linewidth=1)
        ax.add_patch(box)
        ax.text(0.35, y+0.28, name, fontsize=7.5, fontweight='bold', color=hex_to_rgb(color))
        ax.text(0.35, y+0.08, desc, fontsize=6, color='#666')
    draw_arrow(ax, (1.7, 6.0), (1.7, 5.75), color='#555')

    # Dashboard tabs for Block/Inspector
    tabs2 = [
        ('Overview Tab', 'Mandal-scoped stats', PRIMARY),
        ('Schools Tab', 'Mandal schools only', SUPABASE_GREEN),
        ('Map Tab', 'Mandal area markers', HIVE_TEAL),
        ('Inspection Tab', '50+ field assessment form', CRITICAL_RED),
    ]
    for i, (name, desc, color) in enumerate(tabs2):
        y = 5.3 - i * 0.55
        box = FancyBboxPatch((4.2, y), 3.0, 0.45, boxstyle="round,pad=0.02",
                              facecolor='white', edgecolor=hex_to_rgb(color), linewidth=1)
        ax.add_patch(box)
        ax.text(4.35, y+0.28, name, fontsize=7.5, fontweight='bold', color=hex_to_rgb(color))
        ax.text(4.35, y+0.08, desc, fontsize=6, color='#666')
    draw_arrow(ax, (5.7, 6.0), (5.7, 5.75), color='#555')

    # HM tabs
    tabs3 = [
        ('My School Tab', 'School info, infra status,\npriority score, enrolment', PRIMARY),
        ('My Requests Tab', 'Demand plans list,\n3-stage pipeline status', FASTAPI_ORANGE),
    ]
    for i, (name, desc, color) in enumerate(tabs3):
        y = 5.0 - i * 0.85
        box = FancyBboxPatch((8.2, y), 3.2, 0.7, boxstyle="round,pad=0.02",
                              facecolor='white', edgecolor=hex_to_rgb(color), linewidth=1)
        ax.add_patch(box)
        ax.text(8.35, y+0.48, name, fontsize=7.5, fontweight='bold', color=hex_to_rgb(color))
        ax.text(8.35, y+0.18, desc.replace('\n', ' '), fontsize=6, color='#666')
    draw_arrow(ax, (9.7, 6.0), (9.7, 5.7), color='#555')

    # Detail screens
    detail_screens = [
        ('School Profile', 'Enrolment chart, forecast,\ndemand plans, priority', 1.5, 2.2, SUPABASE_GREEN),
        ('Inspection Screen', '50+ fields, GPS,\nphoto evidence', 5.0, 2.2, CRITICAL_RED),
        ('Raise Demand', 'Infra type, qty, cost,\nauto-calculate', 8.5, 2.2, FASTAPI_ORANGE),
    ]
    for name, desc, x, y, color in detail_screens:
        box = FancyBboxPatch((x-1.2, y), 2.8, 0.8, boxstyle="round,pad=0.03",
                              facecolor=hex_to_rgb(color), edgecolor=hex_to_rgb(color), linewidth=1.5)
        ax.add_patch(box)
        ax.text(x+0.2, y+0.55, name, ha='center', fontsize=8, fontweight='bold', color='white')
        ax.text(x+0.2, y+0.2, desc.replace('\n', ' '), ha='center', fontsize=6.5, color='white')

    # Arrows to detail screens
    draw_arrow(ax, (1.7, 3.6), (1.7, 3.0), color=SUPABASE_GREEN)  # Schools tab -> Profile
    draw_arrow(ax, (5.7, 3.1), (5.2, 3.0), color=CRITICAL_RED)  # Inspection tab -> Inspection
    draw_arrow(ax, (9.7, 4.15), (9.7, 3.0), color=FASTAPI_ORANGE)  # HM -> Raise demand

    ax.text(1.7, 3.35, 'Tap school', fontsize=6, color='#777', ha='center', style='italic')
    ax.text(5.7, 3.35, 'Start inspection', fontsize=6, color='#777', ha='center', style='italic')
    ax.text(10.3, 3.5, 'FAB +', fontsize=6, color='#777', style='italic')

    # Bottom description
    ax.text(6, 1.5, 'Navigation: Material Design 3 Bottom Navigation  |  Deep linking via tab callbacks',
            ha='center', fontsize=8, color=TEXT_SECONDARY, style='italic')
    ax.text(6, 1.1, 'Data scoping: Each role sees only their authorized data (district/mandal/school locked by effectiveProvider)',
            ha='center', fontsize=8, color=TEXT_SECONDARY, style='italic')

    path = os.path.join(TEMP_DIR, 'screen_navigation.png')
    fig.savefig(path, dpi=200, bbox_inches='tight', facecolor='white')
    plt.close(fig)
    return path


# ─── PDF Builder ───

class NumberedCanvas(canvas.Canvas):
    """Canvas that adds page numbers and header/footer."""
    def __init__(self, *args, **kwargs):
        canvas.Canvas.__init__(self, *args, **kwargs)
        self._saved_page_states = []

    def showPage(self):
        self._saved_page_states.append(dict(self.__dict__))
        self._startPage()

    def save(self):
        num_pages = len(self._saved_page_states)
        for state in self._saved_page_states:
            self.__dict__.update(state)
            self.draw_page_number(num_pages)
            canvas.Canvas.showPage(self)
        canvas.Canvas.save(self)

    def draw_page_number(self, page_count):
        self.saveState()
        self.setFont('Helvetica', 8)
        self.setFillColor(hex_to_rl(TEXT_SECONDARY))
        page_num = len([s for s in self._saved_page_states if s.get('_pageNumber', 0) <= self._pageNumber])
        # Footer
        self.drawCentredString(W/2, 25, f'Vidya Nirmaan — Architecture & Design Document  |  Page {self._pageNumber} of {page_count}')
        # Header line
        if self._pageNumber > 1:
            self.setStrokeColor(hex_to_rl(PRIMARY))
            self.setLineWidth(0.5)
            self.line(50, H - 40, W - 50, H - 40)
            self.setFont('Helvetica', 7)
            self.drawString(50, H - 35, 'IndiaAI Innovation Challenge — Problem Statement 5')
            self.drawRightString(W - 50, H - 35, 'Dept. of School Education, Andhra Pradesh')
        self.restoreState()


def build_pdf(diagrams):
    """Build the complete PDF document."""
    output_path = os.path.join(os.path.dirname(os.path.abspath(__file__)),
                                'Vidya_Nirmaan_Architecture_Design.pdf')

    doc = SimpleDocTemplate(
        output_path, pagesize=A4,
        topMargin=55, bottomMargin=45,
        leftMargin=50, rightMargin=50
    )

    styles = getSampleStyleSheet()

    # Custom styles
    styles.add(ParagraphStyle(
        'CoverTitle', parent=styles['Title'],
        fontSize=32, leading=40, textColor=hex_to_rl(PRIMARY_DARK),
        alignment=TA_CENTER, spaceAfter=10
    ))
    styles.add(ParagraphStyle(
        'CoverSubtitle', parent=styles['Normal'],
        fontSize=16, leading=22, textColor=hex_to_rl(PRIMARY),
        alignment=TA_CENTER, spaceAfter=8
    ))
    styles.add(ParagraphStyle(
        'SectionTitle', parent=styles['Heading1'],
        fontSize=18, leading=24, textColor=hex_to_rl(PRIMARY_DARK),
        spaceBefore=12, spaceAfter=8
    ))
    styles.add(ParagraphStyle(
        'SubTitle', parent=styles['Heading2'],
        fontSize=13, leading=17, textColor=hex_to_rl(PRIMARY),
        spaceBefore=8, spaceAfter=4
    ))
    styles.add(ParagraphStyle(
        'BodyText2', parent=styles['BodyText'],
        fontSize=10, leading=14.5, textColor=hex_to_rl(TEXT_PRIMARY),
        alignment=TA_JUSTIFY, spaceAfter=6
    ))
    styles.add(ParagraphStyle(
        'Caption', parent=styles['Normal'],
        fontSize=8, leading=10, textColor=hex_to_rl(TEXT_SECONDARY),
        alignment=TA_CENTER, spaceAfter=12, fontName='Helvetica-Oblique'
    ))
    styles.add(ParagraphStyle(
        'TOCEntry', parent=styles['Normal'],
        fontSize=11, leading=20, textColor=hex_to_rl(TEXT_PRIMARY),
        leftIndent=20
    ))
    styles.add(ParagraphStyle(
        'TOCSectionNum', parent=styles['Normal'],
        fontSize=11, leading=20, textColor=hex_to_rl(PRIMARY),
        fontName='Helvetica-Bold'
    ))
    styles.add(ParagraphStyle(
        'CoverBadge', parent=styles['Normal'],
        fontSize=12, leading=16, textColor=hex_to_rl(FASTAPI_ORANGE),
        alignment=TA_CENTER, fontName='Helvetica-Bold'
    ))
    styles.add(ParagraphStyle(
        'BulletItem', parent=styles['BodyText'],
        fontSize=10, leading=14, textColor=hex_to_rl(TEXT_PRIMARY),
        bulletIndent=15, leftIndent=30, spaceAfter=3
    ))

    story = []

    # ═══════════════════════════════════════
    # PAGE 1: COVER
    # ═══════════════════════════════════════
    story.append(Spacer(1, 100))
    story.append(Paragraph('Vidya Nirmaan', styles['CoverTitle']))
    story.append(Paragraph('AI-Powered School Infrastructure<br/>Planning &amp; Monitoring System', styles['CoverSubtitle']))
    story.append(Spacer(1, 20))

    # Divider
    story.append(HRFlowable(width="60%", thickness=2, color=hex_to_rl(PRIMARY), spaceAfter=20, spaceBefore=10))

    story.append(Paragraph('Architecture &amp; Design Document', ParagraphStyle(
        'CoverDoc', parent=styles['Normal'], fontSize=14, leading=18,
        textColor=hex_to_rl(TEXT_PRIMARY), alignment=TA_CENTER, spaceAfter=30
    )))

    story.append(Paragraph('IndiaAI Innovation Challenge', styles['CoverBadge']))
    story.append(Paragraph('Problem Statement 5: School Infrastructure Management', ParagraphStyle(
        'CoverPS', parent=styles['Normal'], fontSize=11, leading=15,
        textColor=hex_to_rl(TEXT_SECONDARY), alignment=TA_CENTER, spaceAfter=8
    )))
    story.append(Paragraph('Department of School Education, Andhra Pradesh', ParagraphStyle(
        'CoverDept', parent=styles['Normal'], fontSize=11, leading=15,
        textColor=hex_to_rl(TEXT_SECONDARY), alignment=TA_CENTER, spaceAfter=40
    )))

    # Info table
    cover_data = [
        ['Version', '1.0'],
        ['Date', 'March 2026'],
        ['Platform', 'Flutter (iOS + Android) + Supabase + FastAPI'],
        ['Coverage', '319 Schools, 57 Districts, 707 Mandals'],
    ]
    cover_table = Table(cover_data, colWidths=[120, 300])
    cover_table.setStyle(TableStyle([
        ('FONTNAME', (0, 0), (0, -1), 'Helvetica-Bold'),
        ('FONTSIZE', (0, 0), (-1, -1), 10),
        ('TEXTCOLOR', (0, 0), (0, -1), hex_to_rl(PRIMARY)),
        ('TEXTCOLOR', (1, 0), (1, -1), hex_to_rl(TEXT_PRIMARY)),
        ('BOTTOMPADDING', (0, 0), (-1, -1), 8),
        ('ALIGN', (0, 0), (-1, -1), 'LEFT'),
    ]))
    story.append(cover_table)

    story.append(PageBreak())

    # ═══════════════════════════════════════
    # PAGE 2: TABLE OF CONTENTS
    # ═══════════════════════════════════════
    story.append(Paragraph('Table of Contents', styles['SectionTitle']))
    story.append(Spacer(1, 10))

    toc_entries = [
        ('1', 'Executive Summary', '3'),
        ('2', 'System Architecture', '4'),
        ('3', 'Technology Stack', '5'),
        ('4', 'Database Schema (ER Diagram)', '6'),
        ('5', 'AI/ML Pipeline: Priority Scoring', '7'),
        ('6', 'AI/ML Pipeline: Demand Validation', '8'),
        ('7', 'AI/ML Pipeline: Enrolment Forecasting', '9'),
        ('8', '3-Stage Demand Approval Pipeline', '10'),
        ('9', 'Role-Based Access Control', '11'),
        ('10', 'Offline-First Architecture', '12'),
        ('11', 'Screen Navigation &amp; User Flow', '13'),
    ]

    toc_data = []
    for num, title, page in toc_entries:
        toc_data.append([
            Paragraph(f'<b>{num}.</b>', styles['TOCSectionNum']),
            Paragraph(title, styles['TOCEntry']),
            Paragraph(page, ParagraphStyle('TOCPage', parent=styles['Normal'],
                                            fontSize=11, textColor=hex_to_rl(TEXT_SECONDARY), alignment=TA_RIGHT))
        ])

    toc_table = Table(toc_data, colWidths=[30, 350, 50])
    toc_table.setStyle(TableStyle([
        ('BOTTOMPADDING', (0, 0), (-1, -1), 5),
        ('TOPPADDING', (0, 0), (-1, -1), 5),
        ('LINEBELOW', (0, 0), (-1, -2), 0.3, hex_to_rl(BG_LIGHT)),
        ('VALIGN', (0, 0), (-1, -1), 'MIDDLE'),
    ]))
    story.append(toc_table)

    story.append(PageBreak())

    # ═══════════════════════════════════════
    # PAGE 3: EXECUTIVE SUMMARY
    # ═══════════════════════════════════════
    story.append(Paragraph('1. Executive Summary', styles['SectionTitle']))
    story.append(HRFlowable(width="100%", thickness=1, color=hex_to_rl(PRIMARY), spaceAfter=12))

    story.append(Paragraph('<b>Problem Statement</b>', styles['SubTitle']))
    story.append(Paragraph(
        'Andhra Pradesh manages over 45,000+ government schools across 57 districts and 707 mandals. '
        'The current infrastructure planning process for facilities like CWSN resource rooms, '
        'accessible toilets, drinking water, electrification, and ramps relies on manual paper-based '
        'workflows prone to data inconsistencies, delayed processing, fraudulent demand inflation, '
        'and inequitable resource allocation. There is no automated system to validate infrastructure '
        'demands, forecast future needs based on enrolment trends, or prioritize schools objectively.',
        styles['BodyText2']
    ))

    story.append(Paragraph('<b>Our Solution: Vidya Nirmaan</b>', styles['SubTitle']))
    story.append(Paragraph(
        'Vidya Nirmaan is an AI-powered mobile application that digitizes the entire school '
        'infrastructure lifecycle: from demand raising by Head Masters, to AI-driven validation '
        'and anomaly detection, field assessment by inspectors, and final officer approval. '
        'The system uses machine learning models including Isolation Forest for fraud detection, '
        'Linear Regression and Cohort Progression for enrolment forecasting, and a weighted '
        'composite scoring algorithm for objective school prioritization.',
        styles['BodyText2']
    ))

    story.append(Paragraph('<b>Key Metrics</b>', styles['SubTitle']))
    metrics_data = [
        ['Metric', 'Value'],
        ['Schools Covered', '319 (pilot), scalable to 45,000+'],
        ['Districts', '57'],
        ['Mandals', '707'],
        ['Demand Plans Managed', '799'],
        ['Enrolment Records', '4,638'],
        ['Infrastructure Types', '5 (Samagra Shiksha norms)'],
        ['AI Models', '3 (Priority Scoring, Validation, Forecasting)'],
        ['Validation Rules', '7 rule-based + Isolation Forest ML'],
        ['User Roles', '5 (State, District, Block, Inspector, HM)'],
        ['Languages', '2 (English + Telugu)'],
        ['Offline Support', 'Full offline-first with auto-sync'],
    ]
    metrics_table = Table(metrics_data, colWidths=[170, 290])
    metrics_table.setStyle(TableStyle([
        ('BACKGROUND', (0, 0), (-1, 0), hex_to_rl(PRIMARY)),
        ('TEXTCOLOR', (0, 0), (-1, 0), rl_colors.white),
        ('FONTNAME', (0, 0), (-1, 0), 'Helvetica-Bold'),
        ('FONTSIZE', (0, 0), (-1, -1), 9),
        ('FONTNAME', (0, 1), (0, -1), 'Helvetica-Bold'),
        ('TEXTCOLOR', (0, 1), (0, -1), hex_to_rl(PRIMARY)),
        ('BOTTOMPADDING', (0, 0), (-1, -1), 6),
        ('TOPPADDING', (0, 0), (-1, -1), 6),
        ('GRID', (0, 0), (-1, -1), 0.5, hex_to_rl(BG_LIGHT)),
        ('ROWBACKGROUNDS', (0, 1), (-1, -1), [rl_colors.white, hex_to_rl('#F8F9FA')]),
        ('VALIGN', (0, 0), (-1, -1), 'MIDDLE'),
    ]))
    story.append(metrics_table)

    story.append(PageBreak())

    # ═══════════════════════════════════════
    # PAGE 4: SYSTEM ARCHITECTURE
    # ═══════════════════════════════════════
    story.append(Paragraph('2. System Architecture', styles['SectionTitle']))
    story.append(HRFlowable(width="100%", thickness=1, color=hex_to_rl(PRIMARY), spaceAfter=8))
    story.append(Paragraph(
        'Vidya Nirmaan follows a 3-tier architecture: a Flutter mobile frontend, a Supabase '
        'backend (PostgreSQL with Row Level Security), and an optional FastAPI ML backend deployed '
        'on Railway cloud. A Hive-based local storage layer provides offline-first capability '
        'with automatic synchronization.',
        styles['BodyText2']
    ))

    img = Image(diagrams['system_architecture'], width=480, height=360)
    story.append(img)
    story.append(Paragraph('Figure 1: System Architecture — 3-Tier with Offline-First Design', styles['Caption']))

    story.append(PageBreak())

    # ═══════════════════════════════════════
    # PAGE 5: TECHNOLOGY STACK
    # ═══════════════════════════════════════
    story.append(Paragraph('3. Technology Stack', styles['SectionTitle']))
    story.append(HRFlowable(width="100%", thickness=1, color=hex_to_rl(PRIMARY), spaceAfter=8))

    tech_data = [
        ['Layer', 'Technology', 'Purpose'],
        ['Frontend', 'Flutter 3.10+', 'Cross-platform mobile (iOS + Android)'],
        ['State Management', 'Riverpod 3.x', 'Reactive state with Notifier/AsyncValue pattern'],
        ['Charts', 'fl_chart', 'Enrolment charts, priority pie, analytics'],
        ['Maps', 'flutter_map', 'School location visualization, priority-coded markers'],
        ['Backend DB', 'Supabase', 'PostgreSQL + Auth + Row Level Security'],
        ['ML Backend', 'FastAPI 0.109+', 'Python ML microservice'],
        ['ML Cloud', 'Railway', 'FastAPI deployment and hosting'],
        ['ML Libraries', 'scikit-learn 1.4+', 'LinearRegression, IsolationForest'],
        ['Data Science', 'NumPy, Pandas', 'Data processing and feature engineering'],
        ['Local Storage', 'Hive', 'Offline-first caching (5 boxes)'],
        ['HTTP Client', 'Dio', 'REST API communication with timeout/retry'],
        ['Export', 'pdf, excel', 'PDF and Excel report generation'],
        ['Localization', 'Custom i18n', 'English + Telugu bilingual support'],
        ['UI Framework', 'Material Design 3', 'Modern, accessible UI components'],
    ]
    tech_table = Table(tech_data, colWidths=[100, 120, 250])
    tech_table.setStyle(TableStyle([
        ('BACKGROUND', (0, 0), (-1, 0), hex_to_rl(PRIMARY)),
        ('TEXTCOLOR', (0, 0), (-1, 0), rl_colors.white),
        ('FONTNAME', (0, 0), (-1, 0), 'Helvetica-Bold'),
        ('FONTSIZE', (0, 0), (-1, -1), 9),
        ('FONTNAME', (0, 1), (0, -1), 'Helvetica-Bold'),
        ('TEXTCOLOR', (0, 1), (0, -1), hex_to_rl(PRIMARY)),
        ('BOTTOMPADDING', (0, 0), (-1, -1), 6),
        ('TOPPADDING', (0, 0), (-1, -1), 6),
        ('GRID', (0, 0), (-1, -1), 0.5, hex_to_rl(BG_LIGHT)),
        ('ROWBACKGROUNDS', (0, 1), (-1, -1), [rl_colors.white, hex_to_rl('#F8F9FA')]),
        ('VALIGN', (0, 0), (-1, -1), 'MIDDLE'),
    ]))
    story.append(tech_table)

    story.append(Spacer(1, 20))
    story.append(Paragraph('<b>Infrastructure Types &amp; Unit Costs (Samagra Shiksha Norms)</b>', styles['SubTitle']))

    infra_data = [
        ['Infrastructure Type', 'Unit Cost (Lakhs)', 'Description'],
        ['CWSN Resource Room', '29.30', 'Special needs classroom facility'],
        ['CWSN Toilet', '4.65', 'Accessible toilet block for differently-abled'],
        ['Drinking Water', '3.40', 'Water purification and supply system'],
        ['Electrification', '1.75', 'School electrical infrastructure'],
        ['Ramps', '1.25', 'Accessibility ramps and handrails'],
    ]
    infra_table = Table(infra_data, colWidths=[150, 110, 210])
    infra_table.setStyle(TableStyle([
        ('BACKGROUND', (0, 0), (-1, 0), hex_to_rl(HIVE_TEAL)),
        ('TEXTCOLOR', (0, 0), (-1, 0), rl_colors.white),
        ('FONTNAME', (0, 0), (-1, 0), 'Helvetica-Bold'),
        ('FONTSIZE', (0, 0), (-1, -1), 9),
        ('FONTNAME', (0, 1), (0, -1), 'Helvetica-Bold'),
        ('BOTTOMPADDING', (0, 0), (-1, -1), 6),
        ('TOPPADDING', (0, 0), (-1, -1), 6),
        ('GRID', (0, 0), (-1, -1), 0.5, hex_to_rl(BG_LIGHT)),
        ('ROWBACKGROUNDS', (0, 1), (-1, -1), [rl_colors.white, hex_to_rl('#E0F2F1')]),
        ('VALIGN', (0, 0), (-1, -1), 'MIDDLE'),
        ('ALIGN', (1, 1), (1, -1), 'CENTER'),
    ]))
    story.append(infra_table)

    story.append(PageBreak())

    # ═══════════════════════════════════════
    # PAGE 6-7: DATABASE SCHEMA
    # ═══════════════════════════════════════
    story.append(Paragraph('4. Database Schema (Entity-Relationship Diagram)', styles['SectionTitle']))
    story.append(HRFlowable(width="100%", thickness=1, color=hex_to_rl(PRIMARY), spaceAfter=8))
    story.append(Paragraph(
        'All tables use the <b>si_</b> prefix (school infrastructure). The schema follows a hierarchical '
        'geographic structure: Districts &rarr; Mandals &rarr; Schools, with satellite tables for '
        'enrolment history, demand plans, infrastructure assessments, priority scores, and ML forecasts. '
        'Two database views (<i>si_schools_view</i> and <i>si_demand_plans_view</i>) provide pre-joined '
        'data for efficient querying.',
        styles['BodyText2']
    ))

    img = Image(diagrams['er_diagram'], width=500, height=345)
    story.append(img)
    story.append(Paragraph('Figure 2: Entity-Relationship Diagram — 9 Tables with Geographic Hierarchy', styles['Caption']))

    story.append(PageBreak())

    # ═══════════════════════════════════════
    # PAGE 7-8: PRIORITY SCORING
    # ═══════════════════════════════════════
    story.append(Paragraph('5. AI/ML Pipeline: Priority Scoring', styles['SectionTitle']))
    story.append(HRFlowable(width="100%", thickness=1, color=hex_to_rl(PRIMARY), spaceAfter=8))
    story.append(Paragraph(
        'The Priority Scoring algorithm computes a composite score (0-100) for each school using '
        'four weighted factors. This score objectively ranks schools for infrastructure investment, '
        'replacing subjective manual assessment. Scores are computed client-side for instant results '
        'and stored in the <b>si_school_priority_scores</b> table.',
        styles['BodyText2']
    ))

    img = Image(diagrams['priority_scoring'], width=490, height=325)
    story.append(img)
    story.append(Paragraph('Figure 3: Priority Scoring Pipeline — 4-Factor Weighted Composite (0-100)', styles['Caption']))

    story.append(PageBreak())

    # ═══════════════════════════════════════
    # PAGE 9: DEMAND VALIDATION
    # ═══════════════════════════════════════
    story.append(Paragraph('6. AI/ML Pipeline: Demand Validation', styles['SectionTitle']))
    story.append(HRFlowable(width="100%", thickness=1, color=hex_to_rl(PRIMARY), spaceAfter=8))
    story.append(Paragraph(
        'Infrastructure demands pass through a dual-layer validation engine. The client-side '
        'rule-based engine applies 7 validation checks with cumulative score deductions. '
        'The backend ML layer uses an <b>Isolation Forest</b> anomaly detector trained on the '
        'demand dataset to identify statistical outliers that rules alone may miss. Demands scoring '
        '&ge;80 are auto-approved, 50-79 are flagged for review, and &lt;50 are rejected.',
        styles['BodyText2']
    ))

    img = Image(diagrams['validation_pipeline'], width=490, height=365)
    story.append(img)
    story.append(Paragraph('Figure 4: Demand Validation Pipeline — 7 Rules + Isolation Forest ML', styles['Caption']))

    story.append(PageBreak())

    # ═══════════════════════════════════════
    # PAGE 10: FORECASTING
    # ═══════════════════════════════════════
    story.append(Paragraph('7. AI/ML Pipeline: Enrolment Forecasting', styles['SectionTitle']))
    story.append(HRFlowable(width="100%", thickness=1, color=hex_to_rl(PRIMARY), spaceAfter=8))
    story.append(Paragraph(
        'Enrolment forecasting uses a dual-model approach: <b>Linear Regression</b> for overall '
        'trend extrapolation and <b>Cohort Progression</b> for grade-wise student flow tracking. '
        'A multi-factor confidence score accounts for data quality, prediction horizon decay, and '
        'historical volatility. The system follows a backend-first strategy, falling back to '
        'client-side linear extrapolation when the ML backend is unavailable.',
        styles['BodyText2']
    ))

    img = Image(diagrams['forecasting'], width=490, height=325)
    story.append(img)
    story.append(Paragraph('Figure 5: Enrolment Forecasting — Dual Model with Confidence Decay', styles['Caption']))

    story.append(PageBreak())

    # ═══════════════════════════════════════
    # PAGE 11: 3-STAGE PIPELINE
    # ═══════════════════════════════════════
    story.append(Paragraph('8. 3-Stage Demand Approval Pipeline', styles['SectionTitle']))
    story.append(HRFlowable(width="100%", thickness=1, color=hex_to_rl(PRIMARY), spaceAfter=8))
    story.append(Paragraph(
        'Every infrastructure demand passes through three sequential stages: <b>AI Validation</b> '
        '(automated scoring and anomaly detection), <b>Field Assessment</b> (physical inspection by '
        'field officers with 50+ data points and GPS verification), and <b>Officer Decision</b> '
        '(manual approval by District/State officials). A <b>hard gate</b> enforces that field '
        'assessment must be completed before officer approval, ensuring no demand is approved without '
        'ground-truth verification.',
        styles['BodyText2']
    ))

    img = Image(diagrams['three_stage_pipeline'], width=490, height=285)
    story.append(img)
    story.append(Paragraph('Figure 6: 3-Stage Approval Pipeline — AI, Assessment, Officer with Hard Gate', styles['Caption']))

    story.append(PageBreak())

    # ═══════════════════════════════════════
    # PAGE 12: RBAC
    # ═══════════════════════════════════════
    story.append(Paragraph('9. Role-Based Access Control', styles['SectionTitle']))
    story.append(HRFlowable(width="100%", thickness=1, color=hex_to_rl(PRIMARY), spaceAfter=8))
    story.append(Paragraph(
        'The application implements strict role-based access control with 5 distinct user roles. '
        'Data scoping is enforced at the provider level using <b>effectiveDistrictProvider</b>, '
        '<b>effectiveMandalProvider</b>, and <b>effectiveSchoolIdProvider</b> to lock each role '
        'to their authorized geographic scope.',
        styles['BodyText2']
    ))

    rbac_data = [
        ['Permission', 'State\nOfficial', 'District\nOfficer', 'Block\nOfficer', 'Field\nInspector', 'School\nHM'],
        ['View Schools', 'All', 'District', 'Mandal', 'Mandal', 'Own school'],
        ['View Map', '\u2713', '\u2713', '\u2713', '\u2713', '\u2713'],
        ['AI + Manual\nValidation', '\u2713', '\u2713', '\u2717', '\u2717', '\u2717'],
        ['Field Inspection', '\u2717', '\u2717', '\u2713', '\u2713', '\u2717'],
        ['Export Data\n(PDF/Excel)', '\u2713', '\u2713', '\u2717', '\u2717', '\u2717'],
        ['Raise Demand', '\u2717', '\u2717', '\u2717', '\u2717', '\u2713'],
        ['District Filter', 'Free', 'Locked', 'Locked', 'Locked', 'Locked'],
        ['Mandal Filter', 'Free', 'Free', 'Locked', 'Locked', 'Locked'],
        ['Dashboard Tabs', '6 tabs', '6 tabs', '5 tabs', '5 tabs', '2 tabs'],
    ]

    rbac_table = Table(rbac_data, colWidths=[95, 75, 75, 75, 75, 75])
    rbac_table.setStyle(TableStyle([
        ('BACKGROUND', (0, 0), (-1, 0), hex_to_rl(PRIMARY)),
        ('TEXTCOLOR', (0, 0), (-1, 0), rl_colors.white),
        ('FONTNAME', (0, 0), (-1, 0), 'Helvetica-Bold'),
        ('FONTNAME', (0, 1), (0, -1), 'Helvetica-Bold'),
        ('FONTSIZE', (0, 0), (-1, -1), 8.5),
        ('BOTTOMPADDING', (0, 0), (-1, -1), 7),
        ('TOPPADDING', (0, 0), (-1, -1), 7),
        ('GRID', (0, 0), (-1, -1), 0.5, hex_to_rl(BG_LIGHT)),
        ('ROWBACKGROUNDS', (0, 1), (-1, -1), [rl_colors.white, hex_to_rl('#F8F9FA')]),
        ('VALIGN', (0, 0), (-1, -1), 'MIDDLE'),
        ('ALIGN', (1, 0), (-1, -1), 'CENTER'),
        ('TEXTCOLOR', (0, 1), (0, -1), hex_to_rl(PRIMARY)),
    ]))

    # Highlight checkmarks green and crosses red
    for row in range(1, len(rbac_data)):
        for col in range(1, len(rbac_data[0])):
            val = rbac_data[row][col]
            if val == '\u2713':
                rbac_table.setStyle(TableStyle([
                    ('TEXTCOLOR', (col, row), (col, row), hex_to_rl(LOW_GREEN)),
                    ('FONTNAME', (col, row), (col, row), 'Helvetica-Bold'),
                    ('FONTSIZE', (col, row), (col, row), 12),
                ]))
            elif val == '\u2717':
                rbac_table.setStyle(TableStyle([
                    ('TEXTCOLOR', (col, row), (col, row), hex_to_rl(CRITICAL_RED)),
                    ('FONTNAME', (col, row), (col, row), 'Helvetica-Bold'),
                    ('FONTSIZE', (col, row), (col, row), 12),
                ]))

    story.append(rbac_table)

    story.append(Spacer(1, 20))
    story.append(Paragraph('<b>Data Scoping Architecture</b>', styles['SubTitle']))
    story.append(Paragraph(
        'Role-based data scoping is implemented through Riverpod providers that lock geographic '
        'filters based on the current user\'s role:',
        styles['BodyText2']
    ))

    scoping_items = [
        '<b>effectiveDistrictProvider</b>: Locks District Officers, Block Officers, Field Inspectors, and HMs to their assigned district. State Officials can freely select any district.',
        '<b>effectiveMandalProvider</b>: Locks Block Officers, Field Inspectors, and HMs to their assigned mandal. State and District Officials can freely select mandals.',
        '<b>effectiveSchoolIdProvider</b>: Locks School HMs to their single assigned school. All other roles see multiple schools.',
    ]
    for item in scoping_items:
        story.append(Paragraph(item, styles['BulletItem'], bulletText='\u2022'))

    story.append(PageBreak())

    # ═══════════════════════════════════════
    # PAGE 13: OFFLINE ARCHITECTURE
    # ═══════════════════════════════════════
    story.append(Paragraph('10. Offline-First Architecture', styles['SectionTitle']))
    story.append(HRFlowable(width="100%", thickness=1, color=hex_to_rl(PRIMARY), spaceAfter=8))
    story.append(Paragraph(
        'Vidya Nirmaan is designed for rural deployment where network connectivity is unreliable. '
        'The Hive-based offline cache provides 5 dedicated storage boxes for school data, demand plans, '
        'pending assessments, offline demand submissions, and sync metadata. Data flows through a '
        'try-online-first, fallback-to-cache strategy with automatic queue-and-retry for write operations.',
        styles['BodyText2']
    ))

    img = Image(diagrams['offline_architecture'], width=490, height=325)
    story.append(img)
    story.append(Paragraph('Figure 7: Offline-First Architecture — Hive Cache with Auto-Sync', styles['Caption']))

    story.append(PageBreak())

    # ═══════════════════════════════════════
    # PAGE 14: SCREEN NAVIGATION
    # ═══════════════════════════════════════
    story.append(Paragraph('11. Screen Navigation &amp; User Flow', styles['SectionTitle']))
    story.append(HRFlowable(width="100%", thickness=1, color=hex_to_rl(PRIMARY), spaceAfter=8))
    story.append(Paragraph(
        'The application follows a role-adaptive navigation pattern. After role selection, '
        'the dashboard dynamically renders different tab sets based on the user\'s role: '
        'State/District Officials see 6 tabs including validation, Block Officers and Field '
        'Inspectors see 5 tabs with inspection capabilities, and School Head Masters see a '
        'purpose-built 2-tab interface focused on their single school and demand management.',
        styles['BodyText2']
    ))

    img = Image(diagrams['screen_navigation'], width=490, height=365)
    story.append(img)
    story.append(Paragraph('Figure 8: Screen Navigation — Role-Adaptive Dashboard with Detail Screens', styles['Caption']))

    # Build
    doc.build(story, canvasmaker=NumberedCanvas)
    return output_path


def main():
    print("=" * 60)
    print("Vidya Nirmaan — Architecture & Design PDF Generator")
    print("=" * 60)

    print("\n[1/7] Generating System Architecture diagram...")
    d1 = generate_system_architecture()
    print(f"  -> {d1}")

    print("[2/7] Generating ER Diagram...")
    d2 = generate_er_diagram()
    print(f"  -> {d2}")

    print("[3/7] Generating Priority Scoring flowchart...")
    d3 = generate_priority_scoring()
    print(f"  -> {d3}")

    print("[4/7] Generating Validation Pipeline diagram...")
    d4 = generate_validation_pipeline()
    print(f"  -> {d4}")

    print("[5/7] Generating Forecasting Pipeline diagram...")
    d5 = generate_forecasting()
    print(f"  -> {d5}")

    print("[6/7] Generating 3-Stage Pipeline diagram...")
    d6 = generate_three_stage_pipeline()
    print(f"  -> {d6}")

    print("[7/7] Generating additional diagrams...")
    d7 = generate_offline_architecture()
    d8 = generate_screen_navigation()
    print(f"  -> {d7}")
    print(f"  -> {d8}")

    diagrams = {
        'system_architecture': d1,
        'er_diagram': d2,
        'priority_scoring': d3,
        'validation_pipeline': d4,
        'forecasting': d5,
        'three_stage_pipeline': d6,
        'offline_architecture': d7,
        'screen_navigation': d8,
    }

    print("\nAssembling PDF document...")
    output = build_pdf(diagrams)
    file_size = os.path.getsize(output) / (1024 * 1024)
    print(f"\n{'=' * 60}")
    print(f"PDF generated successfully!")
    print(f"  File: {output}")
    print(f"  Size: {file_size:.1f} MB")
    print(f"{'=' * 60}")

    # Cleanup temp files
    import shutil
    shutil.rmtree(TEMP_DIR, ignore_errors=True)

    return output


if __name__ == '__main__':
    main()
