class_name AttackStats extends RefCounted

static var s_attack_id : int = 1

var id : int = 0
var damage : float = 30
var cooldown : bool = false
var single_use : bool = false
var stun : float = 0
var tiring : float = 1
var bleed_ticks : int = 0
var speed_multiple : float = 1.0
var attack_name : String
var acts_on_allies : bool = false
var armor_piercing : bool = false

enum AttackTarget { INVALID, FRONT_MOST, REAR_MOST, TWO_REAR_MOST, ANY, MOST_VULNERABLE, CLOSEST_TO_DEATH, FARTHEST_FROM_DEATH, SELF, TWO_FARTHEST_FROM_DEATH, FIRST_TWO, TWO_LEAST_ARMORED }
var attack_target : AttackTarget = AttackTarget.INVALID

static func create(_name : String, _attack_target : AttackTarget) -> AttackStats:
	var ret_val : AttackStats = AttackStats.new()
	ret_val.attack_name = _name
	ret_val.attack_target = _attack_target
	ret_val.id = s_attack_id
	s_attack_id += 1
	return ret_val

func tires(mod : float) -> AttackStats:
	tiring *= mod
	return self

func set_bleed(ticks : int) -> AttackStats:
	assert(bleed_ticks == 0)
	bleed_ticks = ticks
	return self

func set_on_allies() -> AttackStats:
	assert(acts_on_allies == false)
	acts_on_allies = true
	return self

func adjust_speed(mod : float) -> AttackStats:
	speed_multiple *= mod
	return self

func set_armor_piercing() -> AttackStats:
	assert(armor_piercing == false)
	armor_piercing = true
	return self

func adjust_damage(mod : float) -> AttackStats:
	damage *= mod
	return self

func set_stun(_stun : float) -> AttackStats:
	stun = _stun
	return self

func has_cooldown() -> AttackStats:
	assert(cooldown == false)
	cooldown = true
	return self

func has_single_use() -> AttackStats:
	assert(single_use == false)
	single_use = true
	return self

static var s_really_bad_attack : AttackStats = null
static func get_really_bad_attack_attack() -> AttackStats:
	if s_really_bad_attack == null:
		s_really_bad_attack = AttackStats.new()
		s_really_bad_attack.attack_name = "SLOW WEAK MISAIMED"
		s_really_bad_attack.attack_target = AttackTarget.FARTHEST_FROM_DEATH
		s_really_bad_attack.adjust_damage(0.1)
		s_really_bad_attack.adjust_speed(5)
	return s_really_bad_attack

func get_targets(actor : UnitStats, targets : Array[UnitStats]) -> Array[UnitStats]:
	match attack_target:
		AttackTarget.INVALID:
			assert(false)
		AttackTarget.SELF:
			return UnitStats.to_array(actor)
		AttackTarget.FRONT_MOST:
			return UnitStats.to_array(UnitStats.select_lowest(targets, func(a : UnitStats) : return a.get_time_until_action()))
		AttackTarget.FIRST_TWO:
			return UnitStats.select_two_lowest_amount(targets, func(a : UnitStats) : return a.get_time_until_action())
		AttackTarget.REAR_MOST:
			return UnitStats.to_array(UnitStats.select_lowest(targets, func(a : UnitStats) : return 0.0 - a.get_time_until_action()))
		AttackTarget.TWO_REAR_MOST:
			return UnitStats.select_two_lowest_amount(targets, func(a : UnitStats) : return 0.0 - a.get_time_until_action())
		AttackTarget.ANY:
			return targets
		AttackTarget.MOST_VULNERABLE:
			return UnitStats.to_array(UnitStats.select_lowest(targets, func(a : UnitStats) : return 0.0 - a.calculate_damage_from_attack(self)))
		AttackTarget.CLOSEST_TO_DEATH:
			return UnitStats.to_array(UnitStats.select_lowest(targets, func(a : UnitStats) : return a.current_health))
		AttackTarget.FARTHEST_FROM_DEATH:
			return UnitStats.to_array(UnitStats.select_lowest(targets, func(a : UnitStats) : return 0.0 - a.current_health))
		AttackTarget.TWO_FARTHEST_FROM_DEATH:
			return UnitStats.select_two_lowest_amount(targets, func(a : UnitStats) : return 0.0 - a.current_health)
		AttackTarget.TWO_LEAST_ARMORED:
			return UnitStats.select_two_lowest_amount(targets, func(a : UnitStats) : return a.armor if a.armor > 0 else 0 - a.current_health)
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
	if single_use:
		ret_val += ", single use"
	if cooldown:
		ret_val += ", cooldown"
	if tiring > 1:
		ret_val += ", tiring"
	if speed_multiple > 1:
		ret_val += ", slow"
	elif speed_multiple < 1:
		ret_val += ", quick"
	
	return ret_val

func get_moves(actor : UnitStats, units : Array[UnitStats], allow_stupid_humans : bool) -> Array[MMCAction]:
	var ret_val : Array[MMCAction]
	if cooldown && actor.has_cooldown(id):
		return ret_val
	if single_use && actor.has_used():
		return ret_val
	var target_side : UnitStats.Side = actor.side if acts_on_allies else UnitStats.get_other_side(actor.side)
	var potential_targets : Array[UnitStats] = units.filter(func(a : UnitStats) : return a.side == target_side && a.is_alive())
	if acts_on_allies && damage > 0 && !potential_targets.is_empty():
		if !allow_stupid_humans:
			potential_targets = potential_targets.filter(func(a : UnitStats) : return a.bleeding_ticks > 0 || (a.current_health < a.max_health))
		else:
			# Don't let the computer use it unless the character is actually down to 66% or lower
			potential_targets = potential_targets.filter(func(a : UnitStats) : return a.bleeding_ticks > 0 || ((a.current_health * 3) < (a.max_health * 2)))
	if potential_targets.is_empty():
		return ret_val
	var valid_targets : Array[UnitStats] = get_targets(actor, potential_targets)
	for target : UnitStats in valid_targets:
		ret_val.append(EAction.create(actor, target, self))
	return ret_val
	
func get_cost_in_time(actor : UnitStats) -> float:
	if tiring > 1:
		return speed_multiple * actor.slowness * actor.tired
	else:
		return speed_multiple * actor.slowness

func get_cost_in_time_for_target(target : UnitStats) -> float:
	if stun > 0:
		return damage * stun
	else:
		return 0

func apply(actor : UnitStats, target : UnitStats) -> void:
	actor.next_attack += get_cost_in_time(actor)
	if tiring > 1:
		actor.tired *= tiring

	target.next_attack += get_cost_in_time_for_target(target)

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
	
	actor.clear_cooldowns()
	if cooldown:
		actor.set_cooldown(id)
	if single_use:
		actor.set_single_use()
		
	if actor.bleeding_ticks > 0:
		actor.current_health -= (actor.max_health / 10.0)
		actor.bleeding_ticks -= 1
