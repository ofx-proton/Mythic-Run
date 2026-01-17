extends Node2D

# EXPORT
@export var ball_scene: PackedScene
@export var camera_2d: Camera2D
@export var spawn_timer: Timer
@export var initial_spawn_rate: float = 1.0
@export var min_spawn_rate: float = 0.2
@export var spawn_acceleration: float = 0.0175
@export var rain_speed: float = 400.0
@export var max_on_screen: int = 6

# HUD
@export var hud_path: NodePath   # drag HUD (CanvasLayer) here

# SCORE
var score: int = 0
var high_score: int = 0

const SAVE_FILE := "user://highscore.save"

@onready var score_label: Label = get_node(hud_path).get_node("Label2")
@onready var high_score_label: Label = get_node(hud_path).get_node("Label3")


func _ready() -> void:
	randomize()

	load_high_score()
	_update_score_labels()

	spawn_timer.timeout.connect(spawn_ball)
	spawn_timer.wait_time = initial_spawn_rate
	spawn_timer.start()


func spawn_ball() -> void:
	if _count_visible_balls() >= max_on_screen:
		return

	var bounds := _get_camera_bounds()
	var ball := ball_scene.instantiate()

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
	ball.set_rain_velocity(velocity)

	add_child(ball)

	# Score updates on spawn
	score += 1
	if score > high_score:
		high_score = score
		save_high_score()

	_update_score_labels()

	if spawn_timer.wait_time > min_spawn_rate:
		spawn_timer.wait_time = max(
			min_spawn_rate,
			spawn_timer.wait_time - spawn_acceleration
		)


func _update_score_labels() -> void:
	score_label.text = "SCORE: %d" % score
	high_score_label.text = "HIGH SCORE: %d" % high_score


func _count_visible_balls() -> int:
	var count := 0
	for child in get_children():
		if child is Node2D and get_viewport_rect().has_point(child.global_position):
			count += 1
	return count


func _get_camera_bounds() -> Rect2:
	var size := get_viewport_rect().size
	var center := camera_2d.global_position
	var extra := size.y * 2

	return Rect2(
		Vector2(center.x - size.x / 2 - extra, center.y - size.y / 2 - 100),
		Vector2(size.x + extra * 2, size.y + 200)
	)


# -----------------------
# HIGH SCORE SAVE SYSTEM
# -----------------------

func save_high_score() -> void:
	var file := FileAccess.open(SAVE_FILE, FileAccess.WRITE)
	if file:
		file.store_32(high_score)
		file.close()


func load_high_score() -> void:
	if not FileAccess.file_exists(SAVE_FILE):
		high_score = 0
		return

	var file := FileAccess.open(SAVE_FILE, FileAccess.READ)
	if file:
		high_score = file.get_32()
		file.close()
