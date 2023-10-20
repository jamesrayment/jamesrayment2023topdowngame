extends Node2D

@onready var global = get_node("/root/Global")

var enemy = preload("res://enemy.tscn")
var particles = preload("res://cpu_particles_2d.tscn")
var player = preload("res://Player.gd")

#How many enemies are in the scene
var enemies = 1

#How many enemies have been killed
var enemies_killed = 0

#Signals the start of the wave
signal wave_start

#Wave number
var wave = 1

#Enemies per wave
var enemies_per_wave = wave * 5

#Emit the signal to start the upgrade process
var upgrade_emit = false

signal upgrade_spawn

#Signals for the start and end of pause
signal pause
signal pause_end

#Checks whether game is paused 
var pause_check = false

# Called when the node enters the scene tree for the first time.
func _ready():
	$SpawnTimer.start()
	
	get_tree().paused = false
	
	
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Input.is_action_just_released("esc") and pause_check  == false:
		pause.emit()
		get_tree().paused = true
		pause_check = true
		print(get_tree().paused)
	else:
		return
		
		


func _on_enemy_enemy_death():
	enemies_killed += 1
	enemies -= 1
	print(enemies_killed)
	if enemies_killed == enemies_per_wave:
		$SpawnTimer.stop()
		enemies_killed = 0
		upgrade_spawn.emit()
		var enemy_group = get_tree().get_nodes_in_group("enemies")
		for enemy in enemy_group:
			enemy.queue_free()
		
	

func _on_timer_timeout():
	var enemy_spawn = enemy.instantiate()
	add_child(enemy_spawn)
	enemies += 1
	$SpawnTimer.start()


func _on_upgrade_spawn():
	enemies = 0
	var enemy_spawn = enemy.instantiate()


func _on_control_upgrade_end():
	wave += 1
	global.speed += 20 * wave
	wave_start.emit()
	enemies_killed = 0
	enemies_per_wave = wave * 5
	$SpawnTimer.start()


func _on_pause_world_unpause():
	pause_check = true
	await get_tree().create_timer(0.1).timeout
	pause_check = false
