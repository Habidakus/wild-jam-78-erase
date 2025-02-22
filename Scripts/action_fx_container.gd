class_name ActionFXContainer extends RefCounted

var damages : Array[Array] # <unit id, float>
var stunned_unit_id : int = -1
var stunner_unit_id : int = -1
var stunned_time : float = 0

const texture_stunned : Texture = preload("res://Art/Net.png")

func render_fx(unit_graphics_map : Dictionary) -> void: # <unit id, UnitGraphics>
	if unit_graphics_map.has(stunned_unit_id):
		var attacker_graphics : UnitGraphics = unit_graphics_map[stunner_unit_id]
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

func clean_up_net(unit_graphics : UnitGraphics, net : Sprite2D) -> void:
	unit_graphics.remove_child(net)
	net.queue_free()

func add_tiring(_unit : UnitStats):
	print("TODO: Add Tiring VFX")
func apply_bleed(_unit : UnitStats):
	print("TODO: Add Bleed-applied VFX")
func add_cooldown(_unit : UnitStats):
	print("TODO: Add Cooldown triggered VFX")
func expend_single_use(_unit : UnitStats):
	print("TODO: Add single-use consumed VFX")

func add_stun(attacker : UnitStats, target : UnitStats, time : float):
	assert(stunned_unit_id == -1)
	stunner_unit_id = attacker.id
	stunned_unit_id = target.id
	stunned_time = time

func apply_heal(unit : UnitStats, dmg : float):
	damages.append([unit.id, 0 - dmg])

func apply_damage(unit : UnitStats, dmg : float):
	damages.append([unit.id, dmg])

func bleed_once(unit : UnitStats, dmg : float):
	apply_damage(unit, dmg)
