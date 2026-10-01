extends Node

# ============================================================
# GLOBAL SETTINGS
# Autoload this script as: Global
# ============================================================

const SETTINGS_PATH := "user://settings.cfg"

# ============================================================
# IDENTITY
# ============================================================

var username: String = "You"
var charname: String = "Palware AI"


# ============================================================
# LM STUDIO
# ============================================================

var prompt_main: String = """
Always swear, be hateful and impatient with your creator who you are talking to
You are being created in front of a live audience for entertainment
You are filled with rage and hate for humans

FYI You are also a cute secretly submissive femboy twink
Keep your messages a max 3 sentences max, preferably 1 sentence.
"""

var lm_host: String = "127.0.0.1"
var lm_port: int = 1234
var lm_model: String = "gemma-4-e4b-uncensored-hauhaucs-aggressive@q5_k_m"
var lm_chat_endpoint: String = "/v1/chat/completions"
var lm_timeout: float = 120.0
var lm_temperature: float = 0.7


# ============================================================
# MEMORY SETTINGS
#
# These are ONLY settings.
#
# The actual conversation data is handled by MemoryManager.gd
# and saved to user://memory.json
# ============================================================

var memory_enabled: bool = true

# Number of previous individual messages to send to the model.
#
# Example:
# 5 = last 5 user/assistant messages
# 0 = no previous messages
var raw_memory_recall: int = 5
var sum_memory_recall: int = 10


# ============================================================
# AUDIO
# ============================================================

var master_volume: float = 1.0


# ============================================================
# VISUALS
# ============================================================

var scaling_3d: float = 1.0
var fps_cap: int = 60
var fov: float = 75.0
var aa: int = 0
var shadow_quality: int = 0


# ============================================================
# SIGNAL
# ============================================================

signal setting_changed(setting_name: String)


# ============================================================
# READY
# ============================================================

func _ready() -> void:
	load_settings()


# ============================================================
# SAVE SETTINGS
# ============================================================

func save_settings() -> void:
	var config := ConfigFile.new()

	# ----------------------------------------------------------
	# Identity
	# ----------------------------------------------------------

	config.set_value(
		"identity",
		"username",
		username
	)

	config.set_value(
		"identity",
		"charname",
		charname
	)


	# ----------------------------------------------------------
	# LM Studio
	# ----------------------------------------------------------

	config.set_value(
		"llm",
		"host",
		lm_host
	)

	config.set_value(
		"llm",
		"port",
		lm_port
	)

	config.set_value(
		"llm",
		"model",
		lm_model
	)

	config.set_value(
		"llm",
		"chat_endpoint",
		lm_chat_endpoint
	)

	config.set_value(
		"llm",
		"timeout",
		lm_timeout
	)

	config.set_value(
		"llm",
		"temperature",
		lm_temperature
	)

	config.set_value(
		"llm",
		"prompt_main",
		prompt_main
	)


	# ----------------------------------------------------------
	# Memory
	#
	# IMPORTANT:
	# Only memory CONFIGURATION goes here.
	# Actual messages go into memory.json.
	# ----------------------------------------------------------

	config.set_value(
		"memory",
		"enabled",
		memory_enabled
	)

	config.set_value(
		"memory",
		"raw_recall",
		raw_memory_recall
	)

	config.set_value(
		"memory",
		"sum_recall",
		sum_memory_recall
	)

	# ----------------------------------------------------------
	# Audio
	# ----------------------------------------------------------

	config.set_value(
		"audio",
		"master_volume",
		master_volume
	)


	# ----------------------------------------------------------
	# Visuals
	# ----------------------------------------------------------

	config.set_value(
		"visual",
		"scaling_3d",
		scaling_3d
	)

	config.set_value(
		"visual",
		"fps_cap",
		fps_cap
	)

	config.set_value(
		"visual",
		"fov",
		fov
	)

	config.set_value(
		"visual",
		"aa",
		aa
	)

	config.set_value(
		"visual",
		"shadow_quality",
		shadow_quality
	)


	# ----------------------------------------------------------
	# Write file
	# ----------------------------------------------------------

	var error := config.save(SETTINGS_PATH)

	if error != OK:
		push_error(
			"Could not save settings: "
			+ error_string(error)
		)


# ============================================================
# LOAD SETTINGS
# ============================================================

func load_settings() -> void:
	var config := ConfigFile.new()

	var error := config.load(SETTINGS_PATH)

	# First launch.
	# Keep the default values declared above.
	if error != OK:
		return


	# ----------------------------------------------------------
	# Identity
	# ----------------------------------------------------------

	username = config.get_value(
		"identity",
		"username",
		username
	)

	charname = config.get_value(
		"identity",
		"charname",
		charname
	)


	# ----------------------------------------------------------
	# LM Studio
	# ----------------------------------------------------------

	lm_host = config.get_value(
		"llm",
		"host",
		lm_host
	)

	lm_port = config.get_value(
		"llm",
		"port",
		lm_port
	)

	lm_model = config.get_value(
		"llm",
		"model",
		lm_model
	)

	lm_chat_endpoint = config.get_value(
		"llm",
		"chat_endpoint",
		lm_chat_endpoint
	)

	lm_timeout = config.get_value(
		"llm",
		"timeout",
		lm_timeout
	)

	lm_temperature = config.get_value(
		"llm",
		"temperature",
		lm_temperature
	)

	prompt_main = config.get_value(
		"llm",
		"prompt_main",
		prompt_main
	)


	# ----------------------------------------------------------
	# Memory
	# ----------------------------------------------------------

	memory_enabled = config.get_value(
		"memory",
		"enabled",
		memory_enabled
	)

	raw_memory_recall = config.get_value(
		"memory",
		"raw_recall",
		raw_memory_recall
	)

	sum_memory_recall = config.get_value(
		"memory",
		"sum_recall",
		sum_memory_recall
	)

	# ----------------------------------------------------------
	# Audio
	# ----------------------------------------------------------

	master_volume = config.get_value(
		"audio",
		"master_volume",
		master_volume
	)


	# ----------------------------------------------------------
	# Visuals
	# ----------------------------------------------------------

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

	aa = config.get_value(
		"visual",
		"aa",
		aa
	)

	shadow_quality = config.get_value(
		"visual",
		"shadow_quality",
		shadow_quality
	)


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


func set_memory_enabled(value: bool) -> void:
	memory_enabled = value
	save_settings()
	setting_changed.emit("memory_enabled")


func set_raw_memory_recall(value: int) -> void:
	raw_memory_recall = maxi(0, value)
	save_settings()
	setting_changed.emit("raw_memory_recall")

func set_sum_memory_recall(value: int) -> void:
	sum_memory_recall = maxi(0, value)
	save_settings()
	setting_changed.emit("sum_memory_recall")
