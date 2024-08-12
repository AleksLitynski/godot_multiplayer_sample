class_name Character
extends Node3D

var speed: float = 10

@rpc("authority", "call_local", "reliable")
func set_authority(id: int):
	set_multiplayer_authority(id, true)
	
	if is_multiplayer_authority():
		position = global.main.get_local_player().config["pos"]

func _ready():
	global.main.log("Character spawned")
	
func _process(delta: float) -> void:
	if !is_multiplayer_authority(): return
	
	# NOTE: in order to sync the position property, we need to tell the MultiplayerSynchronizer to sync that property.
	# There is a Replication panel on the bottom of the screen where you can set up replicated properties via UI.
	# Or set them via MultiplayerSynchronizer.replication_config
	if Input.is_action_pressed("forward"):
		position.z -= delta * speed
	if Input.is_action_pressed("backward"):
		position.z += delta * speed
	if Input.is_action_pressed("right"):
		position.x += delta * speed
	if Input.is_action_pressed("left"):
		position.x -= delta * speed
