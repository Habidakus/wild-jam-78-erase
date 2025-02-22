class_name SkillStats extends RefCounted

enum SkillScope { SELF, FOE_UNDEAD, ALL_HEROES, ALL_DEAD_HEROES }
enum SkillClass { NONE, ROGUE, FIGHTER, HOLY, MAGIC }
enum SkillPhase { NONE, POST_COMBAT, PRE_COMBAT }

var skill_name : String = "???"
var max_level : int = 1
var current_level : int = 1
var scope : SkillScope = SkillScope.SELF
var skill_class : SkillClass = SkillClass.NONE
var phase : SkillPhase = SkillPhase.NONE
var adjust_initiative : float = 0
var adjust_health : float = 0
var shield : float = 0
var desc : String = "???"

func apply(_phase : SkillPhase, hero : UnitStats, heroes : Array[UnitStats], foes : Array[UnitStats]) -> void:
	if phase != _phase:
		return
	match scope:
		SkillScope.SELF:
			apply_to_unit(hero)
		SkillScope.FOE_UNDEAD:
			for foe : UnitStats in foes:
				if foe.undead:
					apply_to_unit(foe)
		SkillScope.ALL_HEROES:
			for unit : UnitStats in heroes:
				apply_to_unit(unit)
		SkillScope.ALL_DEAD_HEROES:
			for unit : UnitStats in heroes:
				if !unit.is_alive():
					apply_to_unit(unit)

func apply_to_unit(unit : UnitStats) -> void:
	if adjust_health != 0:
		print()
		var new_health : float = min(unit.current_health + unit.max_health * adjust_health * current_level, unit.max_health)
		print("Healing " + unit.unit_name + " for " + str(new_health - unit.current_health) + " hp")
		unit.current_health = new_health
	if adjust_initiative != 0:
		unit.next_attack += adjust_initiative * current_level
		print("lowering " + unit.unit_name + " initiative by " + str(adjust_initiative * current_level)  + " seconds")
	if shield != 0:
		print("TODO: Implement SHIELD skill")

func generate_next_level() -> SkillStats:
	var ret_val : SkillStats = SkillStats.new()
	ret_val.skill_name = skill_name
	ret_val.max_level = max_level
	ret_val.current_level = current_level + 1
	ret_val.scope = scope
	ret_val.skill_class = skill_class
	ret_val.phase = phase
	ret_val.adjust_initiative = adjust_initiative
	ret_val.adjust_health = adjust_health
	ret_val.shield = shield
	ret_val.desc = desc
	return ret_val

func set_description(d : String) -> SkillStats:
	desc = d
	return self

static func create_skill_stealth() -> SkillStats:
	return create("Stealth", 3, SkillPhase.PRE_COMBAT, SkillClass.ROGUE, SkillScope.SELF).mod_initiative(-3.33).set_description("This hero attacks well before everyone else on the field.")
static func create_skill_ambush() -> SkillStats:
	return create("Ambush", 10, SkillPhase.PRE_COMBAT, SkillClass.ROGUE, SkillScope.ALL_HEROES).mod_initiative(-1).set_description("This hero helps the rest of the party set up an ambush, allowing them possible extra attacks at the start of combat.")

static func create_skill_healing_herbs() -> SkillStats:
	return create("Healing Herbs", 4, SkillPhase.POST_COMBAT, SkillClass.FIGHTER, SkillScope.ALL_HEROES).mod_health(0.15).set_description("This hero knows how to prepare a tea of healing herbs between combats, helping restore the health of all wounded allies.")
static func create_skill_walk_it_off() -> SkillStats:
	return create("Walk It Off", 3, SkillPhase.POST_COMBAT, SkillClass.FIGHTER, SkillScope.SELF).mod_health(0.25).set_description("This hero is a veteran of patching themselves up, and heals quickly between combats.")

static func create_skill_healing_prayer() -> SkillStats:
	return create("Healing Prayer", 2, SkillPhase.POST_COMBAT, SkillClass.HOLY, SkillScope.ALL_DEAD_HEROES).mod_health(0.25).set_description("This holy hero helps restore the health of anyone who was defeated in a previous combat.")
static func create_skill_turn_undead() -> SkillStats:
	return create("Turn Undead", 2, SkillPhase.PRE_COMBAT, SkillClass.HOLY, SkillScope.FOE_UNDEAD).mod_health(-0.25).set_description("This holy hero inflicts special damage on all undead before combat is joined.")

static func create_skill_magic_shield() -> SkillStats:
	return create("Magic Shield", 2, SkillPhase.PRE_COMBAT, SkillClass.MAGIC, SkillScope.SELF).mod_shield(50).set_description("This magic hero is skilled in protecting themselves with a magic shield that is prepared before combat.")
static func create_skill_group_shield() -> SkillStats:
	return create("Group Shield", 2, SkillPhase.PRE_COMBAT, SkillClass.MAGIC, SkillScope.ALL_HEROES).mod_shield(15).set_description("This magic hero casts a minor shield spell on all their allies")

static var all_base_skills : Array[SkillStats] = [
	create_skill_ambush(),
	create_skill_group_shield(),
	create_skill_healing_herbs(),
	create_skill_healing_prayer(),
	create_skill_magic_shield(),
	create_skill_stealth(),
	create_skill_turn_undead(),
	create_skill_walk_it_off(),
]

func can_use(unit : UnitStats) -> bool:
	return unit.skill_class == skill_class

func at_max() -> bool:
	return current_level == max_level
	
static func get_viable_skills(units : Array[UnitStats]) -> Array[Array]:
	var ret_val : Array[Array]
	for unit : UnitStats in units:
		for skill : SkillStats in all_base_skills:
			var found_match : Array[SkillStats] = unit.skills.filter(func(a : SkillStats) : return a.skill_name == skill.skill_name)
			if found_match.is_empty():
				if skill.can_use(unit):
					ret_val.append([unit, skill])
			elif found_match.size() == 1:
				if !found_match[0].at_max():
					ret_val.append([unit, found_match[0].generate_next_level()])
			else:
				assert(false, "too many matches")
	return ret_val

func add_to_unit(unit : UnitStats) -> void:
	var found_match : Array[SkillStats] = unit.skills.filter(func(a : SkillStats) : return a.skill_name == skill_name)
	if found_match.is_empty():
		assert(can_use(unit))
		unit.skills.append(self)
	elif found_match.size() == 1:
		assert(!found_match[0].at_max())
		found_match[0].current_level += 1
	else:
		assert(false, "too many matches")
	

static func create(_skill_name : String, _max_level : int, _phase : SkillPhase, _class : SkillClass, _scope : SkillScope) -> SkillStats:
	var ret_val : SkillStats = SkillStats.new()
	ret_val.skill_name = _skill_name
	ret_val.max_level = _max_level
	ret_val.phase = _phase
	ret_val.skill_class = _class
	ret_val.scope = _scope
	return ret_val

func mod_initiative(v : float) -> SkillStats:
	adjust_initiative += v
	return self

func mod_health(v : float) -> SkillStats:
	adjust_health += v
	return self

func mod_shield(v : float) -> SkillStats:
	shield += v
	return self

func generate_description() -> String:
	return "Description:\n\n" + desc
