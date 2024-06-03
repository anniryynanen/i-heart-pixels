extends Node

const CACHE_PATH = "user://cache.json"

var export_paths_: Dictionary
var save_path_order_: Array[String]


func _ready() -> void:
    load_cache_()


func get_export_path(save_path: String) -> String:
    return export_paths_[save_path]


func set_export_path(save_path: String, export_path: String) -> void:
    if save_path in export_paths_:
        var index: int = save_path_order_.rfind(save_path)
        save_path_order_.pop_at(index)

    elif save_path_order_.size() >= 500:
        var removed = save_path_order_.pop_front()
        export_paths_.erase(removed)

    export_paths_[save_path] = export_path
    save_path_order_.append(save_path)

    save_cache_()


func load_cache_() -> void:
    if not FileAccess.file_exists(CACHE_PATH):
        return

    var text: String = FileAccess.get_file_as_string(CACHE_PATH)
    var err: Error = FileAccess.get_open_error()
    if err:
        push_error("Couldn't load cache from %s (%s)" %
            [ProjectSettings.globalize_path(CACHE_PATH), error_string(err)])
        return

    var dict: Dictionary = JSON.parse_string(text)
    if not dict:
        push_error("Couldn't parse cache loaded from " + CACHE_PATH)
        return

    for tuple in dict["export_paths"]:
        var save_path: String = tuple[0]
        var export_path: String = tuple[1]
        export_paths_[save_path] = export_path
        save_path_order_.append(save_path)


func save_cache_() -> void:
    var file: FileAccess = FileAccess.open(CACHE_PATH, FileAccess.WRITE)
    var err: Error = FileAccess.get_open_error()
    if err:
        push_error("Couldn't save cache in %s (%s)" %
            [ProjectSettings.globalize_path(CACHE_PATH), error_string(err)])
        return

    var dict: Dictionary = {
        "export_paths": []
    }

    for save_path in save_path_order_:
        dict["export_paths"].append([save_path, export_paths_[save_path]])

    file.store_string(JSON.stringify(dict))
