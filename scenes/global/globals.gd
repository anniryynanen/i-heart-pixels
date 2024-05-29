extends Node

signal focus_lost
signal app_scale_changed(app_scale: float)
signal pen_color_changed(pen_color: OKColor)

const ERROR_TITLE = ":("

var app_scale: float:
    set(value):
        app_scale = value
        Settings.set_value("app", "scale", app_scale)
        app_scale_changed.emit(app_scale)

var pen_color: OKColor:
    set(value):
        pen_color = value
        Settings.set_value("pen", "color", pen_color)
        pen_color_changed.emit(pen_color)


func _notification(what: int) -> void:
    if what == NOTIFICATION_APPLICATION_FOCUS_OUT:
        focus_lost.emit()


func apply_settings() -> void:
    app_scale = Settings.get_value("app", "scale")
    pen_color = Settings.get_value("pen", "color")
