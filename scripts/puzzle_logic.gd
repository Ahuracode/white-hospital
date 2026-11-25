# منطق خالص بازی «بیمارستان سفید» — بدون وابستگی به صحنه.
# همه‌ی قانون‌های پازل‌ها و شمارنده‌ی کلید اینجاست تا هم UI و هم تست
# خودکار از یک منبع واحد استفاده کنند.
class_name WhiteHospitalLogic
extends RefCounted

const TOTAL_KEYS := 6

const PUZZLE_IDS: Array[String] = ["lab", "surgery", "radiology", "pharmacy", "icu", "maternity"]

const PUZZLE_NAMES := {
	"lab": "آزمایشگاه",
	"surgery": "اتاق عمل",
	"radiology": "رادیولوژی",
	"pharmacy": "داروخانه",
	"icu": "ICU",
	"maternity": "زایمان",
}

const PUZZLE_KEY_NAMES := {
	"lab": "کلید آزمایشگاه",
	"surgery": "کلید اتاق عمل",
	"radiology": "کلید رادیولوژی",
	"pharmacy": "کلید داروخانه",
	"icu": "کلید ICU",
	"maternity": "کلید زایمان",
}

# پازل ۱ — آزمایشگاه: ترتیب عددی لوله‌ها (جدول مرجع روی دیوار).
const LAB_ORDER: Array[String] = ["blue", "green", "yellow", "red"]
const LAB_COLOR_NAMES := {
	"blue": "آبی",
	"green": "سبز",
	"yellow": "زرد",
	"red": "قرمز",
}
const LAB_COLOR_VALUES := {
	"blue": Color("#4A90D9"),
	"green": Color("#7FB069"),
	"yellow": Color("#E8C832"),
	"red": Color("#D94F3D"),
}

# پازل ۲ — اتاق عمل: ترتیب استفاده از ابزار (پوستر روی دیوار).
const SURGERY_ORDER: Array[String] = ["scalpel", "scissors", "forceps", "needle", "clamp"]
const SURGERY_TOOL_NAMES := {
	"scalpel": "چاقوی جراحی",
	"scissors": "قیچی",
	"forceps": "پنس",
	"needle": "سوزن بخیه",
	"clamp": "گیره",
}

# پازل ۳ — رادیولوژی: هر عکس ایکس‌ری به برچسب عضو درستش.
const RADIOLOGY_MATCH := {
	"hand": "دست",
	"foot": "پا",
	"chest": "سینه",
	"skull": "سر",
}
const RADIOLOGY_IMAGE_HINTS := {
	"hand": "عکس: استخوان‌های انگشتان",
	"foot": "عکس: استخوان‌های پا",
	"chest": "عکس: دنده‌ها و قفسه‌ی سینه",
	"skull": "عکس: جمجمه",
}

# پازل ۴ — داروخانه: نسخه‌ی درست.
const PHARMACY_TARGET := {"red": 4, "blue": 2, "yellow": 1}
const PHARMACY_COLOR_NAMES := {
	"red": "قرمز",
	"blue": "آبی",
	"yellow": "زرد",
}

# پازل ۵ — ICU: محدوده‌های سالم مانیتور.
const ICU_HR_MIN := 60
const ICU_HR_MAX := 100
const ICU_O2_MIN := 95
const ICU_O2_MAX := 100
const ICU_SYS_MIN := 100
const ICU_SYS_MAX := 120
const ICU_DIA_MIN := 60
const ICU_DIA_MAX := 80
# مقادیر شروع (خارج از محدوده‌ی سالم) و هدف نمایشی.
const ICU_START := {"hr": 120, "o2": 89, "sys": 160, "dia": 100}
const ICU_TARGET := {"hr": 72, "o2": 98, "sys": 120, "dia": 80}

# پازل ۶ — زایمان: کارت نام هم‌رنگ جوهر با پتوی گهواره.
const MATERNITY_COLORS: Array[String] = ["pink", "blue", "yellow"]
const MATERNITY_COLOR_NAMES := {
	"pink": "صورتی",
	"blue": "آبی",
	"yellow": "زرد",
}
const MATERNITY_COLOR_VALUES := {
	"pink": Color("#E8A0B4"),
	"blue": Color("#7FB3D5"),
	"yellow": Color("#E8C832"),
}
const MATERNITY_CARD_NAMES := {
	"pink": "نیلوفر",
	"blue": "آرش",
	"yellow": "سارا",
}


static func lab_is_solved(order: Array) -> bool:
	return order == LAB_ORDER


static func surgery_expected_at(index: int) -> String:
	if index < 0 or index >= SURGERY_ORDER.size():
		return ""
	return SURGERY_ORDER[index]


static func surgery_is_correct_sequence(seq: Array) -> bool:
	return seq == SURGERY_ORDER


static func radiology_matches(image_id: String, label: String) -> bool:
	return RADIOLOGY_MATCH.get(image_id, "") == label


static func radiology_is_solved(matched: Dictionary) -> bool:
	# matched: image_id -> label درست
	for image_id in RADIOLOGY_MATCH:
		if matched.get(image_id, "") != RADIOLOGY_MATCH[image_id]:
			return false
	return true


static func pharmacy_is_correct(counts: Dictionary) -> bool:
	for color in PHARMACY_TARGET:
		if int(counts.get(color, 0)) != int(PHARMACY_TARGET[color]):
			return false
	return true


static func pharmacy_can_add(counts: Dictionary, color: String) -> bool:
	return int(counts.get(color, 0)) < int(PHARMACY_TARGET[color])


static func icu_hr_ok(hr: int) -> bool:
	return hr >= ICU_HR_MIN and hr <= ICU_HR_MAX


static func icu_o2_ok(o2: int) -> bool:
	return o2 >= ICU_O2_MIN and o2 <= ICU_O2_MAX


static func icu_bp_ok(sys: int, dia: int) -> bool:
	return sys >= ICU_SYS_MIN and sys <= ICU_SYS_MAX and dia >= ICU_DIA_MIN and dia <= ICU_DIA_MAX


static func icu_is_healthy(hr: int, o2: int, sys: int, dia: int) -> bool:
	return icu_hr_ok(hr) and icu_o2_ok(o2) and icu_bp_ok(sys, dia)


static func maternity_matches(card_color: String, cradle_color: String) -> bool:
	return card_color == cradle_color


static func fa_num(n: int) -> String:
	var digits := ["۰", "۱", "۲", "۳", "۴", "۵", "۶", "۷", "۸", "۹"]
	var out := ""
	for ch in str(n):
		out += digits[int(ch)]
	return out


# پیشرفت بازی: پازل‌های حل‌شده، شمارنده‌ی کلید، درِ خروج.
class GameProgress:
	extends RefCounted

	var solved: Dictionary = {}

	func key_count() -> int:
		return solved.size()

	func is_solved(puzzle_id: String) -> bool:
		return bool(solved.get(puzzle_id, false))

	func solve(puzzle_id: String) -> bool:
		if puzzle_id not in WhiteHospitalLogic.PUZZLE_IDS:
			return false
		if is_solved(puzzle_id):
			return false
		solved[puzzle_id] = true
		return true

	func can_open_door() -> bool:
		return key_count() >= WhiteHospitalLogic.TOTAL_KEYS

	func door_message() -> String:
		if can_open_door():
			return "در باز است — می‌توانی از سفینه بیرون بروی!"
		return "در قفل است — %s کلید از %s کلید را داری." % [
			WhiteHospitalLogic.fa_num(key_count()), WhiteHospitalLogic.fa_num(WhiteHospitalLogic.TOTAL_KEYS)
		]
