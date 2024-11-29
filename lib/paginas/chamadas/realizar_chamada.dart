import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../../configs/database.dart';
import '../home.dart';
import '../info_user.dart';

class RealizarChamada extends StatefulWidget {
  final User user;
  final String SubTurno;
  const RealizarChamada({super.key, required this.SubTurno, required this.user});

  @override
  State<RealizarChamada> createState() => _RealizarChamadaState();
}

class _RealizarChamadaState extends State<RealizarChamada> {
  DateTime? selectedDate;
  List<Map<String, dynamic>> alunos = [];
  bool alunosCarregados =
  false; // Flag para saber se os alunos foram carregados

  TextEditingController dataChamadacontroller = TextEditingController();

  // Função para carregar alunos do Firestore
  Future<void> carregarAlunos() async {
    try {
      var querySnapshot = await FirebaseFirestore.instance
          .collection('Alunos')
          .where('Sub', isEqualTo: widget.SubTurno)
          .orderBy('NomeAluno', descending: false)
          .get();

      setState(() {
        alunos = querySnapshot.docs.map((doc) {
          return {
            'NomeAluno': doc['NomeAluno'],
            'Presente': true, // Por padrão, os alunos começam como "presente"
          };
        }).toList();
        alunosCarregados = true; // Alunos carregados com sucesso
      });
    } catch (e) {
      setState(() {
        alunosCarregados =
        true; // Se houver erro, consideramos o carregamento feito
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Erro ao carregar alunos: $e"),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  // Função para salvar a chamada
  uploadData() async {
    try {
      List<Map<String, dynamic>> presencas = alunos.map((aluno) {
        return {
          'NomeAluno': aluno['NomeAluno'],
          'Presente': aluno['Presente'],
        };
      }).toList();

      Map<String, dynamic> uploaddata = {
        'NomeAluno': presencas,
        'Sub': widget.SubTurno,
        'DataChamada': selectedDate != null
            ? Timestamp.fromDate(selectedDate!) // Salva como Timestamp
            : null,
      };

      await DatabaseMethods().addChamada(uploaddata);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Chamada salva com sucesso!"),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Erro ao salvar chamada: $e"),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }


  // Função para selecionar a data
  Future<void> _mostrarCalendarioPersonalizado(BuildContext context) async {
    DateTime? dataSelecionada = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (dataSelecionada != null) {
      setState(() {
        selectedDate = dataSelecionada;
        dataChamadacontroller.text =
        '${dataSelecionada.day}/${dataSelecionada.month}/${dataSelecionada.year}';
      });
    }
  }

  @override
  void initState() {
    super.initState();
    selectedDate = DateTime.now();
    dataChamadacontroller.text = DateFormat('dd/MM/yyyy').format(selectedDate!);
    carregarAlunos();
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
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              alunosCarregados
                  ? alunos.isEmpty
                  ? Center(
                child: Text(
                  'NÃO HÁ ALUNOS CADASTRADOS PARA ESSE SUB',
                  style: TextStyle(
                    fontSize: 15,
                  ),
                ),
              )
                  : Column(
                children: [
                  // Cabeçalho com o nome do Sub Turno e o calendário
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'CHAMADA SUB ${widget.SubTurno}',
                        style: TextStyle(
                          fontSize: 25,
                        ),
                      ),
                      GestureDetector(
                        onTap: () =>
                            _mostrarCalendarioPersonalizado(context),
                        child: Container(
                          child: Center(
                            child: Text(
                                dataChamadacontroller.text.isEmpty
                                    ? 'dd/mm/aaaa'
                                    : dataChamadacontroller.text,
                                style: TextStyle(fontSize: 20)),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                  Container(
                    width: double.infinity,
                    height: 1,
                    color: Colors.black,
                  ),
                  // Lista de alunos
                  Column(
                    children: alunos.map((aluno) {
                      return Column(
                        children: [
                          Container(
                            color: Colors.grey[300],
                            child: ListTile(
                              title: Text(aluno['NomeAluno']),
                              trailing: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    aluno['Presente'] =
                                    !aluno['Presente'];
                                  });
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
                                      borderRadius:
                                      BorderRadius.circular(5),
                                      color: aluno['Presente']
                                          ? Colors.transparent
                                          : Colors.black),
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
                    }).toList(),
                  ),
                  SizedBox(height: 30),
                  ElevatedButton(
                    onPressed: () {
                      uploadData();
                      Navigator.pop(
                          context); // Volta para a tela anterior
                    },
                    child: Text('SALVAR',
                        style: TextStyle(
                            color: Colors.black,
                            fontSize: 20,
                            fontWeight: FontWeight.bold)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[300],
                    ),
                  ),
                ],
              )
                  : CircularProgressIndicator(),
            ],
          ),
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