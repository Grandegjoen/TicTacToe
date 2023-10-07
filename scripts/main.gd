extends Node

var board = preload("res://scenes/board.tscn")

func _ready():
	Gamestate.two_player = false

func _on_one_player_pressed():
	$player_select.visible = false
	$difficulty_select.visible = true

func _on_two_player_pressed():
	Gamestate.two_player = true
	get_tree().change_scene_to_file("res://scenes/board.tscn")


func _on_easy_difficulty_pressed():
	Gamestate.difficulty = "easy"
	get_tree().change_scene_to_file("res://scenes/board.tscn")


func _on_standard_difficulty_pressed():
	Gamestate.difficulty = "standard"
	get_tree().change_scene_to_file("res://scenes/board.tscn")


func _on_impossible_difficulty_pressed():
	Gamestate.difficulty = "impossible"
	get_tree().change_scene_to_file("res://scenes/board.tscn")


func _on_go_back_pressed():
	$player_select.visible = true
	$difficulty_select.visible = false
