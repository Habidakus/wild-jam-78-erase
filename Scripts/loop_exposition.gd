extends StateMachineState_PressAnyKey

var pre_castle_events : Array[Array] = [
	[
		"NAME tricked the Brain Slime of the Hollow Plains into devouring itself.",
		"You had to waste a year slowly sneaking through the Hollow Plains an inch at a time, just to avoid the dreaded Brain Slime."
	],
	[
		"The voratious Tinariwen Lion was slain in bloody combat by NAME.",
		"You came across an entire town that had been devoured by the Tinariwen Lion."
	],
	[
		"NAME escorted the 10,000 orphans of Boreas across the Western marshes.",
		"You were struck wordless for a month when you heard of the tragedy of the Boreas orphans."
	],
	[
		"NAME decyphered the puzzle of the Staedtler Labyrinth, leading you to freedom.",
		"The craven Staedtler Oracles, decieved by a false prophecy, locked you away in their labyrinth - your liberty gained only when they died from internecine fighting."
	],
	[
		"NAME defeated the greedy Governor Tombow in a personal challenge match.",
		"The vile Governor Tombow keep you locked in his gladitorial arena for a year, before begrudgingly granting your earned freedom."
	],
	[
		"Using unparalleled diplomatic skills, NAME convinced the warring nations of Pentel and Castell to stop their ruinous conflict.",
		"You were brought to tears while marching through the war ravaged nations of Pentel and Cestell, their populations devistated, their cities in ruins."
	],
	[
		"NAME rounded up the twelve notorious bandit leaders of the Faber trade road.",
		"You were force to detoured through the Mono Sand Swamps - an extreme choice, but not as frought as endouring the once-famous Faber trade road which was now a bandit plagued gauntlet." 
	]
]

var game : Game
var hero_event_binding : Dictionary # <event index, hero ID>
var event_order : Array[int]
var event_shuffle : Array[Array]

func init(_game : Game, rnd : RandomNumberGenerator) -> void:
	game = _game
	for i : int in range(0, pre_castle_events.size()):
		var order : float = rnd.randf()
		event_shuffle.append([i, order])
	event_shuffle.sort_custom(func(a, b) : return a[1] < b[1])

func enter_state() -> void:
	super.enter_state()
	
	if event_order.is_empty():
		var index : int = 0
		assert(game.heroes.size() > 0)
		for hero : UnitStats in game.heroes:
			hero_event_binding[event_shuffle[index][0]] = hero.id 
			event_order.append(event_shuffle[index][0])
			index += 1
	
	var text : RichTextLabel = find_child("RichTextLabel") as RichTextLabel
	text.text = "Your brand of adventurers has been through so much to reach the dread Fortress of the Chronotyrant.\n\n"
	var success_text : Array[String]
	var failure_text : Array[String]
	for event_index : int in event_order:
		var hero_id : int = hero_event_binding[event_index]
		var matching_heroes : Array[UnitStats] = game.heroes.filter(func(a) : return a.id == hero_id)
		if matching_heroes.is_empty():
			failure_text.append(pre_castle_events[event_index][1])
		elif matching_heroes.size() == 1:
			var hero : UnitStats = matching_heroes[0]
			var line : String = pre_castle_events[event_index][0] as String
			if line.substr(0, 4) == "NAME":
				line = "+" + line
			success_text.append(line.replace("NAME", hero.unit_name))
	for i : int in range(0, success_text.size()):
		if i == 0:
			text.text += success_text[i].replace("+", "")
		elif i == success_text.size() - 1:
			text.text += " And "
			var first_letter : String = success_text[i].substr(0, 1)
			var rest : String = success_text[i].substr(1)
			if first_letter != "+":
				text.text += first_letter.to_lower()
			text.text += rest
		else:
			text.text += " " + success_text[i].replace("+", "")
	if !failure_text.is_empty():
		text.text += "\n\nBut for all your valour, the journey across the lands was heartbreaking. "
		for j : int in range(0, failure_text.size()):
			if j == 0:
				text.text += failure_text[j]
			elif j == failure_text.size() - 1:
				text.text += " And "
				var first_letter : String = failure_text[j].substr(0, 1)
				var rest : String = failure_text[j].substr(1)
				text.text += first_letter.to_lower()
				text.text += rest
			else:
				text.text += " " + failure_text[j]

	text.text += "\n\nBut your quest is nearly at an end - for now you stand before the Fortress of the dread Chronotyrant."
