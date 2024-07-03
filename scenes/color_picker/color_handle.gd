class_name ColorHandle
extends Control

signal color_changed(color: OKColor)

@export var color_param: OKColor.Param

var color: OKColor = OKColor.new():
    set(value):
        color = value.duplicate()
        queue_redraw()

var handle_left_: float
var steps_: int
var dragging_: bool
var drag_start_x_: float
var drag_start_value_: int


func _ready() -> void:
    steps_ = OKColor.steps(color_param)
    Globals.focus_lost.connect(func()-> void: if dragging_: stop_dragging_())


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
            stop_dragging_(button)


func _on_button_pressed(button: InputEventMouseButton) -> void:
    var value: int = color.get_param_in_steps(color_param)

    match button.button_index:
        MOUSE_BUTTON_LEFT:
            start_dragging_(button.position)

        MOUSE_BUTTON_WHEEL_UP:
            if value < steps_:
                color.set_param_in_steps(color_param, value + 1)
                color_changed.emit(color)

        MOUSE_BUTTON_WHEEL_DOWN:
            if value > 0:
                color.set_param_in_steps(color_param, value - 1)
                color_changed.emit(color)


func _on_motion_event(motion: InputEventMouseMotion) -> void:
    if dragging_:
        var full_dist: float = size.x - ColorHandle.get_handle_size(size).x
        var moved: int = roundi((motion.position.x - drag_start_x_) / full_dist * steps_)
        var new_value: int = clampi(drag_start_value_ + moved, 0, steps_)

        if new_value != color.get_param_in_steps(color_param):
            color.set_param_in_steps(color_param, new_value)
            color_changed.emit(color)


func start_dragging_(mouse_pos: Vector2) -> void:
    dragging_ = true
    drag_start_x_ = mouse_pos.x
    drag_start_value_ = color.get_param_in_steps(color_param)


func stop_dragging_(button: InputEventMouseButton = null) -> void:
    if dragging_ and button:
        var handle_width: float = ColorHandle.get_handle_size(size).x
        var full_dist: float = size.x - handle_width
        var moved: int = roundi((button.position.x - drag_start_x_) / full_dist * steps_)
        var deadzone: int = roundi(2.0 * Globals.app_scale)

        if absf(moved) < deadzone:
            var value: int = color.get_param_in_steps(color_param)

            var diff: float = 0.0
            if button.position.x < handle_left_:
                diff = button.position.x - handle_left_
            elif button.position.x > handle_left_ + handle_width:
                diff = button.position.x - handle_left_ - handle_width

            moved = roundi(diff / full_dist * steps_)
            var new_value: int = clampi(value + moved, 0, steps_)

            if new_value != value:
                color.set_param_in_steps(color_param, new_value)
                color_changed.emit(color)

    dragging_ = false


func set_handle_left(offset: float) -> void:
    handle_left_ = offset
    queue_redraw()


static func get_handle_size(area_size: Vector2) -> Vector2:
    return Vector2(32.0 * Globals.app_scale, 0.9 * area_size.y)


func _draw() -> void:
    var handle_size: Vector2 = ColorHandle.get_handle_size(size)
    var handle_top: float = (size.y - handle_size.y) / 2.0
    draw_rect(Rect2(handle_left_, handle_top, handle_size.x, handle_size.y), color.to_rgb())

    %ValueAnchor.anchor_left = (handle_left_ + handle_size.x / 2) / size.x
    %ValueAnchor.anchor_right = %ValueAnchor.anchor_left
    %ValueAnchor.anchor_bottom = (handle_top + handle_size.y) / size.y

    %Value.text = String.num(color.get_param_in_steps(color_param))
    %Value.add_theme_color_override("font_color", IHPColorPicker.get_text_color(color).to_rgb())
