class_name UnitGraphics extends Control

var max_health_width : float
const our_scene : Resource = preload("res://Scenes/unit.tscn")

static func create() -> UnitGraphics:
	var ret_val : UnitGraphics = our_scene.instantiate()
	return ret_val

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	max_health_width = (find_child("Blood Background") as ColorRect).size.x

func _process(_delta: float) -> void:
	if attack_list.is_empty() && action_list.is_empty():
		return
	
	queue_redraw()

func calculate_offset(index : int, c : int, range : float) -> float:
	if c == 1:
		return 0
	return lerpf(-range, range, float(index) / float(c - 1))

func _draw() -> void:
	var default_font = ThemeDB.fallback_font
	var default_font_size = ThemeDB.fallback_font_size
	var count : int = 0
	const half_unit_graphic_height : float = 16.0
	for action : AttackStats in action_list:
		var pos : Vector2 = Vector2(-64, calculate_offset(count, action_list.size(), half_unit_graphic_height))
		count += 1
		draw_circle(Vector2.ZERO + pos, 32, Color.GREEN)
		draw_string(default_font, pos, action.attack_name, HORIZONTAL_ALIGNMENT_CENTER, -1, default_font_size, Color.BLACK)
	var attack_target_count : Dictionary # <UnitGraphics, int>
	for attack : Array in attack_list:
		var target : UnitGraphics = attack[0] as UnitGraphics
		if attack_target_count.has(target):
			attack_target_count[target] += 1
		else:
			attack_target_count[target] = 1
	var attack_target_placed : Dictionary # <UnitGraphics, int>
	for attack : Array in attack_list:
		var target : UnitGraphics = attack[0] as UnitGraphics
		var tcount : int = 0
		if attack_target_placed.has(target):
			tcount = attack_target_placed[target]
			attack_target_placed[target] += 1
		else:
			attack_target_placed[target] = 1
		var target_pos : Vector2 = Vector2(16, 16 + calculate_offset(tcount, attack_target_count[target], half_unit_graphic_height)) + target.global_position - self.global_position
		var pos : Vector2 = target_pos + Vector2(48, 0)
		draw_line(Vector2.ZERO, target_pos, Color.RED, 4)
		draw_string(default_font, pos, attack[1].attack_name, HORIZONTAL_ALIGNMENT_CENTER, -1, default_font_size, Color.RED)

func set_unit_name(n : String) -> void:
	(find_child("Name") as Label).text = n

func set_health(current : float, max_health : float) -> void:
	(find_child("Health") as ColorRect).size.x = max_health_width * current / max_health
	(find_child("HealthText") as Label).text = str(max(1,round(current))) + "/" + str(round(max_health))

var attack_list : Array
func add_draw_attack(target : UnitGraphics, attack : AttackStats) -> void:
	attack_list.append([target, attack])

var action_list : Array[AttackStats]
func add_draw_action(attack : AttackStats) -> void:
	action_list.append(attack)
