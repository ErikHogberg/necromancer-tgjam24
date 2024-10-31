extends MeshInstance3D

@export var zombie_prefab: PackedScene

func summon():
	var zombie = zombie_prefab.instantiate() as Node3D
	get_tree().root.add_child(zombie)
	zombie.global_position = global_position
