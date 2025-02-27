class_name Game extends StateMachineState

var heroes : Array[UnitStats] 
var foes : Array[UnitStats]
var rnd : RandomNumberGenerator = RandomNumberGenerator.new()
var calc : MinMaxCalculator = MinMaxCalculator.new()
var combat_state_machine_state : SMSCombat
var path_state_machine_state : SMSPath
var game_state : EGameState = null
var tooltip_widget : Control
var summary_widget : Control
var summary_alt_tip : Label

const calculation_depth : int = 7 # This is how many look aheads the min-max engine computes
const path_depth : int = 8 # 6 This is how many encounters before the chronotyrant
const path_width : int = 4

func enter_state() -> void:
	super.enter_state()
	combat_state_machine_state.our_state_machine.switch_state("PreGame")

func exit_state(next_state : StateMachineState) -> void:
	combat_state_machine_state.our_state_machine.switch_state("Idle")
	super.exit_state(next_state)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	rnd.seed = int(Time.get_unix_time_from_system())
	tooltip_widget = find_child("Tooltip") as Control
	summary_alt_tip = tooltip_widget.find_child("AltTip") as Label
	tooltip_widget.hide()
	summary_alt_tip.hide()
	summary_widget = find_child("Summary") as Control
	summary_widget.hide()
	combat_state_machine_state = find_child("Combat") as SMSCombat
	combat_state_machine_state.init(self)
	path_state_machine_state = find_child("PathSelection") as SMSPath
	path_state_machine_state.init(self)
	(find_child("Defeated") as StateMachineState).state_exit.connect(Callable(self, "accepted_defeat"))
	(find_child("Victory") as StateMachineState).state_exit.connect(Callable(self, "accepted_defeat"))
	find_child("PreGame").init(self)
	find_child("PostCombat").init(self)
	find_child("LoopExposition").init(self, rnd)
	find_child("BossBattle").init(self)
	
var current_holding_ALT : bool
func _process(_delta: float) -> void:
	var new_holding_ALT : bool = Input.is_key_pressed(KEY_ALT) || Input.is_key_pressed(KEY_CTRL) || Input.is_key_pressed(KEY_SHIFT)
	if new_holding_ALT != current_holding_ALT:
		current_holding_ALT = new_holding_ALT
		update_show_unit_tooltip()

func accepted_defeat() -> void:
	heroes.clear()
	foes.clear()
	game_state.release()
	game_state = null
	combat_state_machine_state.restart()
	find_child("LoopExposition").restart(rnd)
	game_path.clear()
	path_state_machine_state.restart_post_game()
	our_state_machine.switch_state("Menu")

func set_final_battle() -> void:
	combat_state_machine_state.set_final_battle()

var hero_cgs : EGameState.CalculusGetScore
var foe_cgs : EGameState.CalculusGetScore
var hero_cds : EGameState.CalculusDiffScore
var foe_cds : EGameState.CalculusDiffScore

func clear_heroes() -> void:
	heroes.clear()

func load_in_heroes(unit_stats : Array[UnitStats]) -> void:
	assert(heroes.is_empty)
	hero_cgs = EGameState.CalculusGetScore.Default
	hero_cds = EGameState.CalculusDiffScore.Reversed
	foe_cgs = EGameState.CalculusGetScore.Default
	foe_cds = EGameState.CalculusDiffScore.Reversed
	heroes = unit_stats
	assert(!heroes[0].unit_name.is_empty())

func initialize_heroes() -> void:
	assert(heroes.is_empty())
	hero_cgs = EGameState.CalculusGetScore.Default
	hero_cds = EGameState.CalculusDiffScore.Reversed
	foe_cgs = EGameState.CalculusGetScore.Default
	foe_cds = EGameState.CalculusDiffScore.Reversed
	var species = UnitMod.create_species_shuffle(rnd)
	var occupation = UnitMod.create_occupation_shuffle(rnd)
	var equipment = UnitMod.create_equipment_shuffle(rnd)
	for i in range(0, 5):
		heroes.append(UnitStats.create_shuffle_hero(i, species, occupation, equipment, rnd))
	assert(!heroes[0].unit_name.is_empty())

func preserve_heroes() -> void:
	for i in range(0, heroes.size()):
		var current_hero : UnitStats = game_state.get_unit_by_id(heroes[i].id)
		heroes[i].prepare_for_next_battle(current_hero)

func restore_defeated_heroes() -> void:
	for i in range(0, heroes.size()):
		if heroes[i].current_health < 1:
			print("Resurrecting " + heroes[i].unit_name)
			heroes[i].current_health = 1

func perform_post_loop_heals_and_path_reset() -> void:
	for i in range(0, heroes.size()):
		heroes[i].current_health = heroes[i].max_health
	path_state_machine_state.restart_in_game()

func initialize_foes() -> void:
	foes.clear()
	foes = UnitStats.create_difficulty_foes(get_current_difficulty(), rnd, current_path_encounter_stat.encounter_type)
	#for i in range(0, 3):
	#	foes.append(UnitStats.create_foes__goblin(rnd, i == 1))

func destroy_hero(hero : UnitStats) -> void:
	find_child("BossBattle").play_erase_sound()
	heroes = heroes.filter(func(a : UnitStats) : return a.id != hero.id)
	current_path_encounter_stat = game_path.filter(func(a : PathEncounterStat) : return a.graph_pos == Vector2i.ZERO)[0]
	path_state_machine_state.our_state_machine.switch_state("LoopExposition")

func calculate_elo() -> void:
	var human_elo : float = 0 # get_elo("Player")
	#var human_count : int = 0
	for unit : UnitStats in heroes:
		human_elo += get_elo(unit.unit_name)
		#human_count += 1
		#for elo_name : String in unit.elo:
			#human_elo += get_elo(elo_name)
			#human_count += 1
	#human_elo /= float(human_count)
	var computer_elo : float = 0 # get_elo("Computer")
	#var computer_count : int = 0
	for unit : UnitStats in foes:
		computer_elo += get_elo(unit.unit_name)
		#computer_count += 1
		#for elo_name : String in unit.elo:
			#computer_elo += get_elo(elo_name)
			#computer_count += 1
	#computer_elo /= float(computer_count)

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
		
	#update_elo("Player", human_mod * K)
	for unit : UnitStats in heroes:
		update_elo(unit.unit_name, human_mod * K)
		#for elo_name : String in unit.elo:
			#update_elo(elo_name, human_mod * K)
	#update_elo("Computer", computer_mod * K)
	for unit : UnitStats in foes:
		update_elo(unit.unit_name, computer_mod * K)
		#for elo_name : String in unit.elo:
			#update_elo(elo_name, computer_mod * K)
	
	dump_elo()

func clean_up_game_state() -> void:
	game_state.release()
	game_state = null

func perform_skills(phase : SkillStats.SkillPhase, goodguys : Array[UnitStats], badguys : Array[UnitStats]) -> void:
	var skills_to_perform : Array[Array]
	for hero : UnitStats in goodguys:
		for skill : SkillStats in hero.skills:
			skills_to_perform.append([skill, hero])
	# We want the most powerful skills performed first, so that, say, a lesser resurrection doesn't spoil a more powerful one
	skills_to_perform.sort_custom(func(a, b) : return a[0].current_level > b[0].current_level)
	for stp in skills_to_perform:
		stp[0].apply(phase, stp[1], goodguys, badguys)

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

func are_all_hereos_dead() -> bool:
	if game_state == null:
		return false
	var human_count : int = 0
	for unit : UnitStats in game_state.units:
		if unit.is_alive():
			if unit.side == UnitStats.Side.HUMAN:
				human_count += 1
	return human_count == 0

var trip_sheet_labels : Dictionary # <unit id, label>
func ready_trip_sheet() -> void:
	if trip_sheet_labels.is_empty():
		return

	for unitID : int in trip_sheet_labels.keys():
		(trip_sheet_labels[unitID] as Label).queue_free()
	trip_sheet_labels.clear()

var ghost_trip_sheet_pos : Dictionary # <unit ID, future move time>

func update_trip_sheet() -> void:
	var trip_sheet : VBoxContainer = find_child("TripSheet") as VBoxContainer
	var sort_order : Array
	for unit : UnitStats in game_state.units:
		for is_ghost : bool in [false, true]:
			if is_ghost:
				if ghost_trip_sheet_pos.has(unit.id):
					var ghost_id : int = 0 - unit.id
					if !trip_sheet_labels.has(ghost_id):
						assert(unit.is_alive())
						var label : Label = Label.new()
						label.label_settings = LabelSettings.new()
						label.label_settings.font_color = Color.SKY_BLUE if unit.side == UnitStats.Side.HUMAN else Color.PALE_VIOLET_RED
						label.label_settings.font_color.a = 0.75
						label.label_settings.font_size = 20
						label.vertical_alignment = VERTICAL_ALIGNMENT_BOTTOM
						label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
						label.size_flags_vertical = Control.SIZE_EXPAND_FILL
						label.size_flags_stretch_ratio = 2
						label.text = unit.unit_name if !unit.unit_name.is_empty() else "???"
						trip_sheet_labels[ghost_id] = label
					var unit_label : Label = trip_sheet_labels[ghost_id]
					if trip_sheet.get_children().has(unit_label):
						trip_sheet.remove_child(unit_label)
					sort_order.append([ghost_trip_sheet_pos[unit.id], ghost_id])
				else:
					var ghost_id : int = 0 - unit.id
					if trip_sheet_labels.has(ghost_id):
						var ghost_label : Label = trip_sheet_labels[ghost_id]
						if trip_sheet.get_children().has(ghost_label):
							trip_sheet.remove_child(ghost_label)
			else:
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
		label.size_flags_stretch_ratio = entry[0] - prev_time
		prev_time = entry[0]
		trip_sheet.add_child(label)

func get_viable_skills() -> Array[Array]: # [[unit, skill]]
	var sort_list : Array[Array]
	for userSkillTupple : Array in SkillStats.get_viable_skills(heroes):
		sort_list.append([rnd.randf(), userSkillTupple[0], userSkillTupple[1]])
	sort_list.sort_custom(func(a, b) : return a[0] < b[0])
	var ret_val : Array[Array]
	for i in range(0, min(3, sort_list.size())):
		ret_val.append([sort_list[i][1], sort_list[i][2]])
	return ret_val

var battle_space_figures : Dictionary # <unit id, UnitGraphics>
func ready_battle_space() -> void:
	if battle_space_figures.is_empty():
		return

	for unitID : int in battle_space_figures.keys():
		(battle_space_figures[unitID] as UnitGraphics).queue_free()
	battle_space_figures.clear()

func show_unit_skills_in_tooltip(unit_stats : UnitStats, hovering : bool) -> void:
	if hovering:
		if unit_stats != null:
			tooltip_widget.show()
			tooltip_widget.find_child("TooltipTextArea").text = unit_stats.create_skill_select_tooltip()
	else:
		tooltip_widget.hide()
	summary_alt_tip.hide()

var sut_state_unit_id : int
var sut_state_hovering : bool = false
func show_unit_tooltip(unit_id : int, hovering : bool) -> void:
	sut_state_unit_id = unit_id
	sut_state_hovering = hovering
	update_show_unit_tooltip()

func update_show_unit_tooltip() -> void:
	if sut_state_hovering:
		if current_holding_ALT:
			if !summary_widget.visible:
				var unit_stats : UnitStats = game_state.get_unit_by_id(sut_state_unit_id)
				if unit_stats != null:
					if unit_stats.side == UnitStats.Side.HUMAN:
						summary_widget.position.x = 650
					else:
						summary_widget.position.x = 350
					summary_widget.find_child("TooltipTextArea").text = unit_stats.create_summary()
					summary_widget.show()
					summary_alt_tip.hide()
					tooltip_widget.hide()
		else:
			if !tooltip_widget.visible:
				var unit_stats : UnitStats = game_state.get_unit_by_id(sut_state_unit_id)
				if unit_stats != null:
					tooltip_widget.find_child("TooltipTextArea").text = unit_stats.create_tooltip()
					tooltip_widget.show()
					summary_alt_tip.show()
					summary_widget.hide()
	else:
		tooltip_widget.hide()
		summary_widget.position.x = 350;
		summary_widget.hide()
		summary_alt_tip.hide()

func toggle_mod_summary_tooltip(mod : UnitMod, hovering : bool) -> void:
	if hovering:
		summary_widget.show()
		summary_widget.find_child("TooltipTextArea").text = mod.get_summary()
	else:
		summary_widget.hide()

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
			var unit_graphics : UnitGraphics = UnitGraphics.create(unit, self)
			unit_graphics.set_unit_name(unit.unit_name)
			battle_space_figures[unit.id] = unit_graphics
			arena.add_child(unit_graphics)
			#print("Adding #" + str(unit.id) + ": hero=" + str(unit.side == UnitStats.Side.HUMAN) + " rank="+ str(screen_location[unit.id]) + " alive=" + str(unit.is_alive()))
			unit_graphics.position = calculate_position(unit.side == UnitStats.Side.HUMAN, screen_location[unit.id], unit.is_alive(), arena.size)
	for unit : UnitStats in game_state.units:
		var unit_graphics : UnitGraphics = battle_space_figures[unit.id]
		unit_graphics.set_health(unit)
		var new_unit_position : Vector2 = calculate_position(unit.side == UnitStats.Side.HUMAN, screen_location[unit.id], unit.is_alive(), arena.size)
		if new_unit_position != unit_graphics.position:
			var tween : Tween = create_tween()
			tween.tween_property(unit_graphics, "position", new_unit_position, 0.95)

func calculate_max_units_on_one_side() -> int:
	var hero_count : int = 0
	var foe_count : int = 0
	for unit : UnitStats in game_state.units:
		if unit.side == UnitStats.Side.HUMAN:
			hero_count += 1
		else:
			foe_count += 1
	return max(hero_count, foe_count)

func calculate_position(is_hero : bool, rank : int, is_alive : bool, arena_size : Vector2) -> Vector2:
	var ret_val : Vector2 = Vector2.ZERO
	var column_width : float = arena_size.x / 5.0
	var max_units_on_one_side : int = calculate_max_units_on_one_side()
	var row_count : float = max_units_on_one_side + 0.5
	var row_height : float = arena_size.y / row_count
	if is_alive:
		# graphics are placed in a triangle, with the next to go near the top, angled towards each other
		if is_hero:
			ret_val.x = 1.75 - (float(rank) / 4.0)
		else:
			ret_val.x = 3.25 + (float(rank) / 4.0)
		ret_val.y = rank + 0.5
	else:
		if is_hero:
			ret_val.x = 0.5
		else:
			ret_val.x = 4.5
		ret_val.y = row_count - (rank + 1)
	ret_val.x *= column_width
	ret_val.y *= row_height
	return ret_val

func skill_click(event : InputEvent, skill : SkillStats, unit : UnitStats) -> void:
	if !event.is_released():
		return

	if event is InputEventMouseButton:
		show_unit_skills_in_tooltip(unit, false)
		skill.add_to_unit(unit)
		path_state_machine_state.our_state_machine.switch_state("PathSelection")

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
	if game_state == null:
		ready_trip_sheet()
		ready_battle_space()
		round_count = 0
		setup_game_state()
		var current_heroes : Array[UnitStats] = game_state.units.filter(func(a : UnitStats) : return a.side == UnitStats.Side.HUMAN)
		var current_foes : Array[UnitStats] = game_state.units.filter(func(a : UnitStats) : return a.side == UnitStats.Side.COMPUTER)
		perform_skills(SkillStats.SkillPhase.PRE_COMBAT, current_heroes, current_foes)
		update_trip_sheet()
		update_battle_space()
		return

	round_count += 1

	if game_state.who_just_went == UnitStats.Side.HUMAN:
		var best_action = calc.get_best_action(game_state, calculation_depth) as EAction
		#if best_action.attack != null:
			#print(str(best_action))
		#if best_action.attack != null && game_state.get_unit_by_id(best_action.actorID).attacks.has(UnitMod.s_angry_punch_attack):
			#for i in range(1, depth + 1):
				#var debug : MMCDebug = MMCDebug.new()
				#var repeat_action = calc.get_best_action(game_state, i, debug) as EAction
				#if repeat_action.attack != UnitMod.s_angry_punch_attack:
					#var fileAccess : FileAccess = FileAccess.open("./graph.txt", FileAccess.WRITE)
					#debug.dump(game_state, fileAccess)
					#fileAccess.flush()
					#fileAccess.close()
					#print("Wrote to " + fileAccess.get_path_absolute())
					#pass
		if best_action == null:
			best_action = calc.get_best_action(game_state, calculation_depth) as EAction
		harvest_fx(best_action)
		game_state = best_action.resulting_state
		#print(str(best_action))
		update_trip_sheet()
		update_battle_space()
		return
	
	if !combat_state_machine_state.has_human_moves():
		var human_moves : Array[MMCAction] = game_state.get_human_moves()
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

func harvest_fx(action : EAction) -> void:
	if action.attack == null:
		return
	var fx : ActionFXContainer = action.attack.generate_fx(game_state.get_unit_by_id(action.actorID), game_state.get_unit_by_id(action.targetID))
	combat_state_machine_state.apply_fx(fx)

func human_hover_over_action(b : bool, move : EAction) -> void:
	if b:
		var target : UnitStats = game_state.get_unit_by_id(move.targetID)

		if move.attack != null:
			tooltip_widget.show()
			summary_alt_tip.hide()
			tooltip_widget.find_child("TooltipTextArea").text = move.attack.generate_tooltip(target)

		#var dmg : float = game_state.get_unit_by_id(move.targetID).calculate_damage_from_attack(move.attack)
		var actor : UnitStats = game_state.get_unit_by_id(move.actorID)
		ghost_trip_sheet_pos[move.actorID] = actor.next_attack + move.attack.get_cost_in_time(actor)
		
		var target_slow : float = move.attack.get_cost_in_time_for_target(actor, target)
		if target_slow != 0:
			ghost_trip_sheet_pos[move.targetID] = target.next_attack + target_slow
			
		update_trip_sheet()
	else:
		tooltip_widget.hide()

		ghost_trip_sheet_pos.erase(move.actorID)
		assert(!ghost_trip_sheet_pos.has(move.actorID))
		if ghost_trip_sheet_pos.has(move.targetID):
			ghost_trip_sheet_pos.erase(move.targetID)
		update_trip_sheet()
		
		#var ghost_trip_sheet_pos : Dictionary # <unit ID, future move time>
		#print(move.attack.attack_name + " for " + str(round(dmg * 10) / 10) + " damage.")

func human_click_on_action(move : EAction) -> void:
	harvest_fx(move)
	game_state = move.resulting_state
	combat_state_machine_state.clear_human_moves()
	for unitID : int in battle_space_figures.keys():
		(battle_space_figures[unitID] as UnitGraphics).clean_up_human_UX()
	update_trip_sheet()
	update_battle_space()

var game_path : Array[PathEncounterStat]
var current_path_encounter_stat : PathEncounterStat

func get_current_difficulty() -> float:
	return (5.0 - heroes.size()) + (float(current_path_encounter_stat.graph_pos.x) / path_depth)

func all_path_encounter_stats_at_depth(depth : int) -> Array[PathEncounterStat]:
	return game_path.filter(func(a : PathEncounterStat) : return a.graph_pos.x == depth)

func flood_fill_paths() -> void:
	current_path_encounter_stat.visit()
	for pes : PathEncounterStat in game_path:
		pes.can_visit = false
	var start_pes : PathEncounterStat = all_path_encounter_stats_at_depth(0)[0]
	start_pes.flood_fill()

func unvisit_path_nodes() -> void:
	for pes : PathEncounterStat in game_path:
		pes.can_visit = false
		pes.visited = false

func initialize_path() -> void:
	assert(game_path.is_empty())
	var wiggle_range : Vector2 = Vector2(0.25 / float(path_depth + 2.0), 0.25 / float(path_width + 2.0))
	for d : int in range(0, path_depth):
		var current_width : int = path_width
		if d == 0 || d == path_depth - 1:
			current_width = 1
		elif d == 1 || d == path_depth - 2:
			current_width = 2
		for w : int in range(0, current_width):
			var pos : Vector2
			pos.x = float(d + 0.40) / float(path_depth + 1)
			pos.y = float(w + 0.5) / float(current_width)
			pos.x += rnd.randf_range(-wiggle_range.x, wiggle_range.x)
			pos.y += rnd.randf_range(-wiggle_range.y, wiggle_range.y)
			var pe : PathEncounterStat = PathEncounterStat.new()
			pe.init(d, w, pos, rnd.randf())
			game_path.append(pe)
	var start_pes : PathEncounterStat = all_path_encounter_stats_at_depth(0)[0]
	start_pes.set_encounter_type("Gate Guards", PathEncounterStat.EncounterType.GATE_FIGHT)
	for n : PathEncounterStat in all_path_encounter_stats_at_depth(1):
		n.connect_path_to(start_pes)
	var end_pes : PathEncounterStat = all_path_encounter_stats_at_depth(path_depth - 1)[0]
	end_pes.set_encounter_type("Chronotyrant", PathEncounterStat.EncounterType.CHRONOTYRANT)
	for n : PathEncounterStat in all_path_encounter_stats_at_depth(path_depth - 2):
		n.connect_path_to(end_pes)
	game_path.sort_custom(func(a : PathEncounterStat, b: PathEncounterStat) : return a.sort_value < b.sort_value)
	var needs_paths : Array[PathEncounterStat] = game_path.filter(func(a : PathEncounterStat) : return a.needs_paths())
	while !needs_paths.is_empty():
		needs_paths[0].add_paths(game_path, rnd)
		needs_paths.remove_at(0)
		needs_paths = game_path.filter(func(a : PathEncounterStat) : return a.needs_paths())
	var regular_count : int = 0
	for entry : PathEncounterStat in game_path:
		if entry.encounter_type == PathEncounterStat.EncounterType.UNDEFINED:
			entry.set_encounter_type("Combat", PathEncounterStat.EncounterType.REGULAR_FIGHT)
		if entry.encounter_type == PathEncounterStat.EncounterType.REGULAR_FIGHT:
			regular_count += 1
	var undead_count : int = 0
	var place_index : int = 0
	while undead_count * 3 < regular_count:
		if game_path[place_index].encounter_type == PathEncounterStat.EncounterType.REGULAR_FIGHT:
			game_path[place_index].set_encounter_type("Undead", PathEncounterStat.EncounterType.UNDEAD)
			undead_count += 1
		place_index += 1
	path_state_machine_state.place_paths()
	current_path_encounter_stat = start_pes
