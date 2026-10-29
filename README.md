# Kits para Oficinas

Programação para Dispositivos Móveis (IFS – Campus Lagarto).

App em Flutter para montar kits de materiais para oficinas: o usuário entra, vê o catálogo, abre os detalhes de um material e monta o seu kit.

**Equipe:** José Fabrício Santos Gregório, Ramon dos Santos Oliveira, Victor Santos Pinho e Vinicius Dantas Bernardo.

---

## Passo a passo para abrir o projeto

### 1. Instalar o que precisa (só na primeira vez)

- **Git:** https://git-scm.com/downloads
- **Flutter** (versão 3.27 ou mais nova): siga o guia oficial em https://docs.flutter.dev/get-started/install.
  No final, o comando abaixo precisa funcionar no terminal:

  ```bash
  flutter --version
  ```

- **Um editor:** VS Code com as extensões **Flutter** e **Dart**, ou Android Studio com o plugin Flutter.
- **Onde rodar o app** (escolha um):
  - **Google Chrome:** é o jeito mais fácil, não precisa de mais nada.
  - **Emulador Android:** crie um no Android Studio, em *Device Manager*.
  - **Celular Android:** ative a *Depuração USB* nas opções do desenvolvedor e ligue o celular no cabo.

Para conferir se está tudo certo, rode o comando abaixo. Os itens com ✓ verde estão prontos. Não precisa ter tudo verde, só o Flutter e a opção onde você vai rodar.

```bash
flutter doctor
```

### 2. Baixar o projeto

```bash
git clone https://github.com/FabricioGregorio/prova_mobile_kits_oficinas.git
```

```bash
cd prova_mobile_kits_oficinas
```

### 3. Baixar as dependências (Dio etc.)

```bash
flutter pub get
```

### 4. Rodar o app

Veja os aparelhos disponíveis:

```bash
flutter devices
```

Rode no Chrome:

```bash
flutter run -d chrome
```

Ou rode no emulador ou no celular Android (com ele aberto ou conectado):

```bash
flutter run
```

Se tiver mais de um aparelho, o Flutter pergunta qual usar. Também dá para rodar pelo VS Code: escolha o aparelho no canto inferior direito e aperte **F5**.

### 5. Entrar no app

Todas as contas usam a senha **`123456`**:

| E-mail | Kit inicial (segundo a prova) |
|---|---|
| `ana@ifs.edu.br` | 3 canetas e 2 cadernos |
| `bruno@ifs.edu.br` | 4 lápis, 2 borrachas e 1 régua |
| `carla@ifs.edu.br` | 2 colas e 5 canetas |
| `danilo@ifs.edu.br` | vazio |

Como outros alunos usam a mesma API, os kits podem estar diferentes da tabela (o da ana, por exemplo, estava vazio quando testamos).

Também dá para criar uma conta nova pelo link **"Não tem conta? Cadastre-se"**.

> **Atenção:** a API é a mesma para a turma toda. Se você mexer no kit do bruno ou da carla, a mudança vale para todo mundo. Para testar, prefira a conta do **danilo** e deixe o kit vazio no final.

---

## Onde fica cada coisa

```
lib/
├── main.dart, app.dart   início do app
├── core/                 endereço da API, Dio, sessão, estados da tela e tema
├── model/                Usuario, Material, ItemKit e Kit
├── repository/           requisições à API (Dio)
├── viewmodel/            um ViewModel (ChangeNotifier) por tela
└── view/                 telas
    └── widgets/          componentes reutilizáveis (cartão, seletor, botão de remover, textos)
```

O endereço da API fica em `lib/core/config/api_config.dart` (`http://2.25.235.160:3000`).

---

## Problemas comuns

| Problema | Solução |
|---|---|
| `flutter` não é reconhecido no terminal | O Flutter não está no PATH. Refaça o passo de PATH do guia de instalação e abra um terminal novo. |
| Erro de pacote ou `dio` não encontrado | Rode `flutter pub get` de novo. |
| "Não foi possível conectar à API" | Confira a internet e se a API está no ar: abra http://2.25.235.160:3000/materiais no navegador. |
| No Android não carrega nada | A API usa `http`. O `android/app/src/main/AndroidManifest.xml` já tem `usesCleartextTraffic="true"` e a permissão de INTERNET, então não apague essas linhas. |
| Erro estranho depois de atualizar o projeto | Rode `flutter clean` e depois `flutter pub get`. |

Para verificar se o código está sem erros:

```bash
flutter analyze
```

---

## O que entregar

Pela prova, enviamos a pasta `lib`, o arquivo `pubspec.yaml` e o PDF com a documentação da implementação.
