import 'package:hive/hive.dart';
import 'event_location.dart';

part 'event_model.g.dart';

@HiveType(typeId: 4)
class EventModel extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String title;

  @HiveField(2)
  String description;

  @HiveField(3)
  String? imageUrl;

  // Organizer info
  @HiveField(4)
  String organizerId;

  @HiveField(5)
  String organizerName;

  @HiveField(6)
  String? organizerImageUrl;

  // Location (detail)
  @HiveField(7)
  EventLocation location;

  // Time (UTC untuk consistency)
  @HiveField(8)
  DateTime eventStartTime;

  @HiveField(9)
  DateTime eventEndTime;

  // Volunteer & Donation
  @HiveField(10)
  int targetVolunteerCount;

  @HiveField(11)
  int currentVolunteerCount;

  @HiveField(12)
  int participationFeeIdr; // Harga partisipasi (bisa 0 untuk gratis)

  // Category
  @HiveField(13)
  String category; // "Pendidikan", "Anak-anak", "Lingkungan", "Kesehatan", "Sosial"

  // Status
  @HiveField(14)
  bool isActive;

  @HiveField(15)
  DateTime createdAt;

  // List volunteer IDs yang sudah daftar
  @HiveField(16)
  List<String> registeredVolunteerIds;

  EventModel({
    required this.id,
    required this.title,
    required this.description,
    this.imageUrl,
    required this.organizerId,
    required this.organizerName,
    this.organizerImageUrl,
    required this.location,
    required this.eventStartTime,
    required this.eventEndTime,
    required this.targetVolunteerCount,
    this.currentVolunteerCount = 0,
    this.participationFeeIdr = 0,
    required this.category,
    this.isActive = true,
    DateTime? createdAt,
    List<String>? registeredVolunteerIds,
  })  : createdAt = createdAt ?? DateTime.now(),
        registeredVolunteerIds = registeredVolunteerIds ?? [];

  // ==================== GETTERS ====================

  // Apakah event sudah penuh?
  bool get isFull => currentVolunteerCount >= targetVolunteerCount;

  // Apakah event sudah lewat?
  bool get isPast => DateTime.now().isAfter(eventEndTime);

  // Apakah event sedang berlangsung?
  bool get isOngoing {
    final now = DateTime.now();
    return now.isAfter(eventStartTime) && now.isBefore(eventEndTime);
  }

  // Apakah event akan datang?
  bool get isUpcoming => DateTime.now().isBefore(eventStartTime);

  // Persentase volunteer terdaftar
  double get volunteerPercentage {
    if (targetVolunteerCount == 0) return 0;
    return (currentVolunteerCount / targetVolunteerCount) * 100;
  }

  // Sisa slot volunteer
  int get remainingSlots => targetVolunteerCount - currentVolunteerCount;

  // Apakah gratis?
  bool get isFree => participationFeeIdr == 0;

  // Format harga untuk display
  String get formattedPrice {
    if (isFree) return 'Gratis';
    return 'Rp ${participationFeeIdr.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), 
      (Match m) => '${m[1]}.'
    )}';
  }

  // Status event untuk display
  String get eventStatus {
    if (isPast) return 'Selesai';
    if (isOngoing) return 'Sedang Berlangsung';
    if (isFull) return 'Penuh';
    return 'Tersedia';
  }

  // Warna status untuk UI
  String get statusColor {
    if (isPast) return 'grey';
    if (isOngoing) return 'green';
    if (isFull) return 'red';
    return 'blue';
  }

  // Format tanggal event untuk display
  String get formattedEventDate {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
      'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'
    ];
    
    final days = ['Min', 'Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab'];
    
    return '${days[eventStartTime.weekday % 7]}, ${eventStartTime.day} ${months[eventStartTime.month - 1]} ${eventStartTime.year}';
  }

  // Format waktu event (jam saja)
  String get formattedEventTime {
    String formatTime(DateTime dt) {
      return '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    }
    return '${formatTime(eventStartTime)} - ${formatTime(eventEndTime)} WIB';
  }

  // ==================== METHODS ====================

  // Tambah volunteer
  void addVolunteer(String volunteerId) {
    if (!registeredVolunteerIds.contains(volunteerId) && !isFull) {
      registeredVolunteerIds.add(volunteerId);
      currentVolunteerCount++;
      save(); // Save ke Hive
    }
  }

  // Hapus volunteer
  void removeVolunteer(String volunteerId) {
    if (registeredVolunteerIds.contains(volunteerId)) {
      registeredVolunteerIds.remove(volunteerId);
      currentVolunteerCount--;
      save(); // Save ke Hive
    }
  }

  // Check apakah user sudah terdaftar
  bool isUserRegistered(String userId) {
    return registeredVolunteerIds.contains(userId);
  }

  // Untuk debugging
  @override
  String toString() {
    return 'EventModel(id: $id, title: $title, volunteers: $currentVolunteerCount/$targetVolunteerCount)';
  }
}