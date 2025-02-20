extends StateMachineState

var in_decision_state : bool = false
var game : Game

func init(_game : Game) -> void:
	game = _game

func enter_state() -> void:
	super.enter_state()
	in_decision_state = false
	find_child("Rant").show()
	find_child("Choice").hide()
	var hero_box : VBoxContainer = find_child("HeroBox") as VBoxContainer
	for child in hero_box.get_children():
		hero_box.remove_child(child)
		child.queue_free()

func switch_to_decision() -> void:
	in_decision_state = true
	find_child("Rant").hide()
	find_child("Choice").show()
	
	var hero_box : VBoxContainer = find_child("HeroBox") as VBoxContainer
	for hero : UnitStats in game.heroes:
		var button : Button = Button.new()
		button.text = hero.unit_name
		button.icon = hero.get_texture()
		button.tooltip_text = hero.create_tooltip()
		hero_box.add_child(button)
		button.pressed.connect(Callable(game, "destroy_hero").bind(hero))

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
