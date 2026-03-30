extends Area2D

var speed = 400

func _physics_process(delta):
	position += transform.x * speed * delta
	if position.x > 1280 or position.x < 0 or position.y > 720 or position.y < 0:
		queue_free()

func _on_body_entered(body: Node2D) -> void:
	
	
	if body.health <= 0:
		body.owner.is_dead = body
	#print(body.owner.is_dead)
	body.health -= 20
	
	queue_free()
