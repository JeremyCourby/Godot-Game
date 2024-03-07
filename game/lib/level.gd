class_name Level extends Node3D

@onready var anim_light = $DirectionalLight3D/AnimationPlayer
@onready var anim_sky_color = $WorldEnvironment/AnimationPlayer

@export var key:String

var wave_level = 0
var enemy_number = 5
var enemy_wave_number = 0
var actual_enemy_wave_number = enemy_wave_number

var wallscene
var walls

# Called when the node enters the scene tree for the first time.
func _ready():
	anim_light.play("SunRotate",0,0.005)
	anim_sky_color.play("SkyColor",0,0.005)
	wave_level = GameState.player.player_wave_level

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if wave_level < GameState.player.player_wave_level:
		wave_level = GameState.player.player_wave_level
		wave(wave_level)
	
	GameState.player.label_number_enemy.text = str(floor(GameState.player.number_warrok_dead)) + " / " + str(floor(actual_enemy_wave_number))
	if floor(enemy_wave_number) == floor(GameState.player.number_warrok_dead) and GameState.player.wave_finish == false:
		aff_lib_wave("Vague n°" + str(wave_level) + " terminée")
		GameState.player.wave_finish = true
		GameState.player.number_warrok_dead = 0
		actual_enemy_wave_number = 0
	
func wave(wave_number):
	
	var warrokscene = load("res://scenes/warrok.tscn")
	
	var enemy_mult = 1.1
	if(wave_number > 1):
		enemy_number = enemy_number * enemy_mult
	
	enemy_wave_number = enemy_number
	
	aff_lib_wave("Lancement de la vague n°" + str(wave_number))
	
	GameState.player.wave_finish = false
	
	actual_enemy_wave_number = enemy_wave_number
	
	if GameState.player.player_level >= 8:
		remove_wall()
		spawn_wall()
		
	for i in range(0,floor(enemy_number)):
		await get_tree().create_timer(randf_range(0.5,4)).timeout
		var warrok = warrokscene.instantiate()
		warrok.portal_position = $NavigationRegion3D/portal.position
		$Path3D/PathFollow3D.set_progress_ratio(randf_range(0,1))
		$Path3D/PathFollow3D.position.y = $Path3D/PathFollow3D.position.y + 2
		warrok.position = $Path3D/PathFollow3D.position
		add_child(warrok)

func spawn_wall():
	load_wall()
	add_child(walls)

func remove_wall():
	remove_child(walls)
	wallscene = null
	walls = null

func load_wall():
	wallscene = load("res://scenes/walls.tscn")
	walls = wallscene.instantiate()

func aff_lib_wave(str_wave):
	GameState.player.label_wave_aff.visible = true
	GameState.player.label_wave_aff.text = str_wave
	await get_tree().create_timer(3).timeout
	GameState.player.label_wave_aff.visible = false
