extends TextureRect


var switch_time = 1.5
var time = 0.0


func _physics_process(delta: float) -> void:
	time += delta
	if time > switch_time:
		time -= switch_time
		flip_h = not flip_h
