import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_questions_app/services/auth.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  String _errorMessage = '';

  final TextEditingController _controllerEmail = TextEditingController();
  final TextEditingController _controllerPassword = TextEditingController();

  void signin() async {
    try {
      await AuthService().signin(
        _controllerEmail.text,
        _controllerPassword.text,
      );
      print("Signed in, trying to navigate away");
      if (FirebaseAuth.instance.currentUser != null) {
        Navigator.pushReplacementNamed(context, '/info');
      }
    } on FirebaseAuthException catch (e) {
      print(e.code);
      String msg = "";
      if (e.code == 'channel-error') {
        msg = "Usuário ou senha incorreto";
      } else if (e.code == 'invalid-credential') {
        msg = "Senha incorreta";
      } else {
        msg = "Ocorreu um erro. Tente novamente mais tarde";
      }
      setState(() {
        _errorMessage = msg;
      });
    }
  }

  Widget _input(String label, TextEditingController controller,
      [bool isPassword = false]) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: TextField(
        controller: controller,
        autocorrect: false,
        obscureText: isPassword,
        decoration: InputDecoration(
          labelText: label,
        ),
      ),
    );
  }

  Widget _linkNavigator(String content, String routeName) {
    return GestureDetector(
      onTap: () {
        Navigator.pushReplacementNamed(context, routeName);
      },
      child: Text(
        content,
        style: TextStyle(
          color: Colors.blue,
          decoration: TextDecoration.underline,
        ),
      ),
    );
  }

  Widget _actionButton(String label) {
    return ElevatedButton(
      onPressed: signin,
      child: Text(label),
    );
  }

  Widget _breakLine(double space) {
    return Padding(
      padding: EdgeInsets.only(top: space),
    );
  }

  Widget _showError() {
    return Text(
      _errorMessage,
      style: TextStyle(
        color: Colors.red.shade900,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Bem-vindo!",
          textScaler: TextScaler.linear(1.5),
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.grey.shade200,
      ),
      body: ListView(
        padding: EdgeInsets.all(16),
        children: [
          if (_errorMessage != "") _showError(),
          _input("E-mail", _controllerEmail),
          _input("Senha", _controllerPassword, true),
          _linkNavigator("Não tenho uma conta", '/register'),
          _breakLine(16),
          _actionButton("Entrar"),
        ],
      ),
    );
  }
}
