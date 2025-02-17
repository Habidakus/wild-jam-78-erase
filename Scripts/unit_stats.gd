class_name UnitStats extends RefCounted

enum Side { NEITHER, HUMAN, COMPUTER }

var id : int = -1
var max_health : float
var armor : float = 0
var current_health : float
var tired : float = 1
var cooldown : int = 0
var attacks : Array[AttackStats]
var slowness : float
var next_attack : float
var bleeding_ticks : int = 0
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
	ret_val.init(species, occupation, equipment, _side, rnd)
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
	ret_val.bleeding_ticks = bleeding_ticks
	ret_val.attacks = attacks
	ret_val.slowness = slowness
	ret_val.next_attack = next_attack
	ret_val.unit_name = unit_name
	ret_val.side = side
	ret_val.tired = tired
	ret_val.cooldown = cooldown
	return ret_val

func create_tooltip() -> String:
	var ret_val : String = ""
	for e : String in elo:
		if !ret_val.is_empty():
			ret_val += ", "
		ret_val += e
	if armor > 0:
		if !ret_val.is_empty():
			ret_val += ", "
		ret_val += "Armor: " + str(armor)
	if bleeding_ticks > 0:
		if !ret_val.is_empty():
			ret_val += ", "
		ret_val += "Bleeding"
	return ret_val

func get_health_desc() -> String:
	if is_alive():
		var text : String = str(max(1, round(current_health))) + "/" + str(round(max_health))
		if bleeding_ticks > 0:
			text += ", bleed"
		return text
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

func init(_species : UnitMod, _occupation : UnitMod, _equipment : UnitMod, _side : UnitStats.Side, rnd : RandomNumberGenerator) -> void:
	id = next_id
	next_id += 1
	
	side = _side
	max_health = 100 + _species.extra_health + _occupation.extra_health + _equipment.extra_health
	current_health = max_health
	if _species.will_name():
		unit_name = _species.generate_name(rnd)
	else:
		unit_name = UnitStats.Side.keys()[_side] + "/" + _species.elo_name + "/" + _occupation.elo_name + "/" + _equipment.elo_name + "#" + str(id)
	armor = _species.extra_armor + _occupation.extra_armor + _equipment.extra_armor
	slowness = 10 + _species.extra_slowness + _occupation.extra_slowness + _equipment.extra_slowness
	next_attack = slowness + noise.randf_range(0, 0.01)
	add_attacks(_species.attacks)
	add_attacks(_occupation.attacks)
	add_attacks(_equipment.attacks)
	elo.append(_species.elo_name)
	elo.append(_occupation.elo_name)
	elo.append(_equipment.elo_name)

func add_attacks(_attacks : Array[AttackStats]) -> void:
	attacks.append_array(_attacks)

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
	var ret_val : float = attack.damage
	if attack.stun > 0:
		ret_val *= (1.0 - attack.stun)
	if attack.acts_on_allies:
		ret_val = min(max_health - current_health, ret_val)
	else:
		if !attack.armor_piercing:
			ret_val -= armor
			if ret_val < 1:
				ret_val = 1
	if ret_val < 0:
		ret_val = 0
	
	return ret_val
