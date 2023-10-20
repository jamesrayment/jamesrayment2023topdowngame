extends Control

var pause = false

signal world_unpause
# Called when the node enters the scene tree for the first time.
func _ready():
	pause = false
	hide()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	#Unpauses the game
	if Input.is_action_just_pressed("esc") and pause == true:
		get_tree().paused = false
		print(get_tree().paused)
		pause = false
		await get_tree().create_timer(0.1).timeout
		hide()
		world_unpause.emit()

#Activated upon the mmenu button being pressed
func _on_pause_button_pressed():
	get_tree().change_scene_to_file("res://main_menu.tscn")
	get_tree().paused = false
	hide()

#Received upon the pause signal being emitted from the world scene
func _on_world_pause():
	show()
	pause = true


func _on_world_pause_end():
	hide()
	pause = false
