extends StateMachineState

var game : Game

func init(_game : Game) -> void:
	game = _game
	
func _process(_delta: float) -> void:
	game.initialize_heroes()
	#our_state_machine.switch_state("PathSelection")
	our_state_machine.switch_state("LoopExposition")
