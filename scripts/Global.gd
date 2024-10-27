extends Node


var current_scene = null

var friendlies: Array[Node3D] = []
var hostiles: Array[Node3D] = []

func _ready():
	var root = get_tree().root
	current_scene = root.get_child(root.get_child_count() - 1)
