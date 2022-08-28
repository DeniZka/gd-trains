tool #enables setter and getter in tool
extends PathFollow2D

export (bool) var flip setget set_flip, get_flip

func set_flip(value):
	print("ok")
	var cs: RigidBody2D = get_node("terminator")
	if value:
		cs.set_rotation_degrees( 180 )
	else:
		cs.set_rotation_degrees( 0 )
	update()
	
func get_flip():
	var cs: RigidBody2D = get_node("terminator")
	if cs.get_rotation_degrees( ):
		return true
	else:
		return false
	
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
