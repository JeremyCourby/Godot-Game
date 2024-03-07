class_name wall extends Node3D

@onready var healthbar = $SubViewport/HealthBar3D
@export var wall_life = 10

func _ready():
	healthbar.max_value = wall_life
	healthbar.visible = false

func _process(_delta):
	healthbar.value = wall_life
	if wall_life < 10:
		healthbar.visible = true

func hit(damage):
	wall_life -= damage
	if wall_life <= 0:
		queue_free()
