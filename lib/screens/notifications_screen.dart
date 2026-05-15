import 'dart:async';
import 'package:flutter/material.dart';
import '../services/verification_service.dart';

// O modelo permanece aqui para manter a compatibilidade com a tua interface
class NotificationItem {
  final String id;
  final String title;
  final String message;
  final String time;
  final IconData icon;
  final Color iconColor;
  final bool isRead;
  final String type;

  NotificationItem({
    required this.id,
    required this.title,
    required this.message,
    required this.time,
    required this.icon,
    required this.iconColor,
    required this.isRead,
    required this.type,
  });

  NotificationItem copyWith({bool? isRead}) {
    return NotificationItem(
      id: id,
      title: title,
      message: message,
      time: time,
      icon: icon,
      iconColor: iconColor,
      isRead: isRead ?? this.isRead,
      type: type,
    );
  }
}

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final VerificationService _service = VerificationService();
  StreamSubscription? _subscription;
  
  String _selectedFilter = 'Todas';
  final List<String> _filters = ['Todas', 'Não lidas', 'Verificações', 'Sistema'];
  List<NotificationItem> _notifications = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _startListening();
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  // --- LÓGICA ATUALIZADA COM TRATAMENTO DE ERRO ---
  void _startListening() {
    _subscription = _service.ouvirNotificacoes().listen(
      (data) {
        if (mounted) {
          setState(() {
            _notifications = data;
            _isLoading = false;
          });
        }
      },
      onError: (error) {
        debugPrint("ERRO CRÍTICO NO FIRESTORE: $error");
        if (mounted) {
          setState(() => _isLoading = false);
          
          // Se o erro for sobre índices, isto avisará a equipa
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Erro: $error"),
              backgroundColor: Colors.redAccent,
              duration: const Duration(seconds: 10),
              action: SnackBarAction(
                label: 'OK',
                textColor: Colors.white,
                onPressed: () {},
              ),
            ),
          );
        }
      },
    );
  }

  List<NotificationItem> get _filteredNotifications {
    List<NotificationItem> temp = _notifications;
    if (_selectedFilter == 'Não lidas') {
      temp = temp.where((n) => !n.isRead).toList();
    } else if (_selectedFilter == 'Verificações') {
      temp = temp.where((n) => n.type == 'Verificações').toList();
    } else if (_selectedFilter == 'Sistema') {
      temp = temp.where((n) => n.type == 'Sistema').toList();
    }
    return temp;
  }

  int get _unreadCount => _notifications.where((n) => !n.isRead).length;

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
        title: Row(
          children: [
            const Icon(Icons.notifications_active, color: Color(0xFF4CAF50), size: 24),
            const SizedBox(width: 12),
            const Text(
              'Notificações',
              style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
            ),
            if (_unreadCount > 0) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(12)),
                child: Text(
                  '$_unreadCount',
                  style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ],
        ),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            color: const Color(0xFF1A1A1A),
            onSelected: (value) {
              if (value == 'mark_all_read') _service.marcarTodasComoLidas();
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'mark_all_read',
                child: Text('Marcar todas como lidas', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          _buildFilterChips(),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: Color(0xFF4CAF50)))
                : _filteredNotifications.isEmpty
                    ? _buildEmptyState()
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        itemCount: _filteredNotifications.length,
                        itemBuilder: (context, index) => _buildNotificationCard(_filteredNotifications[index]),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChips() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: _filters.map((filter) {
            final isSelected = _selectedFilter == filter;
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: FilterChip(
                selected: isSelected,
                label: Text(filter),
                onSelected: (val) => setState(() => _selectedFilter = filter),
                selectedColor: const Color(0xFF4CAF50),
                backgroundColor: const Color(0xFF1A1A1A),
                checkmarkColor: Colors.black,
                labelStyle: TextStyle(
                  color: isSelected ? Colors.black : Colors.grey.shade400,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
                side: BorderSide(color: isSelected ? const Color(0xFF4CAF50) : Colors.grey.shade800),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildNotificationCard(NotificationItem notification) {
    return GestureDetector(
      onTap: () => _service.marcarNotificacaoComoLida(notification.id),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A1A),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: notification.isRead 
                ? Colors.grey.shade900 
                : const Color(0xFF4CAF50).withOpacity(0.3),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: notification.iconColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(notification.icon, color: notification.iconColor, size: 24),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    notification.title,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: notification.isRead ? FontWeight.normal : FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    notification.message,
                    style: TextStyle(color: Colors.grey.shade400, fontSize: 13, height: 1.4),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    notification.time,
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 11),
                  ),
                ],
              ),
            ),
            if (!notification.isRead)
              Container(
                margin: const EdgeInsets.only(top: 4),
                width: 8,
                height: 8,
                decoration: const BoxDecoration(color: Color(0xFF4CAF50), shape: BoxShape.circle),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.notifications_none, size: 64, color: Colors.grey.shade800),
          const SizedBox(height: 16),
          Text(
            'Tudo limpo por aqui!',
            style: TextStyle(color: Colors.grey.shade500, fontSize: 16, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}