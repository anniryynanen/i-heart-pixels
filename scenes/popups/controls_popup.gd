extends ClosingPopup


func _ready() -> void:
    Globals.keyboard_layout_changed.connect(_on_keyboard_layout_changed)


func _on_keyboard_layout_changed() -> void:
    %PenKey.text = Controls.get_key_label(Controls.PEN)
    %SamplerKey.text = "Hold " + Controls.get_key_label(Controls.COLOR_SAMPLER)
    %FillKey.text = Controls.get_key_label(Controls.FILL)
    %PickerKey.text = Controls.get_key_label(Controls.COLOR_PICKER)
    %NextKey.text = Controls.get_key_label(Controls.NEXT_COLOR)
    %PreviousKey.text = Controls.get_key_label(Controls.PREV_COLOR)
    %ReselectKey.text = Controls.get_key_label(Controls.RESELECT_COLOR)
