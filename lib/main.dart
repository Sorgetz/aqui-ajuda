import 'package:aqui_ajuda_app/view/login_page.dart';
import 'package:aqui_ajuda_app/view/test_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // variaveis de ambiente por conta do mapa
  await dotenv.load(fileName: ".env");
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      initialRoute: '/',
      routes: {'/': (_) => Login(), '/teste': (_) => Teste()},
      // home: Login(),
    );
  }
}
