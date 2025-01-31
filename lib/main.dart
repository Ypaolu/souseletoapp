import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:souseleto/paginas/home.dart';
import 'paginas/login.dart';
import 'configs/firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializa o Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(), // Ouvir mudanças no estado de autenticação
        builder: (BuildContext context, AsyncSnapshot<User?> snapshot) {
          // Verificar se há erro
          if (snapshot.hasError) {
            return Scaffold(
              body: Center(child: Text('Erro: ${snapshot.error}')), // Exibe erro
            );
          }

          // Verificar se a conexão foi estabelecida
          if (snapshot.connectionState == ConnectionState.active) {
            // Se o usuário não estiver autenticado, vai para a tela de login
            if (snapshot.data == null) {
              return Login();
            } else {
              // Se o usuário estiver autenticado, vai para a tela de login
              return Login();
            }
          }

          // Enquanto o status de autenticação estiver carregando
          return Center(child: CircularProgressIndicator()); // Indicador de carregamento
        },
      ),
    );
  }
}

// shift + alt + f (faz a identação do código)
// icone preto: Downgrade to version 0.13.1 and delete android/app/src/main/res/mipmap-anydpi-v26 directory worked for me.