import 'package:aqui_ajuda_app/firebase_options.dart';
import 'package:aqui_ajuda_app/viewmodel/map_point_viewmodel.dart';
import 'package:aqui_ajuda_app/views/login_page.dart';
import 'package:aqui_ajuda_app/views/map_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // variaveis de ambiente por conta do mapa
  await dotenv.load(fileName: ".env");
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(
    MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => MapPointViewModel())],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      initialRoute: '/',
      routes: {'/': (_) => Login(), '/mapa': (_) => Map()},
    );
  }
}
