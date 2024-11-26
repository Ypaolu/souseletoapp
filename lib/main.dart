import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:souseleto/paginas/home.dart';
import 'paginas/login.dart';
import 'configs/firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (BuildContext context, AsyncSnapshot snapshot){
          if(snapshot.hasError){
            return Text(snapshot.error.toString());
          }
          if(snapshot.connectionState==ConnectionState.active){
            if(snapshot.data==null){
              return Login();
            } else {
              return Selecao_de_sub(user: snapshot.data!);
            }
          }

          return Center(child: CircularProgressIndicator());
        }
    ),
  ));
}

// shift + alt + f (faz a identação do código)
// icone preto: Downgrade to version 0.13.1 and delete android/app/src/main/res/mipmap-anydpi-v26 directory worked for me.