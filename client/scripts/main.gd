extends Node2D

var socket = WebSocketPeer.new()
var last_state = WebSocketPeer.STATE_CLOSED

@onready var is_dead = null
@onready var has_bullet = false

@export var bullet_scene: PackedScene

@onready var player1_health = $global_ui/health_bars/health_bars_hbox/player_1_health
@onready var player2_health = $global_ui/health_bars/health_bars_hbox/player_2_health
@onready var player1_hp_colors = player1_health.get_theme_stylebox("fill") as StyleBoxFlat
@onready var player2_hp_colors = player2_health.get_theme_stylebox("fill") as StyleBoxFlat
var url = "ws://76.196.202.79:80"
var data = {
	"position" : [320,360],
	"id" : 0
}

var player1x = []
var player1y = []
var player1mouse = []
var playerHealth = []

var isConnected = false

func _ready():
	player1_hp_colors.bg_color = Color.GREEN
	player2_hp_colors.bg_color = Color.GREEN
	socket.connect_to_url(url)
	
	if $player1.position.x < 640:
		$player1.is_player_1 = true
		$player2.is_player_1 = false
	else:
		$player1.is_player_1 = false
		$player2.is_player_1 = true


func _process(delta):
	
	socket.poll()
	var state = socket.get_ready_state()

	
	if (state == WebSocketPeer.STATE_OPEN):
		while socket.get_available_packet_count() > 0:
			var packet = socket.get_packet()
			var message = packet.get_string_from_utf8()
	
			if(isConnected):
				message = JSON.parse_string(message)
			
			if (!isConnected && message == "connected"):
				isConnected = true
				var msg = JSON.stringify({"action": "get_id"})
				socket.send_text(msg)
						
			if (message is Dictionary):
				if(message.has("newId")):
					print("You are player: " + message.newId)
					data["id"] = message.newId
				elif (message.has("action")):
					if (message.action == "newPosition"):
						if (int(data.id) != int(message.id)):
							# mirror player 2 x position
							$player2.position.x = 1280 - int(message.position[0])
							$player2.position.y = int(message.position[1]);
					if(message.action == "bullet"):
						if (int(data.id) != int(message.id)):
							var screen_size = get_viewport_rect().size
							var center_point = screen_size / 2.0
							var bullet = bullet_scene.instantiate()
							add_child(bullet)
							var cords = message.cords
							var clean_string = cords.replace("(", "").replace(")", "")
							var string_parts = clean_string.split(",")
							var target_cords = Vector2(float(string_parts[0]), float(string_parts[1]))
							var mirrored_x = (center_point.x * 2.0) - target_cords.x
							var mirrored_cords = Vector2(mirrored_x, target_cords.y)
							$player2.look_at(mirrored_cords)
							bullet.transform = $player2.bullet_origin.global_transform
					if (message.action == "update_health"):
						if (int(data.id) != int(message.id)):
							var health = int(message.newhealth)
							$player1.health = health
							player1_health.value = health
	
	player1x.append($player1.position.x)
	player1y.append($player1.position.y)
	playerHealth.append($player2.health)
	
	
	if is_dead != null:
		is_dead.queue_free()
		print("dead")
	
	if (len(playerHealth) == 3):
		playerHealth.remove_at(0)
	
	if (len(playerHealth) == 2 && (playerHealth[0] != playerHealth[1])):
		var msg = JSON.stringify({"action":"update_health", "newhealth":playerHealth[1], "id":data.id})
		socket.send_text(msg)
		player2_health.value = playerHealth[1]
	
	# send bullet to server
	if has_bullet != null:
		var msg = JSON.stringify({"action":"bullet", "cords":get_global_mouse_position(), "id":data.id})
		socket.send_text(msg)
		has_bullet = null
	
	if (len(player1x) == 3 && len(player1y) == 3):
		player1x.remove_at(0)
		player1y.remove_at(0)
	
	if (len(player1x) == 2 && (player1x[0] != player1x[1])):
		var msg = JSON.stringify({"action":"update_x_position", "x": player1x[0], "id":data["id"]})
		socket.send_text(msg)
	
	if (len(player1y) == 2 && (player1y[0] != player1y[1])):
		var msg = JSON.stringify({"action":"update_y_position", "y": player1y[0], "id":data["id"]})
		socket.send_text(msg)
	
	
func _notification(what):
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		if socket.get_ready_state() == WebSocketPeer.STATE_OPEN:
			socket.close(1000, String(data.id))
			print("Closing socket...")
		
		get_tree().quit()
