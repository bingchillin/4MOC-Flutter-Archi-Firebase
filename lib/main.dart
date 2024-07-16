import 'package:flutter/material.dart';
import 'package:projet_flutter_firebase/pages/log_in_screen.dart';
import 'package:projet_flutter_firebase/pages/sign_up_screen.dart';
import 'package:projet_flutter_firebase/profil_screen/profil_screen.dart';
import 'package:projet_flutter_firebase/widgets/custom_elevated_button.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Whazzap!',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
          useMaterial3: true,
        ),
        home: const MyHomePage(),
        routes: {
          LogInScreen.routeName: (context) => const LogInScreen(),
          SignUpScreen.routeName: (context) => const SignUpScreen(),
          ProfilScreen.routeName: (context) => const ProfilScreen(),
        });
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'Whazzap!',
              style: TextStyle(fontSize: 24),
            ),
            const SizedBox(height: 32),

            CustomElevatedButton(
                text: "Connexion",
                color: Colors.lightGreen,
                onTap: () =>
                    Navigator.of(context).pushNamed(LogInScreen.routeName)),
            const SizedBox(height: 16),

            CustomElevatedButton(
              text: "Inscription",
              color: Colors.green,
              onTap: () =>
                  Navigator.of(context).pushNamed(SignUpScreen.routeName),
            ),
            const SizedBox(height: 16),

            CustomElevatedButton(
              text: "Profil",
              color: Colors.green,
              onTap: () =>
                  Navigator.of(context).pushNamed(ProfilScreen.routeName),
            ),
          ],
        ),
      ),
    );
  }
}
