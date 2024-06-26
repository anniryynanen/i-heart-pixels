extends ClosingPopup


func _ready() -> void:
    if DisplayServer.get_name() == "Windows":
        Utils.reverse_children(%BottomButtons)


func _on_about_to_popup() -> void:
    %Width.value = Globals.image.size.x
    %Height.value = Globals.image.size.y
    %XOffset.value = 0.0
    %YOffset.value = 0.0

    %Resize.grab_focus()


func _on_align_left_pressed() -> void: %XOffset.value = 0
func _on_align_right_pressed() -> void: %XOffset.value = %Width.value - Globals.image.size.x
func _on_align_top_pressed() -> void: %YOffset.value = 0
func _on_align_bottom_pressed() -> void: %YOffset.value = %Height.value - Globals.image.size.y


func _on_align_center_h_pressed() -> void:
    %XOffset.value = lerp(min_x_offset_(), max_x_offset_(), 0.5)


func _on_align_center_v_pressed() -> void:
    %YOffset.value = lerp(min_y_offset_(), max_y_offset_(), 0.5)


func _on_resize_pressed() -> void:
    await Globals.image.resize_canvas(
        Vector2i(roundi(%Width.value), roundi(%Height.value)),
        Vector2i(roundi(%XOffset.value), roundi(%YOffset.value)))
    Globals.image_changed.emit(Globals.image)
    hide()


func min_x_offset_() -> float: return minf(0, %Width.value - Globals.image.size.x)
func max_x_offset_() -> float: return maxf(0, %Width.value - Globals.image.size.x)
func min_y_offset_() -> float: return minf(0, %Height.value - Globals.image.size.y)
func max_y_offset_() -> float: return maxf(0, %Height.value - Globals.image.size.y)
