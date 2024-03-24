# Usage
Add the `SmoothScroll` node to all windows that need smooth scrolling. The node works only on one window at a time and does not work on embedded windows. If some specific `Control` shoudln't be smooth scrolling, add the `SmoothScrollIgnore` node to it.

Enabling the addon will automatically add a `SmoothScroll` node as an autoload and add smooth scrolling to the godot editor.
# Explanation
This addon enables smooth scrolling by interecpting non-smooth scroll events and turning them into smooth ones.
This is done with the `_input()` callback, `accept_event()` and `Input.parse_input_event()`.

If it receives a `InputEventMouseButton` in `_input`, it will check if it has a (smooth) factor.
If it doesn't, it will set its factor to 0 to prevent it from being used in normal `Control` nodes. 
Then it will record the events scroll amount in a variable `_needed_scroll`, to then later split the needed scroll amount up into smaller chunks, which will make scrolling smoother.
That is done in `_process()`, in which it will create new `InputEventMouseButton`'s with a modified factor to be parsed.
# Known problems / Limitations
- This will increase the amount of scroll events, which might mess with components that work with single scroll events. To work around this, you can add the `SmoothScrollIgnore` node to the `Control` node that should not receive smoothed scroll events. You can also also check for smoothed scroll events with `event.button_mask & 2048` or disabled (factor 0) scroll events with `event.button_mask & 4096`
- This might not report the correct mouse location if the window is scaled with the viewport expand mode.
- This will not work on embedded windows.