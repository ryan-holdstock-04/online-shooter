extends Node2D

var socket = WebSocketPeer.new()
var last_state = WebSocketPeer.STATE_CLOSED
var state = socket.get_ready_state()
@onready var is_dead = null
@onready var has_bullet = false

@export var bullet_scene: PackedScene

var url = "ws://localhost:8080"
var data = {
	"position" : [320,360],
	"id" : 0
}

var player1x = []
var player1y = []

var isConnected = false

func _ready():
	
	var err = socket.connect_to_url(url)
	
	if $player1.position.x < 640:
		$player1.is_player_1 = true
		$player2.is_player_1 = false
	else:
		$player1.is_player_1 = false
		$player2.is_player_1 = true


func _process(delta):
	# print(is_dead)
	if is_dead != null:
		is_dead.queue_free()
		print("dead")

	print(get_global_mouse_position())
	
	
	socket.poll()
	
	
	var packet = socket.get_packet()
	var message = packet.get_string_from_utf8()
	
	if(isConnected):
		message = JSON.parse_string(message)
	
	if (!isConnected && message == "connected"):
		#print("Connection Successful")
		isConnected = true
		var msg = JSON.stringify({"action": "get_id"})
		socket.send_text(msg)
	
	# send bullet to server
	if has_bullet != null:
		var msg = JSON.stringify({"action":"bullet", "cords":has_bullet, "id":data.id})
		socket.send_text(msg)
		has_bullet = null
		
	
	if (message is Dictionary):
		if(message.has("newId")):
			#print("You are player: " + message.newId)
			data["id"] = message.newId
		elif (message.has("action")):
			if (message.action == "newPosition"):
				if (int(data.id) != int(message.id)):
					
					var noMirrorX = int(message.position[0]) + 640
					
					# mirror player 2 x position
					$player2.position.x = 1280 - int(message.position[0])
					$player2.position.y = int(message.position[1]);
			if(message.action == "bullet"):
				if (int(data.id) != int(message.id)):
					print(message.cords)
					$player2.target = message.cords
					var bullet = bullet_scene.instantiate()
					add_child(bullet)
					bullet.transform = $player2.bullet_origin.global_transform
					
					
					#send a bullet from player 2
				
				
					
					
					#print("Player 2 new position", message.position[0], "," ,message.position[1]);
	
	#print("X:", $player1.position.x)
	#print("y:", $player1.position.y)
	
	player1x.append($player1.position.x)
	player1y.append($player1.position.y)
	
	if (len(player1x) == 3 && len(player1y) == 3):
		player1x.remove_at(0)
		player1y.remove_at(0)
	
	if (len(player1x) == 2 && (player1x[0] != player1x[1])):
		var msg = JSON.stringify({"action":"update_x_position", "x": player1x[0], "id":data["id"]});
		socket.send_text(msg);
	
	if (len(player1y) == 2 && (player1y[0] != player1y[1])):
		var msg = JSON.stringify({"action":"update_y_position", "y": player1y[0], "id":data["id"]});
		socket.send_text(msg);
	
	
func _notification(what):
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		if socket.get_ready_state() == WebSocketPeer.STATE_OPEN:
			socket.close(1000, String(data.id))
			print("Closing socket...")
		
		get_tree().quit()
