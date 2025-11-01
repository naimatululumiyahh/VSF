import 'package:hive/hive.dart';
import '../models/article_model.dart';

class ArticleService {
  static final ArticleService _instance = ArticleService._internal();
  factory ArticleService() => _instance;
  ArticleService._internal();

  Future<List<ArticleModel>> getAllArticles() async {
    final articleBox = Hive.box<ArticleModel>('articles');
    return articleBox.values.toList();
  }

  Future<List<ArticleModel>> getArticlesByCategory(String category) async {
    final articleBox = Hive.box<ArticleModel>('articles');
    return articleBox.values
        .where((article) => article.category.toLowerCase() == category.toLowerCase())
        .toList();
  }

  Future<List<ArticleModel>> getRecentArticles({int limit = 5}) async {
    final articleBox = Hive.box<ArticleModel>('articles');
    final articles = articleBox.values.toList();
    
    articles.sort((a, b) => b.publishedAt.compareTo(a.publishedAt));
    
    return articles.take(limit).toList();
  }

  Future<ArticleModel?> getArticleById(String id) async {
    final articleBox = Hive.box<ArticleModel>('articles');
    
    for (var article in articleBox.values) {
      if (article.id == id) {
        return article;
      }
    }
    
    return null;
  }

  Future<void> addArticle(ArticleModel article) async {
    final articleBox = Hive.box<ArticleModel>('articles');
    await articleBox.add(article);
  }

  Future<List<String>> getUniqueCategories() async {
    final articleBox = Hive.box<ArticleModel>('articles');
    final categories = articleBox.values.map((a) => a.category).toSet().toList();
    categories.sort();
    return categories;
  }
}