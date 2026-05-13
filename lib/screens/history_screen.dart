import 'dart:async';
import 'package:flutter/material.dart';
import '../models/data_models.dart';
import '../services/verification_service.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final VerificationService _verificationService = VerificationService();
  final TextEditingController _searchController = TextEditingController();
  
  StreamSubscription? _historySubscription;
  List<VerificationItem> _allVerifications = [];
  List<VerificationItem> _filteredVerifications = [];
  String _selectedFilter = 'Todos';
  bool _isLoading = true;
  UserStats? _stats;

  final List<String> _filters = const [
    'Todos',
    'VERIFICADAS',
    'FAKE NEWS',
    'Suspeitos'
  ];

  @override
  void initState() {
    super.initState();
    _startListening();
  }

  @override
  void dispose() {
    _historySubscription?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  // Inicia a escuta em tempo real
  void _startListening() {
    _historySubscription = _verificationService.ouvirUserVerifications().listen((data) async {
      // Sempre que os dados mudarem no Firebase, este bloco executa:
      final stats = await _verificationService.getUserStats();
      
      if (mounted) {
        setState(() {
          _allVerifications = data;
          _stats = stats;
          _isLoading = false;
          // Aplica o filtro atual aos novos dados recebidos
          _applyCurrentFilters();
        });
      }
    }, onError: (e) {
      debugPrint("Erro no Stream de Histórico: $e");
      if (mounted) setState(() => _isLoading = false);
    });
  }

  void _applyCurrentFilters() {
    String query = _searchController.text.toLowerCase();
    
    List<VerificationItem> temp = _allVerifications;

    // 1. Filtro por Categoria/Status
    if (_selectedFilter != 'Todos') {
      final statusMap = {
        'VERIFICADAS': VerificationStatus.verified,
        'FAKE NEWS': VerificationStatus.fakeNews,
        'Suspeitos': VerificationStatus.suspicious,
      };
      temp = temp.where((v) => v.status == statusMap[_selectedFilter]).toList();
    }

    // 2. Filtro por Busca de Texto
    if (query.isNotEmpty) {
      temp = temp.where((v) => v.content.toLowerCase().contains(query)).toList();
    }

    setState(() {
      _filteredVerifications = temp;
    });
  }

  // --- LÓGICA DE DETALHES (ACESSAR POR EXTENSO) ---
  
  void _showDetails(VerificationItem item) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1A1A1A),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        expand: false,
        builder: (context, scrollController) => SingleChildScrollView(
          controller: scrollController,
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade800,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Icon(item.status.icon, color: item.status.color, size: 28),
                  const SizedBox(width: 12),
                  Text(
                    item.status.label.toUpperCase(),
                    style: TextStyle(
                      color: item.status.color,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              const Text(
                'CONTEÚDO ANALISADO',
                style: TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                item.content,
                style: const TextStyle(color: Colors.white, fontSize: 16, height: 1.5),
              ),
              const SizedBox(height: 24),
              const Divider(color: Colors.white10),
              const SizedBox(height: 24),
              const Text(
                'PARECER DOS ESPECIALISTAS ETHOS',
                style: TextStyle(color: Color(0xFF4CAF50), fontSize: 12, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Text(
                item.details ?? 'Esta verificação ainda está a ser processada pela nossa equipa técnica. Volte a consultar em breve.',
                style: TextStyle(
                  color: Colors.grey.shade300,
                  fontSize: 15,
                  height: 1.6,
                  fontStyle: item.details == null ? FontStyle.italic : FontStyle.normal,
                ),
              ),
              const SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildDetailMiniCard('Confiança', '${item.confidence}%'),
                  _buildDetailMiniCard('Tipo', item.type.toUpperCase()),
                  _buildDetailMiniCard('Data', '${item.verifiedAt.day}/${item.verifiedAt.month}'),
                ],
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailMiniCard(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(color: Colors.grey.shade600, fontSize: 11)),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ],
    );
  }

  // --- WIDGETS DE INTERFACE MANTIDOS ---

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              _buildSearchBar(),
              const SizedBox(height: 16),
              _buildFilterChips(),
              const SizedBox(height: 16),
              _buildStatsCards(),
            ],
          ),
        ),
        Expanded(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator(color: Color(0xFF4CAF50)))
              : _buildVerificationList(),
        ),
      ],
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
        onChanged: (_) => _applyCurrentFilters(),
        style: const TextStyle(fontSize: 14, color: Colors.white),
        decoration: InputDecoration(
          hintText: 'Buscar no histórico...',
          hintStyle: TextStyle(color: Colors.grey.shade600),
          prefixIcon: Icon(Icons.search, color: Colors.grey.shade600),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
    );
  }

  Widget _buildFilterChips() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: _filters.map((filter) {
          final isSelected = _selectedFilter == filter;
          final Color chipColor = _getFilterColor(filter);

          return GestureDetector(
            onTap: () {
              setState(() => _selectedFilter = filter);
              _applyCurrentFilters();
            },
            child: Container(
              margin: const EdgeInsets.only(right: 10),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: isSelected ? chipColor : const Color(0xFF1A1A1A),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: isSelected ? chipColor : Colors.grey.shade700),
              ),
              child: Text(
                filter,
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.grey.shade400,
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

  Color _getFilterColor(String filter) {
    switch (filter) {
      case 'VERIFICADAS': return const Color(0xFF4CAF50);
      case 'FAKE NEWS': return Colors.red;
      case 'Suspeitos': return Colors.orange;
      default: return Colors.blue;
    }
  }

  Widget _buildStatsCards() {
    return Row(
      children: [
        _buildStatCard(_stats?.verified.toString() ?? '0', 'Verificados', const Color(0xFF4CAF50)),
        const SizedBox(width: 10),
        _buildStatCard(_stats?.fakeNews.toString() ?? '0', 'Fake News', Colors.red),
        const SizedBox(width: 10),
        _buildStatCard(_stats?.suspicious.toString() ?? '0', 'Suspeitos', Colors.orange),
      ],
    );
  }

  Widget _buildStatCard(String value, String label, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.15),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Text(value, style: TextStyle(color: color, fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(label, style: TextStyle(color: color, fontSize: 11)),
          ],
        ),
      ),
    );
  }

  Widget _buildVerificationList() {
    if (_filteredVerifications.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.history, size: 64, color: Colors.grey.shade700),
            const SizedBox(height: 16),
            Text('Nenhuma verificação encontrada', style: TextStyle(color: Colors.grey.shade500, fontSize: 16)),
          ],
        ),
      );
    }

    final grouped = _groupByDate(_filteredVerifications);

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: grouped.length,
      itemBuilder: (context, index) {
        final entry = grouped.entries.elementAt(index);
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Text(entry.key, style: TextStyle(color: Colors.grey.shade500, fontSize: 13)),
            ),
            ...entry.value.map((v) => _buildVerificationItem(v)),
          ],
        );
      },
    );
  }

  Map<String, List<VerificationItem>> _groupByDate(List<VerificationItem> items) {
    final Map<String, List<VerificationItem>> grouped = {};
    for (var item in items) {
      final date = _getDateLabel(item.verifiedAt);
      grouped.putIfAbsent(date, () => []);
      grouped[date]!.add(item);
    }
    return grouped;
  }

  String _getDateLabel(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final itemDate = DateTime(date.year, date.month, date.day);
    if (itemDate == today) return 'Hoje';
    if (itemDate == today.subtract(const Duration(days: 1))) return 'Ontem';
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  Widget _buildVerificationItem(VerificationItem item) {
    return GestureDetector(
      onTap: () => _showDetails(item), // Ação de clique para ver por extenso
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A1A),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: item.status == VerificationStatus.pending 
                ? Colors.grey.shade800 
                : item.status.color.withOpacity(0.3)
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: item.status.color.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    children: [
                      Icon(item.status.icon, color: item.status.color, size: 14),
                      const SizedBox(width: 4),
                      Text(item.status.label.toUpperCase(), style: TextStyle(color: item.status.color, fontSize: 10, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
                const Spacer(),
                Text(
                  '${item.verifiedAt.hour.toString().padLeft(2, '0')}:${item.verifiedAt.minute.toString().padLeft(2, '0')}',
                  style: TextStyle(color: Colors.grey.shade500, fontSize: 11),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              item.content,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.white),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.info_outline, size: 14, color: Colors.grey.shade600),
                const SizedBox(width: 4),
                Text('Toque para ver detalhes', style: TextStyle(color: Colors.grey.shade600, fontSize: 11)),
                const Spacer(),
                if (item.status != VerificationStatus.pending)
                   Text('${item.confidence}% confiança', style: TextStyle(color: item.status.color, fontSize: 11, fontWeight: FontWeight.bold)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}