extends HBoxContainer

@export var text: String:
    set(value):
        text = value
        %Label.text = text
