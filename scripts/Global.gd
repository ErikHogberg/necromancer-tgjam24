extends Node


var current_scene = null

var friendlies: Array[Node3D] = []
var hostiles: Array[Node3D] = []

func _ready():
	var root = get_tree().root
	current_scene = root.get_child(root.get_child_count() - 1)

func get_closest_hostile(pos: Vector3) -> Node3D:
	var closest: Node3D = null
	var closestDistanceSqr: float = 99999
	for enemy in hostiles:
		var distance = enemy.global_position.distance_squared_to(pos)
		if distance < closestDistanceSqr:
			closest = enemy
			closestDistanceSqr = distance
	return closest

func get_closest_friendly(pos: Vector3) -> Node3D:
	var closest: Node3D = null
	var closestDistanceSqr: float = 99999
	for friendly in friendlies:
		var distance = friendly.global_position.distance_squared_to(pos)
		if distance < closestDistanceSqr:
			closest = friendly
			closestDistanceSqr = distance
	return closest
