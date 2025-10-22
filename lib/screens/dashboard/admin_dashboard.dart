import 'package:flutter/material.dart';

class AdminDashboard extends StatelessWidget {
  static const String routeName = '/admin-dashboard';
  const AdminDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Admin Dashboard')),
      body: const Center(
        child:
            Text('Bienvenido, administrador', style: TextStyle(fontSize: 18)),
      ),
    );
  }
}
