class_name ColorEditor
extends ScalableControl

signal color_changed(color: OKColor)

@export var rgb_color: Color

var color: OKColor:
    set(value):
        color = value
        sliders.map(func(s: ColorSlider): s.color = color)
        color_changed.emit(color)
var sliders: Array[ColorSlider]


func _ready() -> void:
    super._ready()

    sliders.append(%Hue)
    sliders.append(%Saturation)
    sliders.append(%Lightness)

    %Hue.handle = %HueHandle
    %Saturation.handle = %SaturationHandle
    %Lightness.handle = %LightnessHandle

    color = OKColor.from_rgb(rgb_color).rounded()
    sliders.map(func(s: ColorSlider): s.color = color)


func _on_hue_handle_value_changed() -> void:
    color.h = %HueHandle.value / 255.0
    _on_ok_color_changed()


func _on_saturation_handle_value_changed() -> void:
    color.s = %SaturationHandle.value / 100.0
    _on_ok_color_changed()


func _on_lightness_handle_value_changed() -> void:
    color.l = %LightnessHandle.value / 100.0
    _on_ok_color_changed()


func _on_ok_color_changed() -> void:
    rgb_color = Color.from_ok_hsl(color.h, color.s, color.l, color.a)
    sliders.map(func(s: ColorSlider):
        s.color = color
        s.queue_redraw()
    )
    color_changed.emit(color)


static func get_line_color(bg_color: OKColor) -> OKColor:
    var line_color: OKColor = bg_color.duplicate()
    line_color.l = 0.1 if bg_color.l > 0.5 else 0.9
    if bg_color.l <= 0.5:
        line_color.s *= 0.8
    line_color.a = 0.45
    return line_color


static func get_text_color(bg_color: OKColor) -> OKColor:
    var text_color: OKColor = OKColor.new()
    text_color.l = 0.0 if bg_color.l > 0.5 else 1.0
    text_color.a = 0.8
    return text_color
