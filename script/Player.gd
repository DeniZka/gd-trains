extends RigidBody2D


var speed = 30
var poly: Polygon2D = null
var mounted = null
var look_at = Vector2(1, 0)
var can_sit = false
var vehicle_near = []

# Called when the node enters the scene tree for the first time.
func _ready():
	poly = get_node("poly_actor")
	pass # Replace with function body.

func coll_on_off(status):
	set_collision_mask_bit(0, status)
	set_collision_layer_bit(0, status)
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Input.is_action_pressed("ui_left") or Input.is_action_pressed("ui_right") or Input.is_action_pressed("ui_up") or Input.is_action_pressed("ui_down"):
		$Node2D/AnimationPlayer.play("scriptwalk")
	else:
		$Node2D/AnimationPlayer.play("stand")
	pass
	
	if Input.is_action_just_pressed("mount"):
		if not mounted and vehicle_near.size() > 0:
			var vv = vehicle_near[0] # or will be null :( bug???
			if vv.mountable:
				vv.mount(self)
				coll_on_off(false)
				mounted = vv
				position = Vector2(0, 0)
				$interact.monitorable = false
				#vv.print_mask()
			
		elif mounted:
			#position = mounted.get_node("dismount_point").position
			mounted.umount(self)
			set_linear_velocity(Vector2(0, 0))
			position
			set_rotation(0)
			coll_on_off(true)
			#var main: Node = get_node("/root/main")
			#get_parent().remset_linear_velocityove_child(self)
			#main.add_child(self)
			mounted = null	
			$interact.monitorable = true	
	

func _physics_process(delta):

	
	rotation = 0
	var v: Vector2 = Vector2(0, 0)
	if not mounted:
		if Input.is_action_pressed("ui_left"):
			v.x += -1
		if Input.is_action_pressed("ui_right"):
			v.x += 1
		if Input.is_action_pressed("ui_up"):
			v.y += -1
		if Input.is_action_pressed("ui_down"):
			v.y += 1
			
			
#	else:

		
	#rotate poly only when walking	
	v = v.normalized() * speed
	#do not turn while just stand
	if v != Vector2(0, 0):
		$shadow.rotation = v.angle() + PI/2
		$Node2D.rotation = v.angle() + PI/2
		
	#poly.rotate( v.angle() )
	
	if Input.is_action_just_released("ui_left"):
		set_linear_velocity(Vector2(0, 0))
	if Input.is_action_just_released("ui_right"):
		set_linear_velocity(Vector2(0, 0))	
	if Input.is_action_just_released("ui_up"):
		set_linear_velocity(Vector2(0, 0))
	if Input.is_action_just_released("ui_down"):
		set_linear_velocity(Vector2(0, 0))
			

	

			
	if mounted:
		set_linear_velocity(Vector2(0, 0)) #no self move
		set_global_transform(mounted.get_global_transform()) #set global position of mount
		#set_position(mounted.get_position())
			
	set_applied_force(v * speed)
	var lvel: Vector2 = get_linear_velocity() 
	if ( lvel.length_squared() > (30 * 30) ):
		lvel = lvel.normalized() * 30
		set_linear_velocity(lvel)
	


func _on_mount_fndr_body_entered(body):
	if body.get_meta("type") == "loco":
		vehicle_near.append(body)
		print("can sit")


func _on_mount_fndr_body_exited(body):
	if body.get_meta("type") == "loco":
		vehicle_near.erase(body)
		can_sit = false


func _on_Player_body_entered(body):
	print(body.name)
	pass # Replace with function body.
