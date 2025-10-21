import 'package:flutter/material.dart';

class UserDashboard extends StatelessWidget {
  static const String routeName = '/user-dashboard';
  const UserDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Dashboard Profesional')),
      body:
          Center(child: Text('User Dashboard', style: TextStyle(fontSize: 18))),
    );
  }
}
