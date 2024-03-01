extends Node3D

@onready var camera:Camera3D = $Camera

const max_camera_angle_up:float = deg_to_rad(60)
const max_camera_angle_down:float = -deg_to_rad (75)
const mouse_sensitivity:float = 0.002

func _input(event) :
	if event is InputEventMouseMotion:
		rotate_y(-event.relative.x * mouse_sensitivity)
		camera.rotate_x(-event.relative.y * (mouse_sensitivity / 10))
		camera.rotation.x = clampf(camera.rotation.x, max_camera_angle_down, max_camera_angle_up)
