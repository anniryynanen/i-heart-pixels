extends Window

signal save
signal quit


func _on_save_pressed() -> void:
    hide()
    save.emit()


func _on_quit_pressed() -> void:
    hide()
    quit.emit()
