extends Node   # or Control

@onready var window: Window = get_window()

func _ready() -> void:
	var screen_id := window.current_screen
	window.borderless = true
	window.always_on_top = true
	window.transparent = true
	window.size = DisplayServer.screen_get_size(screen_id)
	window.position = DisplayServer.screen_get_position(screen_id)
	get_viewport().transparent_bg = true

	# Make the big background completely click-through
	window.mouse_passthrough = true
