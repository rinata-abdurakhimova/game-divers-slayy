class_name ScoreService
extends RefCounted


static func start_score_cents() -> int:
	return GameRules.BOSS_67_START_SCORE_CENTS


static func target_score_cents() -> int:
	return GameRules.BOSS_67_TARGET_SCORE_CENTS


static func failure_score_cents() -> int:
	return GameRules.BOSS_67_FAILURE_SCORE_CENTS


static func apply_score_operation(
	current_score_cents: int,
	operation: StringName,
	value_cents: int
) -> int:
	match operation:
		GameRules.SCORE_OPERATION_ADD:
			return current_score_cents + value_cents
		GameRules.SCORE_OPERATION_SUBTRACT:
			return current_score_cents - value_cents
		GameRules.SCORE_OPERATION_MULTIPLY:
			return _multiply_and_round_to_cents(current_score_cents, value_cents)
		_:
			push_warning("Unknown score operation: %s" % operation)
			return current_score_cents


static func is_victory_score(score_cents: int) -> bool:
	return score_cents == GameRules.BOSS_67_TARGET_SCORE_CENTS


static func is_failure_score(score_cents: int) -> bool:
	return score_cents == GameRules.BOSS_67_FAILURE_SCORE_CENTS


static func is_terminal_score(score_cents: int) -> bool:
	return is_victory_score(score_cents) or is_failure_score(score_cents)


static func can_continue(score_cents: int) -> bool:
	return not is_terminal_score(score_cents)


static func value_to_cents(value: int) -> int:
	return value * 100


static func multiplier_to_cents(multiplier: float) -> int:
	return int(round(multiplier * 100.0))


static func format_score(score_cents: int) -> String:
	var sign_prefix: String = "-" if score_cents < 0 else ""
	var absolute_score: int = absi(score_cents)
	var whole: int = int(floor(float(absolute_score) / 100.0))
	var cents: int = absolute_score % 100
	if cents == 0:
		return "%s%d" % [sign_prefix, whole]
	if cents % 10 == 0:
		return "%s%d.%d" % [sign_prefix, whole, int(cents / 10)]
	return "%s%d.%02d" % [sign_prefix, whole, cents]


static func operation_label(operation: StringName, value_cents: int) -> String:
	match operation:
		GameRules.SCORE_OPERATION_ADD:
			return "+%s" % format_score(value_cents)
		GameRules.SCORE_OPERATION_SUBTRACT:
			return "-%s" % format_score(value_cents)
		GameRules.SCORE_OPERATION_MULTIPLY:
			return "*%s" % format_score(value_cents)
		_:
			return "?%s" % format_score(value_cents)


static func make_snapshot(score_cents: int) -> Dictionary:
	return {
		"score_cents": score_cents,
		"display": format_score(score_cents),
		"target_cents": GameRules.BOSS_67_TARGET_SCORE_CENTS,
		"target_display": format_score(GameRules.BOSS_67_TARGET_SCORE_CENTS),
		"is_victory": is_victory_score(score_cents),
		"is_failure": is_failure_score(score_cents),
		"can_continue": can_continue(score_cents),
	}


static func _multiply_and_round_to_cents(score_cents: int, multiplier_cents: int) -> int:
	var product: int = score_cents * multiplier_cents
	var sign_value: int = -1 if product < 0 else 1
	var absolute_product: int = absi(product)
	return sign_value * int(floor(float(absolute_product + 50) / 100.0))
