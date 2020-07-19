extends Node2D



func _ready():
	add_to_group("Level")
	var floor_of_death = self.get_node("Floor_Of_Death/CollisionShape2D")
	floor_of_death.add_to_group("Floor_Of_Death")
	
	
	

func _on_Floor_Of_Death_body_entered(body):
	print(body)
	if body.is_in_group("Player"):
		body.die()


func _on_Area2D_body_entered(body):
	if body.is_in_group("Player"):
		get_tree().change_scene("won scene.tscn")



