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

  List<VerificationItem> _allVerifications = [];
  List<VerificationItem> _filteredVerifications = [];
  String _selectedFilter = 'Todos';
  bool _isLoading = true;
  UserStats? _stats;

  final List<String> _filters = [
    'Todos',
    'VERIFICADAS',
    'FAKE NEWS',
    'Suspeitos'
  ];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final verifications = await _verificationService.getUserVerifications();
    final stats = await _verificationService.getUserStats();

    setState(() {
      _allVerifications = verifications;
      _filteredVerifications = verifications;
      _stats = stats;
      _isLoading = false;
    });
  }

  void _filterVerifications(String filter) {
    setState(() {
      _selectedFilter = filter;
      if (filter == 'Todos') {
        _filteredVerifications = _allVerifications;
      } else if (filter == 'VERIFICADAS') {
        _filteredVerifications = _allVerifications
            .where((v) => v.status == VerificationStatus.verified)
            .toList();
      } else if (filter == 'FAKE NEWS') {
        _filteredVerifications = _allVerifications
            .where((v) => v.status == VerificationStatus.fakeNews)
            .toList();
      } else if (filter == 'Suspeitos') {
        _filteredVerifications = _allVerifications
            .where((v) => v.status == VerificationStatus.suspicious)
            .toList();
      }
    });
  }

  void _searchVerifications(String query) {
    setState(() {
      if (query.isEmpty) {
        _filterVerifications(_selectedFilter);
      } else {
        _filteredVerifications = _allVerifications
            .where((v) => v.content.toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    });
  }

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
              ? const Center(child: CircularProgressIndicator())
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
        onChanged: _searchVerifications,
        style: const TextStyle(fontSize: 14),
        decoration: InputDecoration(
          hintText: 'Buscar no histórico...',
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

  Widget _buildFilterChips() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: _filters.map((filter) {
          final isSelected = _selectedFilter == filter;
          Color chipColor;

          if (filter == 'VERIFICADAS') {
            chipColor = const Color(0xFF4CAF50);
          } else if (filter == 'FAKE NEWS') {
            chipColor = Colors.red;
          } else if (filter == 'Suspeitos') {
            chipColor = Colors.orange;
          } else {
            chipColor = Colors.blue;
          }

          return GestureDetector(
            onTap: () => _filterVerifications(filter),
            child: Container(
              margin: const EdgeInsets.only(right: 10),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: isSelected ? chipColor : const Color(0xFF1A1A1A),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected ? chipColor : Colors.grey.shade700,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    filter,
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.grey.shade400,
                      fontSize: 13,
                      fontWeight:
                          isSelected ? FontWeight.w600 : FontWeight.normal,
                    ),
                  ),
                  if (filter != 'Todos') ...[
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? Colors.white.withValues(alpha: 0.2)
                            : chipColor.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        _getFilterCount(filter),
                        style: TextStyle(
                          color: isSelected ? Colors.white : chipColor,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  String _getFilterCount(String filter) {
    if (_stats == null) return '0';
    switch (filter) {
      case 'VERIFICADAS':
        return _stats!.verified.toString();
      case 'FAKE NEWS':
        return _stats!.fakeNews.toString();
      case 'Suspeitos':
        return _stats!.suspicious.toString();
      default:
        return _stats!.totalVerifications.toString();
    }
  }

  Widget _buildStatsCards() {
    return Row(
      children: [
        _buildStatCard(
          _stats?.verified.toString() ?? '0',
          'Verificados',
          const Color(0xFF4CAF50),
        ),
        const SizedBox(width: 10),
        _buildStatCard(
          _stats?.fakeNews.toString() ?? '0',
          'Fake News',
          Colors.red,
        ),
        const SizedBox(width: 10),
        _buildStatCard(
          _stats?.suspicious.toString() ?? '0',
          'Suspeitos',
          Colors.orange,
        ),
      ],
    );
  }

  Widget _buildStatCard(String value, String label, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: TextStyle(
                color: color,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 11,
              ),
            ),
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
            Text(
              'Nenhuma verificação encontrada',
              style: TextStyle(
                color: Colors.grey.shade500,
                fontSize: 16,
              ),
            ),
          ],
        ),
      );
    }

    // Agrupa por data
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
              child: Row(
                children: [
                  Icon(Icons.access_time,
                      size: 14, color: Colors.grey.shade600),
                  const SizedBox(width: 6),
                  Text(
                    entry.key,
                    style: TextStyle(
                      color: Colors.grey.shade500,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            ...entry.value.map((v) => _buildVerificationItem(v)),
          ],
        );
      },
    );
  }

  Map<String, List<VerificationItem>> _groupByDate(
      List<VerificationItem> items) {
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
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade800),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: item.status.color.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(item.status.icon, color: item.status.color, size: 14),
                    const SizedBox(width: 4),
                    Text(
                      item.type.toUpperCase(),
                      style: TextStyle(
                        color: item.status.color,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Text(
                _formatTime(item.verifiedAt),
                style: TextStyle(
                  color: Colors.grey.shade500,
                  fontSize: 11,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            item.content,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: item.status.color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  item.status.label.toLowerCase(),
                  style: TextStyle(
                    color: item.status.color,
                    fontSize: 11,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '${item.confidence}% confiança',
                style: TextStyle(
                  color: Colors.grey.shade500,
                  fontSize: 11,
                ),
              ),
              const Spacer(),
              Icon(Icons.open_in_new, size: 16, color: Colors.grey.shade600),
              const SizedBox(width: 8),
              Icon(Icons.delete_outline, size: 16, color: Colors.grey.shade600),
            ],
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
