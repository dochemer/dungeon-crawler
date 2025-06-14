extends Control

@onready var strength: int
@onready var strength_text: LineEdit = $Characteristics/Strength/LineEdit
@onready var rng = RandomNumberGenerator.new()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_strength_button_pressed() -> void:
	strength_text.text = str(_roll_stat()) # Replace with function body.
	
	
func _roll_stat() -> int:
	var dice_rolls = []
	var total = 0
	for i in range(4):
		dice_rolls.append(rng.randi_range(1,6))
	dice_rolls.sort()
	print(dice_rolls)
	for r in dice_rolls.slice(1,4):
		total += r
	return total
