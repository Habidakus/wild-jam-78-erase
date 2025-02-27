extends StateMachineState

var active : bool = false
var game : Game

func _process(_delta: float) -> void:
	if active:
		active = false
		game.calculate_elo()
		game.clean_up_game_state()
		our_state_machine.switch_state("Testing_PrepElo")

func enter_state() -> void:
	super.enter_state()
	active = true
	game = get_parent().get_parent() as Game
	assert(game)
