import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../configs/auth.dart';
import '../configs/database.dart';
import 'login.dart';

List<String> nvlUser = [
  'Padrão',
  'Master',
  'Professor'
]; // Lista de opções do dropdown

class AddUser extends StatefulWidget {
  const AddUser({super.key});

  @override
  State<AddUser> createState() => _AddUserState();
}

class _AddUserState extends State<AddUser> {
  DateTime? selectedDataNasc;
  String? selectedNvlUser = 'Padrão';

  TextEditingController nomeUsercontroller = TextEditingController();
  TextEditingController dataNasccontroller = TextEditingController();
  TextEditingController cpfcontroller = TextEditingController();
  TextEditingController _emailcontroller = TextEditingController();

  Future<bool> verificarCpfExistente(String cpf) async {
    try {
      // A coleção de alunos pode ser algo como 'alunos'
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('Usuarios')
          .where('Cpf', isEqualTo: cpf) // Consultar pelo campo CPF
          .get();

      // Se a consulta retornar algum documento, significa que o CPF já existe
      return querySnapshot.docs.isNotEmpty;
    } catch (e) {
      // Caso haja algum erro na consulta, você pode capturar e mostrar o erro
      print("Erro ao verificar CPF: $e");
      return false;
    }
  }

  // Função para fazer upload dos dados
  uploadData() async {
    String cpf = cpfcontroller.text.trim();
    bool cpfExistente = await verificarCpfExistente(cpf);

    if (cpfExistente) {
      // Exibe a mensagem de erro, mas não fecha a aba
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Já existe um usuário cadastrado com esse CPF.')),
      );
      // Não faz nada mais, a tela de cadastro permanece aberta
    } else {
      if (_formValid()) {
        if (selectedDataNasc != null && selectedNvlUser != null) {
          DateTime combinedDateTimeNasc = DateTime(
            selectedDataNasc!.year,
            selectedDataNasc!.month,
            selectedDataNasc!.day,
          );

          String userId = FirebaseAuth.instance.currentUser!.uid;

          Map<String, dynamic> uploaddata = {
            'NomeUser': nomeUsercontroller.text,
            'DataNasc': Timestamp.fromDate(combinedDateTimeNasc),
            'Cpf': cpfcontroller.text,
            'Nvl': selectedNvlUser,
            'userId': userId, // Armazena o nível selecionado
          };

          // Aqui você envia os dados para o Firestore (ou qualquer banco de dados que esteja usando)
          await DatabaseMethods().addUser(uploaddata);

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                "USUÁRIO CRIADO COM SUCESSO!",
                style: TextStyle(color: Colors.white),
              ),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
            ),
          );
        } else {
          // Caso a data ou o horário não tenham sido selecionados
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                "Selecione a data e o horário!",
                style: TextStyle(color: Colors.white),
              ),
              backgroundColor: Colors.red,
              duration: Duration(seconds: 2),
            ),
          );
        }
      } else {
        // Exibir erro caso os campos não sejam preenchidos
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "Preencha todos os campos obrigatórios!",
              style: TextStyle(color: Colors.white),
            ),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }

  // Função para verificar se os campos do formulário estão válidos
  bool _formValid() {
    return nomeUsercontroller.text.isNotEmpty &&
        _emailcontroller.text.isNotEmpty &&
        cpfcontroller.text.isNotEmpty &&
        selectedDataNasc != null;
  }

  // Exibindo o calendário para selecionar a data de nascimento
  Future<void> _mostrarCalendarioPersonalizado(BuildContext context) async {
    DateTime? dataSelecionadaNasc = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
    );

    if (dataSelecionadaNasc != null) {
      setState(() {
        selectedDataNasc = dataSelecionadaNasc;
        dataNasccontroller.text =
        '${dataSelecionadaNasc.day}/${dataSelecionadaNasc.month}/${dataSelecionadaNasc.year}';
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
                "INFORMAÇÕES DO USUÁRIO",
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
                  Column(
                    children: [
                      Text("Data de Nascimento",
                          style: TextStyle(
                              fontSize: 15, fontWeight: FontWeight.bold)),
                      GestureDetector(
                        onTap: () => _mostrarCalendarioPersonalizado(context),
                        child: Container(
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: Colors.grey[300]),
                          width: 120,
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
                  SizedBox(width: 15),
                  Column(
                    children: [
                      Text("Nome do Usuário",
                          style: TextStyle(
                              fontSize: 15, fontWeight: FontWeight.bold)),
                      Container(
                        width: 120,
                        height: 60,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: Colors.grey[300],
                        ),
                        child: TextFormField(
                          controller: nomeUsercontroller,
                          decoration: InputDecoration(
                            contentPadding: EdgeInsets.symmetric(vertical: 18),
                            border: InputBorder.none,
                          ),
                          style: TextStyle(fontSize: 15),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(height: 15),
              Column(
                children: [
                  Text(
                    "CPF do Usuário",
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
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
                      controller: cpfcontroller,
                      decoration: InputDecoration(
                        contentPadding: EdgeInsets.symmetric(vertical: 18),
                        border: InputBorder.none,
                      ),
                      style: TextStyle(fontSize: 15),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
              Column(
                children: [
                  Text(
                    "Email",
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
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
                      controller: _emailcontroller,
                      decoration: InputDecoration(
                        contentPadding: EdgeInsets.symmetric(vertical: 18),
                        border: InputBorder.none,
                      ),
                      style: TextStyle(fontSize: 15),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
              // Dropdown para selecionar o nível do usuário
              Column(
                children: [
                  Text(
                    "Nível de Usuário",
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  DropdownButton<String>(
                    value: selectedNvlUser,
                    icon: const Icon(Icons.arrow_downward),
                    elevation: 16,
                    style: const TextStyle(color: Colors.black),
                    underline: Container(
                      height: 2,
                      color: Colors.greenAccent,
                    ),
                    onChanged: (String? newValue) {
                      setState(() {
                        selectedNvlUser = newValue;
                      });
                    },
                    items:
                    nvlUser.map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                  ),
                ],
              ),
              ElevatedButton(
                onPressed: () async {
                  String cpf = cpfcontroller.text.trim();
                  bool cpfExistente = await verificarCpfExistente(cpf);

                  if (cpfExistente) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          content: Text(
                              'Já existe um usuário cadastrado com esse CPF.')),
                    );
                  } else if (nomeUsercontroller.text.isEmpty ||
                      cpfcontroller.text.isEmpty ||
                      selectedDataNasc == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('PREENCHA TODOS OS CAMPOS')),
                    );
                  } else {
                    // Primeiro, registra o usuário
                    final message = await AuthService().registrar(
                      email: _emailcontroller.text,
                      senha: 'mudarSenha@123', // Senha padrão
                    );

                    // Verifica se a autenticação foi bem-sucedida
                    if (message != null && message.contains('Sucesso')) {
                      // Se a autenticação foi bem-sucedida, salva os dados no Firestore
                      await uploadData();

                      // Exibe uma mensagem de sucesso
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            "USUÁRIO CRIADO COM SUCESSO!",
                            style: TextStyle(color: Colors.white),
                          ),
                          backgroundColor: Colors.green,
                          duration: Duration(seconds: 2),
                        ),
                      );

                      // Depois de salvar os dados e exibir a mensagem, navega para a tela de login
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(builder: (context) => const Login()),
                      );
                    } else {
                      // Se ocorreu um erro na autenticação, exibe a mensagem de erro
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                            content: Text(message ?? 'Erro desconhecido!')),
                      );
                    }
                  }
                },
                child: Text(
                  'SALVAR',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey[300],
                ),
              )
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
            ],
          ),
          color: Color.fromARGB(255, 57, 177, 61),
        ),
      ),
    );
  }
}