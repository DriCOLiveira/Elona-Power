extends Control

@onready var MM = $MM

var currmenu = "MM"
var selendex = 0
var maxdex = 5


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	currmenu = "MM"
	selendex = 0
	maxdex = 5
	
	MM.visible = true
	
	pass # Replace with function body.

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("down"):
		move_selector(1)
	elif Input.is_action_just_pressed("up"):
		move_selector(-1)
	elif Input.is_action_just_pressed("select"):
		select_option(selendex)	
	pass

func move_selector(dir):
	if dir == 1:
		selendex = clamp(selendex+1, 0, 5)
		MM.get_node("bg/clicky").select(selendex)
	else:
		selendex = clamp(selendex-1, 0, 5)
		MM.get_node("bg/clicky").select(selendex)


func _on_mm_clicky_item_selected(index: int) -> void:
	selendex = index
	select_option(selendex)
	pass # Replace with function body.

func select_option(val):
	match val:
		0:
			var t = load("res://nodes/world/MainGame.tscn").instantiate()
			t.load_map("Vernis")
			get_tree().root.add_child(t)
			queue_free()
		1:
			"""
			get_tree().root.add_child(preload("res://nodes/menus/characreation/characrreation.tscn").instantiate())
			queue_free()
			"""
		5:
			get_tree().quit()
	pass
