extends CharacterBody2D

const SPEED = 400.0
const JUMP_VELOCITY = -350.0
const DASH_SPEED = 1400
const DASH_DURATION = 0.2
const DASH_DISTANCE = 350

var is_idle = true
var is_jump = false
var is_dash = false
var is_move = false
var can_dash = true
var dash_timer = 0.0
var dash_direction = 1

func _physics_process(delta: float) -> void:
	# Reset states each frame
	is_idle = true
	is_move = false
	is_jump = false
	
	# DASH TIMER
	if dash_timer > 0:
		dash_timer -= delta
		is_dash = true
		is_idle = false
		if dash_timer <= 0:
			is_dash = false
	
	# Add gravity (but not during dash)
	if not is_on_floor() and not is_dash:
		velocity += get_gravity() * delta
		is_jump = true
	
	# Handle jump input
	if Input.is_action_just_pressed("move_up") and is_on_floor() and not is_dash:
		velocity.y = JUMP_VELOCITY
		is_jump = true
	
	# HANDLE DASH INPUT
	if Input.is_action_just_pressed("move_dash") and can_dash and not is_dash:
		start_dash()
	
	# Get movement direction
	var direction := Input.get_axis("move_left", "move_right")
	
	# Update facing direction for dash
	if direction != 0:
		dash_direction = 1 if direction > 0 else -1
	
	# APPLY MOVEMENT (different logic during dash)
	if is_dash:
		# Dash movement - fixed speed in dash direction
		velocity.x = dash_direction * DASH_SPEED
		velocity.y = 0  
		is_move = true
	elif direction:
		# Normal movement
		velocity.x = direction * SPEED
		is_move = true
		is_idle = false
	else:
		# Slow down
		velocity.x = move_toward(velocity.x, 0, SPEED)
	move_and_slide()
	if direction > 0:
		$AnimatedSprite2D.flip_h = false
	elif direction < 0:
		$AnimatedSprite2D.flip_h = true
	elif is_dash:
		$AnimatedSprite2D.flip_h = true if dash_direction < 0 else false
	
	# ANIMATION 
	if is_dash:
		$AnimatedSprite2D.play("dash")
	elif is_jump:
		$AnimatedSprite2D.play("jump")
	elif is_move:
		$AnimatedSprite2D.play("walk")
	else:  
		$AnimatedSprite2D.play("idle")

func start_dash():
	is_dash = true
	dash_timer = DASH_DURATION
	can_dash = false
	
	await get_tree().create_timer(0.5).timeout
	can_dash = true
