extends Node

const PATH = "user://settings.cfg"
const ERROR_TITLE = ":("

var file: ConfigFile = ConfigFile.new()


func has_value(section: String, key: String) -> bool:
    return file.has_section_key(section, key)


func set_value(section: String, key: String, value: Variant) -> void:
    file.set_value(section, key, value)


func get_value(section: String, key: String, default: Variant = null) -> Variant:
    return file.get_value(section, key, default)


func load() -> void:
    var err: Error = file.load(PATH)

    if err and err != ERR_FILE_NOT_FOUND:
        OS.alert("Couldn't load settings from %s (%s)" %
            [ProjectSettings.globalize_path(PATH), error_string(err)], ERROR_TITLE)


func queue_save() -> void:
    $SaveTimer.stop()
    $SaveTimer.start()


func save() -> void:
    var err: Error = file.save(PATH)

    if err:
        OS.alert("Couldn't save settings in %s (%s)" %
            [ProjectSettings.globalize_path(PATH), error_string(err)], ERROR_TITLE)
