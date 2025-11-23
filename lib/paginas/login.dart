import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:souseleto/paginas/userPadrao.dart';
import '../configs/auth.dart';
import 'add_user.dart';
import 'alunos/add_aluno.dart';
import 'home.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final TextEditingController _emailcontroller = TextEditingController();
  final TextEditingController _senhacontroller = TextEditingController();
  bool _obscureText = true;
  bool _isLoading = false;

  void _toggleObscureText() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  void _showSnackbar(BuildContext context, String message) {
    const Color darkGreen = Color(0xFF388E3C);

    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: darkGreen,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 4),
      ),
    );
  }

  void _attemptLogin() async {
    final email = _emailcontroller.text.trim();
    final senha = _senhacontroller.text;

    if (email.isEmpty && senha.isEmpty) {
      _showSnackbar(context, 'Por favor, preencha o email e a senha.');
      return;
    }
    if (email.isEmpty) {
      _showSnackbar(context, 'Por favor, preencha o email.');
      return;
    }
    if (senha.isEmpty) {
      _showSnackbar(context, 'Por favor, preencha a senha.');
      return;
    }


    setState(() { _isLoading = true; });

    final message = await AuthService().login(
      email: email,
      senha: senha,
    );

    setState(() { _isLoading = false; });

    if (message != null && message.contains('Successo')) {
      _showSnackbar(context, 'Login realizado com sucesso!');
      _handleLoginScenario();
    } else {
      _showSnackbar(context, 'Falha no Login: ${message ?? 'Erro desconhecido'}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/escudo.png',
              width: 80,
              height: 80,
            ),
            SizedBox(height: 35),
            Text(
              "SouSeleto App",
              style: TextStyle(
                color: Colors.white,
                fontSize: 35,
                fontWeight: FontWeight.bold,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
        toolbarHeight: 100,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.black, Colors.green],
              stops: [0.5, 0.5],
            ),
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(Icons.person, size: 100, color: Colors.black),
              SizedBox(height: 20),
              Text("EMAIL", style: TextStyle(fontSize: 15)),
              SizedBox(
                width: 200,
                child: TextField(
                  controller: _emailcontroller,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'DIGITE SEU EMAIL',
                  ),
                ),
              ),
              SizedBox(height: 20),
              Text("SENHA", style: TextStyle(fontSize: 15)),
              SizedBox(
                width: 200,
                child: TextField(
                  controller: _senhacontroller,
                  obscureText: _obscureText,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'DIGITE SUA SENHA',
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureText
                            ? Icons.visibility
                            : Icons.visibility_off,
                      ),
                      onPressed: _toggleObscureText,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _isLoading ? null : _attemptLogin,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                ),
                child: _isLoading
                    ? SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 3,
                  ),
                )
                    : const Text(
                  'ENTRAR',
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleLoginScenario() async {
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      QuerySnapshot userQuery = await FirebaseFirestore.instance
          .collection('Usuarios')
          .where('userId', isEqualTo: user.uid)
          .get();

      if (userQuery.docs.isEmpty) {
        _showSnackbar(context, 'Erro: Usuário não encontrado!');
        AuthService().logout();
        return;
      }

      DocumentSnapshot userDoc = userQuery.docs.first;

      String? nivel = userDoc['Nvl'] as String?;

      if (nivel == null) {
        _showSnackbar(context, 'Erro: Nível do usuário não encontrado! Verifique com seu administrador.');
        return;
      }

      if (_senhacontroller.text == 'mudarSenha@123') {
        _showSnackbar(context, 'Redirecionando: Por favor, altere sua senha padrão.');
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const NovaSenha()),
        );
        return;
      }

      if (nivel == 'Padrão') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => InfoUserPadrao(user: user),
          ),
        );
      } else if (nivel == 'Master' || nivel == 'Professor'){
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => Selecao_de_sub(user: user),
          ),
        );
      } else {
        _showSnackbar(context, 'Nível de acesso ($nivel) não reconhecido. Acesso negado.');
      }
    }
  }

  @override
  void dispose() {
    _emailcontroller.dispose();
    _senhacontroller.dispose();
    super.dispose();
  }

}

class NovaSenha extends StatefulWidget {
  const NovaSenha({super.key});

  @override
  _NovaSenhaState createState() => _NovaSenhaState();
}

class _NovaSenhaState extends State<NovaSenha> {
  final TextEditingController _novaSenhaController = TextEditingController();
  final TextEditingController _confirmarSenhaController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/escudo.png',
              width: 80,
              height: 80,
            ),
            SizedBox(height: 35),
            Text(
              "SouSeleto App",
              style: TextStyle(
                color: Colors.white,
                fontSize: 35,
                fontWeight: FontWeight.bold,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
        toolbarHeight: 100,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.black, Colors.green],
              stops: [0.5, 0.5],
            ),
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            children: [
              Icon(Icons.person, size: 100, color: Colors.black),
              SizedBox(height: 20),
              Container(
                child: Text("MÍNIMO 6 CARACTERES,\nLETRA MAIÚSCULA,\nNÚMERO\nCARACTER ESPECIAL (@,#,%)",
                  textAlign: TextAlign.center,),
              ),
              SizedBox(height: 20),
              Text("NOVA SENHA", style: TextStyle(fontSize: 15)),
              SizedBox(
                width: 200,
                child: TextField(
                  controller: _novaSenhaController,
                  obscureText: true,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Digite sua nova senha',
                  ),
                ),
              ),
              SizedBox(height: 20),
              Text("CONFIRMAR SENHA", style: TextStyle(fontSize: 15)),
              SizedBox(
                width: 200,
                child: TextField(
                  controller: _confirmarSenhaController,
                  obscureText: true,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Confirme sua senha',
                  ),
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  if (_novaSenhaController.text == _confirmarSenhaController.text &&
                      _novaSenhaController.text.isNotEmpty) {
                    try {
                      User? user = FirebaseAuth.instance.currentUser;
                      if (user != null) {
                        await user.updatePassword(_novaSenhaController.text);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Senha atualizada com sucesso!')),
                        );
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => Selecao_de_sub(user: user),
                          ),
                        );
                      }
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Erro ao atualizar senha: $e')),
                      );
                    }
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('As senhas não coincidem')),
                    );
                  }
                },
                child: Text('ENTRAR',
                style: TextStyle(color: Colors.white),),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              ),
            ],
          ),
        ),
      ),
    );
  }
}