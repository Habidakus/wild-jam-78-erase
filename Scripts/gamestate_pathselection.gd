class_name SMSPath extends StateMachineState

const color_dead_node : Color = Color(0.5, 0.5, 0.5, 1)
const color_live_node : Color = Color(Color.WHITE, 0.5)
const color_current_node : Color = Color(Color.GREEN, 0.5)
const color_past_path : Color = Color(Color.DARK_GREEN, 0.66)
const color_mouse_node : Color = Color(Color.GREEN_YELLOW, 1)

const texture_green_dot : Texture = preload("res://Art/DotPathGreenInner.png")
const texture_full_dot : Texture = preload("res://Art/DotPathFilled.png")
const texture_hollow_dot : Texture = preload("res://Art/DotPathEmpty.png")
const texture_x_path : Texture = preload("res://Art/XPath.png")

const path_graphic_scene : Resource = preload("res://Scenes/path_encounter.tscn")

#var path_logic_node : PathLogicNode = null
var graphic_nodes : Dictionary # <PathEncounterStat, Control>
#var draw_lines : Array
var path_lines : Array[Line2D]
var game : Game = null

func init(_game : Game) -> void:
	game = _game
	game.initialize_path()

func restart_post_game() -> void:
	game.initialize_path()

func restart_in_game() -> void:
	game.unvisit_path_nodes()
	#for pes : PathEncounterStat in graphic_nodes:
	#	var graphic : Control = graphic_nodes[pes]
	#	var poly : Polygon2D = graphic.find_child("Polygon2D") as Polygon2D
	#	poly.color = color_live_node

func enter_state() -> void:
	super.enter_state()
	for line : Line2D in path_lines:
		line.queue_free()
	path_lines.clear()
	game.flood_fill_paths()

	for path_encounter_stat : PathEncounterStat in game.game_path:
		var graphic : Control = graphic_nodes[path_encounter_stat]
		var poly : Polygon2D = graphic.find_child("Polygon2D") as Polygon2D
		if path_encounter_stat.visited:
			if path_encounter_stat == game.current_path_encounter_stat:
				poly.color = color_current_node
			else:
				poly.color = color_past_path
		else:
			if path_encounter_stat.can_visit:
				poly.color = color_dead_node
			else:
				poly.color = color_dead_node
		for e : PathEncounterStat in path_encounter_stat.east:
			var texture : Texture = texture_x_path
			if path_encounter_stat == game.current_path_encounter_stat:
				texture = texture_green_dot
			elif e.visited:
				if path_encounter_stat.visited:
					texture = texture_full_dot
				else:
					texture = texture_x_path
			elif e.can_visit:
				if path_encounter_stat == game.current_path_encounter_stat:
					texture = texture_green_dot
				else:
					texture = texture_hollow_dot
			create_line(graphic.global_position + Vector2(20,20), e.map_pos * self.size + Vector2(20,20), texture)
			#draw_lines.append([graphic.global_position, e.map_pos * self.size, poly.color])
	#queue_redraw()

func create_line(from : Vector2, to : Vector2, texture : Texture) -> void:
	#draw_line(i[0] + Vector2(20,20), i[1] + Vector2(20,20), i[2], 4, true)
	var line : Line2D = Line2D.new()
	#line.material = shader_material
	line.texture = texture
	line.texture_mode = Line2D.LINE_TEXTURE_TILE
	line.texture_repeat = CanvasItem.TEXTURE_REPEAT_ENABLED
	line.antialiased = true
	var direction_norm : Vector2 = (to - from).normalized()
	line.add_point(from + direction_norm * 30)
	line.add_point(to - direction_norm * 30)
	path_lines.append(line)
	add_child(line)

func exit_state(next_state: StateMachineState) -> void:
	var graphic : Control = graphic_nodes[game.current_path_encounter_stat]
	var poly : Polygon2D = graphic.find_child("Polygon2D") as Polygon2D
	poly.color = color_past_path
	super.exit_state(next_state)

func mouse_entered(path_encounter_stat : PathEncounterStat) -> void:
	if game.current_path_encounter_stat.east.has(path_encounter_stat):
		var graphic : Control = graphic_nodes[path_encounter_stat]
		var poly : Polygon2D = graphic.find_child("Polygon2D") as Polygon2D
		poly.color = color_mouse_node
		
func mouse_exited(path_encounter_stat : PathEncounterStat) -> void:
	if game.current_path_encounter_stat.east.has(path_encounter_stat):
		var graphic : Control = graphic_nodes[path_encounter_stat]
		var poly : Polygon2D = graphic.find_child("Polygon2D") as Polygon2D
		poly.color = color_live_node

func gui_input(event: InputEvent, path_encounter_stat : PathEncounterStat) -> void:
	if !event is InputEventMouseButton:
		return
	var iemb : InputEventMouseButton = event as InputEventMouseButton
	if !iemb.is_released():
		return
		
	if game.current_path_encounter_stat.east.has(path_encounter_stat):
		game.current_path_encounter_stat = path_encounter_stat
		match path_encounter_stat.encounter_type:
			PathEncounterStat.EncounterType.GOBLIN:
				our_state_machine.switch_state("Combat")
			PathEncounterStat.EncounterType.DRACONIC:
				our_state_machine.switch_state("Combat")
			PathEncounterStat.EncounterType.SPIDERS:
				our_state_machine.switch_state("Combat")
			PathEncounterStat.EncounterType.UNDEAD:
				our_state_machine.switch_state("Combat")
			PathEncounterStat.EncounterType.CHRONOTYRANT:
				our_state_machine.switch_state("BossBattle")
			_:
				assert(false)

func place_paths() -> void:
	for path_encounter_stat : PathEncounterStat in game.game_path:
		var graphic : Control = path_graphic_scene.instantiate()
		(graphic.find_child("Label") as Label).text = path_encounter_stat.title
		var texture : Texture = path_encounter_stat.get_icon()
		if texture != null:
			var sprite : Sprite2D = (graphic.find_child("Sprite2D") as Sprite2D)
			sprite.texture = texture
			sprite.show()
		add_child(graphic)
		graphic.global_position = path_encounter_stat.map_pos * self.size
		graphic_nodes[path_encounter_stat] = graphic
		var poly : Polygon2D = graphic.find_child("Polygon2D") as Polygon2D
		poly.color = color_live_node
		graphic.mouse_entered.connect(Callable(self, "mouse_entered").bind(path_encounter_stat))
		graphic.mouse_exited.connect(Callable(self, "mouse_exited").bind(path_encounter_stat))
		graphic.gui_input.connect(Callable(self, "gui_input").bind(path_encounter_stat))

#func _draw() -> void:
	#for i in draw_lines:
		#draw_line(i[0] + Vector2(20,20), i[1] + Vector2(20,20), i[2], 4, true)
