#!/usr/bin/env python3
"""Render the White Hospital ground-floor layout mockup (72x44 tiles, 16px base, 2x scale).
Real sprites: zip PNGs (transparent) + keyed-out JPG icons (black flood-fill key-out).
Everything else is drawn schematic (see design.md section 8).
"""
import os
from collections import deque
from PIL import Image, ImageDraw, ImageFont

S = 2                      # render scale (32 px per tile)
T = 16 * S                 # tile size in px
W, H = 72, 44
IMG_W, IMG_H = W * T, H * T

ZIP = "/home/hatch/workspace/telegram-bot/media/topdown_hospital_Assets/topdown_hospital_Assets/Pngs"
MED = "/home/hatch/workspace/telegram-bot/media"
OUT = "/home/hatch/workspace/new-topdown-game/layout-mockup.png"

WHITE = (255, 255, 255)
WALL = (233, 228, 216)
WALL_EDGE = (207, 199, 180)
ASPHALT = (110, 110, 110)
SIDEWALK = (168, 168, 168)
BRICK = (176, 86, 60)

# zone accent colours (name -> hex)
ACCENTS = {
    "reception": (201, 162, 39), "pharmacy": (76, 175, 125), "exam": (91, 141, 239),
    "office": (138, 123, 99), "lab": (127, 176, 105), "storage": (154, 154, 154),
    "ward": (127, 179, 213), "wc": (110, 198, 198), "icu": (226, 109, 90),
    "theatre": (63, 167, 160), "radiology": (74, 144, 217), "maternity": (232, 160, 180),
    "dental": (46, 196, 182), "emergency": (217, 79, 61), "corridor": (184, 178, 164),
}

try:
    FONT_BIG = ImageFont.truetype("/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf", 20)
    FONT_SM = ImageFont.truetype("/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf", 16)
    FONT_XS = ImageFont.truetype("/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf", 13)
except Exception:
    FONT_BIG = FONT_SM = FONT_XS = ImageFont.load_default()


def key_out(path):
    """Black-background JPG -> RGBA with the connected black border region transparent."""
    im = Image.open(path).convert("RGB")
    w, h = im.size
    px = im.load()
    out = Image.new("RGBA", (w, h), (0, 0, 0, 0))
    op = out.load()
    seen = bytearray(w * h)
    q = deque()
    for x in range(w):
        for y in (0, h - 1):
            if sum(px[x, y]) < 120:
                q.append((x, y)); seen[y * w + x] = 1
    for y in range(h):
        for x in (0, w - 1):
            if sum(px[x, y]) < 120 and not seen[y * w + x]:
                q.append((x, y)); seen[y * w + x] = 1
    while q:
        x, y = q.popleft()
        op[x, y] = (0, 0, 0, 0)
        for nx, ny in ((x + 1, y), (x - 1, y), (x, y + 1), (x, y - 1)):
            if 0 <= nx < w and 0 <= ny < h and not seen[ny * w + nx]:
                seen[ny * w + nx] = 1
                if sum(px[nx, ny]) < 120:
                    q.append((nx, ny))
    for y in range(h):
        for x in range(w):
            if not seen[y * w + x]:
                op[x, y] = px[x, y] + (255,)
    # crop to content
    bbox = out.getbbox()
    return out.crop(bbox) if bbox else out


def paste_png(canvas, name, tx, ty):
    im = Image.open(os.path.join(ZIP, name)).convert("RGBA")
    im = im.resize((im.width * S, im.height * S), Image.NEAREST)
    canvas.paste(im, (tx * T, ty * T), im)


def paste_keyed(canvas, jpg_id, px, py, size):
    im = key_out(os.path.join(MED, f"287167{jpg_id}.jpg"))
    s = size / max(im.width, im.height)
    im = im.resize((max(1, int(im.width * s)), max(1, int(im.height * s))), Image.NEAREST)
    canvas.paste(im, (px, py), im)


# ---------------------------------------------------------------- walls
# wall tiles: (x, y) set. Doors are gaps.
walls = set()
for x in range(W):
    walls.add((x, 0))
    walls.add((x, 35))
for y in range(1, 35):
    walls.add((0, y))
    walls.add((71, y))
# top-band dividers (y 1..12)
for x in (15, 27, 36, 46, 62):
    for y in range(1, 13):
        walls.add((x, y))
# corridor walls
for x in range(1, 71):
    walls.add((x, 13))
    walls.add((x, 17))
# bottom-band dividers (y 18..34)
for x in (13, 18, 28, 41, 52, 61):
    for y in range(18, 35):
        walls.add((x, y))
# door gaps: (x, y) in wall rows
DOORS = [(7, 0), (8, 0)]                       # main entrance (north)
DOORS += [(x, 13) for x in (7, 8, 20, 21, 31, 32, 40, 41, 53, 54, 66, 67)]
DOORS += [(x, 17) for x in (6, 7, 15, 16, 22, 23, 34, 35, 46, 47, 56, 57, 65, 66)]
DOORS += [(60, 35), (61, 35)]                  # emergency door (south)
for d in DOORS:
    walls.discard(d)

# ---------------------------------------------------------------- canvas
img = Image.new("RGB", (IMG_W, IMG_H), WHITE)
d = ImageDraw.Draw(img, "RGBA")

# exterior: sidewalk + asphalt
d.rectangle([0, 36 * T, IMG_W, 37 * T], fill=SIDEWALK)
d.rectangle([0, 37 * T, IMG_W, IMG_H], fill=ASPHALT)
# dashed yellow lane line at y=39
for x in range(0, IMG_W, 96):
    d.rectangle([x, 39 * T + 14, x + 48, 39 * T + 18], fill=(232, 200, 50))

# walls
for (x, y) in walls:
    d.rectangle([x * T, y * T, (x + 1) * T - 1, (y + 1) * T - 1], fill=WALL, outline=WALL_EDGE)
# brick-red outer face of south wall, emergency section x55..70
d.rectangle([55 * T, 35 * T + T // 2, 71 * T, 36 * T - 1], fill=BRICK)
# door jambs
for (x, y) in DOORS:
    d.rectangle([x * T, y * T, x * T + 3, (y + 1) * T - 1], fill=(120, 116, 108))
    d.rectangle([(x + 1) * T - 4, y * T, (x + 1) * T - 1, (y + 1) * T - 1], fill=(120, 116, 108))

# zone accent stripes: 4px strip along the inner top edge of each room
ROOMS = [
    ("reception", 1, 1, 14, 12), ("pharmacy", 16, 1, 26, 12), ("exam", 28, 1, 35, 12),
    ("office", 37, 1, 45, 12), ("lab", 47, 1, 61, 12), ("storage", 63, 1, 70, 12),
    ("ward", 1, 18, 12, 34), ("wc", 14, 18, 17, 34), ("icu", 19, 18, 27, 34),
    ("theatre", 29, 18, 40, 34), ("radiology", 42, 18, 51, 34),
    ("maternity", 53, 18, 60, 34), ("dental", 62, 18, 70, 34),
]
for name, x0, y0, x1, y1 in ROOMS:
    c = ACCENTS[name]
    d.rectangle([x0 * T, y0 * T, (x1 + 1) * T - 1, y0 * T + 4], fill=c)

# ---------------------------------------------------------------- schematic helpers
def rect(tx, ty, w_tiles, h_tiles, fill, outline=None):
    d.rectangle([tx * T, ty * T, (tx + w_tiles) * T - 1, (ty + h_tiles) * T - 1],
                fill=fill, outline=outline or fill)

def text_cx(cx_px, cy_px, s, font, fill):
    w = d.textlength(s, font=font)
    d.text((cx_px - w / 2, cy_px - 8), s, font=font, fill=fill)

def label(tx, ty, s, zone):
    c = ACCENTS[zone]
    cx, cy = int((tx + 0.5) * T), int((ty + 0.5) * T)
    w = d.textlength(s, font=FONT_BIG)
    pad = 10
    d.rounded_rectangle([cx - w / 2 - pad, cy - 14, cx + w / 2 + pad, cy + 14],
                        radius=12, fill=(255, 255, 255, 225), outline=c, width=2)
    d.text((cx - w / 2, cy - 10), s, font=FONT_BIG, fill=c)

def bench(tx, ty, w):
    rect(tx, ty, w, 1, (201, 168, 106), (150, 120, 70))

def ambulance(px, py):
    w, h = 12 * T, 3 * T
    d.rounded_rectangle([px, py, px + w - 1, py + h - 1], radius=10, fill=(245, 245, 245), outline=(180, 180, 180), width=2)
    d.rectangle([px + 8, py + h - 26, px + w - 8, py + h - 18], fill=(217, 79, 61))
    d.rectangle([px + w - 92, py + 8, px + w - 12, py + 40], fill=(200, 220, 235), outline=(150, 150, 150))
    cx, cy = px + w // 3, py + h // 2
    d.rectangle([cx - 26, cy - 8, cx + 26, cy + 8], fill=(217, 79, 61))
    d.rectangle([cx - 8, cy - 26, cx + 8, cy + 26], fill=(217, 79, 61))
    for wx in (px + 70, px + w - 80):
        d.ellipse([wx - 16, py + h - 18, wx + 16, py + h + 14], fill=(40, 40, 40))
        d.ellipse([wx - 7, py + h - 9, wx + 7, py + h + 5], fill=(150, 150, 150))

def dental_chair(px, py):
    d.rectangle([px, py + 34, px + 76, py + 58], fill=(46, 196, 182), outline=(20, 140, 130), width=2)
    d.rectangle([px + 56, py + 6, px + 76, py + 40], fill=(46, 196, 182), outline=(20, 140, 130), width=2)
    d.rectangle([px - 14, py + 10, px + 60, py + 14], fill=(150, 150, 150))
    d.ellipse([px - 22, py + 4, px - 6, py + 20], fill=(255, 240, 150), outline=(150, 150, 150))

def cone(px, py):
    d.polygon([(px, py + 22), (px + 11, py), (px + 22, py + 22)], fill=(230, 110, 30))

# ---------------------------------------------------------------- furniture (real zip PNGs)
FURN = [
    # reception
    ("lab_wooden_cabinet_full.png", 6, 3), ("lab_wooden_cabinet_full.png", 8, 3),
    ("lab_computer.png", 7, 2),
    ("room_armchair.png", 2, 8), ("room_armchair.png", 4, 8), ("room_armchair.png", 10, 8), ("room_armchair.png", 12, 8),
    ("room_flower.png", 2, 2), ("room_flower.png", 13, 2),
    # pharmacy
    ("room_pharmacy_shelf.png", 17, 1), ("room_pharmacy_shelf.png", 19, 1),
    ("room_pharmacy_shelf.png", 21, 1), ("room_pharmacy_shelf.png", 23, 1),
    ("lab_medium_table.png", 18, 5), ("lab_medium_table.png", 22, 5),
    ("room_pills_01.png", 18, 4), ("room_pills_02.png", 22, 4),
    ("lab_wooden_cabinet.png", 24, 9),
    # exam
    ("room_bed_v.png", 30, 5), ("room_cabinet.png", 34, 2),
    ("room_hand_sanitizer.png", 34, 5), ("room_anatomy_poster.png", 29, 1),
    ("lab_medium_table.png", 31, 8),
    # office
    ("lab_medium_table.png", 38, 4), ("lab_computer.png", 38, 2),
    ("lab_wooden_cabinet_full.png", 43, 2), ("lab_books.png", 39, 4),
    ("room_armchair.png", 38, 8), ("room_armchair.png", 42, 8),
    ("room_flower.png", 44, 10),
    # lab
    ("lab_large_table.png", 52, 5), ("lab_microscope_h.png", 52, 4),
    ("lab_sample_centrifuge.png", 54, 4), ("lab_sample_vials.png", 55, 4),
    ("lab_computer.png", 56, 4), ("lab_refrigerator.png", 48, 1),
    ("lab_sink.png", 50, 1), ("lab_wooden_cabinet.png", 58, 1),
    ("lab_wooden_cabinet_full.png", 60, 1), ("lab_medium_table.png", 48, 8),
    ("lab_books.png", 49, 8), ("lab_paper_dispenser.png", 49, 1),
    ("lab_vial_001.png", 52, 8), ("lab_vial_002.png", 53, 8),
    ("lab_vial_003.png", 54, 8), ("lab_vial_004.png", 55, 8),
    ("lab_automation_robot.png", 58, 9), ("lab_microscope_v.png", 48, 10),
    # storage
    ("lab_wooden_cabinet.png", 64, 2), ("lab_wooden_cabinet.png", 66, 2),
    ("room_cabinet.png", 68, 2),
    # ward
    ("room_bed_h.png", 2, 20), ("room_bed_h.png", 5, 20), ("room_bed_meal.png", 8, 20),
    ("room_bed_h.png", 2, 26), ("room_bed_h.png", 5, 26), ("room_bed_h.png", 8, 26),
    ("room_bedside_table.png", 4, 20), ("room_bedside_table.png", 7, 20),
    ("room_bedside_table.png", 10, 20), ("room_bedside_table.png", 4, 26),
    ("room_bedside_table.png", 7, 26), ("room_bedside_table.png", 10, 26),
    ("room_iv_stand_b.png", 2, 23), ("room_iv_stand_g.png", 5, 23),
    ("room_iv_stand_w.png", 8, 23), ("room_iv_stand_b.png", 5, 29),
    ("room_ecg_cart.png", 11, 26), ("room_ecg_screen.png", 11, 24),
    ("room_biohazard_bin.png", 11, 31), ("room_biohazard_bin_y.png", 10, 31),
    ("room_hand_sanitizer.png", 11, 19), ("room_anatomy_poster.png", 2, 18),
    ("room_meal_tray.png", 10, 22), ("room_table_meal_h.png", 3, 29),
    ("room_flower.png", 11, 32),
    # restrooms
    ("room_hand_sanitizer.png", 17, 19),
    # icu
    ("room_bed_h.png", 20, 20), ("room_bed_h.png", 20, 26),
    ("room_ecg_cart.png", 24, 20), ("room_ecg_screen.png", 24, 22),
    ("operation_ultrasound_machine.png", 25, 26), ("room_biohazard_bin.png", 26, 32),
    # theatre
    ("operation_light.png", 33, 19), ("operation_table.png", 33, 22),
    ("operation_console_full.png", 30, 19), ("operation_console_computer.png", 30, 22),
    ("operation_accessories_table_full.png", 38, 19), ("operation_accessories_table.png", 38, 21),
    ("operation_console_table.png", 30, 26), ("operation_ecg_full.png", 38, 26),
    ("operation_ecg_screen.png", 38, 25), ("operation_ultrasound_machine.png", 30, 29),
    ("operation_scalpel_01.png", 38, 20), ("operation_scalpel_02.png", 39, 20),
    # radiology
    ("operation_ct_scanner.png", 43, 19), ("operation_table.png", 48, 19),
    ("operation_ultrasound_machine.png", 48, 24), ("operation_ecg_full.png", 43, 26),
    ("operation_radiation_sign.png", 50, 18), ("operation_console_computer.png", 43, 29),
    # maternity
    ("maternity_bed.png", 54, 20), ("maternity_carpet.png", 55, 27),
    ("maternity_light.png", 58, 20), ("maternity_chair.png", 53, 26),
    ("maternity_ball.png", 59, 26), ("maternity_table.png", 53, 29),
    ("maternity_work_cabinet.png", 59, 29), ("maternity_towel_01.png", 54, 25),
    ("maternity_towel_02.png", 55, 25), ("maternity_cottons.png", 56, 25),
    ("maternity_birthing_rope.png", 53, 20),
    # dental
    ("room_cabinet.png", 69, 18), ("room_hand_sanitizer.png", 62, 26),
    # corridor
    ("room_flower.png", 2, 14), ("room_flower.png", 12, 16), ("room_flower.png", 27, 14),
    ("room_flower.png", 52, 16), ("room_flower.png", 69, 14),
    ("lab_medium_table.png", 33, 14), ("lab_medium_table.png", 35, 14),
    ("lab_medium_table.png", 37, 14), ("lab_computer.png", 34, 14),
    # emergency bay
    ("room_bed_h.png", 63, 38),
]
for name, tx, ty in FURN:
    paste_png(img, name, tx, ty)

# keyed-out JPG props: (id, px, py, size_px)
KEYED = [
    (626, 12 * T + 4, 4 * T + 2, 50),    # astronaut display, reception
    (629, 18 * T + 36, 5 * T + 2, 28), (631, 20 * T + 8, 5 * T + 2, 28),
    (647, 22 * T + 36, 5 * T + 2, 28), (630, 19 * T + 8, 5 * T + 2, 28),
    (656, 23 * T + 8, 5 * T + 2, 28), (635, 25 * T + 2, 1 * T + 2, 30),
    (632, 31 * T + 16, 8 * T + 2, 30), (636, 28 * T + 2, 10 * T + 2, 30),
    (668, 60 * T + 2, 10 * T + 2, 30), (665, 48 * T + 8, 8 * T + 2, 28),
    (637, 64 * T + 2, 5 * T + 2, 28), (646, 65 * T + 2, 5 * T + 2, 28),
    (655, 66 * T + 2, 5 * T + 2, 28), (659, 67 * T + 2, 5 * T + 2, 28),
    (660, 69 * T + 2, 10 * T + 2, 30),   # unidentified canister
    (641, 10 * T + 2, 18 * T + 2, 30), (643, 23 * T + 2, 20 * T + 2, 30),
    (642, 26 * T + 2, 19 * T + 2, 28), (662, 19 * T + 2, 31 * T + 2, 30),
    (663, 29 * T + 2, 32 * T + 2, 30), (627, 16 * T + 2, 15 * T - 6, 44),
    (640, 30 * T + 2, 15 * T - 6, 44), (648, 44 * T + 2, 15 * T - 6, 44),
    (667, 57 * T + 2, 37 * T + 4, 44),   # wheelchair by emergency door
]
for jid, px, py, size in KEYED:
    paste_keyed(img, jid, px, py, size)

# "?" marker next to the unidentified canister
d.text((69 * T + 24, 10 * T + 26), "?", font=FONT_BIG, fill=(217, 79, 61))

# ---------------------------------------------------------------- schematic items
# reception: vending machine, fish tank, kids corner
rect(2, 4, 1, 2, (120, 120, 120), (80, 80, 80))
d.rectangle([2 * T + 6, 4 * T + 8, 2 * T + 26, 4 * T + 44], fill=(200, 60, 60))
rect(2, 10, 2, 1, (90, 160, 220), (40, 100, 160))
d.rectangle([2 * T + 4, 10 * T + 6, 2 * T + 60, 10 * T + 12], fill=(180, 220, 245))
d.ellipse([2 * T + 18, 10 * T + 16, 2 * T + 28, 10 * T + 24], fill=(240, 140, 40))
rect(10, 10, 4, 2, (245, 200, 210), (220, 150, 170))
for (bx, by, c) in ((10, 10, (240, 90, 90)), (12, 11, (90, 140, 240)), (13, 10, (240, 200, 90))):
    d.rectangle([bx * T + 6, by * T + 6, bx * T + 26, by * T + 26], fill=c, outline=(120, 120, 120))
# exam: eye chart
d.rectangle([33 * T + 4, 1 * T + 4, 33 * T + 28, 1 * T + 28], fill=(255, 255, 255), outline=(100, 100, 100))
for i, w in enumerate((16, 12, 8, 5)):
    d.rectangle([33 * T + 8, 1 * T + 8 + i * 6, 33 * T + 8 + w, 1 * T + 12 + i * 6], fill=(30, 30, 30))
# storage: boxes
for (bx, by) in ((64, 8), (66, 8), (68, 8)):
    d.rectangle([bx * T + 3, by * T + 3, bx * T + 29, by * T + 29], fill=(190, 150, 100), outline=(140, 105, 60), width=2)
    d.line([bx * T + 3, by * T + 16, bx * T + 29, by * T + 16], fill=(140, 105, 60), width=2)
# restrooms: sinks, toilets, mirror
for sx in (14, 16):
    d.rounded_rectangle([sx * T + 4, 19 * T + 6, sx * T + 28, 19 * T + 26], radius=6, fill=(190, 220, 235), outline=(120, 160, 180))
    d.ellipse([sx * T + 12, 20 * T + 6, sx * T + 20, 20 * T + 14], fill=(120, 160, 180))
    d.rounded_rectangle([sx * T + 4, 22 * T + 4, sx * T + 28, 22 * T + 28], radius=6, fill=(245, 245, 245), outline=(150, 150, 150))
    d.rectangle([sx * T + 4, 22 * T + 4, sx * T + 28, 22 * T + 12], fill=(220, 220, 220), outline=(150, 150, 150))
d.rectangle([14 * T + 4, 18 * T + 2, 17 * T + 28, 18 * T + 10], fill=(200, 210, 220), outline=(150, 160, 170))
# corridor benches + signs
bench(5, 14, 5); bench(20, 16, 5); bench(45, 14, 5); bench(58, 16, 5)
for sx in (10, 25, 45, 60):
    d.rectangle([sx * T + 6, 13 * T + 6, sx * T + 26, 13 * T + 26], fill=(40, 90, 160))
    d.text((sx * T + 12, 13 * T + 8), "H", font=FONT_SM, fill=(255, 255, 255))
# theatre stools
for (sx, sy) in ((31, 24), (37, 28)):
    d.ellipse([sx * T + 6, sy * T + 6, sx * T + 26, sy * T + 26], fill=(150, 150, 150), outline=(100, 100, 100))
# radiology: lead aprons + MRI ring
for ax in (47, 48):
    d.rectangle([ax * T + 6, 18 * T + 2, ax * T + 26, 18 * T + 30], fill=(140, 140, 150), outline=(100, 100, 110))
d.ellipse([44 * T + 2, 30 * T + 2, 46 * T + 30, 32 * T + 30], outline=(120, 120, 130), width=6)
d.ellipse([44 * T + 14, 30 * T + 14, 46 * T + 18, 32 * T + 18], outline=(120, 120, 130), width=3)
# maternity bassinets
for bx in (54, 56, 58):
    d.rectangle([bx * T + 2, 18 * T + 4, bx * T + 30, 18 * T + 28], fill=(245, 245, 245), outline=(150, 180, 200), width=2)
    d.rectangle([bx * T + 2, 18 * T + 16, bx * T + 30, 18 * T + 28], fill=(160, 200, 235))
# dental chairs + stool + tooth poster + wall cabinets
dental_chair(63 * T + 4, 21 * T + 4)
dental_chair(67 * T + 4, 21 * T + 4)
d.ellipse([64 * T + 6, 25 * T + 6, 64 * T + 26, 25 * T + 26], fill=(90, 160, 220), outline=(50, 110, 170))
d.rectangle([63 * T + 4, 18 * T + 4, 63 * T + 28, 18 * T + 28], fill=(255, 255, 255), outline=(100, 100, 100))
d.ellipse([63 * T + 10, 18 * T + 8, 63 * T + 22, 18 * T + 24], fill=(230, 230, 230), outline=(120, 120, 120))
for cx in (66, 67):
    d.rectangle([cx * T + 2, 18 * T + 2, cx * T + 30, 18 * T + 28], fill=(190, 190, 190), outline=(140, 140, 140))
# emergency bay
ambulance(10 * T, 37 * T + 8)
ambulance(30 * T, 37 * T + 8)
for cx in (8, 25, 45):
    cone(cx * T, 41 * T + 4)
# EMERGENCY sign on south wall, left of the door gap (door stays visible at x60-61)
d.rectangle([56 * T, 35 * T + 2, 60 * T, 35 * T + 28], fill=(217, 79, 61))
text_cx(58 * T, 35 * T + 16, "EMERGENCY", FONT_XS, (255, 255, 255))

# ---------------------------------------------------------------- labels
label(5, 11, "RECEPTION", "reception")
label(20, 10, "PHARMACY", "pharmacy")
label(31, 10, "EXAM", "exam")
label(40, 11, "OFFICE", "office")
label(53, 11, "LAB", "lab")
label(66, 11, "STORAGE", "storage")
label(5, 32, "WARD", "ward")
label(15, 28, "WC", "wc")
label(23, 30, "ICU", "icu")
label(34, 31, "THEATRE", "theatre")
label(47, 33, "RADIOLOGY", "radiology")
label(56, 31, "MATERNITY", "maternity")
label(65, 29, "DENTAL", "dental")
label(55, 15, "CORRIDOR", "corridor")
# bay caption
d.text((2 * T, 42 * T + 6), "WHITE HOSPITAL — GROUND FLOOR MOCKUP (72x44 tiles)", font=FONT_SM, fill=(255, 255, 255))
text_cx(20 * T, 42 * T + 6, "", FONT_SM, (255, 255, 255))

img.save(OUT)
print("saved", OUT, img.size)
