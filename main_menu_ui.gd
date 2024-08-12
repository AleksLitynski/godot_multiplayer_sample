class_name MainMenuUi
extends Control


func _ready() -> void:
	%connect_btn.pressed.connect(func():
		connect_to_server()
	)

func get_ip() -> String:
	return %server_port_input.text.split(":")[0]

func get_port() -> int:
	global.main.log(%server_port_input.text)
	return int(%server_port_input.text.split(":")[1])

func connect_to_server():
	var peer = ENetMultiplayerPeer.new()
	peer.create_client(get_ip(), get_port())
	multiplayer.multiplayer_peer = peer
