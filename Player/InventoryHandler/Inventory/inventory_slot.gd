extends ColorRect

const ACTIVE_COLOR:Color = Color(0.78,0.863,0.816)
const DEACTIVE_COLOR:Color = Color(0.18,0.133,0.184)

func init(item:Item) -> void:
	if item == null:
		$MarginContainer/TextureRect.texture = null
		return
	$MarginContainer/TextureRect.texture = load(item.image_path())

func activate():
	color = ACTIVE_COLOR

func deactivate():
	color = DEACTIVE_COLOR
