import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../home.dart';
import '../info_user.dart';

class InfoAluno extends StatefulWidget {
  final User user;
  final String docId;
  const InfoAluno({super.key, required this.docId, required this.user});

  @override
  _InfoAlunoState createState() => _InfoAlunoState();
}

class _InfoAlunoState extends State<InfoAluno> {
  bool _isInfoExpanded = false;

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
          child: FutureBuilder<DocumentSnapshot>(
              future: FirebaseFirestore.instance
                  .collection('Alunos')
                  .doc(widget.docId)
                  .get(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Erro: ${snapshot.error}'));
                } else if (!snapshot.hasData || !snapshot.data!.exists) {
                  return Center(child: Text('Aluno não encontrado'));
                } else {
                  final data = snapshot.data!.data() as Map<String, dynamic>;

                  return Container(
                    child: Center(
                      child: Column(
                        children: <Widget>[
                          Container(
                            child: Row(children: [
                              Expanded(
                                child: Container(
                                  alignment: Alignment.center,
                                  width: 500,
                                  height: 50,
                                  color: Color(0xFFcccccc),
                                  child: Text(
                                    data['NomeAluno'],
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                              Container(
                                  width: 2, height: 50, color: Colors.black),
                              Container(
                                child: GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _isInfoExpanded = !_isInfoExpanded;
                                    });
                                  },
                                  child: Container(
                                    width: 50,
                                    height: 50,
                                    alignment: Alignment.center,
                                    color: Color(0xFFcccccc),
                                    child: Icon(
                                      Icons.expand_more,
                                      size: 50,
                                      color: Colors.black,
                                    ),
                                  ),
                                ),
                              ),
                            ]),
                          ),
                          Container(
                            child: Column(children: [
                              Container(
                                width: double.infinity,
                                height: 2,
                                color: Colors.black,
                              ),
                              if (_isInfoExpanded) ...[
                                Container(
                                  width: double.infinity,
                                  height: 300,
                                  color: Color.fromARGB(255, 235, 235, 235),
                                  child: Container(
                                    child: Column(
                                      mainAxisAlignment:
                                      MainAxisAlignment.center,
                                      children: [
                                        Row(
                                          // Linha 1
                                          mainAxisAlignment:
                                          MainAxisAlignment.center,
                                          children: [
                                            Container(
                                              width: 120,
                                              height: 120,
                                              decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                color: Color(0xFFcccccc),
                                                border: Border.all(
                                                  color: Colors.black,
                                                  width: 2,
                                                ),
                                              ),
                                              child: Icon(
                                                Icons.person,
                                                color: Colors.black,
                                                size: 30,
                                              ),
                                            ),
                                            SizedBox(width: 25),
                                            Column(
                                              children: [
                                                Container(
                                                  child: Text(
                                                    'NOME DO RESPONSÁVEL',
                                                    style: TextStyle(
                                                      color: Colors.black,
                                                      fontSize: 15,
                                                      fontWeight:
                                                      FontWeight.bold,
                                                    ),
                                                  ),
                                                ),
                                                Container(
                                                  alignment: Alignment.center,
                                                  width: 220,
                                                  height: 30,
                                                  decoration: BoxDecoration(
                                                    color: Colors.grey,
                                                    border: Border.all(
                                                      color: Colors.black,
                                                      width: 2,
                                                    ),
                                                  ),
                                                  child: Text(
                                                    data['NomeResp'],
                                                    style: TextStyle(
                                                      color: Colors.black,
                                                      fontSize: 15,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                        SizedBox(height: 20),
                                        Row(
                                          // Linha 2
                                          mainAxisAlignment:
                                          MainAxisAlignment.center,
                                          children: [
                                            Column(
                                              crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                              children: [
                                                Container(
                                                  child: Text(
                                                    'SUB',
                                                    style: TextStyle(
                                                      color: Colors.black,
                                                      fontSize: 15,
                                                      fontWeight:
                                                      FontWeight.bold,
                                                    ),
                                                  ),
                                                ),
                                                Container(
                                                    alignment: Alignment.center,
                                                    width: 100,
                                                    height: 30,
                                                    decoration: BoxDecoration(
                                                      color: Colors.grey,
                                                      border: Border.all(
                                                        color: Colors.black,
                                                        width: 2,
                                                      ),
                                                    ),
                                                    child: Text(
                                                      data['Sub'],
                                                      style: TextStyle(
                                                        color: Colors.black,
                                                        fontSize: 15,
                                                      ),
                                                    )),
                                              ],
                                            ),
                                            SizedBox(width: 25),
                                            Column(
                                              children: [
                                                Container(
                                                  child: Text(
                                                    'CELULAR DO RESPONSÁVEL',
                                                    style: TextStyle(
                                                      color: Colors.black,
                                                      fontSize: 15,
                                                      fontWeight:
                                                      FontWeight.bold,
                                                    ),
                                                  ),
                                                ),
                                                Container(
                                                  alignment: Alignment.center,
                                                  width: 220,
                                                  height: 30,
                                                  decoration: BoxDecoration(
                                                    color: Colors.grey,
                                                    border: Border.all(
                                                      color: Colors.black,
                                                      width: 2,
                                                    ),
                                                  ),
                                                  child: Text(
                                                    data['CellResp'],
                                                    style: TextStyle(
                                                      color: Colors.black,
                                                      fontSize: 15,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                        SizedBox(height: 20),
                                        Row(
                                          // Linha 3
                                          mainAxisAlignment:
                                          MainAxisAlignment.center,
                                          children: [
                                            Column(
                                              children: [
                                                Container(
                                                  child: Text(
                                                    'TIPO SANGUÍNEO',
                                                    style: TextStyle(
                                                      color: Colors.black,
                                                      fontSize: 15,
                                                      fontWeight:
                                                      FontWeight.bold,
                                                    ),
                                                  ),
                                                ),
                                                Container(
                                                    alignment: Alignment.center,
                                                    width: 100,
                                                    height: 30,
                                                    decoration: BoxDecoration(
                                                      color: Colors.grey,
                                                      border: Border.all(
                                                        color: Colors.black,
                                                        width: 2,
                                                      ),
                                                    ),
                                                    child: Text(
                                                      data['Sangue'],
                                                      style: TextStyle(
                                                        color: Colors.black,
                                                        fontSize: 15,
                                                      ),
                                                    )),
                                              ],
                                            ),
                                            SizedBox(width: 25),
                                            Column(
                                              children: [
                                                Container(
                                                  child: Text(
                                                    'CPF',
                                                    style: TextStyle(
                                                      color: Colors.black,
                                                      fontSize: 15,
                                                      fontWeight:
                                                      FontWeight.bold,
                                                    ),
                                                  ),
                                                ),
                                                Container(
                                                  alignment: Alignment.center,
                                                  width: 220,
                                                  height: 30,
                                                  decoration: BoxDecoration(
                                                    color: Colors.grey,
                                                    border: Border.all(
                                                      color: Colors.black,
                                                      width: 2,
                                                    ),
                                                  ),
                                                  child: Text(
                                                    data['CpfAluno'],
                                                    style: TextStyle(
                                                      color: Colors.black,
                                                      fontSize: 15,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                Container(
                                  width: double.infinity,
                                  height: 2,
                                  color: Colors.black,
                                ),
                              ],
                            ]),
                          ),
                        ],
                      ),
                    ),
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