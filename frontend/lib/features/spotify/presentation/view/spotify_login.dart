// import 'dart:convert';
// import 'package:clean_spotify_connec/core/common/my_snackbar.dart';

// import 'package:clean_spotify_connec/features/spotify/presentation/viewmodel/spotify_view_model.dart';
// import 'package:dio/dio.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:shared_preferences/shared_preferences.dart';

// class LoginView extends ConsumerStatefulWidget {
//   const LoginView({super.key});

//   @override
//   ConsumerState<LoginView> createState() => _LoginViewState();
// }

// class _LoginViewState extends ConsumerState<LoginView> {
//   final _gap = const SizedBox(height: 8);
//   bool isObscure = true;

//   String? accessToken;
//   DateTime? expDate;

//   @override
//   void initState() {
//     getAccessToken();
//     super.initState();
//   }

//   Dio dio = Dio();

//   Future<String> getAccessToken() async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     accessToken = prefs.getString('acess_token');
//     String? exp = prefs.getString('expiry_date');
//     expDate = DateTime.parse(exp!);  
//     return accessToken!;
//   }

//   @override
//   Widget build(BuildContext context) {
//     final authState = ref.watch(spotifyViewModelProvider);
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       if (authState.showMessage && authState.error != null) {
//         showSnackBar(message: 'Invalid Credentials', context: context);
//         ref.read(spotifyViewModelProvider.notifier).resetState();
//       }
//     });
//     return Scaffold(
//       body: SafeArea(
//         child: Center(
//           child: Padding(
//             padding: const EdgeInsets.all(8),
//             child: Column(
//               children: [
//                 _gap,
//                 ElevatedButton(
//                   onPressed: () async {
//                     // Navigator.pushNamed(context, AppRoute.homeRoute);
//                     await ref.read(spotifyViewModelProvider.notifier).login();
//                   },
//                   child: const SizedBox(
//                     height: 50,
//                     child: Center(
//                       child: Text(
//                         'Login',
//                         style: TextStyle(
//                           fontSize: 18,
//                           fontFamily: 'Brand Bold',
//                         ),
//                       ),
//                     ),
//                   ),
//                 ),
//                 ElevatedButton(
//                   onPressed: () async {
//                     // Navigator.pushNamed(context, AppRoute.homeRoute);

//                     SharedPreferences prefs =
//                         await SharedPreferences.getInstance();
//                     final String? token = prefs.getString('acess_token');
//                     print("your access token $token");
//                   },
//                   child: const SizedBox(
//                     height: 50,
//                     child: Center(
//                       child: Text(
//                         'Get Access token',
//                         style: TextStyle(
//                           fontSize: 18,
//                           fontFamily: 'Brand Bold',
//                         ),
//                       ),
//                     ),
//                   ),
//                 ),
//                 ElevatedButton(
//                   onPressed: () async {
//                      await ref.read(spotifyViewModelProvider.notifier).sendPrompt();  
//                   },
//                   child: const SizedBox(
//                     height: 50,
//                     child: Center(
//                       child: Text(
//                         'Create playlist',
//                         style: TextStyle(
//                           fontSize: 18,
//                           fontFamily: 'Brand Bold',
//                         ),
//                       ),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
