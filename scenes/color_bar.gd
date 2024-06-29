class_name ColorBar
extends Button

signal drag_hovered(above: bool)

var color: OKColor:
    set(value):
        color = value
        update_()

var selected: bool:
    set(value):
        selected = value
        update_()

var highlighted: bool:
    set(value):
        highlighted = value

        if highlighted:
            var border_color: OKColor = OKColor.new()
            border_color.l = 0.2 if color.is_light() else 0.8

            stylebox.border_color = border_color.to_rgb()
            stylebox.border_width_left = roundi(3.0 * Globals.app_scale)
            stylebox.border_width_right = stylebox.border_width_left
        else:
            stylebox.set_border_width_all(0)

var stylebox: StyleBoxFlat


func _enter_tree() -> void:
    stylebox = StyleBoxFlat.new()
    %Panel.add_theme_stylebox_override("panel", stylebox)
    update_()


func _get_drag_data(_at_position: Vector2) -> Variant:
    return self


func _can_drop_data(at_position: Vector2, data: Variant) -> bool:
    if data is ColorBar:
        drag_hovered.emit(at_position.y < size.y / 2.0)
        return true

    return false


func update_() -> void:
    if not is_inside_tree():
        return

    stylebox.bg_color = color.to_rgb()

    %Asterisk.visible = selected and color.is_light()
    %AsteriskLight.visible = selected and not color.is_light()
