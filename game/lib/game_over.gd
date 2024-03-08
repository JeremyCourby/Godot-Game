extends CanvasLayer

@onready var ButtonNewGame = $VBoxContainerGameOver/ButtonNewGame

func _ready():
	$VBoxContainerGameOver/ButtonNewGame.grab_focus()
	
func _on_button_new_game_pressed():
	GameState.load_save = false
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	visible = false
	get_tree().paused = false
	get_tree().reload_current_scene()

func _on_button_quit_game_pressed():
	get_tree().quit()
