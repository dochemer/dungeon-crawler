extends CharacterBody2D

class_name Player

enum state {
	EXPLORE,
	COMBAT
}

enum combat_state {
	INIT,
	WAIT,
	ATTACK,
	ATTACKANIM,
	INITMOVE,
	SELECTMOVETARGET,
	MOVE,
	MOVEEND,
	ENDTURN
}

enum facing {
	UP,
	DOWN,
	LEFT,
	RIGHT
}


@onready var camera = $Camera2D
var current_state = state.EXPLORE
var current_combat_state
var current_facing = facing.UP

@onready var animator = $AnimatedSprite2D
@onready var navigation_agent_2d: NavigationAgent2D = $NavigationAgent2D
@onready var max_health:int = 280 # fix this later
@onready var health:int = max_health

@onready var melee_zone: Area2D = $MeleeZone
@onready var healthBar: ProgressBar = $ProgressBar
const SPEED = 150
const JUMP_VELOCITY = -400.0

@onready var rng = RandomNumberGenerator.new()
var last_direction:Vector2
var cross_hairs: CrossHair
var attack_direction: facing
var previous_position

signal player_moved

func roll_to_hit(target: int) -> bool:
	if rng.randi_range(1, 20) >= target:
		print("Player hit")
		return true
	else:
		print("Player miss")
		return false

func deal_damage() -> int:
	return rng.randi_range(1, 10) + 8

func take_damage(damage: int) -> void:
	health = health - damage
	healthBar.value = self.health
	
func is_alive() -> bool:
	return health > 0
	
func _ready() -> void:
	animator.animation_looped.connect(_on_animated_sprite_2d_animation_looped)
	healthBar.max_value = self.max_health
	healthBar.value = self.health
	previous_position = Vector2(0,0)
	
func _physics_process(delta: float) -> void:
	if current_state == state.EXPLORE:
		var direction := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
		if direction:
			last_direction = direction
			velocity.x = direction.x * SPEED
			velocity.y = direction.y * SPEED
			
			
			if velocity.x > 0:
				animator.play("walk right")
			elif velocity.x < 0:
				animator.play("walk left")
			elif velocity.y < 0:
				animator.play("walk up")
			elif velocity.y > 0:
				animator.play("walk down")
				
		else:
			if last_direction.x < 0:
				animator.play("idle left")
			elif last_direction.x > 0:
				animator.play("idle right")
			elif last_direction.y < 0:
				animator.play("idle up")
			else:
				animator.play("idle")
			velocity.x = move_toward(velocity.x, 0, SPEED)
			velocity.y = move_toward(velocity.y, 0, SPEED)
		
	elif current_state == state.COMBAT:
		if current_combat_state == combat_state.INITMOVE:
			velocity.x = move_toward(velocity.x, 0, SPEED)
			velocity.y = move_toward(velocity.y, 0, SPEED)
			cross_hairs = load("res://src/scenes/monsters/crosshairs.tscn").instantiate()
			get_tree().current_scene.add_child(cross_hairs)
			cross_hairs.visible = true
			cross_hairs.aim_completed.connect(_on_aim_completed)
			current_combat_state = combat_state.SELECTMOVETARGET
			animator.play("idle")
		elif current_combat_state == combat_state.SELECTMOVETARGET:
			animator.play("idle")
		elif current_combat_state == combat_state.MOVE:
			if navigation_agent_2d.is_navigation_finished():
				current_combat_state = combat_state.MOVEEND
				return

			var direction = navigation_agent_2d.get_next_path_position() - global_position
			direction = direction.normalized()
			
			velocity = velocity.lerp(direction*SPEED, delta)
			
			if velocity.x > 0.2:
				animator.play("walk right")
				current_facing = facing.RIGHT
			elif velocity.x < -0.2:
				animator.play("walk left")
				current_facing = facing.LEFT
			elif velocity.y < -0.2:
				animator.play("walk up")
				current_facing = facing.UP
			elif velocity.y > 0.2:
				animator.play("walk down")
				current_facing = facing.DOWN
			#distance += SPEED*delta
		elif current_combat_state == combat_state.ATTACKANIM:
			if attack_direction == facing.RIGHT:
				animator.play("attack right")
			else:
				animator.play("attack left")
			
			
		elif current_combat_state == combat_state.ATTACK:
			print("attack state")
			animator.play("idle")
		elif current_combat_state == combat_state.ENDTURN:
			velocity.x = move_toward(velocity.x, 0, SPEED)
			velocity.y = move_toward(velocity.y, 0, SPEED)
			animator.play("idle")
		elif current_combat_state == combat_state.INIT:
			velocity.x = move_toward(velocity.x, 0, SPEED)
			velocity.y = move_toward(velocity.y, 0, SPEED)
			animator.play("idle")
		elif current_combat_state == combat_state.MOVEEND:
			velocity.x = move_toward(velocity.x, 0, SPEED)
			velocity.y = move_toward(velocity.y, 0, SPEED)
			#current_combat_state = combat_state.ATTACKANIM
			pass
		else:
			animator.play("idle")
	move_and_slide()
	if position != previous_position:
		emit_signal("player_moved", position)
		previous_position = position
	
	
func _input(event):
	if Input.is_action_just_pressed("aim"):
		print("M key pressed")
		var cross_hairs = load("res://Scenes/Monsters/crosshairs.tscn").instantiate()
		get_tree().current_scene.add_child(cross_hairs)
		cross_hairs.visible = true
		cross_hairs.aim_completed.connect(_on_aim_completed)
		print(cross_hairs.global_position)


func _on_bridge_crossing_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		print(self.collision_mask)
		print("on bridge")
		self.set_collision_mask_value(1, false)
		self.set_collision_mask_value(8, true)
		print(self.collision_mask)
		#$"../Layer Holder/TileMapLayer2".collision_layer = [1]



func _on_bridge_crossing_body_exited(body: Node2D) -> void:
	print("off bridge")
	self.set_collision_mask_value(1, true)
	self.set_collision_mask_value(8, false)
	#$"../Layer Holder/TileMapLayer2".collision_layer = 1
	pass # Replace with function body.
	
func _on_aim_completed(position: Vector2) -> void:
	navigation_agent_2d.target_position = position
	current_combat_state = combat_state.MOVE
	cross_hairs.queue_free()
	#current_state = state.COMBAT
	pass


func _on_animated_sprite_2d_animation_looped() -> void:
	if current_combat_state == combat_state.ATTACKANIM:
		animator.play("idle")
		current_combat_state = combat_state.ATTACK
	pass # Replace with function body.
