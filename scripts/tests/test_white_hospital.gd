# تست خودکار منطق «بیمارستان سفید» — بدون صحنه، فقط قانون‌های پازل،
# شمارنده‌ی کلید و درِ خروج.
# اجرا: godot --headless --path . -s res://scripts/tests/test_white_hospital.gd
extends SceneTree

var _passed := 0
var _failed := 0
var _failures: Array[String] = []


func _init() -> void:
	var Logic = load("res://scripts/puzzle_logic.gd")

	# --- پازل ۱: آزمایشگاه ---
	_check("lab: ترتیب درست قبول می‌شود", Logic.lab_is_solved(["blue", "green", "yellow", "red"]))
	_check("lab: ترتیب برعکس رد می‌شود", not Logic.lab_is_solved(["red", "yellow", "green", "blue"]))
	_check("lab: جابه‌جایی دو لوله رد می‌شود", not Logic.lab_is_solved(["green", "blue", "yellow", "red"]))
	_check("lab: لیست ناقص رد می‌شود", not Logic.lab_is_solved(["blue", "green", "yellow"]))

	# --- پازل ۲: اتاق عمل ---
	_check("surgery: اولین ابزار موردانتظار چاقوست", Logic.surgery_expected_at(0) == "scalpel")
	_check("surgery: سومین ابزار موردانتظار پنس است", Logic.surgery_expected_at(2) == "forceps")
	_check("surgery: ترتیب کامل درست قبول می‌شود", Logic.surgery_is_correct_sequence(["scalpel", "scissors", "forceps", "needle", "clamp"]))
	_check("surgery: ترتیب اشتباه رد می‌شود", not Logic.surgery_is_correct_sequence(["scissors", "scalpel", "forceps", "needle", "clamp"]))
	_check("surgery: ترتیب ناقص رد می‌شود", not Logic.surgery_is_correct_sequence(["scalpel", "scissors"]))

	# --- پازل ۳: رادیولوژی ---
	_check("radio: دست به «دست» می‌خورد", Logic.radiology_matches("hand", "دست"))
	_check("radio: جمجمه به «سر» می‌خورد", Logic.radiology_matches("skull", "سر"))
	_check("radio: دست به «پا» نمی‌خورد", not Logic.radiology_matches("hand", "پا"))
	_check("radio: قفسه‌ی سینه به «سینه» می‌خورد", Logic.radiology_matches("chest", "سینه"))
	_check("radio: هر ۴ جفت درست یعنی حل‌شده", Logic.radiology_is_solved({"hand": "دست", "foot": "پا", "chest": "سینه", "skull": "سر"}))
	_check("radio: ۳ جفت درست یعنی حل‌نشده", not Logic.radiology_is_solved({"hand": "دست", "foot": "پا", "chest": "سینه"}))

	# --- پازل ۴: داروخانه ---
	_check("pharmacy: ۴ قرمز + ۲ آبی + ۱ زرد قبول می‌شود", Logic.pharmacy_is_correct({"red": 4, "blue": 2, "yellow": 1}))
	_check("pharmacy: ۳ قرمز رد می‌شود", not Logic.pharmacy_is_correct({"red": 3, "blue": 2, "yellow": 1}))
	_check("pharmacy: ۵ قرمز رد می‌شود", not Logic.pharmacy_is_correct({"red": 5, "blue": 2, "yellow": 1}))
	_check("pharmacy: ۳ آبی رد می‌شود", not Logic.pharmacy_is_correct({"red": 4, "blue": 3, "yellow": 1}))
	_check("pharmacy: ۰ زرد رد می‌شود", not Logic.pharmacy_is_correct({"red": 4, "blue": 2, "yellow": 0}))
	_check("pharmacy: تا سقف نسخه می‌شود اضافه کرد", Logic.pharmacy_can_add({"red": 3, "blue": 2, "yellow": 1}, "red"))
	_check("pharmacy: بعد از سقف نسخه نمی‌شود اضافه کرد", not Logic.pharmacy_can_add({"red": 4, "blue": 2, "yellow": 1}, "red"))

	# --- پازل ۵: ICU ---
	_check("icu: ۷۲ / ۹۸٪ / ۱۲۰/۸۰ سالم است", Logic.icu_is_healthy(72, 98, 120, 80))
	_check("icu: مقادیر شروع (۱۲۰ / ۸۹٪ / ۱۶۰/۱۰۰) ناسالم است", not Logic.icu_is_healthy(120, 89, 160, 100))
	_check("icu: مرز پایین ضربان (۶۰) سالم است", Logic.icu_is_healthy(60, 98, 120, 80))
	_check("icu: مرز بالای ضربان (۱۰۰) سالم است", Logic.icu_is_healthy(100, 98, 120, 80))
	_check("icu: ضربان ۵۹ ناسالم است", not Logic.icu_is_healthy(59, 98, 120, 80))
	_check("icu: ضربان ۱۰۱ ناسالم است", not Logic.icu_is_healthy(101, 98, 120, 80))
	_check("icu: اکسیژن ۹۴ ناسالم است", not Logic.icu_is_healthy(72, 94, 120, 80))
	_check("icu: اکسیژن ۹۵ سالم است", Logic.icu_is_healthy(72, 95, 120, 80))
	_check("icu: فشار ۱۳۰/۸۰ ناسالم است", not Logic.icu_is_healthy(72, 98, 130, 80))
	_check("icu: فشار ۱۲۰/۹۰ ناسالم است", not Logic.icu_is_healthy(72, 98, 120, 90))

	# --- پازل ۶: زایمان ---
	_check("maternity: کارت صورتی به گهواره‌ی صورتی می‌خورد", Logic.maternity_matches("pink", "pink"))
	_check("maternity: کارت آبی به گهواره‌ی آبی می‌خورد", Logic.maternity_matches("blue", "blue"))
	_check("maternity: کارت صورتی به گهواره‌ی آبی نمی‌خورد", not Logic.maternity_matches("pink", "blue"))
	_check("maternity: کارت زرد به گهواره‌ی صورتی نمی‌خورد", not Logic.maternity_matches("yellow", "pink"))

	# --- پیشرفت بازی: کلیدها و درِ خروج ---
	var progress = Logic.GameProgress.new()
	_check("progress: اول بازی ۰ کلید است", progress.key_count() == 0)
	_check("progress: اول بازی در باز نمی‌شود", not progress.can_open_door())
	_check("progress: پیام درِ قفل تعداد کلید را می‌گوید", progress.door_message().contains("۰ کلید"))
	_check("progress: حل آزمایشگاه یک کلید می‌دهد", progress.solve("lab") and progress.key_count() == 1)
	_check("progress: حل دوباره‌ی همان پازل کلید نمی‌دهد", not progress.solve("lab") and progress.key_count() == 1)
	_check("progress: پازل ناموجود حل نمی‌شود", not progress.solve("nope"))
	_check("progress: با ۵ کلید در هنوز بسته است", _solve_five(progress) and not progress.can_open_door())
	_check("progress: با ۶ کلید در باز می‌شود", progress.solve("maternity") and progress.can_open_door())
	_check("progress: پیام درِ باز درست است", progress.door_message().contains("باز است"))

	# --- اعداد فارسی ---
	_check("fa_num: ۳ می‌شود «۳»", Logic.fa_num(3) == "۳")
	_check("fa_num: ۶ می‌شود «۶»", Logic.fa_num(6) == "۶")

	# --- اسپرایت‌های واقعی ست شده‌اند (نه شماتیک خالی) ---
	var player_tex_dir := "res://assets/sprites/player/"
	for dir in ["down", "left", "right", "up"]:
		_check("sprite: فریم idle جراح (%s) لود می‌شود" % dir, load(player_tex_dir + "surgeon_idle_%s.png" % dir) != null)
		_check("sprite: فریم walk جراح (%s) لود می‌شود" % dir, load(player_tex_dir + "surgeon_walk_%s.png" % dir) != null)
	var puzzle_sprites := {
		"lab": "res://assets/sprites/lab/lab_large_table.png",
		"surgery": "res://assets/sprites/operation/operation_accessories_table_full.png",
		"radiology": "res://assets/sprites/operation/operation_ct_scanner.png",
		"pharmacy": "res://assets/sprites/lab/lab_medium_table.png",
		"icu": "res://assets/sprites/room/room_ecg_screen.png",
		"maternity": "res://assets/sprites/maternity/maternity_bed.png",
	}
	for puzzle_id in puzzle_sprites:
		var tex = load(puzzle_sprites[puzzle_id])
		_check("sprite: اسپرایت نقطه‌ی پازل %s لود می‌شود" % puzzle_id, tex != null and tex.get_width() > 0)
	var sprite_items := 0
	var missing_sprites: Array[String] = []
	for item in WhiteHospitalMap.furniture():
		if item.has("sprite"):
			sprite_items += 1
			if load(String(item["sprite"])) == null:
				missing_sprites.append(String(item["sprite"]))
	_check("sprite: همه‌ی اسپرایت‌های furniture لود می‌شوند (%d مورد)" % sprite_items, sprite_items > 100 and missing_sprites.is_empty())
	_check("sprite: شیت‌های AtlasTexture لود می‌شوند", load("res://assets/sprites/sheets/spritesheet_hospital_01.tres") != null and load("res://assets/sprites/sheets/spritesheet_hospital_lab.tres") != null)

	print("----")
	print("WHITE HOSPITAL TESTS: %d passed, %d failed" % [_passed, _failed])
	for f in _failures:
		print("FAIL: " + f)
	if _failed == 0:
		print("ALL TESTS PASSED")
		quit(0)
		return
	quit(1)


func _solve_five(progress) -> bool:
	for puzzle_id in ["surgery", "radiology", "pharmacy", "icu"]:
		progress.solve(puzzle_id)
	return progress.key_count() == 5


func _check(name: String, ok: bool) -> void:
	if ok:
		_passed += 1
	else:
		_failed += 1
		_failures.append(name)
