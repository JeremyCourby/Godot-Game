class_name Portal extends Node3D

@onready var anim:AnimationPlayer = $AnimationPlayer
@onready var healthbar = $SubViewport/HealthBar3D
const ANIM = "Take 001"

@export var portal_life:float = 1000

func _ready():
	GameState.portal = self
	healthbar.max_value = portal_life
	healthbar.min_value = 0

func _physics_process(_delta):
	anim.play(ANIM)
	healthbar.value = portal_life
