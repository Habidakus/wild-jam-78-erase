class_name ActionFXContainer extends RefCounted

var damages : Array[Array] # <unit id, float>
var stunned_unit_id : int = -1
var attacker_unit_id : int = -1
var bleeding_unit_id : int = -1
var tiring_unit_id : int = -1
var stunned_time : float = 0

const texture_stunned : Texture = preload("res://Art/Net.png")
const texture_basic_attack : Texture = preload("res://Art/SingleSword.png")
const texture_blood_drop : Texture = preload("res://Art/BloodDrop.png")
const texture_sweat_drop : Texture = preload("res://Art/SweatDrop.png")

func render_fx(unit_graphics_map : Dictionary) -> void: # <unit id, UnitGraphics>
	render_stunned(unit_graphics_map)
	render_damages(unit_graphics_map)
	render_bleeding(unit_graphics_map)
	render_tiring(unit_graphics_map)

func render_bleeding(unit_graphics_map : Dictionary) -> void:
	if unit_graphics_map.has(bleeding_unit_id):
		var unit_graphics : UnitGraphics = unit_graphics_map[bleeding_unit_id]
		var blood_drop : FallingVFX = FallingVFX.create(texture_blood_drop, 1.25)
		blood_drop.position = unit_graphics.size / 2
		unit_graphics.add_child(blood_drop)

func render_tiring(unit_graphics_map : Dictionary) -> void:
	if unit_graphics_map.has(tiring_unit_id):
		var unit_graphics : UnitGraphics = unit_graphics_map[tiring_unit_id]
		var sweat_drop : FallingVFX = FallingVFX.create(texture_sweat_drop, 1.25)
		sweat_drop.position = unit_graphics.size / 2
		unit_graphics.add_child(sweat_drop)

func render_stunned(unit_graphics_map : Dictionary) -> void:
	if unit_graphics_map.has(stunned_unit_id):
		var attacker_graphics : UnitGraphics = unit_graphics_map[attacker_unit_id]
		var unit_graphics : UnitGraphics = unit_graphics_map[stunned_unit_id]
		var tween : Tween = unit_graphics.create_tween()
		var net : Sprite2D = Sprite2D.new()
		net.texture = texture_stunned
		net.position = attacker_graphics.global_position - unit_graphics.global_position 
		unit_graphics.add_child(net)
		tween.tween_property(net, "rotation_degrees", 90, 0.95)
		tween.parallel()
		tween.tween_property(net, "position", unit_graphics.size / 2, 0.75)
		tween.tween_property(net, "modulate", Color(1, 1, 1, 0), 0.20)
		tween.tween_callback(Callable(self, "clean_up_net").bind(unit_graphics, net))

func throw_sword(target_graphics : UnitGraphics, attacker_graphics : UnitGraphics) -> void:
	var tween : Tween = target_graphics.create_tween()
	var sword : Sprite2D = Sprite2D.new()
	sword.texture = texture_basic_attack
	sword.position = attacker_graphics.global_position - target_graphics.global_position 
	target_graphics.add_child(sword)
	sword.rotation_degrees = 90 if sword.position.x < 0 else -90
	#tween.tween_property(net, "rotation_degrees", 90, 0.95)
	tween.parallel()
	tween.tween_property(sword, "position", target_graphics.size / 2, 0.75)
	tween.tween_property(sword, "modulate", Color(1, 1, 1, 0), 0.20)
	tween.tween_callback(Callable(self, "clean_up_net").bind(target_graphics, sword))

func render_damages(unit_graphics_map : Dictionary) -> void:
	for entry in damages:
		var unit_id : int = entry[0]
		if unit_graphics_map.has(unit_id):
			var unit_graphics : UnitGraphics = unit_graphics_map[unit_id]
			var dmg : float = entry[1]
			var healing : bool = false
			if dmg < 0:
				healing = true
				dmg = 0 - dmg
			dmg = max(1, round(dmg))
			var color : Color = Color.GREEN if healing else Color.ORANGE_RED
			var floating_text : FloatingText = FloatingText.create(str(dmg), color, 1.25)
			floating_text.position = unit_graphics.size / 2
			unit_graphics.add_child(floating_text)
			if !healing:
				if stunned_unit_id != unit_id: # Don't bother throwing sword if we're throwing net
					if unit_graphics_map.has(attacker_unit_id):
						var attacker_graphics : UnitGraphics = unit_graphics_map[attacker_unit_id]
						throw_sword(unit_graphics, attacker_graphics)

func clean_up_net(unit_graphics : UnitGraphics, net : Sprite2D) -> void:
	unit_graphics.remove_child(net)
	net.queue_free()

func add_cooldown(_unit : UnitStats):
	print("TODO: Add Cooldown triggered VFX")
func expend_single_use(_unit : UnitStats):
	print("TODO: Add single-use consumed VFX")

func apply_bleed(unit : UnitStats):
	bleeding_unit_id = unit.id

func add_tiring(unit : UnitStats):
	tiring_unit_id = unit.id

func add_stun(attacker : UnitStats, target : UnitStats, time : float):
	assert(stunned_unit_id == -1)
	if time > 0:
		attacker_unit_id = attacker.id
		stunned_unit_id = target.id
		stunned_time = time
	else:
		print("TODO: Add Hurry Up VFX")

func apply_heal(unit : UnitStats, dmg : float):
	damages.append([unit.id, 0 - dmg])

func apply_damage(attacker : UnitStats, unit : UnitStats, dmg : float):
	if attacker != null:
		attacker_unit_id = attacker.id
	damages.append([unit.id, dmg])

func bleed_once(unit : UnitStats, dmg : float):
	apply_damage(null, unit, dmg)
