import 'package:hive/hive.dart';
import '../models/event_model.dart';
import '../models/volunteer_registration.dart';

class StatisticsService {
  static final StatisticsService _instance = StatisticsService._internal();
  factory StatisticsService() => _instance;
  StatisticsService._internal();

  Future<Map<String, dynamic>> getGlobalStatistics() async {
    final eventBox = Hive.box<EventModel>('events');
    final registrationBox = Hive.box<VolunteerRegistration>('registrations');

    int totalParticipants = 0;
    int totalDonations = 0;
    int activeEvents = 0;

    for (var event in eventBox.values) {
      totalParticipants += event.currentVolunteerCount;
      totalDonations += event.participationFeeIdr * event.currentVolunteerCount;
      if (event.isActive && !event.isPast) {
        activeEvents++;
      }
    }

    return {
      'totalParticipants': totalParticipants,
      'totalDonations': totalDonations,
      'activeEvents': activeEvents,
      'totalEvents': eventBox.length,
      'totalRegistrations': registrationBox.length,
    };
  }

  Future<Map<String, int>> getCategoryDistribution() async {
    final eventBox = Hive.box<EventModel>('events');
    final Map<String, int> distribution = {};

    for (var event in eventBox.values) {
      distribution[event.category] = (distribution[event.category] ?? 0) + 1;
    }

    return distribution;
  }

  Future<List<EventModel>> getPopularEvents({int limit = 5}) async {
    final eventBox = Hive.box<EventModel>('events');
    final events = eventBox.values.toList();
    
    events.sort((a, b) => b.currentVolunteerCount.compareTo(a.currentVolunteerCount));
    
    return events.take(limit).toList();
  }

  Future<Map<String, dynamic>> getUserStatistics(String userId) async {
    final registrationBox = Hive.box<VolunteerRegistration>('registrations');

    int totalParticipations = 0;
    int totalDonated = 0;
    List<String> categories = [];

    for (var registration in registrationBox.values) {
      if (registration.volunteerId == userId && registration.isPaid) {
        totalParticipations++;
        totalDonated += registration.donationAmount;
      }
    }

    return {
      'totalParticipations': totalParticipations,
      'totalDonated': totalDonated,
      'uniqueCategories': categories.toSet().length,
    };
  }
}