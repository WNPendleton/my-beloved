extends Control


func _ready() -> void:
	Globals.cutscene = true
	show()


func _input(event: InputEvent) -> void:
	if event is InputEventKey:
		var tween = get_tree().create_tween()
		tween.tween_property(self, "modulate", Color(0, 0, 0, 1), 1.0)
		tween.tween_callback(func():
			Globals.cutscene = false
			queue_free()).set_delay(0.5)
	
