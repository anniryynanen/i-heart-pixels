class_name ColorStrip
extends Control

signal handle_left_changed(handle_left: float)

@export var color_param: OKColor.Param

var color: OKColor = OKColor.new():
    set(value):
        color = value.duplicate()
        update_slices_()
        queue_redraw()

var steps_: int
var handle_left_: float
var handle_size_: Vector2
var slices_: int
var slices_before_: int


func _ready() -> void:
    steps_ = OKColor.steps(color_param)


func _on_resized() -> void:
    update_slices_()
    queue_redraw()


func update_slices_() -> void:
    handle_size_ = ColorHandle.get_handle_size(size)
    slices_ = roundi(minf(steps_, size.x - handle_size_.x))
    slices_before_ = roundi(color.get_param_in_steps(color_param) / float(steps_) * slices_)

    handle_left_ = (size.x - handle_size_.x) / slices_ * slices_before_
    handle_left_changed.emit(handle_left_)


func _draw() -> void:
    # Draw slices
    for i in range(slices_):
        var start: float = (size.x - handle_size_.x) / slices_ * i
        var end: float = (size.x - handle_size_.x) / slices_ * (i + 1)

        # Avoid gaps between slices
        if i < slices_ - 1:
            end += 1

        if i >= slices_before_:
            start += handle_size_.x
            end += handle_size_.x

        var slice_color: OKColor = color.duplicate()
        var slice_value: float = i / float(slices_)
        match color_param:
            OKColor.Param.HUE:
                slice_color.h = slice_value
            OKColor.Param.SATURATION:
                slice_color.s = slice_value
            OKColor.Param.LIGHTNESS:
                slice_color.l = slice_value

        draw_rect(Rect2(start, 0, end - start, size.y), slice_color.to_rgb())

    # Draw the area between slices
    draw_rect(Rect2(handle_left_, 0, handle_size_.x, size.y), color.to_rgb())
