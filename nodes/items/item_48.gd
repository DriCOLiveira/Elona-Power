class_name Item extends Sprite2D

var d = Mother.json_file_copy("res://data/items_data.json")
var sd = {
	"ItemName":"dummy"
}

func set_item(bname):
	sd["ItemName"] = bname
	texture = load("res://graphic/Items/"+d[bname]["sprite"]+".png")
	if "y-offset" in d[bname]:
		offset.y = d[bname]["y-offset"]
	pass

func be_picked_up():
	queue_free()
	return sd
	
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
