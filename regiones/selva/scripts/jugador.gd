extends CharacterBody2D
const HEROES := ["maria", "juan", "luis"]
var hero := "juan"
var enabled := false
var facing := 0
var clock := 0.0
var textures: Dictionary = {}

func _ready() -> void:
	for hero_name in HEROES:
		textures[hero_name] = load("res://assets/heroes/%s.png" % hero_name)
	var shape := CircleShape2D.new()
	shape.radius = 10.0
	var collision := CollisionShape2D.new()
	collision.shape = shape
	add_child(collision)
	var camera := Camera2D.new()
	camera.position_smoothing_enabled = true
	camera.position_smoothing_speed = 9.0
	camera.limit_left = 0
	camera.limit_top = 0
	camera.limit_right = 1920
	camera.limit_bottom = 1280
	add_child(camera)
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST

func _physics_process(delta: float) -> void:
	var direction := Vector2.ZERO
	if enabled:
		direction.x = float(Input.is_physical_key_pressed(KEY_D) or Input.is_physical_key_pressed(KEY_RIGHT)) - float(Input.is_physical_key_pressed(KEY_A) or Input.is_physical_key_pressed(KEY_LEFT))
		direction.y = float(Input.is_physical_key_pressed(KEY_S) or Input.is_physical_key_pressed(KEY_DOWN)) - float(Input.is_physical_key_pressed(KEY_W) or Input.is_physical_key_pressed(KEY_UP))
	velocity = direction.normalized() * 235.0
	if direction != Vector2.ZERO:
		if absf(direction.x) > absf(direction.y): facing = 2 if direction.x > 0 else 1
		else: facing = 0 if direction.y > 0 else 3
		clock += delta
	else: clock = 0.0
	move_and_slide()
	queue_redraw()

func _draw() -> void:
	draw_ellipse_shadow()
	var frame: int = [0, 1, 2, 1][int(clock * 9.0) % 4] if clock > 0 else 1
	if textures.has(hero):
		draw_texture_rect_region(textures[hero], Rect2(-28, -51, 56, 56), Rect2(frame * 96, facing * 96, 96, 96))

func draw_ellipse_shadow() -> void:
	draw_set_transform(Vector2(0, 1), 0.0, Vector2(1.0, 0.35))
	draw_circle(Vector2.ZERO, 17, Color(0.02, 0.12, 0.09, 0.3))
	draw_set_transform(Vector2.ZERO)
