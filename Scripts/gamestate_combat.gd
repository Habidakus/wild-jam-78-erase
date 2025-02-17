class_name Combat extends StateMachineState

var game : Game = null

func init(_game : Game) -> void:
	game = _game

func enter_state() -> void:
	super.enter_state()
	game.initialize_foes()
	
func _process(_delta: float) -> void:
	if game.is_fight_finished():
		our_state_machine.switch_state("PostCombat")
	else:
		game.run_one_turn()
