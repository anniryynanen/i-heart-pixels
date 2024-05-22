class_name ColorSlider
extends Control

enum Type {HUE, SATURATION, LIGHTNESS}

@export var type: Type

var color: OKColor
var handle: ColorSliderHandle


func _draw() -> void:
    var gap: float = minf(size.y, floorf(size.x / 4.0))
    var slices: int = roundi(minf(255, size.x - gap))
    var slices_before:int = roundi(value() * slices)

    # Draw slices
    for i in range(slices):
        var start: float = (size.x - gap) / slices * i
        var end: float = (size.x - gap) / slices * (i + 1)

        # Avoid gaps between slices
        if i < slices - 1:
            end += 1

        if i >= slices_before:
            start += gap
            end += gap

        var slice_color: OKColor = color.opaque()
        var slice_value: float = i / (slices * 1.0)
        match type:
            Type.HUE:
                slice_color.h = slice_value
            Type.SATURATION:
                slice_color.s = slice_value
            Type.LIGHTNESS:
                slice_color.l = slice_value

        draw_rect(Rect2(start, 0, end - start, size.y), slice_color.to_rgb())

    # Draw gap
    var gap_start: float = (size.x - gap) / slices * slices_before
    draw_rect(Rect2(gap_start, 0, gap, size.y), color.opaque().to_rgb())

    # Update handle
    if handle:
        handle.color = color.opaque()
        handle.start = gap_start
        handle.width = gap
        handle.queue_redraw()


func value() -> float:
    match type:
        Type.HUE:
            return color.h
        Type.SATURATION:
            return color.s
        _:
            return color.l
