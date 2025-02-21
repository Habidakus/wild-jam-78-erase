extends StateMachineState

var game : Game = null

func init(_game : Game) -> void:
	game = _game
	
func enter_state() -> void:
	super.enter_state()
	game.calculate_elo()
	game.preserve_heroes()
	game.clean_up_game_state()
	game.ready_battle_space()
	#game.initialize_heroes()
	our_state_machine.switch_state("PathSelection")
	
