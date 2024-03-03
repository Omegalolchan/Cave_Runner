extends CharacterBody2D

const WALK_SPEED = 40.0 / 60
const FPS_DELTA = 0.016
var direction : float
var base_velocity : Vector2
var added_velocity : Vector2
var ground_normal : Vector2

var jump_input : bool
var slide_input : bool

var is_jumping
var is_sliding
var on_floor
var current_jump_time : float
var current_coyote_time : float

@export var coyote_max_time = 4
@export var jump_max_time = 20
@export var jump_speed = -35.0
@export var slide_accel = 1
@export var slide_deccel = 3
@export var slide_burst_speed = 1.5
@export var velocity_neutral_deccel = 4
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
		base_velocity.y = (jump_speed * FPS_DELTA)
	#endregion
	
	base_velocity.x = direction * WALK_SPEED
	
	if !on_floor:
		base_velocity.y += gravity * FPS_DELTA

	if on_floor && slide_input:
		is_sliding = true
		Slide()
	else: is_sliding = false

	velocity_neutral()
	velocity = base_velocity + added_velocity
	var collision = move_and_collide(velocity, true)
	if collision:
		handle_collision(collision)
		pass
	
	on_floor = on_floorUpdate()
	
	print(base_velocity, " || ", added_velocity)
	move_and_collide(velocity)
	return

func on_floorUpdate():
	var collision = move_and_collide(Vector2(0, 1), true)
	
	if collision && collision.get_normal().y < 0:
		current_coyote_time = coyote_max_time
		fix_velocity_angle(collision)
		ground_normal = collision.get_normal()
		return true
	else:
		current_coyote_time -= 1
	
	if current_coyote_time > 0:
		return true
	
	return false

func fix_velocity_angle(_collision : KinematicCollision2D):
	if velocity.y > 0:
		base_velocity.y = 0
	var _velocity = velocity
	_velocity.y *= -1
	_velocity = _velocity.rotated(_collision.get_angle())
	_velocity.y *= -1
	velocity = _velocity
	return

func handle_collision(_collision : KinematicCollision2D):
	#region REMOVING WALL FRICTION
	if (round(_collision.get_angle(up_direction) * 10) / 10) == 1.6:
		velocity.x = 0
		added_velocity.x = 0
	#endregion
	
	return 

func velocity_neutral():
	if on_floor && !is_sliding:
		added_velocity.x += -sign(added_velocity.x) * velocity_neutral_deccel * FPS_DELTA
	
	if sqrt(pow(added_velocity.x, 2)) < 0.1:
			added_velocity.x = 0
	return

func Slide():
	if !on_floor: return
	if ground_normal != up_direction:
		if added_velocity.x == 0 && base_velocity.x == 0:
			added_velocity.x += sign(ground_normal.x) * 0.5
		
		if added_velocity.x == 0 && direction != 0 && velocity.x != 0:
			if direction != sign(ground_normal.x):
				added_velocity.x += sign(velocity.x) * 0.5
			if direction == sign(ground_normal.x):
				added_velocity.x += sign(ground_normal.x) * slide_burst_speed
		
		var velocity_magnitude = sqrt(pow(velocity.x,2) +pow(-velocity.y, 2))
		added_velocity.x += (slide_accel * FPS_DELTA) * clamp(int(ground_normal.x * 2), -1,1)
	else:
		if added_velocity.x == 0 :
			added_velocity.x += sign(velocity.x) * slide_burst_speed / 1.5
		added_velocity.x += -sign(added_velocity.x) * slide_deccel * FPS_DELTA
	
	base_velocity.x = 0
	return
