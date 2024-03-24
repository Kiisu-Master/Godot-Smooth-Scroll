@tool
extends EditorPlugin

# Set this to false if you don't want the addon to activate in editor.
var in_editor := true

var _editor_nodes: Array[Node]


func _enter_tree() -> void:
	add_autoload_singleton("SmoothScrollEnabler", "smooth_scroll.gd")
	if in_editor:
		new_smooth_scroll(EditorInterface.get_base_control())
		if not EditorInterface.get_editor_settings().get_setting("interface/editor/use_embedded_menu"):
			new_smooth_scroll(get_editor_window("ProjectSettingsEditor"))
			new_smooth_scroll(get_editor_window("EditorSettingsDialog*"))
			new_smooth_scroll(get_editor_window("CreateDialog"))
			new_smooth_scroll(get_editor_window("EditorHelpSearch"))
			new_smooth_scroll(get_editor_window("ProjectExportDialog"))
		else:
			printerr("Failed to enable smooth scroll in editor windows because embedded windows are enabled.")
		new_smooth_scroll_ignore(EditorInterface.get_editor_viewport_2d().get_parent())
		new_smooth_scroll_ignore(EditorInterface.get_editor_viewport_3d().get_parent())


func _exit_tree() -> void:
	remove_autoload_singleton("SmoothScrollEnabler")
	for node in _editor_nodes:
		if node != null:
			node.queue_free()


func new_smooth_scroll(parent: Node) -> void:
	var smooth_scroll := SmoothScroll.new()
	parent.add_child(smooth_scroll)
	_editor_nodes.append(smooth_scroll)


func new_smooth_scroll_ignore(parent: Control) -> void:
	var smooth_ignore := SmoothScrollIgnore.new()
	parent.add_child(smooth_ignore)
	_editor_nodes.append(smooth_ignore)


func get_editor_window(window_name: String):
	return EditorInterface.get_base_control().find_child("@" + window_name + "@*", true, false)
