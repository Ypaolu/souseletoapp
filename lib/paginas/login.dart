import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../configs/auth.dart';
import 'add_user.dart';
import 'alunos/add_aluno.dart';
import 'home.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final TextEditingController _emailcontroller = TextEditingController();
  final TextEditingController _senhacontroller = TextEditingController();

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
                  obscureText: true,
                  controller: _senhacontroller,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'DIGITE SUA SENHA',
                  ),
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  final message = await AuthService().login(
                    email: _emailcontroller.text,
                    senha: _senhacontroller.text,
                  );

                  if (message != null && message.contains('Successo')) {
                    _handleLoginScenario();
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(message ?? 'Erro ao realizar login'),
                      ),
                    );
                  }
                },
                child: Text('ENTRAR', style: TextStyle(color: Colors.white)),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleLoginScenario() {
    if (_senhacontroller.text == 'mudarSenha@123') {
      // Redireciona para a tela de alteração de senha
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => NovaSenha()),
      );
    } else {
      // Caso contrário, navegue para a tela de seleção normal
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => Selecao_de_sub(
            user: FirebaseAuth.instance.currentUser!,
          ),
        ),
      );
    }
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