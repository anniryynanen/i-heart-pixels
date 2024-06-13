extends Control

var picker_key_: Key = KEY_D


func _ready() -> void:
    $ColorPicker.close_key = picker_key_
    $ColorPicker.color_changed.connect(func(c): Globals.tool_color = c)

    Globals.tool_color_changed.connect(_on_tool_color_changed)
    Globals.keyboard_layout_changed.connect(_on_keyboard_layout_changed)


func _unhandled_key_input(event: InputEvent) -> void:
    var key: InputEventKey = event as InputEventKey

    if key.pressed and key.physical_keycode == picker_key_:
        if $ColorPicker.visible:
            $ColorPicker.hide()
        else:
            popup_color_picker_()

        get_viewport().set_input_as_handled()


func _on_tool_color_changed(tool_color: OKColor) -> void:
    %Color.get_theme_stylebox("panel").bg_color = tool_color.to_rgb()
    $ColorPicker.color = tool_color


func _on_keyboard_layout_changed():
    %Buttons/ColorPicker.tooltip_text = "Color Picker (%s)" % \
        OS.get_keycode_string(DisplayServer.keyboard_get_label_from_physical(picker_key_))


func popup_color_picker_() -> void:
    var screen_size: Vector2i = DisplayServer.screen_get_size()
    var popup_position: Vector2i = DisplayServer.mouse_get_position()
    popup_position -= $ColorPicker.size / 2
    popup_position.y += $ColorPicker.size.y * 0.25

    popup_position.x = clampi(popup_position.x, 0, screen_size.x - $ColorPicker.size.x)
    popup_position.y = clampi(popup_position.y, 0, screen_size.y - $ColorPicker.size.y)

    $ColorPicker.position = popup_position
    $ColorPicker.popup()
