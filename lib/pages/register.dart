import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_questions_app/services/auth.dart';
import 'package:flutter/material.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  String _errorMessage = '';

  final TextEditingController _controllerEmail = TextEditingController();
  final TextEditingController _controllerPassword = TextEditingController();

  void signup(BuildContext context) async {
    try {
      await AuthService().signup(
        _controllerEmail.text,
        _controllerPassword.text,
      );
      if (FirebaseAuth.instance.currentUser != null) {
        Navigator.pushReplacementNamed(context, '/info');
      }
    } on FirebaseAuthException catch (e) {
      String msg = "";
      if (e.code == 'weak-password') {
        msg = "Digite uma senha mais forte";
      } else if (e.code == 'email-already-in-use') {
        msg = "Este e-mail já está sendo utilizado";
      } else {
        msg = "Ocorreu um erro. Tente novamente mais tarde";
      }
      setState(() {
        _errorMessage = msg;
      });
    } catch (e) {
      print(e);
      setState(() {
        _errorMessage = "Ocorreu um erro de conexão. Tente novamente.";
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

  Widget _linkNavigator(
      String content, String routeName, BuildContext context) {
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

  Widget _registerButton(context) {
    return ElevatedButton(
      onPressed: () => signup(context),
      child: Text("Registrar-se"),
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
          _linkNavigator("Já tenho uma conta", '/login', context),
          _breakLine(16),
          _registerButton(context),
        ],
      ),
    );
  }
}
