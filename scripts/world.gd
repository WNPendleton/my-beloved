extends Node2D

@export var delay_range: Curve
@export var ghost_prefab: PackedScene
@export var spawn_angle_range = Vector2(PI * 1.1, PI * 1.9)
@export var home_cutscene: Control
@export var end_cutscene: Node


var delay_time := 0.0
var next_delay = 0.0


func _process(delta: float) -> void:
	if Globals.cutscene:
		return
	delay_time += delta
	if delay_time > next_delay:
		spawn_ghost()
		next_delay = delay_range.sample(randf())
		delay_time = 0.0


func spawn_ghost():
	if Globals.end_cutscene:
		return false
	var new_ghost = ghost_prefab.instantiate()
	add_child(new_ghost)
	var angle = randf_range(spawn_angle_range.x, spawn_angle_range.y)
	new_ghost.global_position = Globals.player.global_position + Vector2.from_angle(angle) * 1000.00


func remove_ghosts():
	for child in get_children():
		if child is Ghost:
			child.repel()

func remove_ghosts_quietly():
	for child in get_children():
		if child is Ghost:
			child.queue_free()


func _on_rain_finished() -> void:
	await get_tree().create_timer(1.0).timeout
	$Rain.play(0.0)


func _on_home_body_entered(body: Node2D) -> void:
	if body is Player and not body.been_home:
		remove_ghosts_quietly()
		body.been_home = true
		home_cutscene.start()


func _on_end_body_entered(body: Node2D) -> void:
	if body is Player:
		remove_ghosts()
		end_cutscene.start()


func _on_music_finished() -> void:
	await get_tree().create_timer(1.0).timeout
	$Music.play(0.0)
