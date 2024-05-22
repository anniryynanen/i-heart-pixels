class_name ColorSliderHandle
extends Control

# The handle is a separate node because they need to be on top of all the sliders

const L_OFFSET = 0.37
const S_MULT = 0.5
const LINE_WIDTH = 2

var color: OKColor
var start: float
var width: float


func _draw() -> void:
    if not color:
        return

    var line_color: OKColor = color.duplicate()
    if color.l < 0.5:
        line_color.l += L_OFFSET
    else:
        line_color.l -= L_OFFSET
    line_color.s *= S_MULT

    draw_rect(Rect2(start, (size.y - width) / 2, width, size.y - (size.y - width)),
        line_color.to_rgb(), false, LINE_WIDTH)
