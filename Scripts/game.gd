class_name Game extends StateMachineState

var heroes : Array[UnitStats] 
var foes : Array[UnitStats]
var rnd : RandomNumberGenerator = RandomNumberGenerator.new()
var calc : MinMaxCalculator = MinMaxCalculator.new()
var game_state : EGameState = null

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	rnd.seed = 2
	find_child("PreGame").init(self)
	find_child("Combat").init(self)
	find_child("PostCombat").init(self)

func initialize_heroes() -> void:
	heroes.clear()
	for i in range(0, 5):
		heroes.append(UnitStats.create_random(rnd, UnitStats.Side.HUMAN))

func initialize_foes() -> void:
	foes.clear()
	for i in range(0, 5):
		foes.append(UnitStats.create_random(rnd, UnitStats.Side.COMPUTER))

func calculate_elo() -> void:
	var human_elo : float = get_elo("Human")
	var human_count : int = 1
	for unit : UnitStats in heroes:
		for elo_name : String in unit.elo:
			human_elo += get_elo(elo_name)
			human_count += 1
	human_elo /= float(human_count)
	var computer_elo : float = get_elo("Computer")
	var computer_count : int = 1
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
	assert(human_alive != computer_alive)

	var human_mod = (1.0 - human_expectation) if human_alive else (0.0 - human_expectation)
	var computer_mod = (1.0 - computer_expectation) if computer_alive else (0.0 - computer_expectation)
	const K : float = 4.0
	
	update_elo("Human", human_mod * K)
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

func one_side_is_dead() -> bool:
	if game_state == null:
		return false
	var human_count : int = 0
	var computer_count : int = 0
	for unit : UnitStats in game_state.units:
		if unit.is_alive():
			if unit.side == UnitStats.Side.HUMAN:
				human_count += 1
			else:
				computer_count += 1
	return human_count == 0 || computer_count == 0

func run_one_turn() -> void:
	if game_state == null:
		var units : Array[UnitStats]
		units.append_array(heroes)
		units.append_array(foes)
		var side_to_go_next : UnitStats.Side = UnitStats.select_lowest(units, func(a : UnitStats) : return a.get_time_until_action()).side
		var who_just_went : UnitStats.Side = UnitStats.get_other_side(side_to_go_next)
		game_state = EGameState.create(who_just_went, units)
	var best_action = calc.get_best_action(game_state, 6) as EAction
	print(str(best_action))
	game_state = best_action.resulting_state
