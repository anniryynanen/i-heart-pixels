class_name ScalableControl
extends Control

var orig_min_size: Vector2


func _ready() -> void:
    orig_min_size = custom_minimum_size
    Signals.app_scale_changed.connect(_on_app_scale_changed)


func _on_app_scale_changed(app_scale: float) -> void:
    custom_minimum_size = app_scale * orig_min_size
