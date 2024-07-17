import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:projet_flutter_firebase/pages/add_group_message_screen.dart';
import 'package:projet_flutter_firebase/pages/log_in_screen.dart';
import 'package:projet_flutter_firebase/pages/my_message_detail_screeen.dart';
import 'package:projet_flutter_firebase/pages/my_message_screen.dart';
import 'package:projet_flutter_firebase/pages/sign_up_screen.dart';
import 'package:projet_flutter_firebase/profil_screen/profil_screen.dart';
import 'package:projet_flutter_firebase/pages/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Whazzap!',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true,
      ),
      initialRoute: LogInScreen.routeName,
      routes: {
        LogInScreen.routeName: (context) => const LogInScreen(),
        SignUpScreen.routeName: (context) => const SignUpScreen(),
        ProfilScreen.routeName: (context) => const ProfilScreen(),
        HomeScreen.routeName: (context) => const HomeScreen(),
        AddGroupMessageScreen.routeName: (context) => const AddGroupMessageScreen(),
        MyMessageDetailScreen.routeName: (context) => MyMessageDetailScreen(),
      },
      onGenerateRoute: (settings) {
        if (settings.name == MyMessageScreen.routeName) {
          final args = settings.arguments as Map<String, dynamic>;
          return MaterialPageRoute(
            builder: (context) => MyMessageScreen(
              groupId: args['groupId'],
              groupName: args['groupName'],
              groupDescription: args['groupDescription'],
            ),
          );
        }
        return null;
      },
    );
  }
}
