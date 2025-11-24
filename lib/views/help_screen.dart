import 'package:flutter/material.dart';

class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text(
          "Sobre o Aqui Ajuda",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        automaticallyImplyLeading: false,
        backgroundColor: Colors.pinkAccent,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // LOGO
            Center(
              child: Icon(
                Icons.volunteer_activism,
                size: 80,
                color: Colors.pinkAccent,
              ),
            ),
            const SizedBox(height: 10),

            Center(
              child: Text(
                "Aqui Ajuda",
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[900],
                ),
              ),
            ),
            Center(
              child: Text(
                "Conectando comunidades em crise",
                style: TextStyle(fontSize: 14, color: Colors.grey[700]),
              ),
            ),

            const SizedBox(height: 25),

            _section(
              icon: Icons.info_outline,
              title: "O que é o Aqui Ajuda?",
              content:
                  "Um aplicativo colaborativo que conecta voluntários, ONGs e comunidades afetadas por desastres ambientais, facilitando a comunicação, organização e resposta rápida em momentos de crise.",
            ),

            _section(
              icon: Icons.question_mark_rounded,
              title: "Por que ele existe?",
              content:
                  "Durante desastres naturais, cada minuto importa. A falta de comunicação eficiente causa atrasos críticos, desperdício de recursos e aumenta o sofrimento das vítimas. O Aqui Ajuda nasce para reduzir essa distância, centralizando informações essenciais em tempo real.",
            ),

            _section(
              icon: Icons.report_problem,
              title: "O que o app resolve?",
              content:
                  "O aplicativo evita dados fragmentados e comunicação dispersa, permitindo que vítimas e voluntários encontrem informações atualizadas sobre pontos de ajuda, riscos e necessidades urgentes.",
            ),

            _bulletList(
              title: "Problemas comuns evitados:",
              bullets: [
                "Pontos de doação desatualizados",
                "Duplicação de esforços",
                "Falta de recursos em áreas urgentes",
                "Dificuldade em identificar áreas de risco",
              ],
            ),

            _section(
              icon: Icons.brush_rounded,
              title: "Princípios de design",
              content:
                  "Usabilidade, confiabilidade e escalabilidade. O app foi projetado para funcionar mesmo em situações de estresse, baixa conectividade e picos de usuários.",
            ),

            _bulletList(
              title: "Pilares do Aqui Ajuda:",
              bullets: [
                "Simplicidade para qualquer usuário",
                "Resiliência das informações",
                "Validação comunitária dos pontos",
                "Transparência e confiança",
                "Arquitetura escalável",
              ],
            ),

            const SizedBox(height: 10),
            Divider(),

            _section(
              icon: Icons.star_rate_rounded,
              title: "Funcionalidades principais",
              content: "",
            ),

            _bulletList(
              bullets: [
                "Login via Google",
                "Cadastro e visualização de pontos de ajuda",
                "Categorias como abrigos, riscos, doações e pedidos de socorro",
                "Feedback comunitário para validar pontos ativos",
                "Geolocalização em tempo real",
                "Notificações baseadas na proximidade",
                "Perfis: voluntário ou necessitado",
              ],
            ),

            const SizedBox(height: 10),
            Divider(),

            _section(
              icon: Icons.public,
              title: "Aplicativos semelhantes",
              content:
                  "FEMA (EUA) e Weather Update (colaborativo) inspiraram algumas funcionalidades de alerta e participação comunitária.",
            ),

            const SizedBox(height: 25),
          ],
        ),
      ),
    );
  }

  Widget _section({
    required IconData icon,
    required String title,
    required String content,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 28, color: Colors.pinkAccent),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  content,
                  style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _bulletList({String? title, required List<String> bullets}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.only(left: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null)
            Text(
              title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          const SizedBox(height: 6),
          ...bullets.map(
            (b) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 3),
              child: Row(
                children: [
                  const Icon(Icons.circle, size: 8, color: Colors.pinkAccent),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      b,
                      style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
