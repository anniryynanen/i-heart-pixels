extends HBoxContainer

var settings_loaded = false


func _ready() -> void:
    load_settings()


func _on_resized() -> void:
    if not settings_loaded:
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


func load_settings() -> void:
    Settings.load()

    if not Settings.has_value("app", "scale"):
        Settings.set_value("app", "scale", 1.0)
    Signals.app_scale_changed.emit(Settings.get_value("app", "scale"))

    if Settings.has_value("window", "x"):
        get_window().position.x = Settings.get_value("window", "x")
        get_window().position.y = Settings.get_value("window", "y")

    if Settings.has_value("window", "width"):
        get_window().size.x = Settings.get_value("window", "width")
        get_window().size.y = Settings.get_value("window", "height")

    if Settings.has_value("window", "mode"):
        get_window().mode = Settings.get_value("window", "mode")

    settings_loaded = true
