extends PathFollow2D

signal on_tip_met()

# Called when the node enters the scene tree for the first time.
func _ready():
	$Area2D/arrow.visible = false

func _on_Area2D_area_entered(area):
	emit_signal("on_tip_met")
