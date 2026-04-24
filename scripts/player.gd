extends CharacterBody2D

@onready var anim = $AnimatedSprite2D
@onready var health_bar = $HealthBar
@onready var attack_area = $AttackArea
@onready var attack_shape = $AttackArea/CollisionShape2D

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

signal HEALTH_CHANGED(health, max_health)

const SPEED = 300.0
const JUMP_VELOCITY = -600.0

var max_health = 100 
var health = 100

var is_attacking = false
var is_hurting = false

var facing = 1

var attack_offset_x = 40.0


func _ready():
	connect("HEALTH_CHANGED", Callable(health_bar, "set_health"))
	emit_signal("HEALTH_CHANGED", health, max_health)

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

	#ATTACK RAAAR!!
	if Input.is_action_just_pressed(attack_action) and not is_attacking and not is_hurting and not input_locked:
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


func _on_animated_sprite_2d_animation_finished() -> void:
	if anim.animation == "attack":
		if state != State.ATTACK_START:
			return
		attack_area.monitoring = false

	if anim.animation == "hurt":
		is_hurting = false


func take_damage(damage: float):
	health -= damage
	health = clamp(health, 0, max_health)
	emit_signal("HEALTH_CHANGED", health, max_health)

	is_hurting = true
	anim.play("hurt")
	print(health)


func _on_attack_area_body_entered(body: Node2D) -> void:
	if is_attacking and body.has_method("take_damage") and body != self:
		body.take_damage(20)
		
		

func start_drawing_phase():
	state = State.DRAWING

	print("DRAW PHASE STARTED")

	await get_tree().create_timer(0.5).timeout

	resolve_attack()
	

func resolve_attack():
	state = State.RESOLVE

	var success = randi() % 2 == 0

	if success:
		print("Attack succeeds")
		is_attacking = false
	else:
		print("Attack failed")
		state = State.STUNNED
		await get_tree().create_timer(0.8).timeout

	is_attacking = false
	input_locked = false
	state = State.IDLE
