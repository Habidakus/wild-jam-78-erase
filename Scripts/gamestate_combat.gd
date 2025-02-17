class_name SMSCombat extends StateMachineState

var game : Game = null
const rest : float = 1.0
var cooldown : float = rest
var human_moves : Array[EAction]
var draw_list : Array

func init(_game : Game) -> void:
	game = _game

func enter_state() -> void:
	super.enter_state()
	game.initialize_foes()
	
func _process(_delta: float) -> void:
	if cooldown > 0:
		cooldown -= _delta
		return
	
	cooldown = rest
	if game.is_fight_finished():
		our_state_machine.switch_state("PostCombat")
		return
		
	game.run_one_turn()
	#if !draw_list.is_empty():
		#queue_redraw()
#
#func _draw() -> void:
	#var arena : ColorRect = find_child("Arena") as ColorRect
	#var arena_pos : Vector2 = arena.position
	#for entry : Array in draw_list:
		#var actor : UnitGraphics = entry[0] as UnitGraphics
		#if entry.size() == 2:
			## applies to self
			#draw_circle(actor.position - Vector2(64, 0), 32, Color.BLUE_VIOLET)
		#else:
			## applies to target
			#var target : UnitGraphics = entry[1] as UnitGraphics
			#actor.queue_redraw()
			#actor.draw_line(Vector2.ZERO, target.position - actor.position, Color.GREEN, 4)
			#draw_line(actor.position, (entry[1] as UnitGraphics).position, Color.RED, 4)

func set_human_moves(moves : Array[MMCAction]) -> void:
	assert(human_moves.is_empty())
	assert(draw_list.is_empty())
	for move : MMCAction in moves:
		var emove : EAction = move as EAction
		human_moves.append(emove)
		var actor_graphic : UnitGraphics = game.battle_space_figures[emove.actorID]
		var target_graphic : UnitGraphics = game.battle_space_figures[emove.targetID]
		if emove.actorID != emove.targetID:
			draw_list.append([actor_graphic, target_graphic, emove.attack.attack_name])
			actor_graphic.add_draw_attack(target_graphic, emove.attack)
		else:
			draw_list.append([actor_graphic, emove.attack.attack_name])
			actor_graphic.add_draw_action(emove.attack)

func has_human_moves() -> bool:
	return !human_moves.is_empty()
