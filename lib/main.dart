import 'package:aqui_ajuda_app/views/login_page.dart';
import 'package:aqui_ajuda_app/views/map_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  // variaveis de ambiente por conta do mapa
  await dotenv.load(fileName: ".env");

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // parte inicial
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      // teste rotas
      initialRoute: '/',
      routes: {'/': (_) => Login(), '/mapa': (_) => Map()},
      // home: Login(),
    );
  }
}
