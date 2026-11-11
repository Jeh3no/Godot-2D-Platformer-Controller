extends CanvasLayer

class_name HUD

@export var play_char_ref: CharacterBody2D
@onready var current_state_label_text: Label = %CurrentStateLabelText
@onready var previous_state_label_text: Label = %PreviousStateLabelText
@onready var velocity_label_text: Label = %VelocityLabelText
@onready var velocity_vector_label_text: Label = %VelocityVectorLabelText
@onready var is_on_floor_label_text: Label = %IsOnFloorLabelText
@onready var nb_jumps_allowed_label_text: Label = %NbJumpsAllowedLabelText
@onready var jump_cooldown_label_text: Label = %JumpCooldownLabelText
@onready var coyote_jump_enabled_label_text: Label = %CoyoteJumpEnabledLabelText
@onready var jump_buffer_enabled_label_text: Label = %JumpBufferEnabledLabelText
@onready var edge_push_label_text: Label = %EdgePushLabelText
@onready var floor_max_length_text: Label = %FloorMaxLengthText


func _physics_process(_delta: float) -> void:
	current_state_label_text.text = str(play_char_ref.state_machine.curr_state_name)
	previous_state_label_text.text = str(play_char_ref.state_machine.previous_state_name)
	velocity_label_text.text = str("%.3f" % play_char_ref.velocity.length())
	velocity_vector_label_text.text = str(
		"[ ",
		"%.3f" % play_char_ref.velocity.x,
		",  ",
		"%.3f" % play_char_ref.velocity.y,
		" ]",
	)
	is_on_floor_label_text.text = str(play_char_ref.is_on_floor())
	nb_jumps_allowed_label_text.text = str(play_char_ref.nb_jumps_allowed)
	jump_cooldown_label_text.text = str("%.3f" % play_char_ref.jump_cooldown)
	coyote_jump_enabled_label_text.text = str(play_char_ref.coyote_jump_enabled)
	jump_buffer_enabled_label_text.text = str(play_char_ref.jump_buffering_enabled)

	if play_char_ref.edge_push_side == -1:
		edge_push_label_text.text = str("Left side")
	elif play_char_ref.edge_push_side == 1:
		edge_push_label_text.text = str("Right side")
	else:
		edge_push_label_text.text = str("None")

	floor_max_length_text.text = str("%.3f" % play_char_ref.floor_snap_length)
