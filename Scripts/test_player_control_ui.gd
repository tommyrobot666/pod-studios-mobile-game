extends Control

var jump_just_pressed:bool = false
var jump:bool = false
var jump_just_released:bool = false
var walk:Vector2 = Vector2.ZERO
var look:Vector2 = Vector2.ZERO

func _on_jump_pressed() -> void:
	if jump == false:
		jump_just_pressed = true
	jump = true

func _on_jump_released() -> void:
	if jump == true:
		jump_just_released = true
	jump = false

func input_read():
	jump_just_pressed = false
	jump_just_released = false

func _process(delta: float) -> void:
	look = $LookJoystickLocations/Look2.current_offset
	walk = $WalkJoystickLocations/Walk.current_offset
