extends Control

@export var open_button: Button
@export var scene_to_open: PackedScene


func _ready():
	open_button.pressed.connect(_on_open_button_pressed)


func _on_open_button_pressed():
	var window = Window.new()
	var content = scene_to_open.instantiate()

	window.add_child(content)
	add_child(window)

	window.size = Vector2(600, 400)

	window.close_requested.connect(window.queue_free)

	window.popup_centered()
