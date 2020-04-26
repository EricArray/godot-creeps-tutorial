extends Area2D

signal hit

export var speed := 400
var screen_size: Vector2
var target := Vector2()
var following := false

onready var animated_sprite = $AnimatedSprite

func _ready():
	screen_size = get_viewport_rect().size
	hide()

func start(pos: Vector2):
	position = pos
	target = pos
	show()
	$CollisionShape2D.disabled = false

func _input(event: InputEvent):
	if event is InputEventScreenTouch and event.pressed:
		target = event.position
		following = true
	
func _process(delta: float):
	var velocity = Vector2()
	
	if following and position.distance_to(target) > 10:
		velocity = target - position
	else:
		following = false
		if Input.is_action_pressed("ui_right"):
			velocity.x += 1
		if Input.is_action_pressed("ui_left"):
			velocity.x -= 1
		if Input.is_action_pressed("ui_down"):
			velocity.y += 1
		if Input.is_action_pressed("ui_up"):
			velocity.y -= 1

	if velocity.length() > 0:
		velocity = velocity.normalized() * speed
		animated_sprite.play()
	else:
		animated_sprite.stop()

	position += velocity * delta
	position.x = clamp(position.x, 0, screen_size.x)
	position.y = clamp(position.y, 0, screen_size.y)

	if velocity.x != 0:
		animated_sprite.animation = "right"
		animated_sprite.flip_v = false
		animated_sprite.flip_h = velocity.x < 0
	elif velocity.y != 0:
		animated_sprite.animation = "up"
		animated_sprite.flip_v = velocity.y > 0

func _on_Player_body_entered(_body):
	hide()
	emit_signal("hit")
	$CollisionShape2D.set_deferred("disabled", true)
