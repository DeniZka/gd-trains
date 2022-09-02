tool
extends PathFollow2D

const ZOOM_FACTOR = 1.7

export (int, "forward", 'Left', "righT" ) var this_line_dir = 2 setget set_split_line, get_split_line
export (int, "forward", "Left", "righT") var main_line_dir = 0 setget set_main_line, get_main_line
export (int, "MAIN", "SPLIT") var default_active_line = 0 setget set_sel_line, get_sel_line
export (bool) var flip = false setget set_flip_switch, get_flip_switch
var m_entered = false
var can_interact = false
var zoom = 1.0

var body_on_switch = []
var body_entered_in = []
var body_entered_out = []

#var split_line = 1
#var main_line = 0
var sel_line = 0
const LINE_MAIN = 0
const LINE_SPLIT = 1
var line_ids = [0, 0]
var line_masks = [0, 0]
var lines = [0, 1]

func switch_line():
	if sel_line:
		sel_line = 0
	else:
		sel_line = 1
	set_arrow()
	
func set_sel_line(value):
	sel_line = value
	set_arrow()
	
func get_sel_line():
	return sel_line

func set_split_line(value):
	lines[LINE_SPLIT] = value
	#print("AFAFFAASDFA", get_node("rot"))
	set_arrow()

func get_split_line():
	return lines[LINE_SPLIT]
	
func set_main_line(value):
	lines[LINE_MAIN] = value
	set_arrow()

func get_main_line():
	return lines[LINE_MAIN]

func set_arrow():
	if $rot:
		if not lines[sel_line]:
			$rot/strait.visible = true
			$rot/left.visible = false
		else:
			if lines[sel_line] == 2:
				$rot/left.scale.y = -1 * zoom
			else:
				$rot/left.scale.y = 1 * zoom
			$rot/strait.visible = false
			$rot/left.visible = true
		
func set_flip_switch(value):
	if $rot: #ACHTUNG STUPID THING CAN CRASH GODOT AT ALL
		if value:
			$rot.set_rotation_degrees(180)
		else:
			$rot.set_rotation_degrees(0)
	
func get_flip_switch():
	return $rot.get_rotation_degrees() == 180

# Called when the node enters the scene tree for the first time.
func _ready():
	line_ids[LINE_SPLIT] = get_parent().get_rail_id()
	line_masks[LINE_SPLIT] = 1 << (line_ids[LINE_SPLIT] + 16)
	pass # Replace with function body.
	
func _process(delta):
	if m_entered:
		if Input.is_action_just_pressed("LMB"):
			switch_line()
	if can_interact:
		if Input.is_action_just_pressed("interact"):
			switch_line()
		
#	pass
func set_zoom():
	if $rot:
		$rot/strait.scale = Vector2(zoom, zoom)
		if $rot/left.scale.y > 0:
			$rot/left.scale = Vector2(zoom, zoom)
		else:
			$rot/left.scale = Vector2(zoom, -zoom)

func _on_sensor_mouse_entered():
	zoom = ZOOM_FACTOR
	set_zoom()
	m_entered = true
	#print("enter")


func _on_sensor_mouse_exited():
	zoom = 1.0
	set_zoom()
	m_entered = false
	#print("leave")

func prepare_line(body):
	#check body is 
#	print("Name:  ", body.name)	
	var line_id = body.get_parent().get_rail_id()
	if line_id != line_ids[1]:
		line_ids[LINE_MAIN] = line_id
		
		line_masks[LINE_MAIN] = 1 << (line_ids[LINE_MAIN] + 16)
		line_masks[LINE_SPLIT] = 1 << (line_ids[LINE_SPLIT] + 16)
		
	return

func _on_in_body_entered(body):
	#on ready (connect to another line) one time
	if (body.name == "rb") or (body.name == "sb"):
		prepare_line(body)
		return
		
	#wheel go resolving
	if body.get_meta("part") != "wheel":
		return
		
	#cheking for single way fork
#	if not body in body_entered_out:
	body_entered_in.append(body)
	
	#set main mask
	var mask = body.get_collision_mask()
#	mask = mask & 0xffff
	mask = mask | line_masks[LINE_MAIN]
	#print("set in mask 0x%04x" % (mask >> 16))
	body.set_collision_mask(mask)
	
func _on_in_body_exited(body):
	body_entered_in.erase(body)
	#remove self mask if body not leave switch at all
	#remove self mask if it not the same as out mask
	if body in body_entered_out and line_masks[LINE_MAIN] != line_masks[sel_line]:
		var mask = body.get_collision_mask()
		mask = mask & ~line_masks[LINE_MAIN]
		body.set_collision_mask(mask)
	#else leave self mask
	
func _on_out_body_entered(body):
	if body.get_meta("part") != "wheel":
		return
	body_entered_out.append(body)
	
	#checking for single way fork
	var true_from_in = false	
	if body in body_entered_in:
		true_from_in = true


	
	var mask = body.get_collision_mask()
	var from_active = mask & line_masks[sel_line] == line_masks[sel_line]
	if not body in body_entered_in and not from_active:
		switch_line()
		
#	mask = mask & 0xffff
	mask = mask | line_masks[sel_line]
	#print("set out mask 0x%04x" % (mask >> 16))
	body.set_collision_mask(mask)

func _on_out_body_exited(body):
	body_entered_out.erase(body)
	#need to remove self mask 
	if body in body_entered_in and line_masks[LINE_MAIN] != line_masks[sel_line]:
		var mask = body.get_collision_mask()
		mask = mask & ~line_masks[sel_line]
		body.set_collision_mask(mask)
	#else leave self mask

func _on_sensor_area_entered(area):
	if area.name == "interact":
		can_interact = true
		zoom = ZOOM_FACTOR
		set_zoom()


func _on_sensor_area_exited(area):
	if area.name == "interact":
		can_interact = false
		zoom = 1.0
		set_zoom()

