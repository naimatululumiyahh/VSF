import 'package:hive/hive.dart';

part 'article_model.g.dart';

@HiveType(typeId: 5)
class ArticleModel extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String title;

  @HiveField(2)
  String imageUrl;

  @HiveField(3)
  String externalLink; // Link ke artikel asli (akan dibuka di browser)

  @HiveField(4)
  String? summary; // Optional: ringkasan singkat untuk preview

  @HiveField(5)
  String category; // "Kemanusiaan", "Pendidikan", "Lingkungan", "Kesehatan", "Sosial"

  @HiveField(6)
  DateTime publishedAt;

  ArticleModel({
    required this.id,
    required this.title,
    required this.imageUrl,
    required this.externalLink,
    this.summary,
    required this.category,
    DateTime? publishedAt,
  }) : publishedAt = publishedAt ?? DateTime.now();

  // Format tanggal untuk display (relative time)
  String get formattedDate {
    final now = DateTime.now();
    final difference = now.difference(publishedAt);

    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        if (difference.inMinutes == 0) {
          return 'Baru saja';
        }
        return '${difference.inMinutes} menit lalu';
      }
      return '${difference.inHours} jam lalu';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} hari lalu';
    } else if (difference.inDays < 30) {
      final weeks = (difference.inDays / 7).floor();
      return '$weeks minggu lalu';
    } else {
      return '${publishedAt.day}/${publishedAt.month}/${publishedAt.year}';
    }
  }

  // Format tanggal absolut
  String get absoluteDate {
    final months = [
      'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
      'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
    ];
    
    return '${publishedAt.day} ${months[publishedAt.month - 1]} ${publishedAt.year}';
  }

  // Badge warna category untuk UI
  String get categoryColor {
    switch (category.toLowerCase()) {
      case 'pendidikan':
        return 'blue';
      case 'lingkungan':
        return 'green';
      case 'kesehatan':
        return 'red';
      case 'sosial':
        return 'orange';
      case 'kemanusiaan':
        return 'purple';
      default:
        return 'grey';
    }
  }

  // Truncate summary untuk card preview
  String get shortSummary {
    if (summary == null || summary!.isEmpty) return '';
    if (summary!.length <= 100) return summary!;
    return '${summary!.substring(0, 97)}...';
  }

  // Untuk debugging
  @override
  String toString() {
    return 'ArticleModel(id: $id, title: $title, category: $category)';
  }
}