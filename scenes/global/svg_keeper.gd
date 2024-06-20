extends Node

const JSON_PATH = "res://icons/svg-txt.json"

var svgs_: Dictionary


func _init() -> void:
    var json: String = FileAccess.get_file_as_string(JSON_PATH)
    if json:
        var variant = JSON.parse_string(json)
        if variant:
            svgs_ = variant as Dictionary


func get_svg_(path: String) -> String:
    return svgs_[path]


func set_svg_(path: String, text: String) -> void:
    svgs_[path] = text
    $SaveTimer.start()


func save_json_() -> void:
    var file = FileAccess.open(JSON_PATH, FileAccess.WRITE)
    file.store_string(JSON.stringify(svgs_))
