class_name Combat extends StateMachineState

var game : Game = null
const rest : float = 1.0
var cooldown : float = rest

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
