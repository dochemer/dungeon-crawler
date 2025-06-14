extends CharacterBody2D

class_name Monster

@export var resource: Resource

@export_group("Statistics")
@onready var max_health = resource.max_health
@export_group("")

#@export var player: CharacterBody2D
@export var zone: Area2D

@onready var health:int = max_health

@onready var monster: Monster = $"."
@onready var healthBar: ProgressBar = $ProgressBar
@onready var navigation_agent_2d: NavigationAgent2D = $NavigationAgent2D

@onready var animator: AnimatedSprite2D = $AnimatedSprite2D
@onready var melee_zone: Area2D = $MeleeZone

const speed = 100
enum state {
	IDLE,
	CHASING,
	COMBAT,
	DYING,
	DEAD
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

var distance = 0
var current_state;
var current_combat_state;
var attack_direction: facing = facing.UP
@onready var rng = RandomNumberGenerator.new()

func roll_to_hit(target: int) -> bool:
	if rng.randi_range(1, 20) >= target:
		print("Monster hit")
		return true
	else:
		print("Monster miss")
		return false

func deal_damage() -> int:
	return rng.randi_range(1, 5) + 2
	
func take_damage(damage: int) -> void:
	self.health = self.health - damage
	healthBar.value = self.health
	if self.health <= 0:
		current_state = state.DYING
		
	
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	animator.sprite_frames = resource.spriteFrames
	animator.animation = "idle"
	animator.animation_looped.connect(_on_animated_sprite_2d_animation_looped)
	#zone.body_entered.connect(_on_zone_body_entered)
	#zone.body_exited.connect(_on_zone_body_exited)
	current_state = state.IDLE
	healthBar.max_value = self.max_health
	healthBar.value = self.health
	#scale.x = 1
	#scale.y = 1
	
func _physics_process(delta: float) -> void:
	#animator.play("idle")
	#if is_instance_valid(player):
	var direction = Vector2.ZERO
	match current_state:
		state.IDLE:
			get_node("CollisionShape2D").disabled = false
			velocity = Vector2(0, 0)
			animator.play("idle")
		state.CHASING:
			direction = navigation_agent_2d.get_next_path_position() - global_position
			direction = direction.normalized()
			
			velocity = velocity.lerp(direction*speed, delta)
			distance += speed*delta
			#var direction = (player.global_position - self.global_position).normalized()
			#velocity = direction * speed * delta
			if direction.x > 0.2:
				animator.play("move right")
			elif direction.x < -0.2:
				animator.play("move left")
			elif direction.y < -0.2:
				animator.play("move up")
			elif direction.y > 0.2:
				animator.play("move down")
			else:
				animator.play("idle")
				
			if distance > 250:
				current_state = state.IDLE
				
		state.DYING:
			animator.play("death")
			
		state.COMBAT:
			get_node("CollisionShape2D").disabled = true
			if current_combat_state == combat_state.ATTACKANIM:
				if attack_direction == facing.UP:
					animator.play("attack up")
				elif attack_direction == facing.RIGHT:
					animator.play("attack right")
				elif attack_direction == facing.LEFT:
					animator.play("attack left")
				else:
					animator.play("attack down")
				
			elif current_combat_state == combat_state.MOVE:
				direction = navigation_agent_2d.get_next_path_position() - global_position
				direction = direction.normalized()
				
				velocity = velocity.lerp(direction*speed, delta)
				distance += speed*delta
				#var direction = (player.global_position - self.global_position).normalized()
				#velocity = direction * speed * delta
				if direction.x > 0.2:
					animator.play("move right")
				elif direction.x < -0.2:
					animator.play("move left")
				elif direction.y < -0.2:
					animator.play("move up")
				elif direction.y > 0.2:
					animator.play("move down")
				else:
					animator.play("idle")
					
				if distance > 250:
					current_combat_state = combat_state.MOVEEND
					velocity.x = move_toward(velocity.x, 0, speed)
					velocity.y = move_toward(velocity.y, 0, speed)
					animator.play("idle")
			elif current_combat_state == combat_state.MOVEEND:
				pass
			else:
				animator.play("idle")
	move_and_slide()
	


func is_alive() -> bool:
	return health > 0
	
func _on_zone_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		var monsters = zone.get_overlapping_bodies().filter(func(node): return node.is_in_group("Monster"))
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

func _on_zone_body_exited(body: Node2D) -> void:
	if body.is_in_group("Player"):
		current_state = state.IDLE
		
func _on_player_detection_body_entered(body: Node2D) -> void:
	pass
	#if body.is_in_group("Player"):
	#	print(self.name, "chasing")
	#	current_state = state.CHASING
		



func _on_player_detection_body_exited(body: Node2D) -> void:
	pass
	#if body.is_in_group("Player"):
	#	current_state = state.IDLE
	
func _on_animated_sprite_2d_animation_looped() -> void:
	if current_state == state.DYING:
		self.hide()
		current_state = state.DEAD
		get_node("CollisionShape2D").disabled = true 
		#self.queue_free()
	if current_combat_state == combat_state.ATTACKANIM:
		animator.play("idle")
		current_combat_state = combat_state.ATTACK
