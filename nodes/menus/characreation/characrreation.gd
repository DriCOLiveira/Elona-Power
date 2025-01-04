extends Control

var character_data = {}

var currpage = "alias"

@onready var alias = $alias
@onready var alias_choices = get_node("alias/choices")

@onready var backstory = $backstory
@onready var backstory_choices = get_node("backstory/choices")

@onready var race = $race
@onready var race_choices = get_node("race/choices")

@onready var gender = $gender
@onready var gender_choices = get_node("gender/choices")

@onready var classes = $classes
@onready var classes_choices = get_node("classes/choices")

@onready var skill = $skill
@onready var skill_choices = get_node("skill/choices")

@onready var attributes = $attributes
@onready var attributes_choices = get_node("attributes/choices")

@onready var feats = $feats
@onready var feats_choices = get_node("feats/choices")

@onready var appearance = $appearance
@onready var appearance_choices = get_node("appearance/choices")
@onready var apperance_view = get_node("appearance/Panel/ani")


var alias_pre_file = "res://data/alias_pre.txt"
var alias_suf_file = "res://data/alias_suf.txt"

var alias_pre_arr = []
var alias_suf_arr = []

var race_data = {}
var class_data = {}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	alias.show()
	backstory.hide()	
	race.hide()
	gender.hide()
	classes.hide()
	skill.hide()
	attributes.hide()
	feats.hide()
	appearance.hide()

	character_data = json_file_copy("res://data/character_data_template.json")
	
	alias_pre_arr = get_text_file_lines(alias_pre_file)
	alias_suf_arr = get_text_file_lines(alias_suf_file)
	
	race_data = json_file_copy("res://data/races_data.json")
	class_data = json_file_copy("res://data/classes_data.json")
	
	fill_aliases()
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	match currpage:
		"alias":
			pass
	pass

func fill_aliases():
	alias_choices.set_item_text(1, reroll_alias())
	alias_choices.set_item_text(2, reroll_alias())
	alias_choices.set_item_text(3, reroll_alias())
	alias_choices.set_item_text(4, reroll_alias())
	alias_choices.set_item_text(5, reroll_alias())
	alias_choices.set_item_text(6, reroll_alias())
	alias_choices.set_item_text(7, reroll_alias())
	alias_choices.set_item_text(8, reroll_alias())
	alias_choices.set_item_text(9, reroll_alias())
	alias_choices.set_item_text(10, reroll_alias())
	alias_choices.set_item_text(11, reroll_alias())
	alias_choices.set_item_text(12, reroll_alias())
	alias_choices.set_item_text(13, reroll_alias())
	alias_choices.set_item_text(14, reroll_alias())
	alias_choices.set_item_text(15, reroll_alias())
	alias_choices.set_item_text(16, reroll_alias())

func reroll_alias():
	var pre = alias_pre_arr.pick_random()
	var suf = alias_suf_arr.pick_random()
	
	return pre+" "+suf
	
	
func get_text_file_lines(filePath):
	var file = FileAccess.open(filePath, FileAccess.READ)
	var content = file.get_as_text()
	var subcontent = content.split("\n")
	var fincontent = []
	for con in subcontent:
		fincontent.append(con.rstrip("\r"))
	return fincontent
	
func alias_select(val):
	if val == 0:
		fill_aliases()
	else:
		#proceed
		character_data['ALIAS'] = alias_choices.get_item_text(val)
		
		currpage = "backstory"
		alias.hide()
		backstory.hide()	
		race.show()
		gender.hide()
		classes.hide()
		skill.hide()
		attributes.hide()
		feats.hide()
		appearance.hide()
		print_races()
		pass
		
func json_file_copy(filePath):
	var file = FileAccess.open(filePath, FileAccess.READ)
	var content = file.get_as_text()
	
	var json = JSON.new()
	var error = json.parse(content)

	if error == OK:
		var data_received = json.data
		return data_received
	pass

func _on_alias_choices_item_clicked(index: int, _at_position: Vector2, _mouse_button_index: int) -> void:
	alias_select(index)
	pass # Replace with function body.
	
func print_races():
	race_choices.clear()
	for key in race_data:
		race_choices.add_item(key)
	print_info('Yerles')
	pass
	
func print_info(key):
	race.get_node("return1").text = race_data[key]['description']


func _on_race_choices_item_clicked(index: int, _at_position: Vector2, _mouse_button_index: int) -> void:
	var t = race_choices.get_item_text(index)
	if (character_data['RACE'] == t):
		character_data['RACE'] = t
		alias.hide()
		backstory.hide()	
		race.hide()
		gender.show()
		classes.hide()
		skill.hide()
		attributes.hide()
		feats.hide()
		appearance.hide()
	else:
		print_info(t)
		character_data['RACE'] = t
	pass # Replace with function body.
	


func _on_gender_choices_item_clicked(index: int, _at_position: Vector2, _mouse_button_index: int) -> void:
	match index:
		0:
			character_data['SEX'] = "M"
			character_data['PRONOUNS'] = "M"
			
		1:
			character_data['SEX'] = "F"
			character_data['PRONOUNS'] = "F"
			
		2:
			character_data['SEX'] = "F"
			character_data['PRONOUNS'] = "M"
			
		3:
			character_data['SEX'] = "M"
			character_data['PRONOUNS'] = "F"
			
		4:
			character_data['SEX'] = "B"
			character_data['PRONOUNS'] = "B"
			
		5:
			character_data['SEX'] = "B"
			character_data['PRONOUNS'] = "B"
			
	alias.hide()
	backstory.hide()	
	race.hide()
	gender.hide()
	classes.show()
	skill.hide()
	attributes.hide()
	feats.hide()
	appearance.hide()
	
	print_classes()
	pass # Replace with function body.
	
func print_classes():
	classes_choices.clear()
	for key in class_data:
		classes_choices.add_item(key)
	pass


func _on_classes_choices_item_clicked(index: int, _at_position: Vector2, _mouse_button_index: int) -> void:
	var t = race_choices.get_item_text(index)
	if (character_data['CLASS'] == t):
		character_data['CLASS'] = t
		alias.hide()
		backstory.hide()	
		race.hide()
		gender.hide()
		classes.hide()
		skill.show()
		attributes.hide()
		feats.hide()
		appearance.hide()
	else:
		
		character_data['CLASS'] = t
	pass # Replace with function body.

func _on_skill_choices_item_clicked(index: int, at_position: Vector2, mouse_button_index: int) -> void:
	alias.hide()
	backstory.hide()	
	race.hide()
	gender.hide()
	classes.hide()
	skill.hide()
	attributes.show()
	feats.hide()
	appearance.hide()
	pass # Replace with function body.


func _on_attributes_choices_item_clicked(index: int, at_position: Vector2, mouse_button_index: int) -> void:
	alias.hide()
	backstory.hide()	
	race.hide()
	gender.hide()
	classes.hide()
	skill.hide()
	attributes.hide()
	feats.show()
	appearance.hide()
	pass # Replace with function body.

var sk_looper = ""
var sk_loop_in = 0
var ea_looper = ""
var ea_loop_in = 0
var hs_loop_in = 0
var hc_loop_in = 0

func _on_feats_choices_item_clicked(index: int, at_position: Vector2, mouse_button_index: int) -> void:
	alias.hide()
	backstory.hide()	
	race.hide()
	gender.hide()
	classes.hide()
	skill.hide()
	attributes.hide()
	feats.hide()
	appearance.show()
	
	sk_looper = race_data[character_data["RACE"]]["appearance"]["skin"]
	ea_looper = race_data[character_data["RACE"]]["appearance"]["ears"]
	
	if len(ea_looper) ==  1:
		appearance.get_node("app/ears").hide()
	refresh_chara_view()
	pass # Replace with function body.
	
func refresh_chara_view():
	var s = character_data['SEX']+"_"+ea_looper[ea_loop_in]+"_"+str(sk_looper[sk_loop_in])
	var sl = load("res://nodes/humanoid/bodies/"+s+".tres")
	apperance_view.set_sprite_frames(sl)
	
	var h = str(hs_loop_in)+"_"+str(hc_loop_in)
	var hl = load("res://nodes/humanoid/hairs/"+h+".tres")
	apperance_view.get_node("Hair").set_sprite_frames(hl)
	
	apperance_view.stop()
	apperance_view.get_node("EyeBase").stop()
	apperance_view.get_node("Hair").stop()
	apperance_view.play("WALK_DOWN")
	apperance_view.get_node("EyeBase").play("WALK_DOWN")
	apperance_view.get_node("Hair").play("WALK_DOWN")
	pass


func _on_skin_minus_button_down() -> void:
	sk_loop_in -= 1
	if sk_loop_in < 0:
		sk_loop_in = len(sk_looper)-1
	refresh_chara_view()


func _on_skin_plus_button_down() -> void:
	sk_loop_in += 1
	if sk_loop_in > len(sk_looper)-1:
		sk_loop_in = 0
	refresh_chara_view()


func _on_ears_minus_button_down() -> void:
	ea_loop_in -= 1
	if ea_loop_in < 0:
		ea_loop_in = len(ea_looper)-1
	refresh_chara_view()


func _on_hairc_minus_button_down() -> void:
	hc_loop_in -= 1
	if hc_loop_in < 0:
		hc_loop_in = 6
	refresh_chara_view()


func _on_hairc_plus_button_down() -> void:
	hc_loop_in += 1
	if hc_loop_in > 6:
		hc_loop_in = 0
	refresh_chara_view()

func _on_finalize_button_down() -> void:
	character_data["APPEARANCE"]["SKIN"] = sk_looper[sk_loop_in]
	character_data["APPEARANCE"]["EARS"] = ea_looper[ea_loop_in]
	character_data["APPEARANCE"]["HAIR"] = hs_loop_in
	character_data["APPEARANCE"]["HAIRC"] = hc_loop_in
	
	Mother.player = character_data
	
	var t = load("res://nodes/world/MainGame.tscn").instantiate()
	t.load_map("Vernis")
	get_tree().root.add_child(t)
	queue_free()
	pass # Replace with function body.
