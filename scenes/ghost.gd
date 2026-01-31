class_name Ghost
extends CharacterBody2D

@onready var speed = randf_range(20.0, 100.0)
@onready var player = Globals.player

func _physics_process(delta: float) -> void:
	global_position = global_position.move_toward(player.global_position, speed * delta)


func repel():
	queue_free()
