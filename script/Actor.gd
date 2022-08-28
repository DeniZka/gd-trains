extends KinematicBody2D

# This represents the player's inertia.
export (int, 0, 200) var push = 10
# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var speed = 200
var poly: Polygon2D = null
var mounted = null
var look_at = Vector2(1, 0)
var can_sit = false
var vehicle_near = null

# Called when the node enters the scene tree for the first time.
func _ready():
	poly = get_node("poly_actor")
	pass # Replace with function body.

func coll_on_off(status):
	set_collision_mask_bit(0, status)
	set_collision_layer_bit(0, status)
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
func _physics_process(delta):
	return
	var v: Vector2 = Vector2(0, 0)
	if Input.is_action_pressed("ui_left"):
		v.x += -1
	if Input.is_action_pressed("ui_right"):
		v.x += 1
	if Input.is_action_pressed("ui_up"):
		v.y += -1
	if Input.is_action_pressed("ui_down"):
		v.y += 1
	v = v.normalized() * speed
	if v != Vector2(0, 0):
		poly.rotation = v.angle()
	#poly.rotate( v.angle() )
	
	
	if Input.is_action_just_pressed("mount"):
		if not mounted and vehicle_near:
			var vv = vehicle_near # or will be null :( bug???
			coll_on_off(false)
			get_parent().remove_child(self)
			vv.add_child(self)
			mounted = vv
			position = Vector2(0, 0)
		elif mounted:
			#position = mounted.get_node("dismount_point").position
			coll_on_off(true)
			mounted = null		
	
	
	
	
	#move_and_slide(v,Vector2(0,0),false,4,0.785398,false)#, Vector2(1, 0))
	move_and_slide(v)
	# after calling move_and_slide()
	for index in get_slide_count():
		var collision = get_slide_collision(index)
		if collision.collider.is_in_group("bodies"):
			collision.collider.apply_central_impulse(-collision.normal * push)
	

	

func _on_mount_fndr_body_entered(body):
	if body.get_meta("type") == "loco":
		vehicle_near = body
		print("can sit")


func _on_mount_fndr_body_exited(body):
	if body.get_meta("type") == "loco":
		vehicle_near = null
		can_sit = false
	pass # Replace with function body.
