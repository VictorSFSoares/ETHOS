import 'package:flutter/material.dart';
import '../models/data_models.dart';

class UserService {
  static final UserService _instance = UserService._internal();
  factory UserService() => _instance;
  UserService._internal();

  // Guarda o utilizador que está logado atualmente
  String? currentUserEmail;
  String? currentUserName;

  void setUser(String email, String name) {
    currentUserEmail = email;
    currentUserName = name;
  }

  void clearUser() {
    currentUserEmail = null;
    currentUserName = null;
  }

  // As tuas conquistas originais mantidas aqui
  List<Achievement> generateAchievements(UserStats stats) {
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
        id: 'verified_25',
        title: 'Verificador Prata',
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
        progress:
            stats.totalVerifications > 100 ? 100 : stats.totalVerifications,
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

  String getBadge(int totalVerifications) {
    if (totalVerifications >= 100) return 'Verificador Diamante';
    if (totalVerifications >= 50) return 'Verificador Ouro';
    if (totalVerifications >= 25) return 'Verificador Prata';
    return 'Verificador Bronze';
  }
}
