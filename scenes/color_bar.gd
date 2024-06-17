class_name ColorBar
extends Button

signal double_clicked

var color: OKColor:
    set(value):
        color = value
        update_()

var selected: bool:
    set(value):
        selected = value
        update_()


func _enter_tree() -> void:
    %Panel.add_theme_stylebox_override("panel", StyleBoxFlat.new())
    update_()


func _gui_input(event: InputEvent) -> void:
    if event is InputEventMouseButton:
        var button: InputEventMouseButton = event as InputEventMouseButton

        if button.button_index == MOUSE_BUTTON_LEFT and button.double_click:
            double_clicked.emit()


func update_() -> void:
    var stylebox: StyleBoxFlat = %Panel.get_theme_stylebox(
        "panel", "PanelContainer") as StyleBoxFlat
    stylebox.bg_color = color.to_rgb()

    if selected:
        var line_color: OKColor = IHPColorPicker.get_line_color(color)
        stylebox.border_color = line_color.to_rgb()

    var light = color.l <= 0.5
    %Asterisk.visible = selected and not light
    %AsteriskLight.visible = selected and light
