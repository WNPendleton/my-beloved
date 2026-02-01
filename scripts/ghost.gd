class_name Ghost
extends CharacterBody2D

@onready var speed = randf_range(300, 400.0)
@onready var player = Globals.player
@export var particles: PackedScene
@export var audio: PackedScene
@export var death_sound: AudioStream

var bonus = 200.0


func _ready() -> void:
	$Sprite2D.play("default")


func _physics_process(delta: float) -> void:
	if Globals.end_cutscene:
		queue_free()
	if Globals.cutscene or Globals.player.dying:
		return
	var dir = global_position.direction_to(player.global_position)
	if dir.x < 0:
		scale = Vector2(-1, 1)
	else:
		scale = Vector2(1, 1)
	var add = bonus if dir.x > 0 else 0.0
	global_position = global_position + (dir *  (speed + add) * delta)


func repel():
	var new_particles = particles.instantiate()
	add_sibling(new_particles)
	new_particles.global_position = global_position
	new_particles.emitting = true
	var new_audio: AudioStreamPlayer2D = audio.instantiate()
	add_sibling(new_audio)
	new_audio.global_position = global_position
	new_audio.stream = death_sound
	new_audio.play()
	queue_free()
