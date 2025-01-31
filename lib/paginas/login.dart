import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:souseleto/paginas/userPadrao.dart';
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
  bool _obscureText = true;

  void _toggleObscureText() {
    setState(() {
      _obscureText = !_obscureText;
    });
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

  void _handleLoginScenario() async {
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      // Buscar o documento do usuário pelo userId no Firestore
      QuerySnapshot userQuery = await FirebaseFirestore.instance
          .collection('Usuarios')
          .where('userId', isEqualTo: user.uid)
          .get();

      if (userQuery.docs.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Usuário não encontrado no Firestore!')),
        );
        return;
      }

      // Pega o primeiro documento encontrado
      DocumentSnapshot userDoc = userQuery.docs.first;

      // Obtém o nível do usuário
      String? nivel = userDoc['Nvl'];

      if (nivel == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Nível do usuário não encontrado!')),
        );
        return;
      }

      // Se a senha for a padrão, redirecionar para alterar senha
      if (_senhacontroller.text == 'mudarSenha@123') {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => NovaSenha()),
        );
        return;
      }

      // Verificar o nível do usuário e redirecionar
      if (nivel == 'Padrão') {
        // Redirecionar para a página específica do usuário padrão
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => InfoUserPadrao(user: user),
          ),
        );
      } else if (nivel == 'Master' || nivel == 'Professor'){
        // Caso contrário, vai para a página de seleção de sub
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => Selecao_de_sub(user: user),
          ),
        );
      }
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