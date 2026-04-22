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
  List<NewsItem> _allNews = [];
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
        _isLoading = false;
      });
    }
  }

  void _showNewsDetail(NewsItem news) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildNewsDetailSheet(news),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF4CAF50)))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _allNews.length,
              itemBuilder: (context, index) => _buildNewsItem(_allNews[index]),
            ),
    );
  }

  Widget _buildNewsItem(NewsItem news) {
    return Card(
      // CORRIGIDO: de .bottom(16) para .only(bottom: 16)
      margin: const EdgeInsets.only(bottom: 16), 
      color: const Color(0xFF1A1A1A),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      clipBehavior: Clip.antiAlias, 
      child: InkWell(
        onTap: () {
          _newsService.addToHistory(news);
          _showNewsDetail(news);
        },
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  news.imageUrl,
                  width: 90,
                  height: 90,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    width: 90, height: 90, color: Colors.grey.shade900,
                    child: const Icon(Icons.image_not_supported, color: Colors.white24),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      news.title,
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      news.description,
                      style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNewsDetailSheet(NewsItem news) {
    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      maxChildSize: 0.95,
      builder: (_, scrollController) => Container(
        decoration: const BoxDecoration(
          color: Color(0xFF1A1A1A),
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: ListView(
          controller: scrollController,
          children: [
            const SizedBox(height: 12),
            Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(2)))),
            const SizedBox(height: 24),
            Text(news.title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
            const SizedBox(height: 12),
            Text("${news.source} • Verificado", style: const TextStyle(color: Color(0xFF4CAF50), fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(news.imageUrl, fit: BoxFit.cover),
            ),
            const SizedBox(height: 24),
            Text(
              news.description,
              style: const TextStyle(fontSize: 16, color: Colors.white70, height: 1.6),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}