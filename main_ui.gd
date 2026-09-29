extends Control

@export var open_button: Button
@onready var lmstudio = $LMStudio
@onready var node = $"Settings Pannel/TabContainer"

func _ready():
	open_button.pressed.connect(_on_open_button_pressed)

func _on_open_button_pressed():
	$"Settings Pannel".show()
