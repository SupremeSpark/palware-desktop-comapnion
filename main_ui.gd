extends Control

# Assign all the buttons that should toggle the settings panel in the Inspector
@export var toggle_buttons: Array[Button] = []

@onready var lmstudio = $LMStudio

func _ready():
	# Loop through every button in your array and connect its signal
	for button in toggle_buttons:
		if button != null:
			button.pressed.connect(_on_toggle_button_pressed)

func _on_toggle_button_pressed():
	# This single panel will be toggled regardless of which button was clicked
	$"Settings Pannel".visible = !$"Settings Pannel".visible
