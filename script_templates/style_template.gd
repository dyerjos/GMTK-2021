#01. tool
#02. class_name
#03. extends
extends Node2D

#04. # docstring:
# A brief description of the class's role and functionality.
# Longer description.

#05. signals:
	#signal spawn_player(position)

#06. enums:
#	enum Jobs {KNIGHT, WIZARD, ROGUE, HEALER, SHAMAN}

#07. constants:
#	const MAX_LIVES = 3

#08. exported:
#	export(Jobs) var job = Jobs.KNIGHT
#	export var max_health = 50
#	export var attack = 5

#09. public variables:
#	var health = max_health setget set_health

#10. private variables:
#	var _speed = 300.0

#11. onready variables:
#	onready var sword = get_node("Sword")
#	onready var gun = get_node("Gun")

#12. optional built-in virtual _init method
#	func _init():

#13. built-in virtual _ready method
#	func _ready():

#14. remaining built-in virtual methods
#	func _process(delta: float) -> void:
#	func _unhandled_input(event: InputEvent) -> void:
#	func _physics_process(delta: float) -> void:

#15. public methods
#16. private methods



#=======================================================
## Style Guide:
# Also use PascalCase when loading a class into a constant or a variable:
#const Weapon = preload("res://weapon.gd")

#-----Use snake_case to name functions and variables:
#var particle_effect
#func load_level():
	
#-----Prepend a single underscore (_) to virtual methods functions the user must override, private functions, and private variables:
#var _counter = 0
#func _recalculate_path():
	

#------Use the past tense to name signals:
#signal door_opened
#signal score_changed

#------Write constants with CONSTANT_CASE, that is to say in all caps with an underscore (_) to separate words:
#const MAX_SPEED = 200

#------Use PascalCase for enum names and CONSTANT_CASE for their members, as they are constants:
#enum Element {
#    EARTH,
#    WATER,
#    AIR,
#    FIRE,
#}
