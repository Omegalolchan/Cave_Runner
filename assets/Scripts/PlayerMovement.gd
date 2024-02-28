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
	if(is_on_floor()):
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

	if(current_jump_time > 0) :
		velocity.y = jump_speed
	#endregion
	
	if !is_on_floor():
		velocity.y += gravity * delta

	if is_on_floor() && slide_input:
		is_sliding = true
		Slide()

	velocity.x = direction * WALK_SPEED

	move_and_slide()
	var collision = get_last_slide_collision()
	return

func Slide():
	# TO DO : Slide 
	return
