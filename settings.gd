extends Control

# ============================================================
# SETTINGS WINDOW
# Global is the shared source of truth. This scene edits Global
# and applies settings to the running application immediately.
# ============================================================

# Kept for the settings that directly affect the existing Chatbox.
# LLM configuration itself is no longer stored in this scene.
@onready var chatbox = get_tree().root.get_node("Main/MainUI/Chatbox")
@onready var LLM: LMStudio = get_tree().root.get_node("Main/MainUI/Chatbox/LMStudio")

@onready var prompt_main: TextEdit = $TabContainer/Prompt/ScrollContainer/VBoxContainer/PromptMain
@onready var player_cam = get_tree().current_scene.get_node("Camera3D")
# @onready var environment: Environment = get_tree().current_scene.get_node("WorldEnviroment").environment

# Epic labels
@onready var layer1_label: Label = $"TabContainer/Memory/ScrollContainer/VBoxContainer/Layer1Label"
@onready var layer2_label: Label = $"TabContainer/Memory/ScrollContainer/VBoxContainer/Layer2Label"
@onready var fps_label: Label = $"TabContainer/Visuals/ScrollContainer/VBoxContainer/FpsLabel"
@onready var fov_label: Label = $"TabContainer/Visuals/ScrollContainer/VBoxContainer/FovLabel"
@onready var mastervolume_label: Label = $TabContainer/Audio/ScrollContainer/VBoxContainer/MasterVolumeLabel
@onready var timeout_label: Label = $TabContainer/Connection/ScrollContainer/VBoxContainer/TimeoutSecLabel

func _ready() -> void:
	# ----------------------------------------------------------
	# Load Global values into the controls.
	# ----------------------------------------------------------
	prompt_main.text = Global.prompt_main

	$TabContainer/Audio/ScrollContainer/VBoxContainer/MasterVolume.value = Global.master_volume
	$"TabContainer/Visuals/ScrollContainer/VBoxContainer/3DScaling".value = Global.scaling_3d
	$"TabContainer/Visuals/ScrollContainer/VBoxContainer/FPS".value = Global.fps_cap
	$"TabContainer/Visuals/ScrollContainer/VBoxContainer/FOV".value = Global.fov
	$TabContainer/Visuals/ScrollContainer/VBoxContainer/AntiAliasing.selected = Global.aa
	$"TabContainer/Visuals/ScrollContainer/VBoxContainer/Shadow".selected = Global.shadow_quality

	# ----------------------------------------------------------
	# Prompt
	# ----------------------------------------------------------
	# Make sure the prompt control is connected even if the signal
	# was not connected in the Godot editor.
	if not prompt_main.text_changed.is_connected(_on_prompt_main_text_changed):
		prompt_main.text_changed.connect(_on_prompt_main_text_changed)

	# ----------------------------------------------------------
	# Apply current settings immediately.
	# ----------------------------------------------------------
	master_volume($TabContainer/Audio/ScrollContainer/VBoxContainer/MasterVolume.value)
	scaling_3d($"TabContainer/Visuals/ScrollContainer/VBoxContainer/3DScaling".value)
	fov($"TabContainer/Visuals/ScrollContainer/VBoxContainer/FOV".value)
	fps_cap($TabContainer/Visuals/ScrollContainer/VBoxContainer/FPS.value)
	aa($TabContainer/Visuals/ScrollContainer/VBoxContainer/AntiAliasing.selected)
	shadow_quality($TabContainer/Visuals/ScrollContainer/VBoxContainer/Shadow.selected)


# ============================================================
# GENERAL SAVE COMPATIBILITY
# ============================================================

# Kept as a compatibility helper in case other controls/scripts
# still call save_game(). New settings should preferably use Global.
func save_game(save_name, value):
	var save = FileAccess.open("user://" + save_name + ".omo", FileAccess.WRITE)
	if save:
		save.store_string(str(value))
		save.close()


func load_slider(save_name, slider):
	var save = FileAccess.open("user://" + save_name + ".omo", FileAccess.READ)
	if save:
		slider.value = float(save.get_as_text())
		save.close()


func load_options(save_name, button):
	var save = FileAccess.open("user://" + save_name + ".omo", FileAccess.READ)
	if save:
		button.selected = int(save.get_as_text())
		save.close()

# ============================================================
# Connection
# ============================================================
func host(value):
	Global.host(value)

func port(value):
	Global.port(value)

func model(value):
	Global.model(value)

func chat_endpoint(value):
	Global.chat_endpoint(value)
	
func timeout_sec (value):
	Global.lm_timeout = value
	Global.save_settings()
	
	timeout_label.text = "Current: " + str(value) + " seconds"

# ============================================================
# Generation
# ============================================================
func context_length(value):
	Global.context_length(value)

func max_response_length(value):
	Global.max_response_length(value)

func temperature(value):
	Global.temperature(value)

func top_p(value):
	Global.top_p(value)

func top_k(value):
	Global.top_k(value)

func min_p(value):
	Global.min_p(value)

func typical_p(value):
	Global.typical_p(value)
	
func repetition_penalty(value):
	Global.min_p(value)

func seed(value):
	Global.typical_p(value)

# ============================================================
# PROMPT
# ============================================================
func change_username(value):
	Global.set_username(value)

	# Preserve current Chatbox behavior immediately.
	if chatbox != null:
		chatbox.username = Global.username

func change_charname(value):
	Global.set_charname(value)

	# Preserve current Chatbox behavior immediately.
	if chatbox != null:
		chatbox.charname = Global.charname

func _on_prompt_main_text_changed() -> void:
	Global.set_prompt(prompt_main.text)
	print("[Settings] AI prompt updated")

# ============================================================
# MEMORY SETTINGS
# ============================================================

func set_memory_enabled(value: bool) -> void:
	Global.set_memory_enabled(value)
	print("[Settings] Memory enabled: ", Global.memory_enabled)

func set_raw_memory_recall(value: int) -> void:
	Global.set_raw_memory_recall(value)
	layer1_label.text = "Vividly remembers last " + str(value/2) + " exchanges"
	print("[Settings] Raw memory recall: ", Global.raw_memory_recall)

func set_sum_memory_recall(value: int) -> void:
	Global.set_sum_memory_recall(value)
	layer2_label.text = "Vaguely remembers " + str(value/2) + " MORE exchanges"
	print("[Settings] Summerized memory recall: ", Global.sum_memory_recall)

func clear_memory() -> void:
	MemoryManager.clear_memory()
	print("[Settings] Rolling memory cleared.")

func get_memory_count() -> int:
	return MemoryManager.get_memory_count()

# ============================================================
# AUDIO
# ============================================================

func master_volume(value):
	Global.master_volume = value
	Global.save_settings()

	AudioServer.set_bus_volume_db(0, linear_to_db(value))
	mastervolume_label.text = "Current Volume: " + str(value) + "%"


# ============================================================
# VISUALS
# ============================================================

func scaling_3d(value):
	Global.scaling_3d = value
	Global.save_settings()

	get_viewport().scaling_3d_scale = value


func fov(value):
	Global.fov = value
	Global.save_settings()

	if player_cam != null:
		player_cam.fov = value

	fov_label.text = "Current FOV: " + str(value)


func set_aa_options(msaa, taa, fxaa):
	get_viewport().msaa_3d = msaa
	get_viewport().use_taa = taa
	get_viewport().screen_space_aa = fxaa


func aa(index):
	Global.aa = index
	Global.save_settings()

	if index == 0:
		set_aa_options(Viewport.MSAA_DISABLED, false, Viewport.SCREEN_SPACE_AA_DISABLED)
	elif index == 1:
		set_aa_options(Viewport.MSAA_DISABLED, false, Viewport.SCREEN_SPACE_AA_FXAA)
	elif index == 2:
		set_aa_options(Viewport.MSAA_DISABLED, true, Viewport.SCREEN_SPACE_AA_DISABLED)
	elif index == 3:
		set_aa_options(Viewport.MSAA_2X, false, Viewport.SCREEN_SPACE_AA_DISABLED)
	elif index == 4:
		set_aa_options(Viewport.MSAA_4X, false, Viewport.SCREEN_SPACE_AA_DISABLED)
	elif index == 5:
		set_aa_options(Viewport.MSAA_8X, false, Viewport.SCREEN_SPACE_AA_DISABLED)


func fps_cap(value):
	Global.fps_cap = value
	Global.save_settings()

	Engine.max_fps = value
	fps_label.text = "Current FPS: " + str(value)

func set_shadow(quality):
	RenderingServer.directional_soft_shadow_filter_set_quality(quality)
	RenderingServer.positional_soft_shadow_filter_set_quality(quality)

func shadow_quality(index):
	Global.shadow_quality = index
	Global.save_settings()

	if index == 0:
		set_shadow(RenderingServer.SHADOW_QUALITY_HARD)
	elif index == 1:
		set_shadow(RenderingServer.SHADOW_QUALITY_SOFT_VERY_LOW)
	elif index == 2:
		set_shadow(RenderingServer.SHADOW_QUALITY_SOFT_LOW)
	elif index == 3:
		set_shadow(RenderingServer.SHADOW_QUALITY_SOFT_MEDIUM)
	elif index == 4:
		set_shadow(RenderingServer.SHADOW_QUALITY_SOFT_HIGH)
	elif index == 5:
		set_shadow(RenderingServer.SHADOW_QUALITY_SOFT_ULTRA)
