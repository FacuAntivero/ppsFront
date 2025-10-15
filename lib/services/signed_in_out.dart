// import 'package:app_fotografia/components/loading_home_screen.dart';
// import 'package:app_fotografia/screens/extras/error_screen.dart';
// import 'package:app_fotografia/services/firebase_service.dart';
// import 'package:app_fotografia/services/photographer_current_screen.dart';
// import 'package:app_fotografia/services/user_current_screen.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import '../screens/auth/sign_in/sign_in_screen.dart';

// class SignedInOut extends StatelessWidget {
//   static String routeName = "/SignedInOut";

//   const SignedInOut({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: StreamBuilder<User?>(
//         stream: FirebaseAuth.instance.authStateChanges(),
//         builder: (context, snapshot) {
//           if (snapshot.hasData) {
//             return FutureBuilder<bool>(
//               future: isPhotographer(),
//               builder: (BuildContext context,
//                   AsyncSnapshot<bool> isPhotographerSnapshot) {
//                 if (isPhotographerSnapshot.connectionState ==
//                     ConnectionState.waiting) {
//                   return loadingHomeScreen(context);
//                 } else if (isPhotographerSnapshot.hasError) {
//                   return const ErrorScreen();
//                 } else {
//                   if (isPhotographerSnapshot.data == true) {
//                     return const PhotographerCurrentScreen(
//                       initialIndex: 0,
//                     );
//                   } else {
//                     return const UserCurrentScreen(initialIndex: 0);
//                   }
//                 }
//               },
//             );
//           } else {
//             return const SignInScreen();
//           }
//         },
//       ),
//     );
//   }
// }
