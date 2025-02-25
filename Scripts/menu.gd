extends StateMachineState

var snap_mp3 : AudioStreamMP3 = preload("res://Sounds/SnapCase.mp3")
var switch_wav : AudioStreamWAV = preload("res://Sounds/Switch.wav")
var button_player : AudioStreamPlayer

# TODO: Move this to a global script, shouldn't live off in menu.gd
func _ready() -> void:
	button_player = find_child("ButtonPlayer") as AudioStreamPlayer
	assert(button_player)
	_connect_buttons(get_tree().root)
	get_tree().node_added.connect(Callable(self, "_on_node_added"))
func _connect_buttons(node : Node) -> void:
	for child : Node in node.get_children():
		_on_node_added(child)
		_connect_buttons(child)
func _on_node_added(node : Node) -> void:
	if node is Button:
		var button : BaseButton = node as BaseButton
		button.mouse_entered.connect(Callable(self, "_play_on_enter_sound"))
		button.mouse_exited.connect(Callable(self, "_play_on_exit_sound"))
		button.button_up.connect(Callable(self, "_play_on_button_up_sound"))
func _play_on_enter_sound() -> void:
	button_player.stream = switch_wav
	button_player.volume_db = -9
	button_player.play()
	pass
func _play_on_exit_sound() -> void:
	#button_player.stream = switch_wav
	#button_player.volume_db = -9
	#button_player.play()
	pass
func _play_on_button_up_sound() -> void:
	button_player.stream = snap_mp3
	button_player.volume_db = -9
	button_player.play()

func _on_button_button_up() -> void:
	our_state_machine.switch_state("Game")

func _on_credits_button_up() -> void:
	our_state_machine.switch_state("Credits")
