extends Node2D

@export var delay_range: Curve
@export var ghost_prefab: PackedScene
@export var spawn_angle_range = Vector2(PI * 1.1, PI * 1.9)

var delay_time := 0.0
var next_delay = 0.0


func _process(delta: float) -> void:
	delay_time += delta
	if delay_time > next_delay:
		spawn_ghost()
		next_delay = delay_range.sample(randf())
		delay_time = 0.0


func spawn_ghost():
	var new_ghost = ghost_prefab.instantiate()
	add_child(new_ghost)
	var angle = randf_range(spawn_angle_range.x, spawn_angle_range.y)
	new_ghost.global_position = Globals.player.global_position + Vector2.from_angle(angle) * 1000.00


func remove_ghosts():
	for child in get_children():
		if child is Ghost:
			child.queue_free()
