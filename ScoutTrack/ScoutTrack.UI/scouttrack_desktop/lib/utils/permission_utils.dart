import '../models/activity.dart';
import '../models/activity_registration.dart';
import '../models/post.dart';

class PermissionUtils {
  static bool canCreatePost(
    String? userRole,
    int? userId,
    Activity activity,
    List<ActivityRegistration> registrations,
  ) {
    if (userRole == null || userId == null) return false;

    if (activity.activityState != 'FinishedActivityState') return false;

    if (userRole == 'Admin') return false;

    if (userRole == 'Troop' && activity.troopId == userId) return true;

    if (userRole == 'Member') {
      final registration = registrations.firstWhere(
        (r) => r.memberId == userId && r.status == 3, // 3 = Completed status
        orElse: () => ActivityRegistration(
          id: 0,
          activityId: 0,
          memberId: 0,
          status: 0,
          registeredAt: DateTime.now(),
          notes: '',
          activityTitle: '',
          memberName: '',
        ),
      );
      return registration.id != 0;
    }

    return false;
  }

  static bool canEditPost(String? userRole, int? userId, Post post) {
    if (userRole == null || userId == null) return false;

    if (userRole == 'Admin') return true;

    return post.createdById == userId;
  }

  static bool canDeletePost(
    String? userRole,
    int? userId,
    Post post,
    Activity activity,
  ) {
    if (userRole == null || userId == null) return false;

    if (userRole == 'Admin') return true;

    if (userRole == 'Troop' && activity.troopId == userId) return true;

    return post.createdById == userId;
  }
}
