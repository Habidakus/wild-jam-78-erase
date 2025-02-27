class_name HeroAssemblyContainer extends Control

var unit_name : String = "???"
var species : UnitMod = null
var occupation : UnitMod = null
var equip : UnitMod = null
var species_label : Label
var occupation_label : Label
var equipment_label : Label
var callback : Callable

func init(_callback : Callable) -> void:
	callback = _callback
	
func assign_hero_name(hero_name : String) -> void:
	unit_name = hero_name

func add_mod(mod : UnitMod, phase : SMSPreGame.Phase) -> void:
	match phase:
		SMSPreGame.Phase.SPECIES_SELECT:
			species = mod
			species_label.text = unit_name + "\nthe " + species.get_mod_name()
			species_label.show()
		SMSPreGame.Phase.CLASS_SELECT:
			occupation = mod
			occupation_label.text = occupation.get_mod_name()
			occupation_label.show()
		SMSPreGame.Phase.EQUIP_SELECT:
			equip = mod
			equipment_label.text = equip.get_mod_name()
			equipment_label.show()

func add_mod_container(unit_mod_container : UnitModContainer, phase : SMSPreGame.Phase) -> void:
	add_mod(unit_mod_container.mod, phase)

func start_glowing() -> void:
	(species_label.find_child("ColorRect") as ColorRect).color = Color.LIME
func stop_glowing() -> void:
	(species_label.find_child("ColorRect") as ColorRect).color = Color.WHITE

func can_slot(_unit_mod_container : UnitModContainer, phase : SMSPreGame.Phase) -> bool:
	match phase:
		SMSPreGame.Phase.SPECIES_SELECT:
			return is_missing_species()
		SMSPreGame.Phase.CLASS_SELECT:
			return is_missing_class()
		SMSPreGame.Phase.EQUIP_SELECT:
			return is_missing_equip()
	assert(false)
	return false

func is_missing_species() -> bool:
	return species == null
func is_missing_class() -> bool:
	return occupation == null
func is_missing_equip() -> bool:
	return equip == null

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	species_label = find_child("Species") as Label
	species_label.hide()
	occupation_label = find_child("Class") as Label
	occupation_label.hide()
	equipment_label = find_child("Equipment") as Label
	equipment_label.hide()

func _on_equipment_hover_start() -> void:
	callback.bind(equip, 3).call()

func _on_equipment_hover_stop() -> void:
	callback.bind(equip, 4).call()

func _on_class_hover_start() -> void:
	callback.bind(occupation, 3).call()

func _on_class_hover_stop() -> void:
	callback.bind(occupation, 4).call()

func _on_species_hover_start() -> void:
	callback.bind(species, 3).call()

func _on_species_hover_stop() -> void:
	callback.bind(species, 4).call()
