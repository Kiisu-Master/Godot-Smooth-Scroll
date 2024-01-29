## A node that intercepts scrolling events and turns them into smoothed scroll events.
## (Works only on one window at a time. Should be manually added to sub-windows.)
class_name SmoothScroll extends Control


## The higher the scroll speed, the faster scrolling will happen.
var scroll_speed: float = 20.0
## How much to jump forward. The actual default would be 1.
var scroll_step: float = .5

var _last_pos: Vector2  # The last known mouse position.
var _last_pos_glob: Vector2
var _needed_scroll: Vector2  # The scroll amount.
var _last_event: InputEventMouseButton  # Last event to copy properties from.


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS  # Don't stop smooth scroll when paused.


func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		_last_pos = event.position  # Update position if mouse moves.
		_last_pos_glob = event.global_position  # Just in case.
	
	
	elif event is InputEventMouseButton:
		
		# Only intercept scrolling events.
		if not event.button_index in \
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
	if _needed_scroll.length_squared() < 0.01:  # Dont always process, to save cpu.
		return
	
	var event := _last_event.duplicate()  # Copy properties of last scroll event.
	
	# Calculate distance to scroll on this frame.
	var dist_y: float = abs(_needed_scroll.y * delta * scroll_speed)
	var dist_x: float = abs(_needed_scroll.x * delta * scroll_speed)
	
	# Determine direction.
	if dist_y > dist_x:  # Vertical scroll.
		if _needed_scroll.y > 0:
			event.button_index = MOUSE_BUTTON_WHEEL_DOWN
			event.button_mask = 16  # Magic mask value found in actual scrollwheel input event.
			_needed_scroll.y -= dist_y  # Decrease needed scroll amount by the amount scrolled.
			_needed_scroll.y = max(_needed_scroll.y, 0)  # Prevent overshoot on low framerate.
		elif _needed_scroll.y < 0:
			event.button_index = MOUSE_BUTTON_WHEEL_UP
			event.button_mask = 8
			_needed_scroll.y += dist_y
			_needed_scroll.y = min(_needed_scroll.y, 0)
		event.factor = dist_y
	else:  # Horizontal scroll.
		if _needed_scroll.x > 0:
			event.button_index = MOUSE_BUTTON_WHEEL_RIGHT
			event.button_mask = 16
			_needed_scroll.x -= dist_x
			_needed_scroll.x = max(_needed_scroll.x, 0)
		elif _needed_scroll.x < 0:
			event.button_index = MOUSE_BUTTON_WHEEL_LEFT
			event.button_mask = 8
			_needed_scroll.x += dist_x
			_needed_scroll.x = min(_needed_scroll.x, 0)
		event.factor = dist_x
	
	# Apply common data to event.
	event.position = _last_pos
	event.global_position = _last_pos_glob
	event.pressed = true
	
	# Send fake input event with factor.
	Input.parse_input_event(event)
	
	# Disable pressed state.
	event = event.duplicate()
	event.button_mask = 0
	event.pressed = false
	Input.parse_input_event(event)
