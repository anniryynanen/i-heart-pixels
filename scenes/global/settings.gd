extends Node

const SETTINGS_PATH = "user://settings.cfg"

var file_: ConfigFile = ConfigFile.new()


func load_settings() -> void:
    var err: Error = file_.load(SETTINGS_PATH)

    if err and err != ERR_FILE_NOT_FOUND:
        OS.alert("Couldn't load settings from %s (%s)" %
            [ProjectSettings.globalize_path(SETTINGS_PATH), error_string(err)],
            Globals.ERROR_TITLE)


func save_settings() -> void:
    var err: Error = file_.save(SETTINGS_PATH)
    $SaveTimer.stop()

    if err:
        OS.alert("Couldn't save settings in %s (%s)" %
            [ProjectSettings.globalize_path(SETTINGS_PATH), error_string(err)],
            Globals.ERROR_TITLE)


func has_value(section: String, key: String) -> bool:
    return file_.has_section_key(section, key)


func set_value(section: String, key: String, value: Variant) -> void:
    file_.set_value(section, key, value)
    $SaveTimer.start()


func set_if_missing(section: String, key: String, value: Variant) -> void:
    if not has_value(section, key):
        set_value(section, key, value)


func get_value(section: String, key: String, default: Variant = null) -> Variant:
    return file_.get_value(section, key, default)
