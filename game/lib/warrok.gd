class_name Warrok extends CharacterBody3D

@onready var anim:AnimationPlayer = $AnimationPlayer
@onready var healthbar = $SubViewport/HealthBar3D

@export var life_warrok:float = 3.0
@export var defense_warrok:float = 1.0

const SPEED = 2.0
const SPEED_RUN = 6.0
const ANIM_IDLE = "warrok/standing_idle"
const ANIM_RUN = "warrok/running"
const ANIM_WALK = "warrok/walking"
const ANIM_HIT = "warrok/reaction"
const ANIM_DEATH = "warrok/react_death_backward"
const ANIM_ATTACK = "warrok/bash"

@export var isDying:bool = false
@export var isHitting:bool = false

var isAttacking:bool = false

signal interaction_detected(node:Node3D)

var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
@onready var nav_agent:NavigationAgent3D = $NavigationAgent3D

func _ready():
	make_path()
	anim.play(ANIM_IDLE)
	healthbar.max_value = life_warrok
	healthbar.min_value = 0

func make_path():
	nav_agent.target_position = GameState.player.global_position
	
func _physics_process(delta):
	make_path()
	if position.y < -10:
		queue_free()
		 
	if not is_on_floor():
		velocity.y -= gravity * delta

	if anim.current_animation != ANIM_HIT and anim.current_animation != ANIM_DEATH:
		var dist_w_p = position.distance_to(GameState.player.position)
		if dist_w_p < 1.25:
			isAttacking = true
			anim.play(ANIM_ATTACK)
		
	healthbar.value = life_warrok
	
	if anim.current_animation != ANIM_HIT and anim.current_animation != ANIM_DEATH and isAttacking == false:
		look_at(Vector3(GameState.player.global_position.x,global_position.y,GameState.player.global_position.z), Vector3.UP)
		var direction = global_position.direction_to(GameState.player.global_position)
		velocity = direction * SPEED_RUN
		anim.play(ANIM_RUN,0.5)
		move_and_slide()
		
		#var target = nav_agent.get_next_path_position()
		#if (target != position):
			#anim.play(ANIM_RUN,0.5)
			#var direction = global_position.direction_to(target)
			#velocity = direction * SPEED_RUN
			#look_at(Vector3(target.x, position.y, target.z), Vector3.UP)
		#move_and_slide()
		
	if isHitting:
		anim.play(ANIM_HIT,0,2.2)
		isHitting = false
		
	if isDying:
		healthbar.visible = false
		var rng = RandomNumberGenerator.new()
		var my_random_number = rng.randf_range(0,1)
		anim.play(ANIM_DEATH)
	
	var distance_health = position.distance_to(GameState.player.position)
	if distance_health > 10:
		healthbar.visible = false
	else:
		if not isDying:
			healthbar.visible = true

func _on_animation_player_animation_finished(anim_name):
	if anim_name == ANIM_DEATH:
		queue_free()
	if(anim_name == ANIM_ATTACK):
		GameState.player.player_life -= 10
		isAttacking = false
