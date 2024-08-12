extends Camera3D

func _ready() -> void:
	if global.main.is_headless():
		process_mode = PROCESS_MODE_DISABLED

func _process(_delta: float) -> void:
	var local_character = global.main.get_local_character()
	if local_character:
		position = local_character.position + Vector3(0, 4, 3)
