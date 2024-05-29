class_name ColorStrip
extends Control

signal handle_left_changed(handle_left: float)

@export var color_param: OKColor.Param

var color: OKColor = OKColor.new():
    set(value):
        color = value.duplicate()
        update_slices()
        queue_redraw()

var steps: int
var handle_left: float
var handle_size: Vector2
var slices: int
var slices_before: int


func _ready() -> void:
    steps = OKColor.steps(color_param)


func _on_resized() -> void:
    update_slices()
    queue_redraw()


func update_slices() -> void:
    handle_size = ColorHandle.get_handle_size(size)
    slices = roundi(minf(steps, size.x - handle_size.x))
    slices_before = roundi(color.get_param_in_steps(color_param) / float(steps) * slices)

    handle_left = (size.x - handle_size.x) / slices * slices_before
    handle_left_changed.emit(handle_left)


func _draw() -> void:
    # Draw slices
    for i in range(slices):
        var start: float = (size.x - handle_size.x) / slices * i
        var end: float = (size.x - handle_size.x) / slices * (i + 1)

        # Avoid gaps between slices
        if i < slices - 1:
            end += 1

        if i >= slices_before:
            start += handle_size.x
            end += handle_size.x

        var slice_color: OKColor = color.duplicate()
        var slice_value: float = i / float(slices)
        match color_param:
            OKColor.Param.HUE:
                slice_color.h = slice_value
            OKColor.Param.SATURATION:
                slice_color.s = slice_value
            OKColor.Param.LIGHTNESS:
                slice_color.l = slice_value

        draw_rect(Rect2(start, 0, end - start, size.y), slice_color.to_rgb())

    # Draw the area between slices
    draw_rect(Rect2(handle_left, 0, handle_size.x, size.y), color.to_rgb())
