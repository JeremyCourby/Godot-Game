class_name Level extends Node3D

@onready var anim_light = $DirectionalLight3D/AnimationPlayer
@onready var anim_sky_color = $WorldEnvironment/AnimationPlayer

@export var key:String

var wave_level = 0
var enemy_number = 5

# Called when the node enters the scene tree for the first time.
func _ready():
	anim_light.play("SunRotate",0,0.005)
	anim_sky_color.play("SkyColor",0,0.005)
	wave_level = GameState.player.player_wave_level

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if wave_level < GameState.player.player_wave_level:
		wave_level = GameState.player.player_wave_level
		wave(wave_level)

func wave(wave_level):
	
	var warrokscene = load("res://scenes/warrok.tscn")

	var enemy_mult = 1.1
	if(wave_level > 1):
		enemy_number = enemy_number * enemy_mult
	
	for i in range(0,enemy_number):
		await get_tree().create_timer(randf_range(0,5)).timeout
		var warrok = warrokscene.instantiate()
		$Path3D/PathFollow3D.set_progress_ratio(randf_range(0,1))
		$Path3D/PathFollow3D.position.y = $Path3D/PathFollow3D.position.y + 2
		warrok.position = $Path3D/PathFollow3D.position
		add_child(warrok)

