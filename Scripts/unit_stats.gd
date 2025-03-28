class_name UnitStats extends RefCounted

enum Side { NEITHER, HUMAN, COMPUTER }
enum Icon { UNSET, Dwarf, Halfling, Human, Orc, Goblin, Ogre, Ratman, Elf, Skeleton, SkeletonKing, Demon, Spider, MantisDrone, MantisQueen, Chronotyrant, Kobald, Moonman, PikeDragon, Slime_Green, Slime_Blue, Ooze, Gelatinous_Cube }

const difficulty_base : float = 3
const difficulty_mult : float = 15

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
var damage_shield : float = 0
var next_attack : float
var bleeding_ticks : int = 0
var unit_name : String
var side : UnitStats.Side
var icon : Icon = Icon.UNSET
var undead : bool = false
var blocking : int = -1
var elo : Array[String]
var skill_class : SkillStats.SkillClass = SkillStats.SkillClass.NONE
var skills : Array[SkillStats]

static var next_id : int = 1
static var noise : RandomNumberGenerator = RandomNumberGenerator.new()

static func create_difficulty_foes(difficulty : float, rnd : RandomNumberGenerator, encounter_type : PathEncounterStat.EncounterType) -> Array[UnitStats]:
	match encounter_type:
		PathEncounterStat.EncounterType.GOBLIN:
			return create_difficulty_foes_gate_fight(difficulty, rnd)
		PathEncounterStat.EncounterType.SPIDERS:
			return create_difficulty_foes_spider_fight(difficulty, rnd)
		PathEncounterStat.EncounterType.SLIMES:
			return create_difficulty_foes_slime_fight(difficulty, rnd)
		PathEncounterStat.EncounterType.DRACONIC:
			return create_difficulty_foes_dragon_fight(difficulty, rnd)
		PathEncounterStat.EncounterType.UNDEAD:
			return create_difficulty_foes_undead_fight(difficulty, rnd)
		PathEncounterStat.EncounterType.CHRONOTYRANT:
			return create_difficulty_foes_chronotyrant(rnd)
		_:
			assert(false)
	return []

static func create_difficulty_foes_chronotyrant(rnd : RandomNumberGenerator) -> Array[UnitStats]:
	var ret_val : Array[UnitStats]
	var foe : UnitStats = UnitStats.new()
	foe.init(UnitMod.s_species_chronotyrant, UnitMod.s_occupation_chronotyrant, UnitMod.s_equipment_chronotyrant, UnitStats.Side.COMPUTER, rnd)
	foe.unit_name = "The Chronotyrant"
	ret_val.append(foe)
	return ret_val

static func create_difficulty_foes_dragon_fight(difficulty : float, rnd : RandomNumberGenerator) -> Array[UnitStats]:
	difficulty += difficulty_base
	difficulty *= difficulty_mult
	var ret_val : Array[UnitStats]
	while difficulty >= 10 && ret_val.size() < 5:
		var selector : Array[int]
		if difficulty < 35:
			selector.append(10)
		if difficulty > 25 && difficulty < 75:
			selector.append(20)
		if difficulty > 60:
			selector.append(40)
		var v = selector[rnd.randi_range(0, selector.size() - 1)]
		var foe : UnitStats = UnitStats.new()
		match v:
			10:
				foe.init(UnitMod.s_species_kobald, UnitMod.s_occupation_dragonkin, UnitMod.s_equipment_dragonkin, UnitStats.Side.COMPUTER, rnd)
				foe.unit_name = "Kobold"
			20:
				foe.init(UnitMod.s_species_kobald_elite, UnitMod.s_occupation_dragonkin, UnitMod.s_equipment_dragonkin, UnitStats.Side.COMPUTER, rnd)
				foe.unit_name = "Kobald Elite"
			40:
				if rnd.randf() < 0.66:
					foe.init(UnitMod.s_species_moonman, UnitMod.s_occupation_dragonkin, UnitMod.s_equipment_dragonkin, UnitStats.Side.COMPUTER, rnd)
					foe.unit_name = "Moon Worm"
				else:
					foe.init(UnitMod.s_species_pike_dragon, UnitMod.s_occupation_dragonkin, UnitMod.s_equipment_dragonkin, UnitStats.Side.COMPUTER, rnd)
					foe.unit_name = "Pike Dragon"
		ret_val.append(foe)
		difficulty -= v
	return ret_val

static func create_difficulty_foes_undead_fight(difficulty : float, rnd : RandomNumberGenerator) -> Array[UnitStats]:
	difficulty += difficulty_base
	difficulty *= difficulty_mult
	var ret_val : Array[UnitStats]
	while difficulty >= 10 && ret_val.size() < 5:
		var selector : Array[int]
		if difficulty < 35:
			selector.append(10)
		if difficulty > 25 && difficulty < 75:
			selector.append(20)
		if difficulty > 60:
			selector.append(40)
		var v = selector[rnd.randi_range(0, selector.size() - 1)]
		var foe : UnitStats = UnitStats.new()
		match v:
			10:
				foe.init(UnitMod.s_species_skeleton, UnitMod.s_occupation_undead_physical, UnitMod.s_equipment_undead, UnitStats.Side.COMPUTER, rnd)
				foe.unit_name = "Skeleton"
			20:
				foe.init(UnitMod.s_species_skeleton, UnitMod.s_occupation_undead_mage, UnitMod.s_equipment_undead, UnitStats.Side.COMPUTER, rnd)
				foe.unit_name = "Skeleton Mage"
			40:
				if rnd.randf() < 0.66:
					foe.init(UnitMod.s_species_skeleton_king, UnitMod.s_occupation_undead_physical, UnitMod.s_equipment_undead, UnitStats.Side.COMPUTER, rnd)
					foe.unit_name = "Skeleton King"
				else:
					foe.init(UnitMod.s_species_demon, UnitMod.s_occupation_demon, UnitMod.s_equipment_undead, UnitStats.Side.COMPUTER, rnd)
					foe.unit_name = "Demon"
		foe.undead = true
		ret_val.append(foe)
		difficulty -= v
	return ret_val

static func create_difficulty_foes_gate_fight(difficulty : float, rnd : RandomNumberGenerator) -> Array[UnitStats]:
	difficulty += difficulty_base
	difficulty *= difficulty_mult
	var ret_val : Array[UnitStats]
	while difficulty >= 10 && ret_val.size() < 5:
		var selector : Array[int]
		if difficulty < 35:
			selector.append(10)
		if difficulty > 25 && difficulty < 75:
			selector.append(20)
		if difficulty > 60:
			selector.append(40)
		var v = selector[rnd.randi_range(0, selector.size() - 1)]
		var foe : UnitStats = UnitStats.new()
		match v:
			10:
				foe.init(UnitMod.s_species_goblin, UnitMod.s_occupation_guard, UnitMod.s_equipment_guard_gear, UnitStats.Side.COMPUTER, rnd)
				foe.unit_name = "Goblin Guard"
			20:
				foe.init(UnitMod.s_species_goblin, UnitMod.s_occupation_guard_sgt, UnitMod.s_equipment_guard_gear, UnitStats.Side.COMPUTER, rnd)
				foe.unit_name = "Goblin Sargent"
			40:
				if rnd.randf() > 0.5:
					foe.init(UnitMod.s_species_goblin, UnitMod.s_occupation_guard_cpt, UnitMod.s_equipment_cpt_gear, UnitStats.Side.COMPUTER, rnd)
					foe.unit_name = "Goblin Captain"
				else:
					foe.init(UnitMod.s_species_ogre, UnitMod.s_occupation_guard_lord, UnitMod.s_equipment_lord_gear, UnitStats.Side.COMPUTER, rnd)
					foe.unit_name = "Ogre Lord"
		ret_val.append(foe)
		difficulty -= v
	return ret_val

static func create_difficulty_foes_slime_fight(difficulty : float, rnd : RandomNumberGenerator) -> Array[UnitStats]:
	difficulty += difficulty_base
	difficulty *= difficulty_mult
	var ret_val : Array[UnitStats]
	var can_generate_ooze : bool = true
	while difficulty >= 10 && ret_val.size() < 5:
		var selector : Array[int]
		if difficulty <= 30:
			selector.append(10)
		if difficulty >= 30:
			if can_generate_ooze:
				selector.append(20)
			else:
				selector.append(10)
		if difficulty >= 50:
			selector.append(40)
		var v = selector[rnd.randi_range(0, selector.size() - 1)]
		var foe : UnitStats = UnitStats.new()
		match v:
			10:
				if rnd.randf() < 0.5:
					foe.init(UnitMod.s_species_slime_green, UnitMod.s_occupation_slime, UnitMod.s_equipment_slime, UnitStats.Side.COMPUTER, rnd)
					foe.unit_name = "Green Slime"
				else:
					foe.init(UnitMod.s_species_slime_blue, UnitMod.s_occupation_slime, UnitMod.s_equipment_slime, UnitStats.Side.COMPUTER, rnd)
					foe.unit_name = "Blue Slime"
			20:
				foe.init(UnitMod.s_species_ooze, UnitMod.s_occupation_slime, UnitMod.s_equipment_slime, UnitStats.Side.COMPUTER, rnd)
				foe.unit_name = "Ooze"
				# It feels bad when there's multiple oozes in a pack, as they just protect everything and it takes forever
				can_generate_ooze = false
			40:
				foe.init(UnitMod.s_species_gelatinous_cube, UnitMod.s_occupation_slime, UnitMod.s_equipment_slime, UnitStats.Side.COMPUTER, rnd)
				foe.unit_name = "Gelatinous Cube"
		ret_val.append(foe)
		difficulty -= v
	return ret_val

static func create_difficulty_foes_spider_fight(difficulty : float, rnd : RandomNumberGenerator) -> Array[UnitStats]:
	difficulty += difficulty_base
	difficulty *= difficulty_mult
	var ret_val : Array[UnitStats]
	while difficulty >= 10 && ret_val.size() < 5:
		var selector : Array[int]
		if difficulty <= 70:
			selector.append(10)
		if difficulty >= 60:
			selector.append(40)
		var v = selector[rnd.randi_range(0, selector.size() - 1)]
		var foe : UnitStats = UnitStats.new()
		match v:
			10:
				if rnd.randf() < 0.5:
					foe.init(UnitMod.s_species_spider, UnitMod.s_occupation_spider, UnitMod.s_equipment_great_spider, UnitStats.Side.COMPUTER, rnd)
					foe.unit_name = "Great Spider"
				else:
					foe.init(UnitMod.s_species_spider, UnitMod.s_occupation_spider, UnitMod.s_equipment_large_spider, UnitStats.Side.COMPUTER, rnd)
					foe.unit_name = "Large Spider"
			40:
				if rnd.randf() < 0.66:
					foe.init(UnitMod.s_species_mantis_drone, UnitMod.s_occupation_mantis, UnitMod.s_equipment_mantis_drone, UnitStats.Side.COMPUTER, rnd)
					foe.unit_name = "Mantis Drone"
				else:
					foe.init(UnitMod.s_species_mantis_queen, UnitMod.s_occupation_mantis, UnitMod.s_equipment_mantis_queen, UnitStats.Side.COMPUTER, rnd)
					foe.unit_name = "Mantis Queen"
		ret_val.append(foe)
		difficulty -= v
	return ret_val

static func load_hero(species : UnitMod, occupation : UnitMod, equipment : UnitMod, hero_name : String) -> UnitStats:
	var ret_val : UnitStats = UnitStats.new()
	ret_val.init_with_name(species, occupation, equipment, Side.HUMAN, hero_name)
	return ret_val

static func create_shuffle_hero(index : int, species : Array[UnitMod], occupation : Array[UnitMod], equipment : Array[UnitMod], rnd : RandomNumberGenerator) -> UnitStats:
	var ret_val : UnitStats = UnitStats.new()
	ret_val.init(species[index], occupation[index], equipment[index], Side.HUMAN, rnd)
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
	ret_val.icon = icon
	ret_val.max_health = max_health
	ret_val.armor = armor
	ret_val.current_health = current_health
	ret_val.bleeding_ticks = bleeding_ticks
	ret_val.attacks = attacks
	ret_val.slowness = slowness
	ret_val.next_attack = next_attack
	ret_val.side = side
	ret_val.tired = tired
	ret_val.damage_shield = damage_shield
	ret_val.magic_shield = magic_shield
	ret_val.cooldown_id = cooldown_id
	ret_val.single_use = single_use
	ret_val.unit_name = unit_name # We need this for the trip sheet
	ret_val.undead = undead
	ret_val.blocking = blocking
	
	# The following members should need to be cloned while evaluating future turns
	# ret_val.skill_class
	# ret_val.skills
	
	return ret_val

func create_skill_select_tooltip() -> String:
	var ret_val : String = "Attacks: " if attacks.size() > 1 else "Attacks: "
	for index in range(0, attacks.size()):
		if index > 0:
			ret_val += ", "
		ret_val += attacks[index].attack_name
	var learned_skills : String = describe_learned_skills()
	if !learned_skills.is_empty():
		ret_val += "\n" + learned_skills
	return ret_val

func create_summary() -> String:
	var ret_val : String = unit_name
	if armor > 0:
		ret_val += "\n" + str(armor) + " armor"
		if bleeding_ticks > 0:
			ret_val += ", bleeding"
	elif bleeding_ticks > 0:
		ret_val += "\nbleeding"
	if damage_shield != 0:
		assert(damage_shield > 0)
		ret_val += "\n" + str(damage_shield) + " retaliation"
	for index in range(0, attacks.size()):
		if !ret_val.is_empty():
			ret_val += "\n"
		ret_val += attacks[index].get_summary()
	return ret_val

func create_tooltip() -> String:
	var ret_val : String = unit_name
	if armor > 0:
		ret_val += "\n" + str(armor) + " armor"
		if bleeding_ticks > 0:
			ret_val += ", bleeding"
	elif bleeding_ticks > 0:
		ret_val += "\nbleeding"
	if damage_shield != 0:
		assert(damage_shield > 0)
		ret_val += "\nUnprotected attackers take " + str(damage_shield) + " retaliation damage"
	ret_val += "\n"
	if attacks.size() > 1:
		ret_val += "Attack: "
	else:
		ret_val += "Attacks: "
	for index in range(0, attacks.size()):
		if index > 0:
			ret_val += ", "
		ret_val += attacks[index].attack_name
	return ret_val

const icon_human : Texture = preload("res://Art/Species_Human.png")
const icon_dwarf : Texture = preload("res://Art/Species_Dwarf.png")
const icon_halfling : Texture = preload("res://Art/Species_Halfling.png")
const icon_orc : Texture = preload("res://Art/Species_Orc.png")
const icon_goblin : Texture = preload("res://Art/Species_Goblin.png")
const icon_ogre : Texture = preload("res://Art/Species_Ogre.png")
const icon_ratman : Texture = preload("res://Art/Species_Ratman.png")
const icon_elf : Texture = preload("res://Art/Species_Elf.png")
const icon_skeleton : Texture = preload("res://Art/Species_Skeleton.png")
const icon_skeleton_king : Texture = preload("res://Art/Species_Skeleton_King.png")
const icon_demon : Texture = preload("res://Art/Species_Demon.png")
const icon_spider : Texture = preload("res://Art/Species_Spider.png")
const icon_mantis_queen : Texture = preload("res://Art/Species_Bugman.png")
const icon_mantis_drone : Texture = preload("res://Art/Species_Mantis.png")
const icon_cronotyrant : Texture = preload("res://Art/Chronotyrant.png")
const icon_kobald : Texture = preload("res://Art/Species_Kobald.png")
const icon_moonman : Texture = preload("res://Art/Species_Moonman.png")
const icon_pikedragon : Texture = preload("res://Art/Species_BirdDragon.png")
const icon_slime_green : Texture = preload("res://Art/Species_Slime_Green.png")
const icon_slime_blue : Texture = preload("res://Art/Species_Slime_Blue.png")
const icon_ooze : Texture = preload("res://Art/Species_Ooze.png")
const icon_gelatinous_cube : Texture = preload("res://Art/Species_Gelatinous_Cube.png")

func get_texture() -> Texture:
	match icon:
		UnitStats.Icon.Kobald:
			return icon_kobald
		UnitStats.Icon.Moonman:
			return icon_moonman
		UnitStats.Icon.PikeDragon:
			return icon_pikedragon
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
		UnitStats.Icon.Ogre:
			return icon_ogre
		UnitStats.Icon.Ratman:
			return icon_ratman
		UnitStats.Icon.Elf:
			return icon_elf
		UnitStats.Icon.Skeleton:
			return icon_skeleton
		UnitStats.Icon.SkeletonKing:
			return icon_skeleton_king
		UnitStats.Icon.Demon:
			return icon_demon
		UnitStats.Icon.Spider:
			return icon_spider
		UnitStats.Icon.MantisDrone:
			return icon_mantis_drone
		UnitStats.Icon.MantisQueen:
			return icon_mantis_queen
		UnitStats.Icon.Slime_Green:
			return icon_slime_green
		UnitStats.Icon.Slime_Blue:
			return icon_slime_blue
		UnitStats.Icon.Ooze:
			return icon_ooze
		UnitStats.Icon.Gelatinous_Cube:
			return icon_gelatinous_cube
		UnitStats.Icon.Chronotyrant:
			return icon_cronotyrant
			
	return null

func get_health_desc() -> String:
	if is_alive():
		var text : String = str(max(1, round(current_health))) + "/" + str(round(max_health))
		if bleeding_ticks > 0:
			text += ", bleed"
		return text
	else:
		return "dead"

func describe_learned_skills() -> String:
	var ret_val : String = ""
	if skills.is_empty():
		return ret_val
	for skill : SkillStats in skills:
		if !ret_val.is_empty():
			ret_val += "\n"
		ret_val += skill.describe_skill()
	return ret_val

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

func init_with_name(_species : UnitMod, _occupation : UnitMod, _equipment : UnitMod, _side : UnitStats.Side, hero_name : String) -> void:
	init_base(_species, _occupation, _equipment, _side, hero_name)

func init(_species : UnitMod, _occupation : UnitMod, _equipment : UnitMod, _side : UnitStats.Side, rnd : RandomNumberGenerator) -> void:
	var hero_name : String = "???"
	if _species.will_name():
		hero_name = _species.generate_name(rnd)
	else:
		hero_name = UnitStats.Side.keys()[_side] + "/" + _species.elo_name + "/" + _occupation.elo_name + "/" + _equipment.elo_name + "#" + str(id)
	init_base(_species, _occupation, _equipment, _side, hero_name)

func init_base(_species : UnitMod, _occupation : UnitMod, _equipment : UnitMod, _side : UnitStats.Side, _hero_name : String) -> void:
	id = next_id
	next_id += 1
	
	side = _side
	max_health = 100 + _species.extra_health + _occupation.extra_health + _equipment.extra_health
	current_health = max_health
	skill_class = _occupation.skill_class
	armor = _species.extra_armor + _occupation.extra_armor + _equipment.extra_armor
	slowness = 10 + _species.extra_slowness + _occupation.extra_slowness + _equipment.extra_slowness
	next_attack = slowness + noise.randf_range(0, 0.01)
	damage_shield = _species.damage_shield + _occupation.damage_shield + _equipment.damage_shield
	unit_name = _hero_name
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

func apply_damage_to_shield_or_health(dmg : float) -> bool:
	if magic_shield > dmg:
		magic_shield -= dmg
		dmg = 0
	elif magic_shield > 0:
		dmg -= magic_shield
		magic_shield = 0
	current_health -= dmg
	return dmg > 1

func calculate_damage_from_attack(attack : AttackStats) -> float:
	var dmg : float = attack.damage
	
	if attack.divine_wrath:
		if icon == Icon.Chronotyrant || undead:
			dmg *= 2.5
		else:
			dmg /= 2.5
	
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
