# 📱 Aqui Ajuda

Aplicativo em Flutter para conectar **voluntários, ONGs e comunidades afetadas por desastres ambientais**.  
A proposta é oferecer uma ferramenta simples, intuitiva e colaborativa que facilite a **organização, comunicação e resposta rápida** em momentos de crise.

---

## 🚀 Funcionalidades

- **Login via Google** com perfis de usuário:
  - **Necessitado**: visualizar pontos de coleta, cadastrar locais de ajuda e avaliar pontos ativos.
  - **Voluntário**: cadastrar pontos de ajuda e se vincular a ONGs.
- **Geolocalização em tempo real** para identificar e cadastrar pontos.
- **Categorias de pontos no mapa**, incluindo:
  - 🛑 Área em risco
  - 🏠 Abrigo temporário (comunitário e para animais)
  - 🍞 Centro de distribuição de comida
  - 📦 Coleta de doações
  - 🚨 Pedido de ajuda/socorro
- **Feedback comunitário**: usuários podem confirmar se pontos ainda estão ativos.
- **Notificações inteligentes** baseadas na proximidade com pontos cadastrados.

---

## 🎯 Objetivo do Projeto

O **Aqui Ajuda** busca reduzir os impactos da falta de comunicação em desastres ambientais, garantindo que **informações cruciais cheguem rápido e de forma confiável** para a comunidade.  
Mais do que um app, é uma **ponte entre quem precisa e quem pode ajudar**.

---

## 🛠️ Tecnologias Utilizadas

- [Flutter](https://flutter.dev/) (Dart)
- [Firebase](https://firebase.google.com/) (autenticação e banco de dados)
- [Google Maps API](https://developers.google.com/maps) / [Carto](https://carto.com/) / [MapTiler](https://www.maptiler.com/) (mapas e geolocalização)
- [flutter_dotenv](https://pub.dev/packages/flutter_dotenv) (variáveis de ambiente)

---

## 📂 Organização do Projeto

```bash
lib/
│── main.dart
│
├── core/              # Configurações centrais (tema, rotas, utils)
├── models/            # Modelos de dados (User, Ponto, ONG)
├── services/          # Serviços (Firebase, Maps, APIs externas)
├── views/             # Telas principais do app
├── widgets/           # Componentes reutilizáveis (cards, botões, etc.)
└── assets/            # Ícones, imagens, configs de estilo
```
