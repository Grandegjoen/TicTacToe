extends Node2D

var board = [0, 0, 0, 0, 0, 0, 0, 0, 0]

@onready var cross = preload("res://assets/Cross.png")
@onready var circle = preload("res://assets/Circle.png")

var cross_turn: bool = true
var can_play: bool = true

var cross_value = 1
var circle_value = 2

var number_of_loops = 0 # Used to test loops with and without alpha-beta pruning

var winning_combinations = [
	[0, 1, 2], [3, 4, 5], [6, 7, 8],  # Rows
	[0, 3, 6], [1, 4, 7], [2, 5, 8],  # Columns
	[0, 4, 8], [2, 4, 6]             # Diagonals
]

func _ready():
	$end_of_game_windows.visible = false
	random_first_player()
	for button in $buttons.get_children():
		button.pressed.connect(button_pressed.bind(button))

func game_result(winner):
	var result_text: String
	if winner == 0:
		result_text = "Tie!"
	elif winner == 1:
		result_text = "Cross Wins!"
	elif winner == 2:
		result_text = "Circle Wins!"
		
	for button in $buttons.get_children():
		button.disabled = true
	$end_of_game_windows/game_result.text = result_text
	$end_of_game_windows.visible = true
	

func button_pressed(button):
	if !can_play:
		return
	if cross_turn:
		place_cross(button.name)
		board[int(str(button.name))] = cross_value 
	else:
		place_circle(button.name)
		board[int(str(button.name))] = circle_value
	can_play = false
	check_results()

func place_cross(slot):
	get_node("slots/slot_" + slot).texture = cross
	get_node("buttons/" + slot).disabled = true
	cross_turn = false

func place_circle(slot):
	get_node("slots/slot_" + slot).texture = circle
	get_node("buttons/" + slot).disabled = true
	cross_turn = true

func check_results():
	for combination in winning_combinations:
		var cell1 = board[combination[0]]
		var cell2 = board[combination[1]]
		var cell3 = board[combination[2]]
		if cell1 != 0 and cell1 == cell2 and cell2 == cell3:
			game_result(cell1) # cell1 being 1 or 2, depending on winner.
			return
	if check_if_tie():
		game_result(0) # Tie
		return
	if !Gamestate.two_player and !cross_turn:
		ai_move()
	else:
		can_play = true

func check_if_tie():
	var tie = true
	for x in board:
		if x == 0:
			tie = false
	return tie

func random_first_player():
	var rng = RandomNumberGenerator.new()
	var random_number = rng.randi_range(1, 2)
	if random_number == 2:
		cross_turn = false
		if !Gamestate.two_player:
			ai_move()

func get_available_moves():
	var current_loop = 0
	var available_slots: Array
	for x in board:
		if x == 0:
			available_slots.append(current_loop)
		current_loop += 1
	return available_slots

func ai_move():
	if Gamestate.difficulty == "easy":
		easy_difficulty()
	elif Gamestate.difficulty == "standard":
		standard_difficulty()
	else:
		impossible_difficulty()
	cross_turn = true
	check_results()

func easy_difficulty():
	var available_slots: Array = get_available_moves()
	var rng = RandomNumberGenerator.new()
	var random_number = rng.randi_range(0, available_slots.size() - 1)
	place_circle(str(available_slots[random_number]))
	board[available_slots[random_number]] = circle_value

func standard_difficulty():
	var player_win = -1
	var ai_win = -1
	for combination in winning_combinations:
		var cell1 = board[combination[0]]
		var cell2 = board[combination[1]]
		var cell3 = board[combination[2]]

		# Check for player's potential win
		if cell1 == 1 and cell2 == 1 and cell3 == 0:
			player_win = combination[2]
		elif cell1 == 1 and cell2 == 0 and cell3 == 1:
			player_win = combination[1]
		elif cell1 == 0 and cell2 == 1 and cell3 == 1:
			player_win = combination[0]

		# Check for AI's potential win
		if cell1 == 2 and cell2 == 2 and cell3 == 0:
			ai_win = combination[2]
		elif cell1 == 2 and cell2 == 0 and cell3 == 2:
			ai_win = combination[1]
		elif cell1 == 0 and cell2 == 2 and cell3 == 2:
			ai_win = combination[0]

	# If AI can win, make the winning move
	if ai_win != -1:
		place_circle(str(ai_win))
		board[ai_win] = circle_value

	# If player can win, block the player
	elif player_win != -1:
		place_circle(str(player_win))
		board[player_win] = circle_value
	
	# Else just make a random play using easy_difficulty function
	else:
		easy_difficulty()
		return

func check_empty_board():
	for x in board:
		if x != 0:
			return false
	return true

func impossible_difficulty():
	if check_empty_board():
		easy_difficulty()
		return
	var best_move = -1
	var best_score = -INF
	var current_loop = 0
	number_of_loops = 0

	for slot in board:
		if slot == 0:
			board[current_loop] = circle_value # Make temporary change to the board
			var score = minimax(board, 0, false, -INF, INF)
			board[current_loop] = 0 # Undo the move on the board
			if score > best_score: # If the minmax value is higher than previous best, replace it.
				best_score = score
				best_move = current_loop
		current_loop += 1
	print(number_of_loops)
	place_circle(str(best_move))
	board[best_move] = circle_value


func minimax(board, depth, maximizing_player, alpha, beta):
	number_of_loops += 1
	var max_player = circle_value # AI
	var min_player = cross_value # Human player

	if check_winner(max_player):
		return 10
	elif check_winner(min_player):
		return -10
	elif is_board_full():
		return 0

	if maximizing_player:
		var best_score = -1000
		var current_loop = 0

		for slot in board: # Traverse all possible moves
			if slot == 0:
				board[current_loop] = max_player # Make a temporary move
				var score = minimax(board, depth + 1, !maximizing_player, alpha, beta) 
				board[current_loop] = 0 # Undo the move
				best_score = max(score, best_score)
				alpha = max(alpha, best_score)
				if beta <= alpha:
					break # Beta cutoff
			current_loop += 1
		return best_score
	else:
		var best_score = 1000
		var current_loop = 0

		for slot in board: # Traverse all possible moves
			if slot == 0:
				board[current_loop] = min_player # Make a temporary move
				var score = minimax(board, depth + 1, !maximizing_player, alpha, beta)
				board[current_loop] = 0 # Undo the move
				best_score = min(score, best_score)
				beta = min(beta, best_score)
				if beta <= alpha:
					break # Alpha cutoff
			current_loop += 1
		return best_score

func check_winner(player):
	for combo in winning_combinations:
		var count = 0
		for cell in combo:
			if board[cell] == player:
				count += 1
		if count == 3:
			return true
	return false

func is_board_full():
	return not board.has(0)

# Here's the old minimax algorithm without alpha-beta pruning.
#func impossible_difficulty():
#	if check_empty_board():
#		easy_difficulty()
#		return
#	var best_move = -1
#	var best_score = -INF
#	var current_loop = 0
#	number_of_loops = 0
#	for slot in board:
#		if slot == 0:
#			board[current_loop] = circle_value # Make temporary change to the board
#			var score = minimax(board, 0, false)
#			board[current_loop] = 0 # Undo the move on the board
#			if score > best_score: # If the minmax value is higher than previous best, replace it.
#				best_score = score
#				best_move = current_loop
#				print(best_score)
#				print(best_move)
#				print("\n")
#		current_loop += 1
#	print(number_of_loops)
#	place_circle(str(best_move))
#	board[best_move] = circle_value
#
#
#func minimax(board, depth, maximizing_player):
#	number_of_loops += 1
#	var max_player = circle_value # AI
#	var min_player = cross_value # Human player
#
#	if check_winner(max_player):
#		return 10
#	elif check_winner(min_player):
#		return -10
#	elif is_board_full():
#		return 0
#
#	if maximizing_player:
#		var best_score = -1000
#		var current_loop = 0
#
#		for slot in board: # Traverse all possible moves
#			if slot == 0:
#				board[current_loop] = max_player # Make a temporary move
#				var score = minimax(board, depth + 1, !maximizing_player) 
#				board[current_loop] = 0 # Undo the move
#				if score > best_score:
#					best_score = score
#			current_loop += 1
#		return best_score
#	else:
#		var best_score = 1000
#		var current_loop = 0
#
#		for slot in board: # Traverse all possible moves
#			if slot == 0:
#				board[current_loop] = min_player # Make a temporary move
#				var score = minimax(board, depth + 1, !maximizing_player)
#				board[current_loop] = 0 # Undo the move
#				if score < best_score:
#					best_score = score
#			current_loop += 1
#		return best_score
#
#func check_winner(player):
#	for combo in winning_combinations:
#		var count = 0
#		for cell in combo:
#			if board[cell] == player:
#				count += 1
#		if count == 3:
#			return true
#	return false
#
#func is_board_full():
#	return not board.has(0)


func _on_retry_button_pressed():
	get_tree().reload_current_scene()

func _on_return_to_menu_pressed():
	get_tree().change_scene_to_file("res://scenes/main.tscn")
