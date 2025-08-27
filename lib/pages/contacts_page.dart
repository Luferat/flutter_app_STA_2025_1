library;

/// Página de contatos
///     Exibe, processa e envia um formulário de contatos

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';

import '../template/config.dart';
import '../template/myappbar.dart';
import '../template/myfooter.dart';
import '../template/mydrawer.dart'; // Importa o menu lateral

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
    // LayoutBuilder permite ajustar o conteúdo para resoluções diferentes
    return LayoutBuilder(
      builder: (context, constraints) {
        // Se a largura é de 1080+
        if (constraints.maxWidth > 1080) {
          // Versão para desktop com menu lateral fixo
          return Row(
            children: [
              const MyDrawer(), // O menu lateral fixo
              Expanded(
                // O Scaffold aninhado para ter a AppBar na página de conteúdo
                child: Scaffold(
                  appBar: MyAppBar(title: pageName),
                  body: SingleChildScrollView(
                    // SingleChildScrollView garante que a tela role quando o teclado aparecer,
                    // evitando que os campos de texto fiquem ocultos.
                    padding: const EdgeInsets.all(32.0),
                    // Adiciona preenchimento em toda a volta do conteúdo.
                    child: _buildContactForm(),
                  ),
                  bottomNavigationBar: const MyBottomNavBar(),
                ),
              ),
            ],
          );
        } else {
          // Versão para mobile/tablet com menu deslizante
          return Scaffold(
            appBar: MyAppBar(title: pageName),
            drawer: const MyDrawer(), // O menu deslizante
            body: SingleChildScrollView(
              padding: const EdgeInsets.all(32.0),
              child: _buildContactForm(),
            ),
            bottomNavigationBar: const MyBottomNavBar(),
          );
        }
      },
    );
  }

  // Método auxiliar para construir o formulário de contato,
  // reutilizável em ambas as versões (desktop e mobile).
  Widget _buildContactForm() {
    return Center(
      // Centraliza o formulário na tela
      child: SizedBox(
        width: 540, // Limita a largura máxima do formulário
        child: Form(
          key: _contactsFormKey, // Associa a chave global ao formulário.
          child: Column(
            // Estica os campos horizontalmente para preencher a largura disponível.
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              const Text(
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
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, escreva seu nome.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20.0), // Espaçamento entre os campos.
              // Campo E-mail.
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'E-mail',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.email),
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, escreva seu e-mail.';
                  }
                  if (!Config.emailRegex.hasMatch(value)) {
                    return 'Por favor, insira um email válido.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20.0),
              // Campo Assunto (subject).
              TextFormField(
                controller: _subjectController,
                decoration: const InputDecoration(
                  labelText: 'Assunto',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.subject),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, escreva o assunto.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20.0),
              // Campo Mensagem (message).
              TextFormField(
                controller: _messageController,
                decoration: const InputDecoration(
                  labelText: 'Mensagem',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.message),
                  alignLabelWithHint: true,
                ),
                maxLines: 5,
                keyboardType: TextInputType.multiline,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, escreva sua mensagem.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20.0),
              // Botão de Enviar.
              ElevatedButton.icon(
                onPressed: _submitContactForm,
                icon: const Icon(Icons.send),
                label: const Text('Enviar'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12.0),
                  textStyle: const TextStyle(fontSize: 18),
                  backgroundColor: Colors.blue[600],
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Método para lidar com o envio do formulário de contato.
  // É assíncrono porque realiza uma operação de rede (HTTP POST).
  void _submitContactForm() async {
    // 1. Validação do Formulário:
    if (_contactsFormKey.currentState!.validate()) {
      // 2. Coleta dos Dados:
      final name = _nameController.text;
      final email = _emailController.text;
      final subject = _subjectController.text;
      final message = _messageController.text;

      // 3. Formatação dos Dados para JSON:
      final Map<String, String> formData = {
        'name': name,
        'email': email,
        'subject': subject,
        'message': message,
      };

      // 5. Bloco de Envio e Tratamento de Erros:
      try {
        // 5.1. Realiza a Requisição POST com Dio:
        final Response response = await _dio.post(
          Config.endPoint['contact'],
          data: formData,
          options: Options(contentType: Headers.jsonContentType),
        );

        // 5.2. Verificação de 'mounted':
        if (!mounted) return;

        // 5.3. Processamento da Resposta da API:
        if (response.statusCode == 200 || response.statusCode == 201) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Mensagem enviada com sucesso!'),
              backgroundColor: Colors.green,
            ),
          );
          _nameController.clear();
          _emailController.clear();
          _subjectController.clear();
          _messageController.clear();
        } else {
          if (kDebugMode) {
            print('Erro ao enviar mensagem: ${response.statusCode}');
            print('Corpo da resposta: ${response.data}');
          }
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Falha ao enviar mensagem. Status: ${response.statusCode}',
              ),
              backgroundColor: Colors.red,
            ),
          );
        }
      } on DioException catch (e) {
        // 5.4. Tratamento de Erros Específicos do Dio:
        if (!mounted) return;
        if (e.response != null) {
          if (kDebugMode) {
            print('Erro de resposta do Dio: ${e.response!.statusCode}');
            print('Dados do erro: ${e.response!.data}');
          }
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Falha ao enviar. Erro do servidor: ${e.response!.statusCode}',
              ),
              backgroundColor: Colors.red,
            ),
          );
        } else {
          if (kDebugMode) {
            print('Erro de conexão ou configuração do Dio: $e');
          }
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Erro de conexão. Verifique sua rede e o servidor.',
              ),
              backgroundColor: Colors.red,
            ),
          );
        }
      } catch (e) {
        // 5.5. Tratamento de Outros Erros Inesperados:
        if (!mounted) return;
        if (kDebugMode) {
          print('Erro inesperado: $e');
        }
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Ocorreu um erro inesperado.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } else {
      // 6. Feedback de Validação Falha:
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, preencha todos os campos corretamente.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
