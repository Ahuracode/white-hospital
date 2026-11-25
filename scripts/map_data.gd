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


# وسایل شماتیک هر اتاق (مستطیل تایل + رنگ + برچسب کوتاه).
# فقط راهنمایی بصری‌اند؛ برخورد ندارند.
static func furniture() -> Array:
	return [
		# پذیرش
		{"rect": Rect2i(3, 3, 6, 1), "color": Color("#8A7B63"), "label": "پیشخوان"},
		{"rect": Rect2i(2, 8, 2, 1), "color": Color("#5B8DEF"), "label": ""},
		{"rect": Rect2i(5, 8, 2, 1), "color": Color("#5B8DEF"), "label": ""},
		{"rect": Rect2i(10, 8, 2, 1), "color": Color("#5B8DEF"), "label": ""},
		# داروخانه
		{"rect": Rect2i(17, 2, 1, 4), "color": Color("#4CAF7D"), "label": "قفسه"},
		{"rect": Rect2i(19, 2, 1, 4), "color": Color("#4CAF7D"), "label": ""},
		{"rect": Rect2i(21, 2, 1, 4), "color": Color("#4CAF7D"), "label": ""},
		{"rect": Rect2i(23, 2, 1, 4), "color": Color("#4CAF7D"), "label": ""},
		{"rect": Rect2i(20, 6, 3, 1), "color": Color("#8A7B63"), "label": "پیشخوان"},
		# معاینه
		{"rect": Rect2i(30, 5, 2, 4), "color": Color("#7FB3D5"), "label": "تخت"},
		# مطب
		{"rect": Rect2i(39, 3, 4, 1), "color": Color("#8A7B63"), "label": "میز"},
		# آزمایشگاه
		{"rect": Rect2i(50, 5, 9, 2), "color": Color("#9A9A9A"), "label": "میز بزرگ آزمایشگاه"},
		{"rect": Rect2i(48, 2, 2, 2), "color": Color("#7FB069"), "label": "یخچال"},
		{"rect": Rect2i(59, 9, 2, 1), "color": Color("#5B8DEF"), "label": "ربات"},
		# انبار
		{"rect": Rect2i(64, 3, 2, 2), "color": Color("#9A9A9A"), "label": "جعبه"},
		{"rect": Rect2i(67, 3, 2, 2), "color": Color("#9A9A9A"), "label": ""},
		# بستری: ۶ تخت در دو ردیف سه‌تایی
		{"rect": Rect2i(2, 21, 3, 1), "color": Color("#7FB3D5"), "label": ""},
		{"rect": Rect2i(6, 21, 3, 1), "color": Color("#7FB3D5"), "label": ""},
		{"rect": Rect2i(9, 21, 3, 1), "color": Color("#7FB3D5"), "label": ""},
		{"rect": Rect2i(2, 28, 3, 1), "color": Color("#7FB3D5"), "label": ""},
		{"rect": Rect2i(6, 28, 3, 1), "color": Color("#7FB3D5"), "label": ""},
		{"rect": Rect2i(9, 28, 3, 1), "color": Color("#7FB3D5"), "label": ""},
		# سرویس
		{"rect": Rect2i(15, 20, 2, 1), "color": Color("#6EC6C6"), "label": "روشویی"},
		# ICU
		{"rect": Rect2i(20, 25, 3, 1), "color": Color("#7FB3D5"), "label": "برانکارد"},
		{"rect": Rect2i(24, 25, 3, 1), "color": Color("#7FB3D5"), "label": ""},
		{"rect": Rect2i(22, 26, 2, 1), "color": Color("#E26D5A"), "label": "مانیتور"},
		# اتاق عمل
		{"rect": Rect2i(33, 25, 3, 2), "color": Color("#3FA7A0"), "label": "میز عمل"},
		{"rect": Rect2i(33, 30, 4, 1), "color": Color("#9A9A9A"), "label": "میز ابزار"},
		# رادیولوژی
		{"rect": Rect2i(44, 23, 4, 5), "color": Color("#4A90D9"), "label": "سی‌تی"},
		{"rect": Rect2i(49, 28, 2, 1), "color": Color("#9A9A9A"), "label": "میز ایکس‌ری"},
		# زایمان
		{"rect": Rect2i(54, 21, 3, 2), "color": Color("#E8A0B4"), "label": "تخت"},
		{"rect": Rect2i(54, 25, 1, 1), "color": Color("#E8A0B4"), "label": ""},
		{"rect": Rect2i(56, 25, 1, 1), "color": Color("#7FB3D5"), "label": ""},
		{"rect": Rect2i(58, 25, 1, 1), "color": Color("#E8C832"), "label": "گهواره‌ها"},
		{"rect": Rect2i(55, 29, 4, 2), "color": Color("#E8A0B4"), "label": "فرش"},
		# دندان‌پزشکی
		{"rect": Rect2i(63, 24, 3, 2), "color": Color("#2EC4B6"), "label": "صندلی"},
		{"rect": Rect2i(67, 24, 3, 2), "color": Color("#2EC4B6"), "label": ""},
		# راهرو: ایستگاه پرستار
		{"rect": Rect2i(33, 14, 6, 2), "color": Color("#8A7B63"), "label": "ایستگاه پرستار"},
		# ایrlاک
		{"rect": Rect2i(4, 38, 3, 1), "color": Color("#7FB3D5"), "label": "برانکارد"},
	]
