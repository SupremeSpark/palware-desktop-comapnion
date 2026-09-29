extends Node

# ============================================================
# SHARED APPLICATION SETTINGS
# This script should be added as an Autoload named "Global".
# ============================================================

# ----------------------------
# Identity
# ----------------------------
var username: String = "You"
var charname: String = "Palware AI"

# ----------------------------
# LM Studio / LLM
# ----------------------------
var prompt_main: String = """
Always swear, be hateful and impatient with your creator who you are talking to
You are being created in front of a live audience for entertanment
You are filled with rage and hate for humans

Keep your messages a max 3 setences max, preferably 1 sentence.

Always end your message with '<message sent to user>' in a new line
"""

var lm_host: String = "127.0.0.1"
var lm_port: int = 1234
var lm_chat_endpoint: String = "/v1/chat/completions"
var lm_model: String = "gemma-4-e4b-uncensored-hauhaucs-aggressive@q5_k_m"
var lm_timeout: float = 120.0
var lm_temperature: float = 0.7

# ----------------------------
# Audio
# ----------------------------
var master_volume: float = 1.0

# ----------------------------
# Visuals
# ----------------------------
var scaling_3d: float = 1.0
var fps_cap: int = 60
var fov: float = 75.0
var aa: int = 0
var shadow_quality: int = 0

# Emitted whenever a setting is changed.
signal setting_changed(setting_name: String)

const SETTINGS_PATH := "user://settings.cfg"


func _ready() -> void:
	load_settings()


# ============================================================
# SAVE / LOAD
# ============================================================

func save_settings() -> void:
	var config := ConfigFile.new()

	# Identity
	config.set_value("identity", "username", username)
	config.set_value("identity", "charname", charname)

	# LLM
	config.set_value("llm", "prompt_main", prompt_main)
	config.set_value("llm", "host", lm_host)
	config.set_value("llm", "port", lm_port)
	config.set_value("llm", "chat_endpoint", lm_chat_endpoint)
	config.set_value("llm", "model", lm_model)
	config.set_value("llm", "timeout", lm_timeout)
	config.set_value("llm", "temperature", lm_temperature)

	# Audio
	config.set_value("audio", "master_volume", master_volume)

	# Visuals
	config.set_value("visual", "scaling_3d", scaling_3d)
	config.set_value("visual", "fps_cap", fps_cap)
	config.set_value("visual", "fov", fov)
	config.set_value("visual", "aa", aa)
	config.set_value("visual", "shadow_quality", shadow_quality)

	var error := config.save(SETTINGS_PATH)

	if error != OK:
		push_error("Could not save settings: %s" % error_string(error))


func load_settings() -> void:
	var config := ConfigFile.new()
	var error := config.load(SETTINGS_PATH)

	if error != OK:
		# First launch: keep the defaults above.
		return

	# Identity
	username = config.get_value("identity", "username", username)
	charname = config.get_value("identity", "charname", charname)

	# LLM
	prompt_main = config.get_value("llm", "prompt_main", prompt_main)
	lm_host = config.get_value("llm", "host", lm_host)
	lm_port = config.get_value("llm", "port", lm_port)
	lm_chat_endpoint = config.get_value("llm", "chat_endpoint", lm_chat_endpoint)
	lm_model = config.get_value("llm", "model", lm_model)
	lm_timeout = config.get_value("llm", "timeout", lm_timeout)
	lm_temperature = config.get_value("llm", "temperature", lm_temperature)

	# Audio
	master_volume = config.get_value("audio", "master_volume", master_volume)

	# Visuals
	scaling_3d = config.get_value("visual", "scaling_3d", scaling_3d)
	fps_cap = config.get_value("visual", "fps_cap", fps_cap)
	fov = config.get_value("visual", "fov", fov)
	aa = config.get_value("visual", "aa", aa)
	shadow_quality = config.get_value("visual", "shadow_quality", shadow_quality)


# ============================================================
# SETTING HELPERS
# ============================================================

func set_prompt(value: String) -> void:
	prompt_main = value
	save_settings()
	setting_changed.emit("prompt_main")


func set_username(value: String) -> void:
	username = value
	save_settings()
	setting_changed.emit("username")


func set_charname(value: String) -> void:
	charname = value
	save_settings()
	setting_changed.emit("charname")
