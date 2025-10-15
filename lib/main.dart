import 'package:flutter/material.dart';
import 'package:flutter_application/constants/size_config.dart';
import 'package:flutter_application/screens/auth/login/user/user_login_screen.dart';
import 'package:flutter_application/services/route_generator.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return MaterialApp(
      title: 'Tranquiliza 360',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.teal,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF4DB6AC),
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(
              color: Color(0xFF00897B),
            ),
          ),
          contentPadding: EdgeInsets.symmetric(
            vertical: SizeConfig.screenWidth * 0.04,
            horizontal: SizeConfig.screenWidth * 0.05,
          ),
        ),
        fontFamily: 'Roboto',
      ),
      home: const UserLoginScreen(),
      onGenerateRoute: RouteGenerator.generateRoute,
    );
  }
}
