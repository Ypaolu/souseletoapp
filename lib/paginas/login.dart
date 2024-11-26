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
  final TextEditingController _novaSenhaController = TextEditingController();
  final TextEditingController _confirmarSenhaController = TextEditingController();
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
              Text("SouSeleto App",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 35,
                    fontWeight: FontWeight.bold,
                    fontStyle: FontStyle.italic,
                  ))
            ],
          ),
          toolbarHeight: 100,
          flexibleSpace: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black,
                    Colors.green,
                  ],
                  stops: [
                    0.5,
                    0.5
                  ]),
            ),
          ),
          centerTitle: true,
        ),
        body: SingleChildScrollView(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
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
                      // Verifique se a senha do usuário é a senha padrão
                      if (_senhacontroller.text == 'mudarSenha@123') {
                        showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                  title: Text("Alterar Senha"),
                                  content: Column(
                                    children: [
                                      TextField(
                                        controller: _novaSenhaController,
                                        obscureText: true,
                                        decoration: InputDecoration(
                                          labelText: 'Nova Senha',
                                          border: OutlineInputBorder(),
                                        ),
                                      ),
                                      SizedBox(height: 20),
                                      TextField(
                                        controller: _confirmarSenhaController,
                                        obscureText: true,
                                        decoration: InputDecoration(
                                          labelText: 'Confirmar Nova Senha',
                                          border: OutlineInputBorder(),
                                        ),
                                      ),
                                    ],
                                  ),
                                  actions: [
                                    ElevatedButton(
                                      onPressed: () async {
                                        if (_novaSenhaController.text ==
                                            _confirmarSenhaController
                                                .text &&
                                            _novaSenhaController
                                                .text.isNotEmpty &&
                                            _confirmarSenhaController
                                                .text.isNotEmpty) {
                                          try {
                                            User? user = FirebaseAuth
                                                .instance.currentUser;
                                            if (user != null) {
                                              // Atualiza a senha do usuário
                                              await user.updatePassword(
                                                  _novaSenhaController.text);
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(
                                                SnackBar(
                                                    content: Text(
                                                        'Senha atualizada com sucesso!')),
                                              );
                                              // Navega para a tela Home após a atualização
                                              Navigator.pushReplacement(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        Selecao_de_sub(
                                                            user: FirebaseAuth
                                                                .instance
                                                                .currentUser!)),
                                              );
                                            }
                                          } catch (e) {
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              SnackBar(
                                                  content: Text(
                                                      'Erro ao atualizar a senha: $e')),
                                            );
                                          }
                                        } else {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            SnackBar(
                                                content: Text(
                                                    'As senhas não coincidem')),
                                          );
                                        }
                                      },
                                      child: Text('Atualizar Senha'),
                                    ),
                                  ]);
                            });
                      } else {
                        // Caso a senha tenha sido alterada, redirecionar para a tela de seleção
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => Selecao_de_sub(
                                user: FirebaseAuth.instance.currentUser!),
                          ),
                        );
                      }
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(message ?? 'Erro ao realizar login'),
                        ),
                      );
                    }
                  },
                  child: Text('ENTRAR', style: TextStyle(color: Colors.white)),
                  style:
                  ElevatedButton.styleFrom(backgroundColor: Colors.green),
                ),
                SizedBox(height: 20),
                ElevatedButton(
                    onPressed: () {
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) => AddUser()));
                    },
                    child:
                    Text('ADD USER', style: TextStyle(color: Colors.white)),
                    style:
                    ElevatedButton.styleFrom(backgroundColor: Colors.blue)),
                SizedBox(height: 20),
                ElevatedButton(
                    onPressed: () {
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) => addAluno()));
                    },
                    child: Text('ADD ALUNO',
                        style: TextStyle(color: Colors.white)),
                    style:
                    ElevatedButton.styleFrom(backgroundColor: Colors.red)),
              ],
            ),
          ),
        ));
  }
}