extends Area2D

var speed = 1700

var screen_size


func _physics_process(delta):
	position += transform.x * speed * delta


func _ready() -> void:
	#Despawns the bullet after 30 secs
	screen_size = get_viewport_rect().size
	set_meta("pistolbullet",1)
	await get_tree().create_timer(30).timeout
	queue_free()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _on_area_entered(area):
	#Despawns the bullet after hitting enemy
	if area.has_meta("enemy_collision"):
		queue_free()
