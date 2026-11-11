extends State

class_name FallState

var state_name: String = "FallState"

@export var play_char_ref: CharacterBody2D


func enter() -> void:
	play_char_ref.animation_player.stop()

	play_char_ref.move_speed = play_char_ref.inair_speed
	play_char_ref.move_accel = play_char_ref.inair_accel
	play_char_ref.move_deccel = play_char_ref.inair_deccel

	if play_char_ref.is_on_floor():
		transitioned.emit(self, "IdleState")
	else:
		#set coyote time timer
		if play_char_ref.state_machine.previous_state_name != "JumpState":
			if play_char_ref.coyote_time_timer == null:
				play_char_ref.coyote_time_timer = Timer.new()
				play_char_ref.coyote_time_timer.wait_time = play_char_ref.coyote_time_val
				play_char_ref.coyote_time_timer.one_shot = true
				play_char_ref.coyote_time_timer.timeout.connect(
					Callable(play_char_ref, "reset_coyote_time_timer").bind(false)
				)
				add_child(play_char_ref.coyote_time_timer)
				play_char_ref.coyote_jump_enabled = true
				play_char_ref.coyote_time_timer.start()

		play_char_ref.animate(4, true)


func physics_update(delta: float) -> void:
	input()

	move(delta)

	if !play_char_ref.is_on_floor():
		gravity_apply(delta)
	else:
		transitioned.emit(self, "IdleState")


func input() -> void:
	if (
		Input.is_action_just_pressed(play_char_ref.jump_action)
		and play_char_ref.state_machine.curr_state_name == "FallState"
	):
		if (
			play_char_ref.nb_jumps_allowed > 0 and play_char_ref.jump_cooldown <= 0.0
			and !play_char_ref.coyote_jump_enabled
		):
			transitioned.emit(self, "JumpState")
		elif play_char_ref.nb_jumps_allowed > 0 and play_char_ref.coyote_jump_enabled:
			play_char_ref.reset_coyote_time_timer(true)
			transitioned.emit(self, "JumpState")
		#set jump buffer timer
		elif !play_char_ref.jump_buffering_enabled:
			if play_char_ref.jump_buffer_timer == null:
				play_char_ref.jump_buffer_timer = Timer.new()
				play_char_ref.jump_buffer_timer.wait_time = play_char_ref.jump_buffer_time
				play_char_ref.jump_buffer_timer.one_shot = true
				play_char_ref.jump_buffer_timer.timeout.connect(
					Callable(play_char_ref, "reset_jump_buffer_timer")
				)
				add_child(play_char_ref.jump_buffer_timer)
				play_char_ref.jump_buffering_enabled = true
				play_char_ref.jump_buffer_timer.start()


func gravity_apply(delta: float) -> void:
	play_char_ref.velocity.y += play_char_ref.fall_gravity * delta


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
