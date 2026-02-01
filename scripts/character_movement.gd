class_name Player
extends CharacterBody2D

enum control_mode {NONE, MOUSE, CONTROLLER}

const HALF_PI = PI * 0.5

@export var foot_speed = 200.0
@export var jump_distance = 100.0
@export var jump_height = 100.0
#@export var land_assist_gravity_multiplier = 0.5
@export var terminal_velocity = 3000.0
@export var ground_acceleration = 400.0
@export var ground_deceleration = 800.0
@export var ground_turn_speed = 800.0
@export var air_acceleration = 100.0
@export var air_deceleration = 100.0
@export var air_turn_speed = 200.0
@export var coyote_time = 0.1
@export var jump_buffer_time = 0.05
@export var mouse_marker: Sprite2D
@export var head: Node2D
@export var camera: Camera2D
@export var sprite: AnimatedSprite2D
@export var jump_sound: AudioStream
@export var land_sound: AudioStream
@export var die_sound: AudioStream
@export var audio: PackedScene

@onready var gravity = 8 * jump_height * pow(foot_speed, 2) / pow(jump_distance, 2)
@onready var jump_velocity = -4 * jump_height * foot_speed / jump_distance
var my_mode = control_mode.NONE
var time_off_floor = 0.0
var time_since_jump_press = INF
var look_angle: float = 0.0
var dying = false
var been_home = false

func _ready() -> void:
	Globals.player = self
	mouse_marker.hide()

func _physics_process(delta: float) -> void:
	
	if dying or Globals.cutscene or Globals.end_cutscene:
		return
	
	time_off_floor += delta
	time_since_jump_press += delta
	
	var vertical_velocity = velocity.y
	var horizontal_velocity = velocity.x
	
	if not is_on_floor(): 
		vertical_velocity += gravity * delta
	else:
		if time_off_floor == INF:
			do_audio(land_sound)
		time_off_floor = 0.0
	
	if Input.is_action_just_pressed("jump"):
		time_since_jump_press = 0.0
	
	if vertical_velocity < 0 and Input.is_action_just_released("jump"):
		vertical_velocity *= 0.5
	
	if time_since_jump_press <= jump_buffer_time and on_coyote_floor():
		sprite.play("jump")
		do_audio(jump_sound)
		vertical_velocity = jump_velocity
		time_since_jump_press = INF
		time_off_floor = INF
	
	mouse_marker.global_position = global_position + Vector2(0, -20) + Vector2.from_angle(look_angle) * 100.0
	
	var aim_dir = Input.get_vector("aim_left", "aim_right", "aim_up", "aim_down")
	if aim_dir:
		my_mode = control_mode.CONTROLLER
		look_angle = aim_dir.angle()
	if my_mode == control_mode.CONTROLLER and not aim_dir:
		look_angle = 0.0 if not sprite.flip_h else PI
	
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
	vertical_velocity = min(vertical_velocity, terminal_velocity)
	velocity = Vector2(horizontal_velocity, vertical_velocity)
	
	if is_on_floor():
		if abs(horizontal_velocity) > 0:
			sprite.play("walk")
		else:
			sprite.play("idle")
	else:
		sprite.play("air_idle")
	
	sprite.flip_h = sign(horizontal_velocity) < 0
	
	var pre_pos = global_position
	move_and_slide()
	var diff = global_position - pre_pos
	mouse_marker.position.x += diff.x


func update_head_angle(angle):
	var flip = abs(angle) > HALF_PI
	head.scale = Vector2(-1.0, 1.0) if flip else Vector2(1.0, 1.0)
	head.rotation = angle + (PI if flip else 0.0)


func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		my_mode = control_mode.MOUSE
		var vp = camera.get_viewport()
		var pos = vp.get_mouse_position()
		var size = vp.size
		mouse_marker.global_position =  camera.global_position + (pos - size / 2.0)
		look_angle = (global_position + Vector2(0, -20)).angle_to_point(mouse_marker.global_position)


func kill():
	dying = true
	head.hide()
	do_audio(die_sound)
	sprite.play("die")


func respawn():
	been_home = false
	hide()
	await get_tree().create_timer(1.0).timeout
	show()
	head.show()
	dying = false
	position = Vector2(-180, -190)
	camera.global_position = global_position
	get_parent().remove_ghosts_quietly()


func on_coyote_floor():
	return time_off_floor <= coyote_time


func do_audio(stream):
	var new_audio = audio.instantiate()
	add_sibling(new_audio)
	new_audio.global_position = global_position
	new_audio.stream = stream
	new_audio.play()


func _on_beak_body_entered(body: Node2D) -> void:
	if dying:
		return
	if body is Ghost:
		body.repel()


func _on_kill_body_entered(body: Node2D) -> void:
	if dying:
		return
	if body is Ghost:
		kill()
		body.queue_free()


func _on_body_sprite_animation_finished() -> void:
	if sprite.animation == "die":
		respawn()


func set_animation(name):
	sprite.play(name)
