extends Area2D

const st_cpl_wait = 0
const st_cpl_done = 1
const st_cpl_ucpl = 2
# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var couple_state = st_cpl_wait
var gaped_to: Area2D = null
var pj: PinJoint2D = null
var mouse_in_click_wait = false


# Called when the node enters the scene tree for the first time.
func _ready():
	pj = get_child(1)
	#pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if mouse_in_click_wait:
		if Input.is_mouse_button_pressed(BUTTON_LEFT):
			mouse_in_click_wait = false
			var ucpla = get_child(2)
			ucpla.get_child(1).visible = false
			ucpla.get_child(2).visible = false
			gaped_to.uncouple()
			uncouple()
#	pass

func _on_hook0_area_entered(area):
	if gaped_to or couple_state != st_cpl_wait: #skip if already gaped
		return
	#cross gape
	couple_state = st_cpl_done
	couple(area)
	area.couple(self)
	print('coupler:' + self.get_path())
	pj.set_node_a(get_parent().get_path())
	pj.set_node_b(gaped_to.get_parent().get_path())
	#
	
	#pass # Replace with function body.
	
func couple(area: Area2D):
	gaped_to = area
	
func uncouple():
	couple_state = st_cpl_ucpl
	gaped_to = null
	pj.set_node_a("")
	pj.set_node_b("")

func _on_hook_area_exited(area):
	if couple_state != st_cpl_ucpl:
		return
	couple_state = st_cpl_wait
	
	#pass # Replace with function body.


func _on_uncouple_mouse_entered():
	#works only for active coupler
	if not gaped_to:
		return
	if not couple_state == st_cpl_done:
		return
	var ucpla = get_child(2)
	ucpla.get_child(1).visible = true
	ucpla.get_child(2).visible = true
	mouse_in_click_wait = true
	#pass # Replace with function body.


func _on_uncouple_mouse_exited():
	#works only for active coupler
	if not gaped_to:
		return
	if not couple_state == st_cpl_done:
		return		
	mouse_in_click_wait = false		
	var ucpla = get_child(2)
	ucpla.get_child(1).visible = false
	ucpla.get_child(2).visible = false
	#pass # Replace with function body.
