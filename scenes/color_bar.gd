extends PanelContainer


func _ready() -> void:
    Globals.pen_color_changed.connect(_on_pen_color_changed)


func _on_pen_color_changed(pen_color: OKColor) -> void:
    var text_color: OKColor = ColorEditor.get_text_color(pen_color)
    text_color.a = 0.96

    %HexColor.text = "#" + pen_color.to_hex()
    %HexColor.add_theme_color_override("font_color", text_color.to_rgb())
    get_theme_stylebox("panel").bg_color = pen_color.to_rgb()

    var bg_color: OKColor
    if text_color.l == 0.0:
        bg_color = OKColor.new(0.0, 0.0, 0.0, 0.2)
        %CopyColor.icon = load("res://icons/phosphor/copy-duotone.svg")
        %PasteColor.icon = load("res://icons/phosphor/clipboard-duotone.svg")
    else:
        bg_color = OKColor.new(0.0, 0.0, 1.0, 0.26)
        %CopyColor.icon = load("res://icons/phosphor/copy-duotone-white.svg")
        %PasteColor.icon = load("res://icons/phosphor/clipboard-duotone-white.svg")

    %CopyColor.get_theme_stylebox("hover").bg_color = bg_color.to_rgb()
    %PasteColor.get_theme_stylebox("hover").bg_color = bg_color.to_rgb()

    bg_color.a *= 1.8
    %CopyColor.get_theme_stylebox("pressed").bg_color = bg_color.to_rgb()
    %PasteColor.get_theme_stylebox("pressed").bg_color = bg_color.to_rgb()


func _on_copy_color_pressed() -> void:
    DisplayServer.clipboard_set("#" + Globals.pen_color.to_hex())


func _on_paste_color_pressed() -> void:
    var text: String = DisplayServer.clipboard_get()

    if text.is_valid_html_color():
        var color: Color = Color(text)
        color.a = 1.0
        Globals.pen_color = OKColor.from_rgb(color)
    else:
        # There might be a lot of text, show longest valid length + 1
        if text.length() > 10:
            text = text.substr(0, 10) + "..."
        OS.alert("Can't paste a color from \"%s\"" % text, Globals.ERROR_TITLE)
