import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../home.dart';
import '../info_user.dart';

class EditarChamada extends StatefulWidget {
  final User user;
  final String docId; // ID da chamada que está sendo editada

  const EditarChamada({super.key, required this.docId, required this.user});

  @override
  _EditarChamadaState createState() => _EditarChamadaState();
}

class _EditarChamadaState extends State<EditarChamada> {
  DateTime? selectedDate;
  List<Map<String, dynamic>> alunos = [];
  bool alunosCarregados =
  false; // Flag para saber se os alunos foram carregados
  String subTurno = ''; // O sub turno será obtido da chamada

  // Carregar dados da chamada específica e seus alunos
  Future<void> carregarChamada() async {
    try {
      // Carregar os dados da chamada pelo docId
      var chamadaSnapshot = await FirebaseFirestore.instance
          .collection('Chamadas')
          .doc(widget.docId)
          .get();

      var chamadaData = chamadaSnapshot.data();
      if (chamadaData != null) {
        // Obtém o sub turno e a data da chamada
        subTurno = chamadaData['Sub'] ?? '';
        selectedDate = (chamadaData['DataChamada'] as Timestamp).toDate();

        // A lista de alunos presentes na chamada
        var alunosDaChamada = chamadaData['NomeAluno'] as List<dynamic>;

        setState(() {
          // Inicializar a lista de alunos com base nos dados da chamada
          alunos = alunosDaChamada.map((aluno) {
            return {
              'NomeAluno': aluno['NomeAluno'],
              'Presente': aluno['Presente'] ??
                  true, // Por padrão, se não tiver presença, assume true
            };
          }).toList();
          alunosCarregados = true;
        });
      }
    } catch (e) {
      setState(() {
        alunosCarregados =
        true; // Se houver erro, consideramos o carregamento feito
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Erro ao carregar dados: $e"),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  // Função para salvar a chamada editada
  Future<void> salvarChamada() async {
    try {
      List<Map<String, dynamic>> presencas = alunos.map((aluno) {
        return {
          'NomeAluno': aluno['NomeAluno'],
          'Presente': aluno['Presente'],
        };
      }).toList();

      Map<String, dynamic> uploaddata = {
        'NomeAluno': presencas,
        'Sub': subTurno,
        'DataChamada': selectedDate != null
            ? Timestamp.fromDate(selectedDate!)
            : null, // Atualizando a data
      };

      // Atualiza os dados da chamada no Firestore
      await FirebaseFirestore.instance
          .collection('Chamadas')
          .doc(widget.docId)
          .update(uploaddata);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Chamada atualizada com sucesso!"),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );

      Navigator.pop(context);
      Navigator.pop(context); // Voltar para a lista de chamadas
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Erro ao atualizar chamada: $e"),
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
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (dataSelecionada != null) {
      setState(() {
        selectedDate = dataSelecionada;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    carregarChamada(); // Carregar dados da chamada e alunos
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
            children: [
              alunosCarregados
                  ? alunos.isEmpty
                  ? Center(child: Text('Nenhum aluno encontrado.'))
                  : Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    // Exibindo a data da chamada
                    GestureDetector(
                      onTap: () =>
                          _mostrarCalendarioPersonalizado(context),
                      child: Container(
                        padding: EdgeInsets.symmetric(vertical: 10),
                        child: Center(
                          child: Text(
                            selectedDate == null
                                ? 'Selecione a data'
                                : DateFormat('dd/MM/yyyy')
                                .format(selectedDate!),
                            style: TextStyle(fontSize: 20),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                    Container(
                      width: double.infinity,
                      height: 1,
                      color: Colors.black,
                    ),
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
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: salvarChamada,
                      child: Text(
                        'SALVAR',
                        style: TextStyle(color: Colors.black),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        padding: EdgeInsets.symmetric(vertical: 15),
                        textStyle: TextStyle(fontSize: 20),
                      ),
                    ),
                  ],
                ),
              )
                  : Center(child: CircularProgressIndicator()),
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
