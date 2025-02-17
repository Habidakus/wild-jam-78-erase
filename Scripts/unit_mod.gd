class_name UnitMod extends RefCounted

var extra_health : float = 0
var elo_name : String = "?"
var extra_armor : float = 0
var extra_slowness : float = 0
var attack : AttackStats = null

static func create(mod_name : String) -> UnitMod:
	var ret_val : UnitMod = UnitMod.new()
	ret_val.elo_name = mod_name
	return ret_val

func add_health(amount : float) -> UnitMod:
	extra_health += amount
	return self

func add_armor(amount : float) -> UnitMod:
	extra_armor += amount
	return self

func add_slowness(amount : float) -> UnitMod:
	extra_slowness += amount
	return self

func set_attack(_attack : AttackStats) -> UnitMod:
	assert(attack == null)
	attack = _attack
	return self

static var s_sling_attack : AttackStats = AttackStats.create("Sling", AttackStats.AttackTarget.ANY).adjust_damage(0.8)
static var s_short_sword_attack : AttackStats = AttackStats.create("Short Sword", AttackStats.AttackTarget.FRONT_MOST).adjust_speed(0.95)

static var s_species_human : UnitMod = create("Human").set_attack(s_short_sword_attack)
static var s_species_dwarf : UnitMod = create("Dwarf").add_health(35).add_armor(10).add_slowness(2)
static var s_species_elf : UnitMod = create("Elf").add_slowness(-1.5).add_health(-10)
static var s_species_halfling : UnitMod = create("Halfling").set_attack(s_sling_attack).add_health(-20).add_slowness(-0.5)
static var s_species_orc : UnitMod = create("Orc").add_health(70).add_slowness(2.25)
static var s_species_ratman : UnitMod = create("Ratman").add_health(-40).add_slowness(-3.25)

static func pick_random_species(rnd : RandomNumberGenerator) -> UnitMod:
	match rnd.randi_range(0, 5):
		0: # Human
			return s_species_human
		1: # Dwarf
			return s_species_dwarf
		2: # Elf
			return s_species_elf
		3: # Halfling
			return s_species_halfling
		4: # Orc
			return s_species_orc
		5: # Rat
			return s_species_ratman
	assert(false)
	return null

static var s_attack_longsword : AttackStats = AttackStats.create("Longsword", AttackStats.AttackTarget.CLOSEST_TO_DEATH).adjust_speed(1.1)
static var s_attack_backstab : AttackStats = AttackStats.create("Dagger", AttackStats.AttackTarget.MOST_VULNERABLE).adjust_speed(0.9).adjust_damage(0.9)
static var s_attack_magic_missile : AttackStats = AttackStats.create("Zzzap", AttackStats.AttackTarget.ANY).adjust_damage(0.935).adjust_speed(0.95)
static var s_attack_smash : AttackStats = AttackStats.create("Smash", AttackStats.AttackTarget.FARTHEST_FROM_DEATH).adjust_damage(1.6).adjust_speed(1.25)
static var s_attack_heal : AttackStats = AttackStats.create("Heal", AttackStats.AttackTarget.CLOSEST_TO_DEATH).adjust_damage(1.25).set_on_allies().tires(1.1)
static var s_attack_net : AttackStats = AttackStats.create("Net", AttackStats.AttackTarget.REAR_MOST).set_stun(0.95).adjust_damage(1)
static var s_attack_blood_curse : AttackStats = AttackStats.create("Blood Curse", AttackStats.AttackTarget.FRONT_MOST).set_bleed(5)

static var s_occupation_knight : UnitMod = create("Knight").set_attack(s_attack_longsword).add_armor(7.5).add_slowness(1)
static var s_occupation_assassin : UnitMod = create("Assassin").set_attack(s_attack_backstab).add_slowness(-1)
static var s_occupation_mage : UnitMod = create("Mage").set_attack(s_attack_magic_missile)
static var s_occupation_barbarian : UnitMod = create("Barbarian").set_attack(s_attack_smash).add_health(75)
static var s_occupation_cleric : UnitMod = create("Cleric").set_attack(s_attack_heal).add_armor(5)
static var s_occupation_retiarius : UnitMod = create("Retiarius").set_attack(s_attack_net)
static var s_occupation_warlock : UnitMod = create("Warlock").set_attack(s_attack_blood_curse)

static func pick_random_occupation(rnd : RandomNumberGenerator) -> UnitMod:
	match rnd.randi_range(0, 5):
		0: # Knight
			return s_occupation_knight
		1: # Assassin
			return s_occupation_assassin
		2: # Mage
			return s_occupation_mage
		3: # Barbarian
			return s_occupation_barbarian
		4:
			return s_occupation_retiarius
		5:
			return s_occupation_warlock
		#6: # CAN'T ADD CLERIC UNTIL THEY GET A DEFAULT ATTACK
		#	return s_occupation_cleric
	assert(false)
	return null

static var s_attack_potion : AttackStats = AttackStats.create("Potion", AttackStats.AttackTarget.FRONT_MOST).adjust_damage(2.5).set_on_allies().tires(1.2)
static var s_attack_halberd : AttackStats = AttackStats.create("Halberd", AttackStats.AttackTarget.FRONT_MOST).set_armor_piercing().adjust_damage(1.15).adjust_speed(1.25)
static var s_attack_zweihander : AttackStats = AttackStats.create("Zweihander", AttackStats.AttackTarget.FRONT_MOST).adjust_damage(2).adjust_speed(2.2).tires(1.085)
static var s_attack_shield : AttackStats = AttackStats.create("Shield Bash", AttackStats.AttackTarget.FRONT_MOST).adjust_damage(0.35).set_stun(0.5)

static var s_equipment_shield : UnitMod = create("Shield").add_armor(5).set_attack(s_attack_shield)
static var s_equipment_armor : UnitMod = create("Armor").add_armor(22.5).add_slowness(2)
static var s_equipment_halberd : UnitMod = create("Halberd").set_attack(s_attack_halberd)
static var s_equipment_potion : UnitMod = create("Potion").set_attack(s_attack_potion)
static var s_equipment_zweihander : UnitMod = create("Zweihander").set_attack(s_attack_zweihander)

static func pick_random_equipment(rnd : RandomNumberGenerator) -> UnitMod:
	match rnd.randi_range(0, 4):
		0:
			return s_equipment_zweihander
		1: # Halberd
			return s_equipment_halberd
		2: # Armor
			return s_equipment_armor
		3:
			return s_equipment_shield
		4:
			return s_equipment_potion
	assert(false)
	return null
