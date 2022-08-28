extends Area2D


# Declare member variables here. Examples:
# var a = 2

#export var sw_mask_in: int  = 17 #just a hint
#export var sw_mask_out = [18, 19]
export(int, "Out Left", "Out Right") var switched_to
export (int, "line1", "line2", "line3", "line4", "line5", "line6", "line7", "line8", "line9", "line10", "line11", "line12", "line13", "line14") var out_left = 0
export (int, "line1", "line2", "line3", "line4", "line5", "line6", "line7", "line8", "line9", "line10", "line11", "line12", "line13", "line14") var out_right = 0

var msk_in = 0
var msk_out = [0, 0]
var msk_all = 0 # mask that clean wheel uses only this switch elements

var entered = false

# Called when the node enters the scene tree for the first time.
func _ready():
	#recalc real masks
	var p = get_parent()
	if p is PathFollow2D:
		var cur: Path2D = p.get_parent()
		msk_in = 1 << cur.rail_id + 16
		print("in mask 0x%04x" % (msk_in >> 16))
	#else:
	#	if sw_mask_in > 0:
	#		msk_in = 1 << (sw_mask_in - 1)
	
	msk_out[0] = 1 << (out_left + 16)
	print("left mask 0x%04x" % (msk_out[0] >> 16))
	msk_out[1] = 1 << (out_right + 16)
	print("right mask 0x%04x" % (msk_out[1] >> 16))
	
	#calculate full switch mask and other physical masks
	msk_all = 0b1111111111111111 | msk_in | msk_out[0] | msk_out[1]
	#         every may needed     input     out0        out1
		
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Input.is_action_just_pressed("LMB") and entered:
		flip()
		
#	pass
func flip():
	switched_to = ~switched_to
	var p_sw: Polygon2D = get_node("button/p_sw")
	p_sw.scale.y = p_sw.scale.y * -1

func _on_switch_body_entered(body):
	if not "wheel" in body.name:
		return
	var mask = body.get_collision_mask()
	#clear unused rail masks
	mask = mask & msk_all
	
	#check goes in input
	var from_in = mask & msk_in == msk_in
	var from_active_out = mask & msk_out[switched_to] == msk_out[switched_to]
	var from_inactive_out = mask & msk_out[~ switched_to] == msk_out[~ switched_to]
	if from_in: print("from in")
	if from_active_out: print("from active out")
	if from_inactive_out:
		#change switch position
		print("from inactive")
		flip()
		Polygon2D
	mask = mask & ~msk_out[~ switched_to] #remove incactive line from mask
	mask = mask | msk_in | msk_out[switched_to] #set out mask
	body.set_collision_mask(mask)		
		
		
func _on_button_mouse_entered():
	entered = true


func _on_button_mouse_exited():
	entered = false




