extends Camera2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	position = Vector2(0.0, 0.0)
	#if get_parent() is Node:
	#	position = Vector2(512, 304)
		#anchor_mode = ANCHOR_MODE_FIXED_TOP_LEFT
	
	#pass # Replace with function body.
func _input(event):
	#event.type == InputEvent.M
	if Input.is_action_pressed("zoom_in"):
		var z: Vector2 = get_zoom()
		z -= z * 0.05
		set_zoom(z)
	if Input.is_action_pressed("zoom_out"):
		var z: Vector2 = get_zoom()
		z += z * 0.05
		set_zoom(z)	
	pass
	
	
func _unhandled_input(event):
	pass
	#if Input.is_action_pressed()
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
