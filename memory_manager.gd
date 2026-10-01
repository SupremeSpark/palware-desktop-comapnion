extends Node

# ============================================================
# MEMORY MANAGER
#
# Handles persistent immediate/raw conversation memory.
#
# Global.gd
#   ↓
# Memory configuration
#
# MemoryManager.gd
#   ↓
# Actual conversation data
#
# memory.json
#   ↓
# Persistent storage
#
# This is intentionally NOT the future RAG system.
# ============================================================


const MEMORY_PATH := "user://memory.json"


# Maximum number of messages we physically keep in the file.
#
# This is different from Global.raw_memory_recall.
#
# Example:
#
# raw_memory_recall = 5
#
# means only 5 are sent to the AI.
#
# MAX_STORED_MESSAGES = 2000
#
# means up to 2000 can remain in memory.json.
const MAX_STORED_MESSAGES := 2000


# ============================================================
# MEMORY DATA
# ============================================================

var messages: Array[Dictionary] = []


# ============================================================
# READY
# ============================================================

func _ready() -> void:
	load_memory()


# ============================================================
# ADD MESSAGE
# ============================================================

func add_message(
	role: String,
	content: String
) -> void:

	# Don't save completely empty messages.
	if content.strip_edges().is_empty():
		return

	messages.append({
		"role": role,
		"content": content
	})


	# Prevent the file from growing forever.
	while messages.size() > MAX_STORED_MESSAGES:
		messages.pop_front()


# ============================================================
# GET RECENT MESSAGES
# ============================================================

func get_recent_messages(
	limit: int
) -> Array[Dictionary]:

	if limit <= 0:
		return []

	if messages.is_empty():
		return []


	var start_index := maxi(
		0,
		messages.size() - limit
	)


	var recent: Array[Dictionary] = []


	for i in range(
		start_index,
		messages.size()
	):

		recent.append(
			messages[i].duplicate(true)
		)


	return recent


# ============================================================
# SAVE MEMORY
# ============================================================

func save_memory() -> void:

	var file := FileAccess.open(
		MEMORY_PATH,
		FileAccess.WRITE
	)


	if file == null:
		push_error(
			"[MemoryManager] Could not open memory.json for writing."
		)

		return


	var data := {
		"messages": messages
	}


	file.store_string(
		JSON.stringify(
			data,
			"  "
		)
	)


	file.close()


	print(
		"[MemoryManager] Saved ",
		messages.size(),
		" messages."
	)


# ============================================================
# LOAD MEMORY
# ============================================================

func load_memory() -> void:

	messages.clear()


	# No memory file yet.
	if not FileAccess.file_exists(
		MEMORY_PATH
	):

		print(
			"[MemoryManager] No memory file found. Starting fresh."
		)

		return


	var file := FileAccess.open(
		MEMORY_PATH,
		FileAccess.READ
	)


	if file == null:
		push_error(
			"[MemoryManager] Could not open memory.json."
		)

		return


	var raw_text := file.get_as_text()

	file.close()


	var data = JSON.parse_string(
		raw_text
	)


	if data == null:
		push_error(
			"[MemoryManager] Could not parse memory.json."
		)

		return


	if not data is Dictionary:
		push_error(
			"[MemoryManager] memory.json root is not a Dictionary."
		)

		return


	var saved_messages = data.get(
		"messages",
		[]
	)


	if not saved_messages is Array:
		push_error(
			"[MemoryManager] Invalid messages array."
		)

		return


	for entry in saved_messages:

		if not entry is Dictionary:
			continue


		if not entry.has("role"):
			continue


		if not entry.has("content"):
			continue


		messages.append({
			"role": str(
				entry["role"]
			),

			"content": str(
				entry["content"]
			)
		})


	# Protect against an unexpectedly huge file.
	while messages.size() > MAX_STORED_MESSAGES:
		messages.pop_front()


	print(
		"[MemoryManager] Loaded ",
		messages.size(),
		" messages."
	)


# ============================================================
# CLEAR MEMORY
# ============================================================

func clear_memory() -> void:

	messages.clear()


	if FileAccess.file_exists(
		MEMORY_PATH
	):

		var global_path := ProjectSettings.globalize_path(
			MEMORY_PATH
		)

		DirAccess.remove_absolute(
			global_path
		)


	print(
		"[MemoryManager] Memory cleared."
	)


# ============================================================
# GET MEMORY COUNT
# ============================================================

func get_memory_count() -> int:
	return messages.size()
