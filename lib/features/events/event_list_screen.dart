import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'add_event_screen.dart';
import 'event_list_controller.dart';
import 'widgets/event_list_view.dart';

class EventListScreen extends StatelessWidget {
  const EventListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(EventListController());

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Atmosphere Admin',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
            onPressed: controller.refreshEvents,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Get.to(() => const AddEventScreen()),
        icon: const Icon(Icons.add),
        label: const Text('Add Event'),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: EventListView(
            controller: controller,
          ),
        ),
      ),
    );
  }
}
