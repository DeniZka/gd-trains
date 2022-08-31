extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var rot_speed = 0.03
var rot_dir = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Input.is_action_pressed("turn_left"):
		rot_dir = -1

	if Input.is_action_pressed("turn_right"):
		rot_dir = 1
		
	if rot_dir:
		rotate(rot_dir * rot_speed * delta)
	
#	pass


func _on_table_tip_on_tip_met():
	rot_dir = 0
