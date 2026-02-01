extends Control

@export var world: Node2D
@export var door_sound: AudioStream
@export var audio: PackedScene

func _ready():
	hide()


func start():
	Globals.cutscene = true
	var tween = get_tree().create_tween()
	var new_audio = audio.instantiate()
	new_audio.stream = door_sound
	world.add_child(new_audio)
	new_audio.global_position = Globals.player.global_position
	new_audio.play()
	tween.tween_property(world, "modulate", Color(0, 0, 0, 1), 1.0)
	tween.tween_callback(func():
		show()
		world.hide())
	tween.tween_property(self, "modulate", Color(0, 0, 0, 1), 1.0).set_delay(3.0)
	tween.tween_callback(func():
		world.modulate = Color(1,1,1,1)
		modulate = Color(1,1,1,1)
		hide()
		world.show()
		Globals.cutscene = false).set_delay(0.5)
