extends Node2D

func _ready():
	if $player1.position.x < 640:
		$player1.is_player_1 = true
		$player2.is_player_1 = false
	else:
		$player1.is_player_1 = false
		$player2.is_player_1 = true
