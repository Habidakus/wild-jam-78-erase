class_name AttackStats extends RefCounted

static var s_attack_id : int = 1

var id : int = 0
var damage : float = 30
var stun : float = 0
var tiring : float = 1
var bleed_ticks : int = 0
var speed_multiple : float = 1.0
var attack_name : String
var acts_on_allies : bool = false
var armor_piercing : bool = false
# All of these single-purpose no-damage booleans should instead be in one enum
var is_command : bool = false
var divine_wrath : bool = false
var blocks : bool = false
# All of these single-purpose use-determiners should instead be in one enum
var cooldown : bool = false
var single_use : bool = false

enum AttackTarget { INVALID, FRONT_MOST, REAR_MOST, TWO_REAR_MOST, ANY, MOST_VULNERABLE, CLOSEST_TO_DEATH, FARTHEST_FROM_DEATH, SELF, TWO_FARTHEST_FROM_DEATH, FIRST_TWO, TWO_LEAST_ARMORED, ANY_WOUNDED }
var attack_target : AttackTarget = AttackTarget.INVALID

static func create(_name : String, _attack_target : AttackTarget) -> AttackStats:
	var ret_val : AttackStats = AttackStats.new()
	ret_val.attack_name = _name
	ret_val.attack_target = _attack_target
	ret_val.id = s_attack_id
	s_attack_id += 1
	return ret_val

func set_divine_wrath() -> AttackStats:
	assert(divine_wrath == false)
	divine_wrath = true
	return self

func tires(mod : float) -> AttackStats:
	tiring *= mod
	return self

func set_bleed(ticks : int) -> AttackStats:
	assert(bleed_ticks == 0)
	bleed_ticks = ticks
	return self

func grants_block() -> AttackStats:
	assert(acts_on_allies)
	assert(blocks == false)
	blocks = true
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

func set_is_command() -> AttackStats:
	assert(acts_on_allies)
	assert(is_command == false)
	is_command = true
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
		AttackTarget.ANY_WOUNDED:
			return targets.filter(func(a : UnitStats) : return a.current_health < a.max_health || a.bleeding_ticks > 0)
		AttackTarget.FARTHEST_FROM_DEATH:
			return UnitStats.to_array(UnitStats.select_lowest(targets, func(a : UnitStats) : return 0.0 - a.current_health))
		AttackTarget.TWO_FARTHEST_FROM_DEATH:
			return UnitStats.select_two_lowest_amount(targets, func(a : UnitStats) : return 0.0 - a.current_health)
		AttackTarget.TWO_LEAST_ARMORED:
			return UnitStats.select_two_lowest_amount(targets, func(a : UnitStats) : return a.armor if a.armor > 0 else 0 - a.current_health)
	return []

func get_targetting_summary() -> String:
	var side_string_solo : String = "ally" if acts_on_allies else "foe"
	var side_string_plural : String = "allies" if acts_on_allies else "foes"
	match attack_target:
		AttackTarget.SELF:
			return "ourself"
		AttackTarget.FRONT_MOST:
			return "next " + side_string_solo + " to act"
		AttackTarget.FIRST_TWO:
			return "next " + side_string_plural + " to act"
		AttackTarget.REAR_MOST:
			return "slowest " + side_string_solo
		AttackTarget.TWO_REAR_MOST:
			return "slowest " + side_string_plural
		AttackTarget.ANY:
			return "any " + side_string_solo
		AttackTarget.MOST_VULNERABLE:
			return "most vulnerable " + side_string_solo
		AttackTarget.CLOSEST_TO_DEATH:
			return side_string_solo + " closest to death"
		AttackTarget.ANY_WOUNDED:
			return "any wounded " + side_string_solo
		AttackTarget.FARTHEST_FROM_DEATH:
			return "least wounded " + side_string_solo
		AttackTarget.TWO_FARTHEST_FROM_DEATH:
			return "least wounded " + side_string_plural
		AttackTarget.TWO_LEAST_ARMORED:
			return "least armored " + side_string_plural
	assert(false)
	return "???"

func get_summary() -> String:
	var hp_dmg : float = round(10.0 * damage * (1.0 - stun)) / 10.0
	var ret_val : String = attack_name + ": "
	if acts_on_allies:
		if is_command:
			ret_val += "Commands " + get_targetting_summary() + " to act immediately after us"
		elif blocks:
			ret_val += "Intercepts damage on " + get_targetting_summary()
		else:
			ret_val += str(hp_dmg) + " health heal on " + get_targetting_summary()
	else:
		if stun > 0:
			var stn_dmg = round(10.0 * damage * stun) / 10.0
			ret_val += str(stn_dmg) + " stun with " + str(hp_dmg) + " damage"
		else:
			ret_val += str(hp_dmg) + " damage"
		ret_val += " vs " + get_targetting_summary()
	if speed_multiple < 1:
		ret_val += ", " + str(round(100 * (1 - speed_multiple))) + "% faster than other actions"
	elif speed_multiple > 1:
		ret_val += ", " + str(round(100 * (speed_multiple - 1))) + "% slower than other actions"
	if cooldown:
		ret_val += ", can't be used twice in a row"
	elif single_use:
		ret_val += ", only once per combat"
	if bleed_ticks > 0:
		ret_val += ", foe will bleed " + str(bleed_ticks * 10) + "% on good hit"
	if armor_piercing:
		ret_val += ", ignores enemy armor"
	if divine_wrath:
		ret_val += ", does massive damage only to undead and Chronotyrants"
	if tiring > 1:
		ret_val += ", will be slower each time used in a combat"

	return ret_val

func generate_tooltip(target : UnitStats) -> String:
	var dmg : float = target.calculate_damage_from_attack(self)
	var ret_val : String = str(round(dmg * 10.0)/10.0)
	if acts_on_allies:
		if is_command:
			ret_val = "Command"
		elif blocks:
			ret_val = "Bodyguard"
		else:
			ret_val += " Healing"
	else:
		assert(is_command == false)
		ret_val += " Damage"
		
	if armor_piercing:
		ret_val += ", ignores armor"
	elif stun > 0:
		ret_val += ", delays"
	elif bleed_ticks > 0:
		ret_val += ", causes bleeding"

	if single_use:
		ret_val += ", single use"
	if cooldown:
		ret_val += ", cooldown"
	if tiring > 1:
		ret_val += ", tiring"
	if speed_multiple > 1.2:
		ret_val += ", very slow"
	elif speed_multiple > 1:
		ret_val += ", slow"
	elif speed_multiple < 0.9:
		ret_val += ", very quick"
	elif speed_multiple < 1:
		ret_val += ", quick"
	
	return ret_val

func dont_consider_stupid_action(targets : Array[UnitStats]) -> Array[UnitStats]:
	if !acts_on_allies:
		return targets
	if targets.is_empty():
		return targets
	if damage > 0 && is_command == false && blocks == false:
		return targets.filter(func(a : UnitStats) : return a.bleeding_ticks > 0 || ((a.current_health * 3) < (a.max_health * 2)))
	return targets

func get_moves(actor : UnitStats, units : Array[UnitStats], allow_stupid_humans : bool) -> Array[MMCAction]:
	var ret_val : Array[MMCAction]
	if cooldown && actor.has_cooldown(id):
		return ret_val
	if single_use && actor.has_used():
		return ret_val
	var target_side : UnitStats.Side = actor.side if acts_on_allies else UnitStats.get_other_side(actor.side)
	var all_living_units_on_target_side : Array[UnitStats] = units.filter(func(a : UnitStats) : return a.side == target_side && a.is_alive())
	var potential_targets : Array[UnitStats] = all_living_units_on_target_side if allow_stupid_humans else dont_consider_stupid_action(all_living_units_on_target_side)
	if acts_on_allies:
		if is_command || blocks:
			# These two actions can't be performed on ourself
			if potential_targets.has(actor):
				potential_targets = potential_targets.filter(func(a : UnitStats) : return a != actor)
	if potential_targets.is_empty():
		return ret_val
	var valid_targets : Array[UnitStats] = get_targets(actor, potential_targets)
	
	if !acts_on_allies:
		# If anyone on the target side has blocking, replace their target with the blocker
		if !valid_targets.is_empty():
			var replace : Dictionary
			for t : UnitStats in all_living_units_on_target_side:
				if t.blocking >= 0:
					replace[t.blocking] = t
			if !replace.is_empty():
				var with_blocking : Array[UnitStats]
				for p : UnitStats in valid_targets:
					if replace.has(p.id):
						if !with_blocking.has(replace[p.id]):
							with_blocking.push_back(replace[p.id])
					else:
						if !with_blocking.has(p):
							with_blocking.push_back(p)
				valid_targets = with_blocking
			
	for target : UnitStats in valid_targets:
		ret_val.append(EAction.create(actor, target, self))
	return ret_val
	
func get_cost_in_time(actor : UnitStats) -> float:
	if tiring > 1:
		return speed_multiple * actor.slowness * actor.tired
	else:
		return speed_multiple * actor.slowness

func get_cost_in_time_for_target(attacker: UnitStats, target : UnitStats) -> float:
	if stun > 0:
		# lower this is, the more resistance they have
		var stun_resistance : float = 1.0 - (target.max_health / (target.max_health + 333.0))
		return damage * stun * stun_resistance
	elif is_command:
		return (attacker.next_attack - target.next_attack) + 0.01
	else:
		return 0

func generate_fx(actor : UnitStats, target : UnitStats) -> ActionFXContainer:
	var ret_val : ActionFXContainer = ActionFXContainer.new()
	apply(actor, target, ret_val)
	return ret_val

func apply(actor : UnitStats, target : UnitStats, fx : ActionFXContainer) -> void:
	# Must be computed before actor goes slower, our attack might be the command "Go Now"
	var target_stun_cost : float = get_cost_in_time_for_target(actor, target)
	actor.blocking = -1

	if fx == null:
		actor.next_attack += get_cost_in_time(actor)
		
	if tiring > 1:
		if fx != null:
			fx.add_tiring(actor)
		else:
			actor.tired *= tiring

	if target_stun_cost:
		if fx != null:
			fx.add_stun(actor, target, target_stun_cost)
		else:
			target.next_attack += target_stun_cost

	var new_bleed_ticks : bool = true if bleed_ticks > 0 && bleed_ticks > target.bleeding_ticks else false
	var dmg : float = target.calculate_damage_from_attack(self)

	if acts_on_allies:
		if fx != null && dmg != 0:
			fx.apply_heal(target, dmg)
		else:
			if is_command:
				pass # we already moved them forward
			elif blocks:
				actor.blocking = target.id
			else:
				# healing
				target.current_health = min(target.current_health + dmg, target.max_health)
				if target.bleeding_ticks > 0:
					target.bleeding_ticks = 0
	else:
		if fx != null && dmg != 0:
			fx.apply_damage(actor, target, dmg)
		else:
			if target.magic_shield > dmg:
				target.magic_shield -= dmg
				dmg = 0
			elif target.magic_shield > 0:
				dmg -= target.magic_shield
				target.magic_shield = 0
				
			target.current_health -= dmg
			if dmg <= 1:
				new_bleed_ticks = false
			if new_bleed_ticks:
				target.bleeding_ticks = bleed_ticks
	
	if fx != null:
		if cooldown:
			fx.add_cooldown(actor)
		if single_use:
			fx.expend_single_use(actor)
	else:
		actor.clear_cooldowns()
		if cooldown:
			actor.set_cooldown(id)
		if single_use:
			actor.set_single_use()
		
	if actor.bleeding_ticks > 0:
		var bleed_amount = actor.max_health / 10.0
		if fx != null:
			fx.bleed_once(actor, bleed_amount)
		else:
			actor.current_health -= bleed_amount
			actor.bleeding_ticks -= 1
