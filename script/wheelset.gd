tool
extends RigidBody2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func set_active_line(line_mask):
	var ch_a = get_children()
	for ch in ch_a:
		if ch is RigidBody2D:
			ch.set_active_line(line_mask)
	
func set_wheel_dist(val):
	var ch_a = get_children()
	for ch in ch_a:
		if "left" in ch.name:
			ch.position.x = - val / 2
			ch.position.y = 0
		if "right" in ch.name:
			ch.position.x =  val / 2  
			ch.position.y = 0
	pass
	
func set_wheel_r(val):
	var ch_a = get_children()
	for ch in ch_a:
		if ch is RigidBody2D:
			ch.get_node("cs").shape.radius = val
			
func set_wheel_softnes(val):
	$right/pj.set_softness(val)
	$left/pj.set_softness(val)
	pass
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
