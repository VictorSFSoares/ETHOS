import 'package:flutter/material.dart';
import '../models/data_models.dart';
import '../services/economy_service.dart';
import '../services/verification_service.dart';
import '../services/news_service.dart';
import 'historycheck_screen.dart';
import 'news_screen.dart'; 

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final VerificationService _verificationService = VerificationService();
  final NewsService _newsService = NewsService(); 
  
  List<VerificationItem> _recentVerifications = [];
  List<NewsItem> _latestNews = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    // Carrega dados dos serviços
    final verifications = await _verificationService.getRecentVerifications();
    final news = await _newsService.getAllNews(); 
    
    if (mounted) {
      setState(() {
        _recentVerifications = verifications.take(3).toList();
        _latestNews = news.take(3).toList();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildVerificationSection(),
          const SizedBox(height: 24),
          _buildQuickActions(context), // Passando context para navegação
          const SizedBox(height: 24),
          _buildMarketRates(),
          const SizedBox(height: 24),
          _buildDashboardNews(), 
          const SizedBox(height: 24),
          _buildTipsSection(),
          const SizedBox(height: 24),
          _buildRecentVerifications(),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildVerificationSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF2E7D32), Color(0xFF1B5E20)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.shield, color: Colors.white, size: 28),
              SizedBox(width: 10),
              Text(
                'Ambiente Seguro',
                style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Você está protegido pelo ETHOS. Fique atualizado e verifique conteúdos suspeitos.',
            style: TextStyle(color: Colors.white.withValues(alpha: 0.9), fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Acesso Rápido',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        const SizedBox(height: 16),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _buildQuickAction(
                Icons.article, 
                'Notícias', 
                'Em alta', 
                Colors.blue,
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const NewsScreen())),
              ),
              _buildQuickAction(
                Icons.trending_up, 
                'Trending', 
                'Mais lidos', 
                const Color(0xFF4CAF50),
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const NewsScreen())),
              ),
              _buildQuickAction(
                Icons.star, 
                'Favoritos', 
                'Salvos', 
                Colors.amber,
                onTap: () => Navigator.pushNamed(context, '/favorites'),
              ),
              _buildQuickAction(
                Icons.history, 
                'Histórico', 
                'Buscas', 
                Colors.purple,
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const HistoryCheckScreen())),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildQuickAction(IconData icon, String title, String subtitle, Color color, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 100, 
        height: 115, 
        margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A1A),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade800),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center, 
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis, 
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: Colors.white),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 10, color: Colors.grey.shade500),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMarketRates() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Mercado em Tempo Real',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        const SizedBox(height: 12),
        FutureBuilder<List<CurrencyRate>>(
          future: EconomyService().getMarketRates(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator(color: Color(0xFF4CAF50)));
            }
            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Text('Moedas indisponíveis no momento.', style: TextStyle(color: Colors.grey.shade600));
            }
            final rates = snapshot.data!;
            return SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: rates.map((rate) => _buildCurrencyCard(rate)).toList(),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildCurrencyCard(CurrencyRate rate) {
    final isPositive = rate.variation >= 0;
    final color = isPositive ? const Color(0xFF4CAF50) : const Color(0xFFE53935);
    final icon = isPositive ? Icons.arrow_upward : Icons.arrow_downward;

    return Container(
      width: 140,
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade800),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(rate.name, style: TextStyle(color: Colors.grey.shade400, fontSize: 12)),
          const SizedBox(height: 8),
          Text(
            'R\$ ${rate.buyValue.toStringAsFixed(2)}',
            style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(icon, color: color, size: 14),
              const SizedBox(width: 4),
              Text(
                '${rate.variation}%',
                style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDashboardNews() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Últimas Notícias',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            GestureDetector(
              onTap: () => Navigator.push(
                context, 
                MaterialPageRoute(builder: (context) => const NewsScreen())
              ),
              child: const Row(
                children: [
                  Text('Ver todas', style: TextStyle(color: Color(0xFF4CAF50), fontSize: 13)),
                  SizedBox(width: 4),
                  Icon(Icons.arrow_forward, color: Color(0xFF4CAF50), size: 16),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (_isLoading)
          const Center(child: CircularProgressIndicator(color: Color(0xFF4CAF50)))
        else if (_latestNews.isEmpty)
          Center(child: Text('Nenhuma notícia no momento.', style: TextStyle(color: Colors.grey.shade600)))
        else
          ..._latestNews.map((news) => _buildCompactNewsCard(news)),
      ],
    );
  }

  Widget _buildCompactNewsCard(NewsItem news) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const NewsScreen()),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        height: 80,
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A1A),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade800),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.horizontal(left: Radius.circular(11)),
              child: Image.network(
                news.imageUrl,
                width: 80,
                height: 80,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  width: 80,
                  height: 80,
                  color: Colors.grey.shade900,
                  child: const Icon(Icons.image, color: Colors.grey),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(10),
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
                        fontSize: 13, 
                        fontWeight: FontWeight.bold,
                        height: 1.2,
                      ),
                    ),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFF4CAF50).withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text(
                            'Verificado',
                            style: TextStyle(color: Color(0xFF4CAF50), fontSize: 9, fontWeight: FontWeight.bold),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            '${news.source} · ${_formatTime(news.publishedAt)}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(color: Colors.grey.shade500, fontSize: 10),
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

  Widget _buildTipsSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade800),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.lightbulb_outline, color: Colors.blue),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Dica do dia',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white),
                ),
                SizedBox(height: 4),
                Text(
                  'Sempre verifique a fonte original da notícia antes de compartilhar com familiares.',
                  style: TextStyle(fontSize: 13, color: Colors.grey),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentVerifications() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Suas Verificações Recentes',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        const SizedBox(height: 16),
        if (_isLoading)
          const Center(child: CircularProgressIndicator())
        else if (_recentVerifications.isEmpty)
          Center(
            child: Text(
              'Nenhuma verificação recente.',
              style: TextStyle(color: Colors.grey.shade600),
            ),
          )
        else
          ..._recentVerifications.map((v) => _buildVerificationItem(v)),
      ],
    );
  }

  Widget _buildVerificationItem(VerificationItem item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade800),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: item.status.color.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(item.status.icon, color: item.status.color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.content,
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  '${item.source} · ${_formatTime(item.verifiedAt)}',
                  style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime time) {
    final diff = DateTime.now().difference(time);
    if (diff.inMinutes < 60) return '${diff.inMinutes} Min';
    if (diff.inHours < 24) return '${diff.inHours}h';
    return '${diff.inDays}d';
  }
}