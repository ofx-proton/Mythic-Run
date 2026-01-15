extends CharacterBody2D

# MOVEMENT
const SPEED = 500.0
const JUMP_VELOCITY = -400.0

# DASH
const DASH_SPEED = 1400.0
const DASH_DURATION = 0.2
const DASH_COOLDOWN = 5

# STATE
var is_idle := true
var is_jump := false
var is_dash := false
var is_move := false

# DASH CONTROL
var can_dash := true
var dash_timer := 0.0
var dash_cooldown_timer := 0.0
var dash_direction := 1


func _physics_process(delta: float) -> void:
	# RESET STATES
	is_idle = true
	is_move = false
	is_jump = false

	# DASH DURATION TIMER
	if dash_timer > 0.0:
		dash_timer -= delta
		is_dash = true
		is_idle = false
		if dash_timer <= 0.0:
			is_dash = false

	# DASH COOLDOWN TIMER
	if dash_cooldown_timer > 0.0:
		dash_cooldown_timer -= delta
		if dash_cooldown_timer <= 0.0:
			can_dash = true

	# GRAVITY (disabled during dash)
	if not is_on_floor() and not is_dash:
		velocity += get_gravity() * delta
		is_jump = true

	# JUMP
	if Input.is_action_just_pressed("move_up") and is_on_floor() and not is_dash:
		velocity.y = JUMP_VELOCITY
		is_jump = true

	# DASH INPUT
	if Input.is_action_just_pressed("move_dash") and can_dash and not is_dash:
		start_dash()

	# HORIZONTAL INPUT
	var direction := Input.get_axis("move_left", "move_right")

	# UPDATE DASH FACING
	if direction != 0:
		dash_direction = 1 if direction > 0 else -1

	# APPLY MOVEMENT
	if is_dash:
		velocity.x = dash_direction * DASH_SPEED
		velocity.y = 0
		is_move = true
	elif direction != 0:
		velocity.x = direction * SPEED
		is_move = true
		is_idle = false
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()

	# FLIP SPRITE
	if direction > 0:
		$AnimatedSprite2D.flip_h = false
	elif direction < 0:
		$AnimatedSprite2D.flip_h = true
	elif is_dash:
		$AnimatedSprite2D.flip_h = dash_direction < 0

	# ANIMATIONS
	if is_dash:
		$AnimatedSprite2D.play("dash")
	elif is_jump:
		$AnimatedSprite2D.play("jump")
	elif is_move:
		$AnimatedSprite2D.play("walk")
	else:
		$AnimatedSprite2D.play("idle")


func start_dash() -> void:
	is_dash = true
	can_dash = false
	dash_timer = DASH_DURATION
	dash_cooldown_timer = DASH_COOLDOWN
