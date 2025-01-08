import 'package:flutter/material.dart';

import 'dart:math';

import 'package:flutter_questions_app/services/auth.dart';

class TicTacToe extends StatefulWidget {
  const TicTacToe({super.key});

  @override
  State<TicTacToe> createState() => _TicTacToeState();
}

class _TicTacToeState extends State<TicTacToe> {
  List<String> board = List.filled(9, '');
  bool isPlayerTurn = true;
  int playerScore = 0;
  int computerScore = 0;

  void resetBoard() {
    setState(() {
      board = List.filled(9, '');
      isPlayerTurn = true;
    });
  }

  void checkWinner() {
    const winningCombinations = [
      [0, 1, 2],
      [3, 4, 5],
      [6, 7, 8],
      [0, 3, 6],
      [1, 4, 7],
      [2, 5, 8],
      [0, 4, 8],
      [2, 4, 6]
    ];

    for (var combo in winningCombinations) {
      if (board[combo[0]] != '' &&
          board[combo[0]] == board[combo[1]] &&
          board[combo[1]] == board[combo[2]]) {
        if (board[combo[0]] == 'X') {
          playerScore++;
        } else {
          computerScore++;
        }
        resetBoard();
      }
    }

    if (!board.contains('')) {
      resetBoard();
    }
  }

  void botMove() {
    List<int> emptySpaces = [];
    for (int i = 0; i < board.length; i++) {
      if (board[i] == '') {
        emptySpaces.add(i);
      }
    }

    if (emptySpaces.isNotEmpty) {
      // int move = emptySpaces[Random().nextInt(emptySpaces.length)];
      int move = minmaxBestMove(board);
      setState(() {
        board[move] = 'O';
        isPlayerTurn = true;
      });
    }
    checkWinner();
  }

  void playerMove(int index) {
    if (board[index] == '' && isPlayerTurn) {
      setState(() {
        board[index] = 'X';
        isPlayerTurn = false;
      });
      checkWinner();
      Future.delayed(Duration(milliseconds: 500), botMove);
    }
  }

  Widget _buildCell(index) {
    return GestureDetector(
      onTap: () => playerMove(index),
      child: Container(
        alignment: Alignment.center,
        margin: EdgeInsets.all(4.0),
        decoration: BoxDecoration(
          color: Colors.blueAccent,
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: Text(
          board[index],
          style: TextStyle(
            fontSize: 48,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  void leave() async {
    await AuthService().signout();
    if (AuthService().currentUser == null) {
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Jogo da velha'),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Jogador: $playerScore',
            style: TextStyle(fontSize: 24),
          ),
          Text(
            'IA: $computerScore',
            style: TextStyle(fontSize: 24),
          ),
          Expanded(
            child: GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
              ),
              itemCount: 9,
              itemBuilder: (context, index) {
                return _buildCell(index);
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: leave,
        child: Icon(Icons.logout),
      ),
    );
  }
}

int evaluate(board) {
  const winningCombinations = [
    [0, 1, 2],
    [3, 4, 5],
    [6, 7, 8],
    [0, 3, 6],
    [1, 4, 7],
    [2, 5, 8],
    [0, 4, 8],
    [2, 4, 6]
  ];

  for (var combo in winningCombinations) {
    if (board[combo[0]] != '' &&
        board[combo[0]] == board[combo[1]] &&
        board[combo[1]] == board[combo[2]]) {
      if (board[combo[0]] == 'O') {
        return 10;
      } else {
        return -10;
      }
    }
  }

  return 0;
}

bool gameIsTie(List<String> board) {
  return !board.contains('');
}

int minmax(List<String> board, int depth, bool isMax) {
  int score = evaluate(board);

  if (score != 0) {
    return score;
  }

  if (gameIsTie(board)) {
    return 0;
  }

  // Without checking, the "best" we have is the worst
  int best = isMax ? -1000 : 1000;
  String curPlayer = isMax ? 'O' : 'X';
  Function evalFunc = isMax
      ? max
      : min; // If current player is maximizer, must get bigger points (max), otherwise, must get the smallest points (min)

  for (int i = 0; i < board.length; i++) {
    if (board[i] != '') {
      continue;
    }

    // Make the move
    board[i] = curPlayer;
    // See if the move leads to success or failure, if result is worse than previous ones discart
    best = evalFunc(best, minmax(board, depth + 1, !isMax));
    // Unmake the move
    board[i] = '';
  }

  return best;
}

int minmaxBestMove(List<String> board) {
  int bestVal = -1000;
  int bestMove = -1;

  for (int i = 0; i < board.length; i++) {
    if (board[i] != '') {
      continue;
    }

    board[i] = 'O';
    int moveVal = minmax(board, 0, false);
    board[i] = '';

    if (moveVal > bestVal) {
      bestMove = i;
      bestVal = moveVal;
    }
  }

  return bestMove;
}
