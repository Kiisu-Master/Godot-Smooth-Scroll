class_name SmoothScrollIgnore extends Control
@onready var parent: Control = get_parent_control()

func _enter_tree():
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	process_mode = Node.PROCESS_MODE_ALWAYS


func _input(event):
	if (is_visible_in_tree() and event is InputEventMouseButton):
		if parent.get_global_rect().has_point(event.global_position):
			if event.button_mask & 2048:
				accept_event()
			if event.button_mask & 4096:
				event.factor = 1.0
