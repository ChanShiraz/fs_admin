import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../models/event.dart';
import 'add_event_controller.dart';
import 'widgets/add_event_form.dart';

class AddEventScreen extends StatelessWidget {
  final Event? eventToEdit;

  const AddEventScreen({super.key, this.eventToEdit});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(
      AddEventController(initialEvent: eventToEdit),
      tag: eventToEdit?.id ?? 'create_event',
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(controller.isEditing ? 'Edit Event' : 'Add Event'),
        actions: [
          Obx(() {
            return TextButton(
              onPressed: controller.isSaving.value
                  ? null
                  : controller.saveEvent,
              child: controller.isSaving.value
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text(
                      'Save',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
            );
          }),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 680),
          child: AddEventForm(controller: controller),
        ),
      ),
    );
  }
}
