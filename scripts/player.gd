# بازیکن تاپ‌داون: حرکت با WASD یا کلیدهای جهت‌دار.
# ظاهر: جراح (فریم‌های عکس ۶۱۶، ۴ جهت؛ idle و walk هر کدام یک فریم).
# فرض دیزاین: بازیکن دکتر/جراح است (design.md §۱۰).
class_name WhiteHospitalPlayer
extends CharacterBody2D

const SPEED := 130.0

const SPRITE_DIR := "res://assets/sprites/player/"
const DIRECTIONS := ["down", "left", "right", "up"]

var frozen := false
var facing := "down"

var _sprite: Sprite2D
var _idle_tex: Dictionary = {}
var _walk_tex: Dictionary = {}


func _ready() -> void:
	var collision := CollisionShape2D.new()
	var rect := RectangleShape2D.new()
	rect.size = Vector2(14, 26)
	collision.shape = rect
	collision.position = Vector2(0, -5)
	add_child(collision)
	for dir in DIRECTIONS:
		_idle_tex[dir] = load(SPRITE_DIR + "surgeon_idle_%s.png" % dir)
		_walk_tex[dir] = load(SPRITE_DIR + "surgeon_walk_%s.png" % dir)
	_sprite = Sprite2D.new()
	_sprite.texture = _idle_tex["down"]
	_sprite.position = Vector2(0, -10)
	add_child(_sprite)


func _physics_process(_delta: float) -> void:
	if frozen:
		velocity = Vector2.ZERO
		move_and_slide()
		_update_sprite(Vector2.ZERO)
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
	_update_sprite(dir)


func _update_sprite(dir: Vector2) -> void:
	if dir != Vector2.ZERO:
		if absf(dir.x) > absf(dir.y):
			facing = "left" if dir.x < 0 else "right"
		else:
			facing = "up" if dir.y < 0 else "down"
		_sprite.texture = _walk_tex[facing]
	else:
		_sprite.texture = _idle_tex[facing]
