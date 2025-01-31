import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../configs/auth.dart';
import 'alunos/lista_alunos.dart';
import 'chamadas/lista_chamadas.dart';
import 'chamadas/realizar_chamada.dart';
import 'convocacoes/lista_convocacoes.dart';
import 'convocacoes/realizar_convocacao.dart';
import 'info_user.dart';
import 'login.dart';

class Selecao_de_sub extends StatefulWidget {

  final User user;
  Selecao_de_sub({super.key, required this.user});

  State<Selecao_de_sub> createState() => _Selecao_de_subState();
}

class _Selecao_de_subState extends State<Selecao_de_sub> {
  String SubTurno = ''; // Inicializa com valor vazio

  bool get _isTurnoSelected => SubTurno.isNotEmpty;
  bool get _isSubSelected =>
      SubTurno.isNotEmpty && SubTurno.split(' ').length > 1;

  // Alterna para o turno Matutino
  void _toggleMatutino() {
    setState(() {
      // Se já for Matutino, limpa a seleção. Caso contrário, seleciona o Matutino com o sub.
      if (SubTurno.isNotEmpty && SubTurno.split(' ')[1] == 'M') {
        SubTurno = '';
      } else {
        // Se ainda não tiver um valor no turno, inicialize com '7 M'.
        if (SubTurno.isEmpty) {
          SubTurno = '7 M'; // Defina o subturno inicial (exemplo '7 M')
        } else {
          SubTurno =
          '${SubTurno.split(' ')[0]} M'; // Mantém o sub selecionado e troca o turno
        }
      }
    });
  }

  // Alterna para o turno Vespertino
  void _toggleVespertino() {
    setState(() {
      // Se já for Vespertino, limpa a seleção. Caso contrário, seleciona o Vespertino com o sub.
      if (SubTurno.isNotEmpty && SubTurno.split(' ')[1] == 'V') {
        SubTurno = '';
      } else {
        // Se ainda não tiver um valor no turno, inicialize com '7 V'.
        if (SubTurno.isEmpty) {
          SubTurno = '7 V'; // Defina o subturno inicial (exemplo '7 V')
        } else {
          SubTurno =
          '${SubTurno.split(' ')[0]} V'; // Mantém o sub selecionado e troca o turno
        }
      }
    });
  }

  // Navega para a tela de seleção de função se o turno e sub foram selecionados
  void _navigateToFuncao() {
    if (_isTurnoSelected && _isSubSelected) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => Selecao_de_funcao(
            user: widget.user,
            SubTurno: SubTurno, // Passa a combinação completa de turno e sub
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Selecione um turno e um sub antes de prosseguir')),
      );
    }
  }

  // Cria os botões para cada sub
  Widget _buildSubButton(String title, int sub) {
    return Opacity(
      opacity: _isTurnoSelected ? 1.0 : 0.5,
      child: GestureDetector(
        onTap: () {
          if (_isTurnoSelected) {
            setState(() {
              // Atualiza o Sub e o Turno
              SubTurno = '$sub ${SubTurno.split(' ')[1]}';
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => Selecao_de_funcao(
                    user: widget.user,
                    SubTurno: SubTurno, // Passa a combinação completa
                  ),
                ),
              );
            });
          }
        },
        child: Container(
          width: double.infinity,
          height: 90,
          color: _isTurnoSelected ? Color(0xFFD9D9D9) : Colors.grey,
          alignment: Alignment.center,
          child: Text(
            title,
            style: TextStyle(
              color: Colors.black,
              fontSize: 35,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    List<int> subNumbers = [7, 9, 11, 13, 15, 17]; // Lista de subs
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
            children: <Widget>[
              Container(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Container(
                      width: 150,
                      height: 35,
                      margin: EdgeInsets.only(top: 15, bottom: 15),
                      child: FloatingActionButton(
                        onPressed: _toggleMatutino,
                        elevation: 0,
                        backgroundColor: SubTurno.contains('M')
                            ? Colors.green
                            : Color(0xFFD9D9D9),
                        child: Text(
                          'MATUTINO',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 30),
                    Container(
                      width: 150,
                      height: 35,
                      child: FloatingActionButton(
                        onPressed: _toggleVespertino,
                        elevation: 0,
                        backgroundColor: SubTurno.contains('V')
                            ? Colors.green
                            : Color(0xFFD9D9D9),
                        child: Text(
                          'VESPERTINO',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Divider(height: 1.5, color: Colors.black),
              Column(
                children: subNumbers
                    .map((sub) => Column(
                  children: [
                    _buildSubButton("SUB $sub", sub),
                    Divider(height: 1.5, color: Colors.black),
                  ],
                ))
                    .toList(),
              ),
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
                  showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                            title: Text("Logout"),
                            content: Text("Deseja realmente sair?"),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                child: Text("CANCELAR"),
                              ),
                              TextButton(
                                onPressed: () async {
                                  final message = await AuthService().logout(); // Chama o logout

                                  if (message != null &&
                                      message.contains('Logout bem-sucedido!')) {
                                    Navigator.pushAndRemoveUntil(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => Login()), (route) => false,
                                    );
                                  }
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                          message ?? 'Erro ao realizar logout'),
                                    ),
                                  );
                                },
                                child: Text("SAIR"),
                              )
                            ]);
                      });
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

class Selecao_de_funcao extends StatefulWidget {
  final String SubTurno;
  final User user;
  const Selecao_de_funcao(
      {super.key, required this.SubTurno, required this.user});

  @override
  _Selecao_de_funcaoState createState() => _Selecao_de_funcaoState();
}

class _Selecao_de_funcaoState extends State<Selecao_de_funcao> {
  bool _isChamadaExpanded = false;
  bool _isConvocacoesExpanded = false;
  bool _isAlunosExpanded = false;

  Widget _buildExpandableSection(
      String title, List<Widget> items, bool isExpanded, Function() onTap) {
    return Column(
      children: [
        GestureDetector(
          onTap: onTap,
          child: Container(
            width: double.infinity,
            height: 80,
            alignment: Alignment.center,
            color: Color(0xFFCCCCCC),
            child: Text(
              title,
              style: TextStyle(
                  color: Colors.black,
                  fontSize: 20,
                  fontWeight: FontWeight.bold),
            ),
          ),
        ),
        if (isExpanded) ...items,
        Divider(height: 1.5, color: Colors.black),
      ],
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
            children: <Widget>[
              Text(
                'SUB ${widget.SubTurno}',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              Container(
                width: double.infinity,
                height: 1.5,
                color: Colors.black,
              ),
              _buildExpandableSection(
                "CHAMADAS",
                [
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AnosChamadas(
                                SubTurno: widget.SubTurno, user: widget.user),
                          ));
                    },
                    child: Container(
                      alignment: Alignment.center,
                      width: double.infinity,
                      height: 80,
                      color: Color(0xFFD9D9D9),
                      child: Text("HISTÓRICO DE CHAMADAS",
                          style: TextStyle(
                              color: Colors.black,
                              fontSize: 15,
                              fontWeight: FontWeight.bold)),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => RealizarChamada(
                                SubTurno: widget.SubTurno, user: widget.user),
                          ));
                    },
                    child: Container(
                        alignment: Alignment.center,
                        width: double.infinity,
                        height: 80,
                        color: Color(0xFFD9D9D9),
                        child: Text("REALIZAR CHAMADA",
                            style: TextStyle(
                                color: Colors.black,
                                fontSize: 15,
                                fontWeight: FontWeight.bold))),
                  ),
                ],
                _isChamadaExpanded,
                    () {
                  setState(() {
                    _isChamadaExpanded = !_isChamadaExpanded;
                  });
                },
              ),
              _buildExpandableSection(
                "CONVOCAÇÕES",
                [
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => AnosConvocacoes(
                                  user: widget.user,
                                  SubTurno: widget.SubTurno)));
                    },
                    child: Container(
                        alignment: Alignment.center,
                        width: double.infinity,
                        height: 80,
                        color: Color(0xFFD9D9D9),
                        child: Text("HISTÓRICO DE CONVOCAÇÕES",
                            style: TextStyle(
                                color: Colors.black,
                                fontSize: 15,
                                fontWeight: FontWeight.bold))),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => RealizarConvocacao(
                                  SubTurno: widget.SubTurno,
                                  user: widget.user)));
                    },
                    child: Container(
                        alignment: Alignment.center,
                        width: double.infinity,
                        height: 80,
                        color: Color(0xFFD9D9D9),
                        child: Text("REALIZAR CONVOCAÇÃO",
                            style: TextStyle(
                                color: Colors.black,
                                fontSize: 15,
                                fontWeight: FontWeight.bold))),
                  ),
                ],
                _isConvocacoesExpanded,
                    () {
                  setState(() {
                    _isConvocacoesExpanded = !_isConvocacoesExpanded;
                  });
                },
              ),
              _buildExpandableSection(
                "ALUNOS",
                [
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => ListaAlunos(
                                  SubTurno: widget.SubTurno,
                                  user: widget.user)));
                    },
                    child: Container(
                        alignment: Alignment.center,
                        width: double.infinity,
                        height: 80,
                        color: Color(0xFFD9D9D9),
                        child: Text("INFORMAÇÕES DOS ALUNOS",
                            style: TextStyle(
                                color: Colors.black,
                                fontSize: 15,
                                fontWeight: FontWeight.bold))),
                  ),
                ],
                _isAlunosExpanded,
                    () {
                  setState(() {
                    _isAlunosExpanded = !_isAlunosExpanded;
                  });
                },
              ),
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