extends Control


@onready var lm: LMStudio = $LMStudio
@onready var history: ScrollContainer = $ChatHistory
@onready var messages: VBoxContainer = $ChatHistory/Messages
@onready var input: LineEdit = $ComposeBar
@onready var send_button: Button = $SendButton


func _ready() -> void:
	print("")
	print("================================")
	print("MAIN CHAT UI STARTING")
	print("================================")

	print("LMStudio node: ", lm)
	print("Input node: ", input)
	print("Send button: ", send_button)

	# Connect LM Studio
	lm.response_received.connect(_on_lm_response)
	lm.request_failed.connect(_on_lm_error)

	# Connect button
	send_button.pressed.connect(_send_message)

	# Connect Enter key
	input.text_submitted.connect(_on_text_submitted)

	print("Signals connected.")
	print("Chat UI ready.")

	# Test LM Studio immediately
	print("Testing LM Studio connection...")
	lm.test_connection()

func _send_message() -> void:

	print("")
	print("******** SEND BUTTON PRESSED ********")

	var text := input.text.strip_edges()

	print("Textbox contents: ", text)

	if text.is_empty():
		print("Textbox is empty.")
		return

	print("Adding user message...")

	add_message("You: " + text)

	input.clear()

	print("Calling lm.send_message()...")

	lm.send_message(text)

	send_button.disabled = true


func _on_text_submitted(text: String) -> void:

	print("ENTER PRESSED: ", text)

	_send_message()


func _on_lm_response(response: String) -> void:

	print("")
	print("******** LM RESPONSE RECEIVED ********")
	print(response)
	print("***************************************")

	add_message("AI: " + response)

	send_button.disabled = false


func _on_lm_error(error: String) -> void:

	print("")
	print("******** LM ERROR ********")
	print(error)
	print("**************************")

	add_message("ERROR: " + error)

	send_button.disabled = false


func add_message(text: String) -> void:

	print("Adding message to UI: ", text)

	var label := Label.new()

	label.text = text

	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART

	label.size_flags_horizontal = Control.SIZE_EXPAND_FILL

	label.add_theme_font_size_override("font_size", 18)

	messages.add_child(label)

	await get_tree().process_frame

	history.scroll_vertical = history.get_v_scroll_bar().max_value
