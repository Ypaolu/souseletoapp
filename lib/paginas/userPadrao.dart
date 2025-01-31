import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import '../configs/auth.dart';
import 'home.dart';
import 'dart:math';

import 'login.dart';

// Função para calcular a distância entre duas coordenadas geográficas
double calcularDistancia(double lat1, double lon1, double lat2, double lon2) {
  const double R = 6371; // Raio da Terra em km
  double dLat = _grausParaRadianos(lat2 - lat1);
  double dLon = _grausParaRadianos(lon2 - lon1);

  double a = sin(dLat / 2) * sin(dLat / 2) +
      cos(_grausParaRadianos(lat1)) * cos(_grausParaRadianos(lat2)) *
          sin(dLon / 2) * sin(dLon / 2);
  double c = 2 * atan2(sqrt(a), sqrt(1 - a));
  double distancia = R * c; // Distância em km

  return distancia * 1000; // Retorna em metros
}

// Função para converter graus para radianos
double _grausParaRadianos(double graus) {
  return graus * (pi / 180);
}

const double LATITUDE_PRE_DEFINIDA = -26.477644906456536; // Exemplo de latitude (São Paulo)
const double LONGITUDE_PRE_DEFINIDA = -49.00183806709477; // Exemplo de longitude (São Paulo)
TextEditingController _localizacaoController = TextEditingController();
TextEditingController _justificativaController = TextEditingController();

class InfoUserPadrao extends StatefulWidget {
  final User user;
  const InfoUserPadrao({super.key, required this.user});

  @override
  _InfoUserPadraoState createState() => _InfoUserPadraoState();
}

class _InfoUserPadraoState extends State<InfoUserPadrao> {
  final TextEditingController _novaSenhaController = TextEditingController();
  final TextEditingController _confirmarSenhaController = TextEditingController();
  double latitude = 0.0;
  double longitude = 0.0;
  String erro = '';
  String horarioPonto = '';

  Future<Position> posicaoAtual(BuildContext context) async {
    LocationPermission permissao;

    // Verificar se os serviços de localização estão habilitados
    bool ativado = await Geolocator.isLocationServiceEnabled();
    if (!ativado) {
      // Exibe um diálogo pedindo para habilitar a localização
      await showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Serviço de Localização Desativado'),
            content: Text(
                'Por favor, habilite os serviços de localização nas configurações do dispositivo.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('OK'),
              ),
            ],
          );
        },
      );
      throw 'Serviço de localização desativado.';
    }

    // Verificar permissões de localização
    permissao = await Geolocator.checkPermission();
    if (permissao == LocationPermission.denied) {
      permissao = await Geolocator.requestPermission();
      if (permissao == LocationPermission.denied) {
        // Exibe um SnackBar informando que a permissão foi negada
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Permissão de localização negada pelo usuário.'),
            duration: Duration(seconds: 3),
          ),
        );
        throw 'Permissão negada.';
      }
    }

    if (permissao == LocationPermission.deniedForever) {
      // Exibe um diálogo pedindo para o usuário conceder permissão manualmente
      await showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Permissão Negada Permanentemente'),
            content: Text(
                'As permissões de localização foram negadas permanentemente. Você deve habilitá-las nas configurações do dispositivo.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('OK'),
              ),
            ],
          );
        },
      );
      throw 'Permissão negada permanentemente.';
    }

    // Obter a posição atual
    Position posicao = await Geolocator.getCurrentPosition();
    return posicao;
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
          child: FutureBuilder<QuerySnapshot>(
              future: FirebaseFirestore.instance
                  .collection('Usuarios')
                  .where('userId', isEqualTo: widget.user.uid) // Busca pelo userId
                  .get(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Erro: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(child: Text('Usuário não encontrado'));
                } else {
                  final data = snapshot.data!.docs.first.data() as Map<String, dynamic>;
                  String nomeUsuario = data['NomeUser'];

                  String formattedDate = '';
                  if (data['DataNasc'] is Timestamp) {
                    DateTime date = (data['DataNasc'] as Timestamp).toDate();
                    formattedDate =
                        DateFormat('dd/MM/yyyy').format(date); // Formata a data
                  }

                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(height: 35),
                      Container(
                        child: Center(
                          child: Container(
                            width: 350,
                            height: 400,
                            decoration: BoxDecoration(
                              color: Colors.grey[300],
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: Colors.black, width: 2),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Column(
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                      MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.person),
                                        SizedBox(
                                          width: 10,
                                        ),
                                        Text('NOME')
                                      ],
                                    ),
                                    Container(
                                      alignment: Alignment.center,
                                      width: 275,
                                      height: 35,
                                      decoration: BoxDecoration(
                                        color: Colors.grey[300],
                                        borderRadius: BorderRadius.circular(10),
                                        border: Border.all(
                                            color: Colors.black, width: 2),
                                      ),
                                      child: Text(data['NomeUser']),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 20),
                                Column(
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                      MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.email),
                                        SizedBox(
                                          width: 10,
                                        ),
                                        Text('EMAIL'),
                                      ],
                                    ),
                                    Container(
                                      alignment: Alignment.center,
                                      width: 275,
                                      height: 35,
                                      decoration: BoxDecoration(
                                        color: Colors.grey[300],
                                        borderRadius: BorderRadius.circular(10),
                                        border: Border.all(
                                            color: Colors.black, width: 2),
                                      ),
                                      child: Text(widget.user.email ?? 'Email'),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 20),
                                Column(
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                      MainAxisAlignment.center,
                                      children: [
                                        /* Icon(Icons.),
                                            SizedBox(
                                              width: 10,
                                            ),*/
                                        Text('CPF'),
                                      ],
                                    ),
                                    Container(
                                      alignment: Alignment.center,
                                      width: 275,
                                      height: 35,
                                      decoration: BoxDecoration(
                                        color: Colors.grey[300],
                                        borderRadius: BorderRadius.circular(10),
                                        border: Border.all(
                                            color: Colors.black, width: 2),
                                      ),
                                      child: Text(data['Cpf']),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 20),
                                Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Column(
                                        children: [
                                          Row(
                                            mainAxisAlignment:
                                            MainAxisAlignment.center,
                                            children: [
                                              Icon(Icons.calendar_month),
                                              SizedBox(
                                                width: 10,
                                              ),
                                              Text('DATA DE NASC.'),
                                            ],
                                          ),
                                          Container(
                                            alignment: Alignment.center,
                                            width: 120,
                                            height: 35,
                                            decoration: BoxDecoration(
                                              color: Colors.grey[300],
                                              borderRadius:
                                              BorderRadius.circular(10),
                                              border: Border.all(
                                                  color: Colors.black,
                                                  width: 2),
                                            ),
                                            child: Text(formattedDate),
                                          ),
                                        ],
                                      ),
                                      SizedBox(width: 35),
                                      Column(
                                        children: [
                                          Row(
                                            mainAxisAlignment:
                                            MainAxisAlignment.center,
                                            children: [
                                              Icon(Icons.key),
                                              SizedBox(
                                                width: 10,
                                              ),
                                              Text('ACESSO'),
                                            ],
                                          ),
                                          Container(
                                            alignment: Alignment.center,
                                            width: 120,
                                            height: 35,
                                            decoration: BoxDecoration(
                                              color: Colors.grey[300],
                                              borderRadius:
                                              BorderRadius.circular(10),
                                              border: Border.all(
                                                  color: Colors.black,
                                                  width: 2),
                                            ),
                                            child: Text(data['Nvl']),
                                          ),
                                        ],
                                      ),
                                    ]),
                                TextButton(
                                    onPressed: () {
                                      showDialog(
                                          context: context,
                                          builder: (BuildContext context) {
                                            return AlertDialog(
                                                title: Text('Alterar Senha'),
                                                content: Column(
                                                  mainAxisSize: MainAxisSize.min,
                                                  children: [
                                                    TextField(
                                                      controller:
                                                      _novaSenhaController,
                                                      obscureText: true,
                                                      decoration:
                                                      InputDecoration(
                                                        labelText: 'Nova Senha',
                                                        border:
                                                        OutlineInputBorder(),
                                                      ),
                                                    ),
                                                    SizedBox(height: 20),
                                                    TextField(
                                                      controller:
                                                      _confirmarSenhaController,
                                                      obscureText: true,
                                                      decoration:
                                                      InputDecoration(
                                                        labelText:
                                                        'Confirmar Nova Senha',
                                                        border:
                                                        OutlineInputBorder(),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                actions: [
                                                  TextButton(
                                                    onPressed: () async {
                                                      if (_novaSenhaController
                                                          .text ==
                                                          _confirmarSenhaController
                                                              .text &&
                                                          _novaSenhaController
                                                              .text
                                                              .isNotEmpty &&
                                                          _confirmarSenhaController
                                                              .text
                                                              .isNotEmpty) {
                                                        try {
                                                          User? user =
                                                              FirebaseAuth
                                                                  .instance
                                                                  .currentUser;
                                                          if (user != null) {
                                                            // Atualiza a senha do usuário
                                                            await user
                                                                .updatePassword(
                                                                _novaSenhaController
                                                                    .text);
                                                            ScaffoldMessenger
                                                                .of(context)
                                                                .showSnackBar(
                                                              SnackBar(
                                                                  content: Text(
                                                                      'Senha atualizada com sucesso!')),
                                                            );
                                                            Navigator.of(context).pop();
                                                          }
                                                        } catch (e) {
                                                          ScaffoldMessenger.of(
                                                              context)
                                                              .showSnackBar(
                                                            SnackBar(
                                                                content: Text(
                                                                    'Erro ao atualizar a senha: $e')),
                                                          );
                                                        }
                                                      } else {
                                                        ScaffoldMessenger.of(
                                                            context)
                                                            .showSnackBar(
                                                          SnackBar(
                                                              content: Text(
                                                                  'As senhas não coincidem')),
                                                        );
                                                      }
                                                    },
                                                    child:
                                                    Text('Atualizar Senha'),
                                                  ),
                                                  TextButton(
                                                      onPressed: () {
                                                        Navigator.of(context).pop();
                                                      },
                                                      child: Text('Cancelar'))
                                                ]);
                                          });
                                    },
                                    child: Text('Alterar Senha',
                                        style: TextStyle(
                                            color: Colors.red, fontSize: 12)))
                              ],
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 35),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          GestureDetector(
                            onTap: () async {
                              try {
                                Position posicao = await posicaoAtual(context);
                                double distancia = calcularDistancia(
                                    posicao.latitude,
                                    posicao.longitude,
                                    LATITUDE_PRE_DEFINIDA,
                                    LONGITUDE_PRE_DEFINIDA
                                );
                                DateTime horarioAtual = DateTime.now();
                                String dia = "${horarioAtual.year}-${horarioAtual.month.toString().padLeft(2, '0')}-${horarioAtual.day.toString().padLeft(2, '0')}";
                                String horario = "${horarioAtual.hour}:${horarioAtual.minute.toString().padLeft(2, '0')}";
                                // Verifica se a distância é maior que 50 metros
                                if (distancia > 310) {
                                  // Exibe o pop-up solicitando a justificativa
                                  showDialog(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      title: Text('Você não está no Seleto'),
                                      content: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          TextField(
                                            controller: _localizacaoController,
                                            decoration: InputDecoration(labelText: 'Informe onde você está'),
                                          ),
                                          TextField(
                                            controller: _justificativaController,
                                            decoration: InputDecoration(labelText: 'Justifique'),
                                          ),
                                        ],
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () async {
                                            // Salva a localização e justificativa
                                            String localizacaoAtual = _localizacaoController.text;
                                            String justificativa = _justificativaController.text;

                                            // Salvar no Firestore com a justificativa
                                            await FirebaseFirestore.instance.collection('Pontos').doc(dia).set({
                                              nomeUsuario: {
                                                horario: {
                                                  'latitude': posicao.latitude,
                                                  'longitude': posicao.longitude,
                                                  'Onde': localizacaoAtual,
                                                  'Justificativa': justificativa,
                                                },
                                              },
                                            }, SetOptions(merge: true));

                                            Navigator.pop(context);
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              SnackBar(
                                                content: Text("Ponto batido com sucesso!"),
                                                backgroundColor: Colors.green,
                                                duration: Duration(seconds: 2),
                                              ),
                                            );
                                          },
                                          child: Text('Salvar'),
                                        ),
                                      ],
                                    ),
                                  );
                                } else {
                                  // Se estiver no local correto, apenas salva o ponto normalmente
                                  await FirebaseFirestore.instance.collection('Pontos').doc(dia).set({
                                    nomeUsuario: {
                                      horario: {
                                        'latitude': posicao.latitude,
                                        'longitude': posicao.longitude,
                                      },
                                    },
                                  }, SetOptions(merge: true));
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text("Ponto batido com sucesso!"),
                                      backgroundColor: Colors.green,
                                      duration: Duration(seconds: 2),
                                    ),
                                  );
                                }
                              } catch (e) {
                                print('Erro: $e');
                              }
                            },
                            child: Container(
                              color: Colors.transparent,
                              child: Icon(
                                Icons.fingerprint,
                                size: 200,
                              ),
                            ),
                          ),
                          SizedBox(width: 20),
                          Container(
                            width: 150,
                            height: 200,
                            decoration: BoxDecoration(
                              color: Colors.grey[300],
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: Colors.black, width: 2),
                            ),
                            child: StreamBuilder<DocumentSnapshot>(
                              stream: FirebaseFirestore.instance
                                  .collection('Pontos')
                                  .doc("${DateTime.now().year}-${DateTime.now().month.toString().padLeft(2, '0')}-${DateTime.now().day.toString().padLeft(2, '0')}")
                                  .snapshots(),
                              builder: (context, snapshot) {
                                if (!snapshot.hasData || !snapshot.data!.exists) {
                                  return Center(child: Text('Nenhum ponto hoje', textAlign: TextAlign.center));
                                }

                                // Obter dados do documento
                                Map<String, dynamic> data = snapshot.data!.data() as Map<String, dynamic>;

                                if (!data.containsKey(nomeUsuario)) {
                                  return Center(child: Text('Nenhum ponto hoje', textAlign: TextAlign.center));
                                }

                                // Obter horários do usuário
                                Map<String, dynamic> horarios = data[nomeUsuario] as Map<String, dynamic>;

                                return ListView(
                                  children: horarios.entries.map((entry) {
                                    String horario = entry.key;
                                    Map<String, dynamic> localizacao = entry.value;

                                    return ListTile(
                                      title: Text(horario),
                                      onTap: () {
                                        // Mostrar pop-up com mais detalhes
                                        showDialog(
                                          context: context,
                                          builder: (context) => AlertDialog(
                                            title: Text('Detalhes do Ponto'),
                                            content: Text(
                                                "Horário: $horario\n"
                                                    "Localização: ${localizacao['latitude']}, ${localizacao['longitude']}\n"
                                                    "Onde estava: ${localizacao.containsKey('Onde') ? localizacao['Onde'] : 'Campo do Seleto'}"
                                            ),
                                          ),
                                        );
                                      },
                                    );
                                  }).toList(),
                                );
                              },
                            ),
                          ),


                        ],
                      ),
                    ],
                  );
                }
              })),
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
            ],
          ),
          color: Color.fromARGB(255, 57, 177, 61),
        ),
      ),
    );
  }
}