extends KinematicBody2D

const GRAVITY_STRENGTH = 500

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
var just_jumped = false
var is_magnetized = true
var other_players_active_side = null
var players_active_side = null
var repel_or_attract = null
var influence_direction
var currentTotalForce : Vector2 = Vector2(0,0)

onready var jumpTimer = $JumpTimer
onready var repelTimer = $RepelTimer

func _ready() -> void:
	if player_id == 2:
		self.modulate = greenColor

func _physics_process(delta):
	just_jumped = false
	var input_vector = get_input_vector()
	apply_horizontal_force(input_vector, delta)
	apply_friction(input_vector)
	jump_check()
	apply_gravity(delta)
	move()
	apply_polarity()
	apply_magnetism()


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

func jump_check():
	if is_on_floor() or jumpTimer.time_left > 0:
		if Input.is_action_just_pressed("move_up_player" + str(player_id)):
			jump(JUMP_FORCE)
			just_jumped = true
	else:
		if Input.is_action_just_released("move_up_player" + str(player_id)) and motion.y < -JUMP_FORCE/2:
			motion.y = -JUMP_FORCE/2;

func jump(force):
	motion.y = -force
	snap_vector = Vector2.ZERO

func apply_gravity(delta):
	if not is_on_floor():
		motion.y += GRAVITY * delta
		motion.y = min(motion.y, JUMP_FORCE)

func move():
	var was_in_air = not is_on_floor()
	var was_on_floor = is_on_floor()
	var last_motion = motion
	var last_position = position
	
	motion = move_and_slide_with_snap(motion, snap_vector*4, Vector2.UP, true, 4, deg2rad(MAX_SLOPE_ANGLE))
	# Landing
	if was_in_air and is_on_floor():
		motion.x = last_motion.x
	
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
	other_players_active_side = area.get_parent().get_node("SouthGravityPoint")
	if "NorthPole" in area.name and is_magnetized:
		repel_or_attract ="repel"
		players_active_side = self.get_node("SouthGravityPoint")
	if "SouthPole" in area.name and is_magnetized and player_id == 1:
		repel_or_attract = "attract"
		players_active_side = self.get_node("NorthGravityPoint")


func _on_SouthPole_area_entered(area: Area2D):
	other_players_active_side = area.get_parent().get_node("SouthGravityPoint")
	if "NorthPole" in area.name and is_magnetized and player_id == 1:
		repel_or_attract = "attract"
		players_active_side = self.get_node("NorthGravityPoint")
	
	if "SouthPole" in area.name and is_magnetized:
		repel_or_attract = "repel"
		players_active_side = self.get_node("SouthGravityPoint")
		
func apply_magnetism():
	if other_players_active_side and players_active_side:
		var other_parent = other_players_active_side.get_parent()
		var other_pos = other_parent.to_global(other_players_active_side.position)
		var player_pos = self.to_global(players_active_side.position)
		var distance = player_pos.distance_to(other_pos)
		if repel_or_attract == "attract":
			influence_direction = player_pos.direction_to(other_pos)
		elif repel_or_attract == "repel":
			influence_direction = -1 * player_pos.direction_to(other_pos)
		if distance > 10 and distance < 200:
			add_central_force(influence_direction * GRAVITY_STRENGTH)
			move_and_slide(currentTotalForce)
			currentTotalForce = Vector2(0,0)
		elif distance > 200: # too far to be affected by magnetic field
			repel_or_attract = null
			other_players_active_side = null
			players_active_side = null
			
		
func add_central_force(toAdd : Vector2):
	currentTotalForce += toAdd
