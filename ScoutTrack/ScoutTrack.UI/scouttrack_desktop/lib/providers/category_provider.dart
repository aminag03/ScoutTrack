import 'package:scouttrack_desktop/providers/base_provider.dart';
import 'package:scouttrack_desktop/models/category.dart';
import 'package:scouttrack_desktop/providers/auth_provider.dart';

class CategoryProvider extends BaseProvider<Category, dynamic> {
  CategoryProvider(AuthProvider? authProvider)
    : super(authProvider, 'category');

  @override
  Category fromJson(dynamic json) {
    return Category.fromJson(json);
  }
}
