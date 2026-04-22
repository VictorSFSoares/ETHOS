import 'package:flutter/material.dart';
import '../models/data_models.dart';
import '../services/news_service.dart';

class HistoryCheckScreen extends StatefulWidget {
  const HistoryCheckScreen({super.key});

  @override
  State<HistoryCheckScreen> createState() => _HistoryCheckScreenState();
}

class _HistoryCheckScreenState extends State<HistoryCheckScreen> {
  final NewsService _newsService = NewsService();
  List<NewsItem> _historyNews = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    try {
      // Certifique-se de que o NewsService possui a função getHistoryNews()
      final history = await _newsService.getHistoryNews(); 
      if (mounted) {
        setState(() {
          _historyNews = history;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Erro ao carregar histórico: $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Histórico de Leitura',
          style: TextStyle(
            color: Colors.white, 
            fontSize: 20, 
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF4CAF50)))
          : _historyNews.isEmpty
              ? _buildEmptyState()
              : RefreshIndicator(
                  color: const Color(0xFF4CAF50),
                  onRefresh: _loadHistory,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _historyNews.length,
                    itemBuilder: (context, index) {
                      return _buildPremiumHistoryCard(_historyNews[index]);
                    },
                  ),
                ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.history, size: 80, color: Colors.grey.shade800),
          const SizedBox(height: 16),
          const Text(
            'Nenhum histórico recente',
            style: TextStyle(
              color: Colors.white, 
              fontSize: 18, 
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'As notícias que você ler\naparecerão aqui.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey.shade500, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildPremiumHistoryCard(NewsItem news) {
    return GestureDetector(
      onTap: () {
        // Envia o log para o operador indicando que a notícia foi reaberta do histórico
        debugPrint('OPERADOR [Log de Histórico]: O usuário abriu a notícia "${news.title}" a partir da tela de Histórico de Leitura.');
        _showNewsDetail(news);
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        height: 120, 
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A1A),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade800),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.horizontal(left: Radius.circular(15)),
              child: Image.network(
                news.imageUrl,
                width: 120,
                height: 120,
                fit: BoxFit.cover, 
                errorBuilder: (context, error, stackTrace) => Container(
                  width: 120,
                  height: 120,
                  color: Colors.grey.shade900,
                  child: const Icon(Icons.image, color: Colors.grey),
                ),
              ),
            ),
            
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      news.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white, 
                        fontSize: 14, 
                        fontWeight: FontWeight.bold,
                        height: 1.2,
                      ),
                    ),
                    
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Expanded(
                          child: Text(
                            news.source,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: Colors.grey.shade400, 
                              fontSize: 12,
                            ),
                          ),
                        ),
                        
                        GestureDetector(
                          onTap: () async {
                            await _newsService.toggleFavorite(news.id);
                            // Apenas atualiza a tela para mudar o ícone (não remove da lista de histórico)
                            if (mounted) setState(() {}); 
                            
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(news.isFavorite ? 'Adicionado aos favoritos' : 'Removido dos favoritos'),
                                  backgroundColor: const Color(0xFF1A1A1A),
                                  duration: const Duration(seconds: 1),
                                ),
                              );
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: const Color(0xFF4CAF50).withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              news.isFavorite ? Icons.bookmark : Icons.bookmark_border, 
                              color: const Color(0xFF4CAF50), 
                              size: 18,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // =======================================================================
  // MÉTODOS DA JANELA DE DETALHES (BOTTOM SHEET)
  // =======================================================================

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
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Color(0xFF1A1A1A),
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: SingleChildScrollView(
            controller: scrollController,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    margin: const EdgeInsets.only(top: 12),
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade600,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.network(
                      news.imageUrl,
                      height: 200,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        height: 200,
                        color: Colors.grey.shade900,
                        child: const Center(child: Icon(Icons.image, size: 40, color: Colors.grey)),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: _getCategoryColor(news.category),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              news.category,
                              style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600),
                            ),
                          ),
                          const SizedBox(width: 10),
                          _buildVerificationBadge(news),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        news.title,
                        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Icon(Icons.source, size: 16, color: Colors.grey.shade500),
                          const SizedBox(width: 6),
                          Text(news.source, style: TextStyle(color: Colors.grey.shade400, fontSize: 13)),
                          const SizedBox(width: 16),
                          Icon(Icons.access_time, size: 16, color: Colors.grey.shade500),
                          const SizedBox(width: 6),
                          Text(_formatTime(news.publishedAt), style: TextStyle(color: Colors.grey.shade400, fontSize: 13)),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Text(
                        news.description,
                        style: TextStyle(color: Colors.grey.shade300, fontSize: 15, height: 1.6),
                      ),
                      const SizedBox(height: 30),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildVerificationBadge(NewsItem news) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: news.status.color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: news.status.color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(news.status.icon, color: news.status.color, size: 14),
          const SizedBox(width: 6),
          Text(
            '${news.confidence}%',
            style: TextStyle(color: news.status.color, fontSize: 12, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime time) {
    final diff = DateTime.now().difference(time);
    if (diff.inMinutes < 60) return 'Há ${diff.inMinutes} min';
    if (diff.inHours < 24) return 'Há ${diff.inHours}h';
    return 'Há ${diff.inDays} dias';
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'Política': return Colors.blue.shade700;
      case 'Saúde': return Colors.red.shade700;
      case 'Tecnologia': return Colors.purple.shade700;
      case 'Economia': return Colors.amber.shade800;
      case 'Educação': return Colors.teal.shade700;
      default: return Colors.green.shade700;
    }
  }
}