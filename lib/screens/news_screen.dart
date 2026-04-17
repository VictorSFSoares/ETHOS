import 'package:flutter/material.dart';
import '../models/data_models.dart';
import '../services/news_service.dart';

class NewsScreen extends StatefulWidget {
  const NewsScreen({super.key});

  @override
  State<NewsScreen> createState() => _NewsScreenState();
}

class _NewsScreenState extends State<NewsScreen> {
  final NewsService _newsService = NewsService();
  final TextEditingController _searchController = TextEditingController();
  
  List<NewsItem> _allNews = [];
  List<NewsItem> _filteredNews = [];
  String _selectedCategory = 'Todas';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadNews();
  }

  Future<void> _loadNews() async {
    final news = await _newsService.getAllNews();
    if (mounted) {
      setState(() {
        _allNews = news;
        _filteredNews = news;
        _isLoading = false;
      });
    }
  }

  Future<void> _filterByCategory(String category) async {
    setState(() {
      _isLoading = true;
      _selectedCategory = category;
    });

    final news = await _newsService.getNewsByCategory(category);
    if (mounted) {
      setState(() {
        _filteredNews = news;
        _isLoading = false;
      });
    }
  }

  void _searchNews(String query) async {
    if (query.isEmpty) {
      _filterByCategory(_selectedCategory);
      return;
    }

    final results = await _newsService.searchNews(query);
    if (mounted) {
      setState(() {
        _filteredNews = results;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // A CORREÇÃO ESTÁ AQUI: Envolvemos tudo em um Scaffold
    return Scaffold(
      backgroundColor: const Color(0xFF000000), // Cor de fundo do app
      appBar: AppBar(
        title: const Text('Notícias Verificadas', style: TextStyle(fontSize: 18)),
        backgroundColor: const Color(0xFF1A1A1A),
        elevation: 0,
        centerTitle: true,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildSearchBar(),
                const SizedBox(height: 16),
                _buildCategoryChips(),
              ],
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: Color(0xFF4CAF50)))
                : _buildNewsList(),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade800),
      ),
      child: TextField(
        controller: _searchController,
        onChanged: _searchNews,
        style: const TextStyle(fontSize: 14, color: Colors.white),
        decoration: InputDecoration(
          hintText: 'Buscar notícias verificadas...',
          hintStyle: TextStyle(color: Colors.grey.shade600),
          prefixIcon: Icon(Icons.search, color: Colors.grey.shade600),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryChips() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: NewsService.categories.map((category) {
          final isSelected = _selectedCategory == category;
          return GestureDetector(
            onTap: () => _filterByCategory(category),
            child: Container(
              margin: const EdgeInsets.only(right: 10),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFF4CAF50) : const Color(0xFF1A1A1A),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected ? const Color(0xFF4CAF50) : Colors.grey.shade700,
                ),
              ),
              child: Text(
                category,
                style: TextStyle(
                  color: isSelected ? Colors.black : Colors.grey.shade400,
                  fontSize: 13,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildNewsList() {
    if (_filteredNews.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.article_outlined, size: 64, color: Colors.grey.shade700),
            const SizedBox(height: 16),
            Text(
              'Nenhuma notícia encontrada',
              style: TextStyle(
                color: Colors.grey.shade500,
                fontSize: 16,
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadNews,
      color: const Color(0xFF4CAF50),
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _filteredNews.length,
        itemBuilder: (context, index) {
          return _buildNewsCard(_filteredNews[index]);
        },
      ),
    );
  }

  Widget _buildNewsCard(NewsItem news) {
    return GestureDetector(
      onTap: () => _showNewsDetail(news),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade800),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                  child: Image.network(
                    news.imageUrl,
                    height: 180,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        height: 180,
                        color: Colors.grey.shade900,
                        child: const Center(
                          child: Icon(Icons.image, size: 40, color: Colors.grey),
                        ),
                      );
                    },
                  ),
                ),
                Positioned(
                  top: 12,
                  left: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: _getCategoryColor(news.category),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      news.category,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: Color(0xFF1A1A1A),
                borderRadius: BorderRadius.vertical(bottom: Radius.circular(16)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    news.title,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    news.description,
                    style: TextStyle(color: Colors.grey.shade400, fontSize: 13),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 14),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${news.source} • ${_formatTime(news.publishedAt)}',
                        style: TextStyle(color: Colors.grey.shade500, fontSize: 11),
                      ),
                      _buildVerificationBadge(news),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVerificationBadge(NewsItem news) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: news.status.color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: news.status.color.withValues(alpha: 0.5)),
      ),
      child: Row(
        children: [
          Icon(news.status.icon, color: news.status.color, size: 12),
          const SizedBox(width: 4),
          Text(
            '${news.confidence}%',
            style: TextStyle(color: news.status.color, fontSize: 11, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'Política': return Colors.blue.shade700;
      case 'Saúde': return Colors.red.shade700;
      case 'Tecnologia': return Colors.purple.shade700;
      case 'Economia': return Colors.amber.shade800;
      case 'Meio Ambiente': return Colors.green.shade700;
      default: return Colors.grey.shade700;
    }
  }

  String _formatTime(DateTime time) {
    final diff = DateTime.now().difference(time);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m';
    if (diff.inHours < 24) return '${diff.inHours}h';
    return '${diff.inDays}d';
  }

  void _showNewsDetail(NewsItem news) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildNewsDetailSheet(news),
    );
  }

  Widget _buildNewsDetailSheet(NewsItem news) {
    return DraggableScrollableSheet(
      initialChildSize: 0.9,
      builder: (_, scrollController) => Container(
        decoration: const BoxDecoration(
          color: Color(0xFF1A1A1A),
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: ListView(
          controller: scrollController,
          padding: const EdgeInsets.all(20),
          children: [
            Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey, borderRadius: BorderRadius.circular(2)))),
            const SizedBox(height: 20),
            ClipRRect(borderRadius: BorderRadius.circular(12), child: Image.network(news.imageUrl, fit: BoxFit.cover)),
            const SizedBox(height: 20),
            Text(news.title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
            const SizedBox(height: 15),
            Text(news.description, style: const TextStyle(fontSize: 16, color: Colors.white70, height: 1.5)),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}