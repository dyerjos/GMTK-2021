extends KinematicBody2D


export(int, 1, 4) var player_id = 1
export (int) var speed = 100
export (int) var jump_speed = -600
export (int) var gravity = 2000

var velocity = Vector2.ZERO


func _physics_process(delta):
	move_player()
	velocity.y += gravity * delta
	velocity = move_and_slide(velocity, Vector2.UP)


func move_player():
	velocity.x = 0
	if Input.is_action_pressed("move_right_player" + str(player_id)):
		velocity.x += speed
		rotate_player()
	if Input.is_action_pressed("move_left_player" + str(player_id)):
		velocity.x -= speed
		rotate_player()
	if Input.is_action_just_pressed("move_up_player" + str(player_id)) and is_on_floor():
		velocity.y = jump_speed
	if Input.is_action_just_pressed("move_down_player" + str(player_id)):
		rotate_player()
#	if Input.is_action_just_pressed("ui_cancel"):
#		blindfold.visible = !blindfold.visible

func rotate_player():
	var ninety_degrees = 90
	var degree_rate = 5
	while ninety_degrees > 0:
		self.rotation_degrees += degree_rate
		ninety_degrees -= degree_rate
		yield(get_tree().create_timer(0.02), "timeout")
