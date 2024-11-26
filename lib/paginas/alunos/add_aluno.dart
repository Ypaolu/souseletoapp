import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../configs/database.dart';

class addAluno extends StatefulWidget {
  const addAluno({super.key});

  @override
  State<addAluno> createState() => _addAlunoState();
}

class _addAlunoState extends State<addAluno> {
  DateTime? selectedDateNasc;
  DateTime? selectedDateEnt;

  TextEditingController nomeAlunocontroller = TextEditingController();
  TextEditingController dataNasccontroller = TextEditingController();
  TextEditingController cpfAlunocontroller = TextEditingController();
  TextEditingController nomeMaecontroller = TextEditingController();
  TextEditingController nomePaicontroller = TextEditingController();
  TextEditingController nomeRespcontroller = TextEditingController();
  TextEditingController cpfRespcontroller = TextEditingController();
  TextEditingController rgRespcontroller = TextEditingController();
  TextEditingController cellRespcontroller = TextEditingController();
  TextEditingController sanguecontroller = TextEditingController();
  TextEditingController dataEntcontroller = TextEditingController();
  TextEditingController subcontroller = TextEditingController();
  TextEditingController cadAtvcontroller = TextEditingController();
  TextEditingController endcontroller = TextEditingController();

  Future<bool> verificarCpfExistente(String cpf) async {
    try {
      // A coleção de alunos pode ser algo como 'alunos'
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('Alunos')
          .where('CpfAluno', isEqualTo: cpf) // Consultar pelo campo CPF
          .get();

      // Se a consulta retornar algum documento, significa que o CPF já existe
      return querySnapshot.docs.isNotEmpty;
    } catch (e) {
      // Caso haja algum erro na consulta, você pode capturar e mostrar o erro
      print("Erro ao verificar CPF: $e");
      return false;
    }
  }

  uploadData() async {
    String cpf = cpfAlunocontroller.text.trim();
    bool cpfExistente = await verificarCpfExistente(cpf);

    if (cpfExistente) {
      // Exibe a mensagem de erro, mas não fecha a aba
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Já existe um aluno cadastrado com esse CPF.')),
      );
      // Não faz nada mais, a tela de cadastro permanece aberta
    } else {
      // Se o CPF não existir, continua o fluxo normal
      if (selectedDateNasc != null) {
        DateTime combinedDateTimeNasc = DateTime(
          selectedDateNasc!.year,
          selectedDateNasc!.month,
          selectedDateNasc!.day,
        );

        if (selectedDateEnt != null) {
          DateTime combinedDateTimeEnt = DateTime(
            selectedDateEnt!.year,
            selectedDateEnt!.month,
            selectedDateEnt!.day,
          );

          Map<String, dynamic> uploaddata = {
            'NomeAluno': nomeAlunocontroller.text,
            'DataNasc': Timestamp.fromDate(combinedDateTimeNasc),
            'CpfAluno': cpfAlunocontroller.text,
            'NomeMae': nomeMaecontroller.text,
            'NomePai': nomePaicontroller.text,
            'NomeResp': nomeRespcontroller.text,
            'CpfResp': cpfRespcontroller.text,
            'RgResp': rgRespcontroller.text,
            'CellResp': cellRespcontroller.text,
            'Sangue': sanguecontroller.text,
            'Sub': subcontroller.text,
            'End': endcontroller.text,
            'CadAtv': true,
            'DataEnt':
            Timestamp.fromDate(combinedDateTimeEnt), // Salva como Timestamp
          };

          await DatabaseMethods().addAluno(uploaddata);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                "ALUNO CRIADO COM SUCESSO!",
                style: TextStyle(color: Colors.white),
              ),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
            ),
          );
        } else {
          // Caso a data de entrada não tenha sido selecionada
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                "Selecione a data de entrada!",
                style: TextStyle(color: Colors.white),
              ),
              backgroundColor: Colors.red,
              duration: Duration(seconds: 2),
            ),
          );
        }
      }
    }
  }

  // Exibindo o calendário para selecionar a data de nascimento
  Future<void> _mostrarCalendarioPersonalizado(BuildContext context) async {
    DateTime? dataSelecionadaNasc = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (dataSelecionadaNasc != null) {
      setState(() {
        selectedDateNasc = dataSelecionadaNasc;
        dataNasccontroller.text =
        '${dataSelecionadaNasc.day}/${dataSelecionadaNasc.month}/${dataSelecionadaNasc.year}';
      });
    }
  }

  // Exibindo o calendário para selecionar a data de entrada
  Future<void> _mostrarCalendarioPersonalizado2(BuildContext context) async {
    DateTime? dataSelecionadaEnt = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (dataSelecionadaEnt != null) {
      setState(() {
        selectedDateEnt = dataSelecionadaEnt; // Corrigir para selectedDateEnt
        dataEntcontroller.text =
        '${dataSelecionadaEnt.day}/${dataSelecionadaEnt.month}/${dataSelecionadaEnt.year}';
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
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(
                  "INFORMAÇÕES DO ALUNO",
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                Column(
                  children: [
                    Text("Data de Nascimento",
                        style:
                        TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                    GestureDetector(
                      onTap: () => _mostrarCalendarioPersonalizado(context),
                      child: Container(
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: Colors.grey[300]),
                        width: 250,
                        height: 60,
                        child: Center(
                          child: Text(
                              dataNasccontroller.text.isEmpty
                                  ? 'dd/mm/aaaa'
                                  : dataNasccontroller.text,
                              style: TextStyle(fontSize: 16)),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10),
                Column(
                  children: [
                    Text("Data de Entrada",
                        style:
                        TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                    GestureDetector(
                      onTap: () => _mostrarCalendarioPersonalizado2(context),
                      child: Container(
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: Colors.grey[300]),
                        width: 250,
                        height: 60,
                        child: Center(
                          child: Text(
                              dataEntcontroller.text.isEmpty
                                  ? 'dd/mm/aaaa'
                                  : dataEntcontroller.text,
                              style: TextStyle(fontSize: 16)),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10),
                Column(
                  children: [
                    Container(
                      child: Text(
                        "Nome do Aluno",
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Container(
                      width: 250,
                      height: 60,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: Colors.grey[300],
                      ),
                      child: TextFormField(
                        controller: nomeAlunocontroller,
                        decoration: InputDecoration(
                          contentPadding: EdgeInsets.symmetric(vertical: 18),
                          border: InputBorder.none,
                        ),
                        style: TextStyle(fontSize: 15),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    SizedBox(height: 15),
                    Container(
                      child: Text(
                        "CPF do Aluno",
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Container(
                      width: 250,
                      height: 60,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: Colors.grey[300],
                      ),
                      child: TextFormField(
                        controller: cpfAlunocontroller,
                        decoration: InputDecoration(
                          contentPadding: EdgeInsets.symmetric(vertical: 18),
                          border: InputBorder.none,
                        ),
                        style: TextStyle(fontSize: 15),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    SizedBox(height: 15),
                    Column(
                      children: [
                        Container(
                          child: Text(
                            "Endereço Completo",
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Container(
                          width: 250,
                          height: 60,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: Colors.grey[300],
                          ),
                          child: TextFormField(
                            controller: endcontroller,
                            decoration: InputDecoration(
                              contentPadding: EdgeInsets.symmetric(vertical: 18),
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
                            "Nome da Mãe",
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Container(
                          width: 250,
                          height: 60,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: Colors.grey[300],
                          ),
                          child: TextFormField(
                            controller: nomeMaecontroller,
                            decoration: InputDecoration(
                              contentPadding: EdgeInsets.symmetric(vertical: 18),
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
                            "Nome do Pai",
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Container(
                          width: 250,
                          height: 60,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: Colors.grey[300],
                          ),
                          child: TextFormField(
                            controller: nomePaicontroller,
                            decoration: InputDecoration(
                              contentPadding: EdgeInsets.symmetric(vertical: 18),
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
                            "Nome do Responsável",
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Container(
                          width: 250,
                          height: 60,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: Colors.grey[300],
                          ),
                          child: TextFormField(
                            controller: nomeRespcontroller,
                            decoration: InputDecoration(
                              contentPadding: EdgeInsets.symmetric(vertical: 18),
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
                            "CPF do Responsável",
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Container(
                          width: 250,
                          height: 60,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: Colors.grey[300],
                          ),
                          child: TextFormField(
                            controller: cpfRespcontroller,
                            decoration: InputDecoration(
                              contentPadding: EdgeInsets.symmetric(vertical: 18),
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
                            "RG do Responsável",
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Container(
                          width: 250,
                          height: 60,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: Colors.grey[300],
                          ),
                          child: TextFormField(
                            controller: rgRespcontroller,
                            decoration: InputDecoration(
                              contentPadding: EdgeInsets.symmetric(vertical: 18),
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
                            "Celular do Responsável",
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Container(
                          width: 250,
                          height: 60,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: Colors.grey[300],
                          ),
                          child: TextFormField(
                            controller: cellRespcontroller,
                            decoration: InputDecoration(
                              contentPadding: EdgeInsets.symmetric(vertical: 18),
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
                            "Tipo Sanguíneo",
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Container(
                          width: 250,
                          height: 60,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: Colors.grey[300],
                          ),
                          child: TextFormField(
                            controller: sanguecontroller,
                            decoration: InputDecoration(
                              contentPadding: EdgeInsets.symmetric(vertical: 18),
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
                          alignment: Alignment.center,
                          child: Text(
                            "SUB (número do sub + 'M' para Matutino e 'V' para Vespertino)",
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Container(
                          width: 250,
                          height: 60,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: Colors.grey[300],
                          ),
                          child: TextFormField(
                            controller: subcontroller,
                            decoration: InputDecoration(
                              contentPadding: EdgeInsets.symmetric(vertical: 18),
                              border: InputBorder.none,
                            ),
                            style: TextStyle(fontSize: 15),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        SizedBox(height: 15),
                      ],
                    ),
                    SizedBox(height: 15),
                    ElevatedButton(
                      onPressed: () async {
                        String cpf = cpfAlunocontroller.text.trim();
                        bool cpfExistente = await verificarCpfExistente(cpf);

                        if (cpfExistente) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                                content: Text(
                                    'Já existe um aluno cadastrado com esse CPF.')),
                          );
                        } else if (nomeAlunocontroller.text.isEmpty ||
                            dataNasccontroller.text.isEmpty ||
                            dataEntcontroller.text.isEmpty ||
                            cpfAlunocontroller.text.isEmpty ||
                            nomeMaecontroller.text.isEmpty ||
                            nomePaicontroller.text.isEmpty ||
                            nomeRespcontroller.text.isEmpty ||
                            cpfRespcontroller.text.isEmpty ||
                            rgRespcontroller.text.isEmpty ||
                            cellRespcontroller.text.isEmpty ||
                            sanguecontroller.text.isEmpty ||
                            endcontroller.text.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('PREENCHA TODOS OS CAMPOS')),
                          );
                        } else {
                          uploadData();
                          Navigator.pop(context);
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
                    SizedBox(height: 15)
                  ],
                ),
              ],
            ),
          )),
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
            ],
          ),
          color: Color.fromARGB(255, 57, 177, 61),
        ),
      ),
    );
  }
}