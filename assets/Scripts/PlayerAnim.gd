extends AnimatedSprite2D

signal death_animation_finished()

var hold = [
	"", # EX : air, jump (all ground anim cancels)
	0,
]
var player : Player:
	set(_value): 
		player = get_parent()
	get:
		return get_parent()

var on : bool = true

var death_push: Vector2

enum anim_to_play {
	IDLE,
	WALK,
	JUMP,
	WALLJUMP,
	SLIDE_UP,
	SLIDE_STRAIGHT,
	SLIDE_DOWN,
	FALL,
}

func _ready() -> void:
	player = player

func _on_player_var_to_anim(ground:bool, speed:Vector2, jump:bool, wall_jump:bool, _walled:bool, slide:bool):
	if !is_zero_approx(sign(speed.x)) and animation != "WALLJUMP":
		scale.x = sign(speed.x)
	

	if ground:
		if speed == Vector2.ZERO:
			play_anim(anim_to_play.IDLE)
			return
		if speed != Vector2.ZERO and not slide:
			play_anim(anim_to_play.WALK)
			return
		if speed != Vector2.ZERO and slide:
			play_anim(calc_slide_angle(speed))
	else:
		if speed.y > 0 and hold[0] == "":
			if frame == 2 and animation == 'FALL':
				return
			play_anim(anim_to_play.FALL)
			return
		if speed.y <= 0 and jump and hold[0] == "" or hold[0] == "jump":
			play_anim(anim_to_play.JUMP)
			return
		if wall_jump and hold[0] == "" or hold[0] == "jump":
			play_anim(anim_to_play.WALLJUMP)
			hold[0] = "jump"
			hold[1] = 5
			if !is_zero_approx(sign(speed.x)) :
				scale.x = sign(-speed.x)
			return


	pass

func _process(_delta: float) -> void:
	if hold[1] >= frame:
		hold[1] = 0
		hold[0] = ""
	
	#if animation == 'DIE' and animation_finished:
		#get_node('../DeathParticle').emitting = true
	
	if animation == 'DIE':
		offset += death_push
		pass
	return

func calc_slide_angle(speed : Vector2) -> anim_to_play:
	if speed.y > 0:
		return anim_to_play.SLIDE_DOWN
	
	if speed.y < 0:
		return anim_to_play.SLIDE_UP

	return anim_to_play.SLIDE_STRAIGHT

func play_anim(anim : anim_to_play):
	if !on : return
	var anim_array = Array( anim_to_play.keys())
	play(anim_array[anim], 1.0, false)
	return

func update_death_push(_vector : Vector2, speed : float = 1):
	death_push = (player.velocity * -1).normalized() * speed
	return


func _on_player_died():
	if animation != 'DIE':
		on = false
		play('DIE')
		get_node('../DeathParticle').emitting = true
	pass # Replace with function body.


func _on_death_particle_finished():
	on = true
	death_push = Vector2.ZERO
	offset = Vector2(0,0)
	death_animation_finished.emit()
	pass # Replace with function body.




