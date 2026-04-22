import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/data_models.dart';

class NewsService {
  static final NewsService _instance = NewsService._internal();
  factory NewsService() => _instance;
  NewsService._internal();

  final String _apiUrl = 'https://api.rss2json.com/v1/api.json?rss_url=https://g1.globo.com/rss/g1/';
  List<NewsItem> _cachedNews = [];
  final List<NewsItem> _historyCache = [];
  // NOVO: Lista para armazenar os favoritos em memória
  final List<NewsItem> _favoritesCache = [];

  Future<List<NewsItem>> getAllNews() async {
    if (_cachedNews.isNotEmpty) return _cachedNews;
    try {
      final response = await http.get(Uri.parse(_apiUrl)).timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List items = data['items'];
        
        _cachedNews = items.map((json) {
          return NewsItem(
            id: json['guid'] ?? DateTime.now().toString(),
            title: json['title'] ?? '',
            description: _cleanHtml(json['description'] ?? 'Sem descrição disponível.'),
            imageUrl: json['enclosure']?['link'] ?? 'https://via.placeholder.com/400',
            source: 'G1 Globo',
            category: 'Geral',
            publishedAt: DateTime.parse(json['pubDate']),
            status: VerificationStatus.verified,
            confidence: 100,
          );
        }).toList();
        return _cachedNews;
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  void addToHistory(NewsItem news) {
    _historyCache.removeWhere((item) => item.id == news.id);
    _historyCache.insert(0, news);
  }

  Future<List<NewsItem>> getHistoryNews() async {
    return _historyCache;
  }

  // NOVO: Método para buscar a lista de favoritos (Resolve erro no favorites_screen.dart)
  Future<List<NewsItem>> getFavoriteNews() async {
    return _favoritesCache;
  }

  // NOVO: Método para alternar favorito (Resolve erro no favorites_screen e historycheck_screen)
  Future<void> toggleFavorite(String id) async {
    // Busca a notícia em qualquer uma das listas para garantir que temos o objeto
    NewsItem? news;
    
    try {
      news = _cachedNews.firstWhere((item) => item.id == id);
    } catch (_) {
      try {
        news = _historyCache.firstWhere((item) => item.id == id);
      } catch (_) {
        try {
          news = _favoritesCache.firstWhere((item) => item.id == id);
        } catch (_) {
          return; // Não achou a notícia
        }
      }
    }

    final isFavorite = _favoritesCache.any((item) => item.id == id);

    if (isFavorite) {
      _favoritesCache.removeWhere((item) => item.id == id);
      news.isFavorite = false;
    } else {
      news.isFavorite = true;
      _favoritesCache.add(news);
    }
  }

  String _cleanHtml(String html) {
    return html.replaceAll(RegExp(r"<[^>]*>"), "").trim();
  }
}