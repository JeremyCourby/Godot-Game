class_name Level extends Node3D

@export var key:String
@onready var anim_light = $DirectionalLight3D/AnimationPlayer
@onready var anim_sky_color = $WorldEnvironment/AnimationPlayer

# Called when the node enters the scene tree for the first time.
func _ready():
	anim_light.play("SunRotate",0,0.005)
	anim_sky_color.play("SkyColor",0,0.005)
	var warrokscene = load("res://scenes/warrok.tscn")
	
	for i in range(0,5):
		var warrok = warrokscene.instantiate()
		warrok.position = Vector3(GameState.player.position.x + randf_range(-10,10),GameState.player.position.y + 1,GameState.player.position.y + randf_range(-10,10))
		add_child(warrok)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

