extends Monster

class_name Ghost

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super._ready()
	max_health = 25
	health = 25
