extends CharacterBody2D

# MOVEMENT CONSTANTS
const SPEED = 500.0
const JUMP_VELOCITY = -400.0
const GRAVITY = 980.0

# DASH CONSTANTS
const DASH_SPEED = 1500.0
const DASH_DURATION = 0.2
const DASH_COOLDOWN = 1.0

# STATE FLAGS
var is_dash := false
var can_dash := true
var is_dead := false

# TIMERS
var dash_timer := 0.0
var dash_cooldown_timer := 0.0
var dash_direction := 1

# AUDIO
const DEATH_SOUND = preload("res://assets/brackeys_platformer_assets/sounds/hurt.wav")
const JUMP_SOUND = preload("res://assets/brackeys_platformer_assets/sounds/jump.wav")
const DASH_SOUND = preload("res://assets/Dash.mp3")
@onready var audio_player := AudioStreamPlayer.new()

func _ready():
	add_to_group("player")
	add_child(audio_player)

func _physics_process(delta: float) -> void:
	if is_dead:
		return
	
	# Update timers
	_update_timers(delta)
	
	# Handle input
	_handle_input()
	
	# Apply movement
	_apply_movement(delta)
	
	# Update visuals
	_update_visuals()

func _update_timers(delta: float):
	if dash_timer > 0.0:
		dash_timer -= delta
		if dash_timer <= 0.0:
			is_dash = false
	
	if dash_cooldown_timer > 0.0:
		dash_cooldown_timer -= delta
		if dash_cooldown_timer <= 0.0:
			can_dash = true

func _handle_input():
	# Dash input 
	if Input.is_action_just_pressed("move_dash") and can_dash and not is_dash:
		_start_dash()
		_play_sound(DASH_SOUND)
		return
	
	# Jump input
	if Input.is_action_just_pressed("move_up") and  not is_dash:
		velocity.y = JUMP_VELOCITY
		_play_sound(JUMP_SOUND, -15)

func _apply_movement(delta: float):
	# Apply gravity if not dashing
	if not is_on_floor() and not is_dash:
		velocity.y += GRAVITY * delta
	
	# Get movement direction
	var direction := Input.get_axis("move_left", "move_right")
	
	# Update dash direction if moving
	if direction != 0:
		dash_direction = 1 if direction > 0 else -1
	
	# Apply horizontal movement
	if is_dash:
		velocity.x = dash_direction * DASH_SPEED
		velocity.y = 0
	elif direction != 0:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
	
	move_and_slide()

func _update_visuals():
	var direction := Input.get_axis("move_left", "move_right")
	var animated_sprite = $AnimatedSprite2D
	
	# Update flip
	if direction > 0:
		animated_sprite.flip_h = false
	elif direction < 0:
		animated_sprite.flip_h = true
	elif is_dash:
		animated_sprite.flip_h = dash_direction < 0
	
	# Update animation
	if is_dash:
		animated_sprite.play("dash")
	elif not is_on_floor():
		animated_sprite.play("jump")
	elif direction != 0:
		animated_sprite.play("walk")
	else:
		animated_sprite.play("idle")

func _start_dash():
	is_dash = true
	can_dash = false
	dash_timer = DASH_DURATION
	dash_cooldown_timer = DASH_COOLDOWN

func _play_sound(sound: AudioStream, volume_db: float = 0.0):
	audio_player.volume_db = volume_db
	audio_player.stream = sound
	audio_player.play()

func die():
	if is_dead:
		return
	
	is_dead = true
	
	# Play death sound
	_play_sound(DEATH_SOUND, -10)
	
	# Stop physics
	velocity = Vector2.ZERO
	set_physics_process(false)
	
	# Visual feedback
	$AnimatedSprite2D.modulate = Color(1, 0.2, 0.2, 0.7)
	
	# Short delay then game over
	await get_tree().create_timer(0.5).timeout
	_show_game_over_screen()

func _show_game_over_screen():
	await get_tree().create_timer(0.2).timeout
	get_tree().change_scene_to_file("res://scenes/end.tscn")
	
	
	
