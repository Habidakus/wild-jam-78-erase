extends StateMachineState

var game : Game = null
var skill_a : SkillGraphic
var skill_b : SkillGraphic
var skill_c : SkillGraphic

var callable_a_on : Callable
var callable_a_off : Callable
var callable_a_click : Callable
var callable_b_on : Callable
var callable_b_off : Callable
var callable_b_click : Callable
var callable_c_on : Callable
var callable_c_off : Callable
var callable_c_click : Callable

func init(_game : Game) -> void:
	game = _game
	skill_a = find_child("SkillA") as SkillGraphic
	skill_b = find_child("SkillB") as SkillGraphic
	skill_c = find_child("SkillC") as SkillGraphic
	
func enter_state() -> void:
	super.enter_state()
	game.calculate_elo()
	game.preserve_heroes()
	game.clean_up_game_state()
	game.perform_skills(SkillStats.SkillPhase.POST_COMBAT, game.heroes, [])
	game.ready_battle_space()
	
	var skill_box : HBoxContainer = find_child("SkillBox") as HBoxContainer
	var skill_list : Array[Array] = game.get_viable_skills()
	
	if skill_list.is_empty():
		our_state_machine.switch_state("PathSelection")
		return

	skill_a.show()
	skill_a.modulate = Color.WHITE
	skill_a.init(skill_list[0][1], skill_list[0][0])
	callable_a_on = Callable(self, "skill_hover").bind(true, skill_a)
	callable_a_off = Callable(self, "skill_hover").bind(false, skill_a)
	callable_a_click = Callable(game, "skill_click").bind(skill_list[0][1], skill_list[0][0])
	skill_a.mouse_entered.connect(callable_a_on)
	skill_a.mouse_exited.connect(callable_a_off)
	skill_a.gui_input.connect(callable_a_click)

	if skill_list.size() > 1:
		skill_b.show()
		skill_b.modulate = Color.WHITE
		skill_b.init(skill_list[1][1], skill_list[1][0])
		callable_b_on = Callable(self, "skill_hover").bind(true, skill_b)
		callable_b_off = Callable(self, "skill_hover").bind(false, skill_b)
		callable_b_click = Callable(game, "skill_click").bind(skill_list[1][1], skill_list[1][0])
		skill_b.mouse_entered.connect(callable_b_on)
		skill_b.mouse_exited.connect(callable_b_off)
		skill_b.gui_input.connect(callable_b_click)
	else:
		skill_b.hide()
		
	if skill_list.size() > 2:
		skill_c.show()
		skill_c.modulate = Color.WHITE
		skill_c.init(skill_list[2][1], skill_list[2][0])
		callable_c_on = Callable(self, "skill_hover").bind(true, skill_c)
		callable_c_off = Callable(self, "skill_hover").bind(false, skill_c)
		callable_c_click = Callable(game, "skill_click").bind(skill_list[2][1], skill_list[2][0])
		skill_c.mouse_entered.connect(callable_c_on)
		skill_c.mouse_exited.connect(callable_c_off)
		skill_c.gui_input.connect(callable_c_click)
	else:
		skill_c.hide()
	
	skill_box.force_update_transform()
	
	#game.initialize_heroes()

func skill_hover(entered : bool, card : SkillGraphic) -> void:
	if entered:
		card.modulate = Color.AQUA
	else:
		card.modulate = Color.WHITE

func exit_state(next_state: StateMachineState) -> void:
	if skill_a.mouse_entered.is_connected(callable_a_on):
		skill_a.mouse_entered.disconnect(callable_a_on)
		skill_a.mouse_exited.disconnect(callable_a_off)
		skill_a.gui_input.disconnect(callable_a_click)
	if skill_b.mouse_entered.is_connected(callable_b_on):
		skill_b.mouse_entered.disconnect(callable_b_on)
		skill_b.mouse_exited.disconnect(callable_b_off)
		skill_b.gui_input.disconnect(callable_b_click)
	if skill_c.mouse_entered.is_connected(callable_c_on):
		skill_c.mouse_entered.disconnect(callable_c_on)
		skill_c.mouse_exited.disconnect(callable_c_off)
		skill_c.gui_input.disconnect(callable_c_click)

	super.exit_state(next_state)
