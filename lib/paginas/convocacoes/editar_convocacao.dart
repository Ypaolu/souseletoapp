import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_multi_formatter/formatters/currency_input_formatter.dart';
import 'package:flutter_multi_formatter/formatters/money_input_enums.dart';
import 'package:intl/intl.dart';

import '../home.dart';
import '../info_user.dart';

class EditarConvocacao extends StatefulWidget {
  final User user;
  final String docId;

  const EditarConvocacao(
      {super.key,
        required this.docId,
        required this.user});

  @override
  _EditarConvocacaoState createState() => _EditarConvocacaoState();
}

class _EditarConvocacaoState extends State<EditarConvocacao> {
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
    carregarConvocacao(); // Carregar os dados da convocação ao iniciar
  }

  Future<void> carregarAlunos() async {
    try {
      var alunosSnapshot = await FirebaseFirestore.instance.collection('Alunos').get();
      var listaAlunos = alunosSnapshot.docs.map((doc) {
        return {
          'ID': doc.id,
          'NomeAluno': doc['NomeAluno'], // Certifique-se de que este é o nome do campo correto no Firestore.
        };
      }).toList();

      setState(() {
        alunos = listaAlunos;
        alunosCarregados = true;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erro ao carregar alunos: $e")),
      );
    }
  }

  Future<void> carregarConvocacao() async {
    try {
      // Carregar dados da convocação
      var chamadaSnapshot = await FirebaseFirestore.instance
          .collection('Convocacoes')
          .doc(widget.docId)
          .get();

      var chamadaData = chamadaSnapshot.data();
      if (chamadaData != null) {
        // Carregar os alunos antes
        await carregarAlunos();

        setState(() {
          // Preencher os campos básicos
          profRespcontroller.text = chamadaData['ProfResp'] ?? '';
          taxacontroller.text = chamadaData['Taxa'] ?? '';
          localcontroller.text = chamadaData['Local'] ?? '';
          enderecocontroller.text = chamadaData['Endereço'] ?? '';

          // Data e hora
          selectedDate = (chamadaData['DataJogo'] as Timestamp).toDate();
          dataJogocontroller.text = DateFormat('dd/MM/yyyy').format(selectedDate!);
          selectedTime = TimeOfDay.fromDateTime(selectedDate!);
          horarioJogocontroller.text = DateFormat('HH:mm').format(selectedDate!);

          // Identificar alunos convocados
          var convocadosData = chamadaData['Convocados'] ?? [];
          if (convocadosData is List) {
            // Verificar quais alunos foram convocados
            selectedAlunos = alunos
                .where((aluno) => convocadosData.contains(aluno['NomeAluno']))
                .map((aluno) => aluno['ID'] as String)
                .toList();

            // Reorganizar a lista de alunos: convocados primeiro
            alunos.sort((a, b) {
              bool aConvocado = selectedAlunos.contains(a['ID']);
              bool bConvocado = selectedAlunos.contains(b['ID']);
              if (aConvocado && !bConvocado) return -1; // Aluno A vem antes
              if (!aConvocado && bConvocado) return 1;  // Aluno B vem depois
              return 0; // Ordem original se ambos forem ou não forem convocados
            });
          }
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erro ao carregar convocação: $e")),
      );
    }
  }


  // Função para atualizar a convocação
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
        'Convocados': alunosSelecionados.map((aluno) => aluno['NomeAluno']).toList(),
      };

      // Atualizar a convocação no Firestore
      await FirebaseFirestore.instance
          .collection('Convocacoes')
          .doc(widget.docId) // Atualizar pelo docId
          .update(uploaddata);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("CONVOCAÇÃO EDITADA COM SUCESSO!"),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("PREENCHA TODOS OS CAMPOS"),
          backgroundColor: Colors.red,
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
     ]),
      ListView.builder(
        shrinkWrap: true,
        itemCount: alunos.length,
        physics: NeverScrollableScrollPhysics(), // Impede a rolagem do ListView.builder
        itemBuilder: (context, index) {
          var aluno = alunos[index];
          return Column(
            children: [
              GestureDetector(
                onTap: () {},
                child: Container(
                  color: Colors.grey[300],
                  child: ListTile(
                    title: Text(aluno['NomeAluno']),
                    trailing: Checkbox(
                      value: selectedAlunos.contains(aluno['ID']),
                      onChanged: (bool? selected) {
                        setState(() {
                          if (selected == true) {
                            selectedAlunos.add(aluno['ID']);
                          } else {
                            selectedAlunos.remove(aluno['ID']);
                          }
                        });
                      },
                      activeColor: Colors.green,
                    ),
                  ),
                ),
              ),
              // Linha de separação
              if (index != alunos.length - 1) // Impede que a linha apareça após o último aluno
                Container(
                  width: double.infinity,
                  height: 1,
                  color: Colors.black,
                ),
            ],
          );
        },
      ),
      Container(
        width: double.infinity,
        height: 1,
        color: Colors.black,
      ),
      SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {if (selectedDate != null &&
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
                            "CONVOCAÇÃO EDITADA COM SUCESSO!",
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
                            "PREENCHA TODOS OS CAMPOS!",
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
                SizedBox(height: 20),],
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