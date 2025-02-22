class_name SMSPath extends StateMachineState

const color_dead_node : Color = Color(Color.DARK_GRAY, 0.5)
const color_live_node : Color = Color(Color.WHITE, 0.5)
const color_current_node : Color = Color(Color.GREEN, 0.5)
const color_past_path : Color = Color(Color.DARK_GREEN, 0.5)
const color_mouse_node : Color = Color(Color.GREEN_YELLOW, 0.5)

var game : Game = null
const path_graphic_scene : Resource = preload("res://Scenes/path_encounter.tscn")

func init(_game : Game, rnd : RandomNumberGenerator) -> void:
	game = _game
	game.initialize_path(rnd)

var draw_lines : Array
	
func enter_state() -> void:
	super.enter_state()
	for path_encounter_stat : PathEncounterStat in game.game_path:
		if path_encounter_stat == game.current_path_encounter_stat:
			var graphic : Control = graphic_nodes[path_encounter_stat]
			var poly : Polygon2D = graphic.find_child("Polygon2D") as Polygon2D
			poly.color = color_current_node
			for e : PathEncounterStat in path_encounter_stat.west:
				draw_lines.append([graphic.global_position, e.map_pos * self.size, color_current_node])
		else:
			var graphic : Control = graphic_nodes[path_encounter_stat]
			for e : PathEncounterStat in path_encounter_stat.west:
				if e.graph_pos.x > path_encounter_stat.graph_pos.x:
					draw_lines.append([graphic.global_position, e.map_pos * self.size, color_live_node])
				else:
					draw_lines.append([graphic.global_position, e.map_pos * self.size, color_dead_node])
			
	queue_redraw()
	
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
			PathEncounterStat.EncounterType.GATE_FIGHT:
				our_state_machine.switch_state("Combat")
			PathEncounterStat.EncounterType.REGULAR_FIGHT:
				our_state_machine.switch_state("Combat")
			PathEncounterStat.EncounterType.UNDEAD:
				our_state_machine.switch_state("Combat")
			PathEncounterStat.EncounterType.CRONOTYRANT:
				our_state_machine.switch_state("BossBattle")
			_:
				assert(false)

var graphic_nodes : Dictionary # <PathEncounterStat, Control>
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

func _draw() -> void:
	for i in draw_lines:
		draw_line(i[0] + Vector2(20,20), i[1] + Vector2(20,20), i[2], 4, true)
