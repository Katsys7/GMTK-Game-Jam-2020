extends KinematicBody2D

#constants
const GRAVITY = 80
const FLOOR_DETECT_DISTANCE : float = 20.0
#movement variables
export var movement_speed : float = 450.0
export var jump_force : float = -50.0

#health 

export var initial_health : int = 1
export var melee_damage : int = 1

#attacks and recovery 

export var launch_power : float = 1500
export var recovery_time : float = 2.0
export var follow_range : float = 1500.0
export var change_direction_ease : float = 1
export var direction_smooth : float = 1

onready var animation_player : AnimationPlayer = $AnimationPlayer
#	onready var audio_stream_helper :  = $AnimationPlayer
onready var flip_helper : Node2D = $FlipHelper

onready var detect_wall_right : RayCast2D = $DetectWallRight
onready var detect_wall_left : RayCast2D = $DetectWallLeft
onready var detect_floor_right : RayCast2D = $DetectFloorRight
onready var detect_floor_left : RayCast2D = $DetectFloorLeft

onready var platform_detector : RayCast2D = $PlatformDetector
onready var player = Utils.get_main_node()
onready var timer_enemy = get_node("Timer")



#state 
var velocity : Vector2 = Vector2()
var launch : float = 1
var is_recovering : bool = false
var recovery_counter : float = 0
var is_following_player : bool = false
var direction : int = 1
var player_in_attack_range : bool = false
var player_distance : float
var current_health : int


func _ready():
	add_to_group("Enemy")
#	print("PLAYER IS ", player)

func _physics_process(delta : float ) -> void:
	if not is_recovering:
		player_distance = player.get_position().x - get_position().x
		direction_smooth += (direction - direction_smooth) * delta * change_direction_ease
		velocity.x = direction_smooth
		
		# flip the flip helper 
		
		if velocity.x > 0.01:
			if flip_helper.get_scale().x == -1:
				flip_helper.set_scale(Vector2(1,1))
		if velocity.x < -0.01:
			if flip_helper.get_scale().x == 1:
				flip_helper.set_scale(Vector2(-1,1))
		
		# check if player is in range 
		
		if abs(player_distance) < follow_range:
			is_following_player = true
		else:
			is_following_player = false
			
		if is_following_player:
			if player_distance < 0:
				direction = -1
			else:
				direction = 1 
				
		if detect_wall_right.is_colliding():
			var collision_object : Object = detect_wall_right.get_collider()
			if not collision_object.is_in_group("Player"):
				if not is_following_player:
					direction = -1
				else:
					jump()
					
		if detect_wall_left.is_colliding():
			var collision_object : Object = detect_wall_left.get_collider()
			if not collision_object.is_in_group("Player"):
				if not is_following_player:
					direction = -1
				else:
					jump()
							
		if not is_following_player:
			if not detect_floor_right.is_colliding():
				direction = -1
			if not detect_floor_left.is_colliding():
				direction = 1	
		
		if player_in_attack_range:
			animation_player.play("Attack")
	else:
		recovery_counter += delta
		velocity.x = launch
		launch += (0 - launch) * delta
		
		if recovery_counter >= recovery_time:
			recovery_counter = 0
			velocity.x = 0
			is_recovering = false
	
	velocity.y += GRAVITY * delta
	
	var snap_vector : Vector2 = Vector2.DOWN * FLOOR_DETECT_DISTANCE if velocity.y == 0.0 else Vector2.ZERO
	var is_on_platform : bool = platform_detector.is_colliding()
	
	velocity = move_and_slide_with_snap(
		velocity, snap_vector, Vector2.UP, not is_on_platform, 4, 0.9, false
	)
	
func jump():
	if is_on_floor():
		velocity.y = jump_force

func hit(attack_direction : int ) -> void:	
	velocity.y -= launch_power
	launch = launch_power * attack_direction
	recovery_counter = 0
	is_recovering = true
	
	if current_health <= 0:
		die()
	
func die() -> void:
	queue_free()

	

# animation functions #

func _attack(body) -> void:
	print("HELLO")
	if body.is_in_group("Player"):
		if body.dead == false:
			body.die()

		
	

# signal functions #

func _on_AttackArea_body_entered(body):
	if body.is_in_group("Player"):
		player_in_attack_range = true

func _on_AttackArea_body_exited(body):
	if body.is_in_group("Player"):
		player_in_attack_range = false



