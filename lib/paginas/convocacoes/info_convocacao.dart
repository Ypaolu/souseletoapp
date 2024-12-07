import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../configs/database.dart';
import '../home.dart';
import '../info_user.dart';
import 'editar_convocacao.dart';

class InfoConvocacao extends StatefulWidget {
  final String docId;
  final User user;
  final String SubTurno;

  const InfoConvocacao({super.key, required this.docId, required this.user, required this.SubTurno});

  @override
  State<InfoConvocacao> createState() => _InfoConvocacaoState();
}

class _InfoConvocacaoState extends State<InfoConvocacao> {
  TextEditingController textcontroller = TextEditingController();

  String formatTimestamp(Timestamp timestamp) {
    final date = timestamp.toDate();
    final formattedDate = DateFormat('dd/MM/yyyy  |  HH:mm').format(date);
    return formattedDate;
  }

  updateData() async {
    Map<String, dynamic> updatedata = {
      'ProfResp': profRespcontroller.text,
      'Taxa': taxacontroller.text,
      'Local': localcontroller.text,
      'Endereço': enderecocontroller.text,
      'DataJogo': dataJogocontroller.text,
    };

    await DatabaseMethods().addConvocacao(updatedata);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          "CONVOCAÇÃO EDITADA COM SUCESSO!",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 2),
      ),
    );
  }

  TextEditingController profRespcontroller = TextEditingController();
  TextEditingController taxacontroller = TextEditingController();
  TextEditingController localcontroller = TextEditingController();
  TextEditingController enderecocontroller = TextEditingController();
  TextEditingController dataJogocontroller = TextEditingController();

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
        child: StreamBuilder<DocumentSnapshot>(
            stream: FirebaseFirestore.instance
                .collection('Convocacoes')
                .doc(widget.docId)
                .snapshots(), // Usando 'snapshots()' para escutar alterações em tempo real
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text('Erro: ${snapshot.error}'));
              } else if (!snapshot.hasData || !snapshot.data!.exists) {
                return Center(child: Text('Convocação não encontrada'));
              } else {
                final data = snapshot.data!.data() as Map<String, dynamic>;
                return Container(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                data['DataJogo'] != null &&
                                    data['DataJogo'] is Timestamp
                                    ? formatTimestamp(data['DataJogo'])
                                    : 'N/A',
                                style: TextStyle(
                                    fontSize: 20, fontWeight: FontWeight.bold),
                              ),
                              SizedBox(width: 15),
                              Container(
                                child: Text(
                                  '|',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              SizedBox(width: 15),
                              Text(
                                '${data['Taxa'] ?? 'N/A'}',
                                style: TextStyle(
                                    fontSize: 20, fontWeight: FontWeight.bold),
                              ),
                              SizedBox(width: 15),
                              IconButton(
                                onPressed: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => EditarConvocacao(
                                              docId: widget.docId,
                                              user: widget.user,
                                              SubTurno: widget.SubTurno)));
                                },
                                icon: Icon(Icons.edit),
                                color: Colors.black,
                                iconSize: 20,
                              )
                            ],
                          ),
                          Column(
                            children: [
                              Text(
                                'PROFESSOR RESPONSÁVEL',
                                style: TextStyle(
                                    fontSize: 20, fontWeight: FontWeight.bold),
                              ),
                              Container(
                                alignment: Alignment.center,
                                width: 400,
                                height: 35,
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    color: Color(0xFFD9D9D9),
                                    border: Border.all(
                                      color: Color(0xFF9B9B9B),
                                      width: 2,
                                    )),
                                child: Text(
                                  '${data['ProfResp'] ?? 'N/A'}',
                                  style: TextStyle(fontSize: 18),
                                ),
                              ),
                            ],
                          ),
                          Column(
                            children: [
                              Text(
                                'LOCAL',
                                style: TextStyle(
                                    fontSize: 20, fontWeight: FontWeight.bold),
                              ),
                              Container(
                                alignment: Alignment.center,
                                width: 400,
                                height: 35,
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    color: Color(0xFFD9D9D9),
                                    border: Border.all(
                                      color: Color(0xFF9B9B9B),
                                      width: 2,
                                    )),
                                child: Text(
                                  '${data['Local'] ?? 'N/A'}',
                                  style: TextStyle(fontSize: 18),
                                ),
                              ),
                            ],
                          ),
                          Column(
                            children: [
                              Text(
                                'ENDEREÇO',
                                style: TextStyle(
                                    fontSize: 20, fontWeight: FontWeight.bold),
                              ),
                              Container(
                                alignment: Alignment.center,
                                width: 400,
                                height: 50,
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    color: Color(0xFFD9D9D9),
                                    border: Border.all(
                                      color: Color(0xFF9B9B9B),
                                      width: 2,
                                    )),
                                child: Text(
                                  '${data['Endereço'] ?? 'N/A'}',
                                  style: TextStyle(fontSize: 18),
                                ),
                              ),
                            ],
                          ),
                          Column(
                            children: [
                              Text(
                                'Jogadores',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  if (data['Convocados'] != null &&
                                      data['Convocados'] is List)
                                    Column(
                                      children: (data['Convocados'] as List)
                                          .map<Widget>((jogador) {
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
                                                  jogador,
                                                  style: TextStyle(fontSize: 18),
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
                                      }).toList(),
                                    )
                                  else
                                    Text('N/A', style: TextStyle(fontSize: 18)),
                                ],
                              ),
                            ],
                          )
                        ]));
              }
            }),
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