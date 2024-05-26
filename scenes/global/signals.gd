extends Node

signal app_scale_changed(app_scale: float)
signal focus_lost


func _notification(what: int) -> void:
    if what == NOTIFICATION_APPLICATION_FOCUS_OUT:
        focus_lost.emit()
