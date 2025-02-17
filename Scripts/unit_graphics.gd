class_name UnitGraphics extends Control

var max_health_width : float
const our_scene : Resource = preload("res://Scenes/unit.tscn")

static func create() -> UnitGraphics:
	var ret_val : UnitGraphics = our_scene.instantiate()
	return ret_val

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	max_health_width = (find_child("Blood Background") as ColorRect).size.x

func set_unit_name(n : String) -> void:
	(find_child("Name") as Label).text = n

func set_health(current : float, max_health : float) -> void:
	(find_child("Health") as ColorRect).size.x = max_health_width * current / max_health
	(find_child("HealthText") as Label).text = str(max(1,round(current))) + "/" + str(round(max_health))
