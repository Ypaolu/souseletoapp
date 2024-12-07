import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
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
  String formatTimestamp(Timestamp timestamp) {
    final date = timestamp.toDate();
    final formattedDate = DateFormat('dd/MM/yyyy').format(date);
    return formattedDate;
  }
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
                              child: Column(
                                  children: [
                                    Container(
                                      width: double.infinity,
                                      height: 2,
                                      color: Colors.black,
                                    ),
                                    if (_isInfoExpanded) ...[
                                      Container(
                                        width: double.infinity,
                                        height: 480,
                                        color: Color.fromARGB(
                                            255, 235, 235, 235),
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
                                                          alignment: Alignment
                                                              .center,
                                                          width: 75,
                                                          height: 30,
                                                          decoration: BoxDecoration(
                                                            color: Colors.grey,
                                                            border: Border.all(
                                                              color: Colors
                                                                  .black,
                                                              width: 2,
                                                            ),
                                                          ),
                                                          child: Text(
                                                            data['Sangue'],
                                                            style: TextStyle(
                                                              color: Colors
                                                                  .black,
                                                              fontSize: 15,
                                                            ),
                                                          )),
                                                    ],
                                                  ),
                                                  SizedBox(width: 10),
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
                                                          alignment: Alignment
                                                              .center,
                                                          width: 75,
                                                          height: 30,
                                                          decoration: BoxDecoration(
                                                            color: Colors.grey,
                                                            border: Border.all(
                                                              color: Colors
                                                                  .black,
                                                              width: 2,
                                                            ),
                                                          ),
                                                          child: Text(
                                                            data['Sub'],
                                                            style: TextStyle(
                                                              color: Colors
                                                                  .black,
                                                              fontSize: 15,
                                                            ),
                                                          )),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                              SizedBox(height: 20),
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
                                                    width: 350,
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
                                              SizedBox(height: 20),
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
                                                    width: 350,
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
                                              SizedBox(height: 25),
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
                                                    width: 350,
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
                                              SizedBox(height: 25),
                                              Column(
                                                mainAxisAlignment:
                                                MainAxisAlignment.center,
                                                children: [
                                                  Container(
                                                    child: Text(
                                                      'Endereço',
                                                      style: TextStyle(
                                                        color: Colors.black,
                                                        fontSize: 15,
                                                        fontWeight: FontWeight
                                                            .bold,
                                                      ),
                                                    ),
                                                  ),
                                                  Container(
                                                    alignment: Alignment.center,
                                                    width: 350,
                                                    height: 30,
                                                    decoration: BoxDecoration(
                                                      color: Colors.grey,
                                                      border: Border.all(
                                                        color: Colors.black,
                                                        width: 2,
                                                      ),
                                                    ),
                                                    child: Text(
                                                      data['End'],
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
                            Container(
                              child: StreamBuilder<QuerySnapshot>(
                                stream: FirebaseFirestore.instance
                                    .collection('Chamadas')
                                    .orderBy('DataChamada', descending: true)
                                    .snapshots(),
                                builder: (context, snapshot) {
                                  if (snapshot.connectionState == ConnectionState.waiting) {
                                    return Center(child: CircularProgressIndicator());
                                  } else if (snapshot.hasError) {
                                    return Center(child: Text('Erro: ${snapshot.error}'));
                                  } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                                    return Center(child: Text('Chamada não encontrada'));
                                  } else {
                                    return Container(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        children: [
                                          ListView.builder(
                                            shrinkWrap: true,
                                            physics: const NeverScrollableScrollPhysics(),
                                            itemCount: snapshot.data!.docs.length,
                                            itemBuilder: (context, index) {
                                              var chamada = snapshot.data!.docs[index];
                                              List<dynamic> alunos = chamada['Alunos'] ?? [];

                                              var alunoPresente = alunos.firstWhere(
                                                    (aluno) => aluno['NomeAluno'] == data['NomeAluno'],
                                                orElse: () => null,
                                              );

                                              if (alunoPresente == null) {
                                                return SizedBox();
                                              }

                                              return Column(
                                                children: [
                                                  Container(
                                                    color: Colors.grey[300],
                                                    child: ListTile(
                                                      title: Text(
                                                        '${formatTimestamp(chamada['DataChamada'])}',
                                                        style: TextStyle(fontSize: 18),
                                                      ),
                                                      subtitle: alunoPresente['Presente'] == 'Justificado'
                                                          ? Text(
                                                        '${alunoPresente['Justificativa'] ?? "Não fornecida"}',
                                                        style: TextStyle(color: Colors.black),
                                                      )
                                                          : null,
                                                      trailing: GestureDetector(
                                                        onTap: () {
                                                          if (alunoPresente['Presente'] == 'Ausente') {
                                                            // Abre o pop-up para justificar
                                                            showDialog(
                                                              context: context,
                                                              builder: (context) {
                                                                TextEditingController justificativaController = TextEditingController();

                                                                return AlertDialog(
                                                                  title: Text('Justificativa de Ausência'),
                                                                  content: TextField(
                                                                    controller: justificativaController,
                                                                    decoration: InputDecoration(
                                                                      hintText: 'Digite a justificativa...',
                                                                    ),
                                                                  ),
                                                                  actions: [
                                                                    TextButton(
                                                                      onPressed: () {
                                                                        Navigator.pop(context);
                                                                      },
                                                                      child: Text('Cancelar'),
                                                                    ),
                                                                    TextButton(
                                                                      onPressed: () {
                                                                        String justificativa = justificativaController.text.trim();

                                                                        // Verifica se o campo de justificativa está vazio
                                                                        if (justificativa.isEmpty) {
                                                                          // Exibe uma mensagem de erro
                                                                          ScaffoldMessenger.of(context).showSnackBar(
                                                                            SnackBar(
                                                                              content: Text('Por favor, digite uma justificativa.'),
                                                                              backgroundColor: Colors.red,
                                                                            ),
                                                                          );
                                                                          return; // Não faz nada se o campo estiver vazio
                                                                        }

                                                                        // Atualiza a justificativa no Firestore
                                                                        FirebaseFirestore.instance
                                                                            .collection('Chamadas')
                                                                            .doc(chamada.id)
                                                                            .update({
                                                                          'Alunos': FieldValue.arrayRemove([{
                                                                            'NomeAluno': alunoPresente['NomeAluno'],
                                                                            'Presente': 'Ausente',
                                                                          }]), // Remove o aluno com status 'Ausente'
                                                                        }).then((_) {
                                                                          // Agora, atualizamos o aluno com a justificativa e status 'Justificado'
                                                                          FirebaseFirestore.instance
                                                                              .collection('Chamadas')
                                                                              .doc(chamada.id)
                                                                              .update({
                                                                            'Alunos': FieldValue.arrayUnion([{
                                                                              'NomeAluno': alunoPresente['NomeAluno'],
                                                                              'Presente': 'Justificado',
                                                                              'Justificativa': justificativa,
                                                                            }]),
                                                                          }).then((_) {
                                                                            Navigator.pop(context); // Fecha o pop-up após salvar
                                                                          });
                                                                        });
                                                                      },
                                                                      child: Text('Salvar'),
                                                                    ),
                                                                  ],
                                                                );
                                                              },
                                                            );
                                                          }
                                                        },
                                                        child: Container(
                                                          alignment: Alignment.center,
                                                          width: 25,
                                                          height: 25,
                                                          decoration: BoxDecoration(
                                                            border: Border.all(
                                                              color: Colors.black,
                                                              width: 2,
                                                            ),
                                                            borderRadius: BorderRadius.circular(5),
                                                            color: alunoPresente['Presente'] == 'Presente'
                                                                ? Colors.green
                                                                : alunoPresente['Presente'] == 'Justificado'
                                                                ? Colors.yellow
                                                                : Colors.red,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  Container(
                                                    width: double.infinity,
                                                    height: 1,
                                                    color: Colors.black,
                                                  ),
                                                  Container(
                                                    width: double.infinity,
                                                    height: 1,
                                                    color: Colors.black,
                                                  ),
                                                ],
                                              );
                                            },
                                          ),
                                        ],
                                      ),
                                    );
                                  }
                                },
                              ),
                            )

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