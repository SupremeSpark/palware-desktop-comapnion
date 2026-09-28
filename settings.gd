extends Control

@onready var player_cam = get_tree().current_scene.get_node("Camera3D")
# @onready var environment: Environment = get_tree().current_scene.get_node("WorldEnviroment").enviroment

func save_game(save_name, value):
	var save = FileAccess.open("user://" + save_name + ".omo", FileAccess.WRITE)
	save.store_string(str(value))
	save.close()

#epic set-ing the settings
func scaling_3d(value):
	save_game("3d_scaling", value)
	get_viewport().scaling_3d_scale = value
	
func maser_volume(value):
	save_game("maser_volume", value)
	AudioServer.set_bus_volume_db(0, linear_to_db(value))

func fov(value):
	save_game("3d_scaling", value)
	if player_cam != null:
		player_cam.fov = value

func set_aa_options(msaa, taa, fxaa):
	get_viewport().msaa_3d = msaa
	get_viewport().use_taa = taa
	get_viewport().screen_space_aa = fxaa
	
func aa(index):
	save_game("3d_scaling", index)
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
