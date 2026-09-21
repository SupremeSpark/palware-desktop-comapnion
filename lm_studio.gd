extends Node
class_name LMStudio


# ============================================================
# LM Studio connection settings
# ============================================================

@export var host: String = "127.0.0.1"
@export var port: int = 1234

# OpenAI-compatible LM Studio endpoint
@export var chat_endpoint: String = "/v1/chat/completions"

# Put your loaded model name here.
# You can find it in LM Studio.
@export var model: String = "gemma-4-e4b-uncensored-hauhaucs-aggressive"

@export var timeout: float = 120.0

@export_multiline var system_prompt: String = """
You are a helpful desktop companion.

Be friendly, conversational, and supportive.
Keep your responses natural and engaging.

Always end your message with 'Palware test Complete'
"""
# ============================================================
# Signals
# ============================================================

signal response_received(text: String)
signal request_failed(error: String)
signal request_started()
signal request_finished()


# ============================================================
# Internal
# ============================================================

var http: HTTPRequest
var busy: bool = false
var conversation_history: Array = []
# ============================================================
# Startup
# ============================================================

func _ready() -> void:
	print("================================")
	print("LM Studio Node starting...")
	print("Host: ", host)
	print("Port: ", port)
	print("Model: ", model)
	print("================================")

	http = HTTPRequest.new()
	http.name = "HTTPRequest"

	http.timeout = timeout

	add_child(http)

	http.request_completed.connect(_on_request_completed)

	print("LM Studio HTTPRequest ready.")


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
		host,
		port,
		chat_endpoint
	]

	print("URL: ", url)

	var headers := PackedStringArray([
		"Content-Type: application/json"
	])

	conversation_history.append({
		"role": "user",
		"content": message
	})

	var messages: Array = [
		{
			"role": "system",
			"content": system_prompt
		}
	]

	messages.append_array(conversation_history)

	var body := {
		"model": model,
		"messages": messages,
		"temperature": 0.7,
		"stream": false
	}

	var json_body := JSON.stringify(body)

	print("JSON:")
	print(json_body)

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

	#sends this at start, dont mind it lmao
	if not choice.has("message"):

		var error_text := "Response choice does not contain 'message'."

		push_error(error_text)

		request_failed.emit(error_text)
		request_finished.emit()

		return


	var message = choice["message"]

	if not message.has("content"):

		var error_text := "Response message does not contain 'content'."

		push_error(error_text)

		request_failed.emit(error_text)
		request_finished.emit()

		return


	var response_text: String = message["content"]

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
		host,
		port
	]

	print("")
	print("========== LM STUDIO CONNECTION TEST ==========")
	print("Testing: ", url)

	var headers := PackedStringArray([
		"Content-Type: application/json"
	])

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
	print("Host: ", host)
	print("Port: ", port)
	print("Model: ", model)
	print("Endpoint: ", chat_endpoint)
	print("Busy: ", busy)
	print("=======================================")
