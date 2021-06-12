extends KinematicBody2D


export(int, 1, 4) var player_id = 1

export (int) var ACCELERATION = 512
export (int) var MAX_SPEED = 100
export (float) var FRICTION = 0.25
export (int) var GRAVITY = 800
export (int) var JUMP_FORCE = 300
export (int) var MAX_SLOPE_ANGLE = 46

#var velocity = Vector2.ZERO

var motion = Vector2.ZERO
var snap_vector = Vector2.ZERO
var just_jumped = false
var double_jump = true

onready var jumpTimer = $JumpTimer

func _physics_process(delta):
	just_jumped = false
	var input_vector = get_input_vector()
	apply_horizontal_force(input_vector, delta)
	apply_friction(input_vector)
	update_snap_vector()
	jump_check()
	apply_gravity(delta)
#	update_animations(input_vector)
	move()
	polarity_check()

func get_input_vector():
	var input_vector = Vector2.ZERO
	input_vector.x = Input.get_action_strength("move_right_player" + str(player_id)) - Input.get_action_strength("move_left_player" + str(player_id))
	return input_vector
	
func apply_horizontal_force(input_vector, delta):
	if input_vector.x != 0:
		motion.x += input_vector.x * ACCELERATION * delta
		motion.x = clamp(motion.x, -MAX_SPEED, MAX_SPEED)
#		rotate_player()

func apply_friction(input_vector):
	if input_vector.x == 0 and is_on_floor():
		motion.x = lerp(motion.x, 0, FRICTION)

func update_snap_vector():
	if is_on_floor():
		snap_vector = Vector2.DOWN

func jump_check():
	if is_on_floor() or jumpTimer.time_left > 0:
		if Input.is_action_just_pressed("move_up_player" + str(player_id)):
			jump(JUMP_FORCE)
			just_jumped = true
	else:
		if Input.is_action_just_released("move_up_player" + str(player_id)) and motion.y < -JUMP_FORCE/2:
			motion.y = -JUMP_FORCE/2;
		
		if Input.is_action_just_pressed("move_up_player" + str(player_id)) and double_jump == true:
			jump(JUMP_FORCE * .75)
			double_jump = false

func jump(force):
#	SoundFX.play("Jump", rand_range(0.8, 1.1), -5)
#	Utils.instance_scene_on_main(JumpEffect, global_position)
	motion.y = -force
	snap_vector = Vector2.ZERO

func apply_gravity(delta):
	if not is_on_floor():
		motion.y += GRAVITY * delta
		motion.y = min(motion.y, JUMP_FORCE)
		
func update_animations(input_vector):
	print('updating animations')
#	var facing = sign(get_local_mouse_position().x)
#	if facing != 0:
#		sprite.scale.x = facing
#
#	if input_vector.x != 0:
#		spriteAnimator.play("Run")
#		spriteAnimator.playback_speed = input_vector.x * sprite.scale.x
#	else:
#		spriteAnimator.playback_speed = 1
#		spriteAnimator.play("Idle")
#
#	if not is_on_floor():
#		spriteAnimator.play("Jump")

func move():
	var was_in_air = not is_on_floor()
	var was_on_floor = is_on_floor()
	var last_motion = motion
	var last_position = position
	
	motion = move_and_slide_with_snap(motion, snap_vector*4, Vector2.UP, true, 4, deg2rad(MAX_SLOPE_ANGLE))
	# Landing
	if was_in_air and is_on_floor():
		motion.x = last_motion.x
#		Utils.instance_scene_on_main(JumpEffect, global_position)
		double_jump = true
	
	# Just left ground
	if was_on_floor and not is_on_floor() and not just_jumped:
		motion.y = 0
		position.y = last_position.y
		jumpTimer.start()
	
	# Prevent Sliding (hack)
	if is_on_floor() and get_floor_velocity().length() == 0 and abs(motion.x) < 1:
		position.x = last_position.x

func polarity_check():
	if Input.is_action_just_pressed("move_down_player" + str(player_id)):
		apply_magnetic_force()
		
func apply_magnetic_force():
	print('magnetic force is now activated. north and south poles are magnetized')

func rotate_player():
	var ninety_degrees = 90
	var degree_rate = 1
	while ninety_degrees > 0:
		self.rotation_degrees += degree_rate
		ninety_degrees -= degree_rate
		yield(get_tree().create_timer(0.2), "timeout")
