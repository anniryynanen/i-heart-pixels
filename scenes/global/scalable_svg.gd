class_name ScalableSVG
extends RefCounted

var width: int
var height: int
var text: String


func _init(texture: Texture2D):
    self.width = texture.get_width()
    self.height = texture.get_height()

    text = FileAccess.open(texture.resource_path, FileAccess.READ).get_as_text()


func get_texture(scale: float) -> ImageTexture:
    var image: Image = Image.create(
        roundi(width * scale), roundi(height * scale), false, Image.Format.FORMAT_RGBA8)

    image.load_svg_from_string(text, scale)
    return ImageTexture.create_from_image(image)
