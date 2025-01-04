extends Node

var player  = {
	"NAME": "Eschato",
	"ALIAS": "Little Bitch",
	"RACE": "Juere",
	"CLASS": "Gunner",
	"SEX": "M",
	"PRONOUNS": "F",
	"HEIGHT": 150,
	"WEIGHT": 55,
	"AGE": 14,
	"BIRTHDATE": {
		"YEAR": 517,
		"MONTH": 1,
		"DAY": 1
	},
	"FULLNESS": 5000,
	"COINS": {
		"GOLD": 1234,
		"PLATINUM": 100
	},
	"EXPERIENCE": {
		"EXPERIENCE": 0,
		"LEVEL": 1
	},
	"KARMA": 0,
	"HP": {
		"CURRENT": 50,
		"MAXIMUM": 100
	},
	"MP": {
		"CURRENT": 50,
		"MAXIMUM": 100
	},
	"STAMINA": {
		"CURRENT": 50,
		"MAXIMUM": 100
	},
	"INVENTORY": {
		"CURRENT": 50.0,
		"MAXIMUM": 100.0,
		"ITEMS": [
			{
				"ItemName": "meat"
			}
		]
	},
	"RELIGION": {
		"GOD":"Kumiromi",
		"Favor": 5
	},
	"ATTRIBUTES": {
		"STR": {
			"ORG":28,
			"FIN":33,
			"POT":100.0
		},
		"CON": {
			"ORG":28,
			"FIN":33,
			"POT":100.0
		},
		"DEX": {
			"ORG":28,
			"FIN":33,
			"POT":100.0
		},
		"PER": {
			"ORG":28,
			"FIN":33,
			"POT":100.0
		},
		"LER": {
			"ORG":28,
			"FIN":33,
			"POT":100.0
		},
		"WIL": {
			"ORG":28,
			"FIN":33,
			"POT":100.0
		},
		"MAG": {
			"ORG":28,
			"FIN":33,
			"POT":100.0
		},
		"CHR": {
			"ORG":28,
			"FIN":33,
			"POT":100.0
		},
		"SPD": {
			"ORG":28,
			"FIN":33,
			"POT":100.0
		}
	},
	"COMBAT SKILLS": {},
	"ADVENTURE SKILLS": {
		"Cooking": {
			"LVL": 4
		}
		
	},
	"BODY PARTS": [
			{
				"Body Part": "Head"
			},
			{
				"Body Part": "Hand",
				"Item Data": {
					"ItemName": "battle axe"
				}
			},
			{
				"Body Part": "Hand",
				"Item Data": {
					"ItemName": "bardish"
				}
			}
	],
	"APPEARANCE": {
		"SKIN": 0,
		"EARS": "R",
		"HAIR": 0,
		"HAIRC": 6
	}
}

var audio = {
	"bg_town": load("res://audio/bg_town.tres"),
	"eat": load("res://audio/eat.tres"),
	"drop": load("res://audio/drop.tres"),
	"get1": load("res://audio/get1.tres"),
	"foot": load("res://audio/foot.tres"),
	"foot1a": load("res://audio/foot1a.tres")
}

var global_data = {
	"tick":0
}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass
	
func time_tick(ticks):
	global_data["tick"] += ticks
	
func ticks_to_turns():
	return floor(global_data["tick"]/4)
	
func turns_to_time():
	var totalminutes = floor(ticks_to_turns()/10)
	var minute = totalminutes%60
	var hour = floor(totalminutes/60)%24
	return [hour, minute]
	
func json_file_copy(filePath):
	var file = FileAccess.open(filePath, FileAccess.READ)
	var content = file.get_as_text()
	
	var json = JSON.new()
	var error = json.parse(content)

	if error == OK:
		var data_received = json.data
		return data_received
