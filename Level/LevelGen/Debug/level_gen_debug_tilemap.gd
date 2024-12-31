extends TileMapLayer

const rectangle:Vector2i = Vector2i(26,0)
const possible:Vector2i = Vector2i(31,0)
const road:Vector2i = Vector2i(34,0)

func place(where:Vector2i,what:Vector2i) -> void:
	#set_cell(coords: Vector2i, source_id: int = -1, atlas_coords: Vector2i = Vector2i(-1, -1), alternative_tile: int = 0)
	set_cell(where,0,what)
