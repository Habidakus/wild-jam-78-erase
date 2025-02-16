class_name EAction extends MMCAction

var resulting_state : EGameState = null
var actorID : int = 0
var targetID : int = 0
var attack : AttackStats = null

func release() -> void:
	if resulting_state != null:
		resulting_state.release()
		resulting_state = null

static func create_pass() -> EAction:
	var ret_val : EAction = EAction.new()
	return ret_val

static func create(_actor : UnitStats, _target : UnitStats, _attack : AttackStats) -> EAction:
	var ret_val : EAction = EAction.new()
	ret_val.actorID = _actor.id
	ret_val.targetID = _target.id
	ret_val.attack = _attack
	return ret_val

func _to_string() -> String:
	if attack != null:
		var attacker : UnitStats = resulting_state.get_unit_by_id(actorID)
		var attacker_desc : String = attacker.unit_name # + " (tick=" + str(round(attacker.next_attack * 10.0) / 10.0) + ")"
		var target : UnitStats = resulting_state.get_unit_by_id(targetID)
		var target_desc : String = target.unit_name + " (" + target.get_health_desc() + ")"
		return attacker_desc + " " + attack.attack_name + " " + target_desc
	else:
		return UnitStats.Side.keys()[resulting_state.who_just_went] + " passes"

func get_score() -> MMCScore:
	return resulting_state.get_score()
