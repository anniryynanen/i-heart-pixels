class_name Main
extends Control

const ERROR_TITLE = ":("

var settings_applied = false


func _enter_tree() -> void:
    Settings.load()

    if not Settings.has_value("app", "scale"):
        Settings.set_value("app", "scale", 1.0)


func _ready() -> void:
    apply_settings()

    %Canvas.set_color(%ColorEditor.color)
    _on_color_editor_color_changed(%ColorEditor.color)


func _on_resized() -> void:
    if not settings_applied:
        return

    if get_window().mode == Window.Mode.MODE_WINDOWED:
        Settings.set_value("window", "x", get_window().position.x)
        Settings.set_value("window", "y", get_window().position.y)
        Settings.set_value("window", "width", get_window().size.x)
        Settings.set_value("window", "height", get_window().size.y)
    Settings.set_value("window", "mode", get_window().mode)
    Settings.queue_save()


func _notification(what: int) -> void:
    # The app is quitting
    if what == NOTIFICATION_WM_CLOSE_REQUEST:
        if get_window().mode == Window.Mode.MODE_WINDOWED:
            Settings.set_value("window", "x", get_window().position.x)
            Settings.set_value("window", "y", get_window().position.y)
            Settings.save()
        get_tree().quit()


func apply_settings() -> void:
    Signals.app_scale_changed.emit(Settings.get_app_scale())

    if Settings.has_value("window", "width"):
        get_window().size.x = Settings.get_value("window", "width")
        get_window().size.y = Settings.get_value("window", "height")

    if Settings.has_value("window", "x"):
        get_window().position.x = Settings.get_value("window", "x")
        get_window().position.y = Settings.get_value("window", "y")

    get_window().mode = Settings.get_value("window", "mode", Window.Mode.MODE_MAXIMIZED)

    settings_applied = true


func _on_color_editor_color_changed(color: OKColor) -> void:
    var text_color = ColorEditor.get_text_color(color)
    text_color.a = 0.96

    %HexColor.text = "#" + color.to_hex()
    %HexColor.add_theme_color_override("font_color", text_color.to_rgb())
    %ColorValueContainer.get_theme_stylebox("panel").bg_color = color.to_rgb()

    var style_box: StyleBoxTexture = %Gradient.get_theme_stylebox("panel") as StyleBoxTexture
    var texture: GradientTexture1D = style_box.texture as GradientTexture1D
    texture.gradient.set_color(1, color.to_rgb())

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
    DisplayServer.clipboard_set("#" + %ColorEditor.color.to_hex())


func _on_paste_color_pressed() -> void:
    var text: String = DisplayServer.clipboard_get()

    if text.is_valid_html_color():
        var color: Color = Color(text)
        color.a = 1.0
        %ColorEditor.color = OKColor.from_rgb(color)
    else:
        # There might be a lot of text, show longest valid length + 1
        if text.length() > 10:
            text = text.substr(0, 10) + "..."
        OS.alert("Can't paste a color from %s" % text, ERROR_TITLE)

