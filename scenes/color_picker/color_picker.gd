class_name IHPColorPicker
extends Window

signal color_changed(color: OKColor)

var color: OKColor = OKColor.new():
    set(value):
        color = value.duplicate()
        color.a = 1.0 # Color picker only deals with opaque colors

        strips_.map(func(s): s.color = color)
        handles_.map(func(h): h.color = color)

var strips_: Array[ColorStrip]
var handles_: Array[ColorHandle]


func _ready() -> void:
    strips_.append(%HueStrip)
    strips_.append(%SaturationStrip)
    strips_.append(%LightnessStrip)

    handles_.append(%HueHandle)
    handles_.append(%SaturationHandle)
    handles_.append(%LightnessHandle)

    handles_.map(func(h): h.color_changed.connect(self._on_handle_color_changed))
    Globals.tool_color_changed.connect(_on_tool_color_changed)


func _unhandled_key_input(event: InputEvent) -> void:
    var key: InputEventKey = event as InputEventKey

    if key.pressed and key.physical_keycode == Controls.COLOR_PICKER:
        hide()
        get_viewport().set_input_as_handled()


func _on_handle_color_changed(handle_color: OKColor) -> void:
    color_changed.emit(handle_color)


func _on_tool_color_changed(tool_color: OKColor) -> void:
    %Color.color = tool_color.to_rgb()


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
