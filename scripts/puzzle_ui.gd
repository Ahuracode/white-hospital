# نمای روبه‌رو (front view) هر پازل: پنل UI با دکمه‌ها و راهنمای داخل صحنه.
# جواب هر پازل داخل همین صحنه قابل کشف است (جدول مرجع / پوستر / نسخه /
# محدوده‌ی سالم / رنگ جوهر). بدون تایمر، بدون جریمه‌ی کلیک اشتباه.
class_name WhiteHospitalPuzzleUI
extends PanelContainer

const WRONG_MSG := "این درست نیست، دوباره امتحان کن."

var puzzle_id: String = ""
var _progress: WhiteHospitalLogic.GameProgress
var _on_solved: Callable
var _font: Font
var _font_bold: Font

var _msg: Label
var _content: VBoxContainer
var _back_button: Button
var _solved := false

# وضعیت پازل‌ها
var _lab_order: Array = []
var _lab_selected := -1
var _lab_buttons: Array[Button] = []
var _surgery_clicked: Array = []
var _surgery_buttons := {}
var _radio_selected := ""
var _radio_matched := {}
var _radio_image_buttons := {}
var _radio_label_buttons := {}
var _pharmacy_counts := {"red": 0, "blue": 0, "yellow": 0}
var _pharmacy_count_labels := {}
var _icu_hr := 0
var _icu_o2 := 0
var _icu_sys := 0
var _icu_dia := 0
var _icu_value_labels := {}
var _mat_selected := ""
var _mat_matched := {}
var _mat_card_buttons := {}
var _mat_cradle_buttons := {}


func setup(p_id: String, progress: WhiteHospitalLogic.GameProgress, on_solved: Callable) -> void:
	puzzle_id = p_id
	_progress = progress
	_on_solved = on_solved
	_font = load("res://assets/fonts/Vazirmatn-Regular.ttf")
	_font_bold = load("res://assets/fonts/Vazirmatn-Bold.ttf")
	custom_minimum_size = Vector2(780, 540)
	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 24)
	margin.add_theme_constant_override("margin_right", 24)
	margin.add_theme_constant_override("margin_top", 18)
	margin.add_theme_constant_override("margin_bottom", 18)
	add_child(margin)
	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 12)
	margin.add_child(vbox)
	var title := _make_label("پازل " + String(WhiteHospitalLogic.PUZZLE_NAMES[puzzle_id]), 26, true)
	vbox.add_child(title)
	var hint := _make_label(_hint_text(), 17, false)
	hint.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	vbox.add_child(hint)
	_content = VBoxContainer.new()
	_content.add_theme_constant_override("separation", 10)
	vbox.add_child(_content)
	_msg = _make_label("", 17, false)
	vbox.add_child(_msg)
	_back_button = _make_button("برگشت (Esc)")
	_back_button.pressed.connect(func() -> void: queue_free())
	vbox.add_child(_back_button)
	match puzzle_id:
		"lab":
			_build_lab()
		"surgery":
			_build_surgery()
		"radiology":
			_build_radiology()
		"pharmacy":
			_build_pharmacy()
		"icu":
			_build_icu()
		"maternity":
			_build_maternity()


func _hint_text() -> String:
	match puzzle_id:
		"lab":
			return "جدول مرجع روی دیوار: آبی = ۱، سبز = ۲، زرد = ۳، قرمز = ۴ — لوله‌ها را به ترتیب عددی بچین. روی یک لوله کلیک کن، بعد روی جای لوله‌ی دیگر کلیک کن تا جابه‌جا شوند."
		"surgery":
			return "پوستر روی دیوار: ۱ چاقو، ۲ قیچی، ۳ پنس، ۴ سوزن، ۵ گیره — ابزارها را به ترتیبی که در عمل استفاده می‌شوند انتخاب کن."
		"radiology":
			return "روی یک عکس کلیک کن، بعد روی برچسب عضو درستش کلیک کن."
		"pharmacy":
			return "نسخه روی پیشخوان: ۴ قرص قرمز + ۲ قرص آبی + ۱ قرص زرد — دقیقاً همان تعداد را بردار. روی قرصِ برداشته‌شده کلیک کن تا پس داده شود."
		"icu":
			return "مانیتور را به حالت سالم برگردان. محدوده‌ی سالم زیر هر مقدار نوشته شده است."
		"maternity":
			return "نام هر نوزاد با جوهری هم‌رنگ پتوی گهواره‌ی خودش نوشته شده است. روی یک کارت کلیک کن، بعد روی گهواره‌ی هم‌رنگش کلیک کن."
	return ""


func _make_label(text: String, size: int, bold: bool) -> Label:
	var l := Label.new()
	l.text = text
	l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	l.add_theme_font_override("font", _font_bold if bold else _font)
	l.add_theme_font_size_override("font_size", size)
	return l


func _make_button(text: String) -> Button:
	var b := Button.new()
	b.text = text
	b.add_theme_font_override("font", _font)
	b.add_theme_font_size_override("font_size", 18)
	b.custom_minimum_size = Vector2(120, 44)
	return b


func _set_msg(text: String, ok: bool = false) -> void:
	_msg.text = text
	_msg.add_theme_color_override("font_color", Color("#2E7D32") if ok else Color("#C62828"))


func _solve() -> void:
	if _solved:
		return
	_solved = true
	_set_msg("درست شد! " + String(WhiteHospitalLogic.PUZZLE_KEY_NAMES[puzzle_id]) + " را گرفتی!", true)
	_back_button.text = "ادامه"
	for child in _content.get_children():
		_disable_tree(child)
	_on_solved.call(puzzle_id)


func _disable_tree(node: Node) -> void:
	if node is Button:
		(node as Button).disabled = true
	for child in node.get_children():
		_disable_tree(child)


# --- پازل ۱: آزمایشگاه ---
func _build_lab() -> void:
	_lab_order = ["red", "yellow", "blue", "green"]
	var row := HBoxContainer.new()
	row.alignment = BoxContainer.ALIGNMENT_CENTER
	row.add_theme_constant_override("separation", 12)
	_content.add_child(row)
	for i in _lab_order.size():
		var color_id: String = _lab_order[i]
		var b := _make_button(String(WhiteHospitalLogic.LAB_COLOR_NAMES[color_id]))
		b.custom_minimum_size = Vector2(130, 90)
		b.add_theme_stylebox_override("normal", _color_box(WhiteHospitalLogic.LAB_COLOR_VALUES[color_id]))
		b.add_theme_color_override("font_color", Color.WHITE)
		b.pressed.connect(_on_lab_tube.bind(i))
		_lab_buttons.append(b)
		row.add_child(b)
	_refresh_lab()


func _color_box(c: Color) -> StyleBoxFlat:
	var s := StyleBoxFlat.new()
	s.bg_color = c
	s.corner_radius_top_left = 8
	s.corner_radius_top_right = 8
	s.corner_radius_bottom_left = 8
	s.corner_radius_bottom_right = 8
	return s


func _on_lab_tube(index: int) -> void:
	if _solved:
		return
	if _lab_selected == -1:
		_lab_selected = index
		_set_msg("حالا روی جای لوله‌ی دیگر کلیک کن تا جابه‌جا شود.")
		_refresh_lab()
		return
	if _lab_selected == index:
		_lab_selected = -1
		_set_msg("")
		_refresh_lab()
		return
	var tmp = _lab_order[_lab_selected]
	_lab_order[_lab_selected] = _lab_order[index]
	_lab_order[index] = tmp
	_lab_selected = -1
	_refresh_lab()
	if WhiteHospitalLogic.lab_is_solved(_lab_order):
		_solve()
	else:
		_set_msg("ترتیب هنوز درست نیست — ادامه بده.")


func _refresh_lab() -> void:
	for i in _lab_buttons.size():
		var color_id: String = _lab_order[i]
		_lab_buttons[i].text = String(WhiteHospitalLogic.LAB_COLOR_NAMES[color_id])
		_lab_buttons[i].add_theme_stylebox_override("normal", _color_box(WhiteHospitalLogic.LAB_COLOR_VALUES[color_id]))
		if i == _lab_selected:
			_lab_buttons[i].text += " (انتخاب شد)"


# --- پازل ۲: اتاق عمل ---
func _build_surgery() -> void:
	var shuffled: Array = ["forceps", "clamp", "scalpel", "needle", "scissors"]
	var row := HBoxContainer.new()
	row.alignment = BoxContainer.ALIGNMENT_CENTER
	row.add_theme_constant_override("separation", 10)
	_content.add_child(row)
	for tool_id in shuffled:
		var b := _make_button(String(WhiteHospitalLogic.SURGERY_TOOL_NAMES[tool_id]))
		b.custom_minimum_size = Vector2(130, 70)
		b.pressed.connect(_on_surgery_tool.bind(String(tool_id)))
		_surgery_buttons[tool_id] = b
		row.add_child(b)


func _on_surgery_tool(tool_id: String) -> void:
	if _solved:
		return
	var expected := WhiteHospitalLogic.surgery_expected_at(_surgery_clicked.size())
	if tool_id == expected:
		_surgery_clicked.append(tool_id)
		var b: Button = _surgery_buttons[tool_id]
		b.disabled = true
		b.add_theme_color_override("font_color", Color("#2E7D32"))
		if WhiteHospitalLogic.surgery_is_correct_sequence(_surgery_clicked):
			_solve()
		else:
			_set_msg("درست است! بعدی: " + String(WhiteHospitalLogic.SURGERY_TOOL_NAMES[WhiteHospitalLogic.surgery_expected_at(_surgery_clicked.size())]) + ".", true)
	else:
		_set_msg(WRONG_MSG)


# --- پازل ۳: رادیولوژی ---
func _build_radiology() -> void:
	var images := HBoxContainer.new()
	images.alignment = BoxContainer.ALIGNMENT_CENTER
	images.add_theme_constant_override("separation", 10)
	_content.add_child(images)
	for image_id in ["hand", "foot", "chest", "skull"]:
		var b := _make_button(String(WhiteHospitalLogic.RADIOLOGY_IMAGE_HINTS[image_id]))
		b.custom_minimum_size = Vector2(170, 80)
		b.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		b.pressed.connect(_on_radio_image.bind(image_id))
		_radio_image_buttons[image_id] = b
		images.add_child(b)
	var labels := HBoxContainer.new()
	labels.alignment = BoxContainer.ALIGNMENT_CENTER
	labels.add_theme_constant_override("separation", 10)
	_content.add_child(labels)
	for label_text in ["پا", "سر", "دست", "سینه"]:
		var b := _make_button(label_text)
		b.custom_minimum_size = Vector2(130, 60)
		b.pressed.connect(_on_radio_label.bind(label_text))
		_radio_label_buttons[label_text] = b
		labels.add_child(b)


func _on_radio_image(image_id: String) -> void:
	if _solved or image_id in _radio_matched:
		return
	_radio_selected = image_id
	_set_msg("حالا برچسب درست این عکس را انتخاب کن.")


func _on_radio_label(label_text: String) -> void:
	if _solved or _radio_selected == "":
		return
	if WhiteHospitalLogic.radiology_matches(_radio_selected, label_text):
		_radio_matched[_radio_selected] = label_text
		(_radio_image_buttons[_radio_selected] as Button).disabled = true
		(_radio_label_buttons[label_text] as Button).disabled = true
		(_radio_image_buttons[_radio_selected] as Button).add_theme_color_override("font_color", Color("#2E7D32"))
		_radio_selected = ""
		if WhiteHospitalLogic.radiology_is_solved(_radio_matched):
			_solve()
		else:
			_set_msg("درست است! ادامه بده.", true)
	else:
		_set_msg(WRONG_MSG)


# --- پازل ۴: داروخانه ---
func _build_pharmacy() -> void:
	var row := HBoxContainer.new()
	row.alignment = BoxContainer.ALIGNMENT_CENTER
	row.add_theme_constant_override("separation", 12)
	_content.add_child(row)
	for color_id in ["red", "blue", "yellow"]:
		var col := VBoxContainer.new()
		col.add_theme_constant_override("separation", 6)
		var b := _make_button("بطری قرص " + String(WhiteHospitalLogic.PHARMACY_COLOR_NAMES[color_id]))
		b.custom_minimum_size = Vector2(170, 70)
		b.add_theme_stylebox_override("normal", _color_box(WhiteHospitalLogic.LAB_COLOR_VALUES[color_id]))
		b.add_theme_color_override("font_color", Color.WHITE)
		b.pressed.connect(_on_pharmacy_add.bind(color_id))
		col.add_child(b)
		var count_label := _make_label("برداشته‌شده: ۰", 16, false)
		_pharmacy_count_labels[color_id] = count_label
		col.add_child(count_label)
		var back := _make_button("پس بده")
		back.custom_minimum_size = Vector2(120, 36)
		back.pressed.connect(_on_pharmacy_return.bind(color_id))
		col.add_child(back)
		row.add_child(col)
	var check := _make_button("بررسی نسخه")
	check.pressed.connect(_on_pharmacy_check)
	_content.add_child(check)


func _on_pharmacy_add(color_id: String) -> void:
	if _solved:
		return
	if WhiteHospitalLogic.pharmacy_can_add(_pharmacy_counts, color_id):
		_pharmacy_counts[color_id] = int(_pharmacy_counts[color_id]) + 1
		_refresh_pharmacy()
		_set_msg("")
	else:
		_set_msg("از این رنگ به اندازه‌ی نسخه برداشتی — اگر اشتباه است پس بده.")


func _on_pharmacy_return(color_id: String) -> void:
	if _solved:
		return
	if int(_pharmacy_counts[color_id]) > 0:
		_pharmacy_counts[color_id] = int(_pharmacy_counts[color_id]) - 1
		_refresh_pharmacy()
		_set_msg("")


func _refresh_pharmacy() -> void:
	for color_id in _pharmacy_count_labels:
		(_pharmacy_count_labels[color_id] as Label).text = "برداشته‌شده: " + WhiteHospitalLogic.fa_num(int(_pharmacy_counts[color_id]))


func _on_pharmacy_check() -> void:
	if _solved:
		return
	if WhiteHospitalLogic.pharmacy_is_correct(_pharmacy_counts):
		_solve()
	else:
		_set_msg("نسخه هنوز درست نیست — نسخه: ۴ قرمز، ۲ آبی، ۱ زرد.")


# --- پازل ۵: ICU ---
func _build_icu() -> void:
	_icu_hr = int(WhiteHospitalLogic.ICU_START["hr"])
	_icu_o2 = int(WhiteHospitalLogic.ICU_START["o2"])
	_icu_sys = int(WhiteHospitalLogic.ICU_START["sys"])
	_icu_dia = int(WhiteHospitalLogic.ICU_START["dia"])
	_add_icu_row("hr", "ضربان قلب", "سالم: ۶۰ تا ۱۰۰", 1, -1)
	_add_icu_row("o2", "اکسیژن خون", "سالم: ۹۵ تا ۱۰۰٪", 1, -1)
	_add_icu_row("sys", "فشار خون (بالایی)", "سالم: ۱۰۰ تا ۱۲۰", 5, -5)
	_add_icu_row("dia", "فشار خون (پایینی)", "سالم: ۶۰ تا ۸۰", 5, -5)
	_refresh_icu()


func _add_icu_row(key: String, title: String, healthy: String, step_up: int, step_down: int) -> void:
	var row := HBoxContainer.new()
	row.alignment = BoxContainer.ALIGNMENT_CENTER
	row.add_theme_constant_override("separation", 10)
	_content.add_child(row)
	row.add_child(_make_label(title, 17, true))
	var minus := _make_button("-")
	minus.custom_minimum_size = Vector2(56, 44)
	minus.pressed.connect(_on_icu_change.bind(key, step_down))
	row.add_child(minus)
	var value := _make_label("", 20, true)
	value.custom_minimum_size = Vector2(110, 44)
	_icu_value_labels[key] = value
	row.add_child(value)
	var plus := _make_button("+")
	plus.custom_minimum_size = Vector2(56, 44)
	plus.pressed.connect(_on_icu_change.bind(key, step_up))
	row.add_child(plus)
	row.add_child(_make_label(healthy, 15, false))


func _on_icu_change(key: String, delta: int) -> void:
	if _solved:
		return
	match key:
		"hr":
			_icu_hr = clampi(_icu_hr + delta, 30, 180)
		"o2":
			_icu_o2 = clampi(_icu_o2 + delta, 70, 100)
		"sys":
			_icu_sys = clampi(_icu_sys + delta, 60, 200)
		"dia":
			_icu_dia = clampi(_icu_dia + delta, 30, 140)
	_refresh_icu()
	if WhiteHospitalLogic.icu_is_healthy(_icu_hr, _icu_o2, _icu_sys, _icu_dia):
		_solve()


func _refresh_icu() -> void:
	(_icu_value_labels["hr"] as Label).text = WhiteHospitalLogic.fa_num(_icu_hr)
	(_icu_value_labels["o2"] as Label).text = WhiteHospitalLogic.fa_num(_icu_o2) + "٪"
	(_icu_value_labels["sys"] as Label).text = WhiteHospitalLogic.fa_num(_icu_sys)
	(_icu_value_labels["dia"] as Label).text = WhiteHospitalLogic.fa_num(_icu_dia)
	(_icu_value_labels["hr"] as Label).add_theme_color_override("font_color", Color("#2E7D32") if WhiteHospitalLogic.icu_hr_ok(_icu_hr) else Color("#C62828"))
	(_icu_value_labels["o2"] as Label).add_theme_color_override("font_color", Color("#2E7D32") if WhiteHospitalLogic.icu_o2_ok(_icu_o2) else Color("#C62828"))
	var bp_ok := WhiteHospitalLogic.icu_bp_ok(_icu_sys, _icu_dia)
	(_icu_value_labels["sys"] as Label).add_theme_color_override("font_color", Color("#2E7D32") if bp_ok else Color("#C62828"))
	(_icu_value_labels["dia"] as Label).add_theme_color_override("font_color", Color("#2E7D32") if bp_ok else Color("#C62828"))


# --- پازل ۶: زایمان ---
func _build_maternity() -> void:
	var cards := HBoxContainer.new()
	cards.alignment = BoxContainer.ALIGNMENT_CENTER
	cards.add_theme_constant_override("separation", 12)
	_content.add_child(cards)
	var cards_title := _make_label("کارت‌های نام (جوهر هر کارت هم‌رنگ پتوی گهواره‌ی همان نوزاد است):", 16, false)
	_content.add_child(cards_title)
	_content.move_child(cards_title, _content.get_child_count() - 2)
	for color_id in ["blue", "yellow", "pink"]:
		var b := _make_button("کارت «" + String(WhiteHospitalLogic.MATERNITY_CARD_NAMES[color_id]) + "» — جوهر " + String(WhiteHospitalLogic.MATERNITY_COLOR_NAMES[color_id]))
		b.custom_minimum_size = Vector2(220, 64)
		b.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		b.add_theme_stylebox_override("normal", _color_box(WhiteHospitalLogic.MATERNITY_COLOR_VALUES[color_id]))
		b.add_theme_color_override("font_color", Color.WHITE)
		b.pressed.connect(_on_mat_card.bind(color_id))
		_mat_card_buttons[color_id] = b
		cards.add_child(b)
	var cradles := HBoxContainer.new()
	cradles.alignment = BoxContainer.ALIGNMENT_CENTER
	cradles.add_theme_constant_override("separation", 12)
	_content.add_child(cradles)
	for color_id in ["pink", "blue", "yellow"]:
		var b := _make_button("گهواره‌ی " + String(WhiteHospitalLogic.MATERNITY_COLOR_NAMES[color_id]))
		b.custom_minimum_size = Vector2(170, 70)
		b.add_theme_stylebox_override("normal", _color_box(WhiteHospitalLogic.MATERNITY_COLOR_VALUES[color_id]))
		b.add_theme_color_override("font_color", Color.WHITE)
		b.pressed.connect(_on_mat_cradle.bind(color_id))
		_mat_cradle_buttons[color_id] = b
		cradles.add_child(b)


func _on_mat_card(color_id: String) -> void:
	if _solved or color_id in _mat_matched:
		return
	_mat_selected = color_id
	_set_msg("حالا گهواره‌ی هم‌رنگ این کارت را انتخاب کن.")


func _on_mat_cradle(color_id: String) -> void:
	if _solved or _mat_selected == "":
		return
	if WhiteHospitalLogic.maternity_matches(_mat_selected, color_id):
		_mat_matched[_mat_selected] = color_id
		(_mat_card_buttons[_mat_selected] as Button).disabled = true
		(_mat_cradle_buttons[color_id] as Button).disabled = true
		_mat_selected = ""
		if _mat_matched.size() == WhiteHospitalLogic.MATERNITY_COLORS.size():
			_solve()
		else:
			_set_msg("درست است! ادامه بده.", true)
	else:
		_set_msg(WRONG_MSG)
