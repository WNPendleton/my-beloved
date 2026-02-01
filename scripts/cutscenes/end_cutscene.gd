extends Node

@export var world: Node2D
@export var ghost: AnimatedSprite2D
@export var particles: PackedScene


func start():
	Globals.end_cutscene = true
	var tween = get_tree().create_tween()
	ghost.play("default")
	Globals.player.update_head_angle(0.0)
	tween.tween_property(Globals.player, "global_position", Vector2(26200, -320), 3.0)
	tween.tween_callback(func():
		Globals.player.set_animation("idle"))
	tween.tween_callback(func():
		Globals.player.set_animation("kneel")
		Globals.player.head.hide()
		).set_delay(1.0)
	tween.tween_callback(func():
		var new_particles = particles.instantiate()
		add_child(new_particles)
		new_particles.global_position = ghost.global_position
		new_particles.emitting = true
		ghost.show()).set_delay(3.0)
	tween.tween_callback(func():
		Globals.player.set_animation("unmask")
		).set_delay(3.0)
	tween.tween_property(ghost, "global_position", Vector2(26200, -320), 5.0).set_delay(3.0)
	tween.tween_callback(func():
		Globals.player.set_animation("kneel_death")
		ghost.hide()
		var new_particles = particles.instantiate()
		add_child(new_particles)
		new_particles.global_position = ghost.global_position
		new_particles.emitting = true
		)
	tween.tween_property(world, "modulate", Color(0,0,0,1), 2.0).set_delay(3.0)
	tween.tween_callback(restart).set_delay(0.5)

func restart():
	Globals.end_cutscene = false
	(func():
		get_tree().change_scene_to_file("res://scenes/main.tscn")
	).call_deferred()
