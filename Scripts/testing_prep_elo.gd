extends StateMachineState

var active : bool = false
var game : Game
var test_rnd : RandomNumberGenerator = RandomNumberGenerator.new()
const depth : int =7
var calc : MinMaxCalculator = MinMaxCalculator.new()

func _process(_delta: float) -> void:
	if active:
		
		var best_action : EAction = calc.get_best_action(game.game_state, depth) as EAction
		#print(str(best_action))
		game.game_state = best_action.resulting_state
		
		if game.is_fight_finished():
			active = false
			our_state_machine.switch_state("Testing_ProcessFight")

func enter_state() -> void:
	super.enter_state()
	active = true
	game = get_parent().get_parent() as Game
	assert(game)

	#var diff : float = rnd.randf_range(0, 6)

	var side_strength : int = test_rnd.randi_range(3, 20)
	
	if test_rnd.randf() < 0.5:
		game.heroes = create_army_undead(side_strength + 1, test_rnd)
		for hero : UnitStats in game.heroes:
			hero.side = UnitStats.Side.HUMAN
		#game.foes = create_army_goblin(side_strength, test_rnd)
		game.foes = create_army_insect(side_strength, test_rnd)
	else:
		game.heroes = create_army_insect(side_strength + 1, test_rnd)
		#game.heroes = create_army_goblin(side_strength + 1, test_rnd)
		for hero : UnitStats in game.heroes:
			hero.side = UnitStats.Side.HUMAN
		game.foes = create_army_undead(side_strength, test_rnd)
	
	game.setup_game_state()

func create_army_insect(value : int, rnd : RandomNumberGenerator) -> Array[UnitStats]:
	var ret_val : Array[UnitStats]
	var foe : UnitStats
	if value >= 8:
		if rnd.randf() < 0.5:
			foe = UnitStats.new()
			foe.init(UnitMod.s_species_mantis_queen, UnitMod.s_occupation_mantis, UnitMod.s_equipment_mantis_queen, UnitStats.Side.COMPUTER, rnd)
			foe.unit_name = "Mantis Queen"
			ret_val.append(foe)
			value -= 8
			if value > 0:
				ret_val.append_array(create_army_undead(value, rnd))
			return ret_val
			
	if value >= 4:
		if rnd.randf() < 0.5:
			foe = UnitStats.new()
			foe.init(UnitMod.s_species_mantis_drone, UnitMod.s_occupation_mantis, UnitMod.s_equipment_mantis_drone, UnitStats.Side.COMPUTER, rnd)
			foe.unit_name = "Mantis Drone"
			ret_val.append(foe)
			value -= 4
			if value > 0:
				ret_val.append_array(create_army_undead(value, rnd))
			return ret_val
			
	if rnd.randf() < 0.5:
		foe = UnitStats.new()
		foe.init(UnitMod.s_species_spider, UnitMod.s_occupation_spider, UnitMod.s_equipment_great_spider, UnitStats.Side.COMPUTER, rnd)
		foe.unit_name = "Great Spider"
		ret_val.append(foe)
		value -= 1
	else:
		foe = UnitStats.new()
		foe.init(UnitMod.s_species_spider, UnitMod.s_occupation_spider, UnitMod.s_equipment_large_spider, UnitStats.Side.COMPUTER, rnd)
		foe.unit_name = "Large Spider"
		ret_val.append(foe)
		value -= 1

	if value > 0:
		ret_val.append_array(create_army_undead(value, rnd))
	return ret_val

func create_army_goblin(value : int, rnd : RandomNumberGenerator) -> Array[UnitStats]:
	var ret_val : Array[UnitStats]
	var foe : UnitStats
	if value >= 8:
		if rnd.randf() < 0.5:
			foe = UnitStats.new()
			foe.init(UnitMod.s_species_ogre, UnitMod.s_occupation_guard_lord, UnitMod.s_equipment_lord_gear, UnitStats.Side.COMPUTER, rnd)
			foe.unit_name = "Ogre Lord"
			ret_val.append(foe)
			value -= 8
			if value > 0:
				ret_val.append_array(create_army_undead(value, rnd))
			return ret_val
			
	if value >= 4:
		if rnd.randf() < 0.5:
			foe = UnitStats.new()
			foe.init(UnitMod.s_species_goblin, UnitMod.s_occupation_guard_cpt, UnitMod.s_equipment_cpt_gear, UnitStats.Side.COMPUTER, rnd)
			foe.unit_name = "Goblin Captain"
			ret_val.append(foe)
			value -= 4
			if value > 0:
				ret_val.append_array(create_army_undead(value, rnd))
			return ret_val
			
	if value >= 2:
		if rnd.randf() < 0.5:
			foe = UnitStats.new()
			foe.init(UnitMod.s_species_goblin, UnitMod.s_occupation_guard_sgt, UnitMod.s_equipment_guard_gear, UnitStats.Side.COMPUTER, rnd)
			foe.unit_name = "Goblin Sargent"
			ret_val.append(foe)
			value -= 2
			if value > 0:
				ret_val.append_array(create_army_undead(value, rnd))
			return ret_val
			
	foe = UnitStats.new()
	foe.init(UnitMod.s_species_goblin, UnitMod.s_occupation_guard, UnitMod.s_equipment_guard_gear, UnitStats.Side.COMPUTER, rnd)
	foe.unit_name = "Goblin Guard"
	ret_val.append(foe)
	value -= 1

	return ret_val

func create_army_undead(value : int, rnd : RandomNumberGenerator) -> Array[UnitStats]:
	var ret_val : Array[UnitStats]
	var foe : UnitStats
	if value >= 8:
		if rnd.randf() < 0.5:
			foe = UnitStats.new()
			foe.init(UnitMod.s_species_demon, UnitMod.s_occupation_demon, UnitMod.s_equipment_undead, UnitStats.Side.COMPUTER, rnd)
			foe.unit_name = "Demon"
			ret_val.append(foe)
			value -= 8
			if value > 0:
				ret_val.append_array(create_army_undead(value, rnd))
			return ret_val
			
	if value >= 4:
		if rnd.randf() < 0.5:
			foe = UnitStats.new()
			foe.init(UnitMod.s_species_skeleton_king, UnitMod.s_occupation_undead_physical, UnitMod.s_equipment_undead, UnitStats.Side.COMPUTER, rnd)
			foe.unit_name = "Skeleton King"
			ret_val.append(foe)
			value -= 4
			if value > 0:
				ret_val.append_array(create_army_undead(value, rnd))
			return ret_val
			
	if value >= 2:
		if rnd.randf() < 0.5:
			foe = UnitStats.new()
			foe.init(UnitMod.s_species_skeleton, UnitMod.s_occupation_undead_mage, UnitMod.s_equipment_undead, UnitStats.Side.COMPUTER, rnd)
			foe.unit_name = "Skeleton Mage"
			ret_val.append(foe)
			value -= 2
			if value > 0:
				ret_val.append_array(create_army_undead(value, rnd))
			return ret_val
			
	foe = UnitStats.new()
	foe.init(UnitMod.s_species_skeleton, UnitMod.s_occupation_undead_physical, UnitMod.s_equipment_undead, UnitStats.Side.COMPUTER, rnd)
	foe.unit_name = "Skeleton"
	ret_val.append(foe)
	value -= 1

	return ret_val
