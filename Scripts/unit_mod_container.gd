class_name UnitModContainer extends Control

var mod : UnitMod = null
var unit_mod_name_label : Label
var callback : Callable
var pressed : bool = false
var home : Vector2
var tween : Tween

func add_mod(_mod : UnitMod, functor : Callable) -> void:
	mod = _mod
	unit_mod_name_label.text = mod.get_mod_name()
	callback = functor

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	unit_mod_name_label = find_child("UnitModName") as Label
	call_deferred("get_home")

func return_home() -> void:
	tween = create_tween()
	tween.tween_property(self, "global_position", home, 1)

func get_home() -> void:
	home = global_position

func get_dist_from_home() -> float:
	return home.distance_to(global_position)

func _on_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if tween != null:
			tween.stop()
		var iemb : InputEventMouseButton = event as InputEventMouseButton
		if iemb.is_pressed():
			callback.bind(self, 0).call()
			pressed = true
		elif iemb.is_released():
			callback.bind(self, 1).call()
			pressed = false
	elif event is InputEventMouseMotion:
		if pressed:
			#var iemm : InputEventMouseMotion = event as InputEventMouseMotion
			callback.bind(self, 2).call()
