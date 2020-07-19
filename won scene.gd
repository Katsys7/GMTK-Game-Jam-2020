extends Node

onready var timer_player = get_node("Timer")

func _ready():
	timer_player.set_wait_time(2)
	timer_player.start()
	
func _on_Timer_timeout():
	
	get_tree().change_scene("title screen.tscn")
