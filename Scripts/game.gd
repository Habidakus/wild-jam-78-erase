class_name Game extends StateMachineState

var heroes : Array[UnitStats] 
var foes : Array[UnitStats]
var rnd : RandomNumberGenerator = RandomNumberGenerator.new()
var calc : MinMaxCalculator = MinMaxCalculator.new()
var combat_state_machine_state : SMSCombat
var game_state : EGameState = null

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	rnd.seed = 41
	combat_state_machine_state = find_child("Combat") as SMSCombat
	combat_state_machine_state.init(self)
	find_child("PreGame").init(self)
	find_child("PostCombat").init(self)

var hero_cgs : EGameState.CalculusGetScore
var foe_cgs : EGameState.CalculusGetScore
var hero_cds : EGameState.CalculusDiffScore
var foe_cds : EGameState.CalculusDiffScore

func initialize_heroes() -> void:
	heroes.clear()
	hero_cgs = EGameState.CalculusGetScore.Default
	hero_cds = EGameState.CalculusDiffScore.Reversed
	foe_cgs = EGameState.CalculusGetScore.Default
	foe_cds = EGameState.CalculusDiffScore.Reversed
	#if rnd.randf() < 0.5:
		#hero_cgs = EGameState.CalculusGetScore.Default
	#else:
		#hero_cgs = EGameState.CalculusGetScore.Reversed
	#if rnd.randf() < 0.5:
		#foe_cgs = EGameState.CalculusGetScore.Reversed
	#else:
		#foe_cgs = EGameState.CalculusGetScore.Default
	#if rnd.randf() < 0.5:
		#hero_cds = EGameState.CalculusDiffScore.Default
	#else:
		#hero_cds = EGameState.CalculusDiffScore.Reversed
	#if rnd.randf() < 0.5:
		#foe_cds = EGameState.CalculusDiffScore.Reversed
	#else:
		#foe_cds = EGameState.CalculusDiffScore.Default
	for i in range(0, 5):
		heroes.append(UnitStats.create_random(rnd, UnitStats.Side.HUMAN))

func initialize_foes() -> void:
	foes.clear()
	for i in range(0, 5):
		foes.append(UnitStats.create_random(rnd, UnitStats.Side.COMPUTER))

func calculate_elo() -> void:
	var human_calculus : String
	var foe_calculus : String
	if hero_cgs == EGameState.CalculusGetScore.Default:
		if hero_cds == EGameState.CalculusDiffScore.Default:
			human_calculus = "DefaultCalculus"
		else:
			human_calculus = "ReverseDiff"
	else:
		if hero_cds == EGameState.CalculusDiffScore.Default:
			human_calculus = "ReverseScore"
		else:
			human_calculus = "ReverseCalculus"
	if foe_cgs == EGameState.CalculusGetScore.Default:
		if foe_cds == EGameState.CalculusDiffScore.Default:
			foe_calculus = "DefaultCalculus"
		else:
			foe_calculus = "ReverseDiff"
	else:
		if foe_cds == EGameState.CalculusDiffScore.Default:
			foe_calculus = "ReverseScore"
		else:
			foe_calculus = "ReverseCalculus"

	var human_elo : float = get_elo("Player")
	human_elo += get_elo(human_calculus)
	var human_count : int = 2
	for unit : UnitStats in heroes:
		for elo_name : String in unit.elo:
			human_elo += get_elo(elo_name)
			human_count += 1
	human_elo /= float(human_count)
	var computer_elo : float = get_elo("Computer")
	computer_elo += get_elo(foe_calculus)
	var computer_count : int = 2
	for unit : UnitStats in foes:
		for elo_name : String in unit.elo:
			computer_elo += get_elo(elo_name)
			computer_count += 1
	computer_elo /= float(computer_count)
	
	assert(human_count == computer_count)

	var human_expectation = 1.0 / (1.0 + pow(10.0, (computer_elo - human_elo) / 400.0))
	var computer_expectation = 1.0 / (1.0 + pow(10.0, (computer_elo - human_elo) / 400.0))
	
	var human_alive : bool = false
	var computer_alive : bool = false
	for unit : UnitStats in game_state.units:
		if unit.is_alive():
			if unit.side == UnitStats.Side.HUMAN:
				human_alive = true
			else:
				computer_alive = true
	var human_score : float = 0.5
	var computer_score : float = 0.5
	if human_alive != computer_alive:
		if human_alive:
			human_score = 1
			computer_score = 0
		else:
			human_score = 0
			computer_score = 1

	var human_mod = human_score - human_expectation
	var computer_mod = computer_score - computer_expectation
	const K : float = 4.0
	
	update_elo(human_calculus, human_mod * K)
	update_elo(foe_calculus, computer_mod * K)
		
	update_elo("Player", human_mod * K)
	for unit : UnitStats in heroes:
		for elo_name : String in unit.elo:
			update_elo(elo_name, human_mod * K)
	update_elo("Computer", computer_mod * K)
	for unit : UnitStats in foes:
		for elo_name : String in unit.elo:
			update_elo(elo_name, computer_mod * K)
	
	dump_elo()
	
	game_state.release()
	game_state = null

var elo_values : Dictionary # <string, float>
func dump_elo() -> void:
	var d : Array
	for key in elo_values.keys():
		d.append([key, elo_values[key]])
	d.sort_custom(func(a, b) : return a[1] > b[1])
	print("-----ELO-------")
	for v in d:
		print("  " + str(round(v[1] * 10) / 10) + " " + v[0])
	
func get_elo(elo_name : String) -> float:
	if !elo_values.has(elo_name):
		elo_values[elo_name] = 1500.0
	return elo_values[elo_name]

func update_elo(elo_name : String, mod : float) -> void:
	elo_values[elo_name] += mod

func is_fight_finished() -> bool:
	if game_state == null:
		return false
	#if round_count > 200:
		#return true
	var human_count : int = 0
	var computer_count : int = 0
	for unit : UnitStats in game_state.units:
		if unit.is_alive():
			if unit.side == UnitStats.Side.HUMAN:
				human_count += 1
			else:
				computer_count += 1
	return human_count == 0 || computer_count == 0

var trip_sheet_labels : Dictionary # <unit id, label>
func ready_trip_sheet() -> void:
	if trip_sheet_labels.is_empty():
		return

	for unitID : int in trip_sheet_labels.keys():
		(trip_sheet_labels[unitID] as Label).queue_free()
	trip_sheet_labels.clear()

func update_trip_sheet() -> void:
	var trip_sheet : VBoxContainer = find_child("TripSheet") as VBoxContainer
	var sort_order : Array
	for unit : UnitStats in game_state.units:
		if !trip_sheet_labels.has(unit.id):
			var label : Label = Label.new()
			label.label_settings = LabelSettings.new()
			label.label_settings.font_color = Color.SKY_BLUE if unit.side == UnitStats.Side.HUMAN else Color.PALE_VIOLET_RED
			label.label_settings.font_size = 20
			label.vertical_alignment = VERTICAL_ALIGNMENT_BOTTOM
			label.size_flags_vertical = Control.SIZE_EXPAND_FILL
			label.size_flags_stretch_ratio = 2
			label.text = unit.unit_name
			trip_sheet_labels[unit.id] = label
		var unit_label : Label = trip_sheet_labels[unit.id]
		if trip_sheet.get_children().has(unit_label):
			trip_sheet.remove_child(unit_label)
		if !unit.is_alive():
			unit_label.hide()
		else:
			sort_order.append([unit.next_attack, unit.id])
	if sort_order.is_empty():
		return
	sort_order.sort_custom(func(a, b) : return a[0] < b[0])
	var start_time : float = sort_order[0][0]
	var prev_time : float = start_time - 1.0
	for entry in sort_order:
		var label : Label = trip_sheet_labels[entry[1]]
		#var unit : UnitStats = game_state.get_unit_by_id(entry[1])
		label.size_flags_stretch_ratio = entry[0] - prev_time
		prev_time = entry[0]
		trip_sheet.add_child(label)

var battle_space_figures : Dictionary # <unit id, UnitGraphics>
func ready_battle_space() -> void:
	if battle_space_figures.is_empty():
		return

	for unitID : int in battle_space_figures.keys():
		(battle_space_figures[unitID] as UnitGraphics).queue_free()
	battle_space_figures.clear()

func update_battle_space() -> void:
	var display_order : Array
	for unit : UnitStats in game_state.units:
		display_order.append([unit.id, unit.next_attack, unit.is_alive(), unit.side])
	display_order.sort_custom(func(a, b) :
		if a[2] != b[2]:
			return a[2]
		if a[1] != b[1]:
			return a[1] < b[1]
		return a[0] < b[0]
	)
	
	var hero_alive_rank : int = 0
	var foe_alive_rank : int = 0
	var hero_dead_rank : int = 0
	var foe_dead_rank : int = 0
	var screen_location : Dictionary # <unit ID, rank>
	for entry in display_order:
		if entry[3] == UnitStats.Side.HUMAN:
			if entry[2]: # Alive
				screen_location[entry[0]] = hero_alive_rank
				hero_alive_rank += 1
			else:
				screen_location[entry[0]] = hero_dead_rank
				hero_dead_rank += 1
		else:
			if entry[2]: # Alive
				screen_location[entry[0]] = foe_alive_rank
				foe_alive_rank += 1
			else:
				screen_location[entry[0]] = foe_dead_rank
				foe_dead_rank += 1

	var arena : ColorRect = find_child("Arena") as ColorRect
	for unit : UnitStats in game_state.units:
		if !battle_space_figures.has(unit.id):
			var unit_graphics : UnitGraphics = UnitGraphics.create(unit)
			unit_graphics.set_unit_name(unit.unit_name)
			battle_space_figures[unit.id] = unit_graphics
			arena.add_child(unit_graphics)
			print("Adding #" + str(unit.id) + ": hero=" + str(unit.side == UnitStats.Side.HUMAN) + " rank="+ str(screen_location[unit.id]) + " alive=" + str(unit.is_alive()))
			unit_graphics.position = calculate_position(unit.side == UnitStats.Side.HUMAN, screen_location[unit.id], unit.is_alive(), arena.size)
	for unit : UnitStats in game_state.units:
		var unit_graphics : UnitGraphics = battle_space_figures[unit.id]
		unit_graphics.set_health(unit)
		var new_unit_position : Vector2 = calculate_position(unit.side == UnitStats.Side.HUMAN, screen_location[unit.id], unit.is_alive(), arena.size)
		if new_unit_position != unit_graphics.position:
			var tween : Tween = create_tween()
			tween.tween_property(unit_graphics, "position", new_unit_position, 0.95)

func calculate_position(is_hero : bool, rank : int, is_alive : bool, arena_size : Vector2) -> Vector2:
	var ret_val : Vector2 = Vector2.ZERO
	var column_width : float = arena_size.x / 5.0
	var row_count : float = (game_state.units.size() / 2.0) + 1.0
	var row_height : float = arena_size.y / row_count
	if is_alive:
		# graphics are placed in a triangle, with the next to go near the top, angled towards each other
		if is_hero:
			ret_val.x = 1.75 - (float(rank) / 4.0)
		else:
			ret_val.x = 3.25 + (float(rank) / 4.0)
		ret_val.y = rank + 1
	else:
		if is_hero:
			ret_val.x = 0.5
		else:
			ret_val.x = 4.5
		ret_val.y = row_count - (rank + 1)
	ret_val.x *= column_width
	ret_val.y *= row_height
	return ret_val


func setup_game_state() -> void:
	assert(game_state == null)
	var units : Array[UnitStats]
	units.append_array(heroes)
	units.append_array(foes)
	var side_to_go_next : UnitStats.Side = UnitStats.select_lowest(units, func(a : UnitStats) : return a.get_time_until_action()).side
	var who_just_went : UnitStats.Side = UnitStats.get_other_side(side_to_go_next)
	var cgs : EGameState.CalculusGetScore = hero_cgs if who_just_went == UnitStats.Side.HUMAN else foe_cgs
	var cds : EGameState.CalculusDiffScore = hero_cds if who_just_went == UnitStats.Side.HUMAN else foe_cds
	game_state = EGameState.create(who_just_went, units, cgs, cds)

var round_count : int = 0
func run_one_turn() -> void:
	const depth : int = 8
	if game_state == null:
		ready_trip_sheet()
		ready_battle_space()
		round_count = 0
		setup_game_state()
		update_trip_sheet()
		update_battle_space()
		return

	round_count += 1

	if game_state.who_just_went == UnitStats.Side.HUMAN:
		var best_action = calc.get_best_action(game_state, depth) as EAction
		#if best_action.attack != null:
			#print(str(best_action))
		#if best_action.attack == AttackStats.get_default_attack():
			#for i in range(1, depth + 1):
				#var debug : MMCDebug = MMCDebug.new()
				#var repeat_action = calc.get_best_action(game_state, i, debug) as EAction
				#if repeat_action.attack == AttackStats.get_default_attack():
					#var fileAccess : FileAccess = FileAccess.open("./graph.txt", FileAccess.WRITE)
					#debug.dump(game_state, fileAccess)
					#fileAccess.flush()
					#fileAccess.close()
					#print("Wrote to " + fileAccess.get_path_absolute())
					#pass
		if best_action == null:
			best_action = calc.get_best_action(game_state, depth) as EAction
		game_state = best_action.resulting_state
		update_trip_sheet()
		update_battle_space()
		return
	
	if !combat_state_machine_state.has_human_moves():
		var human_moves : Array[MMCAction] = game_state.get_moves()
		assert(human_moves != null)
		if human_moves.size() == 1:
			var emove : EAction = human_moves[0] as EAction
			if emove.attack == null:
				game_state = human_moves[0].resulting_state
				update_trip_sheet()
				update_battle_space()
				human_moves.clear()
				return

		var hover_callback : Callable = Callable(self, "human_hover_over_action")
		var click_callback : Callable = Callable(self, "human_click_on_action")
		combat_state_machine_state.set_human_moves(human_moves, hover_callback, click_callback)

func human_hover_over_action(b : bool, move : EAction) -> void:
	if b:
		var dmg : float = game_state.get_unit_by_id(move.targetID).calculate_damage_from_attack(move.attack)
		print(move.attack.attack_name + " for " + str(round(dmg * 10) / 10) + " damage.")

func human_click_on_action(move : EAction) -> void:
	game_state = move.resulting_state
	combat_state_machine_state.clear_human_moves()
	for unitID : int in battle_space_figures.keys():
		(battle_space_figures[unitID] as UnitGraphics).clean_up_human_UX()
	update_trip_sheet()
	update_battle_space()
