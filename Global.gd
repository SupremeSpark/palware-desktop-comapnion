extends Node

# ============================================================
# LLM SETTINGS
# ============================================================

var username: String = "You"
var charname: String = "Palware AI"

var prompt_main: String = """
Always swear, be hateful and impatient with your creator who you are talking to
You are being created in front of a live audience for entertanment
You are filled with rage and hate for humans

Keep your messages a max 3 setences max, preferably 1 sentence.

Always end your message with '<message sent to user>' in a new line
"""

var lm_host: String = "127.0.0.1"
var lm_port: int = 1234
var lm_endpoint: String = "/v1/chat/completions"
var lm_model: String = "gemma-4-e4b-uncensored-hauhaucs-aggressive@q5_k_m"
var lm_timeout: float = 120.0

var temperature: float = 0.7


# ============================================================
# VISUAL SETTINGS
# ============================================================

var master_volume: float = 1.0
var scaling_3d: float = 1.0
var fps_cap: int = 60
var fov: float = 75.0

var aa: int = 0
var shadow_quality: int = 0


# ============================================================
# SIGNALS
# ============================================================

signal setting_changed(setting_name: String)


# ============================================================
# SETTING FUNCTIONS
# ============================================================

func set_setting(setting_name: String, value) -> void:

	set(setting_name, value)

	setting_changed.emit(setting_name)

	save_settings()


# ============================================================
# SAVE / LOAD
# ============================================================

func save_settings() -> void:

	var config := ConfigFile.new()

	# LLM
	config.set_value("llm", "username", username)
	config.set_value("llm", "charname", charname)
	config.set_value("llm", "prompt_main", prompt_main)
	config.set_value("llm", "host", lm_host)
	config.set_value("llm", "port", lm_port)
	config.set_value("llm", "endpoint", lm_endpoint)
	config.set_value("llm", "model", lm_model)
	config.set_value("llm", "timeout", lm_timeout)
	config.set_value("llm", "temperature", temperature)

	# Visual
	config.set_value("visual", "master_volume", master_volume)
	config.set_value("visual", "scaling_3d", scaling_3d)
	config.set_value("visual", "fps_cap", fps_cap)
	config.set_value("visual", "fov", fov)
	config.set_value("visual", "aa", aa)
	config.set_value("visual", "shadow_quality", shadow_quality)

	config.save("user://settings.cfg")


func load_settings() -> void:

	var config := ConfigFile.new()

	var error := config.load("user://settings.cfg")

	if error != OK:
		print("No settings file found. Using defaults.")
		return

	# LLM
	username = config.get_value("llm", "username", username)
	charname = config.get_value("llm", "charname", charname)
	prompt_main = config.get_value("llm", "prompt_main", prompt_main)

	lm_host = config.get_value("llm", "host", lm_host)
	lm_port = config.get_value("llm", "port", lm_port)
	lm_endpoint = config.get_value("llm", "endpoint", lm_endpoint)
	lm_model = config.get_value("llm", "model", lm_model)
	lm_timeout = config.get_value("llm", "timeout", lm_timeout)

	temperature = config.get_value(
		"llm",
		"temperature",
		temperature
	)

	# Visual
	master_volume = config.get_value(
		"visual",
		"master_volume",
		master_volume
	)

	scaling_3d = config.get_value(
		"visual",
		"scaling_3d",
		scaling_3d
	)

	fps_cap = config.get_value(
		"visual",
		"fps_cap",
		fps_cap
	)

	fov = config.get_value(
		"visual",
		"fov",
		fov
	)

	aa = config.get_value("visual", "aa", aa)

	shadow_quality = config.get_value(
		"visual",
		"shadow_quality",
		shadow_quality
	)


# ============================================================
# STARTUP
# ============================================================

func _ready() -> void:

	load_settings()
