class_name UnitGraphics extends Control

var max_health_width : float
const our_scene : Resource = preload("res://Scenes/unit.tscn")

static func create() -> UnitGraphics:
	var ret_val : UnitGraphics = our_scene.instantiate()
	return ret_val

func _ready() -> void:
	max_health_width = (find_child("Blood Background") as ColorRect).size.x

func calculate_offset(index : int, c : int, r : float) -> float:
	if c == 1:
		return 0
	return lerpf(-r, r, float(index) / float(c - 1))

func _draw() -> void:
	const half_unit_graphic_height : float = 16.0
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
		var target_pos : Vector2 = Vector2(0, 16 + calculate_offset(tcount, attack_target_count[target], half_unit_graphic_height)) + target.global_position - self.global_position
		draw_line(Vector2(32, 16), target_pos, Color.RED, 4)

func set_unit_name(n : String) -> void:
	(find_child("Name") as Label).text = n

func set_health(unit : UnitStats) -> void:
	var health_rect : ColorRect = find_child("Health") as ColorRect
	var health_text : Label = find_child("HealthText") as Label
	if unit.is_alive():
		health_rect.show()
		health_rect.size.x = max_health_width * unit.current_health / unit.max_health
		health_text.text = str(max(1,round(unit.current_health))) + "/" + str(round(unit.max_health))
	else:
		health_rect.hide()
		health_text.text = "DEAD"

var attack_list : Array
func add_draw_attack(target : UnitGraphics, attack : AttackStats, hover_callback : Callable, click_callback : Callable) -> void:
	attack_list.append([target, attack])
	target.activate_attack_button(hover_callback, click_callback, attack)
	queue_redraw()

func add_draw_action(attack : AttackStats, hover_callback : Callable, click_callback : Callable) -> void:
	activate_action_button(hover_callback, click_callback, attack)

func clean_up_human_UX() -> void:
	attack_list.clear()
	for button : Button in attack_buttons:
		remove_child(button)
		button.queue_free()
	attack_buttons.clear()
	for button : Button in action_buttons:
		remove_child(button)
		button.queue_free()
	action_buttons.clear()
	queue_redraw()

func create_button(pos : Vector2, text : String, hover_callback : Callable, click_callback : Callable) -> Button:
	var new_button : Button = Button.new()
	new_button.position = pos
	new_button.text = text
	new_button.mouse_entered.connect(hover_callback.bind(true))
	new_button.mouse_exited.connect(hover_callback.bind(false))
	new_button.pressed.connect(click_callback)
	add_child(new_button)
	return new_button

var action_buttons : Array
func activate_action_button(hover_callback : Callable, click_callback : Callable, attack : AttackStats) -> void:
	const half_unit_graphic_height : float = 16.0
	var base_pos : Vector2 = Vector2(-64, 0)
	if !action_buttons.is_empty():
		var count : int = 0
		for existing_button : Button in action_buttons:
			existing_button.position = base_pos + Vector2(0, calculate_offset(count, action_buttons.size() + 1, half_unit_graphic_height))
			count += 1

		var pos : Vector2 = base_pos + Vector2(0, calculate_offset(count, action_buttons.size() + 1, half_unit_graphic_height))
		action_buttons.append(create_button(pos, attack.attack_name, hover_callback, click_callback))
	else:
		action_buttons.append(create_button(base_pos, attack.attack_name, hover_callback, click_callback))
		
var attack_buttons : Array
func activate_attack_button(hover_callback : Callable, click_callback : Callable, attack : AttackStats) -> void:
	const half_unit_graphic_height : float = 16.0
	var base_pos : Vector2 = Vector2(64, 0)
	if !attack_buttons.is_empty():
		var count : int = 0
		for existing_button : Button in attack_buttons:
			existing_button.position = base_pos + Vector2(0, calculate_offset(count, attack_buttons.size() + 1, half_unit_graphic_height))
			count += 1

		var pos : Vector2 = base_pos + Vector2(0, calculate_offset(count, attack_buttons.size() + 1, half_unit_graphic_height))
		attack_buttons.append(create_button(pos, attack.attack_name, hover_callback, click_callback))
	else:
		attack_buttons.append(create_button(base_pos, attack.attack_name, hover_callback, click_callback))
