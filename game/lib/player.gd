extends CharacterBody3D

@onready var anim:AnimationPlayer = $visual/AnimationPlayer
@onready var camera_mount = $camera_mount
@onready var visual = $visual
@onready var healthbar = $HealthBar3D

@export var pivot:Node3D

signal interaction_detected(node:Node3D)
signal interaction_detected_end(node:Node3D)
signal hit(node:Node3D)

var SPEED = 5.0
var walking_speed = 5.0
var running_speed = 10.0
var running = false
const JUMP_VELOCITY = 4.5

const ANIM_WALK = "player/walking"
const ANIM_RUN = "player/running"
const ANIM_IDLE = "player/standing_idle"
const ANIM_ATTACK = "player/sword_slash"
const ANIM_JUMP = "player/jumping"
const ANIM_DEATH = "player/react_death_backward"

var mouse_captured:bool = false
var isAlreadyAtt:bool = false
var isAlreadyDead:bool = false

@export var mouse_sensitivity_horizontal:float = 0.08
@export var mouse_sensitivity_vertical:float = 0.04
@export var player_life:float = 100
@export var isDead:bool = false
@export var player_max_life:float = 100

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
var hit_area:Area3D
@export var attacking:bool = false

func capture_mouse() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	mouse_captured = true
func release_mouse() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	mouse_captured = false

func _ready():
	capture_mouse()
	anim.play(ANIM_IDLE)
	hit_area = $visual/paladin.get_node("RootNode/Skeleton3D/HandAttachement/sword/HitArea")
	hit_area.connect("body_entered", _on_hit_area_body_entered)
	healthbar.get_node("Label").visible = true
	healthbar.max_value = player_life
	healthbar.min_value = 0
	

func _input(event):
	if event is InputEventMouseMotion:
		rotate_y(deg_to_rad(-event.relative.x * mouse_sensitivity_horizontal))
		visual.rotate_y(deg_to_rad(event.relative.x * mouse_sensitivity_horizontal))
		camera_mount.rotate_x(deg_to_rad(-event.relative.y * mouse_sensitivity_vertical))

func _physics_process(delta):
	
	healthbar.value = player_life
	healthbar.get_node("Label").text = str(player_life)+ " / " + str(player_max_life)
	
	if player_life <= 0:
		attacking = true
		anim.play(ANIM_DEATH)
	if position.y < -10:
		attacking = true
		anim.play(ANIM_DEATH)
	
	if Input.is_action_pressed("player_run"):
		SPEED = running_speed
		running = true
	else:
		SPEED = walking_speed
		running = false
	
	if not attacking and Input.is_action_just_pressed("player_attack") and is_on_floor():
		anim.play(ANIM_ATTACK,0.2,1.3)
		attacking = true
	if (attacking):
		return

	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta

	# Handle jump.
	if Input.is_action_pressed("player_jump") and is_on_floor():
		anim.play(ANIM_JUMP)
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir = Input.get_vector("player_left", "player_right", "player_forward", "player_backward")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	if direction:
		if (!mouse_captured): capture_mouse()
		for index in range(get_slide_collision_count()):
			var collision = get_slide_collision(index)
			var collider = collision.get_collider()
			if (collider != null) and collider.is_in_group("stairs"):
				velocity.y = 1.5
				
		if running:
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
		
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)
	
	move_and_slide()

func _on_area_3d_body_entered(body):
	interaction_detected.emit(body)

func _on_area_3d_body_exited(body):
	interaction_detected_end.emit(body)

func _on_hit_area_body_entered(body):
	if (attacking):
		if (isAlreadyAtt == false and body.isDying == false):
			body.life_warrok -= 1
			body.isHitting = true
			isAlreadyAtt = true
			if (body.life_warrok < 1):
				body.isDying = true
			hit.emit(body.life_warrok)

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
