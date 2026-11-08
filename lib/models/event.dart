import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class Event {
  final String? id;
  final String title;
  final String description;
  final String city;
  final DateTime date;
  final String time;
  final String? endTime;
  final String venue;
  final String address;
  final double latitude;
  final double longitude;
  final int accentColorValue;
  final String? weatherNote;
  final int attendeesCount;
  final int? capacity;

  const Event({
    this.id,
    required this.title,
    required this.description,
    this.city = 'Singapore',
    required this.date,
    required this.time,
    this.endTime,
    required this.venue,
    required this.address,
    required this.latitude,
    required this.longitude,
    this.accentColorValue = 0xFFA23E18,
    this.weatherNote,
    this.attendeesCount = 0,
    this.capacity,
  });

  factory Event.fromFirestore(DocumentSnapshot<Map<String, dynamic>> snapshot) {
    final data = snapshot.data() ?? {};
    return Event.fromMap(data, id: snapshot.id);
  }

  factory Event.fromMap(Map<String, dynamic> map, {String? id}) {
    DateTime parsedDate;
    final rawDate = map['date'];
    if (rawDate is Timestamp) {
      parsedDate = rawDate.toDate();
    } else if (rawDate is DateTime) {
      parsedDate = rawDate;
    } else if (rawDate is String) {
      parsedDate = DateTime.tryParse(rawDate) ?? DateTime.now();
    } else {
      parsedDate = DateTime.now();
    }

    return Event(
      id: id ?? map['id'] as String?,
      title: map['title'] as String? ?? '',
      description: map['description'] as String? ?? '',
      city: map['city'] as String? ?? 'Singapore',
      date: parsedDate,
      time: map['time'] as String? ?? '09:00',
      endTime: map['endTime'] as String?,
      venue: map['venue'] as String? ?? '',
      address: map['address'] as String? ?? '',
      latitude: (map['latitude'] as num?)?.toDouble() ?? 1.2847,
      longitude: (map['longitude'] as num?)?.toDouble() ?? 103.8610,
      accentColorValue: (map['accentColorValue'] as num?)?.toInt() ?? 0xFFA23E18,
      weatherNote: map['weatherNote'] as String?,
      attendeesCount: (map['attendeesCount'] as num?)?.toInt() ?? 0,
      capacity: (map['capacity'] as num?)?.toInt(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'description': description,
      'city': city,
      'date': Timestamp.fromDate(date),
      'time': time,
      'endTime': endTime,
      'venue': venue,
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
      'accentColorValue': accentColorValue,
      'weatherNote': weatherNote,
      'attendeesCount': attendeesCount,
      'capacity': capacity,
    };
  }

  String get formattedDate => DateFormat('EEE, d MMM yyyy').format(date);

  String get timeRange {
    if (endTime != null && endTime!.trim().isNotEmpty) {
      return '$time - $endTime';
    }
    return time;
  }
}
