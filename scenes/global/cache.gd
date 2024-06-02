extends Node

const CACHE_PATH = "user://cache.json"

var export_paths: Dictionary
var save_path_order: Array[String]


func _ready() -> void:
    load_cache()


func get_export_path(save_path: String) -> String:
    return export_paths[save_path]


func set_export_path(save_path: String, export_path: String) -> void:
    if save_path in export_paths:
        var index: int = save_path_order.rfind(save_path)
        save_path_order.pop_at(index)

    elif save_path_order.size() >= 500:
        var removed = save_path_order.pop_front()
        export_paths.erase(removed)

    export_paths[save_path] = export_path
    save_path_order.append(save_path)

    save_cache()


func load_cache() -> void:
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
        export_paths[save_path] = export_path
        save_path_order.append(save_path)


func save_cache() -> void:
    var file: FileAccess = FileAccess.open(CACHE_PATH, FileAccess.WRITE)
    var err: Error = FileAccess.get_open_error()
    if err:
        push_error("Couldn't save cache in %s (%s)" %
            [ProjectSettings.globalize_path(CACHE_PATH), error_string(err)])
        return

    var dict: Dictionary = {
        "export_paths": []
    }

    for save_path in save_path_order:
        dict["export_paths"].append([save_path, export_paths[save_path]])

    file.store_string(JSON.stringify(dict))
