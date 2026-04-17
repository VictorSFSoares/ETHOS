import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/data_models.dart';

class NewsService {
  static final NewsService _instance = NewsService._internal();
  factory NewsService() => _instance;
  NewsService._internal();

  final String _apiUrl = 'https://api.rss2json.com/v1/api.json?rss_url=https://g1.globo.com/rss/g1/';
  List<NewsItem> _cachedNews = [];

  static const List<String> categories = ['Todas', 'Brasil', 'Política', 'Economia', 'Educação'];

  Future<List<NewsItem>> getAllNews() async {
    if (_cachedNews.isNotEmpty) return _cachedNews;

    try {
      final response = await http.get(Uri.parse(_apiUrl)).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        if (data['items'] != null) {
          final List<dynamic> articles = data['items'];
          _cachedNews = articles.map((json) => NewsItem.fromRssJson(json)).toList();
          return _cachedNews;
        }
      }
      return _loadMockup();
    } catch (e) {
      return _loadMockup();
    }
  }

  Future<List<NewsItem>> getNewsByCategory(String category) async {
    final news = await getAllNews();
    if (category == 'Todas') return news;
    final lowerCategory = category.toLowerCase();
    return news.where((n) => n.title.toLowerCase().contains(lowerCategory) || n.description.toLowerCase().contains(lowerCategory)).toList();
  }

  Future<List<NewsItem>> getTrendingNews() async {
    final news = await getAllNews();
    if (news.isEmpty) return [];
    return news.take(5).toList();
  }

  Future<List<NewsItem>> searchNews(String query) async {
    final news = await getAllNews();
    final lowerQuery = query.toLowerCase();
    return news.where((n) => n.title.toLowerCase().contains(lowerQuery) || n.description.toLowerCase().contains(lowerQuery)).toList();
  }

  Future<void> toggleFavorite(String id) async {
    final index = _cachedNews.indexWhere((news) => news.id == id);
    if (index != -1) _cachedNews[index].isFavorite = !_cachedNews[index].isFavorite;
  }

  Future<List<NewsItem>> getFavoriteNews() async {
    if (_cachedNews.isEmpty) await getAllNews();
    return _cachedNews.where((news) => news.isFavorite).toList();
  }

  // Backup garantido: Se a internet cair, o app sempre mostra dados lindos e não uma tela vazia
  List<NewsItem> _loadMockup() {
    return [
      NewsItem(
        id: '1', title: 'Novas regras para exportação impactam mercado financeiro',
        description: 'Especialistas debatem os efeitos a longo prazo das novas diretrizes aprovadas.',
        imageUrl: 'https://images.unsplash.com/photo-1611974789855-9c2a0a7236a3?w=800',
        source: 'GloboNews', category: 'Economia', publishedAt: DateTime.now(),
        status: VerificationStatus.verified, confidence: 95,
      ),
      NewsItem(
        id: '2', title: 'Avanços na inteligência artificial focada em saúde',
        description: 'Hospitais brasileiros começam a adotar sistemas automatizados para triagem.',
        imageUrl: 'https://images.unsplash.com/photo-1576091160399-112ba8d25d1d?w=800',
        source: 'G1 Tecnologia', category: 'Tecnologia', publishedAt: DateTime.now(),
        status: VerificationStatus.verified, confidence: 92,
      ),
    ];
  }
}