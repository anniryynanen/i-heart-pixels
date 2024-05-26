extends ScalableControl

signal color_changed(color: OKColor)

@export var rgb_color: Color

var color: OKColor
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
