extends ScalableControl

@export var color: Color

var ok_color: OKColor
var sliders: Array[ColorSlider]


func _ready() -> void:
    super._ready()

    sliders.append(%Hue)
    sliders.append(%Saturation)
    sliders.append(%Lightness)

    %Hue.handle = %HueHandle
    %Saturation.handle = %SaturationHandle
    %Lightness.handle = %LightnessHandle

    ok_color = OKColor.from_rgb(color).rounded()
    sliders.map(func(s: ColorSlider): s.color = ok_color)


func _on_hue_handle_value_changed() -> void:
    ok_color.h = %HueHandle.value / 255.0
    _on_ok_color_changed()


func _on_saturation_handle_value_changed() -> void:
    ok_color.s = %SaturationHandle.value / 100.0
    _on_ok_color_changed()


func _on_lightness_handle_value_changed() -> void:
    ok_color.l = %LightnessHandle.value / 100.0
    _on_ok_color_changed()


func _on_ok_color_changed() -> void:
    color = Color.from_ok_hsl(ok_color.h, ok_color.s, ok_color.l, ok_color.a)
    sliders.map(func(s: ColorSlider):
        s.color = ok_color
        s.queue_redraw()
    )
