import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

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

  Future<void> carregarConvocacao() async {
    try {
      var chamadaSnapshot = await FirebaseFirestore.instance
          .collection('Convocacoes')
          .doc(widget.docId)  // ID do documento da convocação
          .get();

      var chamadaData = chamadaSnapshot.data();
      if (chamadaData != null) {
        setState(() {
          // Preenchendo os campos com os dados da convocação
          profRespcontroller.text = chamadaData['ProfResp'] ?? '';
          taxacontroller.text = chamadaData['Taxa'] ?? '';
          localcontroller.text = chamadaData['Local'] ?? '';
          enderecocontroller.text = chamadaData['Endereço'] ?? '';

          // Data e hora
          selectedDate = (chamadaData['DataJogo'] as Timestamp).toDate();
          dataJogocontroller.text = DateFormat('dd/MM/yyyy').format(selectedDate!);
          selectedTime = TimeOfDay.fromDateTime(selectedDate!);
          horarioJogocontroller.text = DateFormat('HH:mm').format(selectedDate!);

          // Convocados como lista de nomes dos alunos (strings)
          var convocadosData = chamadaData['Convocados'] ?? [];

          if (convocadosData is List) {
            alunos = alunos.where((aluno) {
              return convocadosData.contains(aluno['NomeAluno']);
            }).toList();
          }

          // Marcando os alunos convocados
          selectedAlunos = alunos.map((aluno) => aluno['ID'] as String).toList();
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erro ao carregar dados: $e")),
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
        title: Text('Editar Convocação'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            alunosCarregados
                ? alunos.isEmpty
                ? Center(child: Text('Não há alunos para editar'))
                : Column(
              children: [
                // Campos de edição
                TextField(
                  controller: profRespcontroller,
                  decoration: InputDecoration(labelText: 'Professor Responsável'),
                ),
                TextField(
                  controller: taxacontroller,
                  decoration: InputDecoration(labelText: 'Taxa de Jogo'),
                ),
                TextField(
                  controller: localcontroller,
                  decoration: InputDecoration(labelText: 'Local do Jogo'),
                ),
                TextField(
                  controller: enderecocontroller,
                  decoration: InputDecoration(labelText: 'Endereço'),
                ),
                GestureDetector(
                  onTap: () => _mostrarCalendarioPersonalizado(context),
                  child: TextField(
                    controller: dataJogocontroller,
                    decoration: InputDecoration(labelText: 'Data do Jogo'),
                    enabled: false,
                  ),
                ),
                GestureDetector(
                  onTap: () => _mostrarHorarioPersonalizado(context),
                  child: TextField(
                    controller: horarioJogocontroller,
                    decoration: InputDecoration(labelText: 'Horário do Jogo'),
                    enabled: false,
                  ),
                ),
                // Botão de salvar
                ElevatedButton(
                  onPressed: () {
                    uploadData(alunos);
                  },
                  child: Text('Salvar'),
                ),
              ],
            )
                : CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}