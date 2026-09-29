extends Control


# ============================================================
# REFERENCES
# ============================================================

@onready var chatbox = get_tree().root.get_node("Main/MainUI/Chatbox")
@onready var LLM = get_tree().root.get_node("Main/MainUI/Chatbox/LMStudio")

@onready var player_cam: Camera3D = get_tree().current_scene.get_node("Camera3D")

@onready var prompt_main: TextEdit = $TabContainer/Prompt/ScrollContainer/VBoxContainer/PromptMain

@onready var fps_label: Label = $"TabContainer/Visuals/ScrollContainer/VBoxContainer/FpsLabel"
@onready var fov_label: Label = $"TabContainer/Visuals/ScrollContainer/VBoxContainer/FovLabel"
@onready var mastervolume_label: Label = $"TabContainer/Audio/ScrollContainer/VBoxContainer/MasterVolumeLabel"


# ============================================================
# INITIALIZATION
# ============================================================

func _ready() -> void:
	load_settings_into_ui()

	# Listen for settings changed somewhere else.
	if not Global.setting_changed.is_connected(_on_global_setting_changed):
		Global.setting_changed.connect(_on_global_setting_changed)


func load_settings_into_ui() -> void:

	# -------------------------
	# AUDIO
	# -------------------------

	var master_volume = $TabContainer/Audio/ScrollContainer/VBoxContainer/MasterVolume

	master_volume.value = Global.get_value("master_volume")
	update_master_volume_label(master_volume.value)


	# -------------------------
	# VISUALS
	# -------------------------

	var scaling_3d = $"TabContainer/Visuals/ScrollContainer/VBoxContainer/3DScaling"
	scaling_3d.value = Global.get_value("3d_scaling")


	var fps = $"TabContainer/Visuals/ScrollContainer/VBoxContainer/FPS"
	fps.value = Global.get_value("fps_cap")
	update_fps_label(fps.value)


	var fov_slider = $"TabContainer/Visuals/ScrollContainer/VBoxContainer/FOV"
	fov_slider.value = Global.get_value("fov")
	update_fov_label(fov_slider.value)


	var aa = $TabContainer/Visuals/ScrollContainer/VBoxContainer/AntiAliasing
	aa.selected = Global.get_value("aa")


	var shadow = $"TabContainer/Visuals/ScrollContainer/VBoxContainer/Shadow"
	shadow.selected = Global.get_value("shadow_quality")


# ============================================================
# AUDIO
# ============================================================

func master_volume(value: float) -> void:
	Global.set_value("master_volume", value)
	update_master_volume_label(value)


func update_master_volume_label(value: float) -> void:
	mastervolume_label.text = "Current Volume: " + str(value)


# ============================================================
# VISUALS
# ============================================================

func scaling_3d(value: float) -> void:
	Global.set_value("3d_scaling", value)


func fps_cap(value: float) -> void:
	Global.set_value("fps_cap", int(value))
	update_fps_label(value)


func update_fps_label(value: float) -> void:
	if value == 0:
		fps_label.text = "Current FPS: Unlimited"
	else:
		fps_label.text = "Current FPS: " + str(int(value))


func fov(value: float) -> void:
	Global.set_value("fov", value)

	if player_cam != null:
		player_cam.fov = value

	update_fov_label(value)


func update_fov_label(value: float) -> void:
	fov_label.text = "Current FOV: " + str(value)


# ============================================================
# ANTI-ALIASING
# ============================================================

func aa(index: int) -> void:
	Global.set_value("aa", index)


# ============================================================
# SHADOW QUALITY
# ============================================================

func shadow_quality(index: int) -> void:
	Global.set_value("shadow_quality", index)


# ============================================================
# USER / CHARACTER
# ============================================================

func change_username(value: String) -> void:
	Global.set_value("username", value)

	chatbox.username = value
	LLM.username = value


func change_charname(value: String) -> void:
	Global.set_value("charname", value)

	chatbox.charname = value
	LLM.charname = value


# ============================================================
# GLOBAL SETTING CHANGES
# ============================================================

func _on_global_setting_changed(key: String, value: Variant) -> void:

	match key:

		"master_volume":
			update_master_volume_label(value)

		"fps_cap":
			update_fps_label(value)

		"fov":
			update_fov_label(value)

			if player_cam != null:
				player_cam.fov = value
