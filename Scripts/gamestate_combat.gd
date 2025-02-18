class_name SMSCombat extends StateMachineState

var game : Game = null
const rest : float = 1.0
var cooldown : float = rest
var human_moves : Array[EAction]

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

func set_human_moves(moves : Array[MMCAction], hover_callback : Callable, click_callback : Callable) -> void:
	assert(human_moves.is_empty())
	for move : MMCAction in moves:
		var emove : EAction = move as EAction
		human_moves.append(emove)
		var actor_graphic : UnitGraphics = game.battle_space_figures[emove.actorID]
		var target_graphic : UnitGraphics = game.battle_space_figures[emove.targetID]
		var target_stats : UnitStats = game.game_state.get_unit_by_id(emove.targetID)
		if emove.actorID != emove.targetID:
			actor_graphic.add_draw_attack(target_graphic, emove.attack, target_stats, hover_callback.bind(emove), click_callback.bind(emove))
		else:
			actor_graphic.add_draw_action(emove.attack, target_stats, hover_callback.bind(emove), click_callback.bind(emove))

func has_human_moves() -> bool:
	return !human_moves.is_empty()

func clear_human_moves() -> void:
	human_moves.clear()
