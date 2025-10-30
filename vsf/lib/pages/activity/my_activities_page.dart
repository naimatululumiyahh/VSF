import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../../models/event_model.dart';
import '../../models/user_model.dart';
import '../../models/volunteer_registration.dart';
import 'activity_detail_page.dart';

class MyActivitiesPage extends StatefulWidget {
  final UserModel currentUser;

  const MyActivitiesPage({super.key, required this.currentUser});

  @override
  State<MyActivitiesPage> createState() => _MyActivitiesPageState();
}

class _MyActivitiesPageState extends State<MyActivitiesPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<EventModel> _registeredEvents = [];
  List<VolunteerRegistration> _registrations = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadRegisteredEvents();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _loadRegisteredEvents() {
    final registrationBox = Hive.box<VolunteerRegistration>('volunteer_registrations');
    final eventBox = Hive.box<EventModel>('events');

    // Get all registrations for current user
    _registrations = registrationBox.values
        .where((reg) => reg.volunteerId == widget.currentUser.id)
        .toList();

    // Get all corresponding events
    _registeredEvents = _registrations
        .map((reg) => eventBox.get(reg.eventId))
        .whereType<EventModel>() // Filter out null values
        .toList();

    setState(() {});
  }

  Widget _buildEventCard(EventModel event, VolunteerRegistration registration) {
    final bool isCompleted = event.isPast;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ActivityDetailPage(
              event: event,
              currentUser: widget.currentUser,
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Event Info Row
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  // Event Image
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      image: event.imageUrl != null
                          ? DecorationImage(
                              image: NetworkImage(event.imageUrl!),
                              fit: BoxFit.cover,
                            )
                          : null,
                    ),
                    child: event.imageUrl == null
                        ? Container(
                            color: Colors.grey[200],
                            child: const Icon(Icons.image, size: 32),
                          )
                        : null,
                  ),
                  const SizedBox(width: 16),
                  // Event Details
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          event.formattedEventDate,
                          style: TextStyle(
                            color: Colors.blue[600],
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          event.title,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(Icons.location_on_outlined,
                                size: 14, color: Colors.grey[600]),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                event.location.shortAddress,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey[600],
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // Action Row
            Container(
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(color: Colors.grey[200]!),
                ),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  if (isCompleted && !registration.hasFeedback)
                    Expanded(
                      child: TextButton(
                        onPressed: () {
                          // TODO: Implement feedback dialog
                        },
                        style: TextButton.styleFrom(
                          backgroundColor: Colors.orange[50],
                          foregroundColor: Colors.orange[700],
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text('Beri Feedback'),
                      ),
                    )
                  else if (isCompleted && registration.hasFeedback)
                    Row(
                      children: [
                        Icon(Icons.check_circle,
                            size: 16, color: Colors.green[600]),
                        const SizedBox(width: 4),
                        Text(
                          'Selesai',
                          style: TextStyle(
                            color: Colors.green[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    )
                  else
                    Expanded(
                      child: TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ActivityDetailPage(
                                event: event,
                                currentUser: widget.currentUser,
                              ),
                            ),
                          );
                        },
                        style: TextButton.styleFrom(
                          backgroundColor: Colors.blue[50],
                          foregroundColor: Colors.blue[700],
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text('Lihat Detail'),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Split events into upcoming and past
    final upcomingEvents = _registeredEvents.where((e) => !e.isPast).toList();
    final pastEvents = _registeredEvents.where((e) => e.isPast).toList();

    // Sort by date
    upcomingEvents.sort((a, b) => a.eventStartTime.compareTo(b.eventStartTime));
    pastEvents.sort((a, b) => b.eventStartTime.compareTo(a.eventStartTime)); // Reverse for past events

    return Scaffold(
      appBar: AppBar(
        title: const Text('Aktivitas Saya'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Mendatang'),
            Tab(text: 'Riwayat'),
          ],
          labelStyle: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
          unselectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.normal,
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Upcoming Events Tab
          upcomingEvents.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.event_available,
                          size: 64, color: Colors.grey[400]),
                      const SizedBox(height: 16),
                      Text(
                        'Belum ada aktivitas mendatang',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  itemCount: upcomingEvents.length,
                  itemBuilder: (context, index) {
                    final event = upcomingEvents[index];
                    final registration = _registrations.firstWhere(
                        (r) => r.eventId == event.id);
                    return _buildEventCard(event, registration);
                  },
                ),

          // Past Events Tab
          pastEvents.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.history, size: 64, color: Colors.grey[400]),
                      const SizedBox(height: 16),
                      Text(
                        'Belum ada riwayat aktivitas',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  itemCount: pastEvents.length,
                  itemBuilder: (context, index) {
                    final event = pastEvents[index];
                    final registration = _registrations.firstWhere(
                        (r) => r.eventId == event.id);
                    return _buildEventCard(event, registration);
                  },
                ),
        ],
      ),
    );
  }
}
