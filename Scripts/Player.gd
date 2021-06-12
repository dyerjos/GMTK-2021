extends KinematicBody2D


export(int, 1, 4) var player_id = 1

export (int) var ACCELERATION = 512
export (int) var MAX_SPEED = 100
export (float) var FRICTION = 0.25
export (int) var GRAVITY = 800
export (int) var JUMP_FORCE = 300
export (int) var MAX_SLOPE_ANGLE = 46
export (String) var greenColor = "e5ff00" # player 2 color

#enum {
#	MOVE,
#	PUSH_PULL
#}

#var state = MOVE
var motion = Vector2.ZERO
var snap_vector = Vector2.ZERO
var direction = 1 # left = -1, right = 1
var is_rotating = false
var just_jumped = false
var double_jump = true
var is_magnetized = true
var is_connected = false
var carried_by = null
var is_carrying = false
var target = null

onready var jumpTimer = $JumpTimer
onready var northJoint = $NorthJoint
onready var southJoint = $SouthJoint
onready var northStaticBody = $NorthStaticBody
onready var southStaticBody = $SouthStaticBody

func _ready() -> void:
	if player_id == 2:
		self.modulate = greenColor

func _physics_process(delta):
	just_jumped = false
	
#	match state:
#		MOVE:
	var input_vector = get_input_vector()
	apply_horizontal_force(input_vector, delta)
	apply_friction(input_vector)
#	update_snap_vector() # TODO: delete this?
	jump_check()
	apply_gravity(delta)
#	update_animations(input_vector) # TODO: delete this?
	move()
	apply_polarity()
		
#		PUSH_PULL:
#			move()

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
		
#func update_animations(input_vector):
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
#	pass

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

func _on_NorthPole_area_entered(area: Area2D):
	print(player_id)
	if "NorthPole" in area.name and is_magnetized:
		# repel
#		var other_player = area.get_parent()
#		var other_players_northAdjacentPosition = other_player.get_node("NorthAdjacentPosition").rect_position
		is_connected = false
		print("repel")
	if "SouthPole" in area.name and is_magnetized:
		# opposites attract
		var other_player = area.get_parent()
		
		northJoint.node_b = other_player.get_node("SouthStaticBody")
		
#		var attaching_to = other_player.get_node("SouthAdjacentPosition")
##		var other_player_global = other_player.global_position
#		var other_players_southAdjacentPosition = other_player.get_node("SouthAdjacentPosition").rect_position
##		print('south global pos %s' % other_players_southAdjacentPosition )
##		print('my position is %s' % self.position)
##		self.global_position = other_player.to_global(other_players_southAdjacentPosition)
#		print("target: %s" % target)
#		is_connected = true

		print("attract")
		print("------------")

func _on_SouthPole_area_entered(area: Area2D):
	if "NorthPole" in area.name and is_magnetized:
		var other_player = area.get_parent()
		
		southJoint.node_b = other_player.get_node("NorthStaticBody")
		
#		var attaching_to = other_player.get_node("NorthAdjacentPosition")
##		var other_player_global = other_player.global_position
#		var other_players_northAdjacentPosition = other_player.get_node("NorthAdjacentPosition").rect_position
##		print('south global pos %s' % other_players_southAdjacentPosition )
##		print('my position is %s' % self.position)
#		self.global_position = other_player.to_global(other_players_northAdjacentPosition)
#		print("target: %s" % target)
#		is_connected = true

		print("attract")
		print("------------")
	if "SouthPole" in area.name and is_magnetized:
		pass
