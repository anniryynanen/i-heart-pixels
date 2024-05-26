class_name ColorSliderHandle
extends Control

signal value_changed

var color: OKColor
var value: int
var steps: int

var top: float
var left: float
var width: float
var height: float
var area: Rect2

var dragging: bool
var drag_start_x: float
var drag_start_value: int


func _ready() -> void:
    # Each handle has its own label settings, so that they can be colored
    # independently
    %Value.label_settings = %Value.label_settings.duplicate()

    Signals.focus_lost.connect(func(): if dragging: stop_dragging())


func _gui_input(event: InputEvent) -> void:
    if event is InputEventMouseButton:
        _on_button_event(event as InputEventMouseButton)

    elif event is InputEventMouseMotion:
        _on_motion_event(event as InputEventMouseMotion)


func _on_button_event(button: InputEventMouseButton) -> void:
    if button.pressed:
        _on_button_pressed(button)
    else:
        if button.button_index == MOUSE_BUTTON_LEFT:
            stop_dragging()


func _on_button_pressed(button: InputEventMouseButton) -> void:
    match button.button_index:
        MOUSE_BUTTON_LEFT:
            if area.has_point(button.position):
                start_dragging(button.position)
            else:
                var diff: float = 0.0
                if button.position.x < left:
                    diff = button.position.x - left
                elif button.position.x > left + width:
                    diff = button.position.x - left - width

                var full_dist: float = size.x - width
                var moved: int = roundi(diff / full_dist * steps)
                var new_value: int = clampi(value + moved, 0, steps)

                if new_value != value:
                    value = new_value
                    value_changed.emit()

        MOUSE_BUTTON_WHEEL_UP:
            if value < steps:
                value += 1
                value_changed.emit()

        MOUSE_BUTTON_WHEEL_DOWN:
            if value > 0:
                value -= 1
                value_changed.emit()


func _on_motion_event(motion: InputEventMouseMotion) -> void:
    if dragging:
        var full_dist: float = size.x - width
        var moved: int = roundi((motion.position.x - drag_start_x) / full_dist * steps)
        var new_value: int = clampi(drag_start_value + moved, 0, steps)

        if new_value != value:
            value = new_value
            value_changed.emit()


func start_dragging(mouse_pos: Vector2) -> void:
    dragging = true
    drag_start_x = mouse_pos.x
    drag_start_value = value


func stop_dragging() -> void:
    dragging = false


func _draw() -> void:
    if not color:
        return

    var line_color: OKColor = color.duplicate()
    line_color.l = 0.11 if color.l > 0.5 else 0.89
    line_color.s /= 2.0
    %Value.label_settings.font_color = line_color.to_rgb()

    line_color.l = 0.22 if color.l > 0.5 else 0.78
    var line_width: int = 1
    var global_width: float = width / Settings.get_app_scale()
    if global_width > 50:
        line_color.l = 0.33 if color.l > 0.5 else 0.67
        line_width = 2

    top = (size.y - height) / 2
    area = Rect2(left, top, width, height)

    draw_rect(area, color.to_rgb())
    draw_rect(area, line_color.to_rgb(), false, line_width)

    %ValueAnchor.anchor_left = (left + width - line_width) / size.x
    %ValueAnchor.anchor_right = %ValueAnchor.anchor_left
    %ValueAnchor.anchor_bottom = (top + height - line_width / 2.0) / size.y
    %Value.text = String.num(value)
