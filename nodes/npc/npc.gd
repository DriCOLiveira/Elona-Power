class_name NPC extends CharacterBody2D

var Grid = null
var oldpos = Vector2(0,0)
var target = Vector2(32,32)

var sd = {
	"type": "general vendor",
	"name": "debugname",
	"title": "the general vendor",
	"dialogue options": []
}

#CALL BEFORE ADDING TO SCENE!!!
func set_map(map):
	Grid = map
	
var d = Mother.json_file_copy("res://data/npcs_data.json")
func set_npc(data):
	sd["type"] = data
	sd["title"] = d[data]["title"]
	sd["dialogue options"] = d[data]["dialogue options"]
	
	$texture.texture = load("res://graphic/NPC/overworld/"+d[data]["texture"][0]+".png")
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
	query.exclude = [self]
	var result = space_state.intersect_ray(query)
		
	if result:
		pass
	else:
		position = target
		
func auto_tick():
	if randi() % 2:
		move(Vector2(randi_range(-1,1), 0))
	else:
		move(Vector2(0, randi_range(-1,1)))
