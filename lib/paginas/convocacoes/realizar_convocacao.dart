import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:flutter_multi_formatter/flutter_multi_formatter.dart';

import '../home.dart';
import '../info_user.dart';

class RealizarConvocacao extends StatefulWidget {
  final User user;
  final String SubTurno;

  const RealizarConvocacao({super.key, required this.SubTurno, required this.user});

  @override
  _RealizarConvocacaoState createState() => _RealizarConvocacaoState();
}

class _RealizarConvocacaoState extends State<RealizarConvocacao> {
  DateTime? selectedDate;
  TimeOfDay? selectedTime;
  List<Map<String, dynamic>> alunos = [];
  bool alunosCarregados = false;
  Map<String, bool> expandidos = {};
  List<String> selectedAlunos = [];

  TextEditingController profRespcontroller = TextEditingController();
  TextEditingController taxacontroller = TextEditingController();
  TextEditingController localcontroller = TextEditingController();
  TextEditingController enderecocontroller = TextEditingController();
  TextEditingController dataJogocontroller = TextEditingController();
  TextEditingController horarioJogocontroller = TextEditingController();

  @override
  void initState() {
    super.initState();
    carregarAlunos();
  }

  // Carregar alunos do Firestore
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
            'ID': doc.id,
          };
        }).toList();
        alunosCarregados = true;
      });
    } catch (e) {
      setState(() {
        alunosCarregados = true;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erro ao carregar alunos: $e")),
      );
    }
  }

// Função para fazer o upload dos dados
  uploadData(List<Map<String, dynamic>> alunos) async {
    if (selectedDate != null &&
        selectedTime != null &&
        profRespcontroller.text.isNotEmpty &&
        taxacontroller.text.isNotEmpty &&
        localcontroller.text.isNotEmpty &&
        enderecocontroller.text.isNotEmpty) {
      DateTime combinedDateTime = DateTime(
        selectedDate!.year,
        selectedDate!.month,
        selectedDate!.day,
        selectedTime!.hour,
        selectedTime!.minute,
      );

      var alunosSelecionados = alunos
          .where((aluno) => selectedAlunos.contains(aluno['ID']))
          .toList();

      Map<String, dynamic> uploaddata = {
        'ProfResp': profRespcontroller.text,
        'Taxa': taxacontroller.text,
        'Local': localcontroller.text,
        'Endereço': enderecocontroller.text,
        'DataJogo': Timestamp.fromDate(combinedDateTime),
        'Sub': widget.SubTurno,
        'Convocados':
        alunosSelecionados.map((aluno) => aluno['NomeAluno']).toList(),
      };

      // Enviar os dados para o Firestore
      await FirebaseFirestore.instance
          .collection('Convocacoes')
          .add(uploaddata);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("CONVOCAÇÃO CRIADA COM SUCESSO!",
              style: TextStyle(color: Colors.white)),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("PREENCHA TODOS OS CAMPOS",
              style: TextStyle(color: Colors.white)),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  // Exibindo o calendário para selecionar a data
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
        dataJogocontroller.text =
        '${dataSelecionada.day}/${dataSelecionada.month}/${dataSelecionada.year}';
      });
    }
  }

  // Exibindo o seletor de horário
  Future<void> _mostrarHorarioPersonalizado(BuildContext context) async {
    TimeOfDay? horaSelecionada = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (BuildContext context, Widget? child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
          child: child!,
        );
      },
    );

    if (horaSelecionada != null) {
      setState(() {
        selectedTime = horaSelecionada;
        horarioJogocontroller.text =
        '${horaSelecionada.hour}:${horaSelecionada.minute < 10 ? '0${horaSelecionada.minute}' : horaSelecionada.minute}';
      });
    }
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
        child: Column(
          children: [
            alunosCarregados
                ? alunos.isEmpty
                ? Center(
                child: Text('NÃO HÁ ALUNOS CADASTRADOS PARA ESSE SUB'))
                : Column(
              children: [
                SizedBox(height: 10),
                Text(
                  "INFORMAÇÕES DA CONVOCAÇÃO",
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Seção de Data
                    Column(
                      children: [
                        Text("Data",
                            style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold)),
                        GestureDetector(
                          onTap: () =>
                              _mostrarCalendarioPersonalizado(
                                  context),
                          child: Container(
                            decoration: BoxDecoration(
                                borderRadius:
                                BorderRadius.circular(10),
                                color: Colors.grey[300]),
                            width: 120,
                            height: 60,
                            child: Center(
                              child: Text(
                                dataJogocontroller.text.isEmpty
                                    ? 'dd/mm/aaaa'
                                    : dataJogocontroller.text,
                                style: TextStyle(fontSize: 16),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(width: 20),
                    Column(
                      children: [
                        Text("Horário",
                            style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold)),
                        GestureDetector(
                          onTap: () =>
                              _mostrarHorarioPersonalizado(context),
                          child: Container(
                            decoration: BoxDecoration(
                                borderRadius:
                                BorderRadius.circular(10),
                                color: Colors.grey[300]),
                            width: 120,
                            height: 60,
                            child: Center(
                              child: Text(
                                horarioJogocontroller.text.isEmpty
                                    ? 'hh:mm'
                                    : horarioJogocontroller.text,
                                style: TextStyle(fontSize: 16),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(width: 20),
                    Column(
                      children: [
                        Container(
                          child: Text(
                            "Taxa de jogo",
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Container(
                          width: 120,
                          height: 60,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: Colors.grey[300],
                          ),
                          child: TextFormField(
                            controller: taxacontroller,
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              CurrencyInputFormatter(
                                leadingSymbol: 'R\$ ',
                                thousandSeparator:
                                ThousandSeparator.Period,
                                mantissaLength:
                                2, // duas casas decimais
                              ),
                            ],
                            decoration: InputDecoration(
                              contentPadding:
                              EdgeInsets.symmetric(vertical: 18),
                              border: InputBorder.none,
                            ),
                            style: TextStyle(fontSize: 15),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        SizedBox(width: 15),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: 20),
                // Campo de Professor Responsável
                Column(
                  children: [
                    Container(
                      child: Text(
                        "Professor Responsável",
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Container(
                      width: 400,
                      height: 60,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: Colors.grey[300],
                      ),
                      child: TextFormField(
                        controller: profRespcontroller,
                        decoration: InputDecoration(
                          contentPadding:
                          EdgeInsets.symmetric(vertical: 18),
                          border: InputBorder.none,
                        ),
                        style: TextStyle(fontSize: 15),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    SizedBox(height: 15),
                  ],
                ),
                Column(
                  children: [
                    Container(
                      child: Text(
                        "Local do Jogo",
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Container(
                      width: 400,
                      height: 60,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: Colors.grey[300],
                      ),
                      child: TextFormField(
                        controller: localcontroller,
                        decoration: InputDecoration(
                          contentPadding:
                          EdgeInsets.symmetric(vertical: 18),
                          border: InputBorder.none,
                        ),
                        style: TextStyle(fontSize: 15),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    SizedBox(height: 15),
                  ],
                ),
                Column(
                  children: [
                    Container(
                      child: Text(
                        "Endereço do jogo",
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Container(
                      width: 400,
                      height: 60,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: Colors.grey[300],
                      ),
                      child: TextFormField(
                        controller: enderecocontroller,
                        decoration: InputDecoration(
                          contentPadding:
                          EdgeInsets.symmetric(vertical: 18),
                          border: InputBorder.none,
                        ),
                        style: TextStyle(fontSize: 15),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    SizedBox(height: 20),
                    Container(
                      child: Text('Alunos',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),),
                    ),
                    Container(
                      width: double.infinity,
                      height: 1,
                      color: Colors.black,
                    ),
                    Column(
                      children: alunos.map((aluno) {
                        String alunoID = aluno['ID'];
                        return Column(
                          children: [
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  expandidos[alunoID] =
                                  !(expandidos[alunoID] ?? false);
                                  if (expandidos[alunoID]!) {
                                    // Carregar chamadas ao expandir
                                  }
                                });
                              },
                              child: Container(
                                color: Colors.grey[300],
                                child: ListTile(
                                  title: Text(aluno['NomeAluno']),
                                  trailing: Checkbox(
                                    value: selectedAlunos
                                        .contains(aluno['ID']),
                                    onChanged: (bool? value) {
                                      setState(() {
                                        if (value == true) {
                                          selectedAlunos
                                              .add(aluno['ID']);
                                        } else {
                                          selectedAlunos
                                              .remove(aluno['ID']);
                                        }
                                      });
                                    },
                                    activeColor: Colors.green,
                                  ),
                                ),
                              ),
                            ),
                            Container(
                              width: double.infinity,
                              height: 1,
                              color: Colors.black,
                            ),
                            if (expandidos[alunoID] == true)
                              Container(
                                color: Colors.grey[200],
                                width: double.infinity,
                                height: 200,
                                child: Column(
                                  crossAxisAlignment:
                                  CrossAxisAlignment.start,
                                  children: [
                                    StreamBuilder<QuerySnapshot>(
                                      stream: FirebaseFirestore
                                          .instance
                                          .collection('Chamadas')
                                          .where('AlunosID',
                                          isEqualTo: alunoID)
                                          .orderBy('DataChamada')
                                          .snapshots(),
                                      builder: (context, snapshot) {
                                        if (snapshot
                                            .connectionState ==
                                            ConnectionState.waiting) {
                                          return Center(
                                              child:
                                              CircularProgressIndicator());
                                        }

                                        if (snapshot.hasError) {
                                          return Center(
                                              child: Text(
                                                  'Erro ao carregar dados: ${snapshot.error}'));
                                        }

                                        if (!snapshot.hasData ||
                                            snapshot
                                                .data!.docs.isEmpty) {
                                          return Center(
                                              child: Text(
                                                  'Nenhuma chamada encontrada.'));
                                        }

                                        final documentos =
                                            snapshot.data!.docs;
                                        return ListView.builder(
                                          itemCount:
                                          documentos.length,
                                          itemBuilder:
                                              (context, index) {
                                            var dadosDoc =
                                            documentos[index]
                                                .data()
                                            as Map<String,
                                                dynamic>;
                                            var alunos = List<
                                                Map<String,
                                                    dynamic>>.from(
                                                dadosDoc['Alunos']);
                                            var dataChamada =
                                            (dadosDoc['DataChamada']
                                            as Timestamp)
                                                .toDate();
                                            return Column(
                                              crossAxisAlignment:
                                              CrossAxisAlignment
                                                  .start,
                                              children: [
                                                // Presença e data
                                                ListView.builder(
                                                  shrinkWrap: true,
                                                  itemCount:
                                                  alunos.length,
                                                  itemBuilder:
                                                      (context,
                                                      alunoIndex) {
                                                    var aluno = alunos[
                                                    alunoIndex];
                                                    bool presente =
                                                        aluno['Presente'] ??
                                                            false;
                                                    return ListTile(
                                                      title: Text(aluno[
                                                      'NomeAluno'] ??
                                                          'Nome não disponível'),
                                                      subtitle: Row(
                                                        children: [
                                                          Container(
                                                            width: 20,
                                                            height:
                                                            20,
                                                            decoration:
                                                            BoxDecoration(
                                                              color: presente
                                                                  ? Colors.green
                                                                  : Colors.red,
                                                              borderRadius:
                                                              BorderRadius.circular(5),
                                                            ),
                                                          ),
                                                          SizedBox(width: 10),
                                                          Text(
                                                            'Data: ${DateFormat('dd/MM/yyyy HH:mm').format(dataChamada)}',
                                                            style: TextStyle(
                                                                fontSize:
                                                                12,
                                                                color:
                                                                Colors.grey),
                                                          ),
                                                        ],
                                                      ),
                                                    );
                                                  },
                                                ),
                                              ],
                                            );
                                          },
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        );
                      }).toList(),
                    ),
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        if (selectedDate != null &&
                            selectedTime != null &&
                            profRespcontroller.text.isNotEmpty &&
                            taxacontroller.text.isNotEmpty &&
                            localcontroller.text.isNotEmpty &&
                            enderecocontroller.text.isNotEmpty) {
                          uploadData(alunos);
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                  "CONVOCAÇÃO CRIADA COM SUCESSO!",
                                  style:
                                  TextStyle(color: Colors.white)),
                              backgroundColor: Colors.green,
                              duration: Duration(seconds: 2),
                            ),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                  "PREENCHA TODOS OS CAMPOS",
                                  style:
                                  TextStyle(color: Colors.white)),
                              backgroundColor: Colors.red,
                              duration: Duration(seconds: 2),
                            ),
                          );
                        }
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
                    SizedBox(height: 20)
                  ],
                ),
              ],
            )
                : CircularProgressIndicator(),
          ],
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