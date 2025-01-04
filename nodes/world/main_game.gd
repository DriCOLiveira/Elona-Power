extends Node2D

var Grid = null
var humanoid = preload("res://nodes/humanoid/humanoid.tscn")

var player = null

var currmapdata = {}

var lock = false

# Called when the node enters the scene tree for the first time.
func load_map(mapname):
	for child in $World.get_children():
		child.queue_free()

	var ms = load("res://nodes/maps/"+mapname+".tscn").instantiate()
	$World.add_child(ms)
	Grid = ms
	
	currmapdata = Mother.json_file_copy("res://data/maps/"+mapname+".json")
	spawnmapitems(currmapdata["Initial Data"]["Items"])
	spawnmapnpcs(currmapdata["Initial Data"]["NPCs"])
	
	$audio_bg.stream = Mother.audio["bg_town"]
	
	$cl/Control/lowmenu/con/lowbar/maplabel/Label.text = mapname
	

		
func spawnmapitems(data):
	var n = Node2D.new()
	n.name = "Items"
	$World.add_child(n)
	
	var t =  load("res://nodes/items/item_48.tscn")
	for itemd in data:
		var tt = t.instantiate()
		tt.hide()
		tt.set_item(itemd["name"])
		$World/Items.add_child(tt)
		tt.position = Grid.map_to_local(Vector2i(itemd["coors"][0], itemd["coors"][1]))
		tt.show()
		
func spawnmapnpcs(data):
	var n = Node2D.new()
	n.name = "NPCs"
	$World.add_child(n)
	
	var t =  load("res://nodes/npc/npc.tscn")
	for npcd in data:
		var tt = t.instantiate()
		tt.hide()
		tt.set_map(Grid)
		tt.set_npc(npcd["type"])
		$World/NPCs.add_child(tt)
		tt.force_set_grid_pos(Vector2i(npcd["coors"][0], npcd["coors"][1]))
		tt.show()

func _ready() -> void:
	set_camera_limits()
	
	player = humanoid.instantiate()
	player.set_map(Grid)
	player.start_npc_talk.connect(npctalker)
	player.refresh_hunger_buff_view.connect(refresh_buffs)
	player.refresh_lowbar.connect(refresh_lowbar)
	$World.add_child(player)
	player.force_set_grid_pos(Vector2i(1,1))
	player.set_data(Mother.player)
	
	refresh_lowbar()
	
	autonomy_for_all()
	
	$audio_bg.play()

var camclamp1
var camclamp2

var currmenu = null

var mobmenu = false
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	$Camera2D.position = player.global_position.clamp(camclamp1, camclamp2)
	
	if lock == true:
		if Input.is_action_just_pressed("close"):
			if currmenu != null:
				get_node("cl/Control/togglemenus/"+currmenu).hide()
				lock = false
	else:
		if Input.is_action_just_pressed("openmobilemenu"):
			if mobmenu == true:
				mobmenu = false
				$CanvasLayer/mobilecontrols/menuopener/lilmenus.hide()
			else:
				mobmenu = true
				$CanvasLayer/mobilecontrols/menuopener/lilmenus.show()
		elif Input.is_action_just_pressed("sc1"):
			$'CanvasLayer/mobilecontrols/menuopener/lilmenus/1'.show()
			$'CanvasLayer/mobilecontrols/menuopener/lilmenus/2'.hide()
			$'CanvasLayer/mobilecontrols/menuopener/lilmenus/3'.hide()
			
		elif Input.is_action_just_pressed("sc2"):
			$'CanvasLayer/mobilecontrols/menuopener/lilmenus/1'.hide()
			$'CanvasLayer/mobilecontrols/menuopener/lilmenus/2'.show()
			$'CanvasLayer/mobilecontrols/menuopener/lilmenus/3'.hide()
			
		elif Input.is_action_just_pressed("sc3"):
			$'CanvasLayer/mobilecontrols/menuopener/lilmenus/1'.hide()
			$'CanvasLayer/mobilecontrols/menuopener/lilmenus/2'.hide()
			$'CanvasLayer/mobilecontrols/menuopener/lilmenus/3'.show()
		
		if Input.is_action_just_pressed("drop"):
			lock = true
			currmenu = "Drop"
			var l = load("res://nodes/menus/gamemenus/invitem.tscn")
			for child in $cl/Control/togglemenus/Drop/scroll/items.get_children():
				child.queue_free()
			for item in player.sd["INVENTORY"]["ITEMS"]:
				var ll = l.instantiate()
				ll.set_item(item)
				ll.get_node("touch").pressed.connect(drop_item.bind(ll, item))
				$cl/Control/togglemenus/Drop/scroll/items.add_child(ll)
			$cl/Control/togglemenus/Drop.show()
			
		elif Input.is_action_just_pressed("eat"):
			lock = true
			currmenu = "Eat"
			var l = load("res://nodes/menus/gamemenus/invitem.tscn")
			for child in $cl/Control/togglemenus/Eat/scroll/items.get_children():
				child.queue_free()
				
			var itd = Mother.json_file_copy("res://data/items_data.json")
			
			var i = player.get_node("are").get_overlapping_areas()
			for ii in i:
				var iii = ii.get_node("..")
				if itd[iii.sd["ItemName"]]["material"] == "raw" or evaluate_tag(iii.sd, "force_edible") == true:
					var ll = l.instantiate()
					ll.set_item(iii.sd)
					ll.get_node("name").text = ll.get_node("name").text+" (Ground)"
					ll.get_node("touch").pressed.connect(eat_item.bind(iii, iii.sd))
					$cl/Control/togglemenus/Eat/scroll/items.add_child(ll)
				
			for item in player.sd["INVENTORY"]["ITEMS"]:
				if itd[item["ItemName"]]["material"] == "raw" or evaluate_tag(item, "force_edible") == true:
					var ll = l.instantiate()
					ll.set_item(item)
					ll.get_node("touch").pressed.connect(eat_item.bind(ll, item))
					$cl/Control/togglemenus/Eat/scroll/items.add_child(ll)
			$cl/Control/togglemenus/Eat.show()
			
		elif Input.is_action_just_pressed("get"):
			var i = null
			i = player.get_node("are").get_overlapping_areas()
			if len(i) == 0:
				update_console_log("You grasp at the air.")
			elif len(i) == 1:
				var ii = i[0].get_node("..")
				player.sd["INVENTORY"]["ITEMS"].append(ii.be_picked_up())
				update_console_log("You pick up a "+ii.sd["ItemName"]+".")
				
				$audio_sfx.stream = Mother.audio["get1"]
				$audio_sfx.play()
	
			else:
				lock = true
				currmenu = "Get"
					
				for child in $cl/Control/togglemenus/Get/scroll/items.get_children():
					child.queue_free()
				
				var l = load("res://nodes/menus/gamemenus/invitem.tscn")
				for item in i:
					var ii = item.get_node("..")
					var ll = l.instantiate()
					ll.set_item(ii.sd)
					ll.get_node("touch").pressed.connect(get_item.bind(ii, ii.sd))
					$cl/Control/togglemenus/Get/scroll/items.add_child(ll)
				$cl/Control/togglemenus/Get.show()
		
		elif Input.is_action_just_pressed("wear"):
			lock = true
			currmenu = "Wear"
			var l = load("res://nodes/menus/gamemenus/equipment.tscn")
			for child in $cl/Control/togglemenus/Wear/scroll/items.get_children():
				child.queue_free()
				
			for item in player.sd["BODY PARTS"]:
				if "Item Data" in item:
					var ll = l.instantiate()
					ll.set_item(item)
					
					$cl/Control/togglemenus/Wear/scroll/items.add_child(ll)
					
			$cl/Control/togglemenus/Wear.show()
			
		elif Input.is_action_just_pressed("use"):
			lock = true
			currmenu = "Use"
			var l = load("res://nodes/menus/gamemenus/invitem.tscn")
			for child in $cl/Control/togglemenus/Use/scroll/items.get_children():
				child.queue_free()
				
			var itd = Mother.json_file_copy("res://data/items_data.json")
			
			var i = player.get_node("are").get_overlapping_areas()
			for ii in i:
				var iii = ii.get_node("..")
				if evaluate_tag(iii.sd, "usable") == true:
					var ll = l.instantiate()
					ll.set_item(iii.sd)
					ll.get_node("name").text = ll.get_node("name").text+" (Ground)"
					ll.get_node("touch").pressed.connect(use_item.bind(iii, iii.sd))
					$cl/Control/togglemenus/Use/scroll/items.add_child(ll)
				
			for item in player.sd["INVENTORY"]["ITEMS"]:
				if evaluate_tag(item, "usable") == true:
					var ll = l.instantiate()
					ll.set_item(item)
					ll.get_node("touch").pressed.connect(use_item.bind(ll, item))
					$cl/Control/togglemenus/Use/scroll/items.add_child(ll)
			$cl/Control/togglemenus/Use.show()
			
		elif Input.is_action_pressed("up"):
			player.move(Vector2(0,-1))
			autonomy_for_all()
		elif Input.is_action_pressed("down"):
			player.move(Vector2(0,1))
			autonomy_for_all()
		elif Input.is_action_pressed("left"):
			player.move(Vector2(-1,0))
			autonomy_for_all()
		elif Input.is_action_pressed("right"):
			player.move(Vector2(1,0))
			autonomy_for_all()
	pass
	
func set_camera_limits():
	camclamp1 = Vector2((Grid.get_used_rect().position.x+8)*48, (Grid.get_used_rect().position.y+6)*48)
	camclamp2 = Vector2((Grid.get_used_rect().end.x-8)*48, (Grid.get_used_rect().end.y-4)*48)
	

func update_clock():
	var t = Mother.turns_to_time()[0]
	
	match t:
		0:
			$cl/Control/timedate/clockhand.rotation_degrees = 0
		1:
			$cl/Control/timedate/clockhand.rotation_degrees = 30
		2:
			$cl/Control/timedate/clockhand.rotation_degrees = 60
		3:
			$cl/Control/timedate/clockhand.rotation_degrees = 90
		4:
			$cl/Control/timedate/clockhand.rotation_degrees = 120
		5:
			$cl/Control/timedate/clockhand.rotation_degrees = 150
		6:
			$cl/Control/timedate/clockhand.rotation_degrees = 180
		7:
			$cl/Control/timedate/clockhand.rotation_degrees = 210
		8:
			$cl/Control/timedate/clockhand.rotation_degrees = 240
		9:
			$cl/Control/timedate/clockhand.rotation_degrees = 270
		10:
			$cl/Control/timedate/clockhand.rotation_degrees = 300
		11:
			$cl/Control/timedate/clockhand.rotation_degrees = 330
		12:
			$cl/Control/timedate/clockhand.rotation_degrees = 0
		13:
			$cl/Control/timedate/clockhand.rotation_degrees = 30
		14:
			$cl/Control/timedate/clockhand.rotation_degrees = 60
		15:
			$cl/Control/timedate/clockhand.rotation_degrees = 90
		16:
			$cl/Control/timedate/clockhand.rotation_degrees = 120
		17:
			$cl/Control/timedate/clockhand.rotation_degrees = 150
		18:
			$cl/Control/timedate/clockhand.rotation_degrees = 180
		19:
			$cl/Control/timedate/clockhand.rotation_degrees = 210
		20:
			$cl/Control/timedate/clockhand.rotation_degrees = 240
		21:
			$cl/Control/timedate/clockhand.rotation_degrees = 270
		22:
			$cl/Control/timedate/clockhand.rotation_degrees = 300
		23:
			$cl/Control/timedate/clockhand.rotation_degrees = 330
		
	pass
	
var console_expanded_log = []
var console_shrunken_log = []
func update_console_log(text):
	
	if len(console_shrunken_log) > 2:
		console_shrunken_log.pop_front()
		
	console_shrunken_log.append(text)
	
	
			
	$cl/Control/lowmenu/con/console_shrunk/txt.text = "\n".join(console_shrunken_log)
	"""
	var t = Mother.turns_to_time()	
	var n = "["+str(t[0])+":"+str(t[1])+"]"
	if n != console_shrunken_log[-1] or len(console_shrunken_log) < 3:
		console_shrunken_log.append(n)
		if len(console_shrunken_log) > 3:
			console_shrunken_log.pop_front()
		$cl/Control/lowmenu/con/console_shrunk/txt.text = "\n".join(console_shrunken_log)
	"""

func drop_item(nodde, data):
	nodde.queue_free()
	player.sd["INVENTORY"]["ITEMS"].erase(data)
	
	var t =  load("res://nodes/items/item_48.tscn")
	var tt = t.instantiate()
	tt.hide()
	tt.set_item(data["ItemName"])
	$World/Items.add_child(tt)
	tt.position = player.snapper(player.position)
	tt.show()
	
	update_console_log("You drop a "+nodde.sd["ItemName"]+".")
	
	$audio_sfx.stream = Mother.audio["drop"]
	$audio_sfx.play()
	
	closemenu()

func get_item(nodde, data):
	var d = nodde.be_picked_up()
	player.sd["INVENTORY"]["ITEMS"].append(d)
	update_console_log("You pick up a "+nodde.sd["ItemName"]+".")
	
	$audio_sfx.stream = Mother.audio["get1"]
	$audio_sfx.play()
	
	closemenu()
		
func eat_item(nodde, data):
	nodde.queue_free()
	player.sd["INVENTORY"]["ITEMS"].erase(data)
	player.eat_item(data)
	
	$audio_sfx.stream = Mother.audio["eat"]
	$audio_sfx.play()
	
	closemenu()
	
func wear_item():
	pass
	
func use_item(nodde, data):
	closemenu()
	
	if evaluate_tag(nodde.sd, "cooking tool"):
		lock =  true
		currmenu = "Cook"
		var l = load("res://nodes/menus/gamemenus/recipeselect.tscn")
		var recipedata = Mother.json_file_copy("res://data/cooking recipes.json")
		
		for child in $cl/Control/togglemenus/Cook/half1/scroll/items.get_children():
			child.queue_free()
			
		for recipe in recipedata:
			var ll = l.instantiate()
			ll.set_item(recipedata[recipe])
			ll.get_node("touch").pressed.connect(select_recipe.bind(ll))
			$cl/Control/togglemenus/Cook/half1/scroll/items.add_child(ll)
		
		$cl/Control/togglemenus/Cook/half1.show()
		$cl/Control/togglemenus/Cook/half2.show()
		$cl/Control/togglemenus/Cook/half3.hide()
		$cl/Control/togglemenus/Cook/half2/recipeselect.hide()
		for child in $cl/Control/togglemenus/Cook/half2/scroll/items.get_children():
			child.queue_free()
		$cl/Control/togglemenus/Cook.show()
		
func select_recipe(nodde):
	$cl/Control/togglemenus/Cook/half2/recipeselect/icon.texture = load("res://graphic/Items/"+nodde.sd["Recipe Icon"]+".png")
	$cl/Control/togglemenus/Cook/half2/recipeselect/label.text = nodde.sd["Recipe Name"]
	
	for child in $cl/Control/togglemenus/Cook/half2/scroll/items.get_children():
		child.queue_free()
			
	var l = load("res://nodes/menus/gamemenus/recipeprep.tscn")
	for ingredient in nodde.sd["Recipe Requirements"]:
		var ll = l.instantiate()
		ll.set_item(nodde.sd, ingredient)
		ll.get_node("touch").pressed.connect(select_ingredient_from_list.bind(ll))
		$cl/Control/togglemenus/Cook/half2/scroll/items.add_child(ll)
	
	$cl/Control/togglemenus/Cook/half2/recipeselect.show()
	
func select_ingredient_from_list(nodde):
	$cl/Control/togglemenus/Cook/half1.hide()
	
	nodde.selecteditem = null
	nodde.get_node("ticker").button_pressed = false
	
	for child in $cl/Control/togglemenus/Cook/half3/scroll/items.get_children():
		child.queue_free()
		
	var l = load("res://nodes/menus/gamemenus/altinvitem.tscn")
	for item in player.sd["INVENTORY"]["ITEMS"]:
		if evaluate_tag(item, nodde.sd["Item Tag"]):
			var ll = l.instantiate()
			ll.set_item(item)
			ll.get_node("touch").pressed.connect(select_ingredient.bind(nodde, ll))
			$cl/Control/togglemenus/Cook/half3/scroll/items.add_child(ll)
	
	$cl/Control/togglemenus/Cook/half3.show()
	
func select_ingredient(selectornode, selectednode):
	$cl/Control/togglemenus/Cook/half1.show()
	$cl/Control/togglemenus/Cook/half3.hide()
	
	selectornode.selecteditem = selectednode.sd
	selectornode.get_node("ticker").button_pressed = true
	
func evaluate_tag(itemname, tagname):
	var itd = Mother.json_file_copy("res://data/items_data.json")
	if "tags" in itd[itemname["ItemName"]]:
		if tagname in itd[itemname["ItemName"]]["tags"]:
			return true
		else:
			return false
	else:
		return false		
func autonomy_for_all():
	var cs = $World/NPCs.get_children()
	
	for child in cs:
		child.auto_tick()
		
	player.refresh_tick()
		
func npctalker(npcnode):
	lock = true
	currmenu = "Talk"
	
	$cl/Control/togglemenus/Talk/c/npctitle.text = npcnode.sd["name"]+" "+npcnode.sd["title"]
	
	$cl/Control/togglemenus/Talk/c/text.text = currmapdata["NPC Dialogue"].pick_random()
	
	for child in $cl/Control/togglemenus/Talk/c/cont.get_children():
		child.queue_free()
	
	var t = load("res://nodes/menus/gamemenus/dialogueoption.tscn")
	for dia in npcnode.sd["dialogue options"]:
		match dia:
			"normalchat":
				var tt = t.instantiate()
				tt.get_node("touch").pressed.connect(npctowntalk)
				tt.text = "Let's Talk."
				$cl/Control/togglemenus/Talk/c/cont.add_child(tt)

			"buyitem":
				var tt = t.instantiate()
				tt.get_node("touch").pressed.connect(npctowntalk)
				tt.text = "I want to buy something. (unfinished)"
				$cl/Control/togglemenus/Talk/c/cont.add_child(tt)

			"sellitem":
				var tt = t.instantiate()
				tt.get_node("touch").pressed.connect(npctowntalk)
				tt.text = "I want to sell something. (unfinished)"
				$cl/Control/togglemenus/Talk/c/cont.add_child(tt)
				
			"invest":
				var tt = t.instantiate()
				tt.get_node("touch").pressed.connect(npctowntalk)
				tt.text = "Need someone to invest in your shop? (unfinished)"
				$cl/Control/togglemenus/Talk/c/cont.add_child(tt)
				
			"eatnormal":
				var tt = t.instantiate()
				tt.get_node("touch").pressed.connect(npctowntalk)
				tt.text = "Bring me something to eat. (unfinished)"
				$cl/Control/togglemenus/Talk/c/cont.add_child(tt)
				
			"eatspecial":
				var tt = t.instantiate()
				tt.get_node("touch").pressed.connect(npctowntalk)
				tt.text = "Bring me special dish. (unfinished)"
				$cl/Control/togglemenus/Talk/c/cont.add_child(tt)
				
			"goshelter":
				var tt = t.instantiate()
				tt.get_node("touch").pressed.connect(npctowntalk)
				tt.text = "Take me to the shelter. (unfinished)"
				$cl/Control/togglemenus/Talk/c/cont.add_child(tt)
				
			"exchange":
				var tt = t.instantiate()
				tt.get_node("touch").pressed.connect(exchangenpcplace.bind(npcnode))
				tt.text = "Exchange for my place."
				$cl/Control/togglemenus/Talk/c/cont.add_child(tt)
				
			"bye":
				var tt = t.instantiate()
				tt.get_node("touch").pressed.connect(closemenu)
				tt.text = "Bye bye."
				$cl/Control/togglemenus/Talk/c/cont.add_child(tt)
	
	$cl/Control/togglemenus/Talk.show()

func npctowntalk():
	$cl/Control/togglemenus/Talk/c/text.text = currmapdata["NPC Dialogue"].pick_random()
	
func exchangenpcplace(npcnode):
	var playeroldpos = player.position
	player.position = npcnode.position
	npcnode.position = playeroldpos
	closemenu()
	
func closemenu():
	if currmenu != null:
		get_node("cl/Control/togglemenus/"+currmenu).hide()
		lock = false
		
func refresh_buffs(textt, colorr):
	if textt == "Normal":
		$cl/Control/buffshow/fullness.hide()
	else:
		$cl/Control/buffshow/fullness.text = textt
		$cl/Control/buffshow/fullness.add_theme_color_override("font_color", colorr)
		$cl/Control/buffshow/fullness.show()

func _on_audio_bg_finished() -> void:
	$audio_bg.play()

func refresh_lowbar():
	$cl/Control/uplowmenu/exp.text = "Lv"+str(player.sd["EXPERIENCE"]["LEVEL"])+"/"
	
	$cl/Control/uplowmenu/life.max_value = player.sd["HP"]["MAXIMUM"]
	$cl/Control/uplowmenu/life.value = player.sd["HP"]["CURRENT"]
	$cl/Control/uplowmenu/life/ints.text = str(round(player.sd["HP"]["CURRENT"]))+"("+str(player.sd["HP"]["MAXIMUM"])+")"
	
	$cl/Control/uplowmenu/mana.max_value = player.sd["MP"]["MAXIMUM"]
	$cl/Control/uplowmenu/mana.value = player.sd["MP"]["CURRENT"]
	$cl/Control/uplowmenu/mana/ints.text = str(player.sd["MP"]["CURRENT"])+"("+str(player.sd["MP"]["MAXIMUM"])+")"
	
	$cl/Control/uplowmenu/sp.text = "Sp"+str(player.sd["STAMINA"]["CURRENT"])+"/"+str(player.sd["STAMINA"]["MAXIMUM"])
	
	$cl/Control/uplowmenu/gold.text = str(player.sd["COINS"]["GOLD"])
	$cl/Control/uplowmenu/plat.text = str(player.sd["COINS"]["PLATINUM"])
	
	$cl/Control/lowmenu/con/lowbar/str/Label.text = str(player.sd["ATTRIBUTES"]["STR"]["FIN"])
	$cl/Control/lowmenu/con/lowbar/con/Label.text = str(player.sd["ATTRIBUTES"]["CON"]["FIN"])
	$cl/Control/lowmenu/con/lowbar/dex/Label.text = str(player.sd["ATTRIBUTES"]["DEX"]["FIN"])
	$cl/Control/lowmenu/con/lowbar/per/Label.text = str(player.sd["ATTRIBUTES"]["PER"]["FIN"])
	$cl/Control/lowmenu/con/lowbar/ler/Label.text = str(player.sd["ATTRIBUTES"]["LER"]["FIN"])
	$cl/Control/lowmenu/con/lowbar/wil/Label.text = str(player.sd["ATTRIBUTES"]["WIL"]["FIN"])
	$cl/Control/lowmenu/con/lowbar/mag/Label.text = str(player.sd["ATTRIBUTES"]["MAG"]["FIN"])
	$cl/Control/lowmenu/con/lowbar/chr/Label.text = str(player.sd["ATTRIBUTES"]["CHR"]["FIN"])
	$cl/Control/lowmenu/con/lowbar/spd/Label.text = str(player.sd["ATTRIBUTES"]["SPD"]["FIN"])


func _on_cooknow_pressed() -> void:
	for item in $cl/Control/togglemenus/Cook/half2/scroll/items.get_children():
		if item.selecteditem == null:
			return
			
	player.cook_item($cl/Control/togglemenus/Cook/half2/scroll/items.get_children(), $cl/Control/togglemenus/Cook/half2/scroll/items.get_children()[0].sd2, 100)
	closemenu()
	pass # Replace with function body.
