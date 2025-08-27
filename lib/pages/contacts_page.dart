library;

/// Página de contatos
///     Exibe, processa e envia um formulário de contatos

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';

import '../template/config.dart';
import '../template/myappbar.dart';
import '../template/myfooter.dart';

// Instância privada (private) do Dio
final Dio _dio = Dio();

// Nome da página (AppBar)
final pageName = 'Faça contato';

// Página de Contatos do tipo StatefulWidget.
// Esta página contém um formulário para coletar informações de contato.
class ContactsPage extends StatefulWidget {
  // Construtor da classe ContactsPage.
  const ContactsPage({super.key});

  @override
  // createState é chamado para criar o estado mutável para este widget.
  // Ele retorna uma instância da classe de estado associada (_ContactsPage).
  State<ContactsPage> createState() => _ContactsPage();
}

// A classe de estado associada a ContactsPage.
// Ela contém o estado mutável e a lógica de construção da interface do usuário,
// incluindo o formulário de contatos, validações e manipulação de entrada.
class _ContactsPage extends State<ContactsPage> {
  // Chave global para o formulário de contatos.
  // GlobalKey permite que você acesse o estado do formulário e chame métodos como 'validate()'.
  final GlobalKey<FormState> _contactsFormKey = GlobalKey<FormState>();

  // Declara os controladores para cada campo de texto do formulário.
  // TextEditingController permite que você leia e modifique o texto nos campos.
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _subjectController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();

  @override
  void dispose() {
    // IMPORTANTE! Libera os controladores quando o widget for descartado (removido da árvore de widgets).
    // Isso evita vazamentos de memória. É uma espécie de "desconstrutor".
    _nameController.dispose();
    _emailController.dispose();
    _subjectController.dispose();
    _messageController.dispose();
    super.dispose(); // Chama o dispose da classe pai.
  }

  @override
  // O método build descreve a interface do usuário para esta página.
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyAppBar(title: pageName),
      // Corpo da página, contendo o formulário de contatos.
      body: SingleChildScrollView(
        // SingleChildScrollView garante que a tela role quando o teclado aparecer,
        // evitando que os campos de texto fiquem ocultos.
        padding: const EdgeInsets.all(32.0),
        // Adiciona preenchimento em toda a volta do conteúdo.
        child: Form(
          key: _contactsFormKey, // Associa a chave global ao formulário.
          child: Column(
            // Estica os campos horizontalmente para preencher a largura disponível.
            crossAxisAlignment: CrossAxisAlignment.stretch,

            children: <Widget>[
              const Text(
                // Adicionado 'const'.
                'Preencha todos os campos abaixo para entrar em contato conosco.',
              ),
              const SizedBox(height: 20.0), // Espaçamento vertical.
              // Campo Nome.
              TextFormField(
                // Controlador associado a este campo de texto.
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Nome', // Texto do rótulo.
                  border: OutlineInputBorder(), // Borda ao redor do campo.
                  prefixIcon: Icon(Icons.person), // Ícone à esquerda do campo.
                ),

                // Validação do nome.
                // O validador retorna uma mensagem de erro (String) se a entrada for inválida,
                // ou null se a entrada for válida.
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, escreva seu nome.';
                  }
                  // Retorne null se a validação passar.
                  return null;
                },
              ),

              // Espaçamento entre os campos.
              const SizedBox(height: 20.0),

              // Campo E-mail.
              TextFormField(
                // Controlador associado.
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'E-mail',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.email),
                ),
                // Define o tipo de teclado para e-mail (otimiza para Android e iOS).
                keyboardType: TextInputType.emailAddress,

                // Validação do email.
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, escreva seu e-mail.';
                  }
                  // Validação de e-mail usando a expressão regular.
                  if (!Config.emailRegex.hasMatch(value)) {
                    return 'Por favor, insira um email válido.';
                  }
                  // Retorne null se a validação passar.
                  return null;
                },
              ),
              // Espaçamento entre os campos.
              const SizedBox(height: 20.0),

              // Campo Assunto (subject).
              TextFormField(
                // Controlador associado.
                controller: _subjectController,
                decoration: const InputDecoration(
                  labelText: 'Assunto',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.subject),
                ),

                // Validação do assunto.
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, escreva o assunto.'; // Corrigido o texto da mensagem.
                  }
                  // Retorne null se a validação passar.
                  return null;
                },
              ),
              // Espaçamento entre os campos.
              const SizedBox(height: 20.0),

              // Campo Mensagem (message).
              TextFormField(
                // Controlador associado.
                controller: _messageController,
                decoration: const InputDecoration(
                  labelText: 'Mensagem',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.message),
                  // Alinha o label com o hint em múltiplas linhas.
                  alignLabelWithHint: true,
                ),

                // Permite múltiplas linhas para a mensagem.
                maxLines: 5,

                // Define o tipo de teclado para múltiplas linhas (otimiza para Android).
                keyboardType: TextInputType.multiline,

                // Validação da mensagem.
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, escreva sua mensagem.'; // Corrigido o texto da mensagem.
                  }

                  // Retorne null se a validação passar.
                  return null;
                },
              ),

              // Espaçamento entre os campos.
              const SizedBox(height: 20.0),

              // Botão de Enviar.
              ElevatedButton.icon(
                onPressed: () {
                  // Ação ao pressionar o botão: chama o método de envio do formulário.
                  _submitContactForm();
                },
                icon: const Icon(Icons.send), // Ícone do botão.
                label: const Text('Enviar'), // Texto do botão.
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12.0),
                  // Preenchimento interno do botão.
                  textStyle: const TextStyle(fontSize: 18),
                  // Estilo do texto do botão.
                  backgroundColor: Colors.blue[600],
                  // Cor de fundo do botão.
                  foregroundColor:
                  Colors.white, // Cor do texto e ícone do botão.
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: MyBottomNavBar(),
    );
  }

  // Método para lidar com o envio do formulário de contato.
  // É assíncrono porque realiza uma operação de rede (HTTP POST).
  void _submitContactForm() async {
    // 1. Validação do Formulário:
    // Verifica se todos os campos do formulário são válidos
    // de acordo com as regras de 'validator' definidas nos TextFormField.
    if (_contactsFormKey.currentState!.validate()) {
      // 2. Coleta dos Dados:
      // Pega o texto atual de cada controlador de campo.
      final name = _nameController.text;
      final email = _emailController.text;
      final subject = _subjectController.text;
      final message = _messageController.text;

      // 3. Formatação dos Dados para JSON:
      // Cria um mapa (chave-valor) com os dados do formulário.
      // As chaves ('name', 'email', etc.) devem corresponder ao que sua API espera.
      final Map<String, String> formData = {
        'name': name,
        'email': email,
        'subject': subject,
        'message': message,
      };

      // 5. Bloco de Envio e Tratamento de Erros:
      // Usa um bloco try-catch para gerenciar possíveis erros durante a requisição de rede.
      try {
        // 5.1. Realiza a Requisição POST com Dio:
        // Envia os dados formatados (Map formData) para a apiUrl.
        // Dio automaticamente converte o 'Map' em JSON para o corpo da requisição.
        final Response response = await _dio.post(
          Config.endPoint['contact'],
          data: formData,
          // Define o cabeçalho 'Content-Type' como JSON, informando à API o formato dos dados.
          options: Options(contentType: Headers.jsonContentType),
        );

        // 5.2. Verificação de 'mounted':
        // Garante que o widget ainda está ativo na árvore de widgets antes de usar 'context'.
        // Isso evita erros se o usuário sair da tela antes da resposta da API.
        if (!mounted) return;

        // 5.3. Processamento da Resposta da API:
        // Verifica o código de status HTTP da resposta.
        // 200 (OK) ou 201 (Created) geralmente indicam sucesso.
        if (response.statusCode == 200 || response.statusCode == 201) {
          // Exibe uma mensagem de sucesso na parte inferior da tela.
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Mensagem enviada com sucesso!')),
          );
          // Limpa os campos do formulário para uma nova entrada.
          _nameController.clear();
          _emailController.clear();
          _subjectController.clear();
          _messageController.clear();
        } else {
          // Se o status não for de sucesso, indica um erro vindo da API.
          // Imprime detalhes do erro no console apenas em modo de depuração (kDebugMode).
          if (kDebugMode) {
            print('Erro ao enviar mensagem: ${response.statusCode}');
            print('Corpo da resposta: ${response.data}');
          }
          // Exibe uma mensagem de falha com o código de status.
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Falha ao enviar mensagem. Status: ${response.statusCode}',
              ),
            ),
          );
        }
      } on DioException catch (e) {
        // 5.4. Tratamento de Erros Específicos do Dio:
        // Captura exceções lançadas pelo Dio (ex: erros de rede, timeout, etc.).

        // Verifica 'mounted' novamente antes de usar 'context'.
        if (!mounted) return;

        if (e.response != null) {
          // Erro com resposta do servidor (ex: 404 Not Found, 500 Internal Server Error).
          if (kDebugMode) {
            print('Erro de resposta do Dio: ${e.response!.statusCode}');
            print('Dados do erro: ${e.response!.data}');
          }
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Falha ao enviar. Erro do servidor: ${e.response!.statusCode}',
              ),
            ),
          );
        } else {
          // Erro sem resposta do servidor (ex: problema de conexão à internet, URL incorreta).
          if (kDebugMode) {
            print('Erro de conexão ou configuração do Dio: $e');
          }
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Erro de conexão. Verifique sua rede e o servidor.',
              ),
            ),
          );
        }
      } catch (e) {
        // 5.5. Tratamento de Outros Erros Inesperados:
        // Captura qualquer outra exceção que não seja do tipo DioException.

        // Verifica 'mounted' antes de usar 'context'.
        if (!mounted) return;

        if (kDebugMode) {
          print('Erro inesperado: $e');
        }
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Ocorreu um erro inesperado.')),
        );
      }
    } else {
      // 6. Feedback de Validação Falha:
      // Se o formulário não for válido (algum campo não passou na validação).
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, preencha todos os campos corretamente.'),
        ),
      );
    }
  }
}