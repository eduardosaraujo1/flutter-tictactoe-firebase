import 'package:flutter/material.dart';
import 'package:flutter_questions_app/services/auth.dart';
import 'package:flutter_questions_app/pages/game.dart';
import 'package:flutter_questions_app/pages/auth.dart';

class WidgetTree extends StatefulWidget {
  const WidgetTree({super.key});

  @override
  State<WidgetTree> createState() => _WidgetTreeState();
}

class _WidgetTreeState extends State<WidgetTree> {
  @override
  Widget build(BuildContext context) {
    if (AuthService().currentUser != null) {
      return TicTacToe();
    } else {
      return LoginPage();
    }
  }
}
