extends Control

#connections to other scrits
@onready var chatbox = get_tree().root.get_node("Main/MainUI/Chatbox")
@onready var LLM = get_tree().root.get_node("Main/MainUI/Chatbox/LMStudio")

#
@onready var prompt_main: TextEdit = $TabContainer/Prompt/ScrollContainer/VBoxContainer/PromptMain
@onready var player_cam = get_tree().current_scene.get_node("Camera3D")
# @onready var environment: Environment = get_tree().current_scene.get_node("WorldEnviroment").enviroment
@onready var fps_label: Label = $"TabContainer/Visuals/ScrollContainer/VBoxContainer/FpsLabel"
@onready var fov_label: Label = $"TabContainer/Visuals/ScrollContainer/VBoxContainer/FovLabel"
@onready var mastervolume_label: Label = $TabContainer/Audio/ScrollContainer/VBoxContainer/MasterVolumeLabel

func _ready() -> void:
#loading stuff
	#connection
	#generation
	#prompt
	#memory
	#audio
	load_slider("master_volume", $TabContainer/Audio/ScrollContainer/VBoxContainer/MasterVolume)
	#visuals
	load_slider("3d_scaling", $"TabContainer/Visuals/ScrollContainer/VBoxContainer/3DScaling")
	load_slider("fps_cap", $"TabContainer/Visuals/ScrollContainer/VBoxContainer/FPS")
	load_slider("fov", $"TabContainer/Visuals/ScrollContainer/VBoxContainer/FOV")
	load_options("aa", $TabContainer/Visuals/ScrollContainer/VBoxContainer/AntiAliasing)
	load_options("shadow_quality", $"TabContainer/Visuals/ScrollContainer/VBoxContainer/Shadow")
	#debug (to be worked)
	
#set-ing the settings lmao
	#connection
	#generation
	#prompt
	#memory
	#audio
	master_volume($TabContainer/Audio/ScrollContainer/VBoxContainer/MasterVolume.value)
	#visuals
	scaling_3d($"TabContainer/Visuals/ScrollContainer/VBoxContainer/3DScaling".value)
	fov($"TabContainer/Visuals/ScrollContainer/VBoxContainer/FOV".value)
	fps_cap($TabContainer/Visuals/ScrollContainer/VBoxContainer/FPS.value)
	aa($TabContainer/Visuals/ScrollContainer/VBoxContainer/AntiAliasing.selected)
	shadow_quality($TabContainer/Visuals/ScrollContainer/VBoxContainer/Shadow.selected)
	#debug (to be worked)
	

func save_game(save_name, value):
	var save = FileAccess.open("user://" + save_name + ".omo", FileAccess.WRITE)
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
			save.close

#epic set-ing the settings
func scaling_3d(value):
	save_game("3d_scaling", value)
	get_viewport().scaling_3d_scale = value
	
func master_volume(value):
	save_game("master_volume", value)
	AudioServer.set_bus_volume_db(0, linear_to_db(value))
	mastervolume_label.text = "Current Volume: " + str(value) + "%"

func fov(value):
	save_game("fov", value)
	if player_cam != null:
		player_cam.fov = value
	fov_label.text = "Current FOV: " + str(value)

func set_aa_options(msaa, taa, fxaa):
	get_viewport().msaa_3d = msaa
	get_viewport().use_taa = taa
	get_viewport().screen_space_aa = fxaa
	
func aa(index):
	save_game("aa", index)
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

#enviroment stuff dont touch
#func ssao(index):
	#save_game("ssao", index)
	#environment.ssao_enabled = index
#
#func ssil(index):
	#save_game("ssao", index)
	#environment.ssil_enabled = index
#
#func glow(index):
	#save_game("ssao", index)
	#environment.glow_enabled = index
	
func fps_cap(value):
	save_game("fps", value)
	Engine.max_fps = value
	fps_label.text = "Current FPS: " + str(value)

func set_shadow(quality):
	RenderingServer.directional_soft_shadow_filter_set_quality(quality)
	RenderingServer.positional_soft_shadow_filter_set_quality(quality)

func shadow_quality(index):
	save_game("shadow_quality", index)
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

func change_username(value):
	chatbox.username = value
	LLM.username = value
	
func change_charname(value):
	chatbox.charname = value
	LLM.charname = value
