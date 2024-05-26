extends HBoxContainer

var settings_applied = false


func _enter_tree() -> void:
    Settings.load()

    if not Settings.has_value("app", "scale"):
        Settings.set_value("app", "scale", 1.0)


func _ready() -> void:
    apply_settings()

    %Canvas.set_color(%ColorEditor.color)


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
