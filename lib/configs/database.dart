import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseMethods {
// Função que adiciona novo aluno (temporário)
  Future addAluno(Map<String, dynamic> alunoMap) async {
    return await FirebaseFirestore.instance
        .collection('Alunos')
        .doc()
        .set(alunoMap);
  }

// Função que adiciona novo usuário (temporário)
  Future addUser(Map<String, dynamic> userMap) async {
    return await FirebaseFirestore.instance
        .collection('Usuarios')
        .doc()
        .set(userMap);
  }

  Future addChamada(Map<String, dynamic> chamadaMap) async {
    return await FirebaseFirestore.instance
        .collection('Chamadas')
        .doc()
        .set(chamadaMap);
  }

  Future addConvocacao(Map<String, dynamic> convocacaoMap) async {
    return await FirebaseFirestore.instance
        .collection('Convocacoes')
        .doc()
        .set(convocacaoMap);
  }

  // Função que edita uma convocação
  Future updateConvocacaoData(String profResp, String taxa, String local,
      String endereco, Timestamp dataJogo, String sub, String id) async {
    return await FirebaseFirestore.instance
        .collection("Convocacoes")
        .doc(id)
        .update({
      'ProfResp': profResp,
      'Taxa': taxa,
      'Local': local,
      'Endereço': endereco,
      'DataJogo': dataJogo,
      'Sub': sub,
    });
  }

/*
  // Função que deleta um museu
  Future deleteMuseuData(String id)async{
    return await FirebaseFirestore.instance
    .collection("Museus")
    .doc(id)
    .delete();
  } */
}
