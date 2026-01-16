extends Node2D

# EXPORT
@export var ball_scene: PackedScene
@export var camera_2d: Camera2D
@export var spawn_timer: Timer
@export var initial_spawn_rate: float = 1.0
@export var min_spawn_rate: float = 0.2
@export var spawn_acceleration: float = 0.02
@export var rain_angle: float = 60.0
@export var rain_speed: float = 350.0

# PRIVATE
#var _extended_bounds: Rect2
var _angle_rad: float
var _sin_angle: float
var _cos_angle: float
var _velocity_template: Vector2

func _ready():
	randomize()
	
	# Pre-calculate trigonometric values (optimization)
	_angle_rad = deg_to_rad(rain_angle)
	_sin_angle = sin(_angle_rad)
	_cos_angle = cos(_angle_rad)
	_velocity_template = Vector2(rain_speed * _sin_angle, rain_speed * _cos_angle)
	
	if spawn_timer and ball_scene:
		spawn_timer.timeout.connect(spawn_ball)
		spawn_timer.wait_time = initial_spawn_rate
		spawn_timer.start()

func spawn_ball():
	if not camera_2d or not ball_scene:
		return
	
	# Calculate bounds once per spawn
	var bounds = _get_camera_bounds()
	var ball = ball_scene.instantiate()
	
	# Use pre-calculated velocity
	var velocity = _velocity_template
	
	# Random starting position
	var start_side = randi() % 2
	var x: float
	var y = bounds.position.y
	
	if start_side == 0:
		# Start from left side
		x = randf_range(bounds.position.x, bounds.position.x + bounds.size.x * 0.3)
	else:
		# Start from right side
		x = randf_range(bounds.position.x + bounds.size.x * 0.7, bounds.position.x + bounds.size.x)
		velocity.x = -velocity.x
	
	ball.global_position = Vector2(x, y)
	ball.set_rain_velocity(velocity)
	add_child(ball)
	
	# Accelerate spawn timer
	if spawn_timer.wait_time > min_spawn_rate:
		spawn_timer.wait_time = max(min_spawn_rate, spawn_timer.wait_time - spawn_acceleration)

func _get_camera_bounds() -> Rect2:
	if not camera_2d:
		return Rect2(Vector2.ZERO, get_viewport_rect().size)
	
	var size = get_viewport_rect().size
	var center = camera_2d.global_position
	var bounds = Rect2(center - size / 2, size)
	
	# Pre-calculated trig values from _ready
	var extra_width = _sin_angle / _cos_angle * size.y * 2  # tan(angle) = sin/cos
	
	return Rect2(
		bounds.position.x - extra_width,
		bounds.position.y - 100,
		bounds.size.x + extra_width * 2,
		bounds.size.y + 200
	)
