extends Node

class_name BattleController

@export var player: Player
@export var enemies: Array[CharacterBody2D]

@onready var players: Array[CharacterBody2D] = [player]
@onready var rng = RandomNumberGenerator.new()

var current_turn: Node
var all_combatants: Array[CharacterBody2D]
var current_combatant
var round: int
var target_monster

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	round = 0
	for player in players:
		player.current_state = player.state.COMBAT
		player.current_combat_state = player.combat_state.INIT
	for enemy in enemies:
		enemy.current_state = enemy.state.COMBAT
		enemy.current_combat_state = enemy.combat_state.INIT
	all_combatants = enemies + players
	all_combatants.shuffle()
	current_combatant = all_combatants.pop_front()



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	if current_combatant.current_combat_state != current_combatant.combat_state.ENDTURN:
		if current_combatant.current_combat_state == current_combatant.combat_state.INIT:
			if current_combatant in players:
				if enemies.any(func(combatant) : return combatant.is_alive() and combatant.melee_zone.overlaps_area(current_combatant.melee_zone)):
					current_combatant.current_combat_state = current_combatant.combat_state.ATTACKANIM
					target_monster = enemies.filter(func(combatant) : return combatant.is_alive() and combatant.melee_zone.overlaps_area(current_combatant.melee_zone)).pick_random()
					var angle = current_combatant.global_position.angle_to_point(target_monster.global_position)
					if angle > -PI/2 and angle < PI/2:
						current_combatant.attack_direction = current_combatant.facing.RIGHT
					else:
						current_combatant.attack_direction = current_combatant.facing.LEFT
				else:
					current_combatant.current_combat_state = current_combatant.combat_state.INITMOVE
			else:
				if players.any(func(combatant) : return combatant.is_alive() and combatant.melee_zone.overlaps_area(current_combatant.melee_zone)):
					current_combatant.current_combat_state = current_combatant.combat_state.ATTACKANIM
					var angle = current_combatant.global_position.angle_to_point(player.global_position)
					if angle > -PI/4 and angle < PI/4:
						current_combatant.attack_direction = current_combatant.facing.RIGHT
					elif angle > PI/4 and angle < 3*PI/4:
						current_combatant.attack_direction = current_combatant.facing.DOWN
					elif angle > -3*PI/4 and angle < -PI/4:
						current_combatant.attack_direction = current_combatant.facing.UP
					else:
						current_combatant.attack_direction = current_combatant.facing.LEFT
				else:
					current_combatant.current_combat_state = current_combatant.combat_state.INITMOVE
				
			#current_combatant.current_combat_state = current_combatant.combat_state.ATTACK
		elif current_combatant.current_combat_state == current_combatant.combat_state.INITMOVE:
			if current_combatant in players:
				pass
			else:
				print("Calculate new position for MONSTER")
				current_combatant.distance = 0
				print((current_combatant.global_position- player.global_position).normalized())
				
				var angle = current_combatant.global_position.angle_to_point(player.global_position)
				print(angle)
				if  angle > -PI/8  and angle < PI/8:  
					current_combatant.navigation_agent_2d.target_position = player.global_position + Vector2(-16, 0)
				elif angle > PI/8  and angle < 3*PI/8:  
					current_combatant.navigation_agent_2d.target_position = player.global_position + Vector2(-16, -16)
				elif angle > -3*PI/8  and angle < -PI/8:  
					current_combatant.navigation_agent_2d.target_position = player.global_position + Vector2(-16, 16)
				elif angle > -5*PI/8  and angle < -3*PI/8:  
					current_combatant.navigation_agent_2d.target_position = player.global_position + Vector2(0, 16)
				elif angle > -7*PI/8  and angle < -5*PI/8:  
					current_combatant.navigation_agent_2d.target_position = player.global_position + Vector2(16, 16)
				elif angle > 3*PI/8  and angle < 5*PI/8:  
					current_combatant.navigation_agent_2d.target_position = player.global_position + Vector2(0, -16)
				elif angle > 5*PI/8  and angle < 7*PI/8:  
					current_combatant.navigation_agent_2d.target_position = player.global_position + Vector2(16, -16)	
				else:
					current_combatant.navigation_agent_2d.target_position = player.global_position + Vector2(16,0)
				current_combatant.current_combat_state = current_combatant.combat_state.MOVE

		elif current_combatant.current_combat_state == current_combatant.combat_state.MOVE:
			if current_combatant in players:
				if enemies.any(func(combatant) : return combatant.is_alive() and combatant.melee_zone.overlaps_area(current_combatant.melee_zone)):
					current_combatant.current_combat_state = current_combatant.combat_state.MOVEEND
			else:
				if players.any(func(combatant) : return combatant.is_alive() and combatant.melee_zone.overlaps_area(current_combatant.melee_zone)):
					current_combatant.current_combat_state = current_combatant.combat_state.MOVEEND
					current_combatant.velocity.x = move_toward(current_combatant.velocity.x, 0, current_combatant.speed)
					current_combatant.velocity.y = move_toward(current_combatant.velocity.y, 0, current_combatant.speed)
				#current_combatant.current_combat_state = current_combatant.combat_state.ATTACKANIM
		elif current_combatant.current_combat_state == current_combatant.combat_state.MOVEEND:
			if current_combatant in players:
				if enemies.any(func(combatant) : return combatant.is_alive() and combatant.melee_zone.overlaps_area(current_combatant.melee_zone)):
					current_combatant.current_combat_state = current_combatant.combat_state.ATTACKANIM
					target_monster = enemies.filter(func(combatant) : return combatant.is_alive() and combatant.melee_zone.overlaps_area(current_combatant.melee_zone)).pick_random()
					var angle = current_combatant.global_position.angle_to_point(target_monster.global_position)
					if angle > -PI/2 and angle < PI/2:
						current_combatant.attack_direction = current_combatant.facing.RIGHT
					else:
						current_combatant.attack_direction = current_combatant.facing.LEFT
				else:
					current_combatant.current_combat_state = current_combatant.combat_state.ENDTURN
				pass
			else:
				if players.any(func(combatant) : return combatant.is_alive() and combatant.melee_zone.overlaps_area(current_combatant.melee_zone)):
					current_combatant.current_combat_state = current_combatant.combat_state.ATTACKANIM
					var angle = current_combatant.global_position.angle_to_point(player.global_position)
					if angle > -PI/4 and angle < PI/4:
						current_combatant.attack_direction = current_combatant.facing.RIGHT
					elif angle > PI/4 and angle < 3*PI/4:
						current_combatant.attack_direction = current_combatant.facing.DOWN
					elif angle > -3*PI/4 and angle < -PI/4:
						current_combatant.attack_direction = current_combatant.facing.UP
					else:
						current_combatant.attack_direction = current_combatant.facing.LEFT
				else:
					current_combatant.current_combat_state = current_combatant.combat_state.ENDTURN
			

			#current_combatant.current_combat_state = current_combatant.combat_state.ATTACK
		elif current_combatant.current_combat_state == current_combatant.combat_state.ATTACKANIM:
			pass
		elif current_combatant.current_combat_state == current_combatant.combat_state.ATTACK:
			if current_combatant in players:
				if enemies.any(func(combatant) : return combatant.is_alive() and combatant.melee_zone.overlaps_area(current_combatant.melee_zone)):
					
					var hit = current_combatant.roll_to_hit(5)
					if hit:
						var damage = current_combatant.deal_damage()
						target_monster.take_damage(damage)
				current_combatant.current_combat_state = current_combatant.combat_state.ENDTURN
			else:
				var hit = current_combatant.roll_to_hit(12)
				if hit:
					var damage = current_combatant.deal_damage()
					player.take_damage(damage)
				
				current_combatant.current_combat_state = current_combatant.combat_state.ENDTURN
		else:
			pass
	elif all_combatants.any(func(combatant) : return combatant.is_alive()):
		current_combatant = all_combatants.pop_front()
	elif player.is_alive() and enemies.any(func(combatant) : return combatant.is_alive()):
		all_combatants = enemies.filter(func(combatant) : return combatant.is_alive()) + players
		
		all_combatants.shuffle()
		for combatant in all_combatants:
			combatant.current_state = combatant.state.COMBAT
			combatant.current_combat_state = combatant.combat_state.INIT
		
		current_combatant = all_combatants.pop_front()
		
	elif player.is_alive():
		player.current_state = player.state.EXPLORE
		for enemy in enemies:
			enemy.queue_free()
		self.queue_free()
	pass
