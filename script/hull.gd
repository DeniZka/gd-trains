extends RigidBody2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
export var car_ID: int = 0
var f = 30000
var picked = false
var wheels = []

# Called when the node enters the scene tree for the first time.
func _ready():
	if car_ID > 10:
		get_node("loco").visible = false
	else:
		get_node("car").visible = false
	
	wheels.append(get_node("wheelL1"))
	wheels.append(get_node("wheelL2"))
	wheels.append(get_node("wheelR1"))
	wheels.append(get_node("wheelR2"))
	set_meta("type", "loco")
	var l: Label = get_node("text_pose/id")
	var s: String = "%04d" % car_ID
	l.text = s
	pass # Replace with function body.

func set_active_line(line_mask):
	for w in wheels:
		w.set_active_line(line_mask)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	#print(global_rotation)
	pass
	
func accelerate():
	var v = Vector2(1 * f, 0)
	set_applied_force(v.rotated(global_rotation))
	#add_central_force(v.rotated(global_rotation))
	
func decelerate():
	var v = Vector2(1 * f, 0)
	#add_central_force(v.rotated(global_rotation + PI))
	set_applied_force(v.rotated(global_rotation + PI))
	
func no_force():
	set_applied_force(Vector2(0, 0))

func _physics_process(delta):
	if picked:
		set_applied_force(Vector2(0, 0))
		if Input.is_action_pressed("accelerate"):
			accelerate()
			
		if Input.is_action_pressed("break"):
			decelerate()


func _on_hull_mouse_entered():
	picked = true
	#print("mouse is in")
	#pass # Replace with function body.


func _on_hull_mouse_exited():
	picked = false
	#pass # Replace with function body.
