class_name MMCDebug extends RefCounted
## Class used to help debug usage of the [MinMaxCalculator]
##
## If you're having trouble determining why one action was chosen over another, and suspect there's
## a bug with your score evaluation code, you can give an instance of [MMCDebug] to the [method MinMaxCalculator.get_best_action]
## function and then invoke the [method dump] function to have all the considered actions and game states printed out.

var _all_game_states : Dictionary # key = MMCGameState, value = Dictionary<Action, [Score, GameState]>

func _add_actions(game_state : MMCGameState, actions : Array[MMCAction]) -> void:
	var gsactions : Dictionary
	for action : MMCAction in actions:
		gsactions[action] = []
	if _all_game_states.has(game_state):
		print("Code failure: game state already registered with this MMCDebug instance")
	else:
		_all_game_states[game_state] = gsactions

func _add_result(game_state : MMCGameState, action : MMCAction, result_state : MMCGameState, score : MMCScore) -> void:
	if _all_game_states.has(game_state):
		if _all_game_states[game_state].has(action):
			_all_game_states[game_state][action] = [score, result_state]
		else:
			print("MMCDebug[" + str(game_state) + "] has no action: " + str(action))
	else:
		print("NO GAME STATE FOUND in MMCDebug: " + str(game_state))

func _indent(index : int) -> String:
	var ret_val : String = ""
	for i in range(0, index):
		ret_val += "  "
	return ret_val

## Will invoke the print() function for each action/game_state pair in the evaluation tree. Note
## that your implementations of game state and action should also implement _to_string() in order
## to be useful when the dump() method is called.
func dump(game_state : MMCGameState, file : FileAccess) -> void:
	file.store_line("previous state = " + str(game_state))
	var action_dict : Dictionary = _all_game_states[game_state]
	if action_dict.is_empty():
		file.store_line(_indent(1) + "NO ACTIONS")
		return

	for action in action_dict.keys():
		var tupple : Array = action_dict[action]
		if tupple.is_empty():
			file.store_line(_indent(1) + str(action) + " : not evaluated")
		else:
			file.store_line(_indent(1) + "vvv " + str(action) + " vvv")
			_dump_internal(2, tupple[0], tupple[1], file)
			file.store_line(_indent(1) + "^^^ " + str(action.get_score()) + " ^^^")

func _dump_internal(ind : int, score : MMCScore, game_state : MMCGameState, file : FileAccess) -> void:
	file.store_line(_indent(ind) + str(game_state) + ": " + str(score))
	
	var action_dict : Dictionary = _all_game_states[game_state]
	if action_dict.is_empty():
		file.store_line(_indent(ind + 1) + "NO ACTIONS")
		return
		
	for action in action_dict.keys():
		var tupple : Array = action_dict[action]
		if tupple.is_empty():
			file.store_line(_indent(ind + 1) + str(action) + " : not evaluated")
		else:
			file.store_line(_indent(ind + 1) + "vvv " + str(action) + " vvv")
			_dump_internal(ind + 2, tupple[0], tupple[1], file)
			file.store_line(_indent(ind + 1) + "^^^ " + str(action.get_score()) + " ^^^")
