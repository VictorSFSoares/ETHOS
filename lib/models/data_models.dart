import 'package:flutter/material.dart';

// Enum para status de verificação
enum VerificationStatus {
  verified,
  fakeNews,
  suspicious,
  pending,
}

// Extensão para obter propriedades do status
extension VerificationStatusExtension on VerificationStatus {
  Color get color {
    switch (this) {
      case VerificationStatus.verified:
        return const Color(0xFF4CAF50);
      case VerificationStatus.fakeNews:
        return const Color(0xFFE53935);
      case VerificationStatus.suspicious:
        return const Color(0xFFFF9800);
      case VerificationStatus.pending:
        return const Color(0xFF9E9E9E);
    }
  }

  String get label {
    switch (this) {
      case VerificationStatus.verified:
        return 'Verificado';
      case VerificationStatus.fakeNews:
        return 'Fake News';
      case VerificationStatus.suspicious:
        return 'Suspeito';
      case VerificationStatus.pending:
        return 'Pendente';
    }
  }

  IconData get icon {
    switch (this) {
      case VerificationStatus.verified:
        return Icons.check_circle;
      case VerificationStatus.fakeNews:
        return Icons.cancel;
      case VerificationStatus.suspicious:
        return Icons.warning;
      case VerificationStatus.pending:
        return Icons.pending;
    }
  }
}

// Modelo de Notícia
class NewsItem {
  final String id;
  final String title;
  final String description;
  final String imageUrl;
  final String source;
  final String category;
  final DateTime publishedAt;
  final VerificationStatus status;
  final int confidence;
  final String? author;

  NewsItem({
    required this.id,
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.source,
    required this.category,
    required this.publishedAt,
    required this.status,
    required this.confidence,
    this.author,
  });
}

// Modelo de Verificação no Histórico
class VerificationItem {
  final String id;
  final String content;
  final String type; // 'link', 'text', 'image', 'audio'
  final String source; // WhatsApp, Facebook, Instagram, Email, etc.
  final DateTime verifiedAt;
  final VerificationStatus status;
  final int confidence;
  final String? details;

  VerificationItem({
    required this.id,
    required this.content,
    required this.type,
    required this.source,
    required this.verifiedAt,
    required this.status,
    required this.confidence,
    this.details,
  });

  IconData get typeIcon {
    switch (type) {
      case 'link':
        return Icons.link;
      case 'text':
        return Icons.text_fields;
      case 'image':
        return Icons.image;
      case 'audio':
        return Icons.audiotrack;
      default:
        return Icons.article;
    }
  }
}

// Modelo de Estatísticas do Usuário
class UserStats {
  final int totalVerifications;
  final int verified;
  final int fakeNews;
  final int suspicious;

  UserStats({
    required this.totalVerifications,
    required this.verified,
    required this.fakeNews,
    required this.suspicious,
  });
}

// Modelo de Conquista
class Achievement {
  final String id;
  final String title;
  final String description;
  final IconData icon;
  final bool unlocked;
  final int progress;
  final int total;

  Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.unlocked,
    required this.progress,
    required this.total,
  });
}

// Modelo de Usuário
class UserProfile {
  final String id;
  final String name;
  final String email;
  final String? avatarUrl;
  final String badge;
  final DateTime memberSince;
  final UserStats stats;
  final List<Achievement> achievements;

  UserProfile({
    required this.id,
    required this.name,
    required this.email,
    this.avatarUrl,
    required this.badge,
    required this.memberSince,
    required this.stats,
    required this.achievements,
  });
}
