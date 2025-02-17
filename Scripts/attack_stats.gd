class_name AttackStats extends RefCounted

var damage : float = 30
var stun : float = 0
var tiring : float = 1
var speed_multiple : float = 1.0
var attack_name : String
var acts_on_allies : bool = false
var armor_piercing : bool = false

enum AttackTarget { INVALID, FRONT_MOST, REAR_MOST, ANY, MOST_VULNERABLE, CLOSEST_TO_DEATH, FARTHEST_FROM_DEATH }
var attack_target : AttackTarget = AttackTarget.INVALID

static func create(_name : String, _attack_target : AttackTarget) -> AttackStats:
	var ret_val : AttackStats = AttackStats.new()
	ret_val.attack_name = _name
	ret_val.attack_target = _attack_target
	return ret_val

func tires(mod : float) -> AttackStats:
	tiring *= mod
	return self

func set_on_allies() -> AttackStats:
	acts_on_allies = true
	return self

func adjust_speed(mod : float) -> AttackStats:
	speed_multiple *= mod
	return self

func set_armor_piercing() -> AttackStats:
	armor_piercing = true
	return self

func adjust_damage(mod : float) -> AttackStats:
	damage *= mod
	return self

func set_stun(_stun : float) -> AttackStats:
	stun = _stun
	return self

static var s_default_attack : AttackStats = null
static func get_default_attack() -> AttackStats:
	if s_default_attack == null:
		s_default_attack = AttackStats.new()
		s_default_attack.attack_name = "SLOW WEAK MISAIMED"
		s_default_attack.attack_target = AttackTarget.FARTHEST_FROM_DEATH
		s_default_attack.adjust_damage(0.1)
		s_default_attack.adjust_speed(5)
	return s_default_attack

static var s_arrow_attack : AttackStats = null
static func get_arrow_attack() -> AttackStats:
	if s_arrow_attack == null:
		s_arrow_attack = AttackStats.new()
		s_arrow_attack.attack_name = "Arrow"
		s_arrow_attack.damage = 25
		s_arrow_attack.speed_multiple = 20.0 / 30.0
		s_arrow_attack.attack_target = AttackTarget.REAR_MOST
	return s_arrow_attack

static var s_lunge_attack : AttackStats = null
static func get_lunge_attack() -> AttackStats:
	if s_lunge_attack == null:
		s_lunge_attack = AttackStats.new()
		s_lunge_attack.attack_name = "Lunge"
		s_lunge_attack.damage = 25
		s_lunge_attack.speed_multiple = 20.0 / 30.0
		s_lunge_attack.attack_target = AttackTarget.FRONT_MOST
	return s_lunge_attack

static var s_backstab_attack : AttackStats = null
static func get_backstab_attack() -> AttackStats:
	if s_backstab_attack == null:
		s_backstab_attack = AttackStats.new()
		s_backstab_attack.attack_name = "Backstab"
		s_backstab_attack.damage = 50
		s_backstab_attack.speed_multiple = 65.0 / 30.0
		s_backstab_attack.attack_target = AttackTarget.CLOSEST_TO_DEATH
	return s_backstab_attack

static var s_smash_attack : AttackStats = null
static func get_smash_attack() -> AttackStats:
	if s_smash_attack == null:
		s_smash_attack = AttackStats.new()
		s_smash_attack.attack_name = "Smash"
		s_smash_attack.damage = 50
		s_smash_attack.speed_multiple = 45.0 / 30.0
		s_smash_attack.attack_target = AttackTarget.FARTHEST_FROM_DEATH
	return s_smash_attack

func get_targets(targets : Array[UnitStats]) -> Array[UnitStats]:
	match attack_target:
		AttackTarget.INVALID:
			assert(false)
		AttackTarget.FRONT_MOST:
			return UnitStats.to_array(UnitStats.select_lowest(targets, func(a : UnitStats) : return a.get_time_until_action()))
		AttackTarget.REAR_MOST:
			return UnitStats.to_array(UnitStats.select_lowest(targets, func(a : UnitStats) : return 0.0 - a.get_time_until_action()))
		AttackTarget.ANY:
			return targets
		AttackTarget.MOST_VULNERABLE:
			return UnitStats.to_array(UnitStats.select_lowest(targets, func(a : UnitStats) : return 0.0 - a.calculate_damage_from_attack(self)))
		AttackTarget.CLOSEST_TO_DEATH:
			return UnitStats.to_array(UnitStats.select_lowest(targets, func(a : UnitStats) : return a.current_health))
		AttackTarget.FARTHEST_FROM_DEATH:
			return UnitStats.to_array(UnitStats.select_lowest(targets, func(a : UnitStats) : return 0.0 - a.current_health))
	return []

func get_moves(actor : UnitStats, units : Array[UnitStats]) -> Array[MMCAction]:
	var ret_val : Array[MMCAction]
	var target_side : UnitStats.Side = actor.side if acts_on_allies else UnitStats.get_other_side(actor.side)
	var potential_targets : Array[UnitStats] = units.filter(func(a : UnitStats) : return a.side == target_side && a.is_alive())
	if potential_targets.is_empty():
		return ret_val
	var valid_targets : Array[UnitStats] = get_targets(potential_targets)
	for target : UnitStats in valid_targets:
		ret_val.append(EAction.create(actor, target, self))
	return ret_val

func apply(actor : UnitStats, target : UnitStats) -> void:
	if tiring > 1:
		actor.next_attack += speed_multiple * actor.slowness * actor.tired
		actor.tired *= tiring
	else:
		actor.next_attack += speed_multiple * actor.slowness

	var dmg : float = damage
	if stun > 0:
		target.next_attack += damage * stun
		dmg = (1.0 - stun) * damage

	if acts_on_allies:
		target.current_health = min(target.current_health + dmg, target.max_health)
	elif armor_piercing:
		target.current_health -= dmg
	elif dmg - target.armor > 1:
		target.current_health -= (dmg - target.armor)
	else:
		target.current_health -= 1
