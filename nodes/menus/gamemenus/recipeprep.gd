extends Control

var d = Mother.json_file_copy("res://data/items_data.json")
var sd = {}
var sd2 = {}
var selecteditem = {}

func set_item(recipe_data, ingredient_data):
	$label.text = ingredient_data["Item Show"]
	$ticker.button_pressed = false
	sd = ingredient_data
	sd2 = recipe_data
