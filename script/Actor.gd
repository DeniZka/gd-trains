extends RigidBody2D

var force = 100
var speed = 11
var qspeed = speed * speed
var poly: Polygon2D = null
var mounted = null
enum ms {MS_DRIVER, MS_PASSANGEER}
var mount_status = ms.MS_DRIVER
var look_at = Vector2(1, 0)
var can_sit = false
var vehicle_near = []
var moving = false #when pressed buttons
var moving_area_body = null
enum {ST_IDLE, ST_WALK, ST_JUMP, ST_DRIVE}
var a_state = ST_IDLE

onready var pj: PinJoint2D = $ground_detector/pj

# Called when the node enters the scene tree for the first time.
func _ready():
	poly = get_node("poly_actor")
	pass # Replace with function body.

func coll_on_off(status):
	#set_collision_mask_bit(0, status)
	#set_collision_layer_bit(0, status)
	
	#set_collision_layer_bit(1, status)
	#set_collision_layer_bit(1, status)
	pass
	
func do_mount(vehicle):
	mount_status = vehicle.mount(self)
	coll_on_off(false)
	mounted = vehicle
#				get_parent().remove_child(self)0.02
#				vv.add_child(self)
	#position = vehicle.global_position #DO THIS IN MAIN PROCESS CAUSE OF PHYSICSC DOESNOT ACCEPT IT
	position = vehicle.get_nearest_mount_point(self.global_position)
	$interact.monitorable = false
	$ground_detector.monitoring = false
	#vv.print_mask()	
	
func do_umount():
	#position = mounted.get_node("dismount_point").position
	mounted.umount(self)
	set_linear_velocity(Vector2(0, 0))
#			set_rotation(0)
	coll_on_off(true)
	#var main: Node = get_node("/root/main")
	#get_parent().remset_linear_velocityove_child(self)
	#main.add_child(self)
	global_position = mounted.get_nearest_dismount_point(self.global_position)
	mounted = null	
	$interact.monitorable = true
	$ground_detector.monitoring = true #FIXME: bug when stand back on ground
	
	pj.node_b = ""
	
func try_mount_set_state():
	if not mounted:
		if vehicle_near.size() > 0:
			var vv = vehicle_near[0] # or will be null :( bug???
			if vv.mountable:
				do_mount(vv)
				if vv.got_engine:
					a_state = ST_DRIVE
					$interact/Sprite.visible = false
					$interact/shadow.visible = false
				else:
					a_state = ST_IDLE
	else:
		do_umount()
			
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	match a_state:
		ST_IDLE:
			$interact/AnimationPlayer.play("stand")
			if Input.is_action_pressed("ui_left") or Input.is_action_pressed("ui_right") or Input.is_action_pressed("ui_up") or Input.is_action_pressed("ui_down"):
				a_state = ST_WALK
			if Input.is_action_just_pressed("mount"):
				try_mount_set_state()
		ST_DRIVE:
			$interact/AnimationPlayer.play("stand")
			if Input.is_action_just_pressed("mount"):
				$interact/Sprite.visible = true
				$interact/shadow.visible = true
				do_umount()
				a_state = ST_IDLE
		ST_WALK:
			if not (Input.is_action_pressed("ui_left") or Input.is_action_pressed("ui_right") or Input.is_action_pressed("ui_up") or Input.is_action_pressed("ui_down")):
				a_state = ST_IDLE
			$interact/AnimationPlayer.play("scriptwalk")
			if Input.is_action_just_pressed("mount"):
				try_mount_set_state()
			

func _physics_process(delta):
	pass

#	
#	set_linear_velocity(get_linear_velocity() + l.get_linear_velocity())
#	set_linear_velocity(Vector2(30, 0))


func _integrate_forces(state: Physics2DDirectBodyState):
	#rotation = 0
	var v: Vector2 = Vector2.ZERO
		
	match a_state:
		ST_IDLE:
			if mounted: #as passenger
				#state.set_linear_velocity(mounted.linear_velocity)
				pj.node_b = mounted.get_path()
			elif moving_area_body:
				pj.node_b = moving_area_body.get_path() #hook				
			else:
				state.set_linear_velocity(Vector2.ZERO)
		ST_DRIVE:
			#state.set_linear_velocity(mounted.linear_velocity)
			pj.node_b = mounted.get_path()
		ST_WALK:
			#if not mounted:
			if Input.is_action_pressed("ui_left"):
				v.x += -1
			if Input.is_action_pressed("ui_right"):
				v.x += 1
			if Input.is_action_pressed("ui_up"):
				v.y += -1
			if Input.is_action_pressed("ui_down"):
				v.y += 1
			if Input.is_key_pressed(KEY_SHIFT):
				v = v.normalized() * force * 2
			else:
				v = v.normalized() * force
			v = v.rotated($cam.rotation)
			#do not turn while just stand
			$interact.rotation = v.angle() + PI/2
			
			pj.node_b = ""
			if mounted:
				state.set_linear_velocity(v + mounted.linear_velocity)
			elif moving_area_body:
				if moving_area_body is StaticBody2D:
					state.set_linear_velocity(v)
				else:
					state.set_linear_velocity(v + moving_area_body.linear_velocity)
			else:
				state.set_linear_velocity(v)

#	
#	linear_velocity = linear_velocity + l.linear_velocity
#	pass

func _on_mount_fndr_body_entered(body):
	if body.has_meta("type") and body.get_meta("type") == "loco" and body.mountable:
		vehicle_near.append(body)
		print("can sit")


func _on_mount_fndr_body_exited(body):
	if body.has_meta("type") and body.get_meta("type") == "loco":
		vehicle_near.erase(body)
		can_sit = false


func _on_Player_body_entered(body):
	print(body.name)

func _on_ground_detector_area_entered(area):
	moving_area_body = area.get_parent()

func _on_ground_detector_area_exited(area):
	pj.node_b = "" #due to stuck
	moving_area_body = null
