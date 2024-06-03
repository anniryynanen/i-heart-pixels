extends Node

signal image_changed(image: IHP)
signal unsaved_changes_changed(unsaved_changes: bool)
signal current_path_changed(current_path: String)

signal pen_color_changed(pen_color: OKColor)
signal app_scale_changed(app_scale: float)
signal focus_lost

const ERROR_TITLE = ":("

var image: IHP:
    set(value):
        if image:
            image.unsaved_changes_changed.disconnect(emit_unsaved_changes_changed_)

        image = value
        image.unsaved_changes_changed.connect(emit_unsaved_changes_changed_)
        image_changed.emit(image)

var current_path: String:
    set(value):
        current_path = value
        current_path_changed.emit(current_path)

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


func _init() -> void:
    image = IHP.new(Vector2i(16, 16))


func _notification(what: int) -> void:
    if what == NOTIFICATION_APPLICATION_FOCUS_OUT:
        focus_lost.emit()


func apply_settings() -> void:
    pen_color = Settings.get_value("pen", "color")
    app_scale = Settings.get_value("app", "scale")


func emit_unsaved_changes_changed_(unsaved_changes: bool) -> void:
    unsaved_changes_changed.emit(unsaved_changes)
