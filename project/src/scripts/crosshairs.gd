extends Node2D

class_name CrossHair

signal aim_completed(position)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	print("Creating a new cross hair")
	visible = false
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	position = get_global_mouse_position()


func _input(event):
	if event is InputEventMouseButton and event.double_click:
		print("Double click ", event.position)
	elif event is InputEventMouseButton and event.pressed and event.button_index == 1:
		print("Mouse Click ", event.position)
		aim_completed.emit(get_global_mouse_position())
		visible = not visible
	elif event is InputEventMouseButton and event.pressed and event.button_index == 2:
		print("Right Mouse Click ", event.position)
		print("Cancel aiming")
		self.free()
		
