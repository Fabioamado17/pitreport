import 'package:flutter/material.dart';

class ReportListScreen extends StatelessWidget {
  const ReportListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('As minhas Denúncias')),
      body: const Center(
        child: Text('Lista de denúncias\n(em breve)', textAlign: TextAlign.center),
      ),
    );
  }
}
