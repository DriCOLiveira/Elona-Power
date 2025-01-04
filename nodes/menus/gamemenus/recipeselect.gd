extends Control

var d = Mother.json_file_copy("res://data/items_data.json")
var sd = {}

func set_item(recipe_data):
	$label.text = recipe_data["Recipe Name"]
	$icon.texture = load("res://graphic/Items/"+recipe_data["Recipe Icon"]+".png")
	sd = recipe_data
	pass
