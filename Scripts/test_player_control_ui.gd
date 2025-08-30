extends Control

var jump_just_pressed
var jump
var jump_just_released
var walk
var look

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
	#if $LookJoystickLocations/Look.current_offset.x != 0:
	look = $LookJoystickLocations/Look.current_offset
	#elif $LookJoystickLocations/Look2.current_offset.x != 0:
		#look = $LookJoystickLocations/Look2.current_offset
	#else:
		#look = $LookJoystickLocations/Look3.current_offset
	
	#if $WalkJoystickLocations/Walk.current_offset.x != 0:
	walk = $WalkJoystickLocations/Walk.current_offset
	#elif $WalkJoystickLocations/Walk2.current_offset.x != 0:
		#walk = $WalkJoystickLocations/Walk2.current_offset
	#else:
		#walk = $WalkJoystickLocations/Walk3.current_offset
	
	print(look,walk)
