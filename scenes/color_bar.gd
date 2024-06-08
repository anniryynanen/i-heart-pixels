extends PanelContainer


func _ready() -> void:
    Globals.tool_color_changed.connect(_on_tool_color_changed)


func _on_tool_color_changed(tool_color: OKColor) -> void:
    var text_color: OKColor = ColorEditor.get_text_color(tool_color)
    text_color.a = 0.96

    %HexColor.text = "#" + tool_color.to_hex()
    %HexColor.add_theme_color_override("font_color", text_color.to_rgb())
    get_theme_stylebox("panel").bg_color = tool_color.to_rgb()

    var bg_color: OKColor
    if text_color.l == 0.0:
        bg_color = OKColor.new(0.0, 0.0, 0.0, 0.2)
    else:
        bg_color = OKColor.new(0.0, 0.0, 1.0, 0.26)

    %CopyColor.visible = text_color.l == 0.0
    %PasteColor.visible = text_color.l == 0.0
    %CopyColorWhite.visible = text_color.l == 1.0
    %PasteColorWhite.visible = text_color.l == 1.0

    %CopyColor.get_theme_stylebox("hover").bg_color = bg_color.to_rgb()
    bg_color.a *= 1.8
    %CopyColor.get_theme_stylebox("pressed").bg_color = bg_color.to_rgb()


func _on_copy_color_pressed() -> void:
    DisplayServer.clipboard_set("#" + Globals.tool_color.to_hex())


func _on_paste_color_pressed() -> void:
    var text: String = DisplayServer.clipboard_get()

    if text.is_valid_html_color():
        var color: Color = Color(text)
        color.a = 1.0
        Globals.tool_color = OKColor.from_rgb(color)
    else:
        # There might be a lot of text, show longest valid length + 1
        if text.length() > 10:
            text = text.substr(0, 10) + "..."
        OS.alert("Can't paste a color from \"%s\"" % text, Globals.ERROR_TITLE)
