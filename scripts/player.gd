extends CharacterBody2D

@onready var anim = $AnimatedSprite2D
@onready var health_bar = $HealthBar

signal HEALTH_CHANGED(health, max_health)

const SPEED = 300.0
const JUMP_VELOCITY = -400.0

var max_health = 100 
var health = 50

var is_attacking = false
var is_hurting = false

func _ready():
	connect("HEALTH_CHANGED", Callable(health_bar, "set_health"))
	emit_signal("HEALTH_CHANGED", health, max_health) 

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
	
	#Handle attack.
	if Input.is_action_just_pressed("attack") and not is_attacking and not is_hurting:
		is_attacking = true
		anim.play("attack")
	
	#fake damage
	if Input.is_action_just_pressed("a_button_for_testing_things") and not is_hurting:
		take_damage(15)

		
	var direction  = 0
	if Input.is_action_pressed("move_left"):
		direction = -1
	if Input.is_action_pressed("move_right"):
		direction = 1
	
	if not is_attacking and not is_hurting:
		if direction:
			velocity.x = direction * SPEED
			anim.play("run")
			anim.flip_h = direction < 0
			
		else:
			anim.play("Idle")
			velocity.x = move_toward(velocity.x, 0, SPEED)
	

	move_and_slide()


func _on_animated_sprite_2d_animation_finished() -> void:
	if anim.animation == "attack":
		is_attacking = false
	if anim.animation == "hurt":
		is_hurting = false
	
func take_damage(damage: float):
	health -= damage
	health = clamp(health, 0, max_health)
	emit_signal("HEALTH_CHANGED", health, max_health)
	is_hurting = true
	anim.play("hurt")
	print(health)
	
	
	
