tool
extends Path2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

export (int, "line1", "line2", "line3", "line4", "line5", "line6", "line7", "line8", "line9", "line10", "line11", "line12", "line13", "line14") var rail_id = 0 setget set_rail_id, get_rail_id
export (int, "city", "bridge") var rail_type = 0
var linecolor = 0
const CARS = ["loco"]
onready var line_mask = 1 << linecolor + 16
var a = Color.aliceblue

var LN_CRLS = [Color("aaFFCDF3"), Color("aaFF9233"), Color("aaFFEE33"), Color("aa29D0D0"), Color("aaAD2323"),Color("aaE9DEBB"),Color("aa81C57A"),Color("aa9DAFFF"),Color("aa8126C0"),Color("aa814A19"),Color("aa1D6914"),Color("aa2A4BD7"),Color("aaFFFFFF"),Color("aaA0A0A0"),Color("aa575757"),Color("aa000000")]

func set_rail_id(value):
	set_self_modulate(LN_CRLS[value])
	linecolor = value
	
func get_rail_id():
	#var clr: Color =  get_self_modulate()
	#var ind = LN_CRLS.find(clr)
	#print(ind)
	return linecolor

func init_set_car_col_mask():
	var guides = get_children()
	for g in guides:
		var c = g.get_child(0)
		if c is RigidBody2D and c.get_meta("type") in CARS:
			print("setting mask ")
			c.set_active_line(line_mask)

# Called when the node enters the scene tree for the first time.
func _ready():
	#print (linecolor)
	#create rigid body for curve
	var rb: StaticBody2D = StaticBody2D.new()
	rb.name = "rb"
	#rb.mode = RigidBody2D.MODE_STATIC
	var mask = 1 << linecolor + 15
	rb.set_collision_layer_bit(0, false)
	rb.set_collision_mask_bit(0, false)
	rb.set_collision_layer_bit(linecolor + 16, true)
	rb.set_collision_mask_bit(linecolor + 16, true)
	add_child(rb)
	
	var lnbg: Line2D = Line2D.new()
	lnbg.name = "ln_bg"
	lnbg.default_color = Color(0.5, 0.5, 0.5, 1) 
	lnbg.width = 45
	lnbg.texture_mode = 1#  LINE_TEXTURE_TILE
	if rail_type == 0:
		lnbg.texture = load("res://assets/rail_city.png")
	else:
		lnbg.texture = load("res://assets/rail_bridge_a.png")
	lnbg.z_index = 2
	add_child(lnbg)
	
	#draw curve line
	var ln: Line2D = Line2D.new()
	ln.name = "ln"
	ln.default_color = Color(0.5, 0.5, 0.5, 1) 
	ln.width = 45
	ln.texture_mode = 1#  LINE_TEXTURE_TILE
	ln.texture = load("res://assets/rail_blades.png")
	ln.z_index = 3
	add_child(ln)
	
	# build collision line over the curve and draw it
	var bpts: PoolVector2Array = curve.get_baked_points()
	#create lines
	#var ln: Line2D = get_node("ln")
	#var ln: Line2D = Line2D.new()
	#add_child(ln)
	ln.set_points(bpts)
	lnbg.set_points(bpts)
	#print(bpts)
	
	#create capsules
	#var rb: RigidBody2D = get_node("rb")
	var cs: CollisionShape2D = null
	var sh: CapsuleShape2D = null
	#var sh: RectangleShape2D = null
	var v: Vector2 = Vector2(0, 0)
	
	for i in bpts.size() - 1:
		cs = CollisionShape2D.new()
		rb.add_child(cs)
		#calc middle point to place shape there
		v = (bpts[i+1] - bpts[i]) / 2
		var l = v.length() * 2 
		cs.rotation = v.angle() + PI /2 
		v = v + bpts[i]
		#print(v)
		cs.position = v
		
		sh = CapsuleShape2D.new()
		sh.radius = 9.5 # 8.5
		sh.height = l
		#sh = RectangleShape2D.new()
		#sh.extents.x = 8.5
		#sh.extents.y = l / 2
		cs.shape = sh

	#line masking
	init_set_car_col_mask()
	#print(bpts)
	
	#pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
