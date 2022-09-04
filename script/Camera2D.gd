extends Camera2D

onready var actor: RigidBody2D = $".."

const ST_DEFAULT = 0
const ST_TRANSIT_TO_MOUNT = 1 
const ST_MOUNT = 2
const ST_TRANSIT_TO_DEFAULT = 3
enum ms {MS_DRIVER, MS_PASSANGEER}

var cam_state = ST_DEFAULT
var lerp_w = 0
const TR_SPEED = 2
var last_mount_angle = 0
var add_angle = 0

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
	
func transit_to():

	pass
	
func _unhandled_input(event):
	pass
	#if Input.is_action_pressed()
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	match cam_state:
		ST_DEFAULT:
			if actor.mounted and actor.mount_status == ms.MS_PASSANGEER:
				cam_state = ST_TRANSIT_TO_MOUNT
				lerp_w = 0
				#select nearest vehicle rotation angle
				var ang_orig = actor.mounted.global_rotation
				print("angs: ", ang_orig)
				if  abs(ang_orig) <= PI/2:
					add_angle = 0
				else:
					add_angle = PI
					
			else:
				rotation = 0
		ST_TRANSIT_TO_MOUNT:
			lerp_w += TR_SPEED * delta
			if lerp_w >= 1:
				lerp_w = 1
				cam_state = ST_MOUNT
			rotation = lerp_angle(0, (actor.mounted.global_rotation + add_angle), lerp_w)				
				
		ST_MOUNT:
			if not actor.mounted:
				cam_state = ST_TRANSIT_TO_DEFAULT
			else:
				last_mount_angle = actor.mounted.global_rotation + add_angle
				rotation = last_mount_angle
		ST_TRANSIT_TO_DEFAULT:
			lerp_w -= TR_SPEED * delta
			if lerp_w < 0:
				lerp_w = 0
			rotation = lerp_angle(0, last_mount_angle, lerp_w)
			if lerp_w == 0:
				cam_state = ST_DEFAULT
		
