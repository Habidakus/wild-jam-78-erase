extends StateMachineState

func _on_button_button_up() -> void:
	our_state_machine.switch_state("Game")

func _on_credits_button_up() -> void:
	our_state_machine.switch_state("Credits")
