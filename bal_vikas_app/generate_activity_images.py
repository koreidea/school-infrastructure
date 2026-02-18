#!/usr/bin/env python3
"""Generate placeholder activity images for Bal Vikas ECD app."""

from PIL import Image, ImageDraw, ImageFont
import os
import math

OUTPUT_DIR = "assets/images/activities"

# Activity definitions: (code, title, domain, emoji_symbol)
ACTIVITIES = [
    # Gross Motor
    ("GM_001", "Tummy Time\nPlay", "gm", "baby"),
    ("GM_002", "Ball Games", "gm", "ball"),
    ("GM_003", "Jumping\nExercises", "gm", "jump"),
    ("GM_004", "Obstacle\nCourse", "gm", "obstacle"),
    ("GM_005", "Crawling\nPractice", "gm", "crawl"),
    ("GM_006", "Walking\nSupport", "gm", "walk"),
    # Fine Motor
    ("FM_001", "Block\nStacking", "fm", "blocks"),
    ("FM_002", "Drawing &\nColoring", "fm", "draw"),
    ("FM_003", "Puzzle\nSolving", "fm", "puzzle"),
    ("FM_004", "Play Dough", "fm", "dough"),
    ("FM_005", "Bead\nThreading", "fm", "beads"),
    ("FM_006", "Scissor\nPractice", "fm", "scissor"),
    # Language & Cognition
    ("LC_001", "Picture Book\nReading", "lc", "book"),
    ("LC_002", "Storytelling\nTime", "lc", "story"),
    ("LC_003", "Word Games", "lc", "words"),
    ("LC_004", "Nursery\nRhymes", "lc", "rhymes"),
    ("LC_005", "Daily\nConversation", "lc", "talk"),
    ("LC_006", "Name\nLabeling", "lc", "label"),
    # Cognitive
    ("COG_001", "Sorting\nGames", "cog", "sort"),
    ("COG_002", "Pretend\nPlay", "cog", "pretend"),
    ("COG_003", "Matching\nGames", "cog", "match"),
    ("COG_004", "Hide and\nSeek", "cog", "hide"),
    ("COG_005", "Counting\nGames", "cog", "count"),
    ("COG_006", "Building\nwith Blocks", "cog", "build"),
    # Social-Emotional
    ("SE_001", "Play Dates", "se", "playdate"),
    ("SE_002", "Sharing\nActivities", "se", "share"),
    ("SE_003", "Emotion\nRecognition", "se", "emotion"),
    ("SE_004", "Role Play", "se", "role"),
    ("SE_005", "Cooperative\nGames", "se", "coop"),
    ("SE_006", "Daily\nRoutines", "se", "routine"),
]

# Domain colors (RGB)
DOMAIN_COLORS = {
    "gm": (33, 150, 243),    # Blue
    "fm": (76, 175, 80),     # Green
    "lc": (255, 152, 0),     # Orange
    "cog": (156, 39, 176),   # Purple
    "se": (233, 30, 99),     # Pink
}

DOMAIN_LIGHT = {
    "gm": (227, 242, 253),
    "fm": (232, 245, 233),
    "lc": (255, 243, 224),
    "cog": (243, 229, 245),
    "se": (252, 228, 236),
}

# Simple symbolic drawings for each activity type
def draw_activity_symbol(draw, symbol, cx, cy, size, color):
    """Draw a simple icon/symbol for the activity."""
    s = size
    white = (255, 255, 255)

    if symbol == "baby":
        # Baby on tummy - circle head + body
        draw.ellipse([cx-s*0.15, cy-s*0.3, cx+s*0.15, cy-s*0.05], fill=color)
        draw.ellipse([cx-s*0.3, cy-s*0.05, cx+s*0.3, cy+s*0.25], fill=color)
    elif symbol == "ball":
        # Ball
        draw.ellipse([cx-s*0.25, cy-s*0.25, cx+s*0.25, cy+s*0.25], fill=color)
        draw.ellipse([cx-s*0.18, cy-s*0.18, cx+s*0.18, cy+s*0.18], fill=white)
        draw.ellipse([cx-s*0.12, cy-s*0.12, cx+s*0.12, cy+s*0.12], fill=color)
    elif symbol == "jump":
        # Stick figure jumping
        draw.ellipse([cx-s*0.08, cy-s*0.35, cx+s*0.08, cy-s*0.2], fill=color)
        draw.line([cx, cy-s*0.2, cx, cy+s*0.05], fill=color, width=3)
        draw.line([cx, cy-s*0.1, cx-s*0.15, cy-s*0.25], fill=color, width=3)
        draw.line([cx, cy-s*0.1, cx+s*0.15, cy-s*0.25], fill=color, width=3)
        draw.line([cx, cy+s*0.05, cx-s*0.12, cy+s*0.25], fill=color, width=3)
        draw.line([cx, cy+s*0.05, cx+s*0.12, cy+s*0.25], fill=color, width=3)
    elif symbol == "obstacle":
        # Hurdles
        for offset in [-s*0.2, s*0.1]:
            x = cx + offset
            draw.rectangle([x, cy-s*0.1, x+s*0.05, cy+s*0.2], fill=color)
            draw.rectangle([x-s*0.05, cy-s*0.1, x+s*0.1, cy-s*0.05], fill=color)
    elif symbol == "crawl":
        # Baby crawling shape
        draw.ellipse([cx+s*0.05, cy-s*0.2, cx+s*0.22, cy-s*0.05], fill=color)
        draw.ellipse([cx-s*0.25, cy-s*0.1, cx+s*0.1, cy+s*0.15], fill=color)
    elif symbol == "walk":
        # Two feet / footprints
        draw.ellipse([cx-s*0.15, cy-s*0.2, cx-s*0.02, cy+s*0.1], fill=color)
        draw.ellipse([cx+s*0.02, cy-s*0.05, cx+s*0.15, cy+s*0.25], fill=color)
    elif symbol == "blocks":
        # Stacked blocks
        draw.rectangle([cx-s*0.15, cy, cx+s*0.05, cy+s*0.2], fill=color)
        draw.rectangle([cx+s*0.05, cy, cx+s*0.25, cy+s*0.2], fill=color)
        draw.rectangle([cx-s*0.05, cy-s*0.2, cx+s*0.15, cy], fill=color)
    elif symbol == "draw":
        # Pencil
        draw.line([cx-s*0.2, cy+s*0.2, cx+s*0.15, cy-s*0.15], fill=color, width=4)
        draw.polygon([(cx+s*0.15, cy-s*0.15), (cx+s*0.22, cy-s*0.22), (cx+s*0.18, cy-s*0.08)], fill=color)
    elif symbol == "puzzle":
        # Puzzle piece shape
        draw.rectangle([cx-s*0.15, cy-s*0.15, cx+s*0.15, cy+s*0.15], fill=color)
        draw.ellipse([cx+s*0.08, cy-s*0.08, cx+s*0.25, cy+s*0.08], fill=color)
        draw.ellipse([cx-s*0.08, cy+s*0.08, cx+s*0.08, cy+s*0.25], fill=color)
    elif symbol == "dough":
        # Blob shape
        draw.ellipse([cx-s*0.2, cy-s*0.12, cx+s*0.2, cy+s*0.18], fill=color)
        draw.ellipse([cx-s*0.1, cy-s*0.2, cx+s*0.1, cy-s*0.05], fill=color)
    elif symbol == "beads":
        # String of beads
        for i in range(4):
            bx = cx - s*0.25 + i * s*0.16
            draw.ellipse([bx, cy-s*0.08, bx+s*0.12, cy+s*0.08], fill=color)
        draw.line([cx-s*0.25, cy, cx+s*0.25, cy], fill=color, width=2)
    elif symbol == "scissor":
        # Scissors
        draw.ellipse([cx-s*0.15, cy+s*0.05, cx, cy+s*0.2], outline=color, width=3)
        draw.ellipse([cx, cy+s*0.05, cx+s*0.15, cy+s*0.2], outline=color, width=3)
        draw.line([cx-s*0.08, cy+s*0.05, cx+s*0.05, cy-s*0.2], fill=color, width=3)
        draw.line([cx+s*0.08, cy+s*0.05, cx-s*0.05, cy-s*0.2], fill=color, width=3)
    elif symbol == "book":
        # Open book
        draw.polygon([(cx, cy-s*0.05), (cx-s*0.25, cy-s*0.15), (cx-s*0.25, cy+s*0.15), (cx, cy+s*0.05)], fill=color)
        draw.polygon([(cx, cy-s*0.05), (cx+s*0.25, cy-s*0.15), (cx+s*0.25, cy+s*0.15), (cx, cy+s*0.05)], fill=color)
        draw.line([cx, cy-s*0.05, cx, cy+s*0.05], fill=white, width=2)
    elif symbol == "story":
        # Speech bubble
        draw.ellipse([cx-s*0.2, cy-s*0.15, cx+s*0.2, cy+s*0.1], fill=color)
        draw.polygon([(cx-s*0.05, cy+s*0.08), (cx-s*0.15, cy+s*0.2), (cx+s*0.05, cy+s*0.08)], fill=color)
    elif symbol == "words":
        # ABC text
        draw.text((cx-s*0.18, cy-s*0.12), "ABC", fill=color, font=None)
    elif symbol == "rhymes":
        # Musical notes
        draw.ellipse([cx-s*0.15, cy, cx-s*0.05, cy+s*0.1], fill=color)
        draw.line([cx-s*0.05, cy+s*0.05, cx-s*0.05, cy-s*0.15], fill=color, width=3)
        draw.ellipse([cx+s*0.05, cy-s*0.05, cx+s*0.15, cy+s*0.05], fill=color)
        draw.line([cx+s*0.15, cy, cx+s*0.15, cy-s*0.2], fill=color, width=3)
    elif symbol == "talk":
        # Two speech bubbles
        draw.ellipse([cx-s*0.25, cy-s*0.15, cx+s*0.05, cy+s*0.05], fill=color)
        draw.ellipse([cx-s*0.05, cy-s*0.05, cx+s*0.25, cy+s*0.15], outline=color, width=3)
    elif symbol == "label":
        # Tag/label
        draw.rectangle([cx-s*0.15, cy-s*0.1, cx+s*0.2, cy+s*0.1], fill=color)
        draw.polygon([(cx-s*0.15, cy-s*0.1), (cx-s*0.25, cy), (cx-s*0.15, cy+s*0.1)], fill=color)
        draw.ellipse([cx-s*0.18, cy-s*0.03, cx-s*0.12, cy+s*0.03], fill=white)
    elif symbol == "sort":
        # Different sized circles
        draw.ellipse([cx-s*0.22, cy-s*0.05, cx-s*0.08, cy+s*0.15], fill=color)
        draw.ellipse([cx-s*0.05, cy-s*0.12, cx+s*0.12, cy+s*0.15], fill=color)
        draw.ellipse([cx+s*0.1, cy-s*0.02, cx+s*0.22, cy+s*0.15], fill=color)
    elif symbol == "pretend":
        # Mask / face
        draw.ellipse([cx-s*0.18, cy-s*0.18, cx+s*0.18, cy+s*0.18], fill=color)
        draw.ellipse([cx-s*0.12, cy-s*0.1, cx-s*0.04, cy-s*0.02], fill=white)
        draw.ellipse([cx+s*0.04, cy-s*0.1, cx+s*0.12, cy-s*0.02], fill=white)
        draw.arc([cx-s*0.1, cy, cx+s*0.1, cy+s*0.12], 0, 180, fill=white, width=2)
    elif symbol == "match":
        # Two matching cards
        draw.rectangle([cx-s*0.22, cy-s*0.12, cx-s*0.03, cy+s*0.12], fill=color)
        draw.rectangle([cx+s*0.03, cy-s*0.12, cx+s*0.22, cy+s*0.12], fill=color)
        draw.ellipse([cx-s*0.16, cy-s*0.04, cx-s*0.09, cy+s*0.04], fill=white)
        draw.ellipse([cx+s*0.09, cy-s*0.04, cx+s*0.16, cy+s*0.04], fill=white)
    elif symbol == "hide":
        # Eyes peeking
        draw.ellipse([cx-s*0.18, cy-s*0.08, cx-s*0.04, cy+s*0.08], fill=color)
        draw.ellipse([cx+s*0.04, cy-s*0.08, cx+s*0.18, cy+s*0.08], fill=color)
        draw.ellipse([cx-s*0.14, cy-s*0.03, cx-s*0.08, cy+s*0.03], fill=white)
        draw.ellipse([cx+s*0.08, cy-s*0.03, cx+s*0.14, cy+s*0.03], fill=white)
    elif symbol == "count":
        # 123
        draw.text((cx-s*0.2, cy-s*0.1), "123", fill=color, font=None)
    elif symbol == "build":
        # Tower of blocks
        draw.rectangle([cx-s*0.1, cy+s*0.05, cx+s*0.1, cy+s*0.2], fill=color)
        draw.rectangle([cx-s*0.08, cy-s*0.1, cx+s*0.08, cy+s*0.05], fill=color)
        draw.rectangle([cx-s*0.06, cy-s*0.22, cx+s*0.06, cy-s*0.1], fill=color)
    elif symbol == "playdate":
        # Two stick figures
        for offset in [-s*0.12, s*0.12]:
            px = cx + offset
            draw.ellipse([px-s*0.06, cy-s*0.22, px+s*0.06, cy-s*0.1], fill=color)
            draw.line([px, cy-s*0.1, px, cy+s*0.08], fill=color, width=3)
    elif symbol == "share":
        # Hands holding
        draw.arc([cx-s*0.2, cy-s*0.1, cx, cy+s*0.15], 180, 360, fill=color, width=4)
        draw.arc([cx, cy-s*0.1, cx+s*0.2, cy+s*0.15], 180, 360, fill=color, width=4)
    elif symbol == "emotion":
        # Smiley face
        draw.ellipse([cx-s*0.2, cy-s*0.2, cx+s*0.2, cy+s*0.2], fill=color)
        draw.ellipse([cx-s*0.1, cy-s*0.08, cx-s*0.04, cy-s*0.02], fill=white)
        draw.ellipse([cx+s*0.04, cy-s*0.08, cx+s*0.1, cy-s*0.02], fill=white)
        draw.arc([cx-s*0.1, cy+s*0.02, cx+s*0.1, cy+s*0.12], 0, 180, fill=white, width=2)
    elif symbol == "role":
        # Hat / costume
        draw.ellipse([cx-s*0.15, cy-s*0.05, cx+s*0.15, cy+s*0.18], fill=color)
        draw.polygon([(cx-s*0.2, cy), (cx, cy-s*0.25), (cx+s*0.2, cy)], fill=color)
    elif symbol == "coop":
        # Circle of dots (togetherness)
        for angle in range(0, 360, 60):
            rad = math.radians(angle)
            dx = cx + s * 0.15 * math.cos(rad)
            dy = cy + s * 0.15 * math.sin(rad)
            draw.ellipse([dx-s*0.05, dy-s*0.05, dx+s*0.05, dy+s*0.05], fill=color)
    elif symbol == "routine":
        # Clock
        draw.ellipse([cx-s*0.2, cy-s*0.2, cx+s*0.2, cy+s*0.2], outline=color, width=3)
        draw.line([cx, cy, cx, cy-s*0.12], fill=color, width=3)
        draw.line([cx, cy, cx+s*0.1, cy+s*0.05], fill=color, width=3)
        draw.ellipse([cx-s*0.03, cy-s*0.03, cx+s*0.03, cy+s*0.03], fill=color)
    else:
        # Default: star
        draw.ellipse([cx-s*0.15, cy-s*0.15, cx+s*0.15, cy+s*0.15], fill=color)


def generate_image(code, title, domain, symbol):
    """Generate a single activity placeholder image."""
    w, h = 512, 512
    bg_color = DOMAIN_LIGHT[domain]
    fg_color = DOMAIN_COLORS[domain]

    img = Image.new("RGBA", (w, h), bg_color + (255,))
    draw = ImageDraw.Draw(img)

    # Decorative background circle
    draw.ellipse([w*0.15, h*0.08, w*0.85, h*0.58], fill=fg_color + (30,))

    # Draw activity symbol in center
    draw_activity_symbol(draw, symbol, w*0.5, h*0.33, w*0.7, fg_color)

    # Activity title at bottom
    try:
        font_large = ImageFont.truetype("/System/Library/Fonts/Helvetica.ttc", 32)
        font_small = ImageFont.truetype("/System/Library/Fonts/Helvetica.ttc", 20)
    except:
        font_large = ImageFont.load_default()
        font_small = ImageFont.load_default()

    # Title background band
    draw.rectangle([0, h*0.65, w, h], fill=fg_color + (220,))

    # Draw title text
    lines = title.split("\n")
    y_start = h * 0.68
    for i, line in enumerate(lines):
        bbox = draw.textbbox((0, 0), line, font=font_large)
        tw = bbox[2] - bbox[0]
        x = (w - tw) / 2
        draw.text((x, y_start + i * 40), line, fill=(255, 255, 255), font=font_large)

    # Domain label at top
    domain_names = {"gm": "GROSS MOTOR", "fm": "FINE MOTOR", "lc": "LANGUAGE", "cog": "COGNITIVE", "se": "SOCIAL-EMOTIONAL"}
    domain_label = domain_names.get(domain, domain.upper())
    bbox = draw.textbbox((0, 0), domain_label, font=font_small)
    tw = bbox[2] - bbox[0]
    th = bbox[3] - bbox[1]

    # Domain badge
    pad = 10
    bx = (w - tw) / 2 - pad
    by = 15
    draw.rounded_rectangle([bx, by, bx + tw + pad*2, by + th + pad*2], radius=12, fill=fg_color + (200,))
    draw.text(((w - tw) / 2, by + pad), domain_label, fill=(255, 255, 255), font=font_small)

    # Activity code in corner
    draw.text((15, h - 30), code, fill=fg_color + (100,), font=font_small)

    # Save as PNG
    output_path = os.path.join(OUTPUT_DIR, f"{code}.png")
    img.save(output_path, "PNG", optimize=True)
    print(f"  Generated: {output_path}")


def main():
    os.makedirs(OUTPUT_DIR, exist_ok=True)
    print(f"Generating {len(ACTIVITIES)} activity images...")

    for code, title, domain, symbol in ACTIVITIES:
        generate_image(code, title, domain, symbol)

    print(f"\nDone! {len(ACTIVITIES)} images saved to {OUTPUT_DIR}/")


if __name__ == "__main__":
    main()
