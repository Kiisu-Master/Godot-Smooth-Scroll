## A node that intercepts scrolling events and turns them into smoothed scroll events.
## (Works only on one window at a time. Should be manually added to sub-windows.)
class_name SmoothScroll extends Control


## The higher the scroll speed, the faster scrolling will happen.
@export var scroll_speed: float = 20.0
## How much to jump forward.
@export var scroll_step: float = 1.0

var _last_pos: Vector2  # The last known mouse position.
var _last_pos_glob: Vector2
var _needed_scroll: Vector2  # The scroll amount.
var _last_event: InputEventMouseButton  # Last event to copy properties from.

@onready var _window := get_window()


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS  # Don't stop smooth scroll when paused.


func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		_last_pos = event.position  # Update position if mouse moves.
		_last_pos_glob = event.global_position  # Just in case.
	
	elif event is InputEventMouseButton:
		
		# Only intercept scrolling events.
		if not event.pressed or not event.button_index in \
			[MOUSE_BUTTON_WHEEL_DOWN, MOUSE_BUTTON_WHEEL_UP,
			MOUSE_BUTTON_WHEEL_RIGHT, MOUSE_BUTTON_WHEEL_LEFT]:
				return
		
		# Detect if input doesn't have smooth factor.
		# That is when the factor is a multiple of 1, an integer.
		if roundf(event.factor) == event.factor:
			_last_event = event
			accept_event()
			
			# Calculate the step factor.
			# The event factor can be higher than 1, which has to be taken into account.
			var factor: float = scroll_step * max(event.factor, 1.0)
			
			match event.button_index:
				MOUSE_BUTTON_WHEEL_DOWN:
					_needed_scroll.y += factor
				MOUSE_BUTTON_WHEEL_UP:
					_needed_scroll.y -= factor
				MOUSE_BUTTON_WHEEL_RIGHT:
					_needed_scroll.x += factor
				MOUSE_BUTTON_WHEEL_LEFT:
					_needed_scroll.x -= factor


func _process(delta: float) -> void:
	if _needed_scroll.length_squared() < 0.001:  # Dont always process, to save cpu.
		return
	
	var event := _last_event  # Copy properties of last scroll event.
	
	# Calculate distance to scroll on this frame.
	var dist: Vector2 = _needed_scroll * min(delta * scroll_speed, 0.99)  # Limit to 0.99 to prevent overshoot and infinite feedback on low FPS.
	var abs_dist := dist.abs()
	
	# Determine direction.
	if abs_dist.x < abs_dist.y:  # Vertical scroll.
		
		if dist.y > 0:
			event.button_index = MOUSE_BUTTON_WHEEL_DOWN
			event.button_mask = 0b10000  # Magic mask value found in actual scrollwheel input event.
		else:
			event.button_index = MOUSE_BUTTON_WHEEL_UP
			event.button_mask = 0b01000
		
		_needed_scroll.y -= dist.y  # Decrease needed scroll amount by the amount scrolled.
		event.factor = abs_dist.y
	
	else:  # Horizontal scroll.
		
		if dist.x > 0:
			event.button_index = MOUSE_BUTTON_WHEEL_RIGHT
			event.button_mask = 0b10000  # 16
		else:
			event.button_index = MOUSE_BUTTON_WHEEL_LEFT
			event.button_mask = 0b01000  # 8
		
		_needed_scroll.x -= dist.x
		event.factor = abs_dist.x
	
	# Apply common data to event.
	event.position = _last_pos * _window.content_scale_factor
	event.global_position = _last_pos_glob
	
	# Send fake input event with factor.
	Input.parse_input_event(event)
	
	event = event.duplicate()  # This is the most expensive thing. ( 3/4 of the computation time)
	
	# Disable pressed state.
	event.button_mask = 0
	event.pressed = false
	Input.parse_input_event(event)
