extends CharacterBody3D

@onready var anim:AnimationPlayer = $visual/AnimationPlayer
@onready var camera_mount = $camera_mount
@onready var camera = $camera_mount/Camera3D
@onready var camera2 = $head/Camera3D
@onready var visual = $visual
@onready var healthbar = $PlayerUI/HealthBar3D
@onready var xpbar = $PlayerUI/XPBar
@onready var collision = $CollisionShape3D
@onready var head = $head
@onready var head_camera = $head/Camera3D
@onready var gun_anim = $"head/Camera3D/Steampunk Rifle/AnimationPlayer"
@onready var gun_barrel = $"head/Camera3D/Steampunk Rifle/RayCast3D"
@onready var fond_sword = $PlayerUI/class/FondSword
@onready var fond_gun = $PlayerUI/class/FondGun
@onready var icon_gun = $PlayerUI/class/FondGun/IconGun
@onready var lock_gun = $PlayerUI/class/FondGun/Lock
@onready var player_inv = $PlayerUI/PlayerInv
@onready var portal_healthbar = $PlayerUI/HealthPortal
@onready var visual_paladin = $visual/paladin
@onready var button_wave = $PlayerUI/PlayerInv/FondInv/ButtonWave
@onready var label_wave = $PlayerUI/PlayerInv/FondInv/LabelWave
@onready var label_level = $PlayerUI/TextureRect/Label
@onready var label_wave_aff = $PlayerUI/LabelWaveAff
@onready var label_number_enemy = $PlayerUI/FondNumberEnemy/LabelNumberEnemy
@onready var icon_wall = $PlayerUI/class/FondWall/IconWall
@onready var lock_wall = $PlayerUI/class/FondWall/Lock
@onready var button_comp = $PlayerUI/PlayerInv/ContainerButtons
@onready var label_heart = $PlayerUI/PlayerInv/ContainerImages/BackHeart/LabelHeart
@onready var label_attack = $PlayerUI/PlayerInv/ContainerImages/BackAttack/LabelAttack
@onready var label_speed = $PlayerUI/PlayerInv/ContainerImages/BackSpeed/LabelSpeed

signal interaction_detected(node:Node3D)
signal interaction_detected_end(node:Node3D)
signal hit(node:Node3D)

var SPEED:float = 5.0
var walking_speed:float = 5.0
var running_speed:float = 10.0
var JUMP_VELOCITY:float = 4.5
var isRunning:bool = false
var isAlreadyAtt:bool = false
var isAlreadyDead:bool = false
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
var hit_area:Area3D
var t_bob:float = 0.0
var bullet = load("res://scenes/bullet.tscn")
var bullet_instance
var health_level = 1
var attack_level = 1
var speed_level = 1
var base_attack = 1
var number_comp_up = 0
var is_manette = false

const ANIM_WALK = "player/walking"
const ANIM_RUN = "player/running"
const ANIM_IDLE = "player/standing_idle"
const ANIM_ATTACK = "player/sword_slash"
const ANIM_JUMP = "player/jumping"
const ANIM_DEATH = "player/react_death_backward"

const SWORD = 1
const GUN = 2

const BOB_FREQ = 2.0
const BOB_AMP = 0.08

const BASE_FOV = 75.0
const FOV_CHANGE = 1.5

const max_camera_angle_up:float = deg_to_rad(60)
const max_camera_angle_down:float = -deg_to_rad(75)

@export var mouse_sensitivity_horizontal:float = 0.08
@export var mouse_sensitivity_vertical:float = 0.04
@export var player_life:float = 100
@export var player_xp:float = 0
@export var player_xp_max:float = 5
@export var isDead:bool = false
@export var player_max_life:float = 100
@export var attacking:bool = false
@export var player_class = SWORD
@export var player_level = 1
@export var player_wave_level = 0
@export var number_warrok_dead = 0
@export var wave_finish = true
@export var mouse_captured:bool = false
@export var portal_load_life:float = 1000
@export var wave_load_number:float = 5
@export var wave_load_last_number:float = 5

func _ready():
	capture_mouse()
	visual.visible = true
	anim.play(ANIM_IDLE)
	hit_area = visual_paladin.get_node("RootNode/Skeleton3D/HandAttachement/sword/HitArea")
	hit_area.connect("body_entered", _on_hit_area_body_entered)
	healthbar.get_node("Label").visible = true
	healthbar.max_value = player_max_life
	healthbar.min_value = 0
	xpbar.max_value = player_xp_max
	xpbar.min_value = 0
	fond_sword.texture = load("res://models/menu/kenney_ui-pack-rpg-expansion/PNG/panel_brown.png")
	player_inv.visible = false
	portal_healthbar.max_value = 1000

func _input(event):
	if event is InputEventMouseMotion:
		if(mouse_captured):
			if player_class == SWORD:
				rotate_y(deg_to_rad(-event.relative.x * mouse_sensitivity_horizontal))
				visual.rotate_y(deg_to_rad(event.relative.x * mouse_sensitivity_horizontal))
				camera_mount.rotate_x(deg_to_rad(-event.relative.y * mouse_sensitivity_vertical))
				camera_mount.rotation.x = clamp(camera_mount.rotation.x, deg_to_rad(-40), deg_to_rad(50))
				camera_mount.position.y = 1.3
			if player_class == GUN:
				rotation.y = 0
				head.rotate_y(-event.relative.x * (mouse_sensitivity_horizontal/50))
				head_camera.rotate_x(-event.relative.y * (mouse_sensitivity_vertical/50))
				head_camera.rotation.x = clamp(head_camera.rotation.x, deg_to_rad(-40), deg_to_rad(60))
		is_manette = false

func _physics_process(delta):
	
	if wave_finish == true:
		button_wave.disabled = false
	else:
		button_wave.disabled = true
	
	label_wave.text = "Vague N°" + str(player_wave_level)
	label_level.text = "Lvl. " + str(player_level)
	portal_healthbar.value = GameState.portal.portal_life
	
	var input_dir = Input.get_vector("player_left", "player_right", "player_forward", "player_backward")
	
	if Input.is_action_just_pressed("player_inv"):
		player_inv.visible = not player_inv.visible
		if player_inv.visible == true :
			label_heart.text = "Lvl. " + str(health_level)
			label_attack.text = "Lvl. " + str(attack_level)
			label_speed.text = "Lvl. " + str(speed_level)
			button_wave.grab_focus()
			release_mouse()
			anim.play(ANIM_IDLE)
		else:
			capture_mouse()
			anim.play(ANIM_IDLE)
	
	if number_comp_up > 0:
		button_comp.visible = true
		$PlayerUI/PlayerInv/LabelDispo.visible = true
	else:
		button_comp.visible = false
		$PlayerUI/PlayerInv/LabelDispo.visible = false
	
	if Input.is_action_just_pressed("player_change_class"):
		if player_class == SWORD and player_level >= 5 :
			fond_gun.texture = load("res://models/menu/kenney_ui-pack-rpg-expansion/PNG/panel_brown.png")
			fond_sword.texture = load("res://models/menu/kenney_ui-pack-rpg-expansion/PNG/panel_beige.png")
			player_class = GUN
			rotation.y = 0
			head.rotation = camera_mount.rotation
		else:
			fond_sword.texture = load("res://models/menu/kenney_ui-pack-rpg-expansion/PNG/panel_brown.png")
			fond_gun.texture = load("res://models/menu/kenney_ui-pack-rpg-expansion/PNG/panel_beige.png")
			player_class = SWORD
	
	healthbar.value = player_life
	healthbar.max_value = player_max_life
	healthbar.get_node("Label").text = str(player_life)+ " / " + str(player_max_life)
	xpbar.value = player_xp
	
	if player_xp == player_xp_max:
		xpbar.value = 0
		player_xp = 0
		player_level += 1
		number_comp_up += 1
		
	if player_level >= 5:
		icon_gun.visible = true
		lock_gun.visible = false
	
	if player_level >= 8:
		icon_wall.visible = true
		lock_wall.visible = false
	
	if player_life <= 0:
		collision.disabled = true
		attacking = true
		anim.play(ANIM_DEATH)

	if position.y < -10:
		attacking = true
		anim.play(ANIM_DEATH)
	
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta
	
	if Input.is_action_pressed("player_run"):
		SPEED = running_speed
		isRunning = true
	else:
		SPEED = walking_speed
		isRunning = false
	
	if player_class == SWORD and mouse_captured:
		$camera_mount/Camera3D.set_current(not $camera_mount/Camera3D.current)
		$head/Camera3D.clear_current(true)
		visual.visible = true
		head.visible = false

		if mouse_captured:
			var joypad_dir:Vector2 = Input.get_vector("player_look_left", "player_look_right", "player_look_up", "player_look_down")
			if joypad_dir.length() > 0:
				var look_dir = joypad_dir * delta
				rotate_y(-look_dir.x * 2.0)
				camera.rotate_x(-look_dir.x)
				camera.rotation.x = clamp(camera_mount.rotation.x - look_dir.x, max_camera_angle_down, max_camera_angle_up)
				camera_mount.position.y = 1.75
				
		if not attacking and Input.is_action_just_pressed("player_attack") and is_on_floor() and mouse_captured:
			anim.play(ANIM_ATTACK,0.2,1.3)
			attacking = true
		if (attacking):
			return

		# Handle jump.
		if Input.is_action_pressed("player_jump") and is_on_floor() and mouse_captured:
			velocity.y = JUMP_VELOCITY

		var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
		
		#if is_on_floor():
		if direction and mouse_captured:
			if (!mouse_captured): capture_mouse()
			for index in range(get_slide_collision_count()):
				var slide_collision = get_slide_collision(index)
				var collider = slide_collision.get_collider()
				if (collider != null) and collider.is_in_group("stairs"):
					velocity.y = 1.5

			if isRunning:
				if anim.current_animation != ANIM_RUN:
					anim.play(ANIM_RUN,0.2)
			else:
				if anim.current_animation != ANIM_WALK:
					anim.play(ANIM_WALK,0.2)
			
			if !attacking:
				visual.look_at(position + direction)
			
			velocity.x = direction.x * SPEED
			velocity.z = direction.z * SPEED
		else:
			if anim.current_animation != ANIM_IDLE:
				anim.play(ANIM_IDLE,0.5)
			velocity.x = lerp(velocity.x, direction.x * SPEED, delta * 7.0)
			velocity.z = lerp(velocity.z, direction.z * SPEED, delta * 7.0)
		#else:
			#velocity.x = lerp(velocity.x, direction.x * SPEED, delta * 2.0)
			#velocity.z = lerp(velocity.z, direction.z * SPEED, delta * 2.0)
		move_and_slide()
	
	if player_class == GUN and mouse_captured:
		$head/Camera3D.set_current(not $head/Camera3D.current)
		$camera_mount/Camera3D.clear_current(true)
		visual.visible = false
		head.visible = true
		var direction = null
		
		if mouse_captured:
			var joypad_dir:Vector2 = Input.get_vector("player_look_left", "player_look_right", "player_look_up", "player_look_down")
			if joypad_dir.length() > 0:
				var look_dir = joypad_dir * delta
				rotate_y(-look_dir.x * 2.0)
				#head.rotate_y(-look_dir.x * 4.0)
				head.rotate_x(-look_dir.y)
				#head.rotation.x = clamp(head.rotation.x - look_dir.x, max_camera_angle_down, max_camera_angle_up)
				is_manette = true
		
		if is_manette == true:
			direction = (transform.basis * Vector3(input_dir.x,0,input_dir.y)).normalized()
		else:
			direction = (head.transform.basis * Vector3(input_dir.x,0,input_dir.y)).normalized()
		
		if Input.is_action_pressed("player_jump") and is_on_floor():
			velocity.y = JUMP_VELOCITY
		
		if is_on_floor():
			if direction:
				velocity.x = direction.x * SPEED
				velocity.z = direction.z * SPEED
			else:
				velocity.x = lerp(velocity.x, direction.x * SPEED, delta * 7.0)
				velocity.z = lerp(velocity.z, direction.z * SPEED, delta * 7.0)
		else:
			velocity.x = lerp(velocity.x, direction.x * SPEED, delta * 3.0)
			velocity.z = lerp(velocity.z, direction.z * SPEED, delta * 3.0)
		
		t_bob += delta * velocity.length() * float(is_on_floor())
		head_camera.transform.origin = _headbob(t_bob)
		
		var velocity_clamped = clamp(velocity.length(),0.5,running_speed * 2)
		var target_fov = BASE_FOV + FOV_CHANGE * velocity_clamped
		head_camera.fov = lerp(head_camera.fov, target_fov, delta * 8.0)
		
		if Input.is_action_pressed("player_shoot"):
			if !gun_anim.is_playing():
				gun_anim.play("Shoot")
				bullet_instance = bullet.instantiate()
				bullet_instance.position = gun_barrel.global_position
				bullet_instance.transform.basis = gun_barrel.global_transform.basis
				get_parent().add_child(bullet_instance)
				
		move_and_slide()

func _headbob(time) -> Vector3:
	var pos = Vector3.ZERO
	pos.y = sin(time * BOB_FREQ) * BOB_AMP
	pos.x = sin(time * BOB_FREQ/2) * BOB_AMP
	return pos
	
func capture_mouse() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	mouse_captured = true

func release_mouse() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	mouse_captured = false

func _on_area_3d_body_entered(body):
	interaction_detected.emit(body)

func _on_area_3d_body_exited(body):
	interaction_detected_end.emit(body)

func _on_hit_area_body_entered(body):
	if (attacking):
		if (isAlreadyAtt == false and body.isDying == false):
			body.isHit(base_attack)
			isAlreadyAtt = true

func _on_animation_player_animation_finished(anim_name):
	if(anim_name == ANIM_ATTACK):
		attacking = false
		if Input.is_action_pressed("player_forward") :
			anim.play(ANIM_WALK,0.5)
		else:
			anim.play(ANIM_IDLE,0.5)
	isAlreadyAtt = false
	if anim_name == ANIM_DEATH:
		isDead = true

func _on_button_wave_pressed():
	_on_button_quit_inv_pressed()
	player_wave_level += 1

func _on_button_quit_inv_pressed():
	capture_mouse()
	anim.play(ANIM_IDLE)
	player_inv.visible = false

func _on_timer_regen_timeout():
	if player_life < player_max_life:
		player_life += 1

func _on_button_heart_pressed():
	if number_comp_up > 0:
		health_level += 1
		player_max_life += 50
		healthbar.max_value = player_max_life
		label_heart.text = "Lvl. " + str(health_level)
		number_comp_up -= 1
		button_wave.grab_focus()

func _on_button_attack_pressed():
	if number_comp_up > 0:
		attack_level += 1
		base_attack += 0.2
		label_attack.text = "Lvl. " + str(attack_level)
		number_comp_up -= 1
		button_wave.grab_focus()

func _on_button_speed_pressed():
	if number_comp_up > 0:
		speed_level += 1
		running_speed += 0.5
		walking_speed += 0.25
		label_speed.text = "Lvl. " + str(speed_level)
		number_comp_up -= 1
		button_wave.grab_focus()

func _on_button_heart_focus_entered():
	if button_comp.visible == false:
		button_wave.grab_focus()
