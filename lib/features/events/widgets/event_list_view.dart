import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../add_event_screen.dart';
import '../event_list_controller.dart';
import 'event_admin_tile.dart';
import 'event_empty_state.dart';

class EventListView extends StatelessWidget {
  final EventListController controller;

  const EventListView({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isLoading.value && controller.events.isEmpty) {
        return const Center(child: CircularProgressIndicator());
      }

      if (controller.errorMessage.value.isNotEmpty &&
          controller.events.isEmpty) {
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.cloud_off, size: 40, color: Colors.grey),
                const SizedBox(height: 12),
                Text(
                  controller.errorMessage.value,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: controller.refreshEvents,
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        );
      }

      if (controller.events.isEmpty) {
        return const EventEmptyState();
      }

      return ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 80),
        itemCount: controller.events.length,
        itemBuilder: (context, index) {
          final event = controller.events[index];
          return EventAdminTile(
            event: event,
            onEdit: () => Get.to(() => AddEventScreen(eventToEdit: event)),
            onDelete: () => controller.deleteEvent(event),
          );
        },
      );
    });
  }
}
