import 'package:admin/models/category_model.dart';


class CategoryCache {
  static final CategoryCache _instance = CategoryCache._internal();

  factory CategoryCache() => _instance;

  CategoryCache._internal();

  List<Category> cachedCategories = [];
  bool isLoaded = false;

  void setCategories(List<Category> categories) {
    cachedCategories = categories;
    isLoaded = true;
  }

  List<Category> getCategories() => cachedCategories;
  bool get hasData => isLoaded;
}
