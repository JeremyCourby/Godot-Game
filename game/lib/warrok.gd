class_name Warrok extends CharacterBody3D

@onready var anim:AnimationPlayer = $AnimationPlayer
@onready var healthbar = $SubViewport/HealthBar3D
@onready var nav_agent:NavigationAgent3D = $NavigationAgent3D

signal interaction_detected(node:Node3D)

var isAttacking:bool = false
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
var focus:String = "portal"

const SPEED = 2.0
const SPEED_RUN = 6.0
const ANIM_IDLE = "warrok/standing_idle"
const ANIM_RUN = "warrok/running"
const ANIM_WALK = "warrok/walking"
const ANIM_HIT = "warrok/reaction"
const ANIM_DEATH = "warrok/react_death_backward"
const ANIM_ATTACK = "warrok/bash"

@export var life_warrok:float = 3.0
@export var defense_warrok:float = 1.0
@export var isDying:bool = false
@export var isHitting:bool = false
@export var portal_position:Vector3 = GameState.player.position

func _ready():
	anim.play(ANIM_IDLE)
	healthbar.max_value = life_warrok
	healthbar.min_value = 0

func _physics_process(delta):
	
	if position.y < -10:
		queue_free()
		 
	if not is_on_floor():
		velocity.y -= gravity * delta
	
	healthbar.value = life_warrok
	
	if position.distance_to(GameState.player.position) < 10 :
		focus = "player"
	
	if position.distance_to(GameState.player.position) > 15 :
		focus = "portal"
	
	for index in range(get_slide_collision_count()):
			var collision = get_slide_collision(index)
			var collider = collision.get_collider()
			if (collider != null) and collider.is_in_group("walls") and focus == "portal" and isDying == false:
				hit(1,true,collider)
	
	if anim.current_animation != ANIM_HIT and anim.current_animation != ANIM_DEATH and isAttacking == false:
		if focus == "portal":
			nav_agent.target_position = portal_position
		if focus == "player":
			nav_agent.target_position = GameState.player.position
		var target = nav_agent.get_next_path_position()
		if (target != position):
			anim.play(ANIM_RUN,0.5)
			var direction = position.direction_to(target)
			velocity = direction * SPEED_RUN
			look_at(Vector3(target.x, position.y, target.z), Vector3.UP)
			if focus == "player":
				if nav_agent.get_next_path_position() == nav_agent.get_final_position():
					look_at(Vector3(GameState.player.position.x, position.y, GameState.player.position.z), Vector3.UP)
			move_and_slide()
	
	
		
	if anim.current_animation != ANIM_HIT and anim.current_animation != ANIM_DEATH:
		var dist_w_p = Vector3(0,0,0)
		if focus == "portal":
			dist_w_p = position.distance_to(portal_position)
			if dist_w_p < 5:
				hit(10)
		if focus == "player":
			dist_w_p = position.distance_to(GameState.player.position)
			if dist_w_p < 1.65:
				hit(10)
			
	if isHitting:
		anim.play(ANIM_HIT,0.2,1.5)
		isHitting = false
		
	if isDying:
		healthbar.visible = false
		$CollisionShape3D.disabled = true
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
	if(anim_name == ANIM_HIT):
		isAttacking = false
		isHitting = false

func isHit(damage):
	focus = "player"
	isHitting = true
	life_warrok -= damage
	if (life_warrok <= 0) and isDying == false:
		isDying = true
		GameState.player.player_xp += 1
		GameState.player.number_warrok_dead += 1

func hit(damage, isWalls = false, collider = null):
	if isAttacking == false:
		anim.play(ANIM_ATTACK)
		if isWalls == false:
			if focus == "player":
				GameState.player.player_life -= damage
			if focus == "portal":
				GameState.portal.portal_life -= damage
		else:
			collider.hit(damage)
		isAttacking = true
		await get_tree().create_timer(1.5).timeout
		isAttacking = false
