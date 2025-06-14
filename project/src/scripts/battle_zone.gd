extends Area2D

class_name BattleZone

@export var collision_poly: CollisionPolygon2D
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	self.body_entered.connect(_on_zone_body_entered)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_zone_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		var monsters = self.get_overlapping_bodies().filter(func(node): return node.is_in_group("Monster"))
		if monsters != []:
			var battle_controller = BattleController.new()
			print(monsters)
			#for monster in monsters:
			#	battle_controller.enemies 
			battle_controller.player = body
			var enemies: Array[CharacterBody2D]
			enemies.assign(monsters)
			battle_controller.enemies = enemies
			add_child(battle_controller)
		#print(self.name, "entered zone")
		#print(self.name, "chasing")
		#current_state = state.CHASING
		#distance = 0
		#navigation_agent_2d.target_position = body.global_position
