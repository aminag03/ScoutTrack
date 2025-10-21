import 'dart:async';
import 'package:signalr_netcore/signalr_client.dart';

class NotificationService {
  late HubConnection _hubConnection;
  final String baseUrl;
  String? accessToken;

  NotificationService({required this.baseUrl, this.accessToken});

  Function(
    String message,
    int senderId,
    DateTime createdAt,
    String? activityId,
    String? notificationType,
  )?
  onNotificationReceived;
  Function()? onConnected;
  Function()? onDisconnected;
  Function(String error)? onError;

  bool get isConnected {
    try {
      return _hubConnection.state == HubConnectionState.Connected;
    } catch (e) {
      print('⚠️ Error checking connection state: $e');
      return false;
    }
  }

  Future<void> connect(int userId) async {
    try {
      final cleanBaseUrl = baseUrl.endsWith('/')
          ? baseUrl.substring(0, baseUrl.length - 1)
          : baseUrl;
      final url = '$cleanBaseUrl/notificationhub';
      print('🔌 Attempting to connect to SignalR: $url');
      print('🔑 User ID: $userId');
      print('🔑 Has access token: ${accessToken != null}');
      print(
        '🔑 Access token preview: ${accessToken != null ? accessToken!.substring(0, 20) + "..." : "null"}',
      );

      _hubConnection = HubConnectionBuilder()
          .withUrl(
            url,
            options: HttpConnectionOptions(
              accessTokenFactory: () async {
                print('🔑 SignalR requesting access token...');
                print('🔑 Token available: ${accessToken != null}');
                if (accessToken != null) {
                  print(
                    '🔑 Returning token: ${accessToken!.substring(0, 20)}...',
                  );
                  return accessToken!;
                } else {
                  print('❌ No access token available for SignalR');
                  throw Exception('No access token available');
                }
              },
              skipNegotiation: false,
            ),
          )
          .build();

      _hubConnection.on('ReceiveNotification', (arguments) {
        print('📬 Received SignalR notification: $arguments');
        print('📬 Arguments type: ${arguments.runtimeType}');
        print(
          '📬 Arguments length: ${arguments != null ? (arguments as List).length : 0}',
        );

        if (arguments != null && (arguments as List).isNotEmpty) {
          try {
            final notificationData = arguments[0] as Map<String, dynamic>;
            print('📬 Notification data: $notificationData');

            final message = notificationData['message'] as String;
            final senderId = notificationData['senderId'] as int;
            final createdAtStr = notificationData['createdAt'] as String;
            final createdAt = DateTime.parse(createdAtStr);
            final activityId = notificationData['activityId'] as String?;
            final notificationType =
                notificationData['notificationType'] as String?;

            print(
              '📬 Parsed notification: message=$message, senderId=$senderId, type=$notificationType',
            );

            print('📬 Calling onNotificationReceived callback...');
            onNotificationReceived?.call(
              message,
              senderId,
              createdAt,
              activityId,
              notificationType,
            );
            print('✅ onNotificationReceived callback executed');
          } catch (e, stackTrace) {
            print('❌ Error parsing notification: $e');
            print('Stack trace: $stackTrace');
          }
        } else {
          print('⚠️ Arguments is null or empty');
        }
      });

      _hubConnection.onclose(({error}) {
        onDisconnected?.call();
        print('SignalR connection closed: $error');
      });

      print('🚀 Starting SignalR connection...');
      await _hubConnection.start();
      print('✅ SignalR connection started successfully');

      print('👥 Joining user group: user_$userId');
      await _hubConnection.invoke('JoinUserGroup', args: [userId]);
      print('✅ Joined user group successfully');

      onConnected?.call();
      print('🎉 Connected to SignalR notification hub for user $userId');
    } catch (e, stackTrace) {
      print('❌ Error connecting to SignalR: $e');
      print('Stack trace: $stackTrace');

      if (e.toString().contains('401') ||
          e.toString().contains('Unauthorized')) {
        print('🔐 Authentication error detected - token may be expired');
        onError?.call('Authentication failed - token may be expired');
      } else {
        onError?.call(e.toString());
      }
      rethrow;
    }
  }

  Future<void> disconnect() async {
    try {
      if (_hubConnection.state == HubConnectionState.Connected) {
        await _hubConnection.stop();
        print('Disconnected from SignalR notification hub');
      }
    } catch (e) {
      print('Error disconnecting from SignalR: $e');
    }
  }

  Future<void> updateToken(String newToken) async {
    try {
      print('🔄 Updating SignalR access token...');

      final wasConnected = isConnected;

      accessToken = newToken;
      print('✅ SignalR access token updated');

      if (wasConnected) {
        print('🔄 Reconnecting with new token...');
        await disconnect();
        // Note: The caller should handle reconnection with the new token
        // by calling connect() again with the same userId
      }
    } catch (e) {
      print('❌ Error updating SignalR token: $e');
      onError?.call('Failed to update token: $e');
    }
  }

  Future<void> updateTokenAndReconnect(String newToken, int userId) async {
    try {
      print('🔄 Updating SignalR access token and reconnecting...');

      final wasConnected = isConnected;

      accessToken = newToken;
      print('✅ SignalR access token updated');

      if (wasConnected) {
        print('🔄 Reconnecting with new token...');
        await disconnect();
        await connect(userId);
        print('✅ Reconnected with new token');
      } else {
        print('ℹ️ SignalR was not connected, skipping reconnection');
      }
    } catch (e) {
      print('❌ Error updating SignalR token and reconnecting: $e');
      onError?.call('Failed to update token and reconnect: $e');
      rethrow;
    }
  }
}
