# اسموک‌تست صحنه‌ی اصلی: ساخت پنل هر ۶ پازل، راهنما، درِ خروج و پایان بازی.
# اجرا: godot --headless --path . -s res://scripts/tests/test_ui_smoke.gd
extends SceneTree

var _passed := 0
var _failed := 0
var _failures: Array[String] = []


func _init() -> void:
	var packed: PackedScene = load("res://main.tscn")
	var main = packed.instantiate()
	root.add_child(main)
	await process_frame
	await process_frame

	_check("main: صحنه ساخته شد", main != null)
	_check("main: شمارنده‌ی کلید اول «۰ از ۶» است", main._key_label.text.contains("۰ از ۶"))
	_check("main: پیام آغازین دیده می‌شود", main._intro.visible)

	# راهنما با Q باز و بسته می‌شود.
	main._toggle_guide()
	_check("guide: بعد از Q راهنما باز است", main._guide_open and main._guide_panel.visible)
	_check("guide: پیام آغازین بعد از دیدن راهنما محو می‌شود", not main._intro.visible)
	main._toggle_guide()
	_check("guide: با Q دوباره بسته می‌شود", not main._guide_open)

	# هر ۶ پنل پازل بدون خطا ساخته و بسته می‌شود.
	for puzzle_id in ["lab", "surgery", "radiology", "pharmacy", "icu", "maternity"]:
		main._open_puzzle(puzzle_id)
		await process_frame
		_check("puzzle %s: پنل باز می‌شود" % puzzle_id, main._puzzle_ui != null)
		_check("puzzle %s: بازیکن هنگام پازل فریز است" % puzzle_id, main.player.frozen)
		main._close_puzzle()
		await process_frame
		_check("puzzle %s: پنل بسته می‌شود و بازیکن آزاد می‌شود" % puzzle_id, main._puzzle_ui == null and not main.player.frozen)

	# درِ خروج با ۰ کلید باز نمی‌شود؛ با ۶ کلید صفحه‌ی پایان می‌آید.
	main._interact_door()
	_check("door: با ۰ کلید صفحه‌ی پایان نمی‌آید", not main._end_panel.visible)
	for puzzle_id in ["lab", "surgery", "radiology", "pharmacy", "icu", "maternity"]:
		main._on_puzzle_solved(puzzle_id)
	_check("door: بعد از ۶ کلید شمارنده «۶ از ۶» است", main._key_label.text.contains("۶ از ۶"))
	main._interact_door()
	_check("door: با ۶ کلید صفحه‌ی پایان می‌آید", main._end_panel.visible)
	_check("door: بعد از ۶ کلید برخورد در برداشته شده است", main.map_view._exit_body == null)

	print("----")
	print("WHITE HOSPITAL UI SMOKE: %d passed, %d failed" % [_passed, _failed])
	for f in _failures:
		print("FAIL: " + f)
	if _failed == 0:
		print("ALL UI SMOKE TESTS PASSED")
		quit(0)
		return
	quit(1)


func _check(name: String, ok: bool) -> void:
	if ok:
		_passed += 1
	else:
		_failed += 1
		_failures.append(name)
