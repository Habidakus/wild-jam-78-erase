class_name EGameState extends MMCGameState

enum CalculusGetScore { Default, Reversed }
enum CalculusDiffScore { Default, Reversed }

var calculus_get_score : CalculusGetScore = CalculusGetScore.Default
var calculus_diff_score : CalculusDiffScore = CalculusDiffScore.Default
var who_just_went : UnitStats.Side = UnitStats.Side.NEITHER
var units : Array[UnitStats]
var moves : Array[MMCAction]
var score : EScore = null

func _to_string() -> String:
	var ret_val : String = UnitStats.Side.keys()[who_just_went] + " went, score = " + str(get_score())
	return ret_val

func release() -> void:
	if score != null:
		score = null
	units.clear()
	for move : MMCAction in moves:
		(move as EAction).release()
	moves.clear()

static func create(_who_just_went : UnitStats.Side, _units : Array[UnitStats], cgs : CalculusGetScore, cds : CalculusDiffScore) -> EGameState:
	var ret_val : EGameState = EGameState.new()
	ret_val.calculus_get_score = cgs
	ret_val.calculus_diff_score = cds
	ret_val.who_just_went = _who_just_went
	for unit : UnitStats in _units:
		ret_val.units.append(unit)
	ret_val.units.sort_custom(func(a : UnitStats, b : UnitStats) : return a.get_time_until_action() < b.get_time_until_action())
	return ret_val

func clone() -> EGameState:
	var ret_val : EGameState = EGameState.new()
	ret_val.calculus_get_score = calculus_get_score
	ret_val.calculus_diff_score = calculus_diff_score
	ret_val.who_just_went = who_just_went
	for unit : UnitStats in units:
		ret_val.units.append(unit.clone())
	return ret_val

func get_unit_by_id(id : int) -> UnitStats:
	for unit : UnitStats in units:
		if unit.id == id:
			return unit
	assert(false)
	return null

func apply_action(action : MMCAction) -> MMCGameState:
	var ret_val : EGameState = self.clone()
	ret_val.who_just_went = UnitStats.get_other_side(who_just_went)
	var eaction : EAction = action as EAction
	if eaction.attack != null:
		assert(eaction.targetID != 0)
		assert(eaction.actorID != 0)
		eaction.attack.apply(ret_val.get_unit_by_id(eaction.actorID), ret_val.get_unit_by_id(eaction.targetID))
	else:
		assert(eaction.targetID == 0)
		assert(eaction.actorID == 0)
	return ret_val

func get_moves() -> Array[MMCAction]:
	if moves.is_empty():
		var unit_to_go_next : UnitStats = UnitStats.select_lowest(units.filter(func(a : UnitStats) : return a.is_alive()), func(a : UnitStats) : return a.get_time_until_action())
		if unit_to_go_next == null || unit_to_go_next.side == who_just_went: # Otherside will just have to pass
			var action : EAction = EAction.create_pass()
			action.resulting_state = apply_action(action)
			moves.append(action)
		else:
			moves = unit_to_go_next.get_moves(units, false)
			for action : MMCAction in moves:
				(action as EAction).resulting_state = apply_action(action)
	return moves

func get_human_moves() -> Array[MMCAction]:
	if moves.is_empty():
		var unit_to_go_next : UnitStats = UnitStats.select_lowest(units.filter(func(a : UnitStats) : return a.is_alive()), func(a : UnitStats) : return a.get_time_until_action())
		if unit_to_go_next == null || unit_to_go_next.side == who_just_went: # Otherside will just have to pass
			var action : EAction = EAction.create_pass()
			action.resulting_state = apply_action(action)
			moves.append(action)
		else:
			moves = unit_to_go_next.get_moves(units, true)
			for action : MMCAction in moves:
				(action as EAction).resulting_state = apply_action(action)
	return moves

func get_score() -> MMCScore:
	if score == null:
		score = EScore.new()
		score.reverse = calculus_diff_score == CalculusDiffScore.Reversed
		var our_lowest_health : float = 1000
		var their_lowest_health : float = 1000
		for unit : UnitStats in units:
			if unit.side == who_just_went:
				if unit.is_alive():
					score.numerical_advantage += 1
					score.health_advantage += unit.current_health
					if our_lowest_health > unit.current_health:
						our_lowest_health = unit.current_health
			else:
				if unit.is_alive():
					score.numerical_advantage -= 1
					score.health_advantage -= unit.current_health
					if their_lowest_health > unit.current_health:
						their_lowest_health = unit.current_health
		score.min_health_advantage = our_lowest_health - their_lowest_health
		if calculus_get_score != CalculusGetScore.Default:
			score = score.reversed()

	return score
