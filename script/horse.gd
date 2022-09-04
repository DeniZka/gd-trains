extends RigidBody2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
enum {BACK, STAY, WALK, TROT, CANTER, GALLOP}
var move_state = STAY
enum {LEFT, STRAIT, RIGHT}
var turn_state = STRAIT
onready var ap = $AnimationPlayer
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.
	
const ROT_BACK = 0.3
const ROT_STAY = 1
const ROT_WALK = 0.7
const ROT_TROT = 0.6
const ROT_CANTER = 0.3
const ROT_GALLOP = 0.2
var speed = 0
var sv = Vector2(0, 0)
var rot_speed = 1


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
				
func _input(event):
	if Input.is_action_pressed("ui_left"):
		turn_state = LEFT
	if Input.is_action_pressed("ui_right"):
		turn_state = RIGHT

	if Input.is_action_just_released("ui_left"):
		turn_state = STRAIT
	if Input.is_action_just_released("ui_right"):
		turn_state = STRAIT
		
	match move_state:
		BACK: 
			if Input.is_action_just_released("ui_down"):
				rot_speed = ROT_STAY
				move_state = STAY
		STAY:
			if Input.is_action_just_pressed("ui_down"):
				rot_speed = -ROT_BACK
				move_state = BACK
			if Input.is_action_just_pressed("ui_up"):
				rot_speed = ROT_WALK
				move_state = WALK
		WALK:
			if Input.is_action_just_pressed("ui_down"):
				rot_speed = ROT_STAY
				move_state = STAY
			if Input.is_action_just_pressed("ui_up"):
				rot_speed = ROT_TROT
				move_state = TROT
		TROT:
			if Input.is_action_just_pressed("ui_down"):
				rot_speed = ROT_WALK
				move_state = WALK
			if Input.is_action_just_pressed("ui_up"):
				rot_speed = ROT_CANTER
				move_state = CANTER
		CANTER:
			if Input.is_action_just_pressed("ui_down"):
				rot_speed = ROT_TROT
				move_state = TROT
			if Input.is_action_just_pressed("ui_up"):
				rot_speed = ROT_GALLOP
				move_state = GALLOP
		GALLOP:
			if Input.is_action_just_pressed("ui_down"):
				rot_speed = ROT_CANTER
				move_state = CANTER
#			if Input.is_action_just_pressed("ui_up"):
#				move_state = WALK
				#speedup again
				
func _physics_process(delta):
	pass
	
func _integrate_forces(state: Physics2DDirectBodyState):
	match move_state:
		BACK: 
			state.linear_velocity = Vector2(1,0).rotated(global_rotation + PI/2) * 10
			pass
		STAY:
			state.linear_velocity = Vector2(0, 0)
			pass
		WALK:
			state.linear_velocity = Vector2(1, 0).rotated(global_rotation - PI/2) * 10
			pass
		TROT:
			state.linear_velocity = Vector2(1, 0).rotated(global_rotation - PI/2) * 20
			pass
		CANTER:
			state.linear_velocity = Vector2(1, 0).rotated(global_rotation - PI/2) * 40
			pass
		GALLOP:
			state.linear_velocity = Vector2(1, 0).rotated(global_rotation - PI/2) * 80
			pass
	match turn_state:
		LEFT:
			state.angular_velocity = -rot_speed
			pass
		STRAIT:
			state.angular_velocity = 0
			pass
		RIGHT:
			state.angular_velocity = rot_speed
			pass
	pass
