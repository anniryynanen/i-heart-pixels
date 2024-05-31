extends Control

var settings_applied = false

enum ViewMenu {
    APP_SCALE = 0
}


func _enter_tree() -> void:
    Settings.load()
    set_default_settings()


func _ready() -> void:
    %ColorEditor.color_changed.connect(func(c): Globals.pen_color = c)

    Globals.app_scale_changed.connect(_on_app_scale_changed)
    Globals.pen_color_changed.connect(_on_pen_color_changed)

    apply_settings()


func _notification(what: int) -> void:
    # The app is quitting
    if what == NOTIFICATION_WM_CLOSE_REQUEST:
        if get_window().mode == Window.Mode.MODE_WINDOWED:
            Settings.set_value("window", "x", get_window().position.x)
            Settings.set_value("window", "y", get_window().position.y)

        Settings.save()
        get_tree().quit()


func _on_resized() -> void:
    if not settings_applied:
        return

    if get_window().mode == Window.Mode.MODE_WINDOWED:
        Settings.set_value("window", "x", get_window().position.x)
        Settings.set_value("window", "y", get_window().position.y)
        Settings.set_value("window", "width", get_window().size.x)
        Settings.set_value("window", "height", get_window().size.y)

    Settings.set_value("window", "mode", get_window().mode)


func _on_app_scale_changed(app_scale: float) -> void:
    %MainSplit.split_offset = roundi(
        -Settings.get_value("panels", "right_width") * Globals.app_scale)


func _on_view_menu_id_pressed(id: int) -> void:
    match id:
        ViewMenu.APP_SCALE:
            %AppScalePopup.popup_centered()


func _on_main_split_dragged(offset: int) -> void:
    Settings.set_value("panels", "right_width", roundi(-offset / Globals.app_scale))


func _on_pen_color_changed(pen_color: OKColor) -> void:
    %ColorEditor.color = pen_color

    var style_box: StyleBoxTexture = %Gradient.get_theme_stylebox("panel") as StyleBoxTexture
    var texture: GradientTexture1D = style_box.texture as GradientTexture1D
    texture.gradient.set_color(1, pen_color.to_rgb())


func set_default_settings() -> void:
    Settings.set_if_missing("app", "scale", 1.0)
    Settings.set_if_missing("panels", "right_width", 400.0)
    Settings.set_if_missing("pen", "color", OKColor.new(155.0 / 359.0, 0.77, 0.68))


func apply_settings() -> void:
    if Settings.has_value("window", "width"):
        get_window().size.x = Settings.get_value("window", "width")
        get_window().size.y = Settings.get_value("window", "height")

    if Settings.has_value("window", "x"):
        get_window().position.x = Settings.get_value("window", "x")
        get_window().position.y = Settings.get_value("window", "y")

    get_window().mode = Settings.get_value("window", "mode", Window.Mode.MODE_MAXIMIZED)

    %MainSplit.split_offset = -Settings.get_value("panels", "right_width")

    Globals.apply_settings()
    settings_applied = true
    AppScale.start.call_deferred()
