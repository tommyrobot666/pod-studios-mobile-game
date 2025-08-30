extends CharacterBody3D

@export var jump_velocity:float
@export var gravity:float
@export var min_jump_time:float
@export var jump_peak_time:float
@export var end_jump_gravity:float

@export var mouse_sensitivity = 0.5
var camera_rotation = Vector3()

@onready var third_camera_3d: Camera3D = $ThirdCamera3D
@onready var first_camera_3d: Camera3D = $FirstCamera3D

var jump_time:float
var stop_jump:bool = false
var falling:bool = false
var rising:bool = false

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED) 
	third_camera_3d.make_current()


func _unhandled_input(event):
	if event is InputEventMouseMotion:
		rotation_degrees.y -= event.relative.x * 0.5
		rotation_degrees.x -= event.relative.y * 0.25
	
	elif event.is_action_pressed("ui_cancel"): 
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE) 
		
	elif event.is_action_pressed("toggle_perspective") and not event.is_echo():
		match get_viewport().get_camera_3d():
			third_camera_3d:
				first_camera_3d.make_current()
			first_camera_3d:
				third_camera_3d.make_current()
			_:
				print("unexpected camera")


func _physics_process(delta):
	
	var SPEED = 20.0
	
	var input_direction_2D = (Input.get_vector(
		"move_left", "move_right", "move_forward","move_back"
	) + PlayerControlUi.walk.normalized()).normalized()
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
	if (Input.is_action_just_released("jump") or PlayerControlUi.jump_just_released) and rising:
		stop_jump = true
	
	# handle jump
	if (Input.is_action_just_pressed("jump") or PlayerControlUi.jump_just_pressed) and is_on_floor():
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
	
	rotation_degrees.y -= PlayerControlUi.look.x * 0.5
	rotation_degrees.x -= PlayerControlUi.look.y * 0.25
	
	PlayerControlUi.input_read()
