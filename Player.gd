extends CharacterBody2D

#Health variables
const MAX_HEALTH = 100
var health = MAX_HEALTH

#Stamina Variables
const MAX_STAMINA = 100
var stamina = MAX_STAMINA

#Ammo variables
var MAX_PISTOLAMMO = 9 
var current_pistolammo = MAX_PISTOLAMMO 
var reserve_pistolammo = 999

#Variable checks whether player is realoading or not
var pause = false

#Wave Number
var wave = 1

#Checks for reloading and whether an upgrade is in progress
var reload_check = false
var upgrade_check = false

#Fire rate and reload speed
var fire_rate = 0.25
var reload_speed = 2

#Check for if stamina is decreasing
var decrease = true

#Speed of player pixels/sec 
var speed = 600  
#Speed bonus on sprinting
var speed_bonus = 450
#Speed of shells
var shell_speed = 2000
var shell = preload("res://shell.tscn")
@export var bullet: PackedScene

func _ready() -> void:
	
	upgrade_check = false
	reload_check = true
	
	set_health_label()
	get_node("/root/World/Player/Camera2D/Healthbar").max_value = MAX_HEALTH
	set_health_bar()
	set_stamina_label()
	get_node("/root/World/Player/Camera2D/Staminabar").max_value = MAX_STAMINA
	set_stamina_bar()

func set_health_label() -> void:
	get_node("/root/World/Player/Camera2D/HealthLabel").text = "Health: %s" % health

func set_health_bar() -> void:
	get_node("/root/World/Player/Camera2D/Healthbar").value = health

func set_stamina_label() -> void:
	get_node("/root/World/Player/Camera2D/StaminaLabel").text = "Stamina: %s" % stamina

func set_stamina_bar() -> void:
	get_node("/root/World/Player/Camera2D/Staminabar").value = stamina
	
func set_ammo_label() -> void:
	get_node("/root/World/Player/Camera2D/AmmoLabel").text = str(var_to_str(current_pistolammo))

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept"):
		damage()

func damage() -> void:
	#Removes health when damage is taken
	health -= 1
	if health <= 0:
		health = 0
		set_health_label()
		set_health_bar()
	
func stamina_decrease() -> void:
	#Code for stamina decrease
	decrease = true
	speed = 1050
	if stamina > 0 and speed > 600:
		stamina -= 1
		set_stamina_label()
		set_stamina_bar()
		await get_tree().create_timer(1).timeout
	if stamina <= 0:
		Input.is_action_just_released("is_sprinting")
		decrease = false

func _physics_process(delta):
	#Code for movement
	var direction = Input.get_vector("left", "right", "up", "down")
	velocity = direction * speed
	move_and_slide()
	
	if pause == true:
		pass
	
	if not Input.is_action_pressed("is_sprinting"):
		#Code for stamina increase
		if stamina < 100:
			set_stamina_label()
			set_stamina_bar()
			stamina_increase()
			set_stamina_label()
			set_stamina_bar()
		
	#Cause player to look at the mouse position
	$Sprite2D.look_at(get_global_mouse_position())
	velocity = transform.x * speed
	
	#Stamina checks
	if Input.is_action_pressed("is_sprinting"):
		decrease = true
		stamina_decrease()
	if Input.is_action_just_released("is_sprinting") or stamina == 0:
		decrease = false
		speed = 600
		
	#Code for shooting
	if Input.is_action_pressed("LMB") and pause == false and upgrade_check == false:
		current_pistolammo -= 1
		set_ammo_label()
		if current_pistolammo > 0:
			shoot()
			fire()
			pause = true
			await get_tree().create_timer(fire_rate).timeout
			pause = false
		else:
			current_pistolammo = 0
			set_ammo_label()
			reload()
			set_ammo_label()
			
	#Reload check
	if Input.is_action_pressed("reload") and pause == false:
		reload()
	else:
		return


#Function thar spawns in shells
func fire():
	var shell_instance = shell.instantiate()
	shell_instance.position = $Sprite2D/shell_spawn.get_global_position()
	shell_instance.rotation_degrees = $Sprite2D.rotation_degrees
	shell_instance.apply_impulse(Vector2(),Vector2(shell_speed,0).rotated(rotation))
	get_tree().get_root().call_deferred("add_child",shell_instance)

#Function thar spawns in bullets
func shoot():
	var b = bullet.instantiate()
	b.position = $Sprite2D/bullet_spawn.global_position
	b.rotation = $Sprite2D.rotation
	get_tree().get_current_scene().add_sibling(b)

#FUnction for reloading
func reload():
	reload_check = true
	pause = true
	if reload_check == true:
		reload_check = false
		await get_tree().create_timer(reload_speed).timeout
		reserve_pistolammo -= MAX_PISTOLAMMO - current_pistolammo
		current_pistolammo = MAX_PISTOLAMMO
		set_ammo_label()
		reload_check = false
		reserve_pistolammo = 999
		pause = false
		if reserve_pistolammo < 9:
			current_pistolammo += reserve_pistolammo 
			reserve_pistolammo = 0
			set_ammo_label()
			pause = false
			if current_pistolammo > 9:
				current_pistolammo = 9
				set_ammo_label()
				pause = false

#Function for stamina increase
func stamina_increase():
	if stamina < 100 and decrease == false:
		await get_tree().create_timer(3).timeout
		stamina += 1
		set_stamina_label()
		set_stamina_bar()
	if stamina > 100:
		stamina = MAX_STAMINA
		set_stamina_label()
		set_stamina_bar()

#Function for enemy collision
func _on_area_2d_area_entered(area):
	if area.has_meta("enemy_collision"):
		health -= 2 * wave
		set_health_bar()
		set_health_label()
	if health <= 0:
		health = 0
		set_health_bar()
		set_health_label()
		get_tree().change_scene_to_file("res://main_menu.tscn")

#Function for counting waves
func _on_world_wave_start():
	wave += 1
