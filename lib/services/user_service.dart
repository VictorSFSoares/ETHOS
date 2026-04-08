import 'package:flutter/material.dart';
import '../models/data_models.dart';
import 'verification_service.dart';

/// Serviço de Usuário - Gerencia perfil e conquistas
class UserService {
  // Singleton
  static final UserService _instance = UserService._internal();
  factory UserService() => _instance;
  UserService._internal();

  final VerificationService _verificationService = VerificationService();

  // Perfil do usuário simulado
  Future<UserProfile> getUserProfile() async {
    await Future.delayed(const Duration(milliseconds: 300));
    
    final stats = await _verificationService.getUserStats();
    final achievements = _generateAchievements(stats);

    return UserProfile(
      id: 'user_001',
      name: 'Joelson Balduíno',
      email: 'joel_beto@gmail.com',
      badge: 'Verificador Bronze',
      memberSince: DateTime(2026, 1, 15),
      stats: stats,
      achievements: achievements,
    );
  }

  List<Achievement> _generateAchievements(UserStats stats) {
    return [
      Achievement(
        id: 'first_check',
        title: 'Primeira Verificação',
        description: 'Realize sua primeira verificação',
        icon: Icons.verified,
        unlocked: stats.totalVerifications >= 1,
        progress: stats.totalVerifications >= 1 ? 1 : 0,
        total: 1,
      ),
      Achievement(
        id: 'fake_hunter_10',
        title: 'Caçador de Fakes',
        description: 'Identifique 10 fake news',
        icon: Icons.search,
        unlocked: stats.fakeNews >= 10,
        progress: stats.fakeNews > 10 ? 10 : stats.fakeNews,
        total: 10,
      ),
      Achievement(
        id: 'verifier_50',
        title: 'Verificador Ativo',
        description: 'Realize 50 verificações',
        icon: Icons.task_alt,
        unlocked: stats.totalVerifications >= 50,
        progress: stats.totalVerifications > 50 ? 50 : stats.totalVerifications,
        total: 50,
      ),
      Achievement(
        id: 'truth_seeker',
        title: 'Buscador da Verdade',
        description: 'Confirme 25 notícias verdadeiras',
        icon: Icons.fact_check,
        unlocked: stats.verified >= 25,
        progress: stats.verified > 25 ? 25 : stats.verified,
        total: 25,
      ),
      Achievement(
        id: 'master_100',
        title: 'Mestre Verificador',
        description: 'Realize 100 verificações',
        icon: Icons.military_tech,
        unlocked: stats.totalVerifications >= 100,
        progress: stats.totalVerifications > 100 ? 100 : stats.totalVerifications,
        total: 100,
      ),
      Achievement(
        id: 'vigilante',
        title: 'Vigilante Digital',
        description: 'Identifique 5 conteúdos suspeitos',
        icon: Icons.shield,
        unlocked: stats.suspicious >= 5,
        progress: stats.suspicious > 5 ? 5 : stats.suspicious,
        total: 5,
      ),
    ];
  }

  // Obter badge baseado no nível
  String getBadge(int totalVerifications) {
    if (totalVerifications >= 100) return 'Verificador Diamante';
    if (totalVerifications >= 50) return 'Verificador Ouro';
    if (totalVerifications >= 25) return 'Verificador Prata';
    return 'Verificador Bronze';
  }

  Color getBadgeColor(String badge) {
    switch (badge) {
      case 'Verificador Diamante':
        return Colors.cyan;
      case 'Verificador Ouro':
        return Colors.amber;
      case 'Verificador Prata':
        return Colors.grey;
      default:
        return Colors.brown;
    }
  }
}
