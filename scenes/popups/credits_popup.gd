extends ClosingPopup


func _ready() -> void:
    %GodotLabel.text = Engine.get_license_text()
    $GodotPopup.reset_size()
