import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'widgets/header_widget.dart';
import 'services/db_helper.dart'; // Adicionado
import 'services/user_service.dart'; // Adicionado

import 'screens/home_screen.dart';
import 'screens/history_screen.dart';
import 'screens/news_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/verify_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/notifications_screen.dart';
import 'screens/privacy_screen.dart';
import 'screens/help_screen.dart';
import 'screens/about_screen.dart';
import 'screens/favorites_screen.dart';
import 'screens/login_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp();
  } catch (e) {
    debugPrint("Erro Firebase: $e");
  }
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  runApp(const EthosApp());
}

class EthosApp extends StatelessWidget {
  const EthosApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'ETHOS - Portal de Verificação',
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: Colors.black,
        primaryColor: const Color(0xFF4CAF50),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF4CAF50),
          secondary: Color(0xFF4CAF50),
          surface: Color(0xFF1A1A1A),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.black,
          elevation: 0,
        ),
      ),
      // AuthWrapper verifica se o utilizador está logado no Firebase
      home: const AuthWrapper(),
      routes: {
        '/settings': (context) => const SettingsScreen(),
        '/notifications': (context) => const NotificationsScreen(),
        '/privacy': (context) => const PrivacyScreen(),
        '/help': (context) => const HelpScreen(),
        '/about': (context) => const AboutScreen(),
        '/favorites': (context) => const FavoritesScreen(),
      },
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
                child: CircularProgressIndicator(color: Color(0xFF4CAF50))),
          );
        }
        if (snapshot.hasData) {
          return const MainNavigation(); // Se logado, vai para a navegação principal
        }
        return const LoginScreen(); // Se não logado, vai para o Login
      },
    );
  }
}

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 2; // Começa na Casinha (Home)

  final List<Widget> _screens = [
    const VerifyScreen(),
    const HistoryScreen(),
    const HomeScreen(),
    const NewsScreen(),
    const ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _syncUser(); // Garante que carrega os dados mal a App abre!
  }

  Future<void> _syncUser() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null && user.email != null) {
      var profile = await DBHelper().getProfile(user.email!);

      if (profile == null) {
        // Trocamos 'Usuário ETHOS' por '' (vazio)
        await DBHelper().createInitialProfile(user.email!, '');
        profile = await DBHelper().getProfile(user.email!);
      }

      if (profile != null) {
        // Trocamos 'Usuário ETHOS' por '' (vazio)
        UserService().setUser(user.email!, profile['name'] ?? '');
      }
    }
  }

  String _getAppTitle(int index) {
    switch (index) {
      case 0:
        return 'Análise ETHOS';
      case 1:
        return 'Seu Histórico';
      case 2:
        return 'ETHOS';
      case 3:
        return 'Notícias Seguras';
      case 4:
        return 'Seu Perfil';
      default:
        return 'ETHOS';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding:
                  const EdgeInsets.only(left: 16.0, right: 16.0, top: 16.0),
              child: HeaderWidget(
                title: _getAppTitle(_currentIndex),
                showBackButton: false,
              ),
            ),
            Expanded(child: _screens[_currentIndex]),
          ],
        ),
      ),
      bottomNavigationBar: CurvedNavigationBar(
        index: _currentIndex,
        backgroundColor: Colors.transparent,
        color: const Color(0xFF1A1A1A),
        buttonBackgroundColor: const Color(0xFF4CAF50),
        animationDuration: const Duration(milliseconds: 300),
        items: const [
          Icon(Icons.shield, color: Colors.white, size: 26),
          Icon(Icons.history, color: Colors.white, size: 26),
          Icon(Icons.home, color: Colors.white, size: 26),
          Icon(Icons.article, color: Colors.white, size: 26),
          Icon(Icons.person, color: Colors.white, size: 26),
        ],
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }
}
