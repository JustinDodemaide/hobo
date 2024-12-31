extends PanelContainer

func init(item:Item) -> void:
	if item == null:
		$MarginContainer/TextureRect.texture = null
		return
	$MarginContainer/TextureRect.texture = load(item.image_path())
