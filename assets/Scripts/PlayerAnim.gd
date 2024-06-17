extends AnimatedSprite2D

enum anim_to_play {
	IDLE,
	WALK,
	JUMP,
	WALLJUMP,
	SLIDE_UP,
	SLIDE_STRAIGHT,
	SLIDE_DOWN,
}

func _on_player_var_to_anim(ground:bool, speed:Vector2, jump:bool, wall_jump:bool, walled:bool, slide:bool):
	if speed.x != 0:
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


	pass

func calc_slide_angle(speed : Vector2) -> anim_to_play:
	if speed.y > 0:
		return anim_to_play.SLIDE_DOWN
	
	if speed.y < 0:
		return anim_to_play.SLIDE_UP

	return anim_to_play.SLIDE_STRAIGHT

func play_anim(anim : anim_to_play):
	var anim_array = Array( anim_to_play.keys())
	play(anim_array[anim], 1.0, false)
	return