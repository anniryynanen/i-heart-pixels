extends Control


func _ready() -> void:
    $ColorPicker.color_changed.connect(func(c): Globals.tool_color = c)

    Globals.tool_color_changed.connect(_on_tool_color_changed)
    Globals.keyboard_layout_changed.connect(_on_keyboard_layout_changed)


func _unhandled_key_input(event: InputEvent) -> void:
    var key: InputEventKey = event as InputEventKey

    if key.pressed and key.physical_keycode == Controls.COLOR_PICKER:
        if not $ColorPicker.visible:
            $ColorPicker.popup_color(Globals.tool_color)

        get_viewport().set_input_as_handled()


func _on_color_picker_pressed() -> void:
    $ColorPicker.popup_color(Globals.tool_color)


func _on_tool_color_changed(tool_color: OKColor) -> void:
    %Color.get_theme_stylebox("panel").bg_color = tool_color.to_rgb()


func _on_keyboard_layout_changed():
    var label: String = Controls.get_key_label(Controls.COLOR_PICKER)
    %Buttons/ColorPicker.tooltip_text = "Open color picker (%s)" % label
