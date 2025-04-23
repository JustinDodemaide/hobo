extends Node3D

@export var item:Item.RESOURCE_CATEGORIES

func _on_interactable_area_interacted(who: Variant) -> void:
	if who is not Player:
		return
	
	var path
	match item:
		Item.RESOURCE_CATEGORIES.FUEL:
			path = "res://Item/ResourceCategories/a/Bread/Bread.gd"
		Item.RESOURCE_CATEGORIES.RATIONS:
			path = "res://Item/ResourceCategories/b/1/b1.gd"
		Item.RESOURCE_CATEGORIES.HYDRATION:
			path = "res://Item/ResourceCategories/c/1/c1.gd"
		Item.RESOURCE_CATEGORIES.MONEY:
			path = "res://Item/ResourceCategories/d/1/d1.gd"
	who.inventory_component.inventory[who.inventory_component.inventory_index] = load(path).new()
