extends ClosingPopup


func _ready() -> void:
    Globals.keyboard_layout_changed.connect(_on_keyboard_layout_changed)


func _on_keyboard_layout_changed() -> void:
    %PenControl.text = Controls.get_key_label(Controls.PEN)
    %SamplerControl.text = "Hold " + Controls.get_key_label(Controls.COLOR_SAMPLER)
    %FillControl.text = Controls.get_key_label(Controls.FILL)
    %PickerControl.text = Controls.get_key_label(Controls.COLOR_PICKER)
    %NextControl.text = Controls.get_key_label(Controls.NEXT_COLOR)
    %PreviousControl.text = Controls.get_key_label(Controls.PREV_COLOR)
    %ReselectControl.text = Controls.get_key_label(Controls.RESELECT_COLOR)
