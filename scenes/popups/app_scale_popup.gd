extends ClosingPopup
## Minimum app scale is 1.0 because smaller scales break text positioning. The
## text gets smaller, but node size and anchors don't adjust. This could be
## fixed with custom controls.

var dragging_ = false


func _ready() -> void:
    Globals.app_scale_changed.connect(_on_app_scale_changed)


func _on_app_scale_slider_drag_started() -> void:
    dragging_ = true


func _on_app_scale_slider_drag_ended(_value_changed: bool) -> void:
    dragging_ = false

    if %AppScaleSlider.value != Globals.app_scale:
        Globals.app_scale = %AppScaleSlider.value


func _on_app_scale_slider_value_changed(value: float) -> void:
    %AppScaleLabel.text = String.num(value)

    if not dragging_:
        Globals.app_scale = %AppScaleSlider.value


func _on_app_scale_changed(app_scale: float) -> void:
    %AppScaleSlider.set_value_no_signal(app_scale)
    %AppScaleLabel.text = String.num(app_scale)
