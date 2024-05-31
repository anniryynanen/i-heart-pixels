class_name ColorHandle
extends Control

signal color_changed(color: OKColor)

@export var color_param: OKColor.Param

var color: OKColor = OKColor.new():
    set(value):
        color = value.duplicate()
        queue_redraw()

var handle_left: float:
    set(value):
        handle_left = value
        queue_redraw()

var steps: int
var handle_area: Rect2

var dragging: bool
var drag_start_x: float
var drag_start_value: int


func _ready() -> void:
    steps = OKColor.steps(color_param)
    Globals.focus_lost.connect(func(): if dragging: stop_dragging())


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
    var value: int = color.get_param_in_steps(color_param)
    var left: float = handle_area.position.x
    var width: float = handle_area.size.x

    match button.button_index:
        MOUSE_BUTTON_LEFT:
            if handle_area.has_point(button.position):
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
                    color.set_param_in_steps(color_param, new_value)
                    color_changed.emit(color)

        MOUSE_BUTTON_WHEEL_UP:
            if value < steps:
                color.set_param_in_steps(color_param, value + 1)
                color_changed.emit(color)

        MOUSE_BUTTON_WHEEL_DOWN:
            if value > 0:
                color.set_param_in_steps(color_param, value - 1)
                color_changed.emit(color)


func _on_motion_event(motion: InputEventMouseMotion) -> void:
    if dragging:
        var full_dist: float = size.x - handle_area.size.x
        var moved: int = roundi((motion.position.x - drag_start_x) / full_dist * steps)
        var new_value: int = clampi(drag_start_value + moved, 0, steps)

        if new_value != color.get_param_in_steps(color_param):
            color.set_param_in_steps(color_param, new_value)
            color_changed.emit(color)


func start_dragging(mouse_pos: Vector2) -> void:
    dragging = true
    drag_start_x = mouse_pos.x
    drag_start_value = color.get_param_in_steps(color_param)


func stop_dragging() -> void:
    dragging = false


func set_handle_left(offset: float) -> void:
    handle_left = offset


static func get_handle_size(area_size: Vector2) -> Vector2:
    var height: float = 0.9 * area_size.y
    return Vector2(minf(height, floorf(area_size.x / 4.0)), height)


func _draw() -> void:
    var handle_size: Vector2 = ColorHandle.get_handle_size(size)

    var line_width: int = 1
    if handle_size.x / Globals.app_scale > 50:
        line_width = 2
    line_width = roundi(line_width * Globals.app_scale)

    var handle_top: float = (size.y - handle_size.y) / 2.0
    handle_area = Rect2(handle_left, handle_top, handle_size.x, handle_size.y)

    var line_area: Rect2 = Rect2(
        handle_left + line_width / 2.0,
        handle_top + line_width / 2.0,
        handle_size.x - line_width,
        handle_size.y - line_width)

    draw_rect(handle_area, color.to_rgb())
    draw_rect(line_area, ColorEditor.get_line_color(color).to_rgb(), false, line_width)

    %ValueAnchor.anchor_left = (handle_left + handle_size.x - line_width) / size.x
    %ValueAnchor.anchor_right = %ValueAnchor.anchor_left
    %ValueAnchor.anchor_bottom = (handle_top + handle_size.y - line_width / 2.0) / size.y

    %Value.text = String.num(color.get_param_in_steps(color_param))
    %Value.add_theme_color_override("font_color", ColorEditor.get_text_color(color).to_rgb())
