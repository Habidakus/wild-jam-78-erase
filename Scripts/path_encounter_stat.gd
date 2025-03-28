class_name PathEncounterStat extends RefCounted

enum EncounterType { UNDEFINED, GOBLIN, SPIDERS, SLIMES, DRACONIC, UNDEAD, MISC, CHEST, CHRONOTYRANT}

var encounter_type : EncounterType = EncounterType.UNDEFINED
var graph_pos : Vector2i
var map_pos : Vector2
var sort_value : float
var visited : bool = false
var can_visit : bool = false
var title : String = "???"
var west : Array[PathEncounterStat]
var east : Array[PathEncounterStat]

const goblin_texture : Texture = preload("res://Art/TwoSwords.png")
const chest_texture : Texture = preload("res://Art/Chest.png")
const chronotyrant_texture : Texture = preload("res://Art/Hourglass.png")
const undead_texture : Texture = preload("res://Art/TombStone.png")
const spider_texture : Texture = preload("res://Art/SpiderMapIcon.png")
const dragon_texture : Texture = preload("res://Art/DragonMapIcon.png")
const sewer_texture : Texture = preload("res://Art/Path_Sewer.png")

func visit() -> void:
	visited = true

func flood_fill() -> void:
	can_visit = true
	for e : PathEncounterStat in east:
		e.flood_fill()

func get_icon() -> Texture:
	if encounter_type == EncounterType.SPIDERS:
		return spider_texture
	elif encounter_type == EncounterType.DRACONIC:
		return dragon_texture
	elif encounter_type == EncounterType.GOBLIN:
		return goblin_texture
	elif encounter_type == EncounterType.CHRONOTYRANT:
		return chronotyrant_texture
	elif encounter_type == EncounterType.UNDEAD:
		return undead_texture
	elif encounter_type == EncounterType.CHEST:
		return chest_texture
	elif encounter_type == EncounterType.SLIMES:
		return sewer_texture
	else:
		return null

func init(x : int, y : int, pos : Vector2, _sort_value : float) -> void:
	graph_pos = Vector2i(x, y)
	map_pos = pos
	sort_value = _sort_value

func set_encounter_type(n : String, et : EncounterType) -> void:
	title = n
	encounter_type = et

func connect_path_to(other : PathEncounterStat) -> void:
	assert(abs(graph_pos.x - other.graph_pos.x) == 1)
	if other.graph_pos.x < graph_pos.x:
		other.east.append(self)
		west.append(other)
	else:
		other.west.append(self)
		east.append(other)

func needs_paths() -> bool:
	if graph_pos != Vector2i.ZERO && west.is_empty():
		return true
	if encounter_type != EncounterType.CHRONOTYRANT && east.is_empty():
		return true
	return false

static func get_path_encounter_stat_at_graph_coords(all_paths : Array[PathEncounterStat], coord : Vector2i) -> PathEncounterStat:
	for pes : PathEncounterStat in all_paths:
		if pes.graph_pos == coord:
			return pes
	return null

func add_paths(all_paths : Array[PathEncounterStat], rnd : RandomNumberGenerator) -> void:
	if graph_pos != Vector2i.ZERO && west.is_empty():
		var potential : Array[PathEncounterStat]
		var w = get_path_encounter_stat_at_graph_coords(all_paths, graph_pos + Vector2i(-1, 0))
		if w != null:
			potential.append(w)
		var north_west = get_path_encounter_stat_at_graph_coords(all_paths, graph_pos + Vector2i(-1, 1))
		if north_west != null:
			potential.append(north_west)
		var south_west = get_path_encounter_stat_at_graph_coords(all_paths, graph_pos + Vector2i(-1, -1))
		if south_west != null:
			potential.append(south_west)
		if potential.is_empty():
			potential.append(get_path_encounter_stat_at_graph_coords(all_paths, graph_pos + Vector2i(-1, -2)))
		
		if !potential.is_empty():
			var selected : PathEncounterStat = potential[rnd.randi_range(0, potential.size() - 1)]
			connect_path_to(selected)
		else:
			print("path encounter " + EncounterType.keys()[encounter_type] + " at " + str(graph_pos) + " has no western neighbors?")
	if encounter_type != EncounterType.CHRONOTYRANT && east.is_empty():
		var potential : Array[PathEncounterStat]
		var e = get_path_encounter_stat_at_graph_coords(all_paths, graph_pos + Vector2i(1, 0))
		if e != null:
			potential.append(e)
		var north_east = get_path_encounter_stat_at_graph_coords(all_paths, graph_pos + Vector2i(1, 1))
		if north_east != null:
			potential.append(north_east)
		var south_east = get_path_encounter_stat_at_graph_coords(all_paths, graph_pos + Vector2i(1, -1))
		if south_east != null:
			potential.append(south_east)
		if potential.is_empty():
			potential.append(get_path_encounter_stat_at_graph_coords(all_paths, graph_pos + Vector2i(1, -2)))
		if !potential.is_empty():
			var selected : PathEncounterStat = potential[rnd.randi_range(0, potential.size() - 1)]
			connect_path_to(selected)
		else:
			print("path encounter " + EncounterType.keys()[encounter_type] +  " at " + str(graph_pos) + " has no eastern neighbors?")
