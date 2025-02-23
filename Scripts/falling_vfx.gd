class_name FallingVFX extends Control

const our_scene : Resource = preload("res://Scenes/falling_vfx.tscn")
const SPEED : float = 25

var lifetime : float
var age : float = 0
var dead : bool = false
var dir : Vector2

static func create(texture : Texture, _lifetime : float) -> FallingVFX:
	var ret_val : FallingVFX = our_scene.instantiate()
	var sprite : Sprite2D = ret_val.find_child("Sprite2D") as Sprite2D
	sprite.texture = texture
	ret_val.lifetime = _lifetime
	ret_val.dir = Vector2(RandomNumberGenerator.new().randf_range(-1, 1), 1).normalized()
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
	(find_child("Sprite2D") as Sprite2D).modulate = Color(1, 1, 1, alpha)
