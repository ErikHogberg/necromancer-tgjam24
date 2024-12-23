extends Node


var current_scene = null

var player1: Node3D
var player2: Node3D
var friendlies: Array[Node3D] = []
var hostiles: Array[Node3D] = []

var hp = 100.0
var timer = 0.0

func get_score()->float:
	return friendlies.size() -1

func _ready():
	var root = get_tree().root
	current_scene = root.get_child(root.get_child_count() - 1)

func get_closest_hostile(pos: Vector3, exclude: Node3D =null) -> Node3D:
	var closest: Node3D = null
	var closestDistanceSqr: float = 99999
	for enemy in hostiles:
		if exclude and enemy.get_instance_id() == exclude.get_instance_id():
			continue
		var distance = enemy.global_position.distance_squared_to(pos)
		if distance < closestDistanceSqr:
			closest = enemy
			closestDistanceSqr = distance
	return closest

func get_closest_friendly(pos: Vector3, exclude: Node3D = null) -> Node3D:
	var closest: Node3D = null
	var closestDistanceSqr: float = 99999
	for friendly in friendlies:
		if exclude and friendly.get_instance_id() == exclude.get_instance_id():
			continue
		var distance = friendly.global_position.distance_squared_to(pos)
		if distance < closestDistanceSqr:
			closest = friendly
			closestDistanceSqr = distance
	return closest

func add_friendly(friend: Node3D):
	friendlies.push_back(friend)

func add_hostile(hostile: Node3D):
	hostiles.push_back(hostile)

func remove_friendly(friend: Node3D):
	for i in friendlies.size():
		if friendlies[i] == friend:
			friendlies.remove_at(i)
			return

func remove_hostile(hostile: Node3D):
	for i in hostiles.size():
		if hostiles[i] == hostile:
			hostiles.remove_at(i)
			return

func take_dmg():
	hp -= 30
	# todo: die if oom
