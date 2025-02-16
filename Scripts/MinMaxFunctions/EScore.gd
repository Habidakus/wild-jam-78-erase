class_name EScore extends MMCScore

var numerical_advantage : int = 0
var health_advantage : float = 0

func reversed() -> MMCScore:
	var ret_val : EScore = EScore.new()
	ret_val.numerical_advantage = 0 - numerical_advantage
	ret_val.health_advantage = 0 - health_advantage
	return ret_val

func is_better_than(other : MMCScore) -> bool:
	var other_escore : EScore = other as EScore
	if numerical_advantage != other_escore.numerical_advantage:
		return numerical_advantage > other_escore.numerical_advantage
	if health_advantage != other_escore.health_advantage:
		return health_advantage > other_escore.health_advantage
	return false
