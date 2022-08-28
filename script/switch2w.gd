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
var in_clr_mask = 0

var entered = false
var body_entered_in = []
var body_entered_out = []

# Called when the node enters the scene tree for the first time.
func _ready():
	
	#recalc real masks
	var p = get_parent()
	if p is PathFollow2D:
		var cur: Path2D = p.get_parent()
		msk_in = 1 << cur.rail_id + 16
		in_clr_mask =  0xffff | msk_in 
		print("switch in mask 0x%04x" % (msk_in >> 16))
	#else:
	#	if sw_mask_in > 0:
	#		msk_in = 1 << (sw_mask_in - 1)
	
	msk_out[0] = 1 << (out_left + 16)
	print("left mask 0x%04x" % (msk_out[0] >> 16))
	msk_out[1] = 1 << (out_right + 16)
	print("right mask 0x%04x" % (msk_out[1] >> 16))
	
	#calculate full switch mask and other physical masks
	msk_all = 0xffff | msk_in | msk_out[0] | msk_out[1]
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
	if body.get_meta("part") != "wheel":
		return
	
	#cheking for single way fork
	if body in body_entered_out:
		body_entered_out.erase(body)
	else:
		body_entered_in.append(body)
		
	var mask = body.get_collision_mask()
	mask = mask & 0xffff
	mask = mask | in_clr_mask
	print("set mask ", mask)
	body.set_collision_mask(mask)
	return

		
func _on_out_body_entered(body):
	if body.get_meta("part") != "wheel":
		return
		
	#checking for single way fork
	var true_from_in = false	
	if body in body_entered_in:
		true_from_in = true
		body_entered_in.erase(body)
	else:
		body_entered_out.append(body)
		
	var mask = body.get_collision_mask()
	
	var from_in = mask & msk_in == msk_in
	var from_active_out = mask & msk_out[switched_to] == msk_out[switched_to]
	var from_inactive_out = mask & msk_out[~ switched_to] == msk_out[~ switched_to]
	
	if from_in: 
		print("from in")
	if from_inactive_out and not true_from_in:
		#change switch position
		print("from inactive")
		flip()
	if from_active_out: 
		print("from active out") #do nothing
			
	mask = mask & 0xffff
	mask = mask | msk_out[switched_to]
		
	body.set_collision_mask(mask)
	
	


func _on_out_body_exited(body):
	pass # Replace with function body.

func _on_button_mouse_entered():
	print("Entered")
	entered = true


func _on_button_mouse_exited():
	entered = false




