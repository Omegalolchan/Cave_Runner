extends CharacterBody2D

const WALK_SPEED = 40.0
var direction : float
var jump_input : bool
var is_jumping

@export var jump_max_time = 1.0
@export var jump_speed = -100.0

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")


func _process(delta): # Input gathering
	direction = Input.get_axis("moveLeft", "moveRight")
	jump_input = Input.is_action_pressed("jump")
	print(jump_input)
	return

func _physics_process(delta):
	# Add the gravity.
	if !is_on_floor() && !is_jumping:
		velocity.y += gravity * delta
	
	if(jump_input && is_on_floor()) :
		velocity.y = jump_speed
	
	velocity.x = direction * WALK_SPEED
	
	move_and_slide()
	
	return
