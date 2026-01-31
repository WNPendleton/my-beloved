extends Camera2D

@onready var player = Globals.player

func _physics_process(delta: float) -> void:
	var goal_pos = player.global_position + Vector2(0, -50)
	global_position.y = lerp(global_position.y, goal_pos.y, 0.3)
	global_position.x = goal_pos.x
