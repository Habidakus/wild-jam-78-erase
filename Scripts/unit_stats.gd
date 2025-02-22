class_name UnitStats extends RefCounted

enum Side { NEITHER, HUMAN, COMPUTER }
enum Icon { UNSET, Dwarf, Halfling, Human, Orc, Goblin, Ratman, Elf }

var id : int = -1
var max_health : float
var armor : float = 0
var current_health : float
var magic_shield : float = 0
var tired : float = 1
var cooldown_id : int = -1
var single_use : bool
var attacks : Array[AttackStats]
var slowness : float
var next_attack : float
var bleeding_ticks : int = 0
var unit_name : String
var side : UnitStats.Side
var icon : Icon = Icon.UNSET
var undead : bool = false
var elo : Array[String]
var skill_class : SkillStats.SkillClass = SkillStats.SkillClass.NONE
var skills : Array[SkillStats]

static var next_id : int = 1
static var noise : RandomNumberGenerator = RandomNumberGenerator.new()

static func create_foes__goblin(rnd : RandomNumberGenerator, sgt : bool) -> UnitStats:
	var ret_val : UnitStats = UnitStats.new()
	if sgt:
		ret_val.init(UnitMod.s_species_goblin, UnitMod.s_occupation_guard_sgt, UnitMod.s_equipment_guard_gear, UnitStats.Side.COMPUTER, rnd)
		ret_val.unit_name = "Goblin Sargent"
	else:
		ret_val.init(UnitMod.s_species_goblin, UnitMod.s_occupation_guard, UnitMod.s_equipment_guard_gear, UnitStats.Side.COMPUTER, rnd)
		ret_val.unit_name = "Goblin Guard"
	return ret_val

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

static func select_two_lowest_amount(objs : Array[UnitStats], functor) -> Array[UnitStats]:
	if objs.size() < 3:
		return objs
	var min_value : float
	var best_obj : Object = null
	var second_value : float
	var second_obj : Object = null
	for obj in objs:
		var value : float = functor.call(obj)
		if best_obj == null:
			min_value = value
			best_obj = obj
		elif second_obj == null:
			if value < min_value:
				second_value = min_value
				second_obj = best_obj
				min_value = value
				best_obj = obj
			else:
				second_value = value
				second_obj = obj
		elif value < min_value:
			second_value = min_value
			second_obj = best_obj
			min_value = value
			best_obj = obj
		elif value < second_value:
			second_value = value
			second_obj = obj
	return [best_obj, second_obj]

func prepare_for_next_battle(post_battle_version : UnitStats) -> void:
	current_health = post_battle_version.current_health
	magic_shield = 0

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
	ret_val.side = side
	ret_val.tired = tired
	ret_val.magic_shield = magic_shield
	ret_val.cooldown_id = cooldown_id
	ret_val.single_use = single_use
	ret_val.unit_name = unit_name # We need this for the trip sheet
	
	# The following members should need to be cloned while evaluating future turns
	# ret_val.skill_class
	# ret_val.skills
	# ret_val.undead
	
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

const icon_human : Texture = preload("res://Art/Species_Human.png")
const icon_dwarf : Texture = preload("res://Art/Species_Dwarf.png")
const icon_halfling : Texture = preload("res://Art/Species_Halfling.png")
const icon_orc : Texture = preload("res://Art/Species_Orc.png")
const icon_goblin : Texture = preload("res://Art/Species_Goblin.png")
const icon_ratman : Texture = preload("res://Art/Species_Ratman.png")
const icon_elf : Texture = preload("res://Art/Species_Elf.png")
func get_texture() -> Texture:
	match icon:
		UnitStats.Icon.Human:
			return icon_human
		UnitStats.Icon.Dwarf:
			return icon_dwarf
		UnitStats.Icon.Halfling:
			return icon_halfling
		UnitStats.Icon.Orc:
			return icon_orc
		UnitStats.Icon.Goblin:
			return icon_goblin
		UnitStats.Icon.Ratman:
			return icon_ratman
		UnitStats.Icon.Elf:
			return icon_elf
	return null

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

func get_magic_shield() -> float:
	return magic_shield

func get_moves(units : Array[UnitStats], allow_stupid_humans : bool) -> Array[MMCAction]:
	var ret_val : Array[MMCAction]
	for attack : AttackStats in attacks:
		var actions : Array[MMCAction] = attack.get_moves(self, units, allow_stupid_humans)
		ret_val.append_array(actions)
	return ret_val

func init(_species : UnitMod, _occupation : UnitMod, _equipment : UnitMod, _side : UnitStats.Side, rnd : RandomNumberGenerator) -> void:
	id = next_id
	next_id += 1
	
	side = _side
	max_health = 100 + _species.extra_health + _occupation.extra_health + _equipment.extra_health
	current_health = max_health
	skill_class = _occupation.skill_class
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
	if _species.has_icon():
		icon = _species.get_icon()
	elif _occupation.has_icon():
		icon = _occupation.get_icon()
	elif _equipment.has_icon():
		icon = _equipment.get_icon()
	assert(attacks.filter(func(a : AttackStats) : return a.single_use).size() < 2)

func clear_cooldowns() -> void:
	cooldown_id = -1

func has_cooldown(cid : int) -> bool:
	return cid == cooldown_id

func set_cooldown(cid : int) -> void:
	cooldown_id = cid

func set_single_use() -> void:
	single_use = true

func has_used() -> bool:
	return single_use

func add_attacks(_attacks : Array[AttackStats]) -> void:
	attacks.append_array(_attacks)

func get_time_until_action() -> float:
	return next_attack

func calculate_damage_from_attack(attack : AttackStats) -> float:
	var dmg : float = attack.damage
	if attack.stun > 0:
		dmg *= (1.0 - attack.stun)
	if attack.acts_on_allies:
		return max(0, min(max_health - current_health, dmg))
		
	var magic_shield_dmg : float = 0
	if magic_shield > 0:
		if dmg <= magic_shield:
			return dmg
		magic_shield_dmg = magic_shield
		dmg -= magic_shield
		
	if !attack.armor_piercing:
		dmg -= armor
		if dmg < 1:
			dmg = 1

	if dmg < 0:
		dmg = 0
	
	return dmg + magic_shield_dmg
