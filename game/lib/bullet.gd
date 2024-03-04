extends Node3D

@onready var mesh = $MeshInstance3D
@onready var ray = $RayCast3D
@onready var particles = $GPUParticles3D

const SPEED = 40.0

func _ready():
	pass

func _process(delta):
	position += transform.basis * Vector3(0,0,-SPEED) * delta
	if ray.is_colliding():
		if ray.get_collider().is_in_group("enemy"):
			ray.get_collider().isHit(0.5)
		mesh.visible = false
		particles.emitting = true
		await get_tree().create_timer(1.0).timeout
		queue_free()

func _on_timer_timeout():
	queue_free()
