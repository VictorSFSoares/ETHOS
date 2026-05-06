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
  final List<NewsItem> _favoritesCache = [];

  Future<List<NewsItem>> getAllNews() async {
    if (_cachedNews.isNotEmpty) return _cachedNews;
    try {
      final response = await http.get(Uri.parse(_apiUrl)).timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List items = data['items'];
        
        _cachedNews = items.map((json) {
          final title = json['title'] ?? '';
          return NewsItem(
            id: json['guid'] ?? DateTime.now().toString(),
            title: title,
            description: _cleanHtml(json['description'] ?? 'Sem descrição disponível.'),
            imageUrl: json['enclosure']?['link'] ?? 'https://via.placeholder.com/400',
            source: 'G1 Globo',
            // NOVO: Chamando a função para categorizar
            category: _determineCategory(title),
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

  // NOVO: Lógica para definir a categoria baseada no título (Palavras mais comuns do G1)
  String _determineCategory(String title) {
    String lowerTitle = title.toLowerCase();
    
    if (lowerTitle.contains(RegExp(r'\b(lula|bolsonaro|stf|congresso|senado|câmara|política|governo|ministro|eleições|tse)\b'))) {
      return 'Política';
    }
    if (lowerTitle.contains(RegExp(r'\b(dólar|bolsa|mercado|economia|inflação|juros|imposto|banco|bc|copom|impostos)\b'))) {
      return 'Economia';
    }
    if (lowerTitle.contains(RegExp(r'\b(futebol|esporte|campeonato|libertadores|seleção|flamengo|corinthians|palmeiras|são paulo|vasco)\b'))) {
      return 'Esportes';
    }
    if (lowerTitle.contains(RegExp(r'\b(eua|guerra|israel|gaza|rússia|ucrânia|mundo|internacional|biden|trump|putin)\b'))) {
      return 'Mundo';
    }
    if (lowerTitle.contains(RegExp(r'\b(filme|série|música|show|cinema|televisão|famosos|bbb|globo|arte|pop)\b'))) {
      return 'Pop & Arte';
    }
    if (lowerTitle.contains(RegExp(r'\b(polícia|acidente|chuva|trânsito|brasil|sp|rj|mg)\b'))) {
      return 'Brasil';
    }
    
    return 'Geral';
  }

  void addToHistory(NewsItem news) {
    _historyCache.removeWhere((item) => item.id == news.id);
    _historyCache.insert(0, news);
  }

  Future<List<NewsItem>> getHistoryNews() async {
    return _historyCache;
  }

  Future<List<NewsItem>> getFavoriteNews() async {
    return _favoritesCache;
  }

  Future<void> toggleFavorite(String id) async {
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
          return; 
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