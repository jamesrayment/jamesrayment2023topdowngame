extends Control

signal upgrade_end

@onready var global = get_node("/root/Global")

var speed_tier = 0

signal speed_announce

# Called when the node enters the scene tree for the first time.
func _ready():
	hide()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

#Functions for upgrades that give players a bonus when selected

func _on_speed_upgrade_pressed():
	get_node("/root/World/Player").speed += 200
	speed_tier += 1
	upgrade_end.emit()
	hide()
	get_node("/root/World/Player").upgrade_check = false

func _on_damage_upgrade_pressed():
	global.damage += 2.5
	print(global.damage)
	upgrade_end.emit()
	hide()
	get_node("/root/World/Player").upgrade_check = false


func _on_fire_rate_upgrade_pressed():
	get_node("/root/World/Player").fire_rate -= 0.025
	upgrade_end.emit()
	hide()
	get_node("/root/World/Player").upgrade_check = false

func _on_ammo_upgrade_pressed():
	get_node("/root/World/Player").MAX_PISTOLAMMO += 1
	upgrade_end.emit()
	hide()
	get_node("/root/World/Player").upgrade_check = false

func _on_reload_speed_upgrade_pressed():
	get_node("/root/World/Player").reload_speed -= 0.40
	upgrade_end.emit()
	hide()
	get_node("/root/World/Player").upgrade_check = false
	
func _on_world_upgrade_spawn():
	get_node("/root/World/Player").upgrade_check = true
	show()
