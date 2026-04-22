import 'package:flutter/material.dart';

enum VerificationStatus { verified, fakeNews, suspicious, pending }

extension VerificationStatusExtension on VerificationStatus {
  Color get color {
    switch (this) {
      case VerificationStatus.verified: return const Color(0xFF4CAF50);
      case VerificationStatus.fakeNews: return const Color(0xFFE53935);
      case VerificationStatus.suspicious: return const Color(0xFFFF9800);
      case VerificationStatus.pending: return const Color(0xFF9E9E9E);
    }
  }

  String get label {
    switch (this) {
      case VerificationStatus.verified: return 'Verificado';
      case VerificationStatus.fakeNews: return 'Fake News';
      case VerificationStatus.suspicious: return 'Suspeito';
      case VerificationStatus.pending: return 'Pendente';
    }
  }

  IconData get icon {
    switch (this) {
      case VerificationStatus.verified: return Icons.check_circle;
      case VerificationStatus.fakeNews: return Icons.cancel;
      case VerificationStatus.suspicious: return Icons.warning;
      case VerificationStatus.pending: return Icons.pending;
    }
  }
}

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
  bool isFavorite;

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
    this.isFavorite = false,
  });

  factory NewsItem.fromRssJson(Map<String, dynamic> json) {
    final confidenceScore = 85 + (DateTime.now().millisecond % 15); 
    
    // Extrator de imagens do G1
    String imgUrl = json['thumbnail']?.toString() ?? '';
    
    if (imgUrl.isEmpty && json['enclosure'] != null) {
      imgUrl = json['enclosure']['link']?.toString() ?? '';
    }
    
    if (imgUrl.isEmpty && json['description'] != null) {
      final match = RegExp(r'src="([^"]+)"').firstMatch(json['description'].toString());
      if (match != null) imgUrl = match.group(1) ?? '';
    }

    // Garante HTTPS para evitar bloqueios no Android
    if (imgUrl.startsWith('http://')) {
      imgUrl = imgUrl.replaceFirst('http://', 'https://');
    }

    // Imagem de fallback caso não encontre nenhuma
    if (imgUrl.isEmpty || imgUrl.length < 5) {
      imgUrl = 'https://images.unsplash.com/photo-1504711434969-e33886168f5c?w=800';
    }

    // Limpeza de Tags HTML para o texto aparecer limpo
    String rawDesc = json['description']?.toString() ?? 'Sem descrição disponível.';
    String cleanDesc = rawDesc.replaceAll(RegExp(r'<[^>]*>|&[^;]+;'), '').trim();
    
    // Fallback se a descrição limpa ficar vazia
    if (cleanDesc.isEmpty) cleanDesc = 'Clique para ler os detalhes completos desta notícia no portal.';

    DateTime pubDate = DateTime.now();
    if (json['pubDate'] != null) {
      try { 
        pubDate = DateTime.parse(json['pubDate'].toString().replaceAll(' ', 'T')); 
      } catch (_) {}
    }

    return NewsItem(
      id: json['guid']?.toString() ?? json['link']?.toString() ?? DateTime.now().toString(),
      title: json['title']?.toString() ?? 'Sem título',
      description: cleanDesc,
      imageUrl: imgUrl,
      source: 'Portal G1',
      category: 'Brasil', 
      publishedAt: pubDate, 
      status: VerificationStatus.verified, 
      confidence: confidenceScore,
      isFavorite: false,
    );
  }
}

class VerificationItem {
  final String id;
  final String content;
  final String type;
  final String source;
  final DateTime verifiedAt;
  final VerificationStatus status;
  final int confidence;
  final String? details;

  VerificationItem({
    required this.id, required this.content, required this.type, required this.source,
    required this.verifiedAt, required this.status, required this.confidence, this.details,
  });

  IconData get typeIcon {
    switch (type) {
      case 'link': return Icons.link;
      case 'text': return Icons.text_fields;
      case 'image': return Icons.image;
      case 'audio': return Icons.audiotrack;
      default: return Icons.article;
    }
  }
}

class UserStats {
  final int totalVerifications, verified, fakeNews, suspicious;
  UserStats({required this.totalVerifications, required this.verified, required this.fakeNews, required this.suspicious});
}

class Achievement {
  final String id, title, description;
  final IconData icon;
  final bool unlocked;
  final int progress, total;
  Achievement({required this.id, required this.title, required this.description, required this.icon, required this.unlocked, required this.progress, required this.total});
}

class UserProfile {
  final String id, name, email, badge;
  final String? avatarUrl;
  final DateTime memberSince;
  final UserStats stats;
  final List<Achievement> achievements;
  UserProfile({required this.id, required this.name, required this.email, this.avatarUrl, required this.badge, required this.memberSince, required this.stats, required this.achievements});
}

class CurrencyRate {
  final String name;
  final String code;
  final double buyValue;
  final double variation;

  CurrencyRate({
    required this.name,
    required this.code,
    required this.buyValue,
    required this.variation,
  });

  factory CurrencyRate.fromJson(Map<String, dynamic> json) {
    return CurrencyRate(
      name: json['name']?.toString().split('/').first ?? 'Desconhecido',
      code: json['code'] ?? '',
      buyValue: double.tryParse(json['ask'] ?? '0') ?? 0.0,
      variation: double.tryParse(json['pctChange'] ?? '0') ?? 0.0,
    );
  }
}