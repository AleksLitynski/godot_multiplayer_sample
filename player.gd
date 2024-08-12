class_name Player
extends Node

var character: Character
var config: Dictionary

@rpc("authority", "call_local", "reliable")
func set_authority(id: int):
		set_multiplayer_authority(id, true)
		
@rpc("authority", "call_local", "reliable")
func start_new_round(in_config: Dictionary):
	global.main.log("starting new round at: " + str(in_config["pos"]))
	config = in_config
	global.main.spawn_character.rpc(multiplayer.get_unique_id())
	
