extends CharacterBody2D

# --- Variables (Day 2) ---
@export var MAX_SPEED = 200.0
@export var ACCEL = 800.0
@export var FRICTION = 600.0
@export var DODGE_SPEED = 500.0
@export var STAMINA_REGEN = 25.0

var stamina = 100.0
var max_stamina = 100.0
var dodge_cost = 30.0

# --- State Machine (Day 3 Expansion) ---
enum State { IDLE, MOVE, DODGE, ATTACK }
var current_state = State.IDLE

# --- Node References ---
@onready var hitbox_shape = $Hitbox/CollisionShape2D

func _ready():
	# Ensure hitbox is off at the start
	hitbox_shape.disabled = true

func _physics_process(delta):
	# 1. Constant Stamina Regen (unless dodging)
	if current_state != State.DODGE and stamina < max_stamina:
		stamina = move_toward(stamina, max_stamina, STAMINA_REGEN * delta)

	# 2. State Controller
	match current_state:
		State.IDLE, State.MOVE:
			handle_movement_state(delta)
		State.DODGE:
			handle_dodge_state(delta)
		State.ATTACK:
			handle_attack_state(delta)

# --- State Functions ---

func handle_movement_state(delta):
	var input_vector = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	
	# Handle Velocity
	if input_vector != Vector2.ZERO:
		current_state = State.MOVE
		velocity = velocity.move_toward(input_vector * MAX_SPEED, ACCEL * delta)
	else:
		current_state = State.IDLE
		velocity = velocity.move_toward(Vector2.ZERO, FRICTION * delta)
	
	move_and_slide()

	if Input.is_action_just_pressed("ui_accept") and stamina>=dodge_cost:
		start_dodge(input_vector)
	elif Input.is_action_just_pressed("ui_select"):
		start_attack()
		
func start_dodge(dir):
	stamina-=dodge_cost
	current_state=State.DODGE
	if dir==Vector2.ZERO:
		dir=Vector2.RIGHT
	velocity=dir.normalized()*DODGE_SPEED
	
	await get_tree().create_timer(0.2).timeout
	current_state=State.IDLE
	
func handle_dodge_state(_delta):
	move_and_slide()

func start_attack():
	current_state=State.ATTACK
	velocity=Vector2.ZERO
	hitbox_shape.disabled=false
	print("Swinging Sword")

	await get_tree().create_timer(0.3).timeout
	hitbox_shape.disabled=true
	current_state=State.IDLE
	
func handle_attack_state(delta):
	pass

	
	
			
		
				
		
	
	
	
	

		
