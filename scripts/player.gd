extends CharacterBody2D

@onready var anim = $AnimatedSprite2D
@onready var health_bar = $HealthBar
@onready var attack_area = $AttackArea
@onready var attack_shape = $AttackArea/CollisionShape2D
@onready var drawing_ui = $DrawingUI

@export var move_left_action = "move_left_p1"
@export var move_right_action = "move_right_p1"
@export var jump_action = "jump_p1"
@export var attack_action = "attack_p1"

var input_locked := false

enum State {
	IDLE,
	ATTACK_START,
	DRAWING,
	RESOLVE,
	STUNNED
}

var state = State.IDLE

const SPEED = 300.0
const JUMP_VELOCITY = -600.0

var max_health = 100
var health = 100

var is_attacking = false
var is_hurting = false

var facing = 1
var attack_offset_x = 40.0


func _ready():
	print("PLAYER READY")

	drawing_ui.hide()
	drawing_ui.connect("DRAWING_FINISHED", Callable(self, "_on_drawing_finished"))

	attack_offset_x = attack_shape.position.x


func _physics_process(delta: float) -> void:
	if input_locked:
		return

	if not is_on_floor():
		velocity += get_gravity() * delta

	var direction = 0

	if Input.is_action_pressed(move_left_action):
		direction = -1
	if Input.is_action_pressed(move_right_action):
		direction = 1

	if Input.is_action_just_pressed(jump_action) and is_on_floor():
		velocity.y = JUMP_VELOCITY

	if direction != 0:
		facing = direction

	anim.flip_h = facing < 0
	attack_shape.position.x = abs(attack_offset_x) * facing

	if Input.is_action_just_pressed(attack_action) and not is_attacking and not is_hurting:
		print("ATTACK STARTED")

		is_attacking = true
		input_locked = true
		state = State.ATTACK_START

		anim.play("attack")
		attack_area.monitoring = true

		start_drawing_phase()

	if not is_attacking and not is_hurting:
		if direction != 0:
			velocity.x = direction * SPEED
			anim.play("run")
		else:
			anim.play("Idle")
			velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()


func start_drawing_phase():
	print("DRAW PHASE STARTED")

	state = State.DRAWING

	drawing_ui.start_drawing()

	await get_tree().create_timer(1.0).timeout

	print("DRAW TIMER DONE")

	drawing_ui.finish_drawing()


func _on_drawing_finished(strokes):
	print("DRAWING FINISHED:", strokes.size())

	resolve_attack()


func resolve_attack():
	print("RESOLVE ATTACK")

	state = State.RESOLVE

	var success = randi() % 2 == 0

	if success:
		print("ATTACK SUCCESS")
	else:
		print("ATTACK FAIL")
		state = State.STUNNED
		await get_tree().create_timer(0.8).timeout

	is_attacking = false
	input_locked = false
	state = State.IDLE
