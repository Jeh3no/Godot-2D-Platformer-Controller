extends CharacterBody2D

class_name PlayerCharater

var move_speed: float = 0.0
var move_accel: float = 0.0
var move_deccel: float = 0.0

@export_group("Walk variables")
@export var walk_speed: float = 150.0
@export var walk_accel: float = 9.0
@export var walk_deccel: float = 11.0

@export_group("Jump variables")
@export var jump_height: float = 50.0
@export var jump_time_to_peak: float = 0.42
@export var jump_time_to_fall: float = 0.38
@onready var jump_velocity: float = ((2.0 * jump_height) / jump_time_to_peak) * -1.0
@export var nb_jumps_allowed: int = 2
var nb_jumps_allowed_ref: int = 0
@export var jump_cooldown: float = 0.2
var jump_cooldown_ref: float = 0.0
var jump_cooldown_timer: Timer = null
@export var jump_cut_multiplier: float = 0.3
@export_subgroup("Coyote time variables")
var coyote_jump_enabled: bool = false
var coyote_time_timer: Timer = null
@export var coyote_time_val: float = 0.15
@export_subgroup("Jump buffer variables")
var jump_buffering_enabled: bool = false
@export var jump_buffer_time: float = 0.2
var jump_buffer_timer: Timer = null
@export_subgroup("Edge correction")
@export var edge_push_amount: float = 2.0
@export var edge_push_velocity: float = 20.0
var edge_push_side: int = 0

@export_group("Inair variables")
@export var inair_speed: float = 120.0
@export var inair_accel: float = 9.0
@export var inair_deccel: float = 0.0

#gravity variables
@onready var jump_gravity: float = ((-2.0 * jump_height) / (jump_time_to_peak * jump_time_to_peak)) * -1.0
@onready var fall_gravity: float = ((-2.0 * jump_height) / (jump_time_to_fall * jump_time_to_fall)) * -1.0

@export_group("Slope behaviour variables")
var floor_max_length_ref: float = 6.0

#keybinding variables
var move_left_action: StringName
var move_right_action: StringName
var jump_action: StringName

#reference variables
@onready var animated_sprite: AnimatedSprite2D = %AnimatedSprite
@onready var hitbox: CollisionShape2D = %Hitbox
@onready var animation_player: AnimationPlayer = %AnimationPlayer
@onready var state_machine: StateMachine = %StateMachine
@onready var left_edge_raycast: RayCast2D = %LeftEdgeRaycast
@onready var right_edge_raycast: RayCast2D = %RightEdgeRaycast
@onready var floor_raycast: RayCast2D = %FloorRaycast


func _ready() -> void:
	nb_jumps_allowed_ref = nb_jumps_allowed
	jump_cooldown_ref = jump_cooldown
	jump_cooldown = 0.0


func _process(delta: float) -> void:
	flip_sprite()

	manage_jump_cooldown(delta)


func _physics_process(_delta: float) -> void:
	if is_on_floor():
		if floor_raycast.is_colliding() and state_machine.curr_state_name != "JumpState":
			floor_snap_length = floor_max_length_ref
		else: #to avoid being snapped when leaving a platform (inair)
			floor_snap_length = 0.0

	move_and_slide()


func flip_sprite() -> void:
	animated_sprite.flip_h = velocity.x < 0.0


func animate(which: int, loop_anim: bool) -> void:
	var anim_to_play: Animation = null
	var anim_to_play_name: StringName = ""

	match which:
		1:
			anim_to_play = animation_player.get_animation("1-idle")
			anim_to_play_name = "1-idle"
		2:
			anim_to_play = animation_player.get_animation("2-move")
			anim_to_play_name = "2-move"
		3:
			anim_to_play = animation_player.get_animation("3-jump")
			anim_to_play_name = "3-jump"
		4:
			anim_to_play = animation_player.get_animation("4-fall")
			anim_to_play_name = "4-fall"

	match loop_anim:
		false:
			anim_to_play.loop_mode = Animation.LOOP_NONE
		true:
			anim_to_play.loop_mode = Animation.LOOP_LINEAR

	animation_player.play(anim_to_play_name)


func manage_jump_cooldown(delta: float) -> void:
	if jump_cooldown > 0.0:
		jump_cooldown -= delta


#this feature is used solely for visual feedback on the HUD
func start_edge_push_side_change_val_timer() -> void:
	if edge_push_side != 0:
		var edge_push_side_change_val_timer: Timer = Timer.new()
		edge_push_side_change_val_timer.wait_time = 0.3
		edge_push_side_change_val_timer.one_shot = true
		edge_push_side_change_val_timer.timeout.connect(
			func():
				edge_push_side = 0,
		)
		add_child(edge_push_side_change_val_timer)
		edge_push_side_change_val_timer.start()


func reset_coyote_time_timer(has_used_coyote_jump: bool) -> void:
	coyote_jump_enabled = false
	coyote_time_timer.call_deferred("queue_free")

	#subtract 1 directly, because nb_jumps_allowed should be interpreted as the number
	#of jumps on the ground (1) plus the number of jumps in the air (desired value)
	if !has_used_coyote_jump and nb_jumps_allowed > 0:
		nb_jumps_allowed -= 1


func reset_jump_buffer_timer() -> void:
	jump_buffering_enabled = false
	jump_buffer_timer.call_deferred("queue_free")
