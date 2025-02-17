class_name Game extends StateMachineState

var heroes : Array[UnitStats] 
var foes : Array[UnitStats]
var rnd : RandomNumberGenerator = RandomNumberGenerator.new()
var calc : MinMaxCalculator = MinMaxCalculator.new()
var game_state : EGameState = null

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	rnd.seed = 4
	find_child("PreGame").init(self)
	find_child("Combat").init(self)
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
	if round_count > 200:
		return true
	var human_count : int = 0
	var computer_count : int = 0
	for unit : UnitStats in game_state.units:
		if unit.is_alive():
			if unit.side == UnitStats.Side.HUMAN:
				human_count += 1
			else:
				computer_count += 1
	return human_count == 0 || computer_count == 0

var round_count : int = 0
func run_one_turn() -> void:
	const depth : int = 8
	if game_state == null:
		round_count = 0
		var units : Array[UnitStats]
		units.append_array(heroes)
		units.append_array(foes)
		var side_to_go_next : UnitStats.Side = UnitStats.select_lowest(units, func(a : UnitStats) : return a.get_time_until_action()).side
		var who_just_went : UnitStats.Side = UnitStats.get_other_side(side_to_go_next)
		var cgs : EGameState.CalculusGetScore = hero_cgs if who_just_went == UnitStats.Side.HUMAN else foe_cgs
		var cds : EGameState.CalculusDiffScore = hero_cds if who_just_went == UnitStats.Side.HUMAN else foe_cds
		game_state = EGameState.create(who_just_went, units, cgs, cds)
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
	game_state = best_action.resulting_state
	round_count += 1
