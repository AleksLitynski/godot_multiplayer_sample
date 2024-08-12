class_name InGameUi
extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	%request_new_round.pressed.connect(func():
		global.main.request_start_new_round.rpc()
	)
