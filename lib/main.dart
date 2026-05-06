import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';

// Widgets e Services
import 'widgets/header_widget.dart';
import 'services/db_helper.dart'; 
import 'services/user_service.dart'; 

// Screens (Removi os imports que não estavam sendo usados no código fornecido)
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
import 'screens/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // CORREÇÃO TÉCNICA: O Firebase DEVE ser esperado (await) antes do runApp
  // para evitar erros de inicialização em telas que dependem de Auth.
  try {
    await Firebase.initializeApp();
  } catch (e) {
    debugPrint("Erro ao iniciar Firebase: $e");
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
          surface: const Color(0xFF1A1A1A),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.black,
          elevation: 0,
        ),
      ),
      // Inicia na SplashScreen
      home: const SplashScreen(), 
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

// AuthWrapper: Decide se vai para Login ou Home
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
          return const MainNavigation(); 
        }
        return const LoginScreen(); 
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
  int _currentIndex = 2; 

  final List<Widget> _screens = const [
    VerifyScreen(),
    HistoryScreen(),
    HomeScreen(),
    NewsScreen(),
    ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _syncUser(); 
  }

  Future<void> _syncUser() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null && user.email != null) {
      final db = DBHelper();
      var profile = await db.getProfile(user.email!);

      if (profile == null) {
        await db.createInitialProfile(user.email!, '');
        profile = await db.getProfile(user.email!);
      }

      if (profile != null) {
        UserService().setUser(user.email!, profile['name'] ?? '');
      }
    }
  }

  String _getAppTitle(int index) {
    const titles = [
      'Análise ETHOS',
      'Seu Histórico',
      'ETHOS',
      'Notícias Seguras',
      'Seu Perfil'
    ];
    return titles[index];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
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