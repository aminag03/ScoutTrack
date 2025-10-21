import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../layouts/master_screen.dart';
import '../providers/auth_provider.dart';
import '../providers/notification_provider.dart';
import '../models/notification.dart' as notification_model;
import '../models/search_result.dart';
import '../utils/snackbar_utils.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  SearchResult<notification_model.Notification>? _notifications;
  List<notification_model.Notification> _filteredNotifications = [];
  bool _loading = false;
  String? _error;
  int _unreadCount = 0;
  int currentPage = 0;
  int pageSize = 20;
  int totalPages = 1;

  String _searchQuery = '';
  bool _showOnlyUnread = false;
  final TextEditingController _searchController = TextEditingController();

  late NotificationProvider _notificationProvider;
  late AuthProvider _authProvider;
  final ScrollController _scrollController = ScrollController();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _authProvider = Provider.of<AuthProvider>(context, listen: false);
    _notificationProvider = NotificationProvider(_authProvider);

    _setupNotificationCallback();
    _loadInitialData();
  }

  void _setupNotificationCallback() async {
    print('🔧 Setting up notification screen callback...');
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
    print('✅ Notification screen callback set up');

    await _authProvider.ensureSignalRConnection();

    final notificationService = _authProvider.notificationService;
    if (notificationService != null) {
      print('📡 SignalR connection status: ${notificationService.isConnected}');
    } else {
      print('⚠️ Notification service not initialized');
    }
  }

  @override
  void didUpdateWidget(NotificationsScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    _setupNotificationCallback();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();

    _authProvider.onNotificationReceived = null;

    super.dispose();
  }

  Future<void> _loadInitialData() async {
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
    print('📥 Call stack: ${StackTrace.current}');

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
          "Page": page ?? currentPage,
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
          _applyFilters();
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

  void _applyFilters() {
    if (_notifications?.items == null) {
      _filteredNotifications = [];
      return;
    }

    var filtered = List<notification_model.Notification>.from(
      _notifications!.items!,
    );

    if (_showOnlyUnread) {
      filtered = filtered.where((n) => !n.isRead).toList();
    }

    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((n) {
        final messageLower = n.message.toLowerCase();
        final senderLower = n.senderUsername.toLowerCase();
        final queryLower = _searchQuery.toLowerCase();
        return messageLower.contains(queryLower) ||
            senderLower.contains(queryLower);
      }).toList();
    }

    setState(() {
      _filteredNotifications = filtered;
    });
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
      if (mounted) {
        showSuccessSnackbar(context, 'Obavještenje je označeno kao pročitano.');
      }
    } catch (e) {
      if (mounted) {
        showErrorSnackbar(context, e);
      }
    }
  }

  Future<void> _markAllNotificationsAsRead() async {
    try {
      final confirm = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Označavanje svih obavještenja'),
          content: const Text(
            'Jeste li sigurni da želite označiti sva obavještenja kao pročitana?',
          ),
          contentPadding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
          actionsPadding: const EdgeInsets.all(16),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
              child: const Text('Otkaži'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
              child: const Text('Označi sve'),
            ),
          ],
        ),
      );

      if (confirm == true) {
        await _notificationProvider.markAllAsRead();
        await _loadNotifications();
        await _loadUnreadCount();
        if (mounted) {
          showSuccessSnackbar(
            context,
            'Sva obavještenja su označena kao pročitana.',
          );
        }
      }
    } catch (e) {
      if (mounted) {
        showErrorSnackbar(context, e);
      }
    }
  }

  Future<void> _deleteNotification(int notificationId) async {
    try {
      final confirm = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Brisanje obavještenja'),
          content: const Text(
            'Jeste li sigurni da želite obrisati ovo obavještenje?',
          ),
          contentPadding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
          actionsPadding: const EdgeInsets.all(16),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
              child: const Text('Otkaži'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
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
          title: const Text('Upozorenje'),
          content: const Text(
            'Jeste li sigurni da želite obrisati SVA obavještenja? Ova akcija se ne može poništiti i trajno će ukloniti sva vaša obavještenja.',
          ),
          contentPadding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
          actionsPadding: const EdgeInsets.all(16),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
              child: const Text('Otkaži'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
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

  void _onSearch(String query) {
    setState(() {
      _searchQuery = query;
      _applyFilters();
    });
  }

  void _toggleUnreadFilter() {
    setState(() {
      _showOnlyUnread = !_showOnlyUnread;
      _applyFilters();
    });
  }

  void _clearFilters() {
    setState(() {
      _searchQuery = '';
      _showOnlyUnread = false;
      _searchController.clear();
      _applyFilters();
    });
  }

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _setupNotificationCallback();
      }
    });

    return MasterScreen(
      headerTitle: 'Obavještenja',
      selectedIndex: 2,
      body: RefreshIndicator(
        onRefresh: _loadInitialData,
        child: Column(
          children: [
            _buildSearchAndFilterSection(),
            _buildActionButtons(),
            if (_unreadCount > 0) _buildUnreadBadge(),
            Expanded(child: _buildNotificationsList()),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchAndFilterSection() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      color: Colors.grey.shade50,
      child: Column(
        children: [
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Pretraži obavještenja...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                        _onSearch('');
                      },
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              filled: true,
              fillColor: Colors.white,
            ),
            onChanged: _onSearch,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: FilterChip(
                  label: Text(
                    _showOnlyUnread
                        ? 'Samo nepročitana ($_unreadCount)'
                        : 'Sva obavještenja',
                  ),
                  selected: _showOnlyUnread,
                  onSelected: (_) => _toggleUnreadFilter(),
                  avatar: Icon(
                    _showOnlyUnread ? Icons.mail_outline : Icons.all_inclusive,
                    size: 18,
                  ),
                ),
              ),
              if (_searchQuery.isNotEmpty || _showOnlyUnread) ...[
                const SizedBox(width: 8),
                TextButton.icon(
                  onPressed: _clearFilters,
                  icon: const Icon(Icons.clear_all, size: 18),
                  label: const Text('Očisti'),
                  style: TextButton.styleFrom(foregroundColor: Colors.red),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    final hasNotifications = _notifications?.items?.isNotEmpty ?? false;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton(
              onPressed: _unreadCount > 0 ? _markAllNotificationsAsRead : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Colors.white,
                disabledBackgroundColor: Colors.grey.shade300,
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Icon(Icons.done_all, size: 18),
                  SizedBox(width: 6),
                  Flexible(
                    child: Text(
                      'Označi sve kao pročitano',
                      style: TextStyle(fontSize: 13),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: ElevatedButton(
              onPressed: hasNotifications ? _deleteAllNotifications : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                disabledBackgroundColor: Colors.grey.shade300,
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Icon(Icons.delete_sweep, size: 18),
                  SizedBox(width: 6),
                  Flexible(
                    child: Text(
                      'Obriši sve',
                      style: TextStyle(fontSize: 13),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUnreadBadge() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.info_outline,
            color: Theme.of(context).colorScheme.primary,
            size: 18,
          ),
          const SizedBox(width: 8),
          Text(
            '$_unreadCount ${_getNotificationCountText(_unreadCount)}',
            style: TextStyle(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
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
              'Greška pri učitavanju',
              style: const TextStyle(
                color: Colors.red,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                _error!,
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey.shade700),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () => _loadNotifications(),
              icon: const Icon(Icons.refresh),
              label: const Text('Pokušaj ponovo'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      );
    }

    if (_notifications == null ||
        _notifications!.items == null ||
        _notifications!.items!.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.notifications_none,
              size: 80,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              'Nema obavještenja',
              style: TextStyle(
                fontSize: 20,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Kada dobijete obavještenja,\npojavit će se ovdje',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
            ),
          ],
        ),
      );
    }

    if (_filteredNotifications.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 80, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(
              'Nema rezultata',
              style: TextStyle(
                fontSize: 20,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Pokušajte promijeniti filter\nili upit pretrage',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
            ),
            const SizedBox(height: 16),
            TextButton.icon(
              onPressed: _clearFilters,
              icon: const Icon(Icons.clear_all),
              label: const Text('Očisti filtere'),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(16),
      itemCount: _filteredNotifications.length + 1,
      itemBuilder: (context, index) {
        if (index == _filteredNotifications.length) {
          return _buildPaginationControls();
        }
        final notification = _filteredNotifications[index];
        return _buildNotificationItem(notification);
      },
    );
  }

  Widget _buildNotificationItem(notification_model.Notification notification) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: notification.isRead
            ? Colors.white
            : Theme.of(context).colorScheme.primary.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: notification.isRead
              ? Colors.grey.shade300
              : Theme.of(context).colorScheme.primary.withOpacity(0.3),
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
          ListTile(
            leading: CircleAvatar(
              backgroundColor: notification.isRead
                  ? Colors.grey.shade300
                  : Theme.of(context).colorScheme.primary,
              child: Icon(
                notification.isRead
                    ? Icons.notifications_none
                    : Icons.notifications_active,
                color: notification.isRead
                    ? Colors.grey.shade600
                    : Colors.white,
                size: 22,
              ),
            ),
            title: Text(
              notification.senderUsername.isNotEmpty
                  ? notification.senderUsername
                  : 'Sistem',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: notification.isRead
                    ? Colors.grey.shade700
                    : Colors.black87,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text(
                  notification.message,
                  style: TextStyle(
                    fontSize: 14,
                    color: notification.isRead
                        ? Colors.grey.shade600
                        : Colors.black87,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.access_time,
                      size: 14,
                      color: Colors.grey.shade500,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _formatNotificationDate(notification.createdAt),
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade500,
                      ),
                    ),
                    if (!notification.isRead) ...[
                      const SizedBox(width: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text(
                          'Novo',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
            trailing: PopupMenuButton<String>(
              icon: Icon(Icons.more_vert, color: Colors.grey.shade600),
              onSelected: (value) {
                if (value == 'read' && !notification.isRead) {
                  _markNotificationAsRead(notification.id);
                } else if (value == 'delete') {
                  _deleteNotification(notification.id);
                }
              },
              itemBuilder: (context) => [
                if (!notification.isRead)
                  const PopupMenuItem(
                    value: 'read',
                    child: Row(
                      children: [
                        Icon(Icons.check_circle_outline, size: 20),
                        SizedBox(width: 8),
                        Text('Označi kao pročitano'),
                      ],
                    ),
                  ),
                const PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete_outline, size: 20, color: Colors.red),
                      SizedBox(width: 8),
                      Text('Obriši', style: TextStyle(color: Colors.red)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaginationControls() {
    if (totalPages <= 1) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.only(top: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: currentPage > 0
                ? () => _loadNotifications(page: currentPage - 1)
                : null,
          ),
          const SizedBox(width: 8),
          Text(
            'Stranica ${currentPage + 1} od $totalPages',
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: currentPage < totalPages - 1
                ? () => _loadNotifications(page: currentPage + 1)
                : null,
          ),
        ],
      ),
    );
  }

  String _formatNotificationDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.isNegative) {
      return '${date.day}.${date.month}.${date.year}.';
    }

    final months = (now.year - date.year) * 12 + (now.month - date.month);
    final years = now.year - date.year;

    if (years >= 2) {
      return 'Prije ${years} god.';
    } else if (months >= 2) {
      return 'Prije ${months} mj.';
    } else if (difference.inDays > 0) {
      return 'Prije ${difference.inDays}d';
    } else if (difference.inHours > 0) {
      return 'Prije ${difference.inHours}h';
    } else if (difference.inMinutes > 0) {
      return 'Prije ${difference.inMinutes}m';
    } else {
      return 'Sada';
    }
  }

  String _getNotificationCountText(int count) {
    final lastDigit = count % 10;
    final lastTwoDigits = count % 100;

    if (lastTwoDigits >= 11 && lastTwoDigits <= 14) {
      return 'nepročitanih obavještenja';
    } else if (lastDigit == 1) {
      return 'nepročitano obavještenje';
    } else if (lastDigit >= 2 && lastDigit <= 4) {
      return 'nepročitana obavještenja';
    } else {
      return 'nepročitanih obavještenja';
    }
  }
}
