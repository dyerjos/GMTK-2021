extends KinematicBody2D


export(int, 1, 4) var player_id = 1

export (int) var ACCELERATION = 512
export (int) var MAX_SPEED = 100
export (float) var FRICTION = 0.25
export (int) var GRAVITY = 800
export (int) var JUMP_FORCE = 300
export (int) var MAX_SLOPE_ANGLE = 46
export (String) var greenColor = "e5ff00" # player 2 color

var motion = Vector2.ZERO
var snap_vector = Vector2.ZERO
var direction = 1 # left = -1, right = 1
var is_rotating = false
var just_jumped = false
var double_jump = true
var is_magnetized = false

onready var jumpTimer = $JumpTimer

func _ready() -> void:
	if player_id == 2:
		self.modulate = greenColor

func _physics_process(delta):
	just_jumped = false
	var input_vector = get_input_vector()
	apply_horizontal_force(input_vector, delta)
	apply_friction(input_vector)
#	update_snap_vector() # TODO: delete this?
	jump_check()
	apply_gravity(delta)
#	update_animations(input_vector) # TODO: delete this?
	move()
	apply_polarity()

func get_input_vector():
	var input_vector = Vector2.ZERO
	input_vector.x = Input.get_action_strength("move_right_player" + str(player_id)) - Input.get_action_strength("move_left_player" + str(player_id))
	direction = input_vector.x
	return input_vector
	
func apply_horizontal_force(input_vector, delta):
	if input_vector.x != 0:
		motion.x += input_vector.x * ACCELERATION * delta
		motion.x = clamp(motion.x, -MAX_SPEED, MAX_SPEED)
		rotate_player()

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
	motion.y = -force
	snap_vector = Vector2.ZERO

func apply_gravity(delta):
	if not is_on_floor():
		motion.y += GRAVITY * delta
		motion.y = min(motion.y, JUMP_FORCE)
		
func update_animations(input_vector):
#	print('updating animations')
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
	pass

func move():
	var was_in_air = not is_on_floor()
	var was_on_floor = is_on_floor()
	var last_motion = motion
	var last_position = position
	
	motion = move_and_slide_with_snap(motion, snap_vector*4, Vector2.UP, true, 4, deg2rad(MAX_SLOPE_ANGLE))
	# Landing
	if was_in_air and is_on_floor():
		motion.x = last_motion.x
		double_jump = true
	
	# Just left ground
	if was_on_floor and not is_on_floor() and not just_jumped:
		motion.y = 0
		position.y = last_position.y
		jumpTimer.start()

func apply_polarity():
	if Input.is_action_just_pressed("move_down_player" + str(player_id)):
		print('magnetic force is now activated. north and south poles are magnetized')
		is_magnetized = true

func rotate_player():
	var degree_rate = 5
	self.rotation_degrees += degree_rate * direction 

func _on_NorthPole_area_entered(area: Area2D) -> void:
	pass # Replace with function body.

func _on_SouthPole_area_entered(area: Area2D) -> void:
	pass # Replace with function body.
