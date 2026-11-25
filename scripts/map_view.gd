# رندر شماتیک نقشه + برخورد دیوارها.
# کف سفید پیوسته، دیوار روشن، لبه‌ها بدنه‌ی فلزی سفینه، جنوب ایrlاک.
class_name WhiteHospitalMapView
extends Node2D

var solved: Dictionary = {}
var _font: Font
var _exit_body: StaticBody2D


func _ready() -> void:
	_font = load("res://assets/fonts/Vazirmatn-Regular.ttf")
	_build_collisions()
	queue_redraw()


func refresh(p_solved: Dictionary) -> void:
	solved = p_solved.duplicate()
	queue_redraw()


func open_exit_door() -> void:
	if is_instance_valid(_exit_body):
		_exit_body.queue_free()
		_exit_body = null
	queue_redraw()


func _build_collisions() -> void:
	var body := StaticBody2D.new()
	body.name = "Walls"
	add_child(body)
	for r in WhiteHospitalMap.wall_rects():
		body.add_child(_wall_shape(r))
	# درِ خروج سفینه تا وقتی ۶ کلید جمع نشده بسته است.
	_exit_body = StaticBody2D.new()
	_exit_body.name = "ExitDoor"
	add_child(_exit_body)
	_exit_body.add_child(_wall_shape(Rect2i(WhiteHospitalMap.EXIT_DOOR_START, 43, 2, 1)))


func _wall_shape(r: Rect2i) -> CollisionShape2D:
	var shape := CollisionShape2D.new()
	var rect := RectangleShape2D.new()
	rect.size = Vector2(r.size.x * WhiteHospitalMap.TILE, r.size.y * WhiteHospitalMap.TILE)
	shape.shape = rect
	shape.position = Vector2(
		(r.position.x + r.size.x / 2.0) * WhiteHospitalMap.TILE,
		(r.position.y + r.size.y / 2.0) * WhiteHospitalMap.TILE
	)
	return shape


func _draw() -> void:
	var t := WhiteHospitalMap.TILE
	# کف سفید پیوسته‌ی کل ساختمان.
	draw_rect(Rect2(0, 0, WhiteHospitalMap.MAP_W_PX, WhiteHospitalMap.MAP_H_PX), Color.WHITE)
	# کف فلزی ایrlاک جنوبی.
	var air := WhiteHospitalMap.AIRLOCK_RECT
	draw_rect(
		Rect2(air.position * t, Vector2(air.size.x * t, air.size.y * t)),
		WhiteHospitalMap.AIRLOCK_FLOOR
	)
	# دیوارها.
	for r in WhiteHospitalMap.wall_rects():
		var px := Rect2(r.position * t, Vector2(r.size.x * t, r.size.y * t))
		draw_rect(px, WhiteHospitalMap.WALL_BODY)
		# لبه‌ی بالایی دیوار (cap).
		draw_rect(Rect2(px.position, Vector2(px.size.x, 4)), WhiteHospitalMap.WALL_CAP)
	# بدنه‌ی فلزی سفینه روی لبه‌های بیرونی نقشه.
	_draw_hull()
	# نوار لهجه‌ی هر اتاق (بالای دیوار اتاق) + نام اتاق.
	for room in WhiteHospitalMap.ROOMS:
		var r: Rect2i = room["rect"]
		var accent: Color = room["accent"]
		draw_rect(Rect2(r.position.x * t, (r.position.y - 1) * t + 12, r.size.x * t, 4), accent)
		_draw_centered_text(
			String(room["name"]),
			Vector2((r.position.x + r.size.x / 2.0) * t, (r.position.y + r.size.y - 1.0) * t),
			13, Color(0, 0, 0, 0.35)
		)
	# وسایل شماتیک.
	for item in WhiteHospitalMap.furniture():
		var r: Rect2i = item["rect"]
		var px := Rect2(r.position * t, Vector2(r.size.x * t, r.size.y * t))
		# سایه‌ی نرم ۲۵٪، یک پیکسل پایین‌تر.
		draw_rect(Rect2(px.position + Vector2(0, 1), px.size), Color(0, 0, 0, 0.25))
		draw_rect(px, item["color"])
		draw_rect(px, Color(0, 0, 0, 0.35), false, 1.0)
		if String(item["label"]) != "":
			_draw_centered_text(
				String(item["label"]),
				px.get_center() + Vector2(0, px.size.y / 2.0 + 8),
				11, Color(0, 0, 0, 0.55)
			)
	# تابلوهای راهرو: نام هر اتاق کنار درش.
	_draw_centered_text("راهرو", Vector2(36 * t, 15.5 * t), 13, Color(0, 0, 0, 0.35))
	# ایrlاک: خط زرد خط‌چین دور درِ خروج + تابلوی EXIT + در.
	var exit_x := WhiteHospitalMap.EXIT_DOOR_START * t
	draw_rect(Rect2(exit_x - 8, 40 * t, 48, 3 * t), WhiteHospitalMap.AIRLOCK_LINE)
	_draw_centered_text("EXIT", Vector2(exit_x + 16, 40.5 * t), 16, WhiteHospitalMap.EXIT_RED)
	var door_color := WhiteHospitalMap.EXIT_RED if solved.size() < WhiteHospitalLogic.TOTAL_KEYS else Color("#4CAF7D")
	draw_rect(Rect2(exit_x, 43 * t, 2 * t, t), door_color)
	_draw_centered_text("ایrlاک — درِ خروج سفینه", Vector2(36 * t, 38 * t), 14, Color(0, 0, 0, 0.5))
	# نقطه‌های تعامل پازل: «!» زرد، بعد از حل «✓» سبز.
	for puzzle_id in WhiteHospitalMap.puzzle_spots():
		var pos: Vector2 = WhiteHospitalMap.puzzle_spots()[puzzle_id]
		var done := bool(solved.get(puzzle_id, false))
		var col := Color("#4CAF7D") if done else Color("#E8C832")
		draw_circle(pos + Vector2(0, -14), 10, col)
		draw_arc(pos + Vector2(0, -14), 10, 0, TAU, 24, Color(0, 0, 0, 0.4), 1.5)
		_draw_centered_text("✓" if done else "!", pos + Vector2(0, -14), 13, Color.WHITE)


func _draw_hull() -> void:
	var t := WhiteHospitalMap.TILE
	var w := WhiteHospitalMap.MAP_W_PX
	var h := WhiteHospitalMap.MAP_H_PX
	draw_rect(Rect2(0, 0, w, t), WhiteHospitalMap.HULL_METAL)
	draw_rect(Rect2(0, h - t, w, t), WhiteHospitalMap.HULL_METAL)
	draw_rect(Rect2(0, 0, t, h), WhiteHospitalMap.HULL_METAL)
	draw_rect(Rect2(w - t, 0, t, h), WhiteHospitalMap.HULL_METAL)
	# درز پنل‌های بدنه هر ۴ تایل.
	for x in range(0, WhiteHospitalMap.MAP_W_TILES, 4):
		draw_line(Vector2(x * t, 0), Vector2(x * t, t), WhiteHospitalMap.HULL_SEAM, 1.0)
		draw_line(Vector2(x * t, h - t), Vector2(x * t, h), WhiteHospitalMap.HULL_SEAM, 1.0)
	for y in range(0, WhiteHospitalMap.MAP_H_TILES, 4):
		draw_line(Vector2(0, y * t), Vector2(t, y * t), WhiteHospitalMap.HULL_SEAM, 1.0)
		draw_line(Vector2(w - t, y * t), Vector2(w, y * t), WhiteHospitalMap.HULL_SEAM, 1.0)


func _draw_centered_text(text: String, center: Vector2, size: int, color: Color) -> void:
	if _font == null:
		return
	var ts := _font.get_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1, size)
	draw_string(_font, center - Vector2(ts.x / 2.0, -ts.y / 4.0), text, HORIZONTAL_ALIGNMENT_LEFT, -1, size, color)
