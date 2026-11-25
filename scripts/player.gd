# بازیکن تاپ‌داون: حرکت با WASD یا کلیدهای جهت‌دار.
class_name WhiteHospitalPlayer
extends CharacterBody2D

const SPEED := 130.0

var frozen := false


func _ready() -> void:
	var collision := CollisionShape2D.new()
	var rect := RectangleShape2D.new()
	rect.size = Vector2(14, 26)
	collision.shape = rect
	collision.position = Vector2(0, -5)
	add_child(collision)
	# ظاهر شماتیک: سر + بدن (اسپرایت نهایی از روی فریم‌های ۶۱۶ می‌آید).
	var head := ColorRect.new()
	head.color = Color("#F2C9A0")
	head.position = Vector2(-6, -22)
	head.size = Vector2(12, 10)
	add_child(head)
	var body := ColorRect.new()
	body.color = Color("#2F6F6A")
	body.position = Vector2(-8, -12)
	body.size = Vector2(16, 20)
	add_child(body)


func _physics_process(_delta: float) -> void:
	if frozen:
		velocity = Vector2.ZERO
		move_and_slide()
		return
	var dir := Vector2.ZERO
	if Input.is_key_pressed(KEY_A) or Input.is_key_pressed(KEY_LEFT):
		dir.x -= 1
	if Input.is_key_pressed(KEY_D) or Input.is_key_pressed(KEY_RIGHT):
		dir.x += 1
	if Input.is_key_pressed(KEY_W) or Input.is_key_pressed(KEY_UP):
		dir.y -= 1
	if Input.is_key_pressed(KEY_S) or Input.is_key_pressed(KEY_DOWN):
		dir.y += 1
	velocity = dir.normalized() * SPEED
	move_and_slide()
