import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:firebase_core/firebase_core.dart'; // Importação do Firebase

import 'widgets/header_widget.dart'; 
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

void main() async { 
  
  WidgetsFlutterBinding.ensureInitialized();
  
  
  await Firebase.initializeApp();


  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );
  
  
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
      initialRoute: '/',
      routes: {
        '/': (context) => const MainNavigation(),
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

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 2; // Começa na Casinha (Meio)

  // As telas "puras" (lembre-se de tirar o SafeArea/Scaffold de dentro delas)
  final List<Widget> _screens = [
    const VerifyScreen(),  // 0
    const HistoryScreen(), // 1
    const HomeScreen(),    // 2
    const NewsScreen(),    // 3
    const ProfileScreen(), // 4
  ];

  // Retorna o título correto baseado na aba selecionada
  String _getAppTitle(int index) {
    switch (index) {
      case 0: return 'Análise ETHOS';
      case 1: return 'Seu Histórico';
      case 2: return 'ETHOS'; // Casinha
      case 3: return 'Notícias Seguras';
      case 4: return 'Seu Perfil';
      default: return 'ETHOS';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, 
      // 1. O CORPO AGORA CONTROLA O CABEÇALHO GLOBALMENTE
      body: SafeArea(
        child: Column(
          children: [
            // O Cabeçalho Padrão, que muda o título dinamicamente
            Padding(
              padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 16.0),
              child: HeaderWidget(
                title: _getAppTitle(_currentIndex),
                showBackButton: false, // Sem botão de voltar nas abas principais
              ),
            ),
            
            // O conteúdo da tela selecionada preenche o resto do espaço
            Expanded(
              child: _screens[_currentIndex],
            ),
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
          Icon(Icons.shield, color: Colors.white, size: 26),      // 0: Verificar
          Icon(Icons.history, color: Colors.white, size: 26),     // 1: Histórico
          Icon(Icons.home, color: Colors.white, size: 26),        // 2: Casinha
          Icon(Icons.article, color: Colors.white, size: 26),     // 3: Notícias
          Icon(Icons.person, color: Colors.white, size: 26),      // 4: Perfil
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