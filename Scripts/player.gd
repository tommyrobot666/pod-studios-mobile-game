extends CharacterBody3D

@export_category("Jump")
@export var jump_velocity:float
@export var gravity:float
@export var min_jump_time:float
@export var jump_peak_time:float
@export var end_jump_gravity:float

var jump_time:float
var stop_jump:bool = false
var falling:bool = false
var rising:bool = false

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED) 


func _unhandled_input(event):
	if event is InputEventMouseMotion:
		rotation_degrees.y -= event.relative.x * 0.5
		get_node("Camera3D").rotation_degrees.x -= event.relative.y * 0.2
		get_node("Camera3D").rotation_degrees.x = clamp(
			get_node("Camera3D").rotation_degrees.x, -45.0, 45.0
		)
	elif event.is_action_pressed("ui_cancel"): 
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE) 


func _physics_process(delta):
	
	var SPEED = 15.0
	
	var input_direction_2D = Input.get_vector(
		"move_left", "move_right", "move_forward","move_back"
	)
	var input_direction_3D = Vector3(
		input_direction_2D.x, 0.0, input_direction_2D.y
	)
	
	var direction = transform.basis * input_direction_3D
	
	velocity.x = direction.x * SPEED
	velocity.z = direction.z * SPEED
	
# fall down -> stopped jumping
	if falling and is_on_floor():
		falling = false
		rising = false
	
	# use other gravity for other half of jump
	if falling:
		velocity.y -= end_jump_gravity * delta
	else:
		# is falling after peak of jump
		if jump_time > jump_peak_time:
			falling = true
			rising = false
		
		velocity.y -= gravity * delta
	
	# for if jump is stopped before min_jump_time
	if Input.is_action_just_released("jump") and rising:
		stop_jump = true
	
	# handle jump
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = 15.0
	elif Input.is_action_just_released("jump") and velocity.y > 0.0:
		velocity.y = jump_velocity 
		jump_time = 0
		rising = true
	elif stop_jump and jump_time > min_jump_time:
		# early stop
		velocity.y = 0.0
		stop_jump = false
		falling = true
		rising = false
	
	move_and_slide()
	jump_time += delta
