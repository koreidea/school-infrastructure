#!/usr/bin/env python3
"""
Vidya Nirmaan — Pitch Deck Generator
Professional pitch deck for IndiaAI Innovation Challenge (AIkosh) Section 4
Landscape A4 format, ~12 slides
"""

import os
import tempfile
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from matplotlib.patches import FancyBboxPatch, Circle
import numpy as np

from reportlab.lib import colors as rl_colors
from reportlab.lib.pagesizes import A4, landscape
from reportlab.lib.units import inch, mm, cm
from reportlab.lib.enums import TA_CENTER, TA_LEFT, TA_RIGHT
from reportlab.lib.styles import getSampleStyleSheet, ParagraphStyle
from reportlab.platypus import (
    SimpleDocTemplate, Paragraph, Spacer, Image, Table, TableStyle,
    PageBreak, KeepTogether, HRFlowable, Frame, PageTemplate
)
from reportlab.pdfgen import canvas

# ─── Colors ───
PRIMARY = '#1565C0'
PRIMARY_DARK = '#0D47A1'
PRIMARY_LIGHT = '#E3F2FD'
ACCENT = '#00897B'
ORANGE = '#F57C00'
PURPLE = '#7B1FA2'
RED = '#D32F2F'
GREEN = '#4CAF50'
AMBER = '#F9A825'
TEAL = '#00897B'
WHITE = '#FFFFFF'
DARK = '#212121'
GRAY = '#757575'
LIGHT_GRAY = '#F5F5F5'
BG_BLUE = '#0D47A1'
BG_GRADIENT_TOP = '#1565C0'

PAGE_W, PAGE_H = landscape(A4)  # 841.89 x 595.27

TEMP_DIR = tempfile.mkdtemp()

def hex_to_rgb(h):
    h = h.lstrip('#')
    return tuple(int(h[i:i+2], 16)/255.0 for i in (0, 2, 4))

def hex_to_rl(h):
    r, g, b = hex_to_rgb(h)
    return rl_colors.Color(r, g, b)


# ─── Slide Background Canvas ───

class PitchDeckCanvas(canvas.Canvas):
    """Custom canvas for pitch deck with slide backgrounds and page numbers."""
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
            self._draw_footer(num_pages)
            canvas.Canvas.showPage(self)
        canvas.Canvas.save(self)

    def _draw_footer(self, total):
        self.saveState()
        # Bottom bar
        self.setFillColor(hex_to_rl(PRIMARY_DARK))
        self.rect(0, 0, PAGE_W, 25, fill=1, stroke=0)
        # Page number
        self.setFillColor(hex_to_rl(WHITE))
        self.setFont('Helvetica', 8)
        self.drawCentredString(PAGE_W/2, 9, f'Vidya Nirmaan  |  IndiaAI Innovation Challenge  |  {self._pageNumber} / {total}')
        self.restoreState()


# ─── Diagram Generators ───

def generate_problem_visual():
    """Visual showing the problem landscape."""
    fig, ax = plt.subplots(figsize=(10, 4.5))
    ax.set_xlim(0, 10)
    ax.set_ylim(0, 4.5)
    ax.axis('off')
    fig.patch.set_facecolor('white')

    problems = [
        ('Manual\nPaper-Based', 'Demand forms processed\nmanually across 707 mandals', RED, 0.3),
        ('No Fraud\nDetection', 'Demand inflation goes\nundetected, wasting crores', '#E65100', 2.7),
        ('Inequitable\nAllocation', 'No objective prioritization\nof 45,000+ schools', ORANGE, 5.1),
        ('No Future\nPlanning', 'No enrolment forecasting\nfor proactive infra planning', AMBER, 7.5),
    ]

    for label, desc, color, x in problems:
        # Icon circle
        circle = Circle((x+1, 3.2), 0.6, facecolor=hex_to_rgb(color), edgecolor='white', linewidth=2, zorder=3)
        ax.add_patch(circle)
        ax.text(x+1, 3.2, label, ha='center', va='center', fontsize=8, fontweight='bold', color='white', zorder=4)
        # Description
        box = FancyBboxPatch((x+0.05, 1.2), 1.9, 1.2, boxstyle="round,pad=0.08",
                              facecolor='white', edgecolor=hex_to_rgb(color), linewidth=1.5, alpha=0.9)
        ax.add_patch(box)
        ax.text(x+1, 1.8, desc, ha='center', va='center', fontsize=7.5, color='#333', linespacing=1.4)
        # Connector
        ax.plot([x+1, x+1], [2.6, 2.4], color=hex_to_rgb(color), linewidth=2)

    # Bottom stat bar
    bar = FancyBboxPatch((0.5, 0.15), 9, 0.7, boxstyle="round,pad=0.05",
                          facecolor=hex_to_rgb(PRIMARY_DARK), edgecolor='none', alpha=0.9)
    ax.add_patch(bar)
    ax.text(5, 0.5, '45,000+ Schools  |  57 Districts  |  707 Mandals  |  Andhra Pradesh  |  Dept. of School Education',
            ha='center', va='center', fontsize=9, fontweight='bold', color='white')

    path = os.path.join(TEMP_DIR, 'problem_visual.png')
    fig.savefig(path, dpi=200, bbox_inches='tight', facecolor='white')
    plt.close(fig)
    return path


def generate_solution_overview():
    """Visual showing the solution features."""
    fig, ax = plt.subplots(figsize=(10, 5))
    ax.set_xlim(0, 10)
    ax.set_ylim(0, 5)
    ax.axis('off')
    fig.patch.set_facecolor('white')

    # Central app
    center = FancyBboxPatch((3.5, 1.8), 3, 1.5, boxstyle="round,pad=0.1",
                             facecolor=hex_to_rgb(PRIMARY), edgecolor=hex_to_rgb(PRIMARY_DARK), linewidth=2)
    ax.add_patch(center)
    ax.text(5, 2.85, 'Vidya Nirmaan', ha='center', va='center', fontsize=14, fontweight='bold', color='white')
    ax.text(5, 2.45, 'AI-Powered Mobile App', ha='center', va='center', fontsize=9, color=hex_to_rgb(PRIMARY_LIGHT))
    ax.text(5, 2.1, 'Flutter + Supabase + FastAPI', ha='center', va='center', fontsize=8, color=hex_to_rgb(PRIMARY_LIGHT))

    # Surrounding features
    features = [
        ('AI Priority\nScoring', '4-Factor Weighted\n0-100 Composite', PURPLE, 1.2, 4.2),
        ('Fraud\nDetection', 'Isolation Forest\n7 Validation Rules', RED, 4.0, 4.2),
        ('Enrolment\nForecasting', 'Linear Regression\nCohort Progression', ORANGE, 7.0, 4.2),
        ('3-Stage\nApproval', 'AI → Assessment\n→ Officer', TEAL, 8.8, 2.5),
        ('Offline\nFirst', '5 Hive Boxes\nAuto-Sync', GREEN, 7.0, 0.5),
        ('5 User\nRoles', 'State to School\nRBAC Enforced', PRIMARY, 4.0, 0.3),
        ('Bilingual', 'English + Telugu\nFull Localization', AMBER, 1.2, 0.5),
        ('Field\nInspection', '50+ Data Points\nGPS Verified', '#5D4037', 0.0, 2.5),
    ]

    for label, desc, color, x, y in features:
        box = FancyBboxPatch((x-0.1, y-0.1), 2.0, 0.9, boxstyle="round,pad=0.05",
                              facecolor='white', edgecolor=hex_to_rgb(color), linewidth=1.5)
        ax.add_patch(box)
        ax.text(x+0.9, y+0.55, label, ha='center', va='center', fontsize=8, fontweight='bold', color=hex_to_rgb(color))
        ax.text(x+0.9, y+0.18, desc, ha='center', va='center', fontsize=6.5, color='#555', linespacing=1.3)

        # Line to center
        cx, cy = 5, 2.55
        fx, fy = x+0.9, y+0.4
        ax.plot([fx, cx], [fy, cy], color=hex_to_rgb(color), linewidth=0.8, alpha=0.4, linestyle='--')

    path = os.path.join(TEMP_DIR, 'solution_overview.png')
    fig.savefig(path, dpi=200, bbox_inches='tight', facecolor='white')
    plt.close(fig)
    return path


def generate_ai_models():
    """Visual showing the 3 AI/ML models."""
    fig, ax = plt.subplots(figsize=(10, 4.5))
    ax.set_xlim(0, 10)
    ax.set_ylim(0, 4.5)
    ax.axis('off')
    fig.patch.set_facecolor('white')

    models = [
        {
            'title': 'Priority Scoring',
            'subtitle': 'School Prioritization',
            'color': PURPLE,
            'x': 0.2,
            'items': [
                'Enrolment Pressure (30%)',
                'Infrastructure Gap (30%)',
                'CWSN Needs (20%)',
                'Accessibility (20%)',
            ],
            'output': 'Score 0-100\nCRITICAL > HIGH > MEDIUM > LOW',
        },
        {
            'title': 'Demand Validation',
            'subtitle': 'Fraud Detection',
            'color': RED,
            'x': 3.5,
            'items': [
                '7 Rule-Based Checks',
                'Isolation Forest ML',
                'Unit Cost Deviation',
                'Peer Comparison',
            ],
            'output': 'APPROVED (>=80)\nFLAGGED (50-79) | REJECTED (<50)',
        },
        {
            'title': 'Enrolment Forecast',
            'subtitle': '3-Year Prediction',
            'color': ORANGE,
            'x': 6.8,
            'items': [
                'Linear Regression',
                'Cohort Progression',
                'Confidence Decay',
                'Backend + Client Fallback',
            ],
            'output': 'Y1: ~93% conf\nY2: ~85% | Y3: ~76%',
        },
    ]

    for m in models:
        x = m['x']
        color = m['color']
        # Header
        hdr = FancyBboxPatch((x, 3.2), 3.0, 1.0, boxstyle="round,pad=0.05",
                              facecolor=hex_to_rgb(color), edgecolor=hex_to_rgb(color), linewidth=1.5)
        ax.add_patch(hdr)
        ax.text(x+1.5, 3.9, m['title'], ha='center', va='center', fontsize=11, fontweight='bold', color='white')
        ax.text(x+1.5, 3.5, m['subtitle'], ha='center', va='center', fontsize=8.5, color='white', alpha=0.9)

        # Body
        body = FancyBboxPatch((x, 1.2), 3.0, 2.0, boxstyle="round,pad=0.05",
                               facecolor='white', edgecolor=hex_to_rgb(color), linewidth=1.5)
        ax.add_patch(body)
        for i, item in enumerate(m['items']):
            ax.text(x+0.2, 2.9 - i*0.35, f'\u2022  {item}', fontsize=8, color='#333', va='center')

        # Output
        out = FancyBboxPatch((x, 0.2), 3.0, 0.8, boxstyle="round,pad=0.05",
                              facecolor=hex_to_rgb(color), edgecolor=hex_to_rgb(color), linewidth=1, alpha=0.15)
        ax.add_patch(out)
        lines = m['output'].split('\n')
        for i, line in enumerate(lines):
            ax.text(x+1.5, 0.7 - i*0.25, line, ha='center', fontsize=7.5, fontweight='bold',
                    color=hex_to_rgb(color), va='center')

    path = os.path.join(TEMP_DIR, 'ai_models.png')
    fig.savefig(path, dpi=200, bbox_inches='tight', facecolor='white')
    plt.close(fig)
    return path


def generate_pipeline_visual():
    """Visual for the 3-stage approval pipeline."""
    fig, ax = plt.subplots(figsize=(10, 3.5))
    ax.set_xlim(0, 10)
    ax.set_ylim(0, 3.5)
    ax.axis('off')
    fig.patch.set_facecolor('white')

    stages = [
        ('School HM\nRaises Demand', PRIMARY, 0.2),
        ('Stage 1\nAI Validation', PURPLE, 2.7),
        ('Stage 2\nField Assessment', TEAL, 5.2),
        ('Stage 3\nOfficer Decision', ORANGE, 7.7),
    ]

    for label, color, x in stages:
        box = FancyBboxPatch((x, 1.2), 2.0, 1.5, boxstyle="round,pad=0.08",
                              facecolor=hex_to_rgb(color), edgecolor='white', linewidth=2)
        ax.add_patch(box)
        ax.text(x+1.0, 1.95, label, ha='center', va='center', fontsize=10, fontweight='bold', color='white')

    # Arrows between
    for i in range(3):
        x = stages[i][2] + 2.0
        ax.annotate('', xy=(x+0.7, 1.95), xytext=(x, 1.95),
                    arrowprops=dict(arrowstyle='->', lw=2.5, color='#333'))

    # Sub-labels
    sublabels = [
        ('infra_type, qty\namount, year', 1.2, 0.65),
        ('7 Rules + ML\nScore 0-100', 3.7, 0.65),
        ('50+ fields, GPS\nPhoto evidence', 6.2, 0.65),
        ('APPROVE / FLAG\n/ REJECT', 8.7, 0.65),
    ]
    for text, x, y in sublabels:
        ax.text(x, y, text, ha='center', va='center', fontsize=7.5, color='#555', linespacing=1.3)

    # Hard gate
    gate = FancyBboxPatch((5.8, 2.9), 3.5, 0.4, boxstyle="round,pad=0.03",
                           facecolor=hex_to_rgb(RED), edgecolor='none', alpha=0.9)
    ax.add_patch(gate)
    ax.text(7.55, 3.1, 'HARD GATE: Field assessment required before officer approval',
            ha='center', va='center', fontsize=7.5, fontweight='bold', color='white')

    path = os.path.join(TEMP_DIR, 'pipeline_visual.png')
    fig.savefig(path, dpi=200, bbox_inches='tight', facecolor='white')
    plt.close(fig)
    return path


def generate_impact_chart():
    """Bar chart showing impact metrics."""
    fig, axes = plt.subplots(1, 2, figsize=(10, 4))
    fig.patch.set_facecolor('white')

    # Chart 1: Current vs Vidya Nirmaan comparison
    ax1 = axes[0]
    categories = ['Demand\nProcessing', 'Fraud\nDetection', 'School\nPrioritization', 'Forecast\nAccuracy']
    current = [20, 5, 15, 0]
    vidya = [95, 85, 100, 76]

    x = np.arange(len(categories))
    width = 0.35
    bars1 = ax1.bar(x - width/2, current, width, label='Current (Manual)', color=hex_to_rgb(RED), alpha=0.7)
    bars2 = ax1.bar(x + width/2, vidya, width, label='Vidya Nirmaan (AI)', color=hex_to_rgb(PRIMARY), alpha=0.9)

    ax1.set_ylabel('Efficiency %', fontsize=10, fontweight='bold')
    ax1.set_title('Manual vs AI-Powered', fontsize=12, fontweight='bold', color=hex_to_rgb(PRIMARY_DARK))
    ax1.set_xticks(x)
    ax1.set_xticklabels(categories, fontsize=8)
    ax1.set_ylim(0, 110)
    ax1.legend(fontsize=8)
    ax1.spines['top'].set_visible(False)
    ax1.spines['right'].set_visible(False)

    # Add value labels
    for bar in bars1:
        h = bar.get_height()
        ax1.text(bar.get_x() + bar.get_width()/2., h + 2, f'{int(h)}%', ha='center', fontsize=7, color='#555')
    for bar in bars2:
        h = bar.get_height()
        ax1.text(bar.get_x() + bar.get_width()/2., h + 2, f'{int(h)}%', ha='center', fontsize=7, fontweight='bold', color=hex_to_rgb(PRIMARY_DARK))

    # Chart 2: Scale potential
    ax2 = axes[1]
    phases = ['Pilot\n(Current)', 'Phase 1\n(Year 1)', 'Phase 2\n(Year 2)', 'Phase 3\n(Year 3)']
    schools = [319, 5000, 20000, 45000]
    colors_bar = [hex_to_rgb(PRIMARY), hex_to_rgb(TEAL), hex_to_rgb(ORANGE), hex_to_rgb(GREEN)]

    bars = ax2.bar(phases, schools, color=colors_bar, alpha=0.85, edgecolor='white', linewidth=1.5)
    ax2.set_ylabel('Schools Covered', fontsize=10, fontweight='bold')
    ax2.set_title('Scalability Roadmap', fontsize=12, fontweight='bold', color=hex_to_rgb(PRIMARY_DARK))
    ax2.spines['top'].set_visible(False)
    ax2.spines['right'].set_visible(False)

    for bar, val in zip(bars, schools):
        h = bar.get_height()
        ax2.text(bar.get_x() + bar.get_width()/2., h + 800, f'{val:,}', ha='center', fontsize=9, fontweight='bold', color=hex_to_rgb(PRIMARY_DARK))

    plt.tight_layout(pad=2)
    path = os.path.join(TEMP_DIR, 'impact_chart.png')
    fig.savefig(path, dpi=200, bbox_inches='tight', facecolor='white')
    plt.close(fig)
    return path


def generate_tech_stack_visual():
    """Visual showing tech stack layers."""
    fig, ax = plt.subplots(figsize=(10, 4))
    ax.set_xlim(0, 10)
    ax.set_ylim(0, 4)
    ax.axis('off')
    fig.patch.set_facecolor('white')

    layers = [
        ('Mobile App', 'Flutter 3.10+  |  Riverpod 3.x  |  fl_chart  |  flutter_map  |  Material Design 3', PRIMARY, 3.0),
        ('State Management', 'Riverpod Notifier/AsyncValue  |  Role-Based Provider Scoping  |  Offline Fallback Chain', '#1976D2', 2.2),
        ('Backend', 'Supabase (PostgreSQL + RLS + Auth)  |  FastAPI ML (Railway Cloud)  |  scikit-learn', GREEN, 1.4),
        ('Offline Layer', 'Hive (5 Boxes)  |  Auto-Sync  |  Queue & Retry  |  Graceful Degradation', TEAL, 0.6),
    ]

    for label, desc, color, y in layers:
        box = FancyBboxPatch((0.3, y), 9.4, 0.65, boxstyle="round,pad=0.05",
                              facecolor=hex_to_rgb(color), edgecolor='white', linewidth=2, alpha=0.9)
        ax.add_patch(box)
        ax.text(1.5, y+0.33, label, va='center', fontsize=10, fontweight='bold', color='white')
        ax.text(4.0, y+0.33, desc, va='center', fontsize=8, color='white', alpha=0.9)

    path = os.path.join(TEMP_DIR, 'tech_stack.png')
    fig.savefig(path, dpi=200, bbox_inches='tight', facecolor='white')
    plt.close(fig)
    return path


# ─── PDF Builder ───

def build_pitch_deck(diagrams):
    output_path = os.path.join(os.path.dirname(os.path.abspath(__file__)),
                                'Vidya_Nirmaan_Pitch_Deck.pdf')

    doc = SimpleDocTemplate(
        output_path, pagesize=landscape(A4),
        topMargin=35, bottomMargin=40,
        leftMargin=45, rightMargin=45
    )

    styles = getSampleStyleSheet()

    # Slide styles
    styles.add(ParagraphStyle('SlideTitle', parent=styles['Title'],
        fontSize=28, leading=34, textColor=hex_to_rl(PRIMARY_DARK),
        alignment=TA_LEFT, spaceAfter=4, fontName='Helvetica-Bold'))

    styles.add(ParagraphStyle('SlideTitleCenter', parent=styles['Title'],
        fontSize=28, leading=34, textColor=hex_to_rl(PRIMARY_DARK),
        alignment=TA_CENTER, spaceAfter=4, fontName='Helvetica-Bold'))

    styles.add(ParagraphStyle('SlideSubtitle', parent=styles['Normal'],
        fontSize=14, leading=20, textColor=hex_to_rl(PRIMARY),
        alignment=TA_LEFT, spaceAfter=10))

    styles.add(ParagraphStyle('SlideSubCenter', parent=styles['Normal'],
        fontSize=14, leading=20, textColor=hex_to_rl(PRIMARY),
        alignment=TA_CENTER, spaceAfter=10))

    styles.add(ParagraphStyle('SlideBody', parent=styles['Normal'],
        fontSize=12, leading=17, textColor=hex_to_rl(DARK),
        spaceAfter=6))

    styles.add(ParagraphStyle('SlideBullet', parent=styles['Normal'],
        fontSize=12, leading=17, textColor=hex_to_rl(DARK),
        bulletIndent=20, leftIndent=40, spaceAfter=4))

    styles.add(ParagraphStyle('BigNumber', parent=styles['Normal'],
        fontSize=36, leading=42, textColor=hex_to_rl(PRIMARY),
        alignment=TA_CENTER, fontName='Helvetica-Bold'))

    styles.add(ParagraphStyle('BigLabel', parent=styles['Normal'],
        fontSize=11, leading=14, textColor=hex_to_rl(GRAY),
        alignment=TA_CENTER, spaceAfter=8))

    styles.add(ParagraphStyle('CoverTitle', parent=styles['Title'],
        fontSize=40, leading=48, textColor=hex_to_rl(PRIMARY_DARK),
        alignment=TA_CENTER, fontName='Helvetica-Bold'))

    styles.add(ParagraphStyle('CoverSub', parent=styles['Normal'],
        fontSize=18, leading=24, textColor=hex_to_rl(PRIMARY),
        alignment=TA_CENTER, spaceAfter=6))

    styles.add(ParagraphStyle('CoverInfo', parent=styles['Normal'],
        fontSize=12, leading=16, textColor=hex_to_rl(GRAY),
        alignment=TA_CENTER, spaceAfter=4))

    styles.add(ParagraphStyle('SectionLabel', parent=styles['Normal'],
        fontSize=10, leading=13, textColor=hex_to_rl(ORANGE),
        fontName='Helvetica-Bold', spaceAfter=2))

    styles.add(ParagraphStyle('QuoteText', parent=styles['Normal'],
        fontSize=14, leading=20, textColor=hex_to_rl(DARK),
        alignment=TA_CENTER, fontName='Helvetica-Oblique', spaceAfter=8))

    story = []

    # ═══════════════════════════════════════
    # SLIDE 1: COVER
    # ═══════════════════════════════════════
    story.append(Spacer(1, 80))
    story.append(Paragraph('Vidya Nirmaan', styles['CoverTitle']))
    story.append(Spacer(1, 8))
    story.append(Paragraph('AI-Powered School Infrastructure Planning &amp; Monitoring', styles['CoverSub']))
    story.append(Spacer(1, 15))
    story.append(HRFlowable(width="40%", thickness=3, color=hex_to_rl(ORANGE), spaceAfter=15, spaceBefore=5))
    story.append(Paragraph('IndiaAI Innovation Challenge — Problem Statement 5', ParagraphStyle(
        'CoverBadge', parent=styles['Normal'], fontSize=14, textColor=hex_to_rl(ORANGE),
        alignment=TA_CENTER, fontName='Helvetica-Bold', spaceAfter=8)))
    story.append(Paragraph('Department of School Education, Andhra Pradesh', styles['CoverInfo']))
    story.append(Spacer(1, 30))

    # Cover metrics row
    cover_metrics = [
        ['319', '57', '707', '3', '5'],
        ['Schools', 'Districts', 'Mandals', 'AI Models', 'User Roles'],
    ]
    cm_table = Table(cover_metrics, colWidths=[130]*5)
    cm_table.setStyle(TableStyle([
        ('FONTNAME', (0, 0), (-1, 0), 'Helvetica-Bold'),
        ('FONTSIZE', (0, 0), (-1, 0), 26),
        ('TEXTCOLOR', (0, 0), (-1, 0), hex_to_rl(PRIMARY)),
        ('FONTSIZE', (0, 1), (-1, 1), 10),
        ('TEXTCOLOR', (0, 1), (-1, 1), hex_to_rl(GRAY)),
        ('ALIGN', (0, 0), (-1, -1), 'CENTER'),
        ('BOTTOMPADDING', (0, 0), (-1, 0), 2),
        ('TOPPADDING', (0, 1), (-1, 1), 0),
    ]))
    story.append(cm_table)
    story.append(Spacer(1, 30))
    story.append(Paragraph('March 2026  |  Flutter + Supabase + FastAPI  |  Offline-First Mobile App', styles['CoverInfo']))

    story.append(PageBreak())

    # ═══════════════════════════════════════
    # SLIDE 2: THE PROBLEM
    # ═══════════════════════════════════════
    story.append(Paragraph('THE PROBLEM', styles['SectionLabel']))
    story.append(Paragraph('School Infrastructure Planning is Broken', styles['SlideTitle']))
    story.append(Paragraph(
        'Andhra Pradesh manages 45,000+ government schools with manual, paper-based infrastructure planning. '
        'No automated fraud detection, no objective prioritization, no future-readiness.',
        styles['SlideSubtitle']))
    story.append(Spacer(1, 5))

    img = Image(diagrams['problem'], width=680, height=305)
    story.append(img)

    story.append(PageBreak())

    # ═══════════════════════════════════════
    # SLIDE 3: THE SOLUTION
    # ═══════════════════════════════════════
    story.append(Paragraph('OUR SOLUTION', styles['SectionLabel']))
    story.append(Paragraph('Vidya Nirmaan — End-to-End AI Platform', styles['SlideTitle']))
    story.append(Paragraph(
        'A mobile-first application that digitizes the entire infrastructure lifecycle: '
        'demand → validation → assessment → approval, powered by 3 AI/ML models.',
        styles['SlideSubtitle']))

    img = Image(diagrams['solution'], width=680, height=340)
    story.append(img)

    story.append(PageBreak())

    # ═══════════════════════════════════════
    # SLIDE 4: HOW IT WORKS
    # ═══════════════════════════════════════
    story.append(Paragraph('HOW IT WORKS', styles['SectionLabel']))
    story.append(Paragraph('3-Stage Demand Approval Pipeline', styles['SlideTitle']))
    story.append(Paragraph(
        'Every infrastructure demand passes through AI validation, field verification, and officer approval. '
        'A hard gate ensures no demand is approved without ground-truth inspection.',
        styles['SlideSubtitle']))
    story.append(Spacer(1, 5))

    img = Image(diagrams['pipeline'], width=700, height=245)
    story.append(img)

    story.append(Spacer(1, 20))

    # Key differentiators
    diff_data = [
        ['AI-First Validation', 'Ground-Truth Verification', 'Officer Oversight', 'Full Audit Trail'],
        ['7 automated rules +\nIsolation Forest ML',
         '50+ inspection fields\nwith GPS verification',
         'Manual approve/flag/reject\nwith notes',
         'Every stage timestamped\nand tracked'],
    ]
    diff_table = Table(diff_data, colWidths=[175]*4)
    diff_table.setStyle(TableStyle([
        ('FONTNAME', (0, 0), (-1, 0), 'Helvetica-Bold'),
        ('FONTSIZE', (0, 0), (-1, 0), 11),
        ('TEXTCOLOR', (0, 0), (-1, 0), hex_to_rl(PRIMARY_DARK)),
        ('FONTSIZE', (0, 1), (-1, 1), 9),
        ('TEXTCOLOR', (0, 1), (-1, 1), hex_to_rl(GRAY)),
        ('ALIGN', (0, 0), (-1, -1), 'CENTER'),
        ('VALIGN', (0, 0), (-1, -1), 'TOP'),
        ('BOTTOMPADDING', (0, 0), (-1, -1), 6),
        ('TOPPADDING', (0, 1), (-1, 1), 4),
        ('LINEABOVE', (0, 0), (-1, 0), 2, hex_to_rl(PRIMARY)),
    ]))
    story.append(diff_table)

    story.append(PageBreak())

    # ═══════════════════════════════════════
    # SLIDE 5: AI / ML MODELS
    # ═══════════════════════════════════════
    story.append(Paragraph('AI / ML INNOVATION', styles['SectionLabel']))
    story.append(Paragraph('Three AI Models Working in Concert', styles['SlideTitle']))
    story.append(Paragraph(
        'Client-side + backend ML: priority scoring for objective allocation, '
        'Isolation Forest for fraud detection, dual-model forecasting for future planning.',
        styles['SlideSubtitle']))

    img = Image(diagrams['ai_models'], width=690, height=310)
    story.append(img)

    story.append(PageBreak())

    # ═══════════════════════════════════════
    # SLIDE 6: TECHNOLOGY
    # ═══════════════════════════════════════
    story.append(Paragraph('TECHNOLOGY', styles['SectionLabel']))
    story.append(Paragraph('Modern, Scalable Architecture', styles['SlideTitle']))
    story.append(Spacer(1, 5))

    img = Image(diagrams['tech_stack'], width=690, height=275)
    story.append(img)

    story.append(Spacer(1, 15))

    # Tech highlights
    tech_highlights = [
        ['Cross-Platform', 'Real-Time Backend', 'ML Pipeline', 'Offline-First'],
        ['Single codebase for\niOS + Android',
         'Supabase PostgreSQL\nwith Row Level Security',
         'scikit-learn models on\nRailway cloud',
         'Hive local storage\nwith auto-sync'],
        ['Flutter + Dart', 'Supabase + RLS', 'FastAPI + Python', 'Hive + Queue'],
    ]
    tech_table = Table(tech_highlights, colWidths=[175]*4)
    tech_table.setStyle(TableStyle([
        ('FONTNAME', (0, 0), (-1, 0), 'Helvetica-Bold'),
        ('FONTSIZE', (0, 0), (-1, 0), 11),
        ('TEXTCOLOR', (0, 0), (-1, 0), hex_to_rl(PRIMARY_DARK)),
        ('FONTSIZE', (0, 1), (-1, 1), 9),
        ('TEXTCOLOR', (0, 1), (-1, 1), hex_to_rl(DARK)),
        ('FONTSIZE', (0, 2), (-1, 2), 8),
        ('TEXTCOLOR', (0, 2), (-1, 2), hex_to_rl(GRAY)),
        ('FONTNAME', (0, 2), (-1, 2), 'Helvetica-Oblique'),
        ('ALIGN', (0, 0), (-1, -1), 'CENTER'),
        ('VALIGN', (0, 0), (-1, -1), 'TOP'),
        ('BOTTOMPADDING', (0, 0), (-1, -1), 5),
        ('LINEABOVE', (0, 0), (-1, 0), 2, hex_to_rl(PRIMARY)),
    ]))
    story.append(tech_table)

    story.append(PageBreak())

    # ═══════════════════════════════════════
    # SLIDE 7: KEY METRICS
    # ═══════════════════════════════════════
    story.append(Paragraph('BY THE NUMBERS', styles['SectionLabel']))
    story.append(Paragraph('Platform at a Glance', styles['SlideTitle']))
    story.append(Spacer(1, 15))

    # Big metrics grid
    metrics_row1 = [
        ['319', '4,638', '799', '50+'],
        ['Schools in\nPilot Dataset', 'Enrolment Records\nAnalyzed', 'Demand Plans\nValidated', 'Inspection\nData Points'],
    ]
    m1_table = Table(metrics_row1, colWidths=[175]*4)
    m1_table.setStyle(TableStyle([
        ('FONTNAME', (0, 0), (-1, 0), 'Helvetica-Bold'),
        ('FONTSIZE', (0, 0), (-1, 0), 32),
        ('TEXTCOLOR', (0, 0), (-1, 0), hex_to_rl(PRIMARY)),
        ('FONTSIZE', (0, 1), (-1, 1), 10),
        ('TEXTCOLOR', (0, 1), (-1, 1), hex_to_rl(GRAY)),
        ('ALIGN', (0, 0), (-1, -1), 'CENTER'),
        ('BOTTOMPADDING', (0, 0), (-1, 0), 4),
        ('TOPPADDING', (0, 1), (-1, 1), 0),
    ]))
    story.append(m1_table)
    story.append(Spacer(1, 25))

    metrics_row2 = [
        ['7', '3', '5', '2'],
        ['Validation Rules\n+ Isolation Forest', 'AI/ML Models\nDeployed', 'User Roles with\nRBAC Enforcement', 'Languages\nEN + Telugu'],
    ]
    m2_table = Table(metrics_row2, colWidths=[175]*4)
    m2_table.setStyle(TableStyle([
        ('FONTNAME', (0, 0), (-1, 0), 'Helvetica-Bold'),
        ('FONTSIZE', (0, 0), (-1, 0), 32),
        ('TEXTCOLOR', (0, 0), (-1, 0), hex_to_rl(ORANGE)),
        ('FONTSIZE', (0, 1), (-1, 1), 10),
        ('TEXTCOLOR', (0, 1), (-1, 1), hex_to_rl(GRAY)),
        ('ALIGN', (0, 0), (-1, -1), 'CENTER'),
        ('BOTTOMPADDING', (0, 0), (-1, 0), 4),
        ('TOPPADDING', (0, 1), (-1, 1), 0),
    ]))
    story.append(m2_table)
    story.append(Spacer(1, 25))

    metrics_row3 = [
        ['100%', '< 2s', '0', '45,000+'],
        ['Offline Capable\nFull Functionality', 'AI Validation\nResponse Time', 'Manual Steps in\nFraud Detection', 'Schools\nScalability Target'],
    ]
    m3_table = Table(metrics_row3, colWidths=[175]*4)
    m3_table.setStyle(TableStyle([
        ('FONTNAME', (0, 0), (-1, 0), 'Helvetica-Bold'),
        ('FONTSIZE', (0, 0), (-1, 0), 32),
        ('TEXTCOLOR', (0, 0), (-1, 0), hex_to_rl(TEAL)),
        ('FONTSIZE', (0, 1), (-1, 1), 10),
        ('TEXTCOLOR', (0, 1), (-1, 1), hex_to_rl(GRAY)),
        ('ALIGN', (0, 0), (-1, -1), 'CENTER'),
        ('BOTTOMPADDING', (0, 0), (-1, 0), 4),
        ('TOPPADDING', (0, 1), (-1, 1), 0),
    ]))
    story.append(m3_table)

    story.append(PageBreak())

    # ═══════════════════════════════════════
    # SLIDE 8: IMPACT & SCALABILITY
    # ═══════════════════════════════════════
    story.append(Paragraph('IMPACT &amp; SCALABILITY', styles['SectionLabel']))
    story.append(Paragraph('Transforming Infrastructure Planning', styles['SlideTitle']))
    story.append(Spacer(1, 5))

    img = Image(diagrams['impact'], width=690, height=275)
    story.append(img)

    story.append(Spacer(1, 15))

    impact_data = [
        ['Reduced Processing Time', 'Automated Fraud Detection', 'Objective Prioritization', 'Proactive Planning'],
        ['From weeks to seconds\nwith AI validation',
         'Isolation Forest catches\nanomalies humans miss',
         '4-factor scoring replaces\nsubjective decisions',
         '3-year forecasts enable\nproactive investment'],
    ]
    impact_table = Table(impact_data, colWidths=[175]*4)
    impact_table.setStyle(TableStyle([
        ('FONTNAME', (0, 0), (-1, 0), 'Helvetica-Bold'),
        ('FONTSIZE', (0, 0), (-1, 0), 10),
        ('TEXTCOLOR', (0, 0), (-1, 0), hex_to_rl(PRIMARY_DARK)),
        ('FONTSIZE', (0, 1), (-1, 1), 9),
        ('TEXTCOLOR', (0, 1), (-1, 1), hex_to_rl(GRAY)),
        ('ALIGN', (0, 0), (-1, -1), 'CENTER'),
        ('VALIGN', (0, 0), (-1, -1), 'TOP'),
        ('LINEABOVE', (0, 0), (-1, 0), 2, hex_to_rl(GREEN)),
    ]))
    story.append(impact_table)

    story.append(PageBreak())

    # ═══════════════════════════════════════
    # SLIDE 9: RESPONSIBLE AI
    # ═══════════════════════════════════════
    story.append(Paragraph('RESPONSIBLE AI', styles['SectionLabel']))
    story.append(Paragraph('Ethical, Transparent, Accountable', styles['SlideTitle']))
    story.append(Spacer(1, 10))

    rai_data = [
        ['Principle', 'Implementation'],
        ['Transparency', 'All AI decisions show detailed rule-by-rule breakdown with scores. Officers see exactly why a demand was approved, flagged, or rejected.'],
        ['Human Oversight', '3-stage pipeline ensures human officers make final decisions. AI assists but never auto-approves without assessment + officer review.'],
        ['Fairness', 'Objective 4-factor scoring algorithm treats all schools equally. No geographic or administrative bias in prioritization.'],
        ['Privacy', 'No personal student data collected. Only aggregate enrolment counts. Supabase Row Level Security enforces data access boundaries.'],
        ['Accountability', 'Full audit trail: every validation, assessment, and officer decision is timestamped with the officer name and justification notes.'],
        ['Inclusivity', 'CWSN (Children With Special Needs) weighted at 20% in priority scoring. Bilingual interface (English + Telugu) for accessibility.'],
        ['Offline Equity', 'Full offline-first design ensures rural schools with poor connectivity are not disadvantaged. Auto-sync when connected.'],
    ]
    rai_table = Table(rai_data, colWidths=[120, 590])
    rai_table.setStyle(TableStyle([
        ('BACKGROUND', (0, 0), (-1, 0), hex_to_rl(PRIMARY)),
        ('TEXTCOLOR', (0, 0), (-1, 0), rl_colors.white),
        ('FONTNAME', (0, 0), (-1, 0), 'Helvetica-Bold'),
        ('FONTNAME', (0, 1), (0, -1), 'Helvetica-Bold'),
        ('FONTSIZE', (0, 0), (-1, -1), 9.5),
        ('TEXTCOLOR', (0, 1), (0, -1), hex_to_rl(PRIMARY)),
        ('BOTTOMPADDING', (0, 0), (-1, -1), 7),
        ('TOPPADDING', (0, 0), (-1, -1), 7),
        ('GRID', (0, 0), (-1, -1), 0.5, hex_to_rl(LIGHT_GRAY)),
        ('ROWBACKGROUNDS', (0, 1), (-1, -1), [rl_colors.white, hex_to_rl('#F8F9FA')]),
        ('VALIGN', (0, 0), (-1, -1), 'MIDDLE'),
    ]))
    story.append(rai_table)

    story.append(PageBreak())

    # ═══════════════════════════════════════
    # SLIDE 10: DATA GOVERNANCE
    # ═══════════════════════════════════════
    story.append(Paragraph('DATA GOVERNANCE', styles['SectionLabel']))
    story.append(Paragraph('Secure, Compliant, Role-Scoped', styles['SlideTitle']))
    story.append(Spacer(1, 10))

    dg_data = [
        ['Aspect', 'Approach', 'Details'],
        ['Data Source', 'Government Official Data', 'UDISE+ school database, Samagra Shiksha norms, AP Dept. of Education records'],
        ['Access Control', '5-Role RBAC', 'State Official sees all; District Officer sees district; Block Officer/Inspector sees mandal; HM sees own school only'],
        ['Database Security', 'Row Level Security', 'Supabase PostgreSQL RLS policies enforce data isolation per user role at the database level'],
        ['Encryption', 'In-Transit + At-Rest', 'HTTPS for all API calls. Supabase provides AES-256 encryption at rest. JWT auth tokens for sessions'],
        ['Data Minimization', 'Aggregate Only', 'No personal student data (names, IDs). Only aggregate enrolment counts (boys, girls, total per grade)'],
        ['Offline Security', 'Local-Only Cache', 'Hive cache stored on device only. No cross-device data sharing. Cache cleared on logout'],
        ['Audit Logging', 'Full Traceability', 'Every validation, assessment, and officer decision recorded with timestamp, officer name, and justification'],
        ['Consent', 'Government Authorization', 'Data usage authorized under IndiaAI Innovation Challenge. No third-party data sharing'],
    ]
    dg_table = Table(dg_data, colWidths=[110, 130, 470])
    dg_table.setStyle(TableStyle([
        ('BACKGROUND', (0, 0), (-1, 0), hex_to_rl(TEAL)),
        ('TEXTCOLOR', (0, 0), (-1, 0), rl_colors.white),
        ('FONTNAME', (0, 0), (-1, 0), 'Helvetica-Bold'),
        ('FONTNAME', (0, 1), (0, -1), 'Helvetica-Bold'),
        ('FONTNAME', (1, 1), (1, -1), 'Helvetica-Bold'),
        ('FONTSIZE', (0, 0), (-1, -1), 9),
        ('TEXTCOLOR', (0, 1), (0, -1), hex_to_rl(TEAL)),
        ('TEXTCOLOR', (1, 1), (1, -1), hex_to_rl(DARK)),
        ('BOTTOMPADDING', (0, 0), (-1, -1), 6),
        ('TOPPADDING', (0, 0), (-1, -1), 6),
        ('GRID', (0, 0), (-1, -1), 0.5, hex_to_rl(LIGHT_GRAY)),
        ('ROWBACKGROUNDS', (0, 1), (-1, -1), [rl_colors.white, hex_to_rl('#E0F2F1')]),
        ('VALIGN', (0, 0), (-1, -1), 'MIDDLE'),
    ]))
    story.append(dg_table)

    story.append(PageBreak())

    # ═══════════════════════════════════════
    # SLIDE 11: TEAM
    # ═══════════════════════════════════════
    story.append(Paragraph('THE TEAM', styles['SectionLabel']))
    story.append(Paragraph('Built by Engineers Who Ship', styles['SlideTitle']))
    story.append(Spacer(1, 20))

    team_data = [
        ['Role', 'Focus Area', 'Expertise'],
        ['CEO', 'Product Vision & Architecture', 'End-to-end product development, Mech Engg background, AI/ML, Mobile & Cloud'],
        ['COO', 'Operations & Strategy', 'Business operations, government project coordination, strategic planning'],
        ['CTO', 'Technical Lead', 'Full-stack engineering, system architecture, ML pipeline development'],
        ['Lead Engineer', 'Full-Stack Development', 'Full-stack engineering, 5+ years experience, frontend & backend'],
    ]
    team_table = Table(team_data, colWidths=[110, 180, 420])
    team_table.setStyle(TableStyle([
        ('BACKGROUND', (0, 0), (-1, 0), hex_to_rl(PRIMARY_DARK)),
        ('TEXTCOLOR', (0, 0), (-1, 0), rl_colors.white),
        ('FONTNAME', (0, 0), (-1, 0), 'Helvetica-Bold'),
        ('FONTNAME', (0, 1), (0, -1), 'Helvetica-Bold'),
        ('FONTSIZE', (0, 0), (-1, -1), 11),
        ('TEXTCOLOR', (0, 1), (0, -1), hex_to_rl(PRIMARY)),
        ('BOTTOMPADDING', (0, 0), (-1, -1), 12),
        ('TOPPADDING', (0, 0), (-1, -1), 12),
        ('GRID', (0, 0), (-1, -1), 0.5, hex_to_rl(LIGHT_GRAY)),
        ('ROWBACKGROUNDS', (0, 1), (-1, -1), [rl_colors.white, hex_to_rl('#F8F9FA')]),
        ('VALIGN', (0, 0), (-1, -1), 'MIDDLE'),
    ]))
    story.append(team_table)

    story.append(Spacer(1, 30))

    story.append(Paragraph(
        '<b>Organization:</b> EdTech startup focused on AI-powered solutions for government education — '
        'school infrastructure (Vidya Nirmaan), early childhood development (ECD monitoring), '
        'and personalized learning companions for children.',
        ParagraphStyle('TeamDesc', parent=styles['Normal'], fontSize=11, leading=16,
                       textColor=hex_to_rl(GRAY), alignment=TA_CENTER)
    ))

    story.append(PageBreak())

    # ═══════════════════════════════════════
    # SLIDE 12: CLOSING / CTA
    # ═══════════════════════════════════════
    story.append(Spacer(1, 60))
    story.append(Paragraph('Vidya Nirmaan', styles['CoverTitle']))
    story.append(Spacer(1, 10))
    story.append(Paragraph(
        'Transforming school infrastructure planning from manual paper-based workflows<br/>'
        'to an AI-powered, transparent, accountable, and equitable system.',
        styles['QuoteText']))
    story.append(Spacer(1, 20))
    story.append(HRFlowable(width="30%", thickness=3, color=hex_to_rl(ORANGE), spaceAfter=20, spaceBefore=5))

    closing_metrics = [
        ['3 AI Models', '7 Validation Rules', '5 User Roles', 'Offline-First'],
        ['Priority Scoring\nValidation\nForecasting',
         'Rule-Based +\nIsolation Forest ML',
         'State to School\nRole-Based Access',
         'Works Without\nInternet'],
    ]
    cm_table = Table(closing_metrics, colWidths=[165]*4)
    cm_table.setStyle(TableStyle([
        ('FONTNAME', (0, 0), (-1, 0), 'Helvetica-Bold'),
        ('FONTSIZE', (0, 0), (-1, 0), 14),
        ('TEXTCOLOR', (0, 0), (-1, 0), hex_to_rl(PRIMARY_DARK)),
        ('FONTSIZE', (0, 1), (-1, 1), 9),
        ('TEXTCOLOR', (0, 1), (-1, 1), hex_to_rl(GRAY)),
        ('ALIGN', (0, 0), (-1, -1), 'CENTER'),
        ('VALIGN', (0, 0), (-1, -1), 'TOP'),
        ('BOTTOMPADDING', (0, 0), (-1, -1), 6),
        ('LINEABOVE', (0, 0), (-1, 0), 2, hex_to_rl(PRIMARY)),
    ]))
    story.append(cm_table)

    story.append(Spacer(1, 40))
    story.append(Paragraph(
        '<b>Ready for Pilot Deployment Across Andhra Pradesh</b>',
        ParagraphStyle('ReadyText', parent=styles['Normal'], fontSize=16,
                       textColor=hex_to_rl(GREEN), alignment=TA_CENTER, fontName='Helvetica-Bold')))
    story.append(Spacer(1, 10))
    story.append(Paragraph(
        'iOS + Android  |  English + Telugu  |  Built for 45,000+ Schools',
        styles['CoverInfo']))

    # Build
    doc.build(story, canvasmaker=PitchDeckCanvas)
    return output_path


def main():
    print("=" * 60)
    print("Vidya Nirmaan — Pitch Deck Generator")
    print("=" * 60)

    print("\n[1/6] Generating problem visual...")
    d1 = generate_problem_visual()
    print(f"  -> {d1}")

    print("[2/6] Generating solution overview...")
    d2 = generate_solution_overview()
    print(f"  -> {d2}")

    print("[3/6] Generating AI models visual...")
    d3 = generate_ai_models()
    print(f"  -> {d3}")

    print("[4/6] Generating pipeline visual...")
    d4 = generate_pipeline_visual()
    print(f"  -> {d4}")

    print("[5/6] Generating impact charts...")
    d5 = generate_impact_chart()
    print(f"  -> {d5}")

    print("[6/6] Generating tech stack visual...")
    d6 = generate_tech_stack_visual()
    print(f"  -> {d6}")

    diagrams = {
        'problem': d1,
        'solution': d2,
        'ai_models': d3,
        'pipeline': d4,
        'impact': d5,
        'tech_stack': d6,
    }

    print("\nAssembling Pitch Deck PDF...")
    output = build_pitch_deck(diagrams)
    file_size = os.path.getsize(output) / (1024 * 1024)
    print(f"\n{'=' * 60}")
    print(f"Pitch Deck generated successfully!")
    print(f"  File: {output}")
    print(f"  Size: {file_size:.1f} MB")
    print(f"{'=' * 60}")

    import shutil
    shutil.rmtree(TEMP_DIR, ignore_errors=True)
    return output


if __name__ == '__main__':
    main()
