import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodel/map_point_viewmodel.dart';
import '../viewmodel/feedback_viewmodel.dart';
import '../model/map_point.dart';
import '../model/feedback.dart' hide Feedback;
import 'package:intl/intl.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  String formatDate(DateTime dt) {
    return DateFormat('dd/MM/yyyy HH:mm').format(dt);
  }

  String mapEmoji(String type) {
    switch (type) {
      case "risk":
        return "🛑 Área em risco";
      case "shelter":
        return "🏠 Abrigo";
      case "animal_shelter":
        return "🐾 Abrigo para animais";
      case "food":
        return "🍞 Distribuição de comida";
      case "donation":
        return "📦 Coleta de doações";
      case "help":
        return "🚨 Pedido de ajuda";
      default:
        return "📍 Ponto";
    }
  }

  @override
  Widget build(BuildContext context) {
    final mapVM = Provider.of<MapPointViewModel>(context);
    final fbVM = Provider.of<FeedbackViewModel>(context);
    final user = ModalRoute.of(context)!.settings.arguments;
    final UserCredential? appUser = user as UserCredential?;

    final userPoints = mapVM.mapPoints
        .where((p) => p.createdBy == appUser!.user!.displayName)
        .toList();

    final userFeedbacks = fbVM.feedbacks
        .where((fb) => fb.createdBy == appUser!.user!.displayName)
        .toList();

    final pointById = {
      for (var p in mapVM.mapPoints)
        if (p.active &&
            p.id != null &&
            userFeedbacks.map((f) => f.mapPointId).toList().contains(p.id))
          p.id!: p,
    };

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.pinkAccent,
        elevation: 0,
        title: const Text(
          "Aqui Ajuda",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
        ),
      ),

      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ---------------------------------------------------
          // BEM-VINDO
          // ---------------------------------------------------
          Text(
            "Olá! 👋",
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 4),
          Text(
            "Aqui está um resumo das suas atividades dentro do Aqui Ajuda.",
            style: TextStyle(color: Colors.grey.shade700),
          ),
          SizedBox(height: 20),
          Text(
            "📍 Seus pontos cadastrados",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 12),

          if (userPoints.isEmpty)
            Text("Você ainda não cadastrou nenhum ponto."),

          for (var p in userPoints)
            Container(
              margin: EdgeInsets.only(bottom: 12),
              padding: EdgeInsets.all(16),
              clipBehavior: Clip.hardEdge,
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    p.title,
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 4),
                  Text(mapEmoji(p.type)),
                  SizedBox(height: 6),
                  Text(
                    "Criado em: ${formatDate(p.createdAt.toDate())}",
                    style: TextStyle(fontSize: 13, color: Colors.grey.shade800),
                  ),
                  SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(
                        p.active ? Icons.check_circle : Icons.cancel,
                        color: p.active ? Colors.green : Colors.red,
                        size: 18,
                      ),
                      SizedBox(width: 6),
                      Text(
                        p.active ? "Ativo" : "Inativo",
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ],
              ),
            ),

          SizedBox(height: 30),

          // ---------------------------------------------------
          // FEEDBACKS DO USUÁRIO
          // ---------------------------------------------------
          Text(
            "⭐ Seus feedbacks",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 12),

          if (userFeedbacks.isEmpty || pointById.isEmpty)
            Text("Você ainda não avaliou nenhum ponto."),

          for (var fb in userFeedbacks)
            if (pointById[fb.mapPointId] != null)
              Container(
                margin: EdgeInsets.only(bottom: 12),
                padding: EdgeInsets.all(16),
                clipBehavior: Clip.hardEdge,
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Ponto: ${pointById[fb.mapPointId]?.title}",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),

                    SizedBox(height: 6),

                    Text(
                      "⚡ ${fb.efficiency} | ♿ ${fb.accessibility} | 🛡️ ${fb.security} | 🗂️ ${fb.organization}",
                    ),

                    SizedBox(height: 6),

                    Row(
                      children: [
                        Icon(
                          fb.isAvailable ? Icons.check_circle : Icons.cancel,
                          color: fb.isAvailable ? Colors.green : Colors.red,
                          size: 18,
                        ),
                        SizedBox(width: 6),
                        Text(fb.isAvailable ? "Ainda ativo" : "Ponto inativo"),
                      ],
                    ),

                    if (fb.experience != null && fb.experience != "") ...[
                      SizedBox(height: 6),
                      Text(fb.experience!),
                    ],

                    SizedBox(height: 6),

                    Text(
                      "Avaliado em: ${formatDate(fb.createdAt.toDate())}",
                      style: TextStyle(color: Colors.grey.shade700),
                    ),
                  ],
                ),
              ),
        ],
      ),
    );
  }
}
