extends Node
class_name LMStudio

# ============================================================
# LM STUDIO
# Global is the single source of truth for configuration.
# The actual HTTP/API work remains here.
# ============================================================

signal response_received(text: String)
signal request_failed(error: String)
signal request_started()
signal request_finished()

var http: HTTPRequest
var busy: bool = false
var conversation_history: Array = []


func _ready() -> void:
	print("================================")
	print("LM Studio Node starting...")
	print("Host: ", Global.lm_host)
	print("Port: ", Global.lm_port)
	print("Model: ", Global.lm_model)
	print("================================")

	http = HTTPRequest.new()
	http.name = "HTTPRequest"
	http.timeout = Global.lm_timeout

	add_child(http)
	http.request_completed.connect(_on_request_completed)

	print("LM Studio HTTPRequest ready.")


# ============================================================
# Convenience properties
# These read Global every time they are accessed, so the
# Settings window can change them while the application runs.
# ============================================================

var host: String:
	get:
		return Global.lm_host

var port: int:
	get:
		return Global.lm_port

var chat_endpoint: String:
	get:
		return Global.lm_chat_endpoint

var model: String:
	get:
		return Global.lm_model

var timeout: float:
	get:
		return Global.lm_timeout

var username: String:
	get:
		return Global.username

var charname: String:
	get:
		return Global.charname


# ============================================================
# Public API
# ============================================================

func send_message(message: String) -> void:
	if busy:
		push_warning("LM Studio request already running.")
		return

	busy = true
	request_started.emit()

	print("")
	print("========== LM STUDIO REQUEST ==========")
	print("Message:")
	print(message)
	print("=======================================")

	var url := "http://%s:%d%s" % [
		Global.lm_host,
		Global.lm_port,
		Global.lm_chat_endpoint
	]

	print("URL: ", url)

	var headers := PackedStringArray([
		"Content-Type: application/json"
	])

	conversation_history.append({
		"role": "user",
		"content": message
	})

	# IMPORTANT:
	# Read Global.prompt_main here, when the request is created.
	# This means a prompt edited in Settings is used immediately
	# by the next message without restarting LMStudio.
	var messages: Array = [
		{
			"role": "system",
			"content": Global.prompt_main
		}
	]

	messages.append_array(conversation_history)

	var body := {
		"model": Global.lm_model,
		"messages": messages,
		"temperature": Global.lm_temperature,
		"stream": false
	}

	var json_body := JSON.stringify(body)

	print("System prompt currently being sent:")
	print(Global.prompt_main)
	print("JSON:")
	print(json_body)

	# Keep HTTPRequest's timeout synchronized with the current setting.
	http.timeout = Global.lm_timeout

	var error := http.request(
		url,
		headers,
		HTTPClient.METHOD_POST,
		json_body
	)

	if error != OK:
		busy = false

		var error_text := "HTTPRequest failed to start: %s" % error_string(error)

		push_error(error_text)
		request_failed.emit(error_text)
		request_finished.emit()

		return

	print("HTTPRequest successfully started.")


# ============================================================
# HTTP response
# ============================================================

func _on_request_completed(
	result: int,
	response_code: int,
	headers: PackedStringArray,
	body: PackedByteArray
) -> void:

	print("")
	print("========== LM STUDIO RESPONSE ==========")

	busy = false

	print("Result: ", result)
	print("HTTP response code: ", response_code)
	print("Body size: ", body.size())

	# ----------------------------------------
	# Network-level failure
	# ----------------------------------------

	if result != HTTPRequest.RESULT_SUCCESS:
		var error_text := "HTTP request failed. Result: %s" % result

		push_error(error_text)

		request_failed.emit(error_text)
		request_finished.emit()

		return

	# ----------------------------------------
	# HTTP-level failure
	# ----------------------------------------

	if response_code < 200 or response_code >= 300:
		var error_body := body.get_string_from_utf8()

		print("Server returned error:")
		print(error_body)

		var error_text := "LM Studio returned HTTP %d" % response_code

		push_error(error_text)

		request_failed.emit(error_text)
		request_finished.emit()

		return

	# ----------------------------------------
	# Parse response
	# ----------------------------------------

	var raw_text := body.get_string_from_utf8()

	print("Raw response:")
	print(raw_text)

	var json = JSON.parse_string(raw_text)

	if json == null:
		var error_text := "Could not parse LM Studio JSON response."

		push_error(error_text)

		request_failed.emit(error_text)
		request_finished.emit()

		return

	# ----------------------------------------
	# OpenAI-compatible response
	# ----------------------------------------

	if not json.has("choices"):
		var error_text := "Response does not contain 'choices'."

		push_error(error_text)

		request_failed.emit(error_text)
		request_finished.emit()

		return

	if json["choices"].is_empty():
		var error_text := "LM Studio returned an empty choices array."

		push_error(error_text)

		request_failed.emit(error_text)
		request_finished.emit()

		return

	var choice = json["choices"][0]

	if not choice.has("message"):
		var error_text := "Response choice does not contain 'message'."

		push_error(error_text)

		request_failed.emit(error_text)
		request_finished.emit()

		return

	var response_message = choice["message"]

	if not response_message.has("content"):
		var error_text := "Response message does not contain 'content'."

		push_error(error_text)

		request_failed.emit(error_text)
		request_finished.emit()

		return

	var response_text: String = response_message["content"]

	print("LM Studio says:")
	print(response_text)

	# Add assistant response to conversation history
	conversation_history.append({
		"role": "assistant",
		"content": response_text
	})

	print("========================================")

	response_received.emit(response_text)
	request_finished.emit()


# ============================================================
# Cancel
# ============================================================

func cancel_request() -> void:
	if not busy:
		print("No LM Studio request is running.")
		return

	print("Cancelling LM Studio request...")

	http.cancel_request()

	busy = false

	request_finished.emit()


# ============================================================
# Connection test
# ============================================================

func test_connection() -> void:
	if busy:
		push_warning("Cannot test connection while request is running.")
		return

	var url := "http://%s:%d/v1/models" % [
		Global.lm_host,
		Global.lm_port
	]

	print("")
	print("========== LM STUDIO CONNECTION TEST ==========")
	print("Testing: ", url)

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
			"Could not start connection test: %s"
			% error_string(error)
		)

		return

	print("Connection test request started.")


# ============================================================
# Debug helper
# ============================================================

func print_config() -> void:
	print("")
	print("========== LM STUDIO CONFIG ==========")
	print("Host: ", Global.lm_host)
	print("Port: ", Global.lm_port)
	print("Model: ", Global.lm_model)
	print("Endpoint: ", Global.lm_chat_endpoint)
	print("Temperature: ", Global.lm_temperature)
	print("Prompt length: ", Global.prompt_main.length())
	print("Busy: ", busy)
	print("=======================================")
