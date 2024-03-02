extends Node3D

@onready var label_infos:Label = $HUD/Label
@onready var menu:Control = $Menu
@onready var hud:Control = $HUD
@onready var button_quit:Button = $Menu/ButtonQuit
@onready var player:CharacterBody3D = $Player

var save:SaveManager = SaveManager.new()
var current_level_change = null

# Called when the node enters the scene tree for the first time.
func _ready():
	GameState.player = $Player
	_enter_level("default", "level_1")
	save.load_game()
	_enter_level("default", GameState.current_level_key, GameState.player.position == Vector3.ZERO)
	label_infos.visible = false
	menu.visible = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if GameState.player.isDead == true:
		for spawnpoint:SpawnPoint in GameState.current_level.find_children("", "SpawnPoint"):
			if (spawnpoint.key == "default"):
				GameState.player.position = spawnpoint.position
				GameState.player.rotation = spawnpoint.rotation
				GameState.player.isDead = false
				GameState.player.player_life = GameState.player.player_max_life
				GameState.player.attacking = false
				GameState.player.collision.disabled = false

func _enter_level(from:String, to:String, use_spawn_point:bool = true):
	if (GameState.current_level != null): 
		GameState.current_level.call_deferred("queue_free")
	GameState.current_level = load("res://levels/" + to + ".tscn").instantiate()
	GameState.current_level_key = to
	GameState.current_level.process_mode = PROCESS_MODE_PAUSABLE
	add_child(GameState.current_level)
	if (use_spawn_point) :
		for spawnpoint:SpawnPoint in GameState.current_level.find_children("", "SpawnPoint"):
			if (spawnpoint.key == from):
				GameState.player.position = spawnpoint.position
				GameState.player.rotation = spawnpoint.rotation

func _on_button_quit_pressed():
	save.save_game()
	get_tree().quit()

func _on_player_interaction_detected(node):
	if (node.get_parent() is LevelChange):
		label_infos.text = tr("Open Door")
		label_infos.visible = true
		current_level_change = node.get_parent()

func _on_player_interaction_detected_end(node):
	label_infos.visible = false
	current_level_change = null
	
func _input(event):
	if (not get_tree().paused):
		if Input.is_action_just_pressed("player_interact"):
			if(current_level_change != null):
				_enter_level(GameState.current_level_key, current_level_change.destination)
	if Input.is_action_just_released ("menu"):
		_pause()

func _pause():
	hud.visible = not hud.visible
	menu.visible = not menu.visible
	if get_tree().paused:
		GameState.player.capture_mouse()
	else:
		GameState.player.release_mouse()
		button_quit.grab_focus()
	get_tree().paused = not get_tree().paused


func _on_player_hit(node):
	$TimerInfos.start()

func _on_timer_infos_timeout():
	label_infos.visible = false
