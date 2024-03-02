extends CharacterBody2D

const WALK_SPEED = 40.0 / 60
const FPS_DELTA = 0.016
var direction : float

var jump_input : bool
var slide_input : bool

var is_jumping
var is_sliding
var on_floor
var current_jump_time : float
var current_coyote_time : float

@export var coyote_max_time = 4
@export var jump_max_time = 15
@export var jump_speed = -40.0
@export var gravity_scale : float = 10

var gravity = (8 * 0.016) * gravity_scale

func JumpInputPress():
	jump_input = true
	current_coyote_time = 0
	if on_floor:
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
		velocity.y = (jump_speed * FPS_DELTA)
	#endregion
	
	if !on_floor:
		velocity.y += gravity * delta
	elif !is_jumping:
		velocity.y = 0

	if on_floor && slide_input:
		is_sliding = true
		Slide()

	velocity.x = direction * WALK_SPEED
	var collision = move_and_collide(velocity, true)
	if collision:
		handle_collision(collision)
		pass
	
	on_floor = on_floorUpdate()
	
	print(velocity, on_floor ," | ", current_coyote_time)
	move_and_collide(velocity)
	return

func on_floorUpdate():
	var collision = move_and_collide(Vector2(0, 1), true)
	
	if collision && collision.get_normal().y < 0:
		current_coyote_time = coyote_max_time
		fix_velocity_angle(collision)
		return true
	else:
		current_coyote_time -= 1
	
	if current_coyote_time > 0:
		return true
	
	return false

func fix_velocity_angle(_collision : KinematicCollision2D):
	
	var _velocity = velocity
	_velocity.y *= -1
	_velocity = _velocity.rotated(_collision.get_angle())
	_velocity.y *= -1
	velocity = _velocity
	return

func handle_collision(_collision : KinematicCollision2D):
	
	return 

func Slide():
	# TO DO : Slide 
	return
