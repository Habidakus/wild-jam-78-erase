class_name EScore extends MMCScore

var numerical_advantage : int = 0
var health_advantage : float = 0
var reverse : bool = false

func _to_string() -> String:
	var ret_val : String = ""
	if numerical_advantage != 0:
		if numerical_advantage > 0:
			ret_val = "living +" + str(numerical_advantage)
		else:
			ret_val = "living " + str(numerical_advantage)
		ret_val += ", "
	if health_advantage != 0:
		if health_advantage > 0:
			ret_val += "hp +" + str(health_advantage)
		else:
			ret_val += "hp " + str(health_advantage)
	if ret_val.is_empty():
		ret_val = "EQUAL"
	return ret_val

func reversed() -> MMCScore:
	var ret_val : EScore = EScore.new()
	ret_val.numerical_advantage = 0 - numerical_advantage
	ret_val.health_advantage = 0 - health_advantage
	ret_val.reverse = reverse
	return ret_val

func is_better_than(other : MMCScore) -> bool:
	var other_escore : EScore = other as EScore
	if reverse:
		if numerical_advantage != other_escore.numerical_advantage:
			return numerical_advantage < other_escore.numerical_advantage
		if health_advantage != other_escore.health_advantage:
			return health_advantage < other_escore.health_advantage
		return false
		
	if numerical_advantage != other_escore.numerical_advantage:
		return numerical_advantage > other_escore.numerical_advantage
	if health_advantage != other_escore.health_advantage:
		return health_advantage > other_escore.health_advantage
	return false
