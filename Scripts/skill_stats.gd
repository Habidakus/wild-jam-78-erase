class_name SkillStats extends RefCounted

enum SkillScope { SELF, FOE_UNDEAD, ALL_HEROES, ALL_DEAD_HEROES }
enum SkillClass { NONE, ROGUE, FIGHTER, HOLY, MAGIC }
enum SkillPhase { NONE, POST_COMBAT, PRE_COMBAT, PRE_BOSS }

var skill_name : String = "???"
var max_level : int = 1
var current_level : int = 1
var scope : SkillScope = SkillScope.SELF
var skill_class : SkillClass = SkillClass.NONE
var phase : SkillPhase = SkillPhase.NONE

static func create_skill_stealth() -> SkillStats:
	return create("Stealth", 1, SkillPhase.PRE_COMBAT, SkillClass.ROGUE, SkillScope.SELF).mod_initiative(-20)
static func create_skill_ambush() -> SkillStats:
	return create("Ambush", 3, SkillPhase.PRE_COMBAT, SkillClass.ROGUE, SkillScope.ALL_HEROES).mod_initiative(-5)

static func create_skill_healing_herbs() -> SkillStats:
	return create("Healing Herbs", 4, SkillPhase.POST_COMBAT, SkillClass.FIGHTER, SkillScope.ALL_HEROES).mod_healing(0.15)
static func create_skill_walk_it_off() -> SkillStats:
	return create("Walk It Off", 3, SkillPhase.POST_COMBAT, SkillClass.FIGHTER, SkillScope.SELF).mod_healing(0.25)

static func create_skill_healing_prayer() -> SkillStats:
	return create("Healing Prayer", 2, SkillPhase.POST_COMBAT, SkillClass.HOLY, SkillScope.ALL_DEAD_HEROES).mod_healing(0.25)
static func create_skill_turn_undead() -> SkillStats:
	return create("Turn Undead", 2, SkillPhase.PRE_COMBAT, SkillClass.HOLY, SkillScope.FOE_UNDEAD).apply_damage_to_foe(0.1)

static func create_skill_magic_shield() -> SkillStats:
	return create("Magic Shield", 2, SkillPhase.PRE_COMBAT, SkillClass.MAGIC, SkillScope.SELF).mod_shield(50)
static func create_skill_group_shield() -> SkillStats:
	return create("Group Shield", 2, SkillPhase.PRE_COMBAT, SkillClass.MAGIC, SkillScope.ALL_HEROES).mod_shield(15)

static func create(_skill_name : String, _max_level : int, _phase : SkillPhase, _class : SkillClass, _scope : SkillScope) -> SkillStats:
	var ret_val : SkillStats = SkillStats.new()
	ret_val.skill_name = _skill_name
	ret_val.max_level = _max_level
	ret_val.phase = _phase
	ret_val.skill_class = _class
	ret_val.scope = _scope
	return ret_val
