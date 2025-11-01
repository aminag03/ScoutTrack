import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:scouttrack_mobile/providers/base_provider.dart';
import 'package:scouttrack_mobile/models/like.dart';
import 'package:scouttrack_mobile/providers/auth_provider.dart';
import 'package:scouttrack_mobile/providers/member_provider.dart';
import 'package:scouttrack_mobile/providers/troop_provider.dart';

class LikeProvider extends BaseProvider<Like, dynamic> {
  LikeProvider(AuthProvider? authProvider) : super(authProvider, 'Like');

  @override
  Like fromJson(dynamic json) {
    return Like.fromJson(json);
  }

  Future<List<Like>> getByPost(int postId) async {
    return await handleWithRefresh(() async {
      final uri = Uri.parse(
        "${BaseProvider.baseUrl}$endpoint/post/$postId",
      );

      final response = await http.get(uri, headers: await createHeaders());

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        List<dynamic> items;
        if (data is List) {
          items = data;
        } else if (data['items'] != null) {
          items = data['items'] as List<dynamic>;
        } else {
          items = [];
        }

        final likes = <Like>[];

        for (final item in items) {
          final like = Like.fromJson(item);

          if (like.createdByName == 'Unknown User' && like.createdById > 0) {
            try {
              try {
                final memberProvider = MemberProvider(authProvider);
                final member = await memberProvider.getById(like.createdById);

                final updatedLike = Like(
                  id: like.id,
                  likedAt: like.likedAt,
                  postId: like.postId,
                  createdById: like.createdById,
                  createdByName: '${member.firstName} ${member.lastName}',
                  createdByTroopName: member.troopName,
                  createdByAvatarUrl: member.profilePictureUrl,
                  canUnlike: like.canUnlike,
                );
                likes.add(updatedLike);
                continue;
              } catch (memberError) {
                print('LikeProvider: Not a member, trying troop: $memberError');
              }

              try {
                final troopProvider = TroopProvider(authProvider);
                final troop = await troopProvider.getById(like.createdById);

                final updatedLike = Like(
                  id: like.id,
                  likedAt: like.likedAt,
                  postId: like.postId,
                  createdById: like.createdById,
                  createdByName: troop.name,
                  createdByTroopName: troop.name,
                  createdByAvatarUrl: troop.logoUrl,
                  canUnlike: like.canUnlike,
                );
                likes.add(updatedLike);
                continue;
              } catch (troopError) {
                print('LikeProvider: Not a troop either: $troopError');
              }
              likes.add(like);
            } catch (e) {
              print('LikeProvider: Error fetching user info: $e');
              likes.add(like);
            }
          } else {
            likes.add(like);
          }
        }

        return likes;
      } else if (response.statusCode == 500) {
        return [];
      } else {
        final error = jsonDecode(response.body);
        throw Exception(
          error['title'] ?? 'Greška prilikom učitavanja lajkova.',
        );
      }
    });
  }

  Future<Like> likePost(int postId) async {
    return await handleWithRefresh(() async {
      final uri = Uri.parse(
        "${BaseProvider.baseUrl}$endpoint/post/$postId",
      );

      final response = await http.post(uri, headers: await createHeaders());

      if (response.statusCode == 200) {
        if (response.body.isEmpty) {
          return Like(
            id: 0,
            likedAt: DateTime.now(),
            postId: postId,
            createdById: 0,
            createdByName: 'Current User',
            canUnlike: true,
          );
        }
        return Like.fromJson(jsonDecode(response.body));
      } else {
        if (response.body.isEmpty) {
          throw Exception('Greška prilikom lajkanja objave.');
        }
        final error = jsonDecode(response.body);
        throw Exception(error['message'] ?? 'Greška prilikom lajkanja objave.');
      }
    });
  }

  Future<bool> unlikePost(int postId) async {
    return await handleWithRefresh(() async {
      final uri = Uri.parse(
        "${BaseProvider.baseUrl}$endpoint/post/$postId",
      );

      final response = await http.delete(uri, headers: await createHeaders());

      if (response.statusCode == 200 || response.statusCode == 204) {
        return true;
      } else {
        if (response.body.isEmpty) {
          throw Exception('Greška prilikom uklanjanja lajka.');
        }
        final error = jsonDecode(response.body);
        throw Exception(
          error['message'] ?? 'Greška prilikom uklanjanja lajka.',
        );
      }
    });
  }
}
