extends CharacterBody2D

@onready var speed = 250
@onready var is_player_1

@onready var target
@export var bullet_scene: PackedScene

func _input(event):
	if !is_player_1:
		return
	if event.is_action_pressed("click"):
		target = get_global_mouse_position()
		var bullet = bullet_scene.instantiate()
		owner.add_child(bullet)
		bullet.transform = $bullet_origin.global_transform

func _physics_process(delta):
	# this makes it so only player1 moves, i think do whatever shenanigans determine which player is which here
	# player 1 is determined by position in main.gd
	if !is_player_1:
		return

	look_at(get_global_mouse_position())

	var input_direction = Input.get_vector("left", "right", "up", "down")
	velocity = input_direction * speed
	
	move_and_slide()
