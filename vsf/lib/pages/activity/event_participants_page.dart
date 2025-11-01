import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../../models/event_model.dart';
import '../../models/volunteer_registration.dart';
import '../../models/user_model.dart';

class EventParticipantsPage extends StatelessWidget {
  final EventModel event;
  final UserModel currentUser;

  const EventParticipantsPage({
    super.key,
    required this.event,
    required this.currentUser,
  });

  List<VolunteerRegistration> _getEventRegistrations() {
    final registrationsBox = Hive.box<VolunteerRegistration>('registrations');
    return registrationsBox.values
        .where((reg) => reg.eventId == event.id)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final registrations = _getEventRegistrations();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Daftar Peserta',
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: registrations.length,
        itemBuilder: (context, index) {
          final reg = registrations[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Participant Name and Status
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          reg.volunteerName,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: reg.isPaid ? Colors.green[50] : Colors.orange[50],
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          reg.paymentStatus,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: reg.isPaid ? Colors.green[700] : Colors.orange[700],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Contact Info
                  _buildInfoRow('Email', reg.volunteerEmail),
                  _buildInfoRow('Telepon', reg.volunteerPhone),
                  if (reg.volunteerNik != null)
                    _buildInfoRow('NIK', reg.volunteerNik!),
                  _buildInfoRow('Umur', '${reg.age} tahun'),
                  _buildInfoRow('Motivasi', reg.motivation),

                  if (reg.hasFeedback) ...[
                    const Divider(height: 24),
                    Text(
                      'Feedback',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.blue[600],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      reg.feedbackMessage!,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ]
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey[600],
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 13,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }
}