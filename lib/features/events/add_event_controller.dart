import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_theme.dart';
import '../../../models/event.dart';
import '../../../models/place_prediction.dart';
import '../../../repositories/event_repository.dart';
import '../../../services/places_service.dart';

class AddEventController extends GetxController {
  final EventRepository _repository;
  final PlacesService placesService;
  final Event? initialEvent;

  AddEventController({
    EventRepository? repository,
    PlacesService? placesService,
    this.initialEvent,
  })  : _repository = repository ?? EventRepository(),
        placesService = placesService ?? PlacesService();

  final formKey = GlobalKey<FormState>();

  late final TextEditingController titleController;
  late final TextEditingController descriptionController;
  late final TextEditingController cityController;
  late final TextEditingController venueController;
  late final TextEditingController locationController;
  late final TextEditingController weatherNoteController;
  late final TextEditingController attendeesCountController;
  late final TextEditingController capacityController;

  final RxDouble latitude = 1.2847.obs;
  final RxDouble longitude = 103.8610.obs;
  final RxBool hasResolvedCoordinates = false.obs;

  late final Rx<DateTime> selectedDate;
  late final Rx<TimeOfDay> startTime;
  late final Rx<TimeOfDay?> endTime;
  final RxBool isSaving = false.obs;

  bool get isEditing => initialEvent != null;

  @override
  void onInit() {
    super.onInit();
    final event = initialEvent;

    titleController = TextEditingController(text: event?.title ?? '');
    descriptionController =
        TextEditingController(text: event?.description ?? '');
    cityController = TextEditingController(text: event?.city ?? 'Singapore');
    venueController = TextEditingController(text: event?.venue ?? '');
    locationController = TextEditingController(text: event?.address ?? '');
    weatherNoteController =
        TextEditingController(text: event?.weatherNote ?? '');
    attendeesCountController =
        TextEditingController(text: (event?.attendeesCount ?? 12).toString());
    capacityController =
        TextEditingController(text: event?.capacity?.toString() ?? '');

    if (event != null) {
      latitude.value = event.latitude;
      longitude.value = event.longitude;
      hasResolvedCoordinates.value = true;
    }

    selectedDate =
        (event?.date ?? DateTime.now().add(const Duration(days: 1))).obs;
    startTime = _parseTimeString(event?.time ?? '09:00').obs;
    endTime =
        (event?.endTime != null ? _parseTimeString(event!.endTime!) : null).obs;
  }

  @override
  void onClose() {
    titleController.dispose();
    descriptionController.dispose();
    cityController.dispose();
    venueController.dispose();
    locationController.dispose();
    weatherNoteController.dispose();
    attendeesCountController.dispose();
    capacityController.dispose();
    super.onClose();
  }

  void handlePlaceSelected(PlaceDetails details) {
    latitude.value = details.latitude;
    longitude.value = details.longitude;
    hasResolvedCoordinates.value = true;

    if (venueController.text.trim().isEmpty) {
      venueController.text = details.name;
    }

    Get.snackbar(
      'Location Selected',
      '${details.name} selected and coordinates pinned.',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: AppTheme.charcoal,
      colorText: AppTheme.cream,
      duration: const Duration(seconds: 2),
      margin: const EdgeInsets.all(16),
      borderRadius: 8,
    );
  }

  Future<void> pickDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate.value,
      firstDate: DateTime(2024),
      lastDate: DateTime(2030),
    );

    if (picked != null) {
      selectedDate.value = picked;
    }
  }

  Future<void> pickStartTime(BuildContext context) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: startTime.value,
    );

    if (picked != null) {
      startTime.value = picked;
    }
  }

  Future<void> pickEndTime(BuildContext context) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: endTime.value ??
          TimeOfDay(
            hour: (startTime.value.hour + 2) % 24,
            minute: startTime.value.minute,
          ),
    );

    if (picked != null) {
      endTime.value = picked;
    }
  }

  Future<void> saveEvent() async {
    if (!formKey.currentState!.validate()) {
      return;
    }

    final attendees = int.tryParse(attendeesCountController.text.trim()) ?? 0;
    final capacity = int.tryParse(capacityController.text.trim());
    final venueText = venueController.text.trim();
    final addressText = locationController.text.trim();

    isSaving.value = true;

    try {
      if (!hasResolvedCoordinates.value && addressText.isNotEmpty) {
        final predictions = await placesService.searchPredictions(addressText);
        if (predictions.isNotEmpty) {
          final details =
              await placesService.fetchPlaceDetails(predictions.first.placeId);
          if (details != null) {
            latitude.value = details.latitude;
            longitude.value = details.longitude;
            hasResolvedCoordinates.value = true;
          }
        }
      }

      final formattedStartTime = _formatTimeOfDay(startTime.value);
      final formattedEndTime =
          endTime.value != null ? _formatTimeOfDay(endTime.value!) : null;

      final eventToSave = Event(
        id: initialEvent?.id,
        title: titleController.text.trim(),
        description: descriptionController.text.trim(),
        city: cityController.text.trim().isEmpty
            ? 'Singapore'
            : cityController.text.trim(),
        date: selectedDate.value,
        time: formattedStartTime,
        endTime: formattedEndTime,
        venue: venueText.isNotEmpty ? venueText : addressText,
        address: addressText.isNotEmpty ? addressText : venueText,
        latitude: latitude.value,
        longitude: longitude.value,
        weatherNote: weatherNoteController.text.trim().isEmpty
            ? null
            : weatherNoteController.text.trim(),
        attendeesCount: attendees,
        capacity: capacity,
      );

      if (isEditing) {
        await _repository.updateEvent(eventToSave);
      } else {
        await _repository.addEvent(eventToSave);
      }

      Get.back(result: true);

      Get.snackbar(
        isEditing ? 'Event Updated' : 'Event Published',
        '"${eventToSave.title}" is now live in Firestore.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
        icon: const Icon(Icons.check_circle_outline, color: Colors.white),
        margin: const EdgeInsets.all(16),
        borderRadius: 8,
        duration: const Duration(seconds: 3),
      );
    } catch (e) {
      Get.snackbar(
        'Failed to Push Event',
        'Firestore error: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        icon: const Icon(Icons.error_outline, color: Colors.white),
        margin: const EdgeInsets.all(16),
        borderRadius: 8,
        duration: const Duration(seconds: 4),
      );
    } finally {
      isSaving.value = false;
    }
  }

  String _formatTimeOfDay(TimeOfDay time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  TimeOfDay _parseTimeString(String timeStr) {
    try {
      final parts = timeStr.trim().split(':');
      if (parts.length >= 2) {
        final hour = int.parse(parts[0]);
        final minute = int.parse(parts[1].split(' ')[0]);
        return TimeOfDay(hour: hour, minute: minute);
      }
    } catch (_) {}
    return const TimeOfDay(hour: 9, minute: 0);
  }

  String get formattedSelectedDate =>
      DateFormat('EEEE, d MMMM yyyy').format(selectedDate.value);
}
