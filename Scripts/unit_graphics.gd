class_name UnitGraphics extends Control

var max_health_width : float
var shield_bar : ColorRect
const our_scene : Resource = preload("res://Scenes/unit.tscn")

var attack_list : Array[UnitGraphics]
var action_buttons : Array[Button]
var attack_buttons : Array[Button]

static func create(unit_stats : UnitStats) -> UnitGraphics:
	var ret_val : UnitGraphics = our_scene.instantiate()
	(ret_val.find_child("HealthBar") as Control).tooltip_text = unit_stats.create_tooltip()
	var texture : Texture2D = unit_stats.get_texture()
	if texture != null:
		var sprite : Sprite2D = ret_val.find_child("Sprite2D") as Sprite2D
		sprite.texture = texture
		sprite.scale = Vector2(.678, .678)
	return ret_val

func _ready() -> void:
	max_health_width = (find_child("Blood Background") as ColorRect).size.x
	shield_bar = (find_child("Shield") as ColorRect)

func calculate_offset(index : int, c : int, r : float) -> float:
	if c == 1:
		return 0
	return lerpf(-r, r, float(index) / float(c - 1))

func _draw() -> void:
	const half_unit_graphic_height : float = 16.0
	for target : UnitGraphics in attack_list:
		var target_pos : Vector2 = Vector2(0, 16 + half_unit_graphic_height / 2) + target.global_position - self.global_position
		draw_line(Vector2(32, 16), target_pos, Color.RED, 4)

func set_unit_name(n : String) -> void:
	(find_child("Name") as Label).text = n

func set_health(unit : UnitStats) -> void:
	var health_rect : ColorRect = find_child("Health") as ColorRect
	var health_text : Label = find_child("HealthText") as Label
	if unit.is_alive():
		var magic_shield : float = unit.get_magic_shield()
		health_rect.show()
		health_rect.size.x = max_health_width * unit.current_health / unit.max_health
		health_text.text = str(max(1,round(unit.current_health))) + "/" + str(round(unit.max_health))
		if magic_shield > 0:
			shield_bar.show()
			health_text.text += " +" + str(max(1, round(magic_shield)))
		else:
			shield_bar.hide()
	else:
		shield_bar.hide()
		health_rect.hide()
		health_text.text = "DEAD" if unit.side == UnitStats.Side.COMPUTER else "defeated"

func add_draw_action(attack : AttackStats, target_stats : UnitStats, hover_callback : Callable, click_callback : Callable) -> void:
	action_buttons.append(create_button(false, attack, target_stats, hover_callback, click_callback))
	
func add_draw_attack(target_graphics : UnitGraphics, attack : AttackStats, target_stats : UnitStats, hover_callback : Callable, click_callback : Callable) -> void:
	if !attack_list.has(target_graphics):
		attack_list.append(target_graphics)
	target_graphics.activate_attack_button(hover_callback, click_callback, attack, target_stats)
	queue_redraw()
		
func activate_attack_button(hover_callback : Callable, click_callback : Callable, attack : AttackStats, target_stats : UnitStats) -> void:
	attack_buttons.append(create_button(true, attack, target_stats, hover_callback, click_callback))

func clean_up_human_UX() -> void:
	attack_list.clear()
	for button : Button in attack_buttons:
		find_child("AttackBox").remove_child(button)
		button.queue_free()
	attack_buttons.clear()
	for button : Button in action_buttons:
		find_child("ActionBox").remove_child(button)
		button.queue_free()
	action_buttons.clear()
	queue_redraw()

func create_button(is_attack : bool, attack : AttackStats, target_stats : UnitStats, hover_callback : Callable, click_callback : Callable) -> Button:
	var new_button : Button = Button.new()
	new_button.text = attack.attack_name
	new_button.mouse_entered.connect(hover_callback.bind(true))
	new_button.mouse_exited.connect(hover_callback.bind(false))
	new_button.pressed.connect(click_callback)
	new_button.tooltip_text = attack.generate_tooltip(target_stats)
	# TODO: Consult _make_custom_tooltip to see if we can make this look better
	if is_attack:
		new_button.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
		find_child("AttackBox").add_child(new_button)
	else:
		new_button.size_flags_horizontal = Control.SIZE_SHRINK_END
		find_child("ActionBox").add_child(new_button)
	return new_button
