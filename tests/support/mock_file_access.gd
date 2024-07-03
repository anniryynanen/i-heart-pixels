class_name MockFileAccess
extends RefCounted

var contents: Array[Variant]


func get_open_error() -> Error:
    return OK


func store_var(value: Variant) -> void:
    contents.append(value)


func get_var() -> Variant:
    return contents.pop_front()
