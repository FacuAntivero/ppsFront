import 'package:flutter/material.dart';
import 'package:flutter_application/constants/size_config.dart';

class UserLoginScreen extends StatefulWidget {
  const UserLoginScreen({
    super.key,
  });

  @override
  State<UserLoginScreen> createState() => _UserLoginScreenState();
}

class _UserLoginScreenState extends State<UserLoginScreen> {
  List<bool> isSelected = [true, false];
  bool rememberName = false;
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(
              xs(),
            ),
            child: Column(
              children: [
                ToggleButtons(
                  isSelected: isSelected,
                  onPressed: (index) {},
                  borderRadius: BorderRadius.circular(8),
                  selectedBorderColor: Colors.teal,
                  selectedColor: Colors.teal,
                  fillColor: Colors.teal.shade100,
                  color: Colors.teal.shade600,
                  children: [
                    Padding(
                      padding: EdgeInsets.symmetric(
                        vertical: SizeConfig.screenWidth * 0.01,
                        horizontal: SizeConfig.screenWidth * 0.025,
                      ),
                      child: const Text('Usuario'),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(
                        vertical: SizeConfig.screenWidth * 0.01,
                        horizontal: SizeConfig.screenWidth * 0.025,
                      ),
                      child: const Text('Profesional'),
                    ),
                  ],
                ),
                SizedBox(height: SizeConfig.screenHeight * 0.05),
                LayoutBuilder(
                  builder: (context, constraints) {
                    if (constraints.maxWidth > 400) {
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            flex: 2,
                            child: Image.asset(
                              'assets/images/LogoCircular.png',
                              fit: BoxFit.cover,
                            ),
                          ),
                          SizedBox(width: SizeConfig.screenWidth * 0.05),
                          Expanded(
                            flex: 3,
                            child: buildLoginForm(context),
                          ),
                        ],
                      );
                    } else {
                      return Column(
                        children: [
                          Center(
                            child: SizedBox(
                              height: SizeConfig.screenWidth * 0.4,
                              width: SizeConfig.screenWidth * 0.4,
                              child: Image.asset(
                                'assets/images/LogoCircular.png',
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          SizedBox(height: SizeConfig.screenHeight * 0.05),
                          SizedBox(
                            child: TextFormField(
                              textAlignVertical: TextAlignVertical.center,
                              autocorrect: false,
                              cursorColor: Colors.teal,
                              decoration: InputDecoration(
                                enabledBorder: const OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: Colors.black,
                                  ),
                                ),
                                focusedBorder: const OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: Colors.teal,
                                  ),
                                ),
                                labelText: 'Usuario (Residencia)',
                                labelStyle: TextStyle(
                                  color: Colors.black,
                                  fontSize: SizeConfig.screenWidth * 0.015,
                                ),
                                hintText: 'Email',
                                hintStyle: TextStyle(
                                  fontSize: SizeConfig.screenWidth * 0.02,
                                  color: Colors.grey.shade600,
                                  fontWeight: FontWeight.normal,
                                ),
                                contentPadding: const EdgeInsets.all(0),
                                floatingLabelBehavior:
                                    FloatingLabelBehavior.always,
                                prefixIcon: const Icon(
                                  Icons.person,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: SizeConfig.screenHeight * 0.03),
                          SizedBox(
                            child: TextFormField(
                              obscureText: true,
                              textAlignVertical: TextAlignVertical.center,
                              autocorrect: false,
                              cursorColor: Colors.teal,
                              decoration: InputDecoration(
                                enabledBorder: const OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: Colors.black,
                                  ),
                                ),
                                focusedBorder: const OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.teal),
                                ),
                                labelText: 'Contraseña',
                                labelStyle: TextStyle(
                                  color: Colors.black,
                                  fontSize: SizeConfig.screenWidth * 0.015,
                                ),
                                hintText: 'Contraseña',
                                hintStyle: TextStyle(
                                  fontSize: SizeConfig.screenWidth * 0.02,
                                  color: Colors.grey.shade600,
                                  fontWeight: FontWeight.normal,
                                ),
                                contentPadding: const EdgeInsets.all(0),
                                floatingLabelBehavior:
                                    FloatingLabelBehavior.always,
                                prefixIcon: const Icon(
                                  Icons.lock,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: SizeConfig.screenHeight * 0.025),
                          Row(
                            children: [
                              Checkbox(
                                value: rememberName,
                                onChanged: (value) {
                                  setState(() {
                                    rememberName = value ?? false;
                                  });
                                },
                              ),
                              const Text('Recordar nombre'),
                            ],
                          ),
                          SizedBox(height: SizeConfig.screenHeight * 0.025),
                          TextButton(
                            onPressed: () {},
                            child: const Text(
                              '¿Olvidaste tu contraseña?',
                              style: TextStyle(
                                color: Colors.blue,
                              ),
                            ),
                          ),
                          SizedBox(height: SizeConfig.screenHeight * 0.025),
                          SizedBox(
                            width: SizeConfig.screenWidth * 0.4,
                            child: ElevatedButton(
                              onPressed: () {},
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.teal,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(5),
                                ),
                              ),
                              child: const Text(
                                'Ingresar',
                                style: TextStyle(
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: SizeConfig.screenHeight * 0.05),
                          RichText(
                            text: TextSpan(
                              style: TextStyle(
                                color: Colors.grey.shade600,
                              ),
                              children: const [
                                TextSpan(
                                  text: '¿No tenes una cuenta? ',
                                ),
                                TextSpan(
                                  text: 'Registrate',
                                  style: TextStyle(
                                    color: Colors.blue,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      );
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildLoginForm(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: SizeConfig.screenWidth * 0.4,
          child: TextFormField(
            textAlignVertical: TextAlignVertical.center,
            autocorrect: false,
            cursorColor: Colors.teal,
            decoration: InputDecoration(
              enabledBorder: const OutlineInputBorder(
                borderSide: BorderSide(
                  color: Colors.black,
                ),
              ),
              focusedBorder: const OutlineInputBorder(
                borderSide: BorderSide(color: Colors.teal),
              ),
              labelText: 'Usuario (Residencia)',
              labelStyle: TextStyle(
                color: Colors.black,
                fontSize: SizeConfig.screenWidth * 0.015,
              ),
              hintText: 'Email',
              hintStyle: TextStyle(
                fontSize: SizeConfig.screenWidth * 0.02,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.normal,
              ),
              contentPadding: const EdgeInsets.all(0),
              floatingLabelBehavior: FloatingLabelBehavior.always,
              prefixIcon: const Icon(
                Icons.person,
              ),
            ),
          ),
        ),
        SizedBox(height: SizeConfig.screenHeight * 0.03),
        SizedBox(
          width: SizeConfig.screenWidth * 0.4,
          child: TextFormField(
            obscureText: true,
            textAlignVertical: TextAlignVertical.center,
            autocorrect: false,
            cursorColor: Colors.teal,
            decoration: InputDecoration(
              enabledBorder: const OutlineInputBorder(
                borderSide: BorderSide(
                  color: Colors.black,
                ),
              ),
              focusedBorder: const OutlineInputBorder(
                borderSide: BorderSide(
                  color: Colors.teal,
                ),
              ),
              labelText: 'Contraseña',
              labelStyle: TextStyle(
                color: Colors.black,
                fontSize: SizeConfig.screenWidth * 0.015,
              ),
              hintText: 'Contraseña',
              hintStyle: TextStyle(
                fontSize: SizeConfig.screenWidth * 0.02,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.normal,
              ),
              contentPadding: const EdgeInsets.all(0),
              floatingLabelBehavior: FloatingLabelBehavior.always,
              prefixIcon: const Icon(
                Icons.lock,
              ),
            ),
          ),
        ),
        SizedBox(height: SizeConfig.screenHeight * 0.025),
        Row(
          children: [
            Checkbox(
              value: rememberName,
              onChanged: (value) {
                setState(() {
                  rememberName = value ?? false;
                });
              },
            ),
            const Text('Recordar nombre'),
          ],
        ),
        SizedBox(height: SizeConfig.screenHeight * 0.025),
        TextButton(
          onPressed: () {},
          child: const Text(
            '¿Olvidaste tu contraseña?',
            style: TextStyle(
              color: Colors.blue,
            ),
          ),
        ),
        SizedBox(height: SizeConfig.screenHeight * 0.025),
        SizedBox(
          width: SizeConfig.screenWidth * 0.4,
          child: ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.teal,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(5),
              ),
            ),
            child: const Text(
              'Ingresar',
              style: TextStyle(
                color: Colors.white,
              ),
            ),
          ),
        ),
        SizedBox(height: SizeConfig.screenHeight * 0.05),
        RichText(
          text: TextSpan(
            style: TextStyle(
              color: Colors.grey.shade600,
            ),
            children: const [
              TextSpan(
                text: '¿No tenes una cuenta? ',
              ),
              TextSpan(
                text: 'Registrate',
                style: TextStyle(
                  color: Colors.blue,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
