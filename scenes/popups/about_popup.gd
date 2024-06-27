extends ClosingPopup


func _ready() -> void:
    %IHPLabel.text = %IHPLabel.text \
        .replace("APP", ProjectSettings.get_setting("application/config/name")) \
        .replace("VERSION", "v" + ProjectSettings.get_setting("application/config/version"))
    %GitHub.url = Globals.GITHUB_URL

    %GodotLabel.text = Engine.get_license_text()
    $GodotPopup.reset_size()
