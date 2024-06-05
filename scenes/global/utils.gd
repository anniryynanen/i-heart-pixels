class_name Utils


static func reverse_children(node: Node) -> void:
    for child: Node in node.get_children(true):
        node.move_child(child, 0)
