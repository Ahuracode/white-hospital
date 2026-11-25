# صحنه‌ی اصلی «بیمارستان سفید»: تاپ‌داون، HUD، راهنمای Q، پازل‌ها، درِ خروج.
extends Node2D

const INTERACT_DIST := 52.0
const DOOR_DIST := 64.0

var progress: WhiteHospitalLogic.GameProgress
var player: WhiteHospitalPlayer
var map_view: WhiteHospitalMapView

var _font: Font
var _font_bold: Font
var _hud: CanvasLayer
var _key_label: Label
var _toast: Label
var _prompt: Label
var _intro: Label
var _guide_panel: PanelContainer
var _guide_key_label: Label
var _end_panel: PanelContainer
var _puzzle_ui: WhiteHospitalPuzzleUI
var _puzzle_center: CenterContainer

var _ui_open := false
var _guide_open := false
var _current_spot := ""
var _toast_token := 0


func _ready() -> void:
	progress = WhiteHospitalLogic.GameProgress.new()
	_font = load("res://assets/fonts/Vazirmatn-Regular.ttf")
	_font_bold = load("res://assets/fonts/Vazirmatn-Bold.ttf")
	player = $Player
	map_view = $MapView
	_build_hud()
	_update_key_label()


func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		var key_event := event as InputEventKey
		match key_event.keycode:
			KEY_Q:
				if _puzzle_ui == null:
					_toggle_guide()
			KEY_ESCAPE:
				if _puzzle_ui != null:
					_close_puzzle()
				elif _guide_open:
					_toggle_guide()
			KEY_E:
				if not _ui_open and _current_spot != "":
					_interact_current_spot()
	if event is InputEventMouseButton:
		var mb := event as InputEventMouseButton
		if mb.pressed and mb.button_index == MOUSE_BUTTON_LEFT and not _ui_open:
			_click_world(mb)


func _click_world(mb: InputEventMouseButton) -> void:
	var world_pos := get_global_mouse_position()
	var best := ""
	var best_dist := INTERACT_DIST
	for puzzle_id in WhiteHospitalMap.puzzle_spots():
		var d := world_pos.distance_to(WhiteHospitalMap.puzzle_spots()[puzzle_id])
		if d < best_dist:
			best_dist = d
			best = puzzle_id
	if best != "":
		_open_puzzle(best)
		return
	if world_pos.distance_to(WhiteHospitalMap.exit_door_center()) < DOOR_DIST:
		_interact_door()


func _process(_delta: float) -> void:
	if _ui_open:
		return
	var player_pos := player.global_position
	var best := ""
	var best_dist := INTERACT_DIST
	for puzzle_id in WhiteHospitalMap.puzzle_spots():
		if progress.is_solved(puzzle_id):
			continue
		var d := player_pos.distance_to(WhiteHospitalMap.puzzle_spots()[puzzle_id])
		if d < best_dist:
			best_dist = d
			best = puzzle_id
	if best != "":
		_current_spot = best
		_prompt.text = "E — پازل " + String(WhiteHospitalLogic.PUZZLE_NAMES[best])
		_prompt.visible = true
		return
	if player_pos.distance_to(WhiteHospitalMap.exit_door_center()) < DOOR_DIST:
		_current_spot = "door"
		_prompt.text = "E — درِ خروج سفینه"
		_prompt.visible = true
		return
	_current_spot = ""
	_prompt.visible = false


func _interact_current_spot() -> void:
	if _current_spot == "door":
		_interact_door()
	elif _current_spot != "":
		_open_puzzle(_current_spot)


func _interact_door() -> void:
	if progress.can_open_door():
		_show_end()
	else:
		show_toast(progress.door_message())


func _open_puzzle(puzzle_id: String) -> void:
	if progress.is_solved(puzzle_id):
		show_toast("این پازل را قبلاً حل کرده‌ای.")
		return
	_ui_open = true
	player.frozen = true
	_puzzle_ui = WhiteHospitalPuzzleUI.new()
	_puzzle_ui.setup(puzzle_id, progress, _on_puzzle_solved)
	_puzzle_ui.tree_exited.connect(_on_puzzle_ui_exited)
	_puzzle_center.add_child(_puzzle_ui)
	_puzzle_center.visible = true
	_prompt.visible = false


func _on_puzzle_solved(puzzle_id: String) -> void:
	if progress.solve(puzzle_id):
		_update_key_label()
		map_view.refresh(progress.solved)
		show_toast(String(WhiteHospitalLogic.PUZZLE_KEY_NAMES[puzzle_id]) + " را گرفتی!")
		if progress.can_open_door():
			map_view.open_exit_door()


func _close_puzzle() -> void:
	if _puzzle_ui != null:
		_puzzle_ui.queue_free()


func _on_puzzle_ui_exited() -> void:
	_puzzle_ui = null
	_puzzle_center.visible = false
	_ui_open = false
	player.frozen = false


func _toggle_guide() -> void:
	_guide_open = not _guide_open
	_guide_panel.visible = _guide_open
	_ui_open = _guide_open
	player.frozen = _guide_open
	if _guide_open:
		_intro.visible = false
		_guide_key_label.text = "کلیدها: " + WhiteHospitalLogic.fa_num(progress.key_count()) + " از " + WhiteHospitalLogic.fa_num(WhiteHospitalLogic.TOTAL_KEYS)


func _show_end() -> void:
	_ui_open = true
	player.frozen = true
	_end_panel.visible = true


func _update_key_label() -> void:
	_key_label.text = "کلیدها: " + WhiteHospitalLogic.fa_num(progress.key_count()) + " از " + WhiteHospitalLogic.fa_num(WhiteHospitalLogic.TOTAL_KEYS)


func show_toast(text: String) -> void:
	_toast.text = text
	_toast.visible = true
	_toast_token += 1
	var token := _toast_token
	await get_tree().create_timer(3.5).timeout
	if token == _toast_token:
		_toast.visible = false


func _build_hud() -> void:
	_hud = CanvasLayer.new()
	_hud.name = "HUD"
	_hud.layer = 10
	add_child(_hud)

	_key_label = _make_label("", 22, true)
	_key_label.set_anchors_preset(Control.PRESET_CENTER_TOP)
	_key_label.position = Vector2(0, 12)
	_key_label.size = Vector2(1152, 40)
	_key_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_hud.add_child(_key_label)

	_intro = _make_label("کلید Q بزن تا راهنما رو ببینی", 24, true)
	_intro.set_anchors_preset(Control.PRESET_CENTER)
	_intro.position = Vector2(0, -120)
	_intro.size = Vector2(1152, 50)
	_intro.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_intro.add_theme_color_override("font_color", Color("#1A5276"))
	_hud.add_child(_intro)

	_prompt = _make_label("", 19, false)
	_prompt.set_anchors_preset(Control.PRESET_CENTER_BOTTOM)
	_prompt.position = Vector2(0, -90)
	_prompt.size = Vector2(1152, 40)
	_prompt.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_prompt.visible = false
	_hud.add_child(_prompt)

	_toast = _make_label("", 19, false)
	_toast.set_anchors_preset(Control.PRESET_CENTER_BOTTOM)
	_toast.position = Vector2(0, -50)
	_toast.size = Vector2(1152, 40)
	_toast.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_toast.visible = false
	_hud.add_child(_toast)

	_build_guide()
	_build_end()
	_puzzle_center = CenterContainer.new()
	_puzzle_center.set_anchors_preset(Control.PRESET_FULL_RECT)
	_puzzle_center.visible = false
	_hud.add_child(_puzzle_center)


func _build_guide() -> void:
	_guide_panel = PanelContainer.new()
	_guide_panel.set_anchors_preset(Control.PRESET_CENTER)
	_guide_panel.custom_minimum_size = Vector2(640, 420)
	_guide_panel.visible = false
	_hud.add_child(_guide_panel)
	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 24)
	margin.add_theme_constant_override("margin_right", 24)
	margin.add_theme_constant_override("margin_top", 18)
	margin.add_theme_constant_override("margin_bottom", 18)
	_guide_panel.add_child(margin)
	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 12)
	margin.add_child(vbox)
	vbox.add_child(_make_label("راهنمای بازی", 26, true))
	var goal := _make_label("هدف بازی: ۶ پازل بیمارستانی را حل کن، ۶ کلید بگیر و از درِ خروج سفینه بیرون برو.", 18, false)
	goal.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	vbox.add_child(goal)
	vbox.add_child(_make_label("حرکت: WASD یا کلیدهای جهت‌دار", 18, false))
	vbox.add_child(_make_label("تعامل با پازل: E یا کلیک روی نقطه‌ی «!»", 18, false))
	vbox.add_child(_make_label("بستن راهنما: Q یا Esc", 18, false))
	vbox.add_child(_make_label("درِ خروج فقط با ۶ کلید باز می‌شود.", 18, false))
	_guide_key_label = _make_label("", 20, true)
	vbox.add_child(_guide_key_label)
	var close_button := _make_button("بستن")
	close_button.pressed.connect(_toggle_guide)
	vbox.add_child(close_button)


func _build_end() -> void:
	_end_panel = PanelContainer.new()
	_end_panel.set_anchors_preset(Control.PRESET_CENTER)
	_end_panel.custom_minimum_size = Vector2(560, 300)
	_end_panel.visible = false
	_hud.add_child(_end_panel)
	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 24)
	margin.add_theme_constant_override("margin_right", 24)
	margin.add_theme_constant_override("margin_top", 18)
	margin.add_theme_constant_override("margin_bottom", 18)
	_end_panel.add_child(margin)
	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 14)
	margin.add_child(vbox)
	vbox.add_child(_make_label("از سفینه بیرون رفتی!", 28, true))
	vbox.add_child(_make_label("آفرین! هر ۶ کلید را پیدا کردی و از بیمارستان سفید بیرون رفتی.", 18, false))
	var again := _make_button("دوباره بازی کن")
	again.pressed.connect(func() -> void: get_tree().reload_current_scene())
	vbox.add_child(again)


func _make_label(text: String, size: int, bold: bool) -> Label:
	var l := Label.new()
	l.text = text
	l.add_theme_font_override("font", _font_bold if bold else _font)
	l.add_theme_font_size_override("font_size", size)
	return l


func _make_button(text: String) -> Button:
	var b := Button.new()
	b.text = text
	b.add_theme_font_override("font", _font)
	b.add_theme_font_size_override("font_size", 18)
	b.custom_minimum_size = Vector2(160, 48)
	return b
