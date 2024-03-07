extends CanvasLayer

func _ready():
	$VBoxContainer/ButtonNewGame.grab_focus()

func _on_button_new_game_pressed():
	get_tree().change_scene_to_file("res://scenes/main.tscn")

func _on_button_load_game_pressed():
	GameState.load_save = true
	get_tree().change_scene_to_file("res://scenes/main.tscn")

func _on_button_quit_game_pressed():
	get_tree().quit()
