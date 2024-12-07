import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../home.dart';
import '../info_user.dart';
import 'editar_chamada.dart';

class InfoChamadas extends StatefulWidget {
  final User user;
  final String docId;

  const InfoChamadas({super.key, required this.docId, required this.user});

  @override
  State<InfoChamadas> createState() => _InfoChamadasState();
}

class _InfoChamadasState extends State<InfoChamadas> {
  TextEditingController textcontroller = TextEditingController();

  // Função para formatar timestamp para data legível
  String formatTimestamp(Timestamp timestamp) {
    final date = timestamp.toDate();
    final formattedDate = DateFormat('dd/MM/yyyy').format(date);
    return formattedDate;
  }

  Future<void> _mostrarJustificativaPopup(BuildContext context, Map<String, dynamic> aluno) async {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Justificativa de Falta"),
          content: Text(
            '${aluno['Justificativa'] ?? "Sem justificativa"}',
            style: TextStyle(fontSize: 18),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Fecha o pop-up
              },
              child: Text("Fechar"),
            ),
          ],
        );
      },
    );
  }


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
              colors: [Colors.black, Colors.green],
              stops: [0.5, 0.5],
            ),
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: StreamBuilder<DocumentSnapshot>(
          stream: FirebaseFirestore.instance
              .collection('Chamadas')
              .doc(widget.docId)
              .snapshots(), // Usando 'snapshots()' para escutar alterações em tempo real
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Erro: ${snapshot.error}'));
            } else if (!snapshot.hasData || !snapshot.data!.exists) {
              return Center(child: Text('Chamada não encontrada'));
            } else {
              final data = snapshot.data!.data() as Map<String, dynamic>;

              // Acessando a lista de alunos
              List<dynamic> alunos = data['Alunos'] ?? [];

              return Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '${formatTimestamp(data['DataChamada'])}',
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(width: 20),
                      IconButton(
                          onPressed: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => EditarChamada(
                                      docId: widget.docId, user: widget.user
                                    )));
                          },
                          icon: Icon(Icons.edit)),
                    ],
                  ),
                  SizedBox(height: 20),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: alunos.length,
                    itemBuilder: (context, index) {
                      final aluno = alunos[index];
                      final nomeAluno = aluno['NomeAluno'];
                      final presente = aluno['Presente'];
                      final justificativa = aluno['Justificativa']; // Justificativa, se houver

                      return Column(
                        children: [
                          Container(
                            width: double.infinity,
                            height: 1,
                            color: Colors.black,
                          ),
                          Container(
                            color: Colors.grey[300],
                            child: ListTile(
                              title: Text(
                                nomeAluno,
                                style: TextStyle(fontSize: 18),
                              ),
                              subtitle: presente == 'Justificado'
                                  ? Text(
                                '$justificativa',
                                style: TextStyle(color: Colors.black),
                              )
                                  : null, // Exibe a justificativa se estiver justificado
                              trailing: Container(
                                  alignment: Alignment.center,
                                  width: 25,
                                  height: 25,
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: Colors.black,
                                      width: 2,
                                    ),
                                    borderRadius: BorderRadius.circular(5),
                                    color: aluno['Presente'] == 'Presente'
                                        ? Colors.green
                                        : aluno['Presente'] == 'Ausente'
                                        ? Colors.red
                                        : Colors.yellow, //justificado
                                  ),
                                ),
                              ),
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
                  SizedBox(height: 20),
                ],
              );
            }
          },
        ),
      ),
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
