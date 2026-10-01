extends Node
class_name LMStudio


# ============================================================
# SIGNALS
# ============================================================

signal response_received(text: String)
signal request_failed(error: String)
signal request_started()
signal request_finished()


# ============================================================
# INTERNAL STATE
# ============================================================

var http: HTTPRequest

var busy: bool = false


# The current user message waits here while LM Studio thinks.
#
# We only put it into permanent memory after a successful
# assistant response.
var pending_user_message: String = ""


# ============================================================
# READY
# ============================================================

func _ready() -> void:

	print(
		"================================"
	)

	print(
		"LM Studio Node starting..."
	)

	print(
		"Host: ",
		Global.lm_host
	)

	print(
		"Port: ",
		Global.lm_port
	)

	print(
		"Model: ",
		Global.lm_model
	)

	print(
		"================================"
	)


	http = HTTPRequest.new()

	http.name = "HTTPRequest"

	http.timeout = Global.lm_timeout

	add_child(http)

	http.request_completed.connect(
		_on_request_completed
	)


	print(
		"LM Studio HTTPRequest ready."
	)


# ============================================================
# SEND MESSAGE
# ============================================================

func send_message(
	message: String
) -> void:

	if busy:

		push_warning(
			"LM Studio request already running."
		)

		return


	var cleaned_message := message.strip_edges()


	if cleaned_message.is_empty():
		return


	busy = true

	pending_user_message = cleaned_message

	request_started.emit()


	print("")
	print(
		"========== LM STUDIO REQUEST =========="
	)

	print(
		"Message:"
	)

	print(
		cleaned_message
	)

	print(
		"======================================="
	)


	# ========================================================
	# URL
	# ========================================================

	var url := "http://%s:%d%s" % [
		Global.lm_host,
		Global.lm_port,
		Global.lm_chat_endpoint
	]


	print(
		"URL: ",
		url
	)


	# ========================================================
	# HEADERS
	# ========================================================

	var headers := PackedStringArray([
		"Content-Type: application/json"
	])


	# ========================================================
	# BUILD MESSAGE CONTEXT
	# ========================================================

	var messages: Array = []


	# --------------------------------------------------------
	# SYSTEM PROMPT
	# --------------------------------------------------------

	messages.append({
		"role": "system",
		"content": Global.prompt_main
	})


	# --------------------------------------------------------
	# IMMEDIATE MEMORY
	# --------------------------------------------------------

	if Global.memory_enabled:

		var recalled_messages := (
			MemoryManager.get_recent_messages(
				Global.raw_memory_recall
			)
		)


		messages.append_array(
			recalled_messages
		)


		print(
			"[Memory] Recalling ",
			recalled_messages.size(),
			" previous messages."
		)

	else:

		print(
			"[Memory] Disabled."
		)


	# --------------------------------------------------------
	# CURRENT USER MESSAGE
	# --------------------------------------------------------
	#
	# This is NOT retrieved from memory.
	# It is the message currently being sent.
	# --------------------------------------------------------

	messages.append({
		"role": "user",
		"content": cleaned_message
	})


	# ========================================================
	# BUILD API BODY
	# ========================================================

	var body := {
		"model": Global.lm_model,

		"messages": messages,

		"temperature": Global.lm_temperature,

		"stream": false
	}


	var json_body := JSON.stringify(
		body
	)


	print(
		"System prompt currently being sent:"
	)

	print(
		Global.prompt_main
	)

	print(
		"Messages being sent: ",
		messages.size()
	)


	# ========================================================
	# SEND REQUEST
	# ========================================================

	http.timeout = Global.lm_timeout


	var error := http.request(
		url,
		headers,
		HTTPClient.METHOD_POST,
		json_body
	)


	if error != OK:

		busy = false

		pending_user_message = ""


		var error_text := (
			"HTTPRequest failed to start: "
			+ error_string(error)
		)


		push_error(
			error_text
		)


		request_failed.emit(
			error_text
		)

		request_finished.emit()

		return


	print(
		"HTTPRequest successfully started."
	)


# ============================================================
# RESPONSE
# ============================================================

func _on_request_completed(
	result: int,
	response_code: int,
	headers: PackedStringArray,
	body: PackedByteArray
) -> void:


	print("")
	print(
		"========== LM STUDIO RESPONSE =========="
	)


	busy = false


	print(
		"Result: ",
		result
	)

	print(
		"HTTP response code: ",
		response_code
	)


	# ========================================================
	# NETWORK FAILURE
	# ========================================================

	if result != HTTPRequest.RESULT_SUCCESS:

		var error_text := (
			"HTTP request failed. Result: "
			+ str(result)
		)


		push_error(
			error_text
		)


		pending_user_message = ""


		request_failed.emit(
			error_text
		)

		request_finished.emit()

		return


	# ========================================================
	# HTTP FAILURE
	# ========================================================

	if response_code < 200 or response_code >= 300:

		var error_body := (
			body.get_string_from_utf8()
		)


		print(
			"Server returned error:"
		)

		print(
			error_body
		)


		var error_text := (
			"LM Studio returned HTTP "
			+ str(response_code)
		)


		push_error(
			error_text
		)


		pending_user_message = ""


		request_failed.emit(
			error_text
		)

		request_finished.emit()

		return


	# ========================================================
	# PARSE JSON
	# ========================================================

	var raw_text := (
		body.get_string_from_utf8()
	)


	print(
		"Raw response:"
	)

	print(
		raw_text
	)


	var json = JSON.parse_string(
		raw_text
	)


	if json == null:

		var error_text := (
			"Could not parse LM Studio JSON response."
		)


		push_error(
			error_text
		)


		pending_user_message = ""


		request_failed.emit(
			error_text
		)

		request_finished.emit()

		return


	# ========================================================
	# FIND CHOICES
	# ========================================================

	if not json.has("choices"):

		var error_text := (
			"Response does not contain 'choices'."
		)


		push_error(
			error_text
		)


		pending_user_message = ""


		request_failed.emit(
			error_text
		)

		request_finished.emit()

		return


	if json["choices"].is_empty():

		var error_text := (
			"LM Studio returned an empty choices array."
		)


		push_error(
			error_text
		)


		pending_user_message = ""


		request_failed.emit(
			error_text
		)

		request_finished.emit()

		return


	# ========================================================
	# GET MESSAGE
	# ========================================================

	var choice = json["choices"][0]


	if not choice.has("message"):

		var error_text := (
			"Response choice does not contain 'message'."
		)


		push_error(
			error_text
		)


		pending_user_message = ""


		request_failed.emit(
			error_text
		)

		request_finished.emit()

		return


	var response_message = choice["message"]


	if not response_message.has("content"):

		var error_text := (
			"Response message does not contain 'content'."
		)


		push_error(
			error_text
		)


		pending_user_message = ""


		request_failed.emit(
			error_text
		)

		request_finished.emit()

		return


	var response_text: String = (
		response_message["content"]
	)


	print(
		"LM Studio says:"
	)

	print(
		response_text
	)


	# ========================================================
	# SAVE SUCCESSFUL EXCHANGE
	# ========================================================
	#
	# We save BOTH messages together only after LM Studio
	# successfully responds.
	#
	# This prevents failed requests from becoming orphaned
	# user messages.
	# ========================================================

	if Global.memory_enabled:

		MemoryManager.add_message(
			"user",
			pending_user_message
		)


		MemoryManager.add_message(
			"assistant",
			response_text
		)


		MemoryManager.save_memory()


		print(
			"[Memory] Saved exchange. Total messages: ",
			MemoryManager.get_memory_count()
		)


	# Clear temporary message.
	pending_user_message = ""


	print(
		"========================================"
	)


	# ========================================================
	# NOTIFY CHATBOX
	# ========================================================

	response_received.emit(
		response_text
	)

	request_finished.emit()


# ============================================================
# CANCEL REQUEST
# ============================================================

func cancel_request() -> void:

	if not busy:

		print(
			"No LM Studio request is running."
		)

		return


	print(
		"Cancelling LM Studio request..."
	)


	http.cancel_request()


	busy = false

	pending_user_message = ""


	request_finished.emit()


# ============================================================
# CONNECTION TEST
# ============================================================

func test_connection() -> void:

	if busy:

		push_warning(
			"Cannot test connection while request is running."
		)

		return


	var url := "http://%s:%d/v1/models" % [
		Global.lm_host,
		Global.lm_port
	]


	print("")
	print(
		"========== LM STUDIO CONNECTION TEST =========="
	)

	print(
		"Testing: ",
		url
	)


	var headers := PackedStringArray([
		"Content-Type: application/json"
	])


	http.timeout = Global.lm_timeout


	var error := http.request(
		url,
		headers,
		HTTPClient.METHOD_GET
	)


	if error != OK:

		push_error(
			"Could not start connection test: "
			+ error_string(error)
		)

		return


	print(
		"Connection test request started."
	)


# ============================================================
# DEBUG
# ============================================================

func print_config() -> void:

	print("")
	print(
		"========== LM STUDIO CONFIG =========="
	)

	print(
		"Host: ",
		Global.lm_host
	)

	print(
		"Port: ",
		Global.lm_port
	)

	print(
		"Model: ",
		Global.lm_model
	)

	print(
		"Endpoint: ",
		Global.lm_chat_endpoint
	)

	print(
		"Temperature: ",
		Global.lm_temperature
	)

	print(
		"Prompt length: ",
		Global.prompt_main.length()
	)

	print(
		"Memory enabled: ",
		Global.memory_enabled
	)

	print(
		"Raw memory recall: ",
		Global.raw_memory_recall
	)

	print(
		"Stored memory messages: ",
		MemoryManager.get_memory_count()
	)

	print(
		"Busy: ",
		busy
	)

	print(
		"======================================="
	)
