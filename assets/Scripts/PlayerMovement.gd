extends CharacterBody2D

const WALK_SPEED = 40.0
var direction : float
var jump_input : bool
var is_jumping
var current_jump_time = 0.0

@export var jump_max_time = .1
@export var jump_speed = -100.0
@export var gravity_scale : float = 8 

var gravity = 8 * gravity_scale

func _process(delta): # Input gathering
	direction = Input.get_axis("moveLeft", "moveRight")
	if(Input.is_action_just_pressed("jump")): JumpInputPress()
	if(Input.is_action_just_released("jump")): JumpInputRelease()
	
	if (jump_input) :
		current_jump_time -= delta
	else: 
		current_jump_time = 0
	
	if(current_jump_time <= 0):
		is_jumping = false
	
	return

func JumpInputPress():
	jump_input = true
	if(is_on_floor()):
		current_jump_time = jump_max_time
		is_jumping = true
	return

func JumpInputRelease():
	jump_input = false
	return

func _physics_process(delta):
	# Add the gravity.
	if !is_on_floor():
		velocity.y += gravity * delta
	
	if(current_jump_time > 0) :
		velocity.y = jump_speed
	
	velocity.x = direction * WALK_SPEED
	
	move_and_slide()
	
	return
