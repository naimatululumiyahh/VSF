import 'package:hive/hive.dart';
import 'package:vsf/models/event_location.dart';
import '../models/event_model.dart';

class EventService {
  static final EventService _instance = EventService._internal();
  factory EventService() => _instance;
  EventService._internal();

  Future<List<EventModel>> getAllEvents() async {
    final eventBox = Hive.box<EventModel>('events');
    return eventBox.values.toList();
  }

  Future<List<EventModel>> getActiveEvents() async {
    final eventBox = Hive.box<EventModel>('events');
    return eventBox.values
        .where((event) => event.isActive && !event.isPast)
        .toList();
  }

  Future<List<EventModel>> searchEvents(String query) async {
    final eventBox = Hive.box<EventModel>('events');
    final lowerQuery = query.toLowerCase();
    
    return eventBox.values
        .where((event) =>
            event.title.toLowerCase().contains(lowerQuery) ||
            event.description.toLowerCase().contains(lowerQuery) ||
            event.category.toLowerCase().contains(lowerQuery))
        .toList();
  }

  Future<List<EventModel>> filterEventsByCategory(String category) async {
    final eventBox = Hive.box<EventModel>('events');
    return eventBox.values
        .where((event) => event.category == category)
        .toList();
  }

  Future<List<EventModel>> filterEventsByProvince(String location) async {
    final eventBox = Hive.box<EventModel>('events');
    return eventBox.values
        .where((event) => event.location == location)
        .toList();
  }

  Future<EventModel?> getEventById(String id) async {
    final eventBox = Hive.box<EventModel>('events');
    
    for (var event in eventBox.values) {
      if (event.id == id) {
        return event;
      }
    }
    
    return null;
  }

  Future<List<EventModel>> getEventsByOrganizer(String organizerId) async {
    final eventBox = Hive.box<EventModel>('events');
    return eventBox.values
        .where((event) => event.organizerId == organizerId)
        .toList();
  }

  Future<void> addEvent(EventModel event) async {
    final eventBox = Hive.box<EventModel>('events');
    await eventBox.add(event);
  }

  Future<void> updateEvent(EventModel event) async {
    await event.save();
  }

  Future<List<String>> getUniqueCategories() async {
    final eventBox = Hive.box<EventModel>('events');
    final categories = eventBox.values.map((e) => e.category).toSet().toList();
    categories.sort();
    return categories;
  }

  Future<List<EventLocation>> getUniqueProvinces() async {
    final eventBox = Hive.box<EventModel>('events');
    final location = eventBox.values.map((e) => e.location).toSet().toList();
    location.sort();
    return location;
  }
}