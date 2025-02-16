extends Control

var max_health_width : float

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	max_health_width = (find_child("Blood Background") as ColorRect).size.x

func set_unit_name(n : String) -> void:
	(find_child("Name") as Label).text = n

func set_health(current : float, max : float) -> void:
	(find_child("Health") as ColorRect).size.x = max_health_width * current / max
	(find_child("HealthText") as Label).text = str(max(1,round(current))) + "/" + str(round(max))

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
