class_name ColorSlider
extends Control

enum Type {HUE, SATURATION, LIGHTNESS}

static var STEPS = {
    Type.HUE: 255,
    Type.SATURATION: 100,
    Type.LIGHTNESS: 100
}

@export var type: Type

var color: OKColor
var handle: ColorSliderHandle:
    set(value):
        handle = value
        handle.steps = STEPS[type]


func value() -> int:
    match type:
        Type.HUE:
            return roundi(color.h * STEPS[type])
        Type.SATURATION:
            return roundi(color.s * STEPS[type])
        _:
            return roundi(color.l * STEPS[type])


func _draw() -> void:
    handle.height = 0.85 * size.y
    handle.width = minf(handle.height, floorf(size.x / 4.0))
    var slices: int = roundi(minf(255, size.x - handle.width))
    var slices_before:int = roundi(value() / float(STEPS[type]) * slices)

    # Draw slices
    for i in range(slices):
        var start: float = (size.x - handle.width) / slices * i
        var end: float = (size.x - handle.width) / slices * (i + 1)

        # Avoid gaps between slices
        if i < slices - 1:
            end += 1

        if i >= slices_before:
            start += handle.width
            end += handle.width

        var slice_color: OKColor = color.opaque()
        var slice_value: float = i / float(slices)
        match type:
            Type.HUE:
                slice_color.h = slice_value
            Type.SATURATION:
                slice_color.s = slice_value
            Type.LIGHTNESS:
                slice_color.l = slice_value

        draw_rect(Rect2(start, 0, end - start, size.y), slice_color.to_rgb())

    # Draw the area between slices
    handle.left = (size.x - handle.width) / slices * slices_before
    draw_rect(Rect2(handle.left, 0, handle.width, size.y), color.opaque().to_rgb())

    # Update handle
    if handle:
        handle.color = color.opaque()
        handle.value = value()
        handle.queue_redraw()
