import 'package:flutter/material.dart';
import 'dart:io';
import 'package:hive/hive.dart';
import '../../models/event_model.dart';
import '../../models/user_model.dart';
import 'create_event_page.dart';
import 'activity_detail_page.dart';

class OrganizerActivitiesPage extends StatefulWidget {
  final UserModel currentUser;

  const OrganizerActivitiesPage({super.key, required this.currentUser});

  @override
  State<OrganizerActivitiesPage> createState() => _OrganizerActivitiesPageState();
}

class _OrganizerActivitiesPageState extends State<OrganizerActivitiesPage> {
  List<EventModel> _myEvents = [];

  @override
  void initState() {
    super.initState();
    _loadMyEvents();
  }

  Widget _buildLeadingImage(EventModel event) {
    final url = event.imageUrl;
    if (url == null || url.isEmpty) return const Icon(Icons.event, size: 40);

    if (url.startsWith('http') || url.startsWith('https')) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.network(url, width: 56, height: 56, fit: BoxFit.cover, errorBuilder: (_,__,___) => const Icon(Icons.broken_image)),
      );
    }

    try {
      final f = File(url);
      if (f.existsSync()) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.file(f, width: 56, height: 56, fit: BoxFit.cover),
        );
      }
    } catch (_) {}

    return const Icon(Icons.image_not_supported, size: 40);
  }

  void _loadMyEvents() {
    final box = Hive.box<EventModel>('events');
    setState(() {
      _myEvents = box.values.where((e) => e.organizerId == widget.currentUser.id).toList();
      _myEvents.sort((a,b) => b.createdAt.compareTo(a.createdAt));
    });
  }

  Future<void> _createEvent() async {
    final res = await Navigator.push<bool?>(
      context,
      MaterialPageRoute(builder: (_) => CreateEventPage(currentUser: widget.currentUser)),
    );
    if (res == true) _loadMyEvents();
  }

  Future<void> _editEvent(EventModel event) async {
    final res = await Navigator.push<bool?>(
      context,
      MaterialPageRoute(builder: (_) => CreateEventPage(currentUser: widget.currentUser, existingEvent: event)),
    );
    if (res == true) _loadMyEvents();
  }

  Future<void> _deleteEvent(EventModel event) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Kegiatan'),
        content: const Text('Yakin ingin menghapus kegiatan ini? Tindakan ini tidak bisa dibatalkan.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Batal')),
          ElevatedButton(onPressed: () => Navigator.pop(context, true), child: const Text('Hapus')),
        ],
      ),
    );
    if (confirm == true) {
      final box = Hive.box<EventModel>('events');
      await box.delete(event.id);
      _loadMyEvents();
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Kegiatan dihapus')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Aktivitas Saya (Organisasi)'),
        actions: [
          IconButton(icon: const Icon(Icons.add), onPressed: _createEvent),
        ],
      ),
      body: _myEvents.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.event_note, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  const Text('Anda belum memiliki kegiatan terbit'),
                  const SizedBox(height: 8),
                  ElevatedButton(onPressed: _createEvent, child: const Text('Buat Kegiatan')),
                ],
              ),
            )
          : RefreshIndicator(
              onRefresh: () async => _loadMyEvents(),
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(vertical: 12),
                itemCount: _myEvents.length,
                itemBuilder: (context, index) {
                  final event = _myEvents[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: ListTile(
            leading: _buildLeadingImage(event),
                      title: Text(event.title),
                      subtitle: Text(event.formattedEventDate),
                      trailing: PopupMenuButton<String>(
                        onSelected: (v) {
                          if (v == 'edit') _editEvent(event);
                          if (v == 'delete') _deleteEvent(event);
                        },
                        itemBuilder: (context) => [
                          const PopupMenuItem(value: 'edit', child: Text('Edit')),
                          const PopupMenuItem(value: 'delete', child: Text('Hapus')),
                        ],
                      ),
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder: (_) => ActivityDetailPage(event: event, currentUser: widget.currentUser)));
                      },
                    ),
                  );
                },
              ),
            ),
    );
  }
}
