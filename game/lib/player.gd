extends CharacterBody3D

@onready var anim:AnimationPlayer = $visual/AnimationPlayer
@onready var camera_mount = $camera_mount
@onready var visual = $visual
@onready var healthbar = $HealthBar3D
@onready var collision = $CollisionShape3D
@onready var head = $head
@onready var head_camera = $head/Camera3D
@onready var gun_anim = $"head/Camera3D/Steampunk Rifle/AnimationPlayer"
@onready var gun_barrel = $"head/Camera3D/Steampunk Rifle/RayCast3D"

signal interaction_detected(node:Node3D)
signal interaction_detected_end(node:Node3D)
signal hit(node:Node3D)

var SPEED:float = 5.0
var walking_speed:float = 5.0
var running_speed:float = 10.0
var JUMP_VELOCITY:float = 4.5
var mouse_captured:bool = false
var isRunning:bool = false
var isAlreadyAtt:bool = false
var isAlreadyDead:bool = false
var isJumping:bool = false
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
var hit_area:Area3D
var t_bob:float = 0.0
var bullet = load("res://scenes/bullet.tscn")
var bullet_instance

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

@export var mouse_sensitivity_horizontal:float = 0.08
@export var mouse_sensitivity_vertical:float = 0.04
@export var player_life:float = 100
@export var isDead:bool = false
@export var player_max_life:float = 100
@export var attacking:bool = false
@export var player_class = SWORD

func _ready():
	capture_mouse()
	visual.visible = true
	anim.play(ANIM_IDLE)
	hit_area = $visual/paladin.get_node("RootNode/Skeleton3D/HandAttachement/sword/HitArea")
	hit_area.connect("body_entered", _on_hit_area_body_entered)
	healthbar.get_node("Label").visible = true
	healthbar.max_value = player_life
	healthbar.min_value = 0

func _input(event):
	if event is InputEventMouseMotion:
		if player_class == SWORD:
			rotate_y(deg_to_rad(-event.relative.x * mouse_sensitivity_horizontal))
			visual.rotate_y(deg_to_rad(event.relative.x * mouse_sensitivity_horizontal))
			camera_mount.rotate_x(deg_to_rad(-event.relative.y * mouse_sensitivity_vertical))
			camera_mount.rotation.x = clamp(camera_mount.rotation.x, deg_to_rad(-40), deg_to_rad(50))
		if player_class == GUN:
			head.rotate_y(-event.relative.x * (mouse_sensitivity_horizontal/50))
			head_camera.rotate_x(-event.relative.y * (mouse_sensitivity_vertical/50))
			head_camera.rotation.x = clamp(head_camera.rotation.x, deg_to_rad(-40), deg_to_rad(60))

func _physics_process(delta):
	
	var input_dir = Input.get_vector("player_left", "player_right", "player_forward", "player_backward")
	
	if Input.is_action_pressed("player_change_class"):
		if player_class == SWORD:
			player_class = GUN
			return
		if player_class == GUN:
			player_class = SWORD
			return
	
	healthbar.value = player_life
	healthbar.get_node("Label").text = str(player_life)+ " / " + str(player_max_life)
	
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
	
	if player_class == SWORD:
		$camera_mount/Camera3D.set_current(not $camera_mount/Camera3D.current)
		$head/Camera3D.clear_current(true)
		visual.visible = true
		head.visible = false
		
		if not attacking and Input.is_action_just_pressed("player_attack") and is_on_floor():
			anim.play(ANIM_ATTACK,0.2,1.3)
			attacking = true
		if (attacking):
			return

		# Handle jump.
		if Input.is_action_pressed("player_jump") and is_on_floor():
			isJumping = true
			anim.play(ANIM_JUMP,0.2,1.5)
			velocity.y = JUMP_VELOCITY

		var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
		
		if is_on_floor():
			if direction:
				if (!mouse_captured): capture_mouse()
				for index in range(get_slide_collision_count()):
					var collision = get_slide_collision(index)
					var collider = collision.get_collider()
					if (collider != null) and collider.is_in_group("stairs"):
						velocity.y = 1.5
				if not isJumping:
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
		else:
			velocity.x = lerp(velocity.x, direction.x * SPEED, delta * 2.0)
			velocity.z = lerp(velocity.z, direction.z * SPEED, delta * 2.0)
		move_and_slide()
	
	if player_class == GUN:
		$head/Camera3D.set_current(not $head/Camera3D.current)
		$camera_mount/Camera3D.clear_current(true)
		visual.visible = false
		head.visible = true
		
		if Input.is_action_pressed("player_jump") and is_on_floor():
			velocity.y = JUMP_VELOCITY

		var direction = (head.transform.basis * Vector3(input_dir.x,0,input_dir.y)).normalized()
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
			body.hit(1)
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
	if anim_name == ANIM_JUMP:
		isJumping = false
