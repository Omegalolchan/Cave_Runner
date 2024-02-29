extends CharacterBody2D

const WALK_SPEED = 40.0
var direction : float

var jump_input : bool
var slide_input : bool

var is_jumping
var is_sliding
var current_jump_time = 0.0

@export var jump_max_time = 15
@export var jump_speed = -30.0
@export var gravity_scale : float = 10

var gravity = 8 * gravity_scale

func JumpInputPress():
	jump_input = true
	if on_floor():
		current_jump_time = jump_max_time
		is_jumping = true
	return

func JumpInputRelease():
	jump_input = false
	return

func GetInput():
	direction = Input.get_axis("moveLeft", "moveRight")
	if(Input.is_action_just_pressed("jump")): JumpInputPress()
	if(Input.is_action_just_released("jump")): JumpInputRelease()
	
	if Input.is_action_pressed("slide"):
		slide_input = true 
	else:
		slide_input = false
	
	return

func _physics_process(delta):
	GetInput()
	#region Jump
	if (jump_input) :
		current_jump_time -= 1
	else: 
		current_jump_time = 0
	
	if(current_jump_time <= 0):
		is_jumping = false

	if(is_jumping) :
		velocity.y = jump_speed
	#endregion
	
	if !on_floor():
		velocity.y += gravity * delta
	elif current_jump_time <= 0:
		velocity.y = 0

	if on_floor() && slide_input:
		is_sliding = true
		Slide()

	velocity.x = direction * WALK_SPEED
	print(velocity, on_floor())
	var collision = move_and_collide(velocity * delta, true)
	if collision:
		#HANDLE COLISION#
		pass
	move_and_collide(velocity * delta)
	return

func on_floor():
	var collision = move_and_collide(Vector2(0, 1), true)
	if collision && collision.get_normal().y < 0:
		return true
	return false

func get_collision_type(_collision : KinematicCollision2D):
	
	return 

func Slide():
	# TO DO : Slide 
	return
