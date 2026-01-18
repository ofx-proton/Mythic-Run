extends CharacterBody2D

const SPEED = 500.0
const JUMP_VELOCITY = -400.0
const GRAVITY = 980.0
const DASH_SPEED = 1500.0
const DASH_DURATION = 0.2
const DASH_COOLDOWN = 1.0

var is_dash := false
var can_dash := true
var is_dead := false
var lives: int = 3
var dash_direction := 1

@onready var sprite = $AnimatedSprite2D
@onready var audio_player := AudioStreamPlayer.new()

const DEATH_SOUND = preload("res://assets/brackeys_platformer_assets/sounds/hurt.wav")
const JUMP_SOUND = preload("res://assets/brackeys_platformer_assets/sounds/jump.wav")
const DASH_SOUND = preload("res://assets/Dash.mp3")

func _ready() -> void:
	add_to_group("player")
	add_child(audio_player)

func _physics_process(delta: float) -> void:
	if is_dead: return

	_apply_movement(delta)
	_update_visuals()

func _apply_movement(delta: float) -> void:
	if not is_on_floor() and not is_dash:
		velocity.y += GRAVITY * delta

	var input_dir = Input.get_axis("move_left", "move_right")
	if input_dir != 0: dash_direction = sign(input_dir)

	if Input.is_action_just_pressed("move_dash") and can_dash:
		_start_dash()

	if Input.is_action_just_pressed("move_up") and not is_dash:
		velocity.y = JUMP_VELOCITY
		_play_sound(JUMP_SOUND, -15)

	if is_dash:
		velocity.x = dash_direction * DASH_SPEED
		velocity.y = 0
	elif input_dir != 0:
		velocity.x = input_dir * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()

func _start_dash() -> void:
	is_dash = true
	can_dash = false
	_play_sound(DASH_SOUND)
	get_tree().create_timer(DASH_DURATION).timeout.connect(func(): is_dash = false)
	get_tree().create_timer(DASH_COOLDOWN).timeout.connect(func(): can_dash = true)

func _update_visuals() -> void:
	var input_dir = Input.get_axis("move_left", "move_right")
	if input_dir != 0: sprite.flip_h = input_dir < 0
	elif is_dash: sprite.flip_h = dash_direction < 0

	if is_dash: sprite.play("dash")
	elif not is_on_floor(): sprite.play("jump")
	elif input_dir != 0: sprite.play("walk")
	else: sprite.play("idle")

func _play_sound(sound: AudioStream, vol: float = 0.0) -> void:
	audio_player.stream = sound
	audio_player.volume_db = vol
	audio_player.play()

func die() -> void:
	lives -= 1
	match lives:
		2: sprite.modulate = Color(0.75, 0.63, 0.13)
		1: sprite.modulate = Color(0.94, 0.51, 0.26)
		0:
			is_dead = true
			_play_sound(DEATH_SOUND, -10)
			sprite.modulate = Color(1, 0.2, 0.2, 0.7)
			velocity = Vector2.ZERO
			set_physics_process(false)
			await get_tree().create_timer(0.4).timeout
			get_tree().change_scene_to_file("res://scenes/end.tscn")
