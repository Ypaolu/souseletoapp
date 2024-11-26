import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'home.dart';

class InfoUser extends StatefulWidget {
  final User user;
  const InfoUser({super.key, required this.user});

  @override
  _InfoUserState createState() => _InfoUserState();
}

class _InfoUserState extends State<InfoUser> {
  final TextEditingController _novaSenhaController = TextEditingController();
  final TextEditingController _confirmarSenhaController =
  TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Image.asset(
          'assets/escudo.png',
          width: 80,
          height: 80,
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
          child: FutureBuilder<QuerySnapshot>(
              future: FirebaseFirestore.instance
                  .collection('Usuarios')
                  .where('userId',
                  isEqualTo: widget.user.uid) // Busca pelo userId
                  .get(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Erro: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(child: Text('Usuário não encontrado'));
                } else {
                  final data =
                  snapshot.data!.docs.first.data() as Map<String, dynamic>;

                  String formattedDate = '';
                  if (data['DataNasc'] is Timestamp) {
                    DateTime date = (data['DataNasc'] as Timestamp).toDate();
                    formattedDate =
                        DateFormat('dd/MM/yyyy').format(date); // Formata a data
                  }

                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        child: Center(
                          child: Container(
                            width: 350,
                            height: 500,
                            decoration: BoxDecoration(
                              color: Colors.grey[300],
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: Colors.black, width: 2),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Column(
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                      MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.person),
                                        SizedBox(
                                          width: 10,
                                        ),
                                        Text('NOME')
                                      ],
                                    ),
                                    Container(
                                      alignment: Alignment.center,
                                      width: 275,
                                      height: 35,
                                      decoration: BoxDecoration(
                                        color: Colors.grey[300],
                                        borderRadius: BorderRadius.circular(10),
                                        border: Border.all(
                                            color: Colors.black, width: 2),
                                      ),
                                      child: Text(data['NomeUser']),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 20),
                                Column(
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                      MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.email),
                                        SizedBox(
                                          width: 10,
                                        ),
                                        Text('EMAIL'),
                                      ],
                                    ),
                                    Container(
                                      alignment: Alignment.center,
                                      width: 275,
                                      height: 35,
                                      decoration: BoxDecoration(
                                        color: Colors.grey[300],
                                        borderRadius: BorderRadius.circular(10),
                                        border: Border.all(
                                            color: Colors.black, width: 2),
                                      ),
                                      child: Text(widget.user.email ?? 'Email'),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 20),
                                Column(
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                      MainAxisAlignment.center,
                                      children: [
                                        /* Icon(Icons.),
                                            SizedBox(
                                              width: 10,
                                            ),*/
                                        Text('CPF'),
                                      ],
                                    ),
                                    Container(
                                      alignment: Alignment.center,
                                      width: 275,
                                      height: 35,
                                      decoration: BoxDecoration(
                                        color: Colors.grey[300],
                                        borderRadius: BorderRadius.circular(10),
                                        border: Border.all(
                                            color: Colors.black, width: 2),
                                      ),
                                      child: Text(data['Cpf']),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 20),
                                Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Column(
                                        children: [
                                          Row(
                                            mainAxisAlignment:
                                            MainAxisAlignment.center,
                                            children: [
                                              Icon(Icons.calendar_month),
                                              SizedBox(
                                                width: 10,
                                              ),
                                              Text('DATA DE NASC.'),
                                            ],
                                          ),
                                          Container(
                                            alignment: Alignment.center,
                                            width: 120,
                                            height: 35,
                                            decoration: BoxDecoration(
                                              color: Colors.grey[300],
                                              borderRadius:
                                              BorderRadius.circular(10),
                                              border: Border.all(
                                                  color: Colors.black,
                                                  width: 2),
                                            ),
                                            child: Text(formattedDate),
                                          ),
                                        ],
                                      ),
                                      SizedBox(width: 35),
                                      Column(
                                        children: [
                                          Row(
                                            mainAxisAlignment:
                                            MainAxisAlignment.center,
                                            children: [
                                              Icon(Icons.key),
                                              SizedBox(
                                                width: 10,
                                              ),
                                              Text('ACESSO'),
                                            ],
                                          ),
                                          Container(
                                            alignment: Alignment.center,
                                            width: 120,
                                            height: 35,
                                            decoration: BoxDecoration(
                                              color: Colors.grey[300],
                                              borderRadius:
                                              BorderRadius.circular(10),
                                              border: Border.all(
                                                  color: Colors.black,
                                                  width: 2),
                                            ),
                                            child: Text(data['Nvl']),
                                          ),
                                        ],
                                      ),
                                    ]),
                                TextButton(
                                    onPressed: () {
                                      showDialog(
                                          context: context,
                                          builder: (BuildContext context) {
                                            return AlertDialog(
                                                title: Text('Alterar Senha'),
                                                content: Column(
                                                  mainAxisSize: MainAxisSize.min,
                                                  children: [
                                                    TextField(
                                                      controller:
                                                      _novaSenhaController,
                                                      obscureText: true,
                                                      decoration:
                                                      InputDecoration(
                                                        labelText: 'Nova Senha',
                                                        border:
                                                        OutlineInputBorder(),
                                                      ),
                                                    ),
                                                    SizedBox(height: 20),
                                                    TextField(
                                                      controller:
                                                      _confirmarSenhaController,
                                                      obscureText: true,
                                                      decoration:
                                                      InputDecoration(
                                                        labelText:
                                                        'Confirmar Nova Senha',
                                                        border:
                                                        OutlineInputBorder(),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                actions: [
                                                  TextButton(
                                                    onPressed: () async {
                                                      if (_novaSenhaController
                                                          .text ==
                                                          _confirmarSenhaController
                                                              .text &&
                                                          _novaSenhaController
                                                              .text
                                                              .isNotEmpty &&
                                                          _confirmarSenhaController
                                                              .text
                                                              .isNotEmpty) {
                                                        try {
                                                          User? user =
                                                              FirebaseAuth
                                                                  .instance
                                                                  .currentUser;
                                                          if (user != null) {
                                                            // Atualiza a senha do usuário
                                                            await user
                                                                .updatePassword(
                                                                _novaSenhaController
                                                                    .text);
                                                            ScaffoldMessenger
                                                                .of(context)
                                                                .showSnackBar(
                                                              SnackBar(
                                                                  content: Text(
                                                                      'Senha atualizada com sucesso!')),
                                                            );
                                                            Navigator.of(context).pop();
                                                          }
                                                        } catch (e) {
                                                          ScaffoldMessenger.of(
                                                              context)
                                                              .showSnackBar(
                                                            SnackBar(
                                                                content: Text(
                                                                    'Erro ao atualizar a senha: $e')),
                                                          );
                                                        }
                                                      } else {
                                                        ScaffoldMessenger.of(
                                                            context)
                                                            .showSnackBar(
                                                          SnackBar(
                                                              content: Text(
                                                                  'As senhas não coincidem')),
                                                        );
                                                      }
                                                    },
                                                    child:
                                                    Text('Atualizar Senha'),
                                                  ),
                                                  TextButton(
                                                      onPressed: () {
                                                        Navigator.of(context).pop();
                                                      },
                                                      child: Text('Cancelar'))
                                                ]);
                                          });
                                    },
                                    child: Text('Alterar Senha',
                                        style: TextStyle(
                                            color: Colors.red, fontSize: 12)))
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                }
              })),
      bottomNavigationBar: Container(
        height: 80,
        child: BottomAppBar(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              IconButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                icon: Icon(Icons.reply, color: Colors.black, size: 30),
              ),
              IconButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => Selecao_de_sub(user: widget.user),
                    ),
                  );
                },
                icon: Icon(Icons.home, color: Colors.black, size: 30),
              ),
              IconButton(
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => InfoUser(user: widget.user)));
                },
                icon: Icon(Icons.person, color: Colors.black, size: 30),
              ),
            ],
          ),
          color: Color.fromARGB(255, 57, 177, 61),
        ),
      ),
    );
  }
}