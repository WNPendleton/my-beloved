extends CharacterBody2D

enum control_mode {NONE, MOUSE, CONTROLLER}

const HALF_PI = PI * 0.5

@export var foot_speed = 200.0
@export var jump_distance = 100.0
@export var jump_height = 100.0
#@export var land_assist_gravity_multiplier = 0.5
#@export var terminal_velocity = 15.0
@export var ground_acceleration = 400.0
@export var ground_deceleration = 800.0
@export var ground_turn_speed = 800.0
@export var air_acceleration = 100.0
@export var air_deceleration = 100.0
@export var air_turn_speed = 200.0
#@export var coyote_time = 0.1
#@export var jump_buffer_time = 0.05
@export var mouse_marker: Sprite2D
@export var head: Node2D
@export var camera: Camera2D
@export var sprite: AnimatedSprite2D

@onready var gravity = 8 * jump_height * pow(foot_speed, 2) / pow(jump_distance, 2)
@onready var jump_velocity = -4 * jump_height * foot_speed / jump_distance
var my_mode = control_mode.NONE

func _ready() -> void:
	print(gravity)
	Globals.player = self
	#mouse_marker.hide()

func _physics_process(delta: float) -> void:
	var vertical_velocity = velocity.y
	var horizontal_velocity = velocity.x
	if not is_on_floor():
		vertical_velocity += gravity * delta
	
	if Input.is_action_just_pressed("jump") and is_on_floor():
		vertical_velocity = jump_velocity
	
	if my_mode == control_mode.NONE:
		mouse_marker.global_position = global_position + Vector2(50, -20)
	
	var aim_dir = Input.get_vector("aim_left", "aim_right", "aim_up", "aim_down")
	if aim_dir:
		my_mode = control_mode.CONTROLLER
		mouse_marker.global_position = head.global_position + aim_dir * 100.0
	
	if my_mode == control_mode.MOUSE:
		var vp = camera.get_viewport()
		var pos = vp.get_mouse_position()
		var size = vp.size
		mouse_marker.global_position =  camera.global_position + (pos - size / 2.0)
	
	var angle = head.global_position.angle_to_point(mouse_marker.global_position)
	var flip = abs(angle) > HALF_PI
	head.scale = Vector2(-1.0, 1.0) if flip else Vector2(1.0, 1.0)
	head.rotation = angle + (PI if flip else 0.0)
	
	var direction := Input.get_axis("left", "right")
	var turning = sign(direction) != sign(horizontal_velocity)
	if direction:
		if is_on_floor():
			if turning:
				horizontal_velocity += ground_turn_speed * direction * delta
			else:
				horizontal_velocity += ground_acceleration * direction * delta
		else:
			if turning:
				horizontal_velocity += air_turn_speed * direction * delta
			else:
				horizontal_velocity += air_acceleration * direction * delta
	else:
		if is_on_floor():
			var decel = ground_deceleration * delta
			if abs(horizontal_velocity) < decel:
				horizontal_velocity = 0.0
			else:
				horizontal_velocity -= decel * sign(horizontal_velocity)
		else:
			var decel = air_deceleration * delta
			if abs(horizontal_velocity) < decel:
				horizontal_velocity = 0.0
			else:
				horizontal_velocity -= decel * sign(horizontal_velocity)
	horizontal_velocity = clamp(horizontal_velocity, -foot_speed, foot_speed)
	velocity = Vector2(horizontal_velocity, vertical_velocity)
	
	if is_on_floor() and abs(horizontal_velocity) > 0:
		sprite.play()
		sprite.animation = "walk"
	else:
		sprite.animation = "idle"
	
	sprite.flip_h = sign(horizontal_velocity) < 0
	
	var pre_pos = global_position
	move_and_slide()
	var diff = global_position - pre_pos
	mouse_marker.position.x += diff.x


func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		my_mode = control_mode.MOUSE


func kill():
	pass


func _on_beak_body_entered(body: Node2D) -> void:
	if body is Ghost:
		body.repel()


func _on_kill_body_entered(body: Node2D) -> void:
	if body is Ghost:
		kill()
		body.queue_free()
