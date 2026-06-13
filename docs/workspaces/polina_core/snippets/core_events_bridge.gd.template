extends Node
class_name PolinaCoreEventsBridge

@export var game_events_path: NodePath = ^"/root/GameEvents"

var _game_events: Node = null


func _ready() -> void:
	_game_events = get_node_or_null(game_events_path)


func connect_player(player: Node) -> void:
	if player == null:
		return
	_connect_if_available(player, "action_requested", Callable(self, "_on_action_requested"))
	_connect_if_available(player, "reset_completed", Callable(self, "_on_reset_completed"))


func connect_health(health: Node) -> void:
	if health == null:
		return
	_connect_if_available(health, "health_changed", Callable(self, "_on_health_changed"))
	_connect_if_available(health, "hit_taken", Callable(self, "_on_hit_taken"))
	_connect_if_available(health, "died", Callable(self, "_on_died"))


func connect_rules(rules: Node) -> void:
	if rules == null:
		return
	_connect_if_available(rules, "score_changed", Callable(self, "_on_score_changed"))
	_connect_if_available(rules, "timer_changed", Callable(self, "_on_timer_changed"))
	_connect_if_available(rules, "level_completed", Callable(self, "_on_level_completed"))
	_connect_if_available(rules, "game_over", Callable(self, "_on_game_over"))


func _connect_if_available(source: Node, signal_name: StringName, target: Callable) -> void:
	if not source.has_signal(signal_name):
		return
	if source.is_connected(signal_name, target):
		return
	source.connect(signal_name, target)


func _emit_game_event(signal_name: StringName, args: Array = []) -> void:
	if _game_events == null:
		return
	if not _game_events.has_signal(signal_name):
		return

	var call_args: Array = [signal_name]
	call_args.append_array(args)
	_game_events.callv("emit_signal", call_args)


func _on_action_requested() -> void:
	pass


func _on_reset_completed() -> void:
	pass


func _on_health_changed(current: int, maximum: int) -> void:
	_emit_game_event(&"health_changed", [current, maximum])


func _on_hit_taken(amount: int, _current: int, _maximum: int) -> void:
	_emit_game_event(&"player_hit", [amount])


func _on_died() -> void:
	_emit_game_event(&"player_died")


func _on_score_changed(value: int) -> void:
	_emit_game_event(&"score_changed", [value])


func _on_timer_changed(seconds_left: float) -> void:
	_emit_game_event(&"timer_changed", [seconds_left])


func _on_level_completed() -> void:
	_emit_game_event(&"level_completed")


func _on_game_over(won: bool, reason: StringName) -> void:
	_emit_game_event(&"game_over", [won, reason])
