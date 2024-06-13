extends Control


func _ready() -> void:
    $ColorPicker.color_changed.connect(func(c): Globals.tool_color = c)

    Globals.tool_color_changed.connect(_on_tool_color_changed)
    Globals.keyboard_layout_changed.connect(_on_keyboard_layout_changed)


func _unhandled_key_input(event: InputEvent) -> void:
    var key: InputEventKey = event as InputEventKey

    if key.pressed and key.physical_keycode == Controls.COLOR_PICKER:
        if not $ColorPicker.visible:
            popup_color_picker_()

        get_viewport().set_input_as_handled()


func _on_tool_color_changed(tool_color: OKColor) -> void:
    %Color.get_theme_stylebox("panel").bg_color = tool_color.to_rgb()
    $ColorPicker.color = tool_color


func _on_keyboard_layout_changed():
    var label: String = Controls.get_key_label(Controls.COLOR_PICKER)
    %Buttons/ColorPicker.tooltip_text = "Color Picker (%s)" % label


func popup_color_picker_() -> void:
    var screen_size: Vector2i = DisplayServer.screen_get_size()
    var popup_position: Vector2i = DisplayServer.mouse_get_position()
    popup_position -= $ColorPicker.size / 2
    popup_position.y += $ColorPicker.size.y * 0.25

    popup_position.x = clampi(popup_position.x, 0, screen_size.x - $ColorPicker.size.x)
    popup_position.y = clampi(popup_position.y, 0, screen_size.y - $ColorPicker.size.y)

    $ColorPicker.position = popup_position
    $ColorPicker.popup()
