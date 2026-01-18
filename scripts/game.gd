extends Node2D

@export var ball_scene: PackedScene
@export var camera_2d: Camera2D
@export var player_node: Node2D
@export var spawn_timer: Timer
@export var initial_spawn_rate: float = 1.0
@export var min_spawn_rate: float = 0.2
@export var spawn_acceleration: float = 0.0175
@export var rain_speed: float = 400.0
@export var max_on_screen: int = 6

var score: int = 0
var high_score: int = 0
const SAVE_FILE := "user://highscore.save"

@export var hud_path: NodePath
@onready var score_label: Label = get_node(hud_path).get_node("Label2")
@onready var high_score_label: Label = get_node(hud_path).get_node("Label3")

func _ready() -> void:
	randomize()
	load_high_score()
	_update_score_labels()
	process_mode = Node.PROCESS_MODE_ALWAYS
	if player_node:
		player_node.process_mode = Node.PROCESS_MODE_PAUSABLE
	spawn_timer.process_mode = Node.PROCESS_MODE_PAUSABLE
	spawn_timer.timeout.connect(spawn_ball)
	spawn_timer.wait_time = initial_spawn_rate
	spawn_timer.start()

func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE:
		var is_paused = get_tree().paused
		get_tree().paused = not is_paused

func spawn_ball() -> void:
	if _count_balls_in_view() >= max_on_screen:
		return

	var bounds := _get_camera_bounds()
	var ball := ball_scene.instantiate()
	ball.process_mode = Node.PROCESS_MODE_PAUSABLE
	ball.add_to_group("balls")

	var angle := deg_to_rad(randf_range(0.0, 89.0))
	var velocity := Vector2(
		rain_speed * sin(angle),
		rain_speed * cos(angle)
	)

	var x: float
	var y := bounds.position.y

	if randi() % 2 == 0:
		x = randf_range(bounds.position.x, bounds.position.x + bounds.size.x * 0.3)
	else:
		x = randf_range(bounds.position.x + bounds.size.x * 0.7, bounds.position.x + bounds.size.x)
		velocity.x = -velocity.x

	ball.global_position = Vector2(x, y)

	if ball.has_method("set_rain_velocity"):
		ball.set_rain_velocity(velocity)

	add_child(ball)

	score += 1
	if score > high_score:
		high_score = score
		save_high_score()

	_update_score_labels()

	if spawn_timer.wait_time > min_spawn_rate:
		spawn_timer.wait_time = max(min_spawn_rate, spawn_timer.wait_time - spawn_acceleration)

func _count_balls_in_view() -> int:
	var count = 0
	var view_rect = _get_actual_view_rect()
	for ball in get_tree().get_nodes_in_group("balls"):
		if is_instance_valid(ball) and view_rect.has_point(ball.global_position):
			count += 1
	return count

func _get_actual_view_rect() -> Rect2:
	var v_size := get_viewport_rect().size
	var center := camera_2d.get_screen_center_position()
	return Rect2(center - (v_size / 2), v_size)

func _get_camera_bounds() -> Rect2:
	var v_size := get_viewport_rect().size
	var center := camera_2d.get_screen_center_position()
	var top_left = center - (v_size / 2)
	return Rect2(
		Vector2(top_left.x, top_left.y - 100), 
		Vector2(v_size.x, v_size.y + 200)
	)

func _update_score_labels() -> void:
	if score_label: score_label.text = "SCORE: %d" % score
	if high_score_label: high_score_label.text = "HIGH SCORE: %d" % high_score

func save_high_score() -> void:
	var file := FileAccess.open(SAVE_FILE, FileAccess.WRITE)
	if file:
		file.store_32(high_score)

func load_high_score() -> void:
	if FileAccess.file_exists(SAVE_FILE):
		var file := FileAccess.open(SAVE_FILE, FileAccess.READ)
		if file:
			high_score = file.get_32()
	else:
		high_score = 0
