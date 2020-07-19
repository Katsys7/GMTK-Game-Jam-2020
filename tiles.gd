extends Node2D


func _ready():
	$Sprite/StaticBody2D/CollisionPolygon2D.polygon = $Path2D.curve.tessellate()
	pass # Replace with function body.

