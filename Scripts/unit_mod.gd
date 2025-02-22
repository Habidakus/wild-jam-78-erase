class_name UnitMod extends RefCounted

var extra_health : float = 0
var elo_name : String = "?"
var extra_armor : float = 0
var extra_slowness : float = 0
var attacks : Array[AttackStats]
var naming_function : String
var icon : UnitStats.Icon = UnitStats.Icon.UNSET
var skill_class : SkillStats.SkillClass = SkillStats.SkillClass.NONE

static func create(mod_name : String) -> UnitMod:
	var ret_val : UnitMod = UnitMod.new()
	ret_val.elo_name = mod_name
	return ret_val

func set_skill_class(_class : SkillStats.SkillClass) -> UnitMod:
	skill_class = _class
	return self

func has_icon() -> bool:
	return icon != UnitStats.Icon.UNSET

func get_icon() -> UnitStats.Icon:
	return icon

func set_icon(i : UnitStats.Icon) -> UnitMod:
	icon = i
	return self

func add_health(amount : float) -> UnitMod:
	extra_health += amount
	return self

func add_armor(amount : float) -> UnitMod:
	extra_armor += amount
	return self

func add_slowness(amount : float) -> UnitMod:
	extra_slowness += amount
	return self

func set_attack(attack : AttackStats) -> UnitMod:
	attacks.append(attack)
	return self

func set_namer(function_name : String) -> UnitMod:
	naming_function = function_name
	return self

func will_name() -> bool:
	return !naming_function.is_empty()

func generate_name(rnd : RandomNumberGenerator) -> String:
	return Callable(self, naming_function).bind(rnd).call()

static func create_orc_name(rnd : RandomNumberGenerator) -> String:
	const orc_beginning : Array[String] = ["N", "G", "Gh", "Kl", "T", "Arb", "M", "Az"]
	var ret_val : String = orc_beginning[rnd.randi_range(0, orc_beginning.size() - 1)]
	const orc_middle_a : Array[String] = ["az", "ub", "ar", "ag", "aw", "ut", "og", "im", "ur", "or", "uz", "aug"]
	ret_val += orc_middle_a[rnd.randi_range(0, orc_middle_a.size() - 1)]
	const orc_middle_b : Array[String] = ["dre", "a", "gha", "ro", "ja", "sni", "go", "zu", "glu", "zi", "la", "za", "re"]
	ret_val += orc_middle_b[rnd.randi_range(0, orc_middle_b.size() - 1)]
	const orc_ending : Array[String] = ["w", "d", "b", "g", "ruk", "m", "z", "rk", "r", "ng", "l"]
	ret_val += orc_ending[rnd.randi_range(0, orc_ending.size() - 1)]
	return ret_val

static func create_human_name(rnd : RandomNumberGenerator) -> String:
	const human_first_name : Array[String] = [ "Agatha", "Bartholomew", "Cassandra", "Derrick", "Edmund", "Felicity", "Gawain", "Hannabel", "Ishmael", "Jesmond", "Nowell", "Samara", "Victor"]
	var ret_val : String = human_first_name[rnd.randi_range(0, human_first_name.size() - 1)]
	ret_val += " "
	const human_last_name : Array[String] = ["Yorke", "Whitgyft", "Unthank", "Tonstall", "Smith", "Ruddok", "Plumton", "Norfolk", "Abbot", "Bishop", "Grimm"]
	ret_val += human_last_name[rnd.randi_range(0, human_last_name.size() - 1)]
	return ret_val

static func create_ratman_name(rnd : RandomNumberGenerator) -> String:
	const rat_beginning : Array[String] = ["G", "R", "L", "Zz", "Ch", "B", "V", "K", "Sl", "Asm", "N", "Kr"]
	var ret_val : String = rat_beginning[rnd.randi_range(0, rat_beginning.size() - 1)]
	const rat_ending : Array[String] = ["a", "ack", "al", "as", "ard", "in", "ip", "isk", "ist", "ith", "odz", "om", "eus", "u"]
	ret_val += rat_ending[rnd.randi_range(0, rat_ending.size() - 1)]
	return ret_val

static func create_elf_name(rnd : RandomNumberGenerator) -> String:
	const elf_beginning : Array[String] = ["E", "Ga", "Glo", "Fëa", "Eare", "Fi", "Ea", "A", "Lú", "Dri", "Elmi"]
	var ret_val : String = elf_beginning[rnd.randi_range(0, elf_beginning.size() - 1)]
	const elf_middle : Array[String] = ["lro", "la", "drie", "rfi", "nde", "no", "ndi", "ngo", "lfi", "rwe", "thei", "nste"]
	ret_val += elf_middle[rnd.randi_range(0, elf_middle.size() - 1)]
	const elf_ending : Array[String] = ["nd", "l", "r", "n", "st"]
	ret_val += elf_ending[rnd.randi_range(0, elf_ending.size() - 1)]
	return ret_val

static func create_dwarf_name(rnd : RandomNumberGenerator) -> String:
	const dwarf_first_name : Array[String] = ["Urist", "Ùshrir", "Sodel", "Limul", "Dumat", "Bofur", "Dori", "Ori", "Thorin", "Rhys", "Tagwen", "Hjodill"]
	var ret_val : String = dwarf_first_name[rnd.randi_range(0, dwarf_first_name.size() - 1)]
	ret_val += " "
	const dwarf_last_prefix : Array[String] = ["Mac", "Mc", "O'"]
	ret_val += dwarf_last_prefix[rnd.randi_range(0, dwarf_last_prefix.size() - 1)]
	const dwarf_last_suffix : Array[String] = ["Blackanvil", "Deepshaft", "Doubleax", "Goldbones", "Hammer", "Leadshoe", "Mountain", "Motherlode", "Nostril", "Rocknoggin", "Smashy", "Stonefinger", "Stalewind", "Shaletooth", "Tankard", "Thickale", "Tinmonger"]
	ret_val += dwarf_last_suffix[rnd.randi_range(0, dwarf_last_suffix.size() - 1)]
	return ret_val

static func create_halfling_name(rnd : RandomNumberGenerator) -> String:
	const halfling_first_name : Array[String] = ["Bunny", "Batty", "Cheery", "Chuckle", "Candy", "Curly", "Doc", "Dawn", "Flower", "Honest", "Happy", "Hope", "Musky", "Petal", "Smiley", "Spanky", "Sunny",]
	var ret_val : String = halfling_first_name[rnd.randi_range(0, halfling_first_name.size() - 1)]
	ret_val += " "
	const halfling_last_prefix : Array[String] = ["Blush", "Bright", "Dank", "Dirty", "Funny", "Fuzzy", "Oil", "Onion", "Pickle", "Rose", "Shine", "Squeak", "Stink", "Sweet", "Tart", "Tickle", "Whisper", "Wicked", "Wonder",]
	ret_val += halfling_last_prefix[rnd.randi_range(0, halfling_last_prefix.size() - 1)]
	const halfling_last_suffix : Array[String] = ["barrel", "belly", "button", "cheek", "finger", "foot", "farm", "leaf", "navel", "palm", "pants", "smoke", "stockings", "tater", "toe", "tooth", "tummy"]
	ret_val += halfling_last_suffix[rnd.randi_range(0, halfling_last_suffix.size() - 1)]
	return ret_val

static var s_rusty_sword_attack : AttackStats = AttackStats.create("Rusty Sword", AttackStats.AttackTarget.TWO_FARTHEST_FROM_DEATH).adjust_damage(0.8).tires(1.1)
static var s_angry_punch_attack : AttackStats = AttackStats.create("Angry Punch", AttackStats.AttackTarget.FIRST_TWO).tires(1.1)

static var s_species_goblin : UnitMod = create("Goblin").add_health(-40).set_icon(UnitStats.Icon.Goblin)
static var s_occupation_guard : UnitMod = create("Guard").add_armor(5)
static var s_occupation_guard_sgt : UnitMod = create("Sargent").add_armor(15).add_health(30).set_attack(s_angry_punch_attack).add_slowness(1)
static var s_equipment_guard_gear : UnitMod = create("Rusty Sword").set_attack(s_rusty_sword_attack)
	
static var s_sling_attack : AttackStats = AttackStats.create("Sling", AttackStats.AttackTarget.ANY).adjust_damage(0.8).adjust_speed(0.9)
static var s_short_sword_attack : AttackStats = AttackStats.create("Short Sword", AttackStats.AttackTarget.FIRST_TWO).adjust_speed(0.95)

static var s_species_human : UnitMod = create("Human").set_attack(s_short_sword_attack).set_namer("create_human_name").set_icon(UnitStats.Icon.Human)
static var s_species_dwarf : UnitMod = create("Dwarf").add_health(35).add_armor(10).add_slowness(2).set_namer("create_dwarf_name").set_icon(UnitStats.Icon.Dwarf)
static var s_species_elf : UnitMod = create("Elf").add_slowness(-1.5).add_health(-10).set_namer("create_elf_name").set_icon(UnitStats.Icon.Elf)
static var s_species_halfling : UnitMod = create("Halfling").set_attack(s_sling_attack).add_health(-20).add_slowness(-2).set_namer("create_halfling_name").set_icon(UnitStats.Icon.Halfling)
static var s_species_orc : UnitMod = create("Orc").add_health(70).add_slowness(2.25).set_namer("create_orc_name").set_icon(UnitStats.Icon.Orc)
static var s_species_ratman : UnitMod = create("Ratman").add_health(-40).add_slowness(-3.25).set_namer("create_ratman_name").set_icon(UnitStats.Icon.Ratman)

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
static var s_attack_backstab : AttackStats = AttackStats.create("Backstab", AttackStats.AttackTarget.MOST_VULNERABLE).adjust_speed(0.9).adjust_damage(0.9)
static var s_attack_magic_missile : AttackStats = AttackStats.create("Zzzap", AttackStats.AttackTarget.ANY).adjust_damage(0.95)
static var s_attack_smash : AttackStats = AttackStats.create("Smash", AttackStats.AttackTarget.FARTHEST_FROM_DEATH).adjust_damage(1.55).adjust_speed(1.25)
static var s_attack_heal : AttackStats = AttackStats.create("Heal", AttackStats.AttackTarget.CLOSEST_TO_DEATH).adjust_damage(1.25).set_on_allies().has_cooldown()
static var s_attack_net : AttackStats = AttackStats.create("Net", AttackStats.AttackTarget.TWO_REAR_MOST).set_stun(0.95).adjust_damage(2).has_single_use().adjust_speed(1.25)
static var s_attack_blood_curse : AttackStats = AttackStats.create("Blood Curse", AttackStats.AttackTarget.TWO_LEAST_ARMORED).set_bleed(5)
static var s_attack_mace : AttackStats = AttackStats.create("Mace", AttackStats.AttackTarget.FRONT_MOST).adjust_damage(1.25).adjust_speed(1.15)
static var s_attack_trident : AttackStats = AttackStats.create("Trident", AttackStats.AttackTarget.REAR_MOST).set_armor_piercing()

static var s_occupation_knight : UnitMod = create("Knight").set_skill_class(SkillStats.SkillClass.FIGHTER).set_attack(s_attack_longsword).add_armor(7.5).add_slowness(1)
static var s_occupation_assassin : UnitMod = create("Assassin").set_skill_class(SkillStats.SkillClass.ROGUE).set_attack(s_attack_backstab).add_slowness(-1)
static var s_occupation_mage : UnitMod = create("Mage").set_skill_class(SkillStats.SkillClass.MAGIC).set_attack(s_attack_magic_missile)
static var s_occupation_barbarian : UnitMod = create("Barbarian").set_skill_class(SkillStats.SkillClass.FIGHTER).set_attack(s_attack_smash).add_health(70)
static var s_occupation_cleric : UnitMod = create("Cleric").set_skill_class(SkillStats.SkillClass.HOLY).set_attack(s_attack_heal).add_armor(5).set_attack(s_attack_mace)
static var s_occupation_retiarius : UnitMod = create("Retiarius").set_skill_class(SkillStats.SkillClass.FIGHTER).set_attack(s_attack_net).set_attack(s_attack_trident)
static var s_occupation_warlock : UnitMod = create("Warlock").set_skill_class(SkillStats.SkillClass.MAGIC).set_attack(s_attack_blood_curse)

static func pick_random_occupation(rnd : RandomNumberGenerator) -> UnitMod:
	match rnd.randi_range(0, 6):
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
		6:
			return s_occupation_cleric
	assert(false)
	return null

static var s_attack_potion : AttackStats = AttackStats.create("Potion", AttackStats.AttackTarget.SELF).adjust_damage(2.5).set_on_allies().has_single_use()
static var s_attack_halberd : AttackStats = AttackStats.create("Halberd", AttackStats.AttackTarget.FRONT_MOST).set_armor_piercing().adjust_damage(1.15).adjust_speed(1.25)
static var s_attack_zweihander : AttackStats = AttackStats.create("Zweihander", AttackStats.AttackTarget.FRONT_MOST).adjust_damage(2).adjust_speed(2.2).tires(1.085)
static var s_attack_shield : AttackStats = AttackStats.create("Shield Bash", AttackStats.AttackTarget.FRONT_MOST).adjust_damage(0.35).set_stun(0.5)

static var s_equipment_shield : UnitMod = create("Shield").add_armor(5).set_attack(s_attack_shield)
static var s_equipment_armor : UnitMod = create("Plate Mail").add_armor(22.5).add_slowness(1)
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
