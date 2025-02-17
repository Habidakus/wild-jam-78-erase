class_name MMCScore extends RefCounted
## Reprentation of worth that any given [MMCAction] is if commited to a [MMCGameState]
##
## You must provide a derived class that extends [MMCScore] and your own implementation of the
## [method reversed] and [method is_better_than] functions.

## Returns the exact opposite of the current score. For instance, if the current score reflects
## a chess board where black has just taken white's queen from black's persepective -- the reverse
## would that same chess board from white's perspective (eg, one queen down). Note that you do not
## necessarily need to have a score implemention know which player it currently has, only the
## abstract that from one viewpoint it is a queen up, and from the reversed viewpoint it is a queen
## down.
func reversed() -> MMCScore:
	assert(false, "The derived MMCScore class must implement reversed()")
	return null

## Compare the current score with another one, and return true if the current score is certainly
## better than the other one (eg: should return false if they are essentially equal, let alone worse).
func is_better_than(other : MMCScore) -> bool:
	assert(false, "The derived MMCScore class must implement is_better_than()")
	return false

static var _HIGHEST : MMCScore = MMCConstScore.create_highest()
static var _LOWEST : MMCScore = MMCConstScore.create_lowest()

static func _is_first_better_than_second(first : MMCScore, second : MMCScore) -> bool:
	if second == _HIGHEST:
		return false
	if first == _LOWEST:
		return false
	if first == _HIGHEST:
		return true
	if second == _LOWEST:
		return true
	return first.is_better_than(second)
	
static func _is_first_better_than_or_equal_to_second(first : MMCScore, second : MMCScore) -> bool:
	if first == _HIGHEST:
		return true
	if second == _LOWEST:
		return true
	if second == _HIGHEST:
		return false
	if first == _LOWEST:
		return false
	return !second.is_better_than(first)
