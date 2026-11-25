# داده‌ی نقشه‌ی «بیمارستان سفید» — مختصات تایل از design.md §۴.
# تایل ۱۶×۱۶؛ نقشه ۷۲×۴۴ تایل (۱۱۵۲×۷۰۴ پیکسل).
# جنوب نقشه ایrlاک / درِ خروج سفینه است، نه خیابان.
class_name WhiteHospitalMap
extends RefCounted

const TILE := 16
const MAP_W_TILES := 72
const MAP_H_TILES := 44
const MAP_W_PX := MAP_W_TILES * TILE
const MAP_H_PX := MAP_H_TILES * TILE

const WALL_BODY := Color("#F2EFE6")
const WALL_CAP := Color("#D9D2C2")
const HULL_METAL := Color("#7C8794")
const HULL_SEAM := Color("#5F6B78")
const AIRLOCK_FLOOR := Color("#C9CDD2")
const AIRLOCK_LINE := Color("#E8C832")
const EXIT_RED := Color("#D94F3D")

# هر اتاق: مستطیل داخلی (تایل)، در به راهرو، رنگ لهجه، پازل (در صورت وجود).
const ROOMS := [
	{"id": "reception", "name": "پذیرش و انتظار", "rect": Rect2i(1, 1, 14, 12), "door_side": "S", "door_start": 7, "accent": Color("#C9A227"), "puzzle": ""},
	{"id": "pharmacy", "name": "داروخانه", "rect": Rect2i(16, 1, 11, 12), "door_side": "S", "door_start": 20, "accent": Color("#4CAF7D"), "puzzle": "pharmacy"},
	{"id": "exam", "name": "اتاق معاینه", "rect": Rect2i(28, 1, 8, 12), "door_side": "S", "door_start": 31, "accent": Color("#5B8DEF"), "puzzle": ""},
	{"id": "doctor", "name": "مطب دکتر", "rect": Rect2i(37, 1, 9, 12), "door_side": "S", "door_start": 40, "accent": Color("#8A7B63"), "puzzle": ""},
	{"id": "lab", "name": "آزمایشگاه", "rect": Rect2i(47, 1, 15, 12), "door_side": "S", "door_start": 53, "accent": Color("#7FB069"), "puzzle": "lab"},
	{"id": "storage", "name": "انبار", "rect": Rect2i(63, 1, 8, 12), "door_side": "S", "door_start": 66, "accent": Color("#9A9A9A"), "puzzle": ""},
	{"id": "ward", "name": "بخش بستری", "rect": Rect2i(1, 18, 12, 17), "door_side": "N", "door_start": 6, "accent": Color("#7FB3D5"), "puzzle": ""},
	{"id": "wc", "name": "سرویس بهداشتی", "rect": Rect2i(14, 18, 4, 17), "door_side": "N", "door_start": 15, "accent": Color("#6EC6C6"), "puzzle": ""},
	{"id": "icu", "name": "ICU", "rect": Rect2i(19, 18, 9, 17), "door_side": "N", "door_start": 22, "accent": Color("#E26D5A"), "puzzle": "icu"},
	{"id": "surgery", "name": "اتاق عمل", "rect": Rect2i(29, 18, 12, 17), "door_side": "N", "door_start": 34, "accent": Color("#3FA7A0"), "puzzle": "surgery"},
	{"id": "radiology", "name": "رادیولوژی", "rect": Rect2i(42, 18, 10, 17), "door_side": "N", "door_start": 46, "accent": Color("#4A90D9"), "puzzle": "radiology"},
	{"id": "maternity", "name": "زایمان", "rect": Rect2i(53, 18, 8, 17), "door_side": "N", "door_start": 56, "accent": Color("#E8A0B4"), "puzzle": "maternity"},
	{"id": "dental", "name": "دندان‌پزشکی", "rect": Rect2i(62, 18, 9, 17), "door_side": "N", "door_start": 65, "accent": Color("#2EC4B6"), "puzzle": ""},
]

# راهروی مرکزی (y=14 تا ۱۶) و ایrlاک جنوبی (y=36 تا ۴۳).
const CORRIDOR_RECT := Rect2i(1, 14, 70, 3)
const AIRLOCK_RECT := Rect2i(1, 36, 70, 8)

# ورودی ایrlاک از دیوار جنوبی ردیف پایین: زیر زایمان، هم‌راستا با درِ
# شمالی‌اش (x56–57) — مطابق نوار قرمز EMERGENCY ماکاپ زیر زایمان.
const AIRLOCK_DOOR_START := 56
# درِ خروج سفینه در دیوار جنوب ایrlاک (x60–61)، مطابق design.md §۴.
const EXIT_DOOR_START := 60

# نقطه‌های تعامل پازل (مرکز تایل، به پیکسل).
static func puzzle_spots() -> Dictionary:
	return {
		"lab": Vector2(54, 6) * TILE + Vector2(TILE, TILE) * 0.5,
		"surgery": Vector2(34, 26) * TILE + Vector2(TILE, TILE) * 0.5,
		"radiology": Vector2(46, 26) * TILE + Vector2(TILE, TILE) * 0.5,
		"pharmacy": Vector2(21, 6) * TILE + Vector2(TILE, TILE) * 0.5,
		"icu": Vector2(23, 26) * TILE + Vector2(TILE, TILE) * 0.5,
		"maternity": Vector2(56, 26) * TILE + Vector2(TILE, TILE) * 0.5,
	}

static func exit_door_center() -> Vector2:
	return Vector2((EXIT_DOOR_START + 1) * TILE, 41.5 * TILE)

static func room_for_puzzle(puzzle_id: String) -> Dictionary:
	for room in ROOMS:
		if room["puzzle"] == puzzle_id:
			return room
	return {}


static func _add_row(walls: Array[Rect2i], y: int, door_starts: Array) -> void:
	var x := 1
	var gaps: Array[int] = []
	for d in door_starts:
		gaps.append(int(d))
	gaps.sort()
	for gap in gaps:
		if gap > x:
			walls.append(Rect2i(x, y, gap - x, 1))
		x = gap + 2
	if x <= 70:
		walls.append(Rect2i(x, y, 71 - x, 1))


# همه‌ی مستطیل‌های دیوار (تایل): بدنه‌ی بیرونی سفینه + دیوار اتاق‌ها.
static func wall_rects() -> Array[Rect2i]:
	var walls: Array[Rect2i] = []
	# بدنه‌ی بیرونی سفینه.
	walls.append(Rect2i(0, 0, 1, MAP_H_TILES))
	walls.append(Rect2i(71, 0, 1, MAP_H_TILES))
	walls.append(Rect2i(0, 0, MAP_W_TILES, 1))
	walls.append(Rect2i(0, 43, EXIT_DOOR_START, 1))
	walls.append(Rect2i(EXIT_DOOR_START + 2, 43, MAP_W_TILES - EXIT_DOOR_START - 2, 1))
	# ردیف‌های افقی با جای در.
	_add_row(walls, 13, [7, 20, 31, 40, 53, 66])
	_add_row(walls, 17, [6, 15, 22, 34, 46, 56, 65])
	_add_row(walls, 35, [AIRLOCK_DOOR_START])
	# ستون‌های عمودی بین اتاق‌های ردیف بالا (y=1 تا ۱۲).
	for x in [15, 27, 36, 46, 62]:
		walls.append(Rect2i(x, 1, 1, 12))
	# ستون‌های عمودی بین اتاق‌های ردیف پایین (y=18 تا ۳۴).
	for x in [13, 18, 28, 41, 52, 61]:
		walls.append(Rect2i(x, 18, 1, 17))
	return walls


# وسایل نقشه — جایگذاری دقیقاً مطابق render_mockup.py (FURN + KEYED).
# هر مورد یا اسپرایت واقعی است ({"sprite", "pos"} و برای پراپ‌های key-out
# شده {"size"} هم دارد) یا شماتیک است ({"rect", "color", "label"}).
# اسپرایت‌ها با اندازه‌ی واقعی‌شان (پیکسل) از گوشه‌ی بالا-چپ تایل کشیده
# می‌شوند؛ برخورد ندارند — فقط راهنمایی بصری‌اند.
static func furniture() -> Array:
	return [
		{"sprite": "res://assets/sprites/lab/lab_wooden_cabinet_full.png", "pos": Vector2(96, 48)},
		{"sprite": "res://assets/sprites/lab/lab_wooden_cabinet_full.png", "pos": Vector2(128, 48)},
		{"sprite": "res://assets/sprites/lab/lab_computer.png", "pos": Vector2(112, 32)},
		{"sprite": "res://assets/sprites/room/room_armchair.png", "pos": Vector2(32, 128)},
		{"sprite": "res://assets/sprites/room/room_armchair.png", "pos": Vector2(64, 128)},
		{"sprite": "res://assets/sprites/room/room_armchair.png", "pos": Vector2(160, 128)},
		{"sprite": "res://assets/sprites/room/room_armchair.png", "pos": Vector2(192, 128)},
		{"sprite": "res://assets/sprites/room/room_flower.png", "pos": Vector2(32, 32)},
		{"sprite": "res://assets/sprites/room/room_flower.png", "pos": Vector2(208, 32)},
		{"sprite": "res://assets/sprites/room/room_pharmacy_shelf.png", "pos": Vector2(272, 16)},
		{"sprite": "res://assets/sprites/room/room_pharmacy_shelf.png", "pos": Vector2(304, 16)},
		{"sprite": "res://assets/sprites/room/room_pharmacy_shelf.png", "pos": Vector2(336, 16)},
		{"sprite": "res://assets/sprites/room/room_pharmacy_shelf.png", "pos": Vector2(368, 16)},
		{"sprite": "res://assets/sprites/lab/lab_medium_table.png", "pos": Vector2(288, 80)},
		{"sprite": "res://assets/sprites/lab/lab_medium_table.png", "pos": Vector2(352, 80)},
		{"sprite": "res://assets/sprites/room/room_pills_01.png", "pos": Vector2(288, 64)},
		{"sprite": "res://assets/sprites/room/room_pills_02.png", "pos": Vector2(352, 64)},
		{"sprite": "res://assets/sprites/lab/lab_wooden_cabinet.png", "pos": Vector2(384, 144)},
		{"sprite": "res://assets/sprites/room/room_bed_v.png", "pos": Vector2(480, 80)},
		{"sprite": "res://assets/sprites/room/room_cabinet.png", "pos": Vector2(544, 32)},
		{"sprite": "res://assets/sprites/room/room_hand_sanitizer.png", "pos": Vector2(544, 80)},
		{"sprite": "res://assets/sprites/room/room_anatomy_poster.png", "pos": Vector2(464, 16)},
		{"sprite": "res://assets/sprites/lab/lab_medium_table.png", "pos": Vector2(496, 128)},
		{"sprite": "res://assets/sprites/lab/lab_medium_table.png", "pos": Vector2(608, 64)},
		{"sprite": "res://assets/sprites/lab/lab_computer.png", "pos": Vector2(608, 32)},
		{"sprite": "res://assets/sprites/lab/lab_wooden_cabinet_full.png", "pos": Vector2(688, 32)},
		{"sprite": "res://assets/sprites/lab/lab_books.png", "pos": Vector2(624, 64)},
		{"sprite": "res://assets/sprites/room/room_armchair.png", "pos": Vector2(608, 128)},
		{"sprite": "res://assets/sprites/room/room_armchair.png", "pos": Vector2(672, 128)},
		{"sprite": "res://assets/sprites/room/room_flower.png", "pos": Vector2(704, 160)},
		{"sprite": "res://assets/sprites/lab/lab_large_table.png", "pos": Vector2(832, 80)},
		{"sprite": "res://assets/sprites/lab/lab_microscope_h.png", "pos": Vector2(832, 64)},
		{"sprite": "res://assets/sprites/lab/lab_sample_centrifuge.png", "pos": Vector2(864, 64)},
		{"sprite": "res://assets/sprites/lab/lab_sample_vials.png", "pos": Vector2(880, 64)},
		{"sprite": "res://assets/sprites/lab/lab_computer.png", "pos": Vector2(896, 64)},
		{"sprite": "res://assets/sprites/lab/lab_refrigerator.png", "pos": Vector2(768, 16)},
		{"sprite": "res://assets/sprites/lab/lab_sink.png", "pos": Vector2(800, 16)},
		{"sprite": "res://assets/sprites/lab/lab_wooden_cabinet.png", "pos": Vector2(928, 16)},
		{"sprite": "res://assets/sprites/lab/lab_wooden_cabinet_full.png", "pos": Vector2(960, 16)},
		{"sprite": "res://assets/sprites/lab/lab_medium_table.png", "pos": Vector2(768, 128)},
		{"sprite": "res://assets/sprites/lab/lab_books.png", "pos": Vector2(784, 128)},
		{"sprite": "res://assets/sprites/lab/lab_paper_dispenser.png", "pos": Vector2(784, 16)},
		{"sprite": "res://assets/sprites/lab/lab_vial_001.png", "pos": Vector2(832, 128)},
		{"sprite": "res://assets/sprites/lab/lab_vial_002.png", "pos": Vector2(848, 128)},
		{"sprite": "res://assets/sprites/lab/lab_vial_003.png", "pos": Vector2(864, 128)},
		{"sprite": "res://assets/sprites/lab/lab_vial_004.png", "pos": Vector2(880, 128)},
		{"sprite": "res://assets/sprites/lab/lab_automation_robot.png", "pos": Vector2(928, 144)},
		{"sprite": "res://assets/sprites/lab/lab_microscope_v.png", "pos": Vector2(768, 160)},
		{"sprite": "res://assets/sprites/lab/lab_wooden_cabinet.png", "pos": Vector2(1024, 32)},
		{"sprite": "res://assets/sprites/lab/lab_wooden_cabinet.png", "pos": Vector2(1056, 32)},
		{"sprite": "res://assets/sprites/room/room_cabinet.png", "pos": Vector2(1088, 32)},
		{"sprite": "res://assets/sprites/room/room_bed_h.png", "pos": Vector2(32, 320)},
		{"sprite": "res://assets/sprites/room/room_bed_h.png", "pos": Vector2(80, 320)},
		{"sprite": "res://assets/sprites/room/room_bed_meal.png", "pos": Vector2(128, 320)},
		{"sprite": "res://assets/sprites/room/room_bed_h.png", "pos": Vector2(32, 416)},
		{"sprite": "res://assets/sprites/room/room_bed_h.png", "pos": Vector2(80, 416)},
		{"sprite": "res://assets/sprites/room/room_bed_h.png", "pos": Vector2(128, 416)},
		{"sprite": "res://assets/sprites/room/room_bedside_table.png", "pos": Vector2(64, 320)},
		{"sprite": "res://assets/sprites/room/room_bedside_table.png", "pos": Vector2(112, 320)},
		{"sprite": "res://assets/sprites/room/room_bedside_table.png", "pos": Vector2(160, 320)},
		{"sprite": "res://assets/sprites/room/room_bedside_table.png", "pos": Vector2(64, 416)},
		{"sprite": "res://assets/sprites/room/room_bedside_table.png", "pos": Vector2(112, 416)},
		{"sprite": "res://assets/sprites/room/room_bedside_table.png", "pos": Vector2(160, 416)},
		{"sprite": "res://assets/sprites/room/room_iv_stand_b.png", "pos": Vector2(32, 368)},
		{"sprite": "res://assets/sprites/room/room_iv_stand_g.png", "pos": Vector2(80, 368)},
		{"sprite": "res://assets/sprites/room/room_iv_stand_w.png", "pos": Vector2(128, 368)},
		{"sprite": "res://assets/sprites/room/room_iv_stand_b.png", "pos": Vector2(80, 464)},
		{"sprite": "res://assets/sprites/room/room_ecg_cart.png", "pos": Vector2(176, 416)},
		{"sprite": "res://assets/sprites/room/room_ecg_screen.png", "pos": Vector2(176, 384)},
		{"sprite": "res://assets/sprites/room/room_biohazard_bin.png", "pos": Vector2(176, 496)},
		{"sprite": "res://assets/sprites/room/room_biohazard_bin_y.png", "pos": Vector2(160, 496)},
		{"sprite": "res://assets/sprites/room/room_hand_sanitizer.png", "pos": Vector2(176, 304)},
		{"sprite": "res://assets/sprites/room/room_anatomy_poster.png", "pos": Vector2(32, 288)},
		{"sprite": "res://assets/sprites/room/room_meal_tray.png", "pos": Vector2(160, 352)},
		{"sprite": "res://assets/sprites/room/room_table_meal_h.png", "pos": Vector2(48, 464)},
		{"sprite": "res://assets/sprites/room/room_flower.png", "pos": Vector2(176, 512)},
		{"sprite": "res://assets/sprites/room/room_hand_sanitizer.png", "pos": Vector2(272, 304)},
		{"sprite": "res://assets/sprites/room/room_bed_h.png", "pos": Vector2(320, 320)},
		{"sprite": "res://assets/sprites/room/room_bed_h.png", "pos": Vector2(320, 416)},
		{"sprite": "res://assets/sprites/room/room_ecg_cart.png", "pos": Vector2(384, 320)},
		{"sprite": "res://assets/sprites/room/room_ecg_screen.png", "pos": Vector2(384, 352)},
		{"sprite": "res://assets/sprites/operation/operation_ultrasound_machine.png", "pos": Vector2(400, 416)},
		{"sprite": "res://assets/sprites/room/room_biohazard_bin.png", "pos": Vector2(416, 512)},
		{"sprite": "res://assets/sprites/operation/operation_light.png", "pos": Vector2(528, 304)},
		{"sprite": "res://assets/sprites/operation/operation_table.png", "pos": Vector2(528, 352)},
		{"sprite": "res://assets/sprites/operation/operation_console_full.png", "pos": Vector2(480, 304)},
		{"sprite": "res://assets/sprites/operation/operation_console_computer.png", "pos": Vector2(480, 352)},
		{"sprite": "res://assets/sprites/operation/operation_accessories_table_full.png", "pos": Vector2(608, 304)},
		{"sprite": "res://assets/sprites/operation/operation_accessories_table.png", "pos": Vector2(608, 336)},
		{"sprite": "res://assets/sprites/operation/operation_console_table.png", "pos": Vector2(480, 416)},
		{"sprite": "res://assets/sprites/operation/operation_ecg_full.png", "pos": Vector2(608, 416)},
		{"sprite": "res://assets/sprites/operation/operation_ecg_screen.png", "pos": Vector2(608, 400)},
		{"sprite": "res://assets/sprites/operation/operation_ultrasound_machine.png", "pos": Vector2(480, 464)},
		{"sprite": "res://assets/sprites/operation/operation_scalpel_01.png", "pos": Vector2(608, 320)},
		{"sprite": "res://assets/sprites/operation/operation_scalpel_02.png", "pos": Vector2(624, 320)},
		{"sprite": "res://assets/sprites/operation/operation_ct_scanner.png", "pos": Vector2(688, 304)},
		{"sprite": "res://assets/sprites/operation/operation_table.png", "pos": Vector2(768, 304)},
		{"sprite": "res://assets/sprites/operation/operation_ultrasound_machine.png", "pos": Vector2(768, 384)},
		{"sprite": "res://assets/sprites/operation/operation_ecg_full.png", "pos": Vector2(688, 416)},
		{"sprite": "res://assets/sprites/operation/operation_radiation_sign.png", "pos": Vector2(800, 288)},
		{"sprite": "res://assets/sprites/operation/operation_console_computer.png", "pos": Vector2(688, 464)},
		{"sprite": "res://assets/sprites/maternity/maternity_bed.png", "pos": Vector2(864, 320)},
		{"sprite": "res://assets/sprites/maternity/maternity_carpet.png", "pos": Vector2(880, 432)},
		{"sprite": "res://assets/sprites/maternity/maternity_light.png", "pos": Vector2(928, 320)},
		{"sprite": "res://assets/sprites/maternity/maternity_chair.png", "pos": Vector2(848, 416)},
		{"sprite": "res://assets/sprites/maternity/maternity_ball.png", "pos": Vector2(944, 416)},
		{"sprite": "res://assets/sprites/maternity/maternity_table.png", "pos": Vector2(848, 464)},
		{"sprite": "res://assets/sprites/maternity/maternity_work_cabinet.png", "pos": Vector2(944, 464)},
		{"sprite": "res://assets/sprites/maternity/maternity_towel_01.png", "pos": Vector2(864, 400)},
		{"sprite": "res://assets/sprites/maternity/maternity_towel_02.png", "pos": Vector2(880, 400)},
		{"sprite": "res://assets/sprites/maternity/maternity_cottons.png", "pos": Vector2(896, 400)},
		{"sprite": "res://assets/sprites/maternity/maternity_birthing_rope.png", "pos": Vector2(848, 320)},
		{"sprite": "res://assets/sprites/room/room_cabinet.png", "pos": Vector2(1104, 288)},
		{"sprite": "res://assets/sprites/room/room_hand_sanitizer.png", "pos": Vector2(992, 416)},
		{"sprite": "res://assets/sprites/room/room_flower.png", "pos": Vector2(32, 224)},
		{"sprite": "res://assets/sprites/room/room_flower.png", "pos": Vector2(192, 256)},
		{"sprite": "res://assets/sprites/room/room_flower.png", "pos": Vector2(432, 224)},
		{"sprite": "res://assets/sprites/room/room_flower.png", "pos": Vector2(832, 256)},
		{"sprite": "res://assets/sprites/room/room_flower.png", "pos": Vector2(1104, 224)},
		{"sprite": "res://assets/sprites/lab/lab_medium_table.png", "pos": Vector2(528, 224)},
		{"sprite": "res://assets/sprites/lab/lab_medium_table.png", "pos": Vector2(560, 224)},
		{"sprite": "res://assets/sprites/lab/lab_medium_table.png", "pos": Vector2(592, 224)},
		{"sprite": "res://assets/sprites/lab/lab_computer.png", "pos": Vector2(544, 224)},
		{"sprite": "res://assets/sprites/room/room_bed_h.png", "pos": Vector2(1008, 608)},
		{"sprite": "res://assets/sprites/props/astronaut_626.png", "pos": Vector2(194, 65), "size": Vector2(25, 25)},
		{"sprite": "res://assets/sprites/props/medicine_jar_629.png", "pos": Vector2(306, 81), "size": Vector2(14, 14)},
		{"sprite": "res://assets/sprites/props/medicine_jar_631.png", "pos": Vector2(324, 81), "size": Vector2(14, 14)},
		{"sprite": "res://assets/sprites/props/medicine_jar_647.png", "pos": Vector2(370, 81), "size": Vector2(14, 14)},
		{"sprite": "res://assets/sprites/props/blister_pack_630.png", "pos": Vector2(308, 81), "size": Vector2(14, 14)},
		{"sprite": "res://assets/sprites/props/blister_pack_656.png", "pos": Vector2(372, 81), "size": Vector2(14, 14)},
		{"sprite": "res://assets/sprites/props/first_aid_kit_635.png", "pos": Vector2(401, 17), "size": Vector2(15, 15)},
		{"sprite": "res://assets/sprites/props/syringe_632.png", "pos": Vector2(504, 129), "size": Vector2(15, 15)},
		{"sprite": "res://assets/sprites/props/first_aid_kit_636.png", "pos": Vector2(449, 161), "size": Vector2(15, 15)},
		{"sprite": "res://assets/sprites/props/robot_668.png", "pos": Vector2(961, 161), "size": Vector2(15, 15)},
		{"sprite": "res://assets/sprites/props/test_tube_665.png", "pos": Vector2(772, 129), "size": Vector2(14, 14)},
		{"sprite": "res://assets/sprites/props/medicine_box_637.png", "pos": Vector2(1025, 81), "size": Vector2(14, 14)},
		{"sprite": "res://assets/sprites/props/medicine_box_646.png", "pos": Vector2(1041, 81), "size": Vector2(14, 14)},
		{"sprite": "res://assets/sprites/props/medicine_box_655.png", "pos": Vector2(1057, 81), "size": Vector2(14, 14)},
		{"sprite": "res://assets/sprites/props/first_aid_box_659.png", "pos": Vector2(1073, 81), "size": Vector2(14, 14)},
		{"sprite": "res://assets/sprites/props/unknown_canister_660.png", "pos": Vector2(1105, 161), "size": Vector2(15, 15)},
		{"sprite": "res://assets/sprites/props/first_aid_kit_641.png", "pos": Vector2(161, 289), "size": Vector2(15, 15)},
		{"sprite": "res://assets/sprites/props/oxygen_tank_643.png", "pos": Vector2(369, 321), "size": Vector2(15, 15)},
		{"sprite": "res://assets/sprites/props/blood_bag_642.png", "pos": Vector2(417, 305), "size": Vector2(14, 14)},
		{"sprite": "res://assets/sprites/props/first_aid_kit_662.png", "pos": Vector2(305, 497), "size": Vector2(15, 15)},
		{"sprite": "res://assets/sprites/props/first_aid_kit_663.png", "pos": Vector2(465, 513), "size": Vector2(15, 15)},
		{"sprite": "res://assets/sprites/props/wheelchair_627.png", "pos": Vector2(257, 237), "size": Vector2(22, 22)},
		{"sprite": "res://assets/sprites/props/wheelchair_640.png", "pos": Vector2(481, 237), "size": Vector2(22, 22)},
		{"sprite": "res://assets/sprites/props/wheelchair_648.png", "pos": Vector2(705, 237), "size": Vector2(22, 22)},
		{"sprite": "res://assets/sprites/props/wheelchair_667.png", "pos": Vector2(913, 594), "size": Vector2(22, 22)},
		# --- شماتیک (اسپرایت واقعی ندارند؛ §۸ design.md) ---
		# پذیرش: دستگاه فروش، آکواریوم، گوشه‌ی کودکان.
		{"rect": Rect2i(2, 4, 1, 2), "color": Color("#9A9A9A"), "label": "دستگاه فروش"},
		{"rect": Rect2i(2, 10, 2, 1), "color": Color("#5B8DEF"), "label": "آکواریوم"},
		{"rect": Rect2i(10, 10, 4, 2), "color": Color("#E8A0B4"), "label": "گوشه‌ی کودکان"},
		# معاینه: تابلوی چشم.
		{"rect": Rect2i(33, 1, 1, 1), "color": Color("#F2EFE6"), "label": "تابلوی چشم"},
		# انبار: جعبه‌ها.
		{"rect": Rect2i(64, 8, 1, 1), "color": Color("#BE9664"), "label": "جعبه"},
		{"rect": Rect2i(66, 8, 1, 1), "color": Color("#BE9664"), "label": ""},
		{"rect": Rect2i(68, 8, 1, 1), "color": Color("#BE9664"), "label": ""},
		# سرویس: روشویی و توالت.
		{"rect": Rect2i(14, 19, 1, 1), "color": Color("#6EC6C6"), "label": "روشویی"},
		{"rect": Rect2i(16, 19, 1, 1), "color": Color("#6EC6C6"), "label": ""},
		{"rect": Rect2i(14, 22, 1, 1), "color": Color("#F2EFE6"), "label": "توالت"},
		{"rect": Rect2i(16, 22, 1, 1), "color": Color("#F2EFE6"), "label": ""},
		# راهرو: نیمکت‌ها.
		{"rect": Rect2i(5, 14, 5, 1), "color": Color("#C9A86A"), "label": "نیمکت"},
		{"rect": Rect2i(20, 16, 5, 1), "color": Color("#C9A86A"), "label": ""},
		{"rect": Rect2i(45, 14, 5, 1), "color": Color("#C9A86A"), "label": ""},
		{"rect": Rect2i(58, 16, 5, 1), "color": Color("#C9A86A"), "label": ""},
		# اتاق عمل: چهارپایه‌ها.
		{"rect": Rect2i(31, 24, 1, 1), "color": Color("#9A9A9A"), "label": "چهارپایه"},
		{"rect": Rect2i(37, 28, 1, 1), "color": Color("#9A9A9A"), "label": ""},
		# رادیولوژی: روپوش سربی + حلقه‌ی MRI.
		{"rect": Rect2i(47, 18, 1, 1), "color": Color("#8C8C96"), "label": "روپوش سربی"},
		{"rect": Rect2i(48, 18, 1, 1), "color": Color("#8C8C96"), "label": ""},
		{"rect": Rect2i(44, 30, 3, 3), "color": Color("#B9B9C0"), "label": "MRI"},
		# زایمان: ۳ گهواره.
		{"rect": Rect2i(54, 18, 1, 1), "color": Color("#E8A0B4"), "label": "گهواره"},
		{"rect": Rect2i(56, 18, 1, 1), "color": Color("#7FB3D5"), "label": ""},
		{"rect": Rect2i(58, 18, 1, 1), "color": Color("#E8C832"), "label": ""},
		# دندان‌پزشکی: ۲ صندلی + پوستر دندان + چهارپایه.
		{"rect": Rect2i(63, 21, 3, 2), "color": Color("#2EC4B6"), "label": "صندلی دندان‌پزشکی"},
		{"rect": Rect2i(67, 21, 3, 2), "color": Color("#2EC4B6"), "label": ""},
		{"rect": Rect2i(63, 18, 1, 1), "color": Color("#F2EFE6"), "label": "پوستر دندان"},
		{"rect": Rect2i(64, 25, 1, 1), "color": Color("#5B8DEF"), "label": ""},
	]