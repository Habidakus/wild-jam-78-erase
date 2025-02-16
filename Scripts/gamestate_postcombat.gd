extends StateMachineState

var game : Game = null

func init(_game : Game) -> void:
	game = _game
	
func enter_state() -> void:
	super.enter_state()
	game.calculate_elo()
	game.initialize_heroes()
	our_state_machine.switch_state("Combat")
	
