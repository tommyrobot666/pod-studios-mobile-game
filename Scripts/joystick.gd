extends TouchScreenButton
class_name Joystick

var currently_pressed:bool = false
@onready var start_pos:Vector2 = self.global_position
var current_offset = Vector2.ZERO
@onready var last_touch = start_pos
@export var radius:float = 999
@export var last_touch_radius:float = 100


func _ready() -> void:
	pressed.connect(_pressed)
	released.connect(_released)

func _pressed():
	currently_pressed = true
	#print(2)

func _released():
	current_offset = Vector2.ZERO
	currently_pressed = false
	last_touch = start_pos
	global_position = start_pos
	#print(3)

func _input(event: InputEvent) -> void:
	if currently_pressed and event is InputEventScreenDrag:
		var event_drag:InputEventScreenDrag = event as InputEventScreenDrag
		#print(event_drag.position - last_touch)
		#print((event_drag.position - last_touch).length_squared())
		if ((event_drag.position - event_drag.screen_relative) - last_touch).length_squared() < last_touch_radius*last_touch_radius:
			#print(1)
			global_position = event_drag.position
			current_offset = (event_drag.position - last_touch)
			last_touch = event_drag.position
			
			if radius != -1:
				if current_offset.length_squared() > radius*radius:
					_pressed()
