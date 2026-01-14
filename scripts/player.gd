extends CharacterBody2D

const SPEED = 300.0
const JUMP_VELOCITY = -400.0
var is_idle = true
var is_jump = false
var is_move = false

func _physics_process(delta: float) -> void:
	# Reset states each frame
	is_idle = true
	is_move = false
	is_jump = false
	
	# Add gravity
	if not is_on_floor():
		velocity += get_gravity() * delta
		is_jump = true  # In air = jumping/falling
	
	# Handle jump input
	if Input.is_action_just_pressed("move_up") and is_on_floor():
		velocity.y = JUMP_VELOCITY
		is_jump = true
	
	# Get movement direction
	var direction := Input.get_axis("move_left", "move_right")
	
	# Apply movement
	if direction:
		velocity.x = direction * SPEED
		is_move = true
		is_idle = false
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		# is_idle remains true if not jumping
	
	# Apply physics
	move_and_slide()
	
	# ANIMATION (after all state checks)
	if is_jump:
		$AnimatedSprite2D.play("jump")
	elif is_move:
		$AnimatedSprite2D.play("walk")
	else:  # This else: needs proper indentation!
		$AnimatedSprite2D.play("idle")
