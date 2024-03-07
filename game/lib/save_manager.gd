class_name SaveManager extends Object

const default_filename:String = "Save_Game"

func _build():
	if GameState.player.wave_finish == false:
		GameState.player.player_wave_level -= 1
		GameState.player.wave_load_number = GameState.player.wave_load_last_number
	return {
		"current_level": GameState.current_level_key,
		"position_x": GameState.player.position.x,
		"position_y": GameState.player.position.y,
		"position_z": GameState.player.position.z,
		"rotation_x": GameState.player.rotation_degrees.x,
		"rotation_y": GameState.player.rotation_degrees.y,
		"rotation_z": GameState.player.rotation_degrees.z,
		"player_level": GameState.player.player_level,
		"player_xp": GameState.player.player_xp,
		"player_life": GameState.player.player_life,
		"player_max_life": GameState.player.player_max_life,
		"portal_life": GameState.portal.portal_life,
		"player_wave_level": GameState.player.player_wave_level,
		"player_health_level": GameState.player.health_level,
		"player_attack_level": GameState.player.attack_level,
		"player_speed_level": GameState.player.speed_level,
		"player_walking_speed": GameState.player.walking_speed,
		"player_running_speed": GameState.player.running_speed,
		"player_base_attack": GameState.player.base_attack,
		"wave_load_number": GameState.player.wave_load_number
	}
	
func save_game():
	print(default_filename)
	var savegame = FileAccess.open(default_filename, FileAccess.WRITE)
	if (savegame != null):
		savegame.store_line(JSON.stringify(_build()))
		
func load_game() :
	var savegame = FileAccess.open(default_filename, FileAccess.READ)
	if (savegame != null):
		var json:JSON = JSON.new()
		var parse_result = json.parse(savegame.get_line())
		if not(parse_result == OK):
			return
		var data: Dictionary = json.get_data()
		GameState.player.position.x = data.get("position_x", GameState.player.position.x)
		GameState.player.position.y = data.get("position_y", GameState.player.position.y)
		GameState.player.position.z = data.get("position_z", GameState.player.position.z)
		GameState.player.rotation_degrees.x = data.get("rotation_x", GameState.player.rotation_degrees.x)
		GameState.player.rotation_degrees.y = data.get("rotation_y", GameState.player.rotation_degrees.y)
		GameState.player.rotation_degrees.z = data.get("rotation_z", GameState.player.rotation_degrees.z)
		GameState.current_level_key = data.get("current_level", GameState.current_level_key)
		GameState.player.player_level = data.get("player_level", GameState.player.player_level)
		GameState.player.player_xp = data.get("player_xp", GameState.player.player_xp)
		GameState.player.player_life = data.get("player_life", GameState.player.player_life)
		GameState.player.player_max_life = data.get("player_max_life", GameState.player.player_max_life)
		GameState.player.portal_load_life = data.get("portal_life", GameState.player.portal_load_life)
		GameState.player.player_wave_level = data.get("player_wave_level", GameState.player.player_wave_level)
		GameState.player.health_level = data.get("player_health_level", GameState.player.health_level)
		GameState.player.attack_level = data.get("player_attack_level", GameState.player.attack_level)
		GameState.player.speed_level = data.get("player_speed_level", GameState.player.speed_level)
		GameState.player.walking_speed = data.get("player_walking_speed", GameState.player.walking_speed)
		GameState.player.running_speed = data.get("player_running_speed", GameState.player.running_speed)
		GameState.player.base_attack = data.get("player_base_attack", GameState.player.base_attack)
		GameState.player.wave_load_number = data.get("wave_load_number", GameState.player.wave_load_number)
