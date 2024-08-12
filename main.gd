class_name Main
extends Node3D

var default_port: int = 7777
var current_ui: Node
var UIS = {
	"MAIN_MENU": preload("res://main_menu_ui.tscn"),
	"IN_GAME": preload("res://in_game_ui.tscn")
}

func _enter_tree() -> void:
	global.main = self

func is_headless():
	return DisplayServer.get_name() == "headless"
	
func _ready() -> void:
	global.main.log("Starting Up")
	var server_flag_set = "--server" in OS.get_cmdline_user_args()
	
	# Setup Server
	if server_flag_set:
		var port_idx: int = OS.get_cmdline_user_args().find("--port")
		var port: int = default_port
		if port_idx != -1 && port_idx + 1 < len(OS.get_cmdline_user_args()):
			port = int(OS.get_cmdline_user_args()[port_idx + 1])
		
		var peer = ENetMultiplayerPeer.new()
		peer.create_server(port)
		multiplayer.multiplayer_peer = peer
	
	# Setup Client
	if not is_headless():
		goto_ui("MAIN_MENU")
	
	# Handle Peer Connections
	multiplayer.peer_connected.connect(func(id):
		global.main.log("peer_connected " + str(id))
		
		# If we're a server, spawn a player for the new player
		if multiplayer.is_server():
			spawn_player(id)
			
			for peer_id in multiplayer.get_peers():
				if get_player(peer_id):
					get_player(peer_id).set_authority.rpc_id(id, peer_id)
				if get_character(peer_id):
					get_character(peer_id).set_authority.rpc_id(id, peer_id)

		# when we connect to the server, load the in game UI
		if id == 1 and multiplayer.get_unique_id() != 1:
			goto_ui("IN_GAME")
	)

	multiplayer.peer_disconnected.connect(func(id):
		global.main.log("peer_disconnected " + str(id))
		if id == 1: return
		
		despawn_character(id)
		despawn_player(id)
	)
	

####################
## UI AND LOGGING ##
####################

# Loads a UI from the UIS dictionary
func goto_ui(ui: String):
	if current_ui:
		current_ui.queue_free()
		current_ui.get_parent().remove_child(current_ui)
		current_ui = null
	current_ui = UIS[ui].instantiate()
	add_child(current_ui)

# Logs a message to the screen as well as the console
func log(message: String):
	print(message)
	if not is_headless():
		var row = Label.new()
		row.text = message
		%logs.add_child(row)

#############################
## SPAWNING AND DESPAWNING ##
#############################

# Called on the server only. Gives ownership of the player to that player after spawning
func spawn_player(id):
	var player: Player = preload("res://player.tscn").instantiate()
	player.name = "player_" + str(id)
	add_child(player)
	player.set_authority.rpc(id)
	global.main.log("spawned player... " + str(id))

# Lets a player request a character be spawned for them, then gives that player ownership
@rpc("any_peer", "call_remote", "reliable")
func spawn_character(id):
	# only the player who owns the character can ask for it to be spawned
	if id == multiplayer.get_remote_sender_id() && multiplayer.is_server():
		var character = preload("res://character.tscn").instantiate()
		character.name = "character_" + str(id)
		add_child(character)
		character.set_authority.rpc(id)
		global.main.log("spawned character... " + str(id))

func despawn_character(id):
	var character = get_character(id) 
	if character:
		character.queue_free()
		remove_child(character)
		global.main.log("despawned character... " + str(id))


func despawn_player(id):
	var player = get_player(id)
	if player:
		player.queue_free()
		remove_child(player)
		global.main.log("despawned player... " + str(id))

func get_local_player():
	return get_player(multiplayer.get_unique_id())

func get_local_character():
	return get_character(multiplayer.get_unique_id())
	
func get_player(id: int):
	var nm = "player_" + str(id)
	if has_node(nm): return get_node(nm)
	return null

func get_character(id: int):
	var nm = "character_" + str(id)
	if has_node(nm): return get_node(nm)
	return null
	
	
##############################
## STARTING NEW GAME ROUNDS ##
##############################

# Any player can ask to start a new round at any time
# TODO: prevent restarts in the middle of a round, for example
@rpc("any_peer", "call_local", "reliable")
func request_start_new_round():
	global.main.log("somebody requested a new round...")
	# any player can ask us to start a new round, and we just will
	if multiplayer.is_server():
		var pos = Vector3(0, 0, 0)
		for client_id: int in multiplayer.get_peers():
			pos.x += 2
			despawn_character(client_id)
			start_new_round.rpc_id(client_id, pos)

# Server method to tell players to start a new round
@rpc("authority", "call_remote", "reliable")
func start_new_round(pos: Vector3):
	get_local_player().start_new_round({
		"pos": pos
	})
