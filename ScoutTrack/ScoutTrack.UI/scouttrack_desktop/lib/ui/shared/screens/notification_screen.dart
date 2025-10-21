import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:scouttrack_desktop/ui/shared/layouts/master_screen.dart';
import 'package:scouttrack_desktop/providers/auth_provider.dart';
import 'package:scouttrack_desktop/providers/notification_provider.dart';
import 'package:scouttrack_desktop/models/notification.dart'
    as notification_model;
import 'package:scouttrack_desktop/models/search_result.dart';
import 'package:scouttrack_desktop/utils/error_utils.dart';
import 'package:scouttrack_desktop/ui/shared/widgets/pagination_controls.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  SearchResult<notification_model.Notification>? _notifications;
  bool _loading = false;
  String? _error;
  String? _role;
  int _unreadCount = 0;
  int currentPage = 1;
  int pageSize = 10;
  int totalPages = 1;

  late NotificationProvider _notificationProvider;
  late AuthProvider _authProvider;
  final ScrollController _scrollController = ScrollController();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _authProvider = Provider.of<AuthProvider>(context, listen: false);
    _notificationProvider = NotificationProvider(_authProvider);

    _authProvider.onNotificationReceived = () {
      print(
        '🔔🔔🔔 Real-time notification received in notification screen 🔔🔔🔔',
      );
      print('🔔 Widget mounted: $mounted');
      print('🔔 Current loading state: $_loading');
      print(
        '🔔 Current notifications count: ${_notifications?.items?.length ?? 0}',
      );

      if (mounted) {
        print(
          '✅ Widget is mounted, calling _loadNotifications with forceRefresh=true',
        );
        _loadNotifications(forceRefresh: true);
        _loadUnreadCount();
      } else {
        print('❌ Widget not mounted, skipping refresh');
      }
    };

    final notificationService = _authProvider.notificationService;
    if (notificationService != null) {
      print('📡 SignalR connection status: ${notificationService.isConnected}');
    } else {
      print('⚠️ Notification service not initialized');
    }

    _loadInitialData();
  }

  @override
  void dispose() {
    _scrollController.dispose();

    _authProvider.onNotificationReceived = null;

    super.dispose();
  }

  Future<void> _loadInitialData() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final role = await authProvider.getUserRole();
    if (!mounted) return;
    setState(() {
      _role = role;
    });
    await _loadNotifications();
    await _loadUnreadCount();
  }

  Future<void> _loadNotifications({
    int? page,
    bool forceRefresh = false,
  }) async {
    print(
      '📥 _loadNotifications called: forceRefresh=$forceRefresh, _loading=$_loading',
    );

    if (_loading && !forceRefresh) {
      print('⏭️ Skipping load - already loading and not force refresh');
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      print('📥 Fetching notifications from API...');
      final result = await _notificationProvider.getMyNotifications(
        filter: {
          "Page": ((page ?? currentPage) - 1),
          "PageSize": pageSize,
          "OrderBy": "-createdAt",
          "IncludeTotalCount": true,
        },
      );

      print('📥 Received ${result.items?.length ?? 0} notifications from API');
      print('📥 Total count: ${result.totalCount ?? 0}');

      if (mounted) {
        setState(() {
          _notifications = result;
          currentPage = page ?? currentPage;
          totalPages = ((result.totalCount ?? 0) / pageSize).ceil();
          if (totalPages == 0) totalPages = 1;
          if (currentPage > totalPages) currentPage = totalPages;
          if (currentPage < 1) currentPage = 1;
        });
        print('✅ Notifications updated in state');
      }
    } catch (e) {
      print('❌ Error loading notifications: $e');
      if (mounted) {
        setState(() {
          _error = e.toString();
          _notifications = null;
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
        print('✅ Loading state set to false');
      }
    }
  }

  Future<void> _loadUnreadCount() async {
    try {
      final count = await _notificationProvider.getUnreadCount();
      if (mounted) {
        setState(() {
          _unreadCount = count;
        });
      }
    } catch (e) {
      print('Error loading unread count: $e');
    }
  }

  Future<void> _markNotificationAsRead(int notificationId) async {
    try {
      await _notificationProvider.markAsRead(notificationId);
      await _loadNotifications();
      await _loadUnreadCount();
    } catch (e) {
      showErrorSnackbar(context, e);
    }
  }

  Future<void> _markAllNotificationsAsRead() async {
    try {
      await _notificationProvider.markAllAsRead();
      await _loadNotifications();
      await _loadUnreadCount();
    } catch (e) {
      showErrorSnackbar(context, e);
    }
  }

  Future<void> _deleteNotification(int notificationId) async {
    try {
      final confirm = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Brisanje obavještenja'),
          content: const Text(
            'Jeste li sigurni da želite obrisati ovo obavještenje? Ova akcija se ne može poništiti.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Otkaži'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
              child: const Text('Obriši'),
            ),
          ],
        ),
      );

      if (confirm == true) {
        await _notificationProvider.deleteNotification(notificationId);
        await _loadNotifications();
        await _loadUnreadCount();

        if (mounted) {
          showSuccessSnackbar(context, 'Obavještenje je uspješno obrisano.');
        }
      }
    } catch (e) {
      if (mounted) {
        showErrorSnackbar(context, e);
      }
    }
  }

  Future<void> _deleteAllNotifications() async {
    try {
      final confirm = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Brisanje svih obavještenja'),
          content: const Text(
            'Jeste li sigurni da želite obrisati SVA obavještenja? Ova akcija se ne može poništiti i obrisat će sva vaša obavještenja.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Otkaži'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
              child: const Text('Obriši sve'),
            ),
          ],
        ),
      );

      if (confirm == true) {
        await _notificationProvider.deleteAllNotifications();
        await _loadNotifications();
        await _loadUnreadCount();

        if (mounted) {
          showSuccessSnackbar(
            context,
            'Sva obavještenja su uspješno obrisana.',
          );
        }
      }
    } catch (e) {
      if (mounted) {
        showErrorSnackbar(context, e);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return MasterScreen(
      role: _role ?? '',
      selectedMenu: 'Obavještenja',
      child: Container(
        color: Theme.of(context).colorScheme.surface,
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Row(
                  children: [
                    if (_unreadCount > 0) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade600,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '$_unreadCount nepročitanih',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                    ],
                    ElevatedButton.icon(
                      onPressed: _unreadCount > 0
                          ? _markAllNotificationsAsRead
                          : null,
                      icon: const Icon(Icons.done_all),
                      label: const Text('Označi sva kao pročitana'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton.icon(
                      onPressed: (_notifications?.items?.isNotEmpty ?? false)
                          ? _deleteAllNotifications
                          : null,
                      icon: const Icon(Icons.delete_sweep),
                      label: const Text('Obriši sva obavještenja'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 24),
            if (_notifications != null)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.green.shade200),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: Colors.green.shade700,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Prikazano ${_notifications!.items?.length ?? 0} od ukupno ${_notifications!.totalCount ?? 0} obavještenja',
                      style: TextStyle(
                        color: Colors.green.shade700,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            if (_notifications != null) const SizedBox(height: 16),
            Expanded(child: _buildNotificationsList()),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationsList() {
    if (_loading && _notifications == null) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              'Greška pri učitavanju: $_error',
              style: const TextStyle(color: Colors.red, fontSize: 16),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
              onPressed: () => _loadNotifications(),
              child: const Text('Pokušaj ponovo'),
            ),
          ],
        ),
      );
    }

    if (_notifications == null ||
        _notifications!.items == null ||
        _notifications!.items!.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.notifications_none, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'Nema obavještenja',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Kada dobijete obavještenja, pojavit će se ovdje',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        Expanded(
          child: Scrollbar(
            controller: _scrollController,
            thumbVisibility: true,
            trackVisibility: true,
            child: ListView.builder(
              controller: _scrollController,
              itemCount: _notifications!.items!.length,
              itemBuilder: (context, index) {
                final notification = _notifications!.items![index];
                return _buildNotificationItem(notification);
              },
            ),
          ),
        ),
        const SizedBox(height: 8),
        PaginationControls(
          currentPage: currentPage,
          totalPages: totalPages,
          totalCount: _notifications?.totalCount ?? 0,
          onPageChanged: (page) => _loadNotifications(page: page),
        ),
      ],
    );
  }

  Widget _buildNotificationItem(notification_model.Notification notification) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: notification.isRead ? Colors.white : Colors.blue.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: notification.isRead
              ? Colors.grey.shade300
              : Colors.blue.shade300,
          width: notification.isRead ? 1 : 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Row(
                  children: [
                    Icon(
                      Icons.person,
                      size: 20,
                      color: notification.isRead
                          ? Colors.grey.shade600
                          : Colors.blue.shade700,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      notification.senderUsername.isNotEmpty
                          ? notification.senderUsername
                          : 'Sistem',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: notification.isRead
                            ? Colors.grey.shade700
                            : Colors.blue.shade800,
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                children: [
                  Text(
                    _formatNotificationDate(notification.createdAt),
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),
                  if (!notification.isRead) ...[
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(Icons.check_circle_outline, size: 20),
                      onPressed: () => _markNotificationAsRead(notification.id),
                      tooltip: 'Označi kao pročitano',
                      color: Colors.blue.shade600,
                    ),
                  ],
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.delete_outline, size: 20),
                    onPressed: () => _deleteNotification(notification.id),
                    tooltip: 'Obriši obavještenje',
                    color: Colors.red.shade600,
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            notification.message,
            style: TextStyle(
              fontSize: 15,
              color: notification.isRead
                  ? Colors.grey.shade800
                  : Colors.black87,
              height: 1.4,
            ),
          ),
          if (!notification.isRead) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.blue.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                'Nepročitano',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _formatNotificationDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 0) {
      return '${difference.inDays}d';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m';
    } else {
      return 'Sada';
    }
  }
}
