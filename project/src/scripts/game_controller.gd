extends Node2D

@export var battle_controller: BattleController

@onready var player: Player = $player
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#battle_controller.player = player
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
