extends Control

var d = Mother.json_file_copy("res://data/items_data.json")
var sd = {
	"ItemName":"dummy"
}

func set_item(data):
	$name.text = data["ItemName"]
	$icon.texture = load("res://graphic/Items/"+d[data["ItemName"]]["sprite"]+".png")
	
	sd["ItemName"] = data["ItemName"]
	pass
