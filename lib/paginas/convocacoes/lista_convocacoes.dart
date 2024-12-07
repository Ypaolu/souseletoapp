import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../home.dart';
import '../info_user.dart';
import 'info_convocacao.dart';

class AnosConvocacoes extends StatefulWidget {
  final User user;
  final String SubTurno;
  const AnosConvocacoes(
      {super.key, required this.SubTurno, required this.user});

  @override
  _AnosConvocacoesState createState() => _AnosConvocacoesState();
}

class _AnosConvocacoesState extends State<AnosConvocacoes> {
  final List<String> meses = [
    'Janeiro',
    'Fevereiro',
    'Março',
    'Abril',
    'Maio',
    'Junho',
    'Julho',
    'Agosto',
    'Setembro',
    'Outubro',
    'Novembro',
    'Dezembro'
  ];
  final List<int> anos = [2025, 2024, 2023, 2022];
  final Map<String, bool> _expandedMonths = {};

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
          children: meses.map((mes) {
            int monthIndex =
                meses.indexOf(mes) + 1; // Índice do mês para navegação
            return _mesButton(mes, monthIndex);
          }).toList(),
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
                onPressed: () {},
                icon: Icon(Icons.person, color: Colors.black, size: 30),
              ),
            ],
          ),
          color: Color.fromARGB(255, 57, 177, 61),
        ),
      ),
    );
  }

  Widget _mesButton(String mes, int monthIndex) {
    bool isExpanded =
        _expandedMonths[mes] ?? false; // Verifica se o mês está expandido

    return GestureDetector(
      onTap: () {
        setState(() {
          _expandedMonths[mes] = !isExpanded; // Alterna o estado de expansão
        });
      },
      child: Container(
        decoration: BoxDecoration(
          color: Color(0xFFCCCCCC),
          border: Border.all(
            color: Colors.black,
            width: 1,
          ),
        ),
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.symmetric(vertical: 15),
              width: double.infinity,
              alignment: Alignment.center,
              child: Text(
                mes.toUpperCase(),
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            if (isExpanded) // Exibe os anos apenas se o mês estiver expandido
              ...anos.map((ano) {
                return Container(
                  decoration: BoxDecoration(
                    color: Color(0xFFCCCCCC),
                    border: Border.all(
                      color: Colors.black,
                      width: 1,
                    ),
                  ),
                  child: ListTile(
                    contentPadding: EdgeInsets.symmetric(vertical: 10),
                    title: Text(
                      "$ano",
                      style:
                      TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ListaConvocacoes(
                              year: ano,
                              month: monthIndex,
                              SubTurno: widget.SubTurno,
                              user: widget.user
                          ),
                        ),
                      );
                    },
                  ),
                );
              }).toList(),
          ],
        ),
      ),
    );
  }
}

class ListaConvocacoes extends StatefulWidget {
  final int year, month;
  final String SubTurno;
  final User user;
  const ListaConvocacoes(
      {super.key,
        required this.year,
        required this.month,
        required this.SubTurno,
        required this.user});

  @override
  State<ListaConvocacoes> createState() => _ListaConvocacoesState();
}

class _ListaConvocacoesState extends State<ListaConvocacoes> {
  TextEditingController textcontroller = TextEditingController();

  // Controladores para atualização de dados
  TextEditingController profRespcontroller = TextEditingController();
  TextEditingController taxacontroller = TextEditingController();
  TextEditingController localcontroller = TextEditingController();
  TextEditingController enderecocontroller = TextEditingController();
  TextEditingController horarioJogocontroller = TextEditingController();
  TextEditingController dataJogocontroller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    // Definindo o intervalo de data para o mês e ano especificado
    DateTime startDate = DateTime(widget.year, widget.month, 1);
    DateTime endDate = DateTime(widget.year, widget.month + 1, 1);

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
                stops: [0.5, 0.5]),
          ),
        ),
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('Convocacoes')
            .where('DataJogo',
            isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
            .where('DataJogo', isLessThanOrEqualTo: Timestamp.fromDate(endDate))
            .where('Sub', isEqualTo: widget.SubTurno)
            .orderBy('DataJogo', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Erro: ${snapshot.error}'));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
                child: Text('Nenhum jogo encontrado para este período.'));
          }

          final documents = snapshot.data!.docs;
          final dateFormat =
          DateFormat('dd/MM/yyyy'); // Definindo o formato de data

          return ListView.builder(
            itemCount: documents.length,
            itemBuilder: (context, index) {
              final docData = documents[index].data() as Map<String, dynamic>;

              return SingleChildScrollView(
                  child: Container(
                    margin: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                    decoration: BoxDecoration(
                      color: Color(0xFFD9D9D9),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: ListTile(
                      title: GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => InfoConvocacao(
                                  docId: documents[index].id, user: widget.user, SubTurno: widget.SubTurno),
                            ),
                          );
                        },
                        child: Text(
                          dateFormat.format((docData['DataJogo'] as Timestamp)
                              .toDate()), // Converte o Timestamp para dateTime e formata para uma String
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 20,
                          ),
                        ),
                      ),
                    ),
                  ));
            },
          );
        },
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