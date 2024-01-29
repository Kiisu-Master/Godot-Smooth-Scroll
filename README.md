# Usage
The `SmoothScroll` node should be added to the root window. It will act on all `Control` nodes that are scrollable and make use of the event `factor`.
It might only work on one window at a time.
# Explanation
This addon enables smooth scrolling by interecpting non-smooth scroll events and turning them into smooth ones.
This is done with the `_input()` callback, `accept_event()` and `Input.parse_input_event()`.

If it receives a `InputEventMouseButton` in `_input`, it will check if it has a (smooth) factor.
If it doesn't, it will `accept_event()` to prevent it from being used in `Control` nodes. 
Then it will record the events scroll amount in a variable `_needed_scroll`, to then later split the needed scroll amount up into smaller chunks, which will make scrolling smoother.
That is done in `_process()`, in which it will create new `InputEventMouseButton`'s with a modified factor to be parsed.
# Known problems / Limitations
- This will increase the amount of scroll events, which might mess with components that work with single scroll events.
- This might not report the correct mouse location if the window is scaled with the viewport expand mode.