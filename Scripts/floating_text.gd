class_name FloatingText extends Control

const our_scene : Resource = preload("res://Scenes/floating_text.tscn")
const SPEED : float = 50

var lifetime : float
var age : float = 0
var dead : bool = false
var dir : Vector2

static func create(_text : String, color : Color, _lifetime : float) -> FloatingText:
	var ret_val : FloatingText = our_scene.instantiate()
	var label : Label = ret_val.find_child("Label") as Label
	label.text = _text
	label.label_settings.font_color = color
	ret_val.lifetime = _lifetime
	ret_val.dir = Vector2(RandomNumberGenerator.new().randf_range(-1, 1), -1).normalized()
	return ret_val

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if dead:
		return
		
	age += delta
	if age > lifetime:
		dead = true
		queue_free()
		return
	
	position += dir * SPEED * delta

	var age_as_fraction = age / lifetime
	var alpha : float = 1.0 - (age_as_fraction * age_as_fraction)
	(find_child("Label") as Label).modulate = Color(1, 1, 1, alpha)
