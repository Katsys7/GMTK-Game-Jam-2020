extends Node


func get_main_node() -> Node:
	var root_node : Node = get_tree().get_root().get_node("World/Player/Player_Body")
	return root_node
