class_name AnchorKeeper
extends RefCounted

var control_: Control
var offset_left_: float
var offset_right_: float
var offset_top_: float
var offset_bottom_: float


func _init(control: Control) -> void:
    control_ = control
    offset_right_ = control.offset_right
    offset_left_ = control.offset_left
    offset_top_ = control.offset_top
    offset_bottom_ = control.offset_bottom


func fix() -> void:
    if control_.anchor_left == 1 and control_.anchor_right == 1:
        control_.offset_right = offset_right_ * Globals.app_scale

    if control_.anchor_top == 1 and control_.anchor_bottom == 1:
        control_.offset_bottom = offset_bottom_ * Globals.app_scale
