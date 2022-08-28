extends Area2D

export var line_mask = 0
# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var clear_mask = 0xffff
var mask_ready = false

# Called when the node enters the scene tree for the first time.
func _ready():
	#!!! can't ready mask there cause of tehere's no
	#check is on rail
	#if line setter is on rigid body
	var p = get_parent()
	if p is RigidBody2D:
		line_mask = p.get_collision_mask()
		print("line mask ", line_mask)
		clear_mask = clear_mask | line_mask
	#if line setter is on curve
	
	if p is PathFollow2D:
		var cur: Path2D = p.get_parent()
		line_mask = 1 << cur.rail_id + 16
		print("clear mask 0x%04x" % (line_mask >> 16))
		clear_mask = clear_mask | line_mask

		
	#pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_line_setter_body_entered(body):
	if (not "wheel" in body.name):
		return
		
	var bmsk = body.get_collision_mask()
	bmsk = bmsk & clear_mask
	print("set mask ", bmsk)
	body.set_collision_mask(bmsk)
	#pass # Replace with function body.
