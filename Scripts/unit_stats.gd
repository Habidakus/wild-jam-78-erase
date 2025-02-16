class_name UnitStats extends RefCounted

enum Side { NEITHER, HUMAN, COMPUTER }

var id : int = -1
var max_health : float
var armor : float = 0
var current_health : float
var tired : float = 1
var attacks : Array[AttackStats]
var slowness : float
var next_attack : float
var unit_name : String
var side : UnitStats.Side
var elo : Array[String]

static var next_id : int = 1
static var noise : RandomNumberGenerator = RandomNumberGenerator.new()

static func create_random(rnd : RandomNumberGenerator, _side : UnitStats.Side) -> UnitStats:
	var ret_val : UnitStats = UnitStats.new()
	var species : UnitMod = UnitMod.pick_random_species(rnd)
	var occupation : UnitMod = UnitMod.pick_random_occupation(rnd)
	var equipment : UnitMod = UnitMod.pick_random_equipment(rnd)
	ret_val.init(species, occupation, equipment, _side)
	return ret_val

static func create_random_hero(rnd : RandomNumberGenerator) -> UnitStats:
	var ret_val : UnitStats = UnitStats.new()
	ret_val.init_old(create_random_hero_name(rnd), 100, 0, 10, UnitStats.Side.HUMAN)
	ret_val.add_attack(AttackStats.get_default_attack())
	ret_val.add_attack(AttackStats.get_arrow_attack())
	ret_val.add_attack(AttackStats.get_lunge_attack())
	return ret_val

static func create_random_foe(rnd : RandomNumberGenerator) -> UnitStats:
	var ret_val : UnitStats = UnitStats.new()
	ret_val.init_old(create_random_foe_name(rnd), 100, 0, 10, UnitStats.Side.COMPUTER)
	ret_val.add_attack(AttackStats.get_default_attack())
	ret_val.add_attack(AttackStats.get_smash_attack())
	ret_val.add_attack(AttackStats.get_backstab_attack())
	return ret_val

static func create_random_hero_name(rnd : RandomNumberGenerator) -> String:
	var ret_val : String = ""
	match rnd.randi_range(0, 4): #inclusive,inclusive
		0:
			ret_val = "Ja"
		1:
			ret_val = "Po"
		2:
			ret_val = "Ana"
		3:
			ret_val = "Mi"
		4:
			ret_val = "By"
	match rnd.randi_range(0, 4): #inclusive,inclusive
		0:
			ret_val += "so"
		1:
			ret_val += "rte"
		2:
			ret_val += "ti"
		3:
			ret_val += "se"
		4:
			ret_val += "ra"
	match rnd.randi_range(0, 4): #inclusive,inclusive
		0:
			ret_val += "n"
		1:
			ret_val += "r"
		2:
			ret_val += "na"
		3:
			ret_val += "nus"
		4:
			ret_val += "cy"
	return ret_val

static func create_random_foe_name(rnd : RandomNumberGenerator) -> String:
	var ret_val : String = ""
	match rnd.randi_range(0, 4): #inclusive,inclusive
		0:
			ret_val = "Xa"
		1:
			ret_val = "Vo"
		2:
			ret_val = "Wa"
		3:
			ret_val = "Gru"
		4:
			ret_val = "Cru"
	match rnd.randi_range(0, 4): #inclusive,inclusive
		0:
			ret_val += "xa"
		1:
			ret_val += "pe"
		2:
			ret_val += "zi"
		3:
			ret_val += "va"
		4:
			ret_val += "wu"
	match rnd.randi_range(0, 4): #inclusive,inclusive
		0:
			ret_val += "x"
		1:
			ret_val += "ve"
		2:
			ret_val += "w"
		3:
			ret_val += "z"
		4:
			ret_val += "ck"
	return ret_val

static func get_other_side(s : UnitStats.Side) -> UnitStats.Side:
	if s == UnitStats.Side.HUMAN:
		return UnitStats.Side.COMPUTER
	elif s == UnitStats.Side.COMPUTER:
		return UnitStats.Side.HUMAN
	assert(false)
	return UnitStats.Side.NEITHER

static func to_array(unit : UnitStats) -> Array[UnitStats]:
	var ret_val : Array[UnitStats]
	ret_val.append(unit)
	return ret_val

static func select_lowest(objs : Array[UnitStats], functor) -> UnitStats:
	var min_value = null
	var best_obj : Object = null
	for obj in objs:
		var value : float = functor.call(obj)
		if best_obj == null || value < min_value:
			min_value = value
			best_obj = obj
	return best_obj

func clone() -> UnitStats:
	var ret_val : UnitStats = UnitStats.new()
	ret_val.id = id
	ret_val.max_health = max_health
	ret_val.armor = armor
	ret_val.current_health = current_health
	ret_val.attacks = attacks
	ret_val.slowness = slowness
	ret_val.next_attack = next_attack
	ret_val.unit_name = unit_name
	ret_val.side = side
	ret_val.tired = tired
	return ret_val

func get_health_desc() -> String:
	if is_alive():
		return str(max(1, round(current_health))) + "/" + str(round(max_health))
	else:
		return "dead"

func is_alive() -> bool:
	return current_health > 0

func get_moves(units : Array[UnitStats]) -> Array[MMCAction]:
	var ret_val : Array[MMCAction]
	for attack : AttackStats in attacks:
		var actions : Array[MMCAction] = attack.get_moves(self, units)
		ret_val.append_array(actions)
	return ret_val

func init(_species : UnitMod, _occupation : UnitMod, _equipment : UnitMod, _side : UnitStats.Side) -> void:
	id = next_id
	next_id += 1
	
	side = _side
	max_health = 100 + _species.extra_health + _occupation.extra_health + _equipment.extra_health
	current_health = max_health
	unit_name = UnitStats.Side.keys()[_side] + "/" + _species.elo_name + "/" + _occupation.elo_name + "/" + _equipment.elo_name + "#" + str(id)
	armor = _species.extra_armor + _occupation.extra_armor + _equipment.extra_armor
	slowness = 10 + _species.extra_slowness + _occupation.extra_slowness + _equipment.extra_slowness
	next_attack = slowness + noise.randf_range(0, 0.01)
	add_attack(_species.attack)
	add_attack(_occupation.attack)
	add_attack(_equipment.attack)
	elo.append(_species.elo_name)
	elo.append(_occupation.elo_name)
	elo.append(_equipment.elo_name)

func add_attack(attack : AttackStats) -> void:
	if attack != null:
		attacks.append(attack)

func init_old(_unit_name : String, health : float, _armor : float, _slowness : float, _side : UnitStats.Side) -> void:
	id = next_id
	next_id += 1

	unit_name = _unit_name
	max_health = health
	current_health = health
	armor = _armor
	slowness = _slowness
	side = _side
	next_attack = _slowness + noise.randf_range(0, 0.01)

func get_time_until_action() -> float:
	return next_attack

func calculate_damage_from_attack(attack : AttackStats) -> float:
	return attack.damage
