extends ClosingPopup

signal save
signal close


func _ready() -> void:
    if DisplayServer.get_name() == "Windows":
        Utils.reverse_children(%Buttons)


func _on_about_to_popup() -> void:
    %Save.grab_focus()


func _on_save_pressed() -> void:
    hide()
    save.emit()


func _on_close_pressed() -> void:
    hide()
    close.emit()
