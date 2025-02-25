extends StateMachineState

var in_decision_state : bool = false
var final_battle : bool = false
var game : Game
var hero_box : GridContainer
var audio_stream_player : AudioStreamPlayer
var rant_sound : AudioStreamMP3 = preload("res://Sounds/rant.mp3")
var resurrection_sound : AudioStreamWAV = preload("res://Sounds/resurrection_03.wav")

func init(_game : Game) -> void:
	game = _game
	hero_box = find_child("HeroBox") as GridContainer
	assert(hero_box)
	audio_stream_player = find_child("AudioStreamPlayer") as AudioStreamPlayer
	assert(audio_stream_player)
	audio_stream_player.finished.connect(Callable(self, "release_exit"))

func enter_state() -> void:
	super.enter_state()
	in_decision_state = false
	find_child("Choice").hide()
	for child in hero_box.get_children():
		hero_box.remove_child(child)
		child.queue_free()
	if game.heroes.size() == 3:
		final_battle = true
		find_child("Rant").hide()
		find_child("FinalBattle").show()
	else:
		find_child("FinalBattle").hide()
		find_child("Rant").show()
		if game.heroes.size() == 5:
			audio_stream_player.stop()
			audio_stream_player.stream = rant_sound
			audio_stream_player.play()

var exit_when_stream_finishes : bool = false
var waiting_on_stream_to_finish : bool = false
var next_state : StateMachineState = null

func _process(_delta: float) -> void:
	if exit_when_stream_finishes:
		if waiting_on_stream_to_finish:
			return
		else:
			exit_when_stream_finishes = false
			waiting_on_stream_to_finish = false
			super.exit_state(next_state)

func exit_state(_next_state: StateMachineState) -> void:
	# TODO: We should ramp up the speed of the background and then ramp down, before fading out
	game.perform_post_loop_heals()
	exit_when_stream_finishes = true
	#super.exit_state(next_state)

func release_exit() -> void:
	assert(exit_when_stream_finishes)
	waiting_on_stream_to_finish = false

func play_erase_sound() -> void:
	
	for child in hero_box.get_children():
		hero_box.remove_child(child)
		child.queue_free()
		
	waiting_on_stream_to_finish = true
	audio_stream_player.stop()
	audio_stream_player.stream = resurrection_sound
	audio_stream_player.play()

func switch_to_decision() -> void:
	if final_battle:
		final_battle = false
		game.set_final_battle()
		our_state_machine.switch_state("Combat")
		return

	in_decision_state = true
	find_child("Rant").hide()
	find_child("FinalBattle").hide()
	find_child("Choice").show()
	
	for hero : UnitStats in game.heroes:
		var button : Button = Button.new()
		button.text = hero.unit_name
		button.icon = hero.get_texture()
		button.tooltip_text = hero.create_tooltip()
		hero_box.add_child(button)
		button.pressed.connect(Callable(game, "destroy_hero").bind(hero))
		var label : RichTextLabel = RichTextLabel.new()
		label.text = hero.describe_learned_skills()
		label.add_theme_color_override("default_color", Color.BLACK)
		label.custom_minimum_size = Vector2(200, 0)
		label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		label.fit_content = true
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
