# 📱 Aqui Ajuda

O Aplicativo em Flutter serve para conectar **voluntários, ONGs e comunidades afetadas por desastres ambientais**.  
A proposta é oferecer uma ferramenta simples, intuitiva e colaborativa que facilite a **organização, comunicação e resposta rápida** em momentos de crise.
o mesmo  nasce para reduzir essa distância, oferecendo uma plataforma simples, intuitiva e colaborativa que centraliza informações e facilita ações rápidas.

---
## 🧐 Por que o Aqui Ajuda existe?
Durante desastres naturais, cada minuto importa.
A falta de comunicação eficiente entre quem precisa de ajuda e quem pode oferecê-la resulta em atrasos críticos, desperdício de recursos e aumento do sofrimento das comunidades.
O Aqui Ajuda foi criado para diminuir o impacto dessas falhas de comunicação, permitindo que informações essenciais circulem de forma confiável e em tempo real.

## ❓ Que problema o Aqui Ajuda resolve?
Em situações emergenciais, diferentes grupos voluntários, ONGs e vítimas — operam com dados fragmentados, comunicações dispersas e falta de visibilidade sobre o que realmente está acontecendo.

Isso leva a cenários como:

 - Pontos de doação desatualizados ou inativos
 - Duplicação de esforços em áreas já atendidas
 - Falta de recursos onde a necessidade é mais urgente
 - Dificuldade em identificar locais de risco em tempo real
   
## 🚨 Quais princípios de design orientam o Aqui Ajuda?
O design e a arquitetura do Aqui Ajuda foram guiados por princípios de usabilidade, confiabilidade e escalabilidade, com base em boas práticas de sistemas distribuídos e aplicações críticas.

Entre seus pilares estão:

- Simplicidade na experiência do usuário: qualquer pessoa deve conseguir usar o app, mesmo em situações de estresse.
- Resiliência da informação: dados essenciais, como pontos de abrigo ou pedidos de ajuda, precisam estar disponíveis mesmo com conectividade limitada.
- Feedback comunitário: a própria comunidade valida e mantém os dados atualizados.
- Transparência e confiança: todos os pontos no mapa são categorizados e abertos à verificação.
- Escalabilidade: a arquitetura suporta o aumento repentino de usuários durante crises.
  

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
## 📍 Aplicativos similares 
FEMA : O aplicativo FEMA (Federal Emergency Management Agency) é uma ferramenta oficial desenvolvida pela Agência Federal de Gerenciamento de Emergências dos Estados Unidos,  é gratuito e está disponível para Android e iOS, voltada para ajudar cidadãos a se prepararem, responderem e se recuperarem de desastres naturais e outras situações de emergência.

Com o aplicativo, os usuários podem:

 - Receber alertas em tempo real sobre desastres e condições climáticas severas diretamente do Serviço Nacional de Meteorologia (NOAA).

 - Acompanhar locais afetados por furacões, tornados, enchentes, incêndios e outros eventos.

 - Acessar orientações de segurança detalhadas sobre o que fazer antes, durante e depois de diferentes tipos de desastre.

 - Criar um plano familiar de emergência, incluindo pontos de encontro, contatos importantes e rotas de evacuação.

 - Registrar pedidos de assistência federal após desastres declarados pelo governo.

 - Localizar abrigos de emergência e centros de recuperação próximos.

 - Salvar informações importantes sobre seguros, documentos e contatos de emergência em um só lugar.

Weather Update: O Weather Update é um aplicativo colaborativo que funciona de forma semelhante ao famoso Waze, mas voltado para o monitoramento do clima. A ferramenta permite que os próprios usuários compartilhem informações em tempo real sobre as condições meteorológicas em suas regiões, como temperatura, chuva, ventos, neblina e outras ocorrências.

o aplicativo reúne imagens de satélite, dados de radares e fotos enviadas pelos usuários, criando um panorama dinâmico e atualizado sobre o tempo em diferentes locais. Essa troca de informações torna o Weather Update uma ótima opção para quem deseja se planejar antes de viajar ou sair de casa, especialmente em áreas propensas a mudanças climáticas bruscas ou desastres naturais.

## 🛠️ Tecnologias Utilizadas

- [Flutter](https://flutter.dev/) (Dart)
- [Firebase](https://firebase.google.com/) (autenticação e banco de dados)
- [Google Maps API](https://developers.google.com/maps) / [Carto](https://carto.com/) / [MapTiler](https://www.maptiler.com/) (mapas e geolocalização)
- [flutter_dotenv](https://pub.dev/packages/flutter_dotenv) (variáveis de ambiente)
