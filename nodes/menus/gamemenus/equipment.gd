extends Control

var d = Mother.json_file_copy("res://data/items_data.json")
var sd = {
	"ItemName":"dummy"
}

func set_item(data):
	$sloticon.texture = load("res://graphic/Interface/Equipment/"+data["Body Part"]+".png")
	$slotlabel.text = data["Body Part"]
	$ico.texture = load("res://graphic/Items/"+d[data["Item Data"]["ItemName"]]["sprite"]+".png")
	$name.text = data["Item Data"]["ItemName"]
	pass
