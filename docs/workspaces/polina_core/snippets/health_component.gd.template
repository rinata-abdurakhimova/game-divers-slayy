extends Node
class_name PolinaHealthComponent

signal health_changed(current: int, maximum: int)
signal hit_taken(amount: int, current: int, maximum: int)
signal healed(amount: int, current: int, maximum: int)
signal died
signal reset_completed

@export var maximum_health: int = 3
@export var start_full: bool = true
@export var invulnerability_seconds: float = 0.25

var current_health: int = 1
var is_alive: bool = true
var _invulnerability_left: float = 0.0
var _death_emitted: bool = false


func _ready() -> void:
	reset_health()


func _process(delta: float) -> void:
	if _invulnerability_left > 0.0:
		_invulnerability_left = maxf(0.0, _invulnerability_left - delta)


func take_damage(amount: int) -> bool:
	if amount <= 0:
		return false
	if not is_alive:
		return false
	if _invulnerability_left > 0.0:
		return false

	current_health = maxi(0, current_health - amount)
	_invulnerability_left = invulnerability_seconds
	health_changed.emit(current_health, maximum_health)
	hit_taken.emit(amount, current_health, maximum_health)

	if current_health <= 0:
		_die()

	return true


func heal(amount: int) -> bool:
	if amount <= 0:
		return false
	if not is_alive:
		return false
	if current_health >= maximum_health:
		return false

	var old_health: int = current_health
	current_health = mini(maximum_health, current_health + amount)
	var actual_amount: int = current_health - old_health
	health_changed.emit(current_health, maximum_health)
	healed.emit(actual_amount, current_health, maximum_health)
	return true


func reset_health(new_maximum: int = -1) -> void:
	if new_maximum > 0:
		maximum_health = new_maximum

	current_health = maximum_health if start_full else mini(current_health, maximum_health)
	current_health = maxi(1, current_health)
	is_alive = true
	_death_emitted = false
	_invulnerability_left = 0.0
	health_changed.emit(current_health, maximum_health)
	reset_completed.emit()


func set_invulnerable(seconds: float) -> void:
	_invulnerability_left = maxf(_invulnerability_left, seconds)


func is_invulnerable() -> bool:
	return _invulnerability_left > 0.0


func _die() -> void:
	is_alive = false
	if _death_emitted:
		return
	_death_emitted = true
	died.emit()
