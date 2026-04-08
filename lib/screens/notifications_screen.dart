import 'package:flutter/material.dart';

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
  String _selectedFilter = 'Todas';
  final List<String> _filters = ['Todas', 'Não lidas', 'Verificações', 'Sistema'];

  List<NotificationItem> _notifications = [
    NotificationItem(
      id: '1',
      title: 'Verificação Concluída',
      message: 'A notícia "Governo anuncia novas medidas econômicas" foi verificada como VERDADEIRA.',
      time: '2 min atrás',
      icon: Icons.check_circle,
      iconColor: const Color(0xFF4CAF50),
      isRead: false,
      type: 'Verificações',
    ),
    NotificationItem(
      id: '2',
      title: 'Alerta de Fake News',
      message: 'Detectamos uma notícia falsa circulando sobre "Vacina contra COVID-19 causa alterações no DNA".',
      time: '15 min atrás',
      icon: Icons.warning,
      iconColor: Colors.red,
      isRead: false,
      type: 'Verificações',
    ),
    NotificationItem(
      id: '3',
      title: 'Nova Conquista Desbloqueada',
      message: 'Parabéns! Você desbloqueou a conquista "Caçador de Fakes" por identificar 10 notícias falsas.',
      time: '1 hora atrás',
      icon: Icons.emoji_events,
      iconColor: Colors.amber,
      isRead: false,
      type: 'Sistema',
    ),
    NotificationItem(
      id: '4',
      title: 'Conteúdo Suspeito',
      message: 'O link que você verificou apresenta sinais de manipulação. Recomendamos cautela.',
      time: '2 horas atrás',
      icon: Icons.help,
      iconColor: Colors.orange,
      isRead: true,
      type: 'Verificações',
    ),
    NotificationItem(
      id: '5',
      title: 'Atualização do App',
      message: 'Uma nova versão do ETHOS está disponível com melhorias de desempenho.',
      time: '5 horas atrás',
      icon: Icons.system_update,
      iconColor: Colors.blue,
      isRead: true,
      type: 'Sistema',
    ),
    NotificationItem(
      id: '6',
      title: 'Dica do Dia',
      message: 'Sempre verifique a fonte original antes de compartilhar uma notícia.',
      time: '1 dia atrás',
      icon: Icons.lightbulb,
      iconColor: Colors.purple,
      isRead: true,
      type: 'Sistema',
    ),
    NotificationItem(
      id: '7',
      title: 'Relatório Semanal',
      message: 'Você verificou 12 notícias esta semana. Continue combatendo a desinformação!',
      time: '2 dias atrás',
      icon: Icons.analytics,
      iconColor: const Color(0xFF4CAF50),
      isRead: true,
      type: 'Sistema',
    ),
    NotificationItem(
      id: '8',
      title: 'Verificação Pendente',
      message: 'Você tem 3 verificações pendentes esperando análise.',
      time: '3 dias atrás',
      icon: Icons.pending,
      iconColor: Colors.grey,
      isRead: true,
      type: 'Verificações',
    ),
  ];

  List<NotificationItem> get _filteredNotifications {
    switch (_selectedFilter) {
      case 'Não lidas':
        return _notifications.where((n) => !n.isRead).toList();
      case 'Verificações':
        return _notifications.where((n) => n.type == 'Verificações').toList();
      case 'Sistema':
        return _notifications.where((n) => n.type == 'Sistema').toList();
      default:
        return _notifications;
    }
  }

  int get _unreadCount => _notifications.where((n) => !n.isRead).length;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            const Icon(Icons.verified, color: Color(0xFF4CAF50), size: 24),
            const SizedBox(width: 8),
            const Text(
              'Notificações',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (_unreadCount > 0) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '$_unreadCount',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
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
              if (value == 'mark_all_read') {
                _markAllAsRead();
              } else if (value == 'clear_all') {
                _showClearAllDialog();
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'mark_all_read',
                child: Row(
                  children: [
                    Icon(Icons.done_all, color: Color(0xFF4CAF50), size: 20),
                    SizedBox(width: 12),
                    Text('Marcar todas como lidas', style: TextStyle(color: Colors.white)),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'clear_all',
                child: Row(
                  children: [
                    Icon(Icons.delete_outline, color: Colors.red, size: 20),
                    SizedBox(width: 12),
                    Text('Limpar todas', style: TextStyle(color: Colors.white)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          _buildFilterChips(),
          Expanded(
            child: _filteredNotifications.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _filteredNotifications.length,
                    itemBuilder: (context, index) {
                      return _buildNotificationCard(_filteredNotifications[index]);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChips() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
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
                labelStyle: TextStyle(
                  color: isSelected ? Colors.black : Colors.white,
                  fontSize: 13,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
                backgroundColor: const Color(0xFF1A1A1A),
                selectedColor: const Color(0xFF4CAF50),
                checkmarkColor: Colors.black,
                side: BorderSide(
                  color: isSelected ? const Color(0xFF4CAF50) : Colors.grey.shade700,
                ),
                onSelected: (selected) {
                  setState(() {
                    _selectedFilter = filter;
                  });
                },
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildNotificationCard(NotificationItem notification) {
    return Dismissible(
      key: Key(notification.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.red.withOpacity(0.2),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(Icons.delete, color: Colors.red),
      ),
      onDismissed: (direction) {
        setState(() {
          _notifications.removeWhere((n) => n.id == notification.id);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Notificação removida'),
            backgroundColor: const Color(0xFF1A1A1A),
            behavior: SnackBarBehavior.floating,
            action: SnackBarAction(
              label: 'Desfazer',
              textColor: const Color(0xFF4CAF50),
              onPressed: () {
                setState(() {
                  _notifications.add(notification);
                });
              },
            ),
          ),
        );
      },
      child: GestureDetector(
        onTap: () => _markAsRead(notification),
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: notification.isRead
                ? const Color(0xFF1A1A1A)
                : const Color(0xFF1A1A1A).withOpacity(0.9),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: notification.isRead
                  ? Colors.grey.shade800
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
                child: Icon(
                  notification.icon,
                  color: notification.iconColor,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            notification.title,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: notification.isRead
                                  ? FontWeight.normal
                                  : FontWeight.bold,
                            ),
                          ),
                        ),
                        if (!notification.isRead)
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: Color(0xFF4CAF50),
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      notification.message,
                      style: TextStyle(
                        color: Colors.grey.shade400,
                        fontSize: 13,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      notification.time,
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 11,
                      ),
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

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.notifications_off_outlined,
            size: 64,
            color: Colors.grey.shade700,
          ),
          const SizedBox(height: 16),
          Text(
            'Nenhuma notificação',
            style: TextStyle(
              color: Colors.grey.shade400,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Você está em dia!',
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  void _markAsRead(NotificationItem notification) {
    if (!notification.isRead) {
      setState(() {
        final index = _notifications.indexWhere((n) => n.id == notification.id);
        if (index != -1) {
          _notifications[index] = notification.copyWith(isRead: true);
        }
      });
    }
  }

  void _markAllAsRead() {
    setState(() {
      _notifications = _notifications.map((n) => n.copyWith(isRead: true)).toList();
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle, color: Color(0xFF4CAF50)),
            SizedBox(width: 12),
            Text('Todas as notificações foram marcadas como lidas'),
          ],
        ),
        backgroundColor: Color(0xFF1A1A1A),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showClearAllDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Limpar Notificações', style: TextStyle(color: Colors.white)),
        content: const Text(
          'Deseja remover todas as notificações? Esta ação não pode ser desfeita.',
          style: TextStyle(color: Colors.grey),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancelar', style: TextStyle(color: Colors.grey.shade400)),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _notifications.clear();
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Row(
                    children: [
                      Icon(Icons.check_circle, color: Color(0xFF4CAF50)),
                      SizedBox(width: 12),
                      Text('Todas as notificações foram removidas'),
                    ],
                  ),
                  backgroundColor: Color(0xFF1A1A1A),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Limpar', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
