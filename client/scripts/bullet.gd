extends Area2D

var speed = 400

func _physics_process(delta):
	position += transform.x * speed * delta

func _on_body_entered(body: Node2D) -> void:
	body.owner.is_dead = body
	#print(body.owner.is_dead)
	queue_free()
