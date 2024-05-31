class_name ColorEditor
extends Control

signal color_changed(color: OKColor)

var color: OKColor = OKColor.new():
    set(value):
        color = value.duplicate()
        color.a = 1.0 # ColorEditor only deals with opaque colors

        strips.map(func(s): s.color = color)
        handles.map(func(h): h.color = color)

var strips: Array[ColorStrip]
var handles: Array[ColorHandle]


func _ready() -> void:
    strips.append(%HueStrip)
    strips.append(%SaturationStrip)
    strips.append(%LightnessStrip)

    handles.append(%HueHandle)
    handles.append(%SaturationHandle)
    handles.append(%LightnessHandle)

    handles.map(func(h): h.color_changed.connect(self._on_handle_color_changed))
    Globals.pen_color_changed.connect(_on_pen_color_changed)


func _on_handle_color_changed(handle_color: OKColor) -> void:
    Globals.pen_color = handle_color


func _on_pen_color_changed(pen_color: OKColor) -> void:
    %Color.color = pen_color.to_rgb()


static func get_line_color(bg_color: OKColor) -> OKColor:
    var line_color: OKColor = bg_color.duplicate()
    line_color.s *= 0.8
    line_color.l = 0.14 if bg_color.l > 0.5 else 0.9
    line_color.a = 0.45
    return line_color


static func get_text_color(bg_color: OKColor) -> OKColor:
    var text_color: OKColor = OKColor.new()
    text_color.l = 0.0 if bg_color.l >= 0.5 else 1.0
    text_color.a = 0.8
    return text_color
