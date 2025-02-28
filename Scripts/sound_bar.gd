extends Node

const snap_mp3 : AudioStreamMP3 = preload("res://Sounds/SnapCase.mp3")
const switch_wav : AudioStreamWAV = preload("res://Sounds/Switch.wav")
var button_player : AudioStreamPlayer = AudioStreamPlayer.new()

func _ready() -> void:
	button_player.bus = "UI"
	button_player.process_mode = Node.PROCESS_MODE_ALWAYS
	var tree = get_tree()
	tree.root.add_child.call_deferred(button_player)
	_connect_buttons(tree.root)
	tree.node_added.connect(Callable(self, "_on_node_added"))

func play_button_hover_start() -> void:
	button_player.stream = switch_wav
	button_player.volume_db = -9
	button_player.play()

func play_button_hover_end() -> void:
	#button_player.stream = switch_wav
	#button_player.volume_db = -9
	#button_player.play()
	pass

func play_button_up() -> void:
	button_player.stream = snap_mp3
	button_player.volume_db = -9
	button_player.play()
	
func _connect_buttons(node : Node) -> void:
	for child : Node in node.get_children():
		_on_node_added(child)
		_connect_buttons(child)

func _on_node_added(node : Node) -> void:
	if node is Button:
		var button : BaseButton = node as BaseButton
		Callable()
		button.mouse_entered.connect(Callable(self, "play_button_hover_start"))
		button.mouse_exited.connect(Callable(self, "play_button_hover_end"))
		button.button_up.connect(Callable(self, "play_button_up"))
