extends RigidBody2D

var force = 100
var speed = 11
var qspeed = speed * speed
var poly: Polygon2D = null
var mounted = null
var look_at = Vector2(1, 0)
var can_sit = false
var vehicle_near = []
var moving = false #when pressed buttons
var moving_area_body = null

# Called when the node enters the scene tree for the first time.
func _ready():
	poly = get_node("poly_actor")
	pass # Replace with function body.

func coll_on_off(status):
	#set_collision_mask_bit(0, status)
	set_collision_layer_bit(1, status)
	#set_collision_layer_bit(0, status)
	set_collision_layer_bit(1, status)
	
func do_mount(vehicle):
	vehicle.mount(self)
	coll_on_off(false)
	mounted = vehicle
#				get_parent().remove_child(self)0.02
#				vv.add_child(self)
	position = vehicle.global_position #DO THIS IN MAIN PROCESS CAUSE OF PHYSICSC DOESNOT ACCEPT IT
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
	mounted = null	
	$interact.monitorable = true
	$ground_detector.monitoring = true #FIXME: bug when stand back on ground
	$pj.node_b = ""
	
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Input.is_action_pressed("ui_left") or Input.is_action_pressed("ui_right") or Input.is_action_pressed("ui_up") or Input.is_action_pressed("ui_down"):
		$interact/AnimationPlayer.play("scriptwalk")
	else:
		$interact/AnimationPlayer.play("stand")
	
	if Input.is_action_just_pressed("mount"):
		if not mounted and vehicle_near.size() > 0:
			var vv = vehicle_near[0] # or will be null :( bug???
			if vv.mountable:
				do_mount(vv)
		elif mounted:
			do_umount()
	

func _physics_process(delta):
	pass

#	
#	set_linear_velocity(get_linear_velocity() + l.get_linear_velocity())
#	set_linear_velocity(Vector2(30, 0))


func _integrate_forces(state: Physics2DDirectBodyState):
	
	
	
	if Input.is_action_just_released("ui_left"):
		set_linear_velocity(Vector2(0, 0))
		moving = false
	if Input.is_action_just_released("ui_right"):
		set_linear_velocity(Vector2(0, 0))	
		moving = false
	if Input.is_action_just_released("ui_up"):
		set_linear_velocity(Vector2(0, 0))
		moving = false
	if Input.is_action_just_released("ui_down"):
		set_linear_velocity(Vector2(0, 0))
		moving = false
			
	
	#rotation = 0
	var v: Vector2 = Vector2(0, 0)
	#if not mounted:
	if Input.is_action_pressed("ui_left"):
		moving = true
		v.x += -1
	if Input.is_action_pressed("ui_right"):
		v.x += 1
		moving = true
	if Input.is_action_pressed("ui_up"):
		v.y += -1
		moving = true
	if Input.is_action_pressed("ui_down"):
		v.y += 1
		moving = true
			
	#rotate poly only when walking	
	if Input.is_key_pressed(KEY_SHIFT):
		v = v.normalized() * force * 2
	else:
		v = v.normalized() * force
	v = v.rotated($cam.rotation)
	#do not turn while just stand
	if moving:
		$interact.rotation = v.angle() + PI/2

		
	if mounted:
		pass
#		var l:RigidBody2D = $"/root/main/lines/c_centr/car_poser2/loco"
		#set_linear_velocity(v + mounted.linear_velocity)
		set_linear_velocity(mounted.linear_velocity)
		#if moving:
		#	$pj.node_b = ""
		#else:
		#	$pj.node_b = mounted.get_path()
	elif moving_area_body:
		if moving:
			$pj.node_b = ""
			if moving_area_body is StaticBody2D:
				set_linear_velocity(v)
			else:
				set_linear_velocity(v + moving_area_body.linear_velocity)
		else:
			$pj.node_b = moving_area_body.get_path()
		
	else:
		
		set_linear_velocity(v)
	var lvel: Vector2 = get_linear_velocity()
#	print(lvel.length())
	if ( lvel.length_squared() > (qspeed) ):
		lvel = lvel.normalized() * speed
#		set_linear_velocity(lvel)	
	
#	
#	linear_velocity = linear_velocity + l.linear_velocity
#	pass

func _on_mount_fndr_body_entered(body):
	if body.get_meta("type") == "loco" and body.mountable:
		vehicle_near.append(body)
		print("can sit")


func _on_mount_fndr_body_exited(body):
	if body.get_meta("type") == "loco":
		vehicle_near.erase(body)
		can_sit = false


func _on_Player_body_entered(body):
	print(body.name)
	pass # Replace with function body.

func _on_ground_detector_area_entered(area):
	moving_area_body = area.get_parent()

func _on_ground_detector_area_exited(area):
	$pj.node_b = "" #due to stuck
	moving_area_body = null
