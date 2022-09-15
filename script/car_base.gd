tool
extends RigidBody2D

export (int, 0, 200) var base_length = 100 setget setlen, getlen
export (int, 0, 200) var wheel_gap = 50 setget setgap, getgap
export (float, 0, 10) var wheel_r = 5 setget setwr, getwr

var blen = 100
var glen = 50
var wr = 5

var soft_qspd = 200 #speed which lower more soft wheels
# Declare member variables here. Examples:
# var a = 2
# var b = "text"
func setlen(val):
	if not $ws_front:
		return
	blen = val
	$ws_front.position.y = - val / 2
	$ws_rear.position.y = val / 2 
	
func getlen():
	return blen
	
func setgap(val):
	if not $ws_front:
		return
	glen = val
	$ws_front.set_wheel_dist( val )
	$ws_rear.set_wheel_dist( val )
func getgap():
	return glen
	
func setwr(val):
	if not $ws_front:
		return
	wr = val
	$ws_front.set_wheel_r(val)
	
	
func getwr():
	return wr

# Called when the node enters the scene tree for the first time.
func _ready():
	set_meta("type", "loco")
	pass # Replace with function body.

func set_active_line(line_mask):
	$ws_front.set_active_line(line_mask)
	$ws_front.set_active_line(line_mask)
	$ws_rear.set_active_line(line_mask)
	$ws_rear.set_active_line(line_mask)
	
func _physics_process(delta):
	if linear_velocity.length_squared() < soft_qspd:
		$ws_front.set_wheel_softnes(0.5)
	else:
		$ws_front.set_wheel_softnes(0.05)
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
