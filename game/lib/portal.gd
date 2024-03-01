extends Node3D

@onready var anim:AnimationPlayer = $AnimationPlayer
const ANIM = "Take 001"

func _physics_process(delta):
	anim.play(ANIM)
