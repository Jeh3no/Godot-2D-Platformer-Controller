extends State

class_name JumpState

var state_name: String = "JumpState"

@export var play_char_ref: CharacterBody2D


func enter() -> void:
	play_char_ref.animation_player.stop()

	play_char_ref.move_speed = play_char_ref.inair_speed
	play_char_ref.move_accel = play_char_ref.inair_accel
	play_char_ref.move_deccel = play_char_ref.inair_deccel

	play_char_ref.animate(3, false)

	jump()


func physics_update(delta: float) -> void:
	input()

	move(delta)

	if !play_char_ref.is_on_floor():
		if play_char_ref.velocity.y >= 0.0:
			transitioned.emit(self, "FallState")

		gravity_apply(delta)
		corner_correction(delta)


func input() -> void:
	if Input.is_action_just_pressed(play_char_ref.jump_action):
		if play_char_ref.nb_jumps_allowed > 0 and play_char_ref.jump_cooldown <= 0.0:
			jump()

	if Input.is_action_just_released(play_char_ref.jump_action):
		play_char_ref.velocity.y *= play_char_ref.jump_cut_multiplier


func gravity_apply(delta: float) -> void:
	play_char_ref.velocity.y += play_char_ref.jump_gravity * delta


func corner_correction(delta: float) -> void:
	#the code below is a Godot 4 adapted version of the code explained in this video :
	#https://www.youtube.com/watch?v=tW-Nxbxg5qs, made by VolTer
	#this solution even works with perfectly square tilemaps.
	var motion = play_char_ref.velocity * delta

	if play_char_ref.test_move(play_char_ref.global_transform, motion):
		for j in [-1, 1]:
			for i in range(1, 8 + 1):
				var offset = Vector2(i * j, 0)

				if not play_char_ref.test_move(
					play_char_ref.global_transform.translated(offset),
					motion,
				):
					play_char_ref.global_position.x += i * j
					play_char_ref.edge_push_side = signi(i * j)
					play_char_ref.start_edge_push_side_change_val_timer()
					return


func move(delta: float) -> void:
	var move_dir: float = Input.get_axis(
		play_char_ref.move_left_action,
		play_char_ref.move_right_action,
	)

	if move_dir:
		play_char_ref.velocity.x = lerp(
			play_char_ref.velocity.x,
			move_dir * play_char_ref.move_speed,
			play_char_ref.move_accel * delta,
		)


func jump() -> void:
	if play_char_ref.is_on_floor():
		play_char_ref.floor_snap_length = 0.0
	play_char_ref.nb_jumps_allowed -= 1
	play_char_ref.jump_cooldown = play_char_ref.jump_cooldown_ref
	play_char_ref.velocity.y = play_char_ref.jump_velocity
