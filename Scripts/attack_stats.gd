class_name AttackStats extends RefCounted

var damage : float = 30
var cooldown : int = 0
var stun : float = 0
var tiring : float = 1
var bleed_ticks : int = 0
var speed_multiple : float = 1.0
var attack_name : String
var acts_on_allies : bool = false
var armor_piercing : bool = false

enum AttackTarget { INVALID, FRONT_MOST, REAR_MOST, ANY, MOST_VULNERABLE, CLOSEST_TO_DEATH, FARTHEST_FROM_DEATH, SELF }
var attack_target : AttackTarget = AttackTarget.INVALID

static func create(_name : String, _attack_target : AttackTarget) -> AttackStats:
	var ret_val : AttackStats = AttackStats.new()
	ret_val.attack_name = _name
	ret_val.attack_target = _attack_target
	return ret_val

func tires(mod : float) -> AttackStats:
	tiring *= mod
	return self

func set_bleed(ticks : int) -> AttackStats:
	assert(bleed_ticks == 0)
	bleed_ticks = ticks
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

func has_cooldown(_cooldown : int) -> AttackStats:
	cooldown = _cooldown
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

func get_targets(actor : UnitStats, targets : Array[UnitStats]) -> Array[UnitStats]:
	match attack_target:
		AttackTarget.INVALID:
			assert(false)
		AttackTarget.SELF:
			return UnitStats.to_array(actor)
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

func generate_tooltip(target : UnitStats) -> String:
	var dmg : float = target.calculate_damage_from_attack(self)
	var ret_val : String = str(round(dmg * 10.0)/10.0)
	if acts_on_allies:
		ret_val += " Healing"
	elif armor_piercing:
		ret_val += " Armor Piercing"
	elif stun > 0:
		ret_val += " Stunning"
	elif bleed_ticks > 0:
		ret_val += " Bleed"
	else:
		ret_val += " Damage"
	if cooldown > 0:
		ret_val += ", cooldown"
	if tiring > 0:
		ret_val += ", tiring"
	if speed_multiple > 1:
		ret_val += ", slow"
	elif speed_multiple < 1:
		ret_val += ", quick"
	
	return ret_val

func get_moves(actor : UnitStats, units : Array[UnitStats]) -> Array[MMCAction]:
	var ret_val : Array[MMCAction]
	if actor.cooldown > 0 && cooldown > 0:
		return ret_val
	var target_side : UnitStats.Side = actor.side if acts_on_allies else UnitStats.get_other_side(actor.side)
	var potential_targets : Array[UnitStats] = units.filter(func(a : UnitStats) : return a.side == target_side && a.is_alive())
	if acts_on_allies && damage > 0 && !potential_targets.is_empty():
		potential_targets = potential_targets.filter(func(a : UnitStats) : return a.bleeding_ticks > 0 || ((a.current_health * 3) < (a.max_health * 2)))
	if potential_targets.is_empty():
		return ret_val
	var valid_targets : Array[UnitStats] = get_targets(actor, potential_targets)
	for target : UnitStats in valid_targets:
		ret_val.append(EAction.create(actor, target, self))
	return ret_val

func apply(actor : UnitStats, target : UnitStats) -> void:
	if tiring > 1:
		actor.next_attack += speed_multiple * actor.slowness * actor.tired
		actor.tired *= tiring
	else:
		actor.next_attack += speed_multiple * actor.slowness

	if stun > 0:
		target.next_attack += damage * stun

	var new_bleed_ticks : bool = true if bleed_ticks > 0 && bleed_ticks > target.bleeding_ticks else false
	var dmg : float = target.calculate_damage_from_attack(self)

	if acts_on_allies:
		target.current_health = min(target.current_health + dmg, target.max_health)
		if target.bleeding_ticks > 0:
			target.bleeding_ticks = 0
	else:
		target.current_health -= dmg
		if dmg <= 1:
			new_bleed_ticks = false
		if new_bleed_ticks:
			target.bleeding_ticks = bleed_ticks
	
	if actor.cooldown > 0:
		actor.cooldown -= 1
	if cooldown > 0:
		actor.cooldown += cooldown
		
	if actor.bleeding_ticks > 0:
		actor.current_health -= (actor.max_health / 10.0)
		actor.bleeding_ticks -= 1
