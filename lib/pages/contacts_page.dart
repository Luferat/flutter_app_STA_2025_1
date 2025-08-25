import 'package:Flutter_app/template/myappbar.dart';
import 'package:Flutter_app/template/mydrawer.dart';
import 'package:Flutter_app/template/myfooter.dart';
import 'package:flutter/material.dart';

import '../template/config.dart';

final pageName = Config.appName;

class ContactsPage extends StatelessWidget {

  // Construtor
  const ContactsPage({super.key});

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: MyAppBar(title: 'Faça Contato'),

      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          // Widgets de Column
          children: [
            const Text('Esta é uma Página Stateless!'),
            const SizedBox(height: 20),
            const Text('Essa é a página de contatos'),
          ],
        ),
      ),

      drawer: MyDrawer(),

      bottomNavigationBar: MyBottomNavBar(),

    );

  }

}