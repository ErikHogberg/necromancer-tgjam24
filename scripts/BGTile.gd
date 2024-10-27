extends StaticBody3D
class_name BGTile

@export var label: Label3D

func SetIndex(index: int):
	label.text = str(index)
