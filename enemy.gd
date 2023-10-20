extends Area2D

var health = 50

@onready var global = get_node("/root/Global")

@onready var damage = global.damage
@onready var speed = global.speed

signal enemy_death

var wave = 1

var particles = preload("res://cpu_particles_2d.tscn")
@export var particle_spawn: PackedScene

var enemy = preload("res://enemy.tscn")
@export var enemy_spawn: PackedScene

# Called when the node enters the scene tree for the first time.
func _ready():
	set_meta("enemy_collision",1)
	add_to_group("enemies")
	enemy_death.connect(get_node("/root/World")._on_enemy_enemy_death)
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	look_at(get_node("/root/World/Player").global_position)
	move_local_x(speed * delta)
	if health <= 0:
		enemy_death.emit()
		queue_free()



#Enemy takes damage if hit by a bullet
func _on_area_entered(area):
	if area.has_meta("pistolbullet"):
		health -= damage
		var particle_spawn = particles.instantiate()
		add_child(particle_spawn)
		await get_tree().create_timer(0.2).timeout
		remove_child(particle_spawn)
		
		

#Deletes the enemy upon the upgrades spawning
func _on_world_upgrade_spawn():
	queue_free()


func _on_world_wave_start():
	wave += 1
	
