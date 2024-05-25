class_name ScalableLabel
extends Label

var orig_font_size: int


func _ready() -> void:
    if not label_settings:
        label_settings = LabelSettings.new()
    orig_font_size = label_settings.font_size

    Signals.app_scale_changed.connect(_on_app_scale_changed)


func _on_app_scale_changed(app_scale: float) -> void:
    label_settings.font_size = roundi(app_scale * orig_font_size)
