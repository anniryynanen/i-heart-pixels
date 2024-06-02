extends Node

signal image_changed(image: IHP)
signal pen_color_changed(pen_color: OKColor)
signal app_scale_changed(app_scale: float)
signal focus_lost

const ERROR_TITLE = ":("

var image: IHP = IHP.new(Vector2i(16, 16)):
    set(value):
        image = value
        image_changed.emit(image)

var current_path: String

var pen_color: OKColor:
    set(value):
        pen_color = value
        Settings.set_value("pen", "color", pen_color)
        pen_color_changed.emit(pen_color)

var app_scale: float:
    set(value):
        app_scale = value
        Settings.set_value("app", "scale", app_scale)
        app_scale_changed.emit(app_scale)


func _notification(what: int) -> void:
    if what == NOTIFICATION_APPLICATION_FOCUS_OUT:
        focus_lost.emit()


func apply_settings() -> void:
    pen_color = Settings.get_value("pen", "color")
    app_scale = Settings.get_value("app", "scale")
