class_name UnitGraphics extends Control

var max_health_width : float
var shield_bar : ColorRect
const our_scene : Resource = preload("res://Scenes/unit.tscn")
const red_arrow_line_texture : Texture = preload("res://Art/RedPointerPath.png")
const green_arrow_line_texture : Texture = preload("res://Art/GreenPointerPath.png")
const scrolling_line_shader : Shader = preload("res://Art/ScrollingRedArrow.gdshader")
var shader_material : ShaderMaterial = ShaderMaterial.new()

var attack_list : Array[UnitGraphics]
var action_buttons : Array[Button]
var attack_buttons : Array[Button]

static func create(unit_stats : UnitStats, game : Game) -> UnitGraphics:
	var ret_val : UnitGraphics = our_scene.instantiate()
	var healthbar_control : Control = ret_val.find_child("HealthBar") as Control
	healthbar_control.mouse_entered.connect(Callable(game, "show_unit_tooltip").bind(unit_stats.id, true))
	healthbar_control.mouse_exited.connect(Callable(game, "show_unit_tooltip").bind(unit_stats.id, false))
	var texture : Texture2D = unit_stats.get_texture()
	if texture != null:
		var sprite : Sprite2D = ret_val.find_child("Sprite2D") as Sprite2D
		sprite.texture = texture
		if unit_stats.icon == UnitStats.Icon.Chronotyrant:
			sprite.scale = Vector2(.0986, .0986)
		else:
			sprite.scale = Vector2(.678, .678)
	return ret_val

func _ready() -> void:
	max_health_width = (find_child("Blood Background") as ColorRect).size.x
	shield_bar = (find_child("Shield") as ColorRect)
	shader_material.shader = scrolling_line_shader

func calculate_offset(index : int, c : int, r : float) -> float:
	if c == 1:
		return 0
	return lerpf(-r, r, float(index) / float(c - 1))

static func create_curve(from : Vector2, mid : Vector2, to: Vector2, count : int) -> Array[Vector2]:
	var ret_val : Array[Vector2]
	ret_val.append(from)
	for i in range(1, count - 2):
		var frac : float = float(i) / float(count - 1)
		var start : Vector2 = lerp(from, mid, frac)
		var end : Vector2 = lerp(mid, to, frac)
		var point : Vector2 = lerp(start, end, frac)
		ret_val.append(point)
	ret_val.append(to)
	return ret_val

func create_line(from : Vector2, to : Vector2, friendly : bool) -> Line2D:
	var mid : Vector2 = Vector2((from.x + to.x)/ 2, to.y)
	var points : Array[Vector2] = create_curve(from, mid, to, 24)
	var line : Line2D = Line2D.new()
	line.material = shader_material
	line.texture = green_arrow_line_texture if friendly else red_arrow_line_texture
	line.texture_mode = Line2D.LINE_TEXTURE_TILE
	line.texture_repeat = CanvasItem.TEXTURE_REPEAT_ENABLED
	line.antialiased = true
	line.add_point(from)
	for i : int in range(0, points.size()):
		line.add_point(points[i])
	line.add_point(to)
	return line

var attack_lines : Array[Line2D]
func add_attack_lines() -> void:
	const half_unit_graphic_height : float = 16.0
	for target : UnitGraphics in attack_list:
		var target_pos : Vector2 = Vector2(0, 16 + half_unit_graphic_height / 2) + target.global_position - self.global_position
		var friendly : bool = false
		if target_pos.x < 0:
			target_pos.x += 48
			friendly = true
		var line : Line2D = create_line(Vector2(48, 16), target_pos, friendly)
		add_child(line)
		attack_lines.append(line)

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
	add_attack_lines()
		
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
	for al : Line2D in attack_lines:
		al.queue_free()
	attack_lines.clear()

func create_button(is_attack : bool, attack : AttackStats, _target_stats : UnitStats, hover_callback : Callable, click_callback : Callable) -> Button:
	var new_button : Button = Button.new()
	new_button.text = attack.attack_name
	new_button.mouse_entered.connect(hover_callback.bind(true))
	new_button.mouse_exited.connect(hover_callback.bind(false))
	new_button.pressed.connect(click_callback)
	if is_attack:
		if !attack.acts_on_allies:
			if _target_stats.calculate_damage_from_attack(attack) > (_target_stats.current_health + _target_stats.magic_shield):
				new_button.add_theme_color_override("font_color", Color.ORANGE_RED)
				new_button.add_theme_color_override("font_hover_color", Color.RED)
		new_button.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
		find_child("AttackBox").add_child(new_button)
	else:
		new_button.size_flags_horizontal = Control.SIZE_SHRINK_END
		find_child("ActionBox").add_child(new_button)
	return new_button
