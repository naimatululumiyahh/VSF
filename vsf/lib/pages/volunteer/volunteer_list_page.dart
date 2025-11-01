import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../../models/event_model.dart';
import '../../models/user_model.dart';
import '../activity/activity_detail_page.dart';
import 'package:intl/intl.dart';

class VolunteerListPage extends StatefulWidget {
  final UserModel currentUser;
  final String? initialSearchQuery;
  final String? initialCategory;
  final String? initialLocation;
  final DateTime? initialDate;

  const VolunteerListPage({
    super.key, 
    required this.currentUser,
    this.initialSearchQuery,
    this.initialCategory,
    this.initialLocation,
    this.initialDate,
  });

  @override
  State<VolunteerListPage> createState() => _VolunteerListPageState();
}

class _VolunteerListPageState extends State<VolunteerListPage> {
  final _searchController = TextEditingController();
  List<EventModel> _allEvents = [];
  List<EventModel> _filteredEvents = [];
  
  String _selectedCategory = 'Semua';
  String _selectedLocation = 'Semua';
  DateTime? _selectedDate;

  final List<String> _categories = [
    'Semua',
    'Pendidikan',
    'Lingkungan',
    'Kesehatan',
    'Sosial',
    'Anak-anak'
  ];

  final List<String> _locations = [
    'Semua',
    'Jakarta Utara',
    'Jakarta Selatan',
    'Jakarta Barat',
    'Jakarta Timur',
    'Jakarta Pusat',
    'Bandung',
    'Surabaya',
    'Depok',
  ];

  @override
  void initState() {
    super.initState();
    _searchController.text = widget.initialSearchQuery ?? '';
    _selectedCategory = widget.initialCategory ?? 'Semua';
    _selectedLocation = widget.initialLocation ?? 'Semua';
    _selectedDate = widget.initialDate;
    
    _searchController.addListener(_filterEvents);
    _loadEvents();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _loadEvents() {
    final eventBox = Hive.box<EventModel>('events');
    setState(() {
      _allEvents = eventBox.values.where((event) => !event.isPast).toList();
      _filterEvents();
    });
  }

  void _filterEvents() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredEvents = _allEvents.where((event) {
        // Filter by search query
        final matchesQuery = query.isEmpty ||
            event.title.toLowerCase().contains(query) ||
            event.description.toLowerCase().contains(query) ||
            event.location.city.toLowerCase().contains(query);

        // Filter by category
        final matchesCategory = _selectedCategory == 'Semua' ||
            event.category == _selectedCategory;

        // Filter by location
        final matchesLocation = _selectedLocation == 'Semua' ||
            event.location.city == _selectedLocation;

        // Filter by date
        final matchesDate = _selectedDate == null ||
            (event.eventStartTime.year == _selectedDate!.year &&
             event.eventStartTime.month == _selectedDate!.month &&
             event.eventStartTime.day == _selectedDate!.day);

        return matchesQuery && matchesCategory && matchesLocation && matchesDate;
      }).toList();
    });
  }

  Widget _buildEventCard(EventModel event) {
    return InkWell(
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
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(
            bottom: BorderSide(color: Colors.grey[200]!),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              event.title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.location_on_outlined, size: 16, color: Colors.blue[600]),
                const SizedBox(width: 4),
                Text(
                  event.location.shortAddress,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.access_time_rounded, size: 16, color: Colors.blue[600]),
                const SizedBox(width: 4),
                Text(
                  '${DateFormat('EEE, d MMM', 'id_ID').format(event.eventStartTime)} | '
                  '${DateFormat('HH:mm').format(event.eventStartTime)} - '
                  '${DateFormat('HH:mm').format(event.eventEndTime)} WIB',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _filterEvents();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daftar Kegiatan'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {
              // TODO: Implement notifications
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Cari kegiatan...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey[100],
              ),
            ),
          ),

          // Filter Section
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Row(
              children: [
                // Category Filter
                Expanded(
                  child: PopupMenuButton<String>(
                    onSelected: (value) {
                      setState(() {
                        _selectedCategory = value;
                        _filterEvents();
                      });
                    },
                    itemBuilder: (context) {
                      return _categories.map((category) {
                        return PopupMenuItem(
                          value: category,
                          child: Text(category),
                        );
                      }).toList();
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey[300]!),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Kategori',
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                          const Icon(Icons.arrow_drop_down),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),

                // Location Filter
                Expanded(
                  child: PopupMenuButton<String>(
                    onSelected: (value) {
                      setState(() {
                        _selectedLocation = value;
                        _filterEvents();
                      });
                    },
                    itemBuilder: (context) {
                      return _locations.map((location) {
                        return PopupMenuItem(
                          value: location,
                          child: Text(location),
                        );
                      }).toList();
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey[300]!),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Lokasi',
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                          const Icon(Icons.arrow_drop_down),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),

                // Date Filter
                Expanded(
                  child: GestureDetector(
                    onTap: _selectDate,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey[300]!),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Tanggal',
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                          const Icon(Icons.arrow_drop_down),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Results Count
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            alignment: Alignment.centerLeft,
            child: Text(
              '${_filteredEvents.length} kegiatan ditemukan',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 13,
              ),
            ),
          ),

          // Events List
          Expanded(
            child: _filteredEvents.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.search_off, size: 64, color: Colors.grey[400]),
                        const SizedBox(height: 16),
                        Text(
                          'Tidak ada kegiatan ditemukan',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: _filteredEvents.length,
                    itemBuilder: (context, index) {
                      return _buildEventCard(_filteredEvents[index]);
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
