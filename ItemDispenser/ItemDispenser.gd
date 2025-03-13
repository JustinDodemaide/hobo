extends Node3D

@export var item:Item.RESOURCE_CATEGORIES

func _on_interactable_area_interacted(who: Variant) -> void:
	if who is not Player:
		return
	
	var path
	match item:
		Item.RESOURCE_CATEGORIES.A:
			path = "res://Item/ResourceCategories/a/Bread/Bread.gd"
		Item.RESOURCE_CATEGORIES.B:
			path = "res://Item/ResourceCategories/b/1/b1.gd"
		Item.RESOURCE_CATEGORIES.C:
			path = "res://Item/ResourceCategories/c/1/c1.gd"
		Item.RESOURCE_CATEGORIES.D:
			path = "res://Item/ResourceCategories/d/1/d1.gd"
		Item.RESOURCE_CATEGORIES.E:
			path = "res://Item/ResourceCategories/e/1/e1.gd"
	who.inventory_component.inventory[who.inventory_component.inventory_index] = load(path).new()
