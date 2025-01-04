class_name Humanoid extends CharacterBody2D

var Grid = null
var oldpos = Vector2(0,0)
var target = Vector2(32,32)

var sd = {}

signal refresh_hunger_buff_view(text, color)
signal refresh_lowbar
signal start_npc_talk(npcnode)

#CALL BEFORE ADDING TO SCENE!!!
func set_map(map):
	Grid = map
	
func set_data(data):
	sd = data
	set_appearance(sd["SEX"], sd["APPEARANCE"]["EARS"], sd["APPEARANCE"]["SKIN"], sd["APPEARANCE"]["HAIR"], sd["APPEARANCE"]["HAIRC"])
	
func set_appearance(body, ears, skinc, hairs, hairc):
	var b = body+"_"+ears+"_"+str(skinc)
	var bl = load("res://nodes/humanoid/bodies/"+b+".tres")
	$body.set_sprite_frames(bl)
	
	var h = str(hairs)+"_"+str(hairc)
	var hl = load("res://nodes/humanoid/hairs/"+h+".tres")
	$hair.set_sprite_frames(hl)
	pass

func _ready():
	position = snapper(position)
	oldpos = position
	
func snapper(pos):
	return Grid.map_to_local(Grid.local_to_map(pos))
	
func force_set_pos(pos):
	position = snapper(pos)
	
func force_set_grid_pos(gridpos):
	position = Grid.map_to_local(gridpos)

func move(dir):
	target = snapper(position + (dir * 64))
	
	var space_state = get_world_2d().direct_space_state
	var query = PhysicsRayQueryParameters2D.create(position, target)
	var result = space_state.intersect_ray(query)
		
	if result:
		match dir:
			Vector2(0,1):
				$body.animation = "WALK_DOWN"
				$eyebase.animation = "WALK_DOWN"
				$hair.animation = "WALK_DOWN"
				$chest.animation = "WALK_DOWN"
				$leg.animation = "WALK_DOWN"

			Vector2(0,-1):
				$body.animation = "WALK_UP"
				$eyebase.animation = "WALK_UP"
				$hair.animation = "WALK_UP"
				$chest.animation = "WALK_UP"
				$leg.animation = "WALK_UP"

			Vector2(1,0):
				$body.animation = "WALK_RIGHT"
				$eyebase.animation = "WALK_RIGHT"
				$hair.animation = "WALK_RIGHT"
				$chest.animation = "WALK_RIGHT"
				$leg.animation = "WALK_RIGHT"
					
			Vector2(-1,0):
				$body.animation = "WALK_LEFT"
				$eyebase.animation = "WALK_LEFT"
				$hair.animation = "WALK_LEFT"
				$chest.animation = "WALK_LEFT"
				$leg.animation = "WALK_LEFT"
					
		if result.collider is NPC:
			print(result.collider.name)
			start_npc_talk.emit(result.collider)
		#print("Hit at point: ", result.position)
	else:
		match dir:
			Vector2(0,1):
				if $body.animation == "WALK_DOWN":
					var v = $body.frame + 1
					if v > 3:
						v = 0
					$body.frame = v
					$eyebase.frame = v
					$hair.frame = v
					$chest.frame = v
					$leg.frame = v
					
				else:
					$body.animation = "WALK_DOWN"
					$eyebase.animation = "WALK_DOWN"
					$hair.animation = "WALK_DOWN"
					$chest.animation = "WALK_DOWN"
					$leg.animation = "WALK_DOWN"
					
			Vector2(0,-1):
				if $body.animation == "WALK_UP":
					var v = $body.frame + 1
					if v > 3:
						v = 0
					$body.frame = v
					$eyebase.frame = v
					$hair.frame = v
					$chest.frame = v
					$leg.frame = v
					
				else:
					$body.animation = "WALK_UP"
					$eyebase.animation = "WALK_UP"
					$hair.animation = "WALK_UP"
					$chest.animation = "WALK_UP"
					$leg.animation = "WALK_UP"

			Vector2(1,0):
				if $body.animation == "WALK_RIGHT":
					var v = $body.frame + 1
					if v > 3:
						v = 0
					$body.frame = v
					$eyebase.frame = v
					$hair.frame = v
					$chest.frame = v
					$leg.frame = v
					
				else:
					$body.animation = "WALK_RIGHT"
					$eyebase.animation = "WALK_RIGHT"
					$hair.animation = "WALK_RIGHT"
					$chest.animation = "WALK_RIGHT"
					$leg.animation = "WALK_RIGHT"
					
			Vector2(-1,0):
				if $body.animation == "WALK_LEFT":
					var v = $body.frame + 1
					if v > 3:
						v = 0
					$body.frame = v
					$eyebase.frame = v
					$hair.frame = v
					$chest.frame = v
					$leg.frame = v
					
				else:
					$body.animation = "WALK_LEFT"
					$eyebase.animation = "WALK_LEFT"
					$hair.animation = "WALK_LEFT"
					$chest.animation = "WALK_LEFT"
					$leg.animation = "WALK_LEFT"
					
		position = target
		
func eat_item(data):
	var itd = Mother.json_file_copy("res://data/items_data.json")
	sd["FULLNESS"] += itd[data["ItemName"]]["food data"]["Satiation"]
	refresh_tick()
	
func cook_item(raw_food_datas, recipe_data, instrument_quality):
	var itd = Mother.json_file_copy("res://data/items_data.json")
	var CF = randi_range(0, sd["ADVENTURE SKILLS"]["Cooking"]["LVL"])
	CF = clampi(CF, 0, sd["ADVENTURE SKILLS"]["Cooking"]["LVL"]/5 + 7)
	
	CF = randi_range(0, CF)
	if CF > 3:
		CF = randi_range(0, CF-1)
		
	if CF < 3 and sd["ADVENTURE SKILLS"]["Cooking"]["LVL"] >= 5:
		var tchance = randi_range(1, 4)
		if tchance == 1:
			CF = 3
			
	if CF < 3 and sd["ADVENTURE SKILLS"]["Cooking"]["LVL"] >= 10:
		var tchance = randi_range(1, 3)
		if tchance == 1:
			CF = 3
	
	CF = CF + int(instrument_quality/100)
	CF = clampi(CF, 1, 9)
	
	
	var cooked_food_data = recipe_data["Results"][CF-1]
	for ingredient in raw_food_datas:
		sd["INVENTORY"]["ITEMS"].erase(ingredient.selecteditem)
	
	sd["INVENTORY"]["ITEMS"].append({"ItemName": cooked_food_data})
	
func eval_fullness():
	if sd["FULLNESS"] >= 10000:
		return ["Bloated", Color("000000")]
	elif sd["FULLNESS"] >= 8250:
		return ["Satisfied!", Color("000000")]
	elif sd["FULLNESS"] >= 7500:
		return ["Satisfied", Color("000000")]
	elif sd["FULLNESS"] >= 6250:
		return ["Normal", Color("000000")]
	elif sd["FULLNESS"] >= 5000:
		return ["Hungry", Color("0000FF")]
	elif sd["FULLNESS"] >= 3250:
		return ["Hungry!", Color("0000FF")]
	elif sd["FULLNESS"] >= 2500:
		return ["Very Hungry", Color("0000FF")]
	elif sd["FULLNESS"] >= 1250:
		return ["Very Hungry!", Color("FF0000")]
	elif sd["FULLNESS"] >= 0:
		return ["Starving", Color("FF0000")]
	else:
		return ["Starving!", Color("FF0000")]
	
func refresh_tick():
	#fullness
	sd["FULLNESS"] -= 1
	refresh_hunger_buff_view.emit(eval_fullness()[0], eval_fullness()[1])
	
	#hp
	if sd["HP"]["CURRENT"] < sd["HP"]["MAXIMUM"]:
		sd["HP"]["CURRENT"] = clamp(sd["HP"]["CURRENT"]+sd["HP"]["MAXIMUM"]*0.005, -999999, sd["HP"]["MAXIMUM"])
	
	refresh_lowbar.emit()
