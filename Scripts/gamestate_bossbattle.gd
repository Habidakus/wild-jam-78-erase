extends StateMachineState

var in_decision_state : bool = false
var game : Game
var hero_box : GridContainer

func init(_game : Game) -> void:
	game = _game
	hero_box = find_child("HeroBox") as GridContainer
	assert(hero_box)

func enter_state() -> void:
	super.enter_state()
	in_decision_state = false
	find_child("Rant").show()
	find_child("Choice").hide()
	for child in hero_box.get_children():
		hero_box.remove_child(child)
		child.queue_free()

func exit_state(next_state: StateMachineState) -> void:
	# TODO: We should ramp up the speed of the background and then ramp down, before fading out
	game.perform_post_loop_heals()
	super.exit_state(next_state)

func switch_to_decision() -> void:
	in_decision_state = true
	find_child("Rant").hide()
	find_child("Choice").show()
	
	for hero : UnitStats in game.heroes:
		var button : Button = Button.new()
		button.text = hero.unit_name
		button.icon = hero.get_texture()
		button.tooltip_text = hero.create_tooltip()
		hero_box.add_child(button)
		button.pressed.connect(Callable(game, "destroy_hero").bind(hero))
		var label : Label = Label.new()
		label.text = hero.describe_learned_skills()
		label.add_theme_color_override("font_color", Color.BLACK)
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
		label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		hero_box.add_child(label)

func _input(event : InputEvent) -> void:
	_handle_event(event)

func _unhandled_input(event : InputEvent) -> void:
	_handle_event(event)

func _handle_event(event : InputEvent) -> void:
	if in_decision_state:
		return
	if event.is_released():
		if event is InputEventKey:
			switch_to_decision()
		if event is InputEventMouseButton:
			switch_to_decision()
