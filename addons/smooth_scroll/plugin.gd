@tool
extends EditorPlugin

# Set this to false if you don't want the addon to activate in editor.
var in_editor := true

var _editor_smooth_scroll_node: SmoothScroll


func _enter_tree() -> void:
	add_autoload_singleton("GoodScroll", "smooth_scroll.gd")
	if in_editor:
		_editor_smooth_scroll_node = SmoothScroll.new()
		add_child(_editor_smooth_scroll_node)


func _exit_tree() -> void:
	remove_autoload_singleton("GoodScroll")
	if _editor_smooth_scroll_node != null:
		_editor_smooth_scroll_node.queue_free()
