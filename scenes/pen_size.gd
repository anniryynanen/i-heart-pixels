extends VBoxContainer


func _ready() -> void:
    Globals.pen_size_changed.connect(update_label_)

    await Globals.pen_size_changed
    %Slider.set_value_no_signal(Globals.pen_size)


func _gui_input(event: InputEvent) -> void:
    if event is InputEventMouseButton and event.is_pressed():
        var button: InputEventMouseButton = event as InputEventMouseButton

        match button.button_index:
            MOUSE_BUTTON_WHEEL_UP:
                %Slider.value += %Slider.step

            MOUSE_BUTTON_WHEEL_DOWN:
                %Slider.value -= %Slider.step


func _on_slider_value_changed(value: float) -> void:
    Globals.pen_size = roundi(value)


func update_label_(pen_size: int) -> void:
    %Label.text = "Pen Size: %s" % pen_size
