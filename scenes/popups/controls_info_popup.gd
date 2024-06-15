extends ClosingPopup


func _ready() -> void:
    %PanLabel.text = "[b]Pan[/b] the canvas: Drag with middle mouse button"
    %ZoomLabel.text = "[b]Zoom[/b] the canvas: Scroll with mouse wheel"

    Globals.keyboard_layout_changed.connect(_on_keyboard_layout_changed)


func _on_keyboard_layout_changed() -> void:
    %PenAndEraserLabel.text = \
        "Select [b]pen[/b] or switch between [b]pen[/b] and [b]eraser:[/b] " + \
        Controls.get_key_label(Controls.PEN)

    %ColorSamplerLabel.text = "Activate [b]color sampler:[/b] Hold down " + \
        Controls.get_key_label(Controls.COLOR_SAMPLER).to_upper()

    %ColorPickerLabel.text = "Open [b]color picker:[/b] " + \
        Controls.get_key_label(Controls.COLOR_PICKER)
