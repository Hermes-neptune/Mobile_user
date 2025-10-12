# Mobile_user

Um aplicativo móvel Flutter moderno e completo para gerenciamento de perfil de usuário, conquistas de jogos, interações sociais e muito mais. Desenvolvido com foco em experiência do usuário, design responsivo e arquitetura modular.

## 📋 Sobre o Projeto

O **Mobile_user** é uma aplicação multiplataforma desenvolvida em Flutter que oferece uma experiência rica e interativa para usuários gerenciarem seus perfis, acompanharem conquistas em jogos, interagirem com amigos e personalizarem suas preferências. O aplicativo suporta Android, iOS e Web, proporcionando uma experiência consistente em todas as plataformas.

### Principais Características

- 🎮 **Gerenciamento de Jogos:** Acompanhe seus jogos favoritos e explore novos títulos
- 🏆 **Sistema de Conquistas:** Visualize e desbloqueie conquistas e medalhas
- 👥 **Rede Social:** Conecte-se com amigos, chat em grupo e individual
- 📱 **Design Responsivo:** Interface otimizada para diferentes tamanhos de tela
- 🔔 **Notificações:** Sistema completo de notificações em tempo real
- ⚙️ **Configurações Personalizáveis:** Customize a experiência do aplicativo

## 🛠️ Tecnologias Utilizadas

- **Flutter:** Framework principal para desenvolvimento multiplataforma
- **Dart:** Linguagem de programação
- **HTTP:** Comunicação com APIs REST
- **SharedPreferences:** Armazenamento local de dados
- **URL Launcher:** Abertura de links externos

## Estrutura de Projeto

```
Mobile_user/
├── android/             # Configurações e recursos otimizados para a plataforma Android
├── ios/                 # Configurações e recursos otimizados para a plataforma iOS
├── lib/                 # O coração do aplicativo: código-fonte Dart modular e bem-estruturado
│   ├── achievement_details_screen.dart # Detalhes imersivos de conquistas/jogos
│   ├── api_config.dart                 # Configuração centralizada de APIs
│   ├── bottom_nav.dart                 # Navegação intuitiva e responsiva
│   ├── chat_screen.dart                # Tela de chat individual
│   ├── forgot_password_screen.dart     # Recuperação de senha
│   ├── friend_profile_screen.dart      # Visualização de perfil de amigos
│   ├── game_details_screen.dart        # Visão aprofundada sobre seus jogos
│   ├── group_chat_screen.dart          # Chat em grupo
│   ├── group_settings_screen.dart      # Configurações de grupo
│   ├── home_screen.dart                # O ponto de partida para a jornada do usuário
│   ├── login_screen.dart               # Tela de autenticação
│   ├── main.dart                       # O ponto de entrada principal do aplicativo
│   ├── notifications_screen.dart       # Gerenciamento eficiente de notificações
│   ├── profile_screen.dart             # Controle total sobre o perfil do usuário
│   ├── request_screen.dart             # Gerenciamento de solicitações
│   ├── settings_screen.dart            # Personalização completa da experiência
│   ├── social_screen.dart              # Interações sociais
│   └── tournament_screen.dart          # Torneios e competições
├── assets/              # Recursos estáticos (imagens, ícones, etc.)
├── test/                # Testes unitários e de widget para garantir a qualidade do código
├── web/                 # Suporte para a plataforma Web, expandindo o alcance do aplicativo
├── .gitignore           # Gerenciamento de versão otimizado, ignorando arquivos desnecessários
├── pubspec.yaml         # Gerenciamento de dependências e metadados do projeto Flutter
├── README.md            # Este guia essencial para o projeto
└── LICENSE              # Detalhes da licença para uso e distribuição
```

## Funcionalidades 

### 🎯 Funcionalidades Principais

*   **Navegação Inferior:** Acesso rápido às seções cruciais do aplicativo através de uma barra de navegação intuitiva
*   **Tela Inicial (Home):** Hub central personalizado com informações relevantes, jogos em destaque e notícias
*   **Gerenciamento de Notificações:** Sistema completo para manter-se atualizado com alertas e mensagens importantes
*   **Perfil do Usuário:** 
    - Visualização e edição de informações pessoais
    - Gerenciamento de créditos e conquistas
    - Exibição de medalhas e estatísticas
    - Histórico de atividades
*   **Detalhes de Conquistas e Jogos:** 
    - Visualização detalhada de conquistas desbloqueadas
    - Informações completas sobre jogos
    - Progresso e estatísticas
*   **Configurações Personalizáveis:** 
    - Controle de notificações
    - Preferências de usuário
    - Configurações de conta
    - Links para suporte e informações
*   **Recursos Sociais:**
    - Chat individual com amigos
    - Chat em grupo
    - Visualização de perfis de amigos
    - Sistema de solicitações de amizade
    - Gerenciamento de grupos
*   **Autenticação Segura:**
    - Login com validação
    - Recuperação de senha
    - Gerenciamento de sessão

## Execução Local

### Pré-requisitos 

Antes de começar, certifique-se de ter os seguintes requisitos instalados:

- **Flutter SDK:** Versão 3.0.0 ou superior
- **Dart SDK:** Incluído com o Flutter
- **Android Studio** ou **Xcode** (dependendo da plataforma alvo)
- **Dispositivo físico** ou **emulador/simulador** configurado

Valide sua instalação do Flutter com o comando:

```bash
flutter doctor
```

Este comando verificará todas as dependências necessárias e informará sobre possíveis problemas.

### Passos para Instalação 

1.  **Clone o Repositório:** Adquira o código-fonte com um simples comando:
    ```bash
    git clone https://github.com/Hermes-neptune/Mobile_user.git
    cd Mobile_user
    ```

2.  **Instale as Dependências:** Garanta que todas as bibliotecas necessárias estejam prontas para uso:
    ```bash
    flutter pub get
    ```

3.  **Execute o Aplicativo:** Conecte seu dispositivo (Android ou iOS) ou inicie um emulador/simulador e execute:
    ```bash
    flutter run
    ```
    Para uma experiência web (se configurada):
    ```bash
    flutter run -d chrome # ou seu navegador preferido
    ```

### 🔧 Comandos Úteis

```bash
# Verificar problemas de configuração
flutter doctor -v

# Limpar cache e rebuildar
flutter clean && flutter pub get

# Executar em modo release
flutter run --release

# Executar em dispositivo específico
flutter devices  # Lista dispositivos disponíveis
flutter run -d <device-id>

# Gerar APK para Android
flutter build apk

# Gerar IPA para iOS
flutter build ios
```

## 🐛 Solução de Problemas

### Problemas Comuns

**Erro de dependências:**
```bash
flutter clean
flutter pub get
```

**Erro de build:**
```bash
# Para Android
cd android && ./gradlew clean
cd ..

# Para iOS
cd ios && rm -rf Pods Podfile.lock
pod install
cd ..
```

**Problemas de conexão com API:**
- Verifique se o arquivo `lib/api_config.dart` está configurado corretamente
- Certifique-se de que o dispositivo/emulador tem acesso à internet
- Verifique se o backend está funcionando e acessível

## 📸 Screenshots

*Adicione screenshots do aplicativo aqui para demonstrar as funcionalidades*

## 🔐 Segurança

- As senhas são tratadas de forma segura através de comunicação HTTPS
- Tokens de autenticação são armazenados localmente de forma segura
- As preferências do usuário são armazenadas usando SharedPreferences

## 🌐 APIs e Integrações

O aplicativo se comunica com APIs backend para:
- Autenticação de usuários
- Gerenciamento de perfil
- Sistema de amizades
- Notificações
- Jogos em destaque
- Sistema de conquistas

## Contribuição

Contribuições são muito bem-vindas! Siga os passos abaixo para contribuir com o projeto:

1.  **Faça um Fork:** Crie sua própria cópia do repositório clicando em "Fork" no GitHub
2.  **Crie uma Nova Branch:** Desenvolva suas funcionalidades em um ambiente isolado
    ```bash
    git checkout -b feature/sua-nova-feature
    ```
3.  **Realize Suas Alterações e Commit:** Implemente suas ideias e registre-as
    ```bash
    git commit -m 'Implementa funcionalidade X com maestria'
    ```
4.  **Envie Suas Alterações:** Compartilhe seu trabalho
    ```bash
    git push origin feature/sua-nova-feature
    ```
5.  **Abra um Pull Request:** Proponha suas melhorias para integração ao projeto principal

### 📝 Diretrizes para Contribuição

- Siga o estilo de código existente no projeto
- Escreva mensagens de commit claras e descritivas
- Adicione testes quando apropriado
- Atualize a documentação conforme necessário
- Certifique-se de que o código compila sem erros ou warnings

## 📄 Licença: Liberdade e Transparência

Este projeto é distribuído sob a licença **MIT License**. Consulte o arquivo `LICENSE` para todos os detalhes e termos de uso.

## 👥 Autores e Reconhecimentos

- **MTSmalow** - Desenvolvedor Principal - [MTSmalow](https://github.com/MTSmalow)

## 📞 Suporte e Contato

Para dúvidas, sugestões ou reportar problemas:
- Abra uma [Issue](https://github.com/Hermes-neptune/Mobile_user/issues) no GitHub
- Entre em contato através do perfil do GitHub

## 🚀 Roadmap e Futuras Funcionalidades

- [ ] Implementação de modo escuro/claro
- [ ] Suporte a múltiplos idiomas (i18n)
- [ ] Integração com mais plataformas de jogos
- [ ] Sistema de conquistas em tempo real
- [ ] Melhorias na interface do chat
- [ ] Notificações push
- [ ] Testes automatizados expandidos
