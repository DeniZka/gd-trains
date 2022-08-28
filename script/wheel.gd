extends RigidBody2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
func set_active_line(line_mask):
	var mask = get_collision_mask()
	mask = mask & 0xffff
	mask = mask | line_mask
	set_collision_mask(mask)

# Called when the node enters the scene tree for the first time.
func _ready():
	set_meta("part", "wheel")
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
