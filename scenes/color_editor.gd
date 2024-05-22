extends Control

@export var color: Color

var ok_color: OKColor
var sliders: Array[ColorSlider]


func _ready() -> void:
    sliders.append(%Hue)
    sliders.append(%Saturation)
    sliders.append(%Lightness)

    %Hue.handle = %HueHandle
    %Saturation.handle = %SaturationHandle
    %Lightness.handle = %LightnessHandle

    ok_color = OKColor.from_rgb(color)
    sliders.map(func(s: ColorSlider): s.color = ok_color)
