extends CharacterBody2D
class_name Player

signal var_to_anim(ground : bool, speed : Vector2, jump : bool, wall_jump : bool, walled : bool, slide : bool)
signal died()

# VARIABLES {{{

@onready var tilemap0 : TileMapLayer = get_node('../Tilemap/Layer0')

const WALK_SPEED = 50.0 / 60
var FPS_DELTA = 0.016
var direction : float
var base_velocity : Vector2
var added_velocity : Vector2
var ground_normal : Vector2

var jump_input : bool
var slide_input : bool

var jump_lock
var jump_turn
var is_walljumping : bool
var is_jumping
var is_sliding
var on_floor
var on_wall
var dead : bool

var current_jump_time : float
var current_coyote_time : float
var coyote_max_time = 10
var jump_max_time = 20
var jump_speed = -35.0
var slide_accel = 1
var slide_deccel = 1
var slide_burst_speed = 1.5
var velocity_neutral_deccel = 2
var gravity_scale : float = 10

var gravity = (9 * 0.016) * gravity_scale
#}}}

# INPUT {{{
func GetInput():
	var JumpInputPress = func():
		jump_input = true
		if on_floor:
			current_jump_time = jump_max_time
			is_jumping = true
		current_coyote_time = 0
		if on_wall and !on_floor:
			is_walljumping = true
		return
	
	var JumpInputRelease = func():
		jump_input = false
		return
	
	direction = Input.get_axis("moveLeft", "moveRight")
	if(Input.is_action_just_pressed("jump")): JumpInputPress.call()
	if(Input.is_action_just_released("jump")): JumpInputRelease.call()
	
	if Input.is_action_pressed("slide"):
		slide_input = true 
	else:
		slide_input = false
	return
# }}}

func die():
	died.emit()
	dead = true
	added_velocity = Vector2.ZERO
	base_velocity = Vector2.ZERO
	return	

func _init() -> void:
	Global.player = self

func _physics_process(delta):
	FPS_DELTA = delta
	GetInput()

	if dead: return

	### Checking Wall collisions
	on_wall = false
	var wall_raycast = raycast(position - Vector2(6,-8), position + Vector2(6,8), true, true, 1)
	if wall_raycast:
		if wall_raycast.normal == Vector2(0,0) or wall_raycast.normal == Vector2(-1,0) and !on_floor:
			on_wall = true
		
	#region Jump {{{
	if (jump_input) :
		current_jump_time -= 1
	else: 
		current_jump_time = 0
	
	if(current_jump_time <= 0):
		is_jumping = false

	if(is_jumping && !jump_lock) :
		base_velocity.y = (jump_speed * FPS_DELTA)
		if current_jump_time == jump_max_time - 1 && jump_turn:
			added_velocity.x = modulus(added_velocity.x) * direction
			jump_turn = false
			is_sliding = false
			
	if is_walljumping and !on_floor and on_wall and !is_jumping:
		base_velocity.y = 0
		if velocity.y > 0: added_velocity.y = 0
		if get_timer("wall_jump").get('exists') == false:
			create_timer("wall_jump", 20 * FPS_DELTA)
			added_velocity.y -= 30 * FPS_DELTA
			added_velocity.x = sign(-wall_raycast.position.x + position.x) * FPS_DELTA * -jump_speed * 2
		
		
	#endregion }}}
	
	base_velocity.x = direction * WALK_SPEED
	
	#if is_walljumping and direction != sign(added_velocity.x) and direction != 0 and get_timer("wall_jump").get('exists'):
		#base_velocity.x *= get_timer("wall_jump").get('percentage_passed') / 100
	
	if !on_floor:
		base_velocity.y += gravity * FPS_DELTA
		if added_velocity.x != 0:
			base_velocity.x *= 0.5

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
	
	move_and_collide(velocity)
	var_to_anim.emit(on_floor , velocity, is_jumping, is_walljumping, on_wall, is_sliding)
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
	
	return false

func fix_velocity_angle(_collision : KinematicCollision2D):
	if velocity.y > 0:
		base_velocity.y = 0
		added_velocity.y = 0
	var _velocity = velocity
	_velocity.y *= -1
	if _collision.get_normal().x > 0:
		_velocity = _velocity.rotated(-_collision.get_angle())
	else:
		_velocity = _velocity.rotated(_collision.get_angle())
	_velocity.y *= -1
	velocity = _velocity
	return

func handle_collision(_collision : KinematicCollision2D):
	#region handling walls {{{
	var same_velocity_aganist_wall = func(v_to_check : float):
		if sign(_collision.get_position().x - position.x) != sign(v_to_check) && v_to_check == 0:
			return false
		return true
		
	if (round(_collision.get_angle(up_direction) * 10) / 10) == 1.6 && same_velocity_aganist_wall.call(velocity.x):
		velocity.x = 0
		added_velocity.x = 0
	#endregion }}}
	if _collision.get_normal().y < 0:
		jump_turn = true
		create_timer("jump_turn", 60 )
	elif _collision.get_normal().y == 1 and velocity.y < 0: ## Handling player hitting head on roof
		added_velocity.y *= 0.5
		#velocity.y = 0
	elif _collision.get_normal().y > 0:
		velocity = velocity.slide(_collision.get_normal())
	


	return 

# velocity neutral (decel cenarios) {{{
func velocity_neutral():
	if direction != sign(added_velocity.x) && direction != 0 && added_velocity.x != 0 && on_floor: #letting the player have more control on his speed#
		added_velocity.x += -sign(added_velocity.x) * velocity_neutral_deccel * 2 * FPS_DELTA
	
	if on_floor && !is_sliding && direction != sign(added_velocity.x):
		added_velocity.x += -sign(added_velocity.x) * velocity_neutral_deccel * FPS_DELTA
	elif on_floor && !is_sliding:
		added_velocity.x += -sign(added_velocity.x) * velocity_neutral_deccel / 2 * FPS_DELTA
	
	if !on_floor:
		added_velocity.x += -sign(added_velocity.x) * velocity_neutral_deccel / 4 * FPS_DELTA
	
	if !on_floor and direction != sign(added_velocity.x) && direction != 0:
		added_velocity.x += -sign(added_velocity.x) * velocity_neutral_deccel / 2 * FPS_DELTA
	
	if modulus(added_velocity.x) < 0.1:
		added_velocity.x = 0
	
	return
# }}}

func Slide():
	if !on_floor: return
	
	if ground_normal != up_direction:
		if added_velocity.x == 0 && velocity.x == 0: # small push if player is standing still
			added_velocity.x += sign(ground_normal.x) * 0.5
		
		if added_velocity.x == 0 && direction != 0 && velocity.x != 0: # initial boost
			if direction != sign(ground_normal.x):
				added_velocity.x += sign(velocity.x) * 0.5
			if direction == sign(ground_normal.x):
				added_velocity.x += sign(ground_normal.x) * slide_burst_speed
		
		added_velocity.x += (slide_accel * sign(ground_normal.x)) * FPS_DELTA
		if is_jumping and current_jump_time == jump_max_time - 1 and velocity.y < 0:
			added_velocity.y -= modulus(velocity.x) / 1.5
			added_velocity.x *= 0.25
	else:
		if added_velocity.x == 0 :
			added_velocity.x += sign(velocity.x) * slide_burst_speed / 1.5
			jump_lock = true
			create_timer("slide_jump_lock", FPS_DELTA * 2)

	added_velocity.x += -sign(added_velocity.x) * slide_deccel * FPS_DELTA
	base_velocity.x = 0

	return

# timer, raycast and other calc functions {{{
func modulus(n : float):
	return sqrt(pow(n, 2))

func create_timer(_name : String, time : float):
	var t = Timer.new()
	t.process_callback = Timer.TIMER_PROCESS_PHYSICS
	t.name = _name
	t.one_shot = true
	t.autostart = true
	t.wait_time = time
	if get_node_or_null("../Player/"+_name):
		t = get_node("../Player/"+_name)
		t.wait_time += time
		return
	else:
		add_child(t)
	var time_end = Callable(on_timer_end) 
	t.timeout.connect(time_end.bind(_name))
	t.start(time)
	return

func on_timer_end(_name : String):
	get_node("../Player/"+_name).queue_free()
	match _name:
		"slide_jump_lock":
			jump_lock = false
			jump_turn = true
			create_timer("jump_turn", 60)
		"jump_turn":
			jump_turn = false
		"wall_jump":
			is_walljumping = false
	return

func stop_timer(_name : String):
	var timer : Timer
	if get_node_or_null("../Player/"+_name) ==  null:
		return
	timer = get_node("../Player/"+_name)
	timer.stop()
	timer.queue_free()
	return

func get_timer(_name : String): # Returns the time left/passed of given Timer
	var value = {
		"time_left": 0,
		"time_passed": 0,
		"percentage_passed": 0,
		"exists": false
	}
	if get_node_or_null("../Player/"+_name) == null:
		return value
	var timer : Timer
	timer = get_node("../Player/"+_name) as Timer
	value.time_left = timer.time_left
	value.time_passed = timer.wait_time - timer.time_left
	value.percentage_passed = (value.time_passed / timer.wait_time) * 100
	value.exists = true
	return value

func raycast(start_vector : Vector2, end_vector : Vector2, inside_hit : bool, exclude_self : bool, layer : int) -> Dictionary:
	var space_state = get_world_2d().direct_space_state # getting physics space
	var query = PhysicsRayQueryParameters2D.create(start_vector, end_vector)
	if exclude_self: query.exclude = [self]
	query.hit_from_inside = inside_hit 
	query.collision_mask = layer
	var result = space_state.intersect_ray(query)
	return result
# }}}
