extends CharacterBody2D

@onready var speed = 250
@onready var is_player_1
@onready var health = 100
#@onready var is_dead = false
@onready var sprite = $sprite
@onready var hitbox = $hitbox
@onready var target
@export var bullet_scene: PackedScene
@onready var can_shoot = true
@onready var bullet_origin = $bullet_origin
@onready var bullet_cd = $bullet_cd

func _on_bullet_cd_timeout():
	can_shoot = true

func _input(event):
	# same as below, makes it so only player1 shoots
	if !is_player_1:
		return
	if event.is_action_pressed("click") and can_shoot:
		target = get_global_mouse_position()
		var bullet = bullet_scene.instantiate()
		owner.add_child(bullet)
		bullet.transform = $bullet_origin.global_transform
		owner.has_bullet = get_global_mouse_position()
		can_shoot = false
		if bullet_cd.is_stopped():
			bullet_cd.start()

func _physics_process(delta):
	# this makes it so only player1 moves, i think do whatever shenanigans determine which player is which here
	# player 1 is determined by position in main.gd
	if !is_player_1:
		return

	look_at(get_global_mouse_position())

	var input_direction = Input.get_vector("left", "right", "up", "down")
	velocity = input_direction * speed

	move_and_slide()
	position.x = clamp(position.x, 0+sprite.texture.get_width()/2, 1280-sprite.texture.get_width()/2)
	position.y = clamp(position.y, 0+sprite.texture.get_height()/2, 720-sprite.texture.get_height()/2)
	
