# TicTacToe

Simple Tic Tac Toe game with three difficulties:

<h3>Easy:</h3> 
- Places pieces randomly

<h3>Standard:</h3> 
- Checks if AI or human is one piece away from winning, and places the winning move or prevents the player from winning. Can still be beaten.

<h3>Impossible:</h3> 
- Uses minimax algorithm to make the best possible move, making it impossible to beat. The best you can hope for is a tie.<br>
- Also implemented Alpha-Beta Pruning, lowering the computation cost significantly. AI's first move without Alpha-Beta Pruning requires it to run through 55504 possible scenarioes, whereas Alpha-Pruning allows it to only use about 5000~.


You can also select two player mode, allowing you to play against someone else.
