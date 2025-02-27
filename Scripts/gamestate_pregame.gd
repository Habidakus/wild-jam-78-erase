class_name SMSPreGame extends StateMachineState

var game : Game
var species : Array[UnitMod]
var occupations : Array[UnitMod]
var equipment : Array[UnitMod]
var hero_containers : Array[HeroAssemblyContainer]
var mod_containers : Array[UnitModContainer]
var work_area : ReferenceRect
var global_corner_min : Vector2
var global_corner_max : Vector2

const hero_container_scene = preload("res://Scenes/hero_assembly_container.tscn")
const unit_mod_container_scene = preload("res://Scenes/unit_mod_container.tscn")

enum Phase { SETUP, SPECIES_SELECT, CLASS_SELECT, EQUIP_SELECT}
var phase : Phase = Phase.SETUP

func init(_game : Game) -> void:
	game = _game

func _ready() -> void:
	work_area = find_child("ReferenceRect") as ReferenceRect

func load_work_area() -> void:
	global_corner_min = work_area.global_position
	global_corner_max = work_area.global_position + work_area.size

func setup_column(_column_name : String, _mods : Array[UnitMod]) -> void:
	pass
	#var column : VBoxContainer = find_child(column_name) as VBoxContainer
	#for mod : UnitMod in mods:
		#var label : Label = Label.new()
		#label.text = mod.get_mod_name()
		#label.label_settings = LabelSettings.new()
		#label.label_settings.font_color = Color.BLACK
		#label.label_settings.font_size = 28
		#var color_rectbox : ColorRect = ColorRect.new()
		#color_rectbox.set_anchors_preset(PRESET_FULL_RECT)
		#color_rectbox.show_behind_parent = true
		#label.add_child(color_rectbox)
		#column.add_child(label)

func change_phase(new_phase : Phase) -> void:
	if phase == new_phase:
		return
	phase = new_phase
	match phase:
		Phase.SETUP:
			assert(false)
		Phase.SPECIES_SELECT:
			
			hero_containers.clear()
			for i in range(0, 5):
				var hero_container = hero_container_scene.instantiate()
				hero_containers.append(hero_container)
				hero_container.global_position = global_corner_min;
				hero_container.global_position.x += 100
				hero_container.global_position.y += (i + 0.5) * (global_corner_max.y - global_corner_min.y) / 5
				#heroes_column.add_child(hero_container)
				hero_container.scale = Vector2(0.44, 0.44)
				add_child(hero_container)
		
			assert(species.size() >= 5)
			if species.size() == 5:
				for i in range(0, species.size()):
					assign_hero_name(i, species[i].generate_name(game.rnd))
					slot_mod_in_hero(i, species[i])
			else:
				call_deferred("detach_species_selections")
		Phase.CLASS_SELECT:
			call_deferred("detach_class_selections")
		Phase.EQUIP_SELECT:
			call_deferred("detach_equip_selections")

func clear_unused_previous_mods() -> void:
	for unused_previous_mod : UnitModContainer in mod_containers:
		unused_previous_mod.queue_free()
	mod_containers.clear()

func display_new_mods(unit_mods : Array[UnitMod]) -> void:
	for index : int in range(0, unit_mods.size()):
		var mod_container = unit_mod_container_scene.instantiate()
		mod_containers.append(mod_container)
		mod_container.global_position = global_corner_max;
		mod_container.global_position.x -= 300
		mod_container.global_position.y = global_corner_min.y + index * (global_corner_max.y - global_corner_min.y) / unit_mods.size()
		mod_container.scale = Vector2(0.44, 0.44)
		add_child(mod_container)
		mod_container.add_mod(unit_mods[index], Callable(self, "mod_event"))

func detach_species_selections() -> void:
	display_new_mods(species)

func detach_class_selections() -> void:
	clear_unused_previous_mods()
	display_new_mods(occupations)

func detach_equip_selections() -> void:
	clear_unused_previous_mods()
	display_new_mods(equipment)

func get_closest_hero_assembly(unit_mod_container : UnitModContainer) -> HeroAssemblyContainer:
	var best_dist : float = unit_mod_container.get_dist_from_home()
	var ret_val : HeroAssemblyContainer = null
	for hero : HeroAssemblyContainer in hero_containers:
		if hero.can_slot(unit_mod_container, phase):
			var dist_to_hero : float = hero.global_position.distance_to(unit_mod_container.global_position)
			if dist_to_hero < best_dist:
				best_dist = dist_to_hero
				ret_val = hero
	return ret_val

var umc_mouse_offset : Vector2
var current_closest_hero_assembly : HeroAssemblyContainer = null

func mod_event(unit_mod_container : UnitModContainer, event : int) -> void:
	if event == 0: # click on
		umc_mouse_offset = get_global_mouse_position() - unit_mod_container.global_position
	elif event == 1: # click off
		unit_mod_container.global_position = get_global_mouse_position() - umc_mouse_offset
		if current_closest_hero_assembly == null:
			unit_mod_container.return_home()
		else:
			current_closest_hero_assembly.add_mod_container(unit_mod_container, phase)
			mod_containers.erase(unit_mod_container)
			unit_mod_container.queue_free()
	elif event == 2: # mouse move
		unit_mod_container.global_position = get_global_mouse_position() - umc_mouse_offset
		var closest_hero : HeroAssemblyContainer = get_closest_hero_assembly(unit_mod_container)
		if closest_hero == current_closest_hero_assembly:
			return
		if current_closest_hero_assembly != null:
			current_closest_hero_assembly.stop_glowing()
		current_closest_hero_assembly = closest_hero
		if current_closest_hero_assembly != null:
			current_closest_hero_assembly.start_glowing()

func enter_state() -> void:
	super.enter_state()
	phase = Phase.SETUP
	call_deferred("load_work_area")
	#for child : Node in heroes_column.get_children():
		#if child is Label:
			#continue
		#if child is Separator:
			#continue
		#child.queue_free()

func exit_state(next_state: StateMachineState) -> void:
	hero_containers.clear()
	mod_containers.clear()
	species.clear()
	occupations.clear()
	equipment.clear()
	super.exit_state(next_state)

func _process(_delta: float) -> void:
	if global_corner_max == Vector2.ZERO:
		return

	if species.is_empty() && game != null:
		species = UnitMod.create_species_shuffle(game.rnd)
		assert(species.size() >= 5)
		setup_column("SpeciesColumn", species)
		occupations = UnitMod.create_occupation_shuffle(game.rnd)
		setup_column("ClassColumn", occupations)
		equipment = UnitMod.create_equipment_shuffle(game.rnd)
		setup_column("EquipColumn", equipment)
		change_phase(Phase.SPECIES_SELECT)

	match phase:
		Phase.SPECIES_SELECT:
			if all_heroes_have_species():
				change_phase(Phase.CLASS_SELECT)
		Phase.CLASS_SELECT:
			if all_heroes_have_class():
				change_phase(Phase.EQUIP_SELECT)
		Phase.EQUIP_SELECT:
			if all_heroes_have_equip():
				export_heroes()

func assign_hero_name(index : int, hero_name : String) -> void:
	hero_containers[index].assign_hero_name(hero_name)

func slot_mod_in_hero(index : int, mod : UnitMod) -> void:
	hero_containers[index].add_mod(mod, phase)

func all_heroes_have_species() -> bool:
	return !hero_containers.any(func(a : HeroAssemblyContainer) : return a.is_missing_species())

func all_heroes_have_class() -> bool:
	return !hero_containers.any(func(a : HeroAssemblyContainer) : return a.is_missing_class())

func all_heroes_have_equip() -> bool:
	return !hero_containers.any(func(a : HeroAssemblyContainer) : return a.is_missing_equip())

func export_heroes() -> void:
	var unit_stats : Array[UnitStats]
	for hero_assembly : HeroAssemblyContainer in hero_containers:
		unit_stats.append(UnitStats.load_hero(hero_assembly.species, hero_assembly.occupation, hero_assembly.equip, hero_assembly.unit_name))
	game.load_in_heroes(unit_stats)
	our_state_machine.switch_state("LoopExposition")

func _on_random_button_button_up() -> void:
	game.initialize_heroes()
	#our_state_machine.switch_state("PathSelection")
	#our_state_machine.switch_state("Testing_PrepElo")
	our_state_machine.switch_state("LoopExposition")
