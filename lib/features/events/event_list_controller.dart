import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/theme/app_theme.dart';
import '../../models/event.dart';
import '../../repositories/event_repository.dart';

class EventListController extends GetxController {
  final EventRepository _repository;
  StreamSubscription<List<Event>>? _subscription;

  EventListController({EventRepository? repository})
      : _repository = repository ?? EventRepository();

  final RxList<Event> events = <Event>[].obs;
  final RxBool isLoading = true.obs;
  final RxString errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    _startListening();
  }

  @override
  void onClose() {
    _subscription?.cancel();
    super.onClose();
  }

  void _startListening() {
    isLoading.value = true;
    errorMessage.value = '';

    _subscription?.cancel();
    _subscription = _repository.streamEvents().listen(
      (data) {
        events.assignAll(data);
        isLoading.value = false;
        errorMessage.value = '';
      },
      onError: (err) {
        isLoading.value = false;
        errorMessage.value = err.toString();
        Get.snackbar(
          'Firestore Sync Issue',
          'Could not fetch events: $err',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
          duration: const Duration(seconds: 4),
        );
      },
    );
  }

  void refreshEvents() {
    _startListening();
  }

  Future<void> deleteEvent(Event event) async {
    if (event.id == null) return;
    try {
      await _repository.deleteEvent(event.id!);
      Get.snackbar(
        'Event Removed',
        '"${event.title}" has been deleted from Firestore.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppTheme.charcoal,
        colorText: AppTheme.cream,
        margin: const EdgeInsets.all(16),
        borderRadius: 8,
        duration: const Duration(seconds: 2),
      );
    } catch (e) {
      Get.snackbar(
        'Delete Failed',
        'Could not remove event: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }
}
