extends KinematicBody2D


const ACCELARATION = 500
const TARGET_FPS = 60
const MAX_SPEED = 480
const FRICTION = 10
const AIR_RESISTANCE = 1
const GRAVITY = 4
var JUMP_FORCE = 140
const MAX_HEALTH = 4
#stats 
export var score : int = 0
export var humanity : int = 50
var health
#physics
export var max_speed : int = 480
export var jumpForce : int = 600
export var gravity : int = 500
export var acceleration : float = 512
var vel = Vector2.ZERO
var grounded : bool = false
var dead= false
#components 
onready var animation_tree = get_node("AnimationTree")
onready var state_machine = animation_tree.get("parameters/playback")
onready var sprite = $Sprite
onready var timer = get_node("../Timer")
onready var timer2_player = get_node("../Timer2")
onready var rng = RandomNumberGenerator.new()
func _ready():
	health = 4
	rng.randomize()
	var my_random_number = rng.randf_range(1, 5)
	timer.set_wait_time(my_random_number)
	timer.start()
	add_to_group("Player")

func _on_Timer_timeout():
	JUMP_FORCE = rng.randf_range(150,400)
	print(JUMP_FORCE)

func _physics_process(delta):
	if health == 0:
		die()
		
	var x_input = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	
	if x_input != 0:
#		animated_sprite.play("Run")
		vel.x += x_input * delta * ACCELARATION 
		vel.x = clamp(vel.x, -max_speed, max_speed)
		sprite.scale = Vector2(1,1) if x_input > 0 else Vector2(-1,1)
		state_machine.travel('Run')
	else:
		state_machine.travel('Idle')
	vel.y += gravity * delta
	
	if is_on_floor():
		if x_input == 0:
			vel.x = lerp(vel.x, 0, FRICTION * delta)
		
		if Input.is_action_just_pressed("ui_up"):
			vel.y = -JUMP_FORCE
			state_machine.travel("Jump")
								
	else:
#		animated_sprite.play("Jump")
				
		if x_input == 0:
			vel.x = lerp(vel.x, 0, AIR_RESISTANCE * delta)
	if Input.is_action_just_pressed("attack_1"):
		attack('attack_1')
		return
	if Input.is_action_just_pressed("attack_2"):
		attack('attack_2')
		return
	vel = move_and_slide(vel, Vector2.UP)
	


func attack(attack = 'attack_1'):
	if attack == 'attack_1':
		state_machine.travel('Attack_Normal')
	if attack == 'attack_2':
		state_machine.travel('Attack_Heavy')
	
	
func hurt():
	health -= 1
	print("hurt")
	
func die():
	dead = true
#	print("HERE"
	state_machine.travel("Dead")
	set_physics_process(false)
	print(timer2_player)
	timer2_player.start()


func _on_Area2D_body_entered(body):
	if body.is_in_group("Enemy"):
		body.hit(1)

		
func _on_Timer2_timeout():
	print('here')
	get_tree().change_scene("game over.tscn")
