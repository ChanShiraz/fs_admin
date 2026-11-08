import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../add_event_controller.dart';
import 'event_schedule_pickers.dart';
import 'place_autocomplete_field.dart';

class AddEventForm extends StatelessWidget {
  final AddEventController controller;

  const AddEventForm({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Form(
      key: controller.formKey,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextFormField(
            controller: controller.titleController,
            decoration: const InputDecoration(
              labelText: 'Event Title *',
              hintText: 'e.g. Morning Coffee Tasting & Brewing',
            ),
            validator: (value) =>
                value == null || value.trim().isEmpty ? 'Required' : null,
          ),
          const SizedBox(height: 14),
          TextFormField(
            controller: controller.descriptionController,
            maxLines: 3,
            decoration: const InputDecoration(
              labelText: 'Description *',
              hintText: 'Everyday plain English description',
            ),
            validator: (value) =>
                value == null || value.trim().isEmpty ? 'Required' : null,
          ),
          const SizedBox(height: 18),
          Obx(() => EventSchedulePickers(
                formattedDate: controller.formattedSelectedDate,
                startTime: controller.startTime.value,
                endTime: controller.endTime.value,
                onPickDate: () => controller.pickDate(context),
                onPickStartTime: () => controller.pickStartTime(context),
                onPickEndTime: () => controller.pickEndTime(context),
              )),
          const SizedBox(height: 18),
          PlaceAutocompleteField(
            controller: controller.locationController,
            placesService: controller.placesService,
            onPlaceSelected: controller.handlePlaceSelected,
            labelText: 'Search Location / Address *',
            hintText: 'Type to search venue or address...',
            validator: (value) =>
                value == null || value.trim().isEmpty ? 'Required' : null,
          ),
          Obx(() {
            if (!controller.hasResolvedCoordinates.value) {
              return const SizedBox.shrink();
            }
            return const Padding(
              padding: EdgeInsets.only(top: 6, left: 4),
              child: Row(
                children: [
                  Icon(Icons.check_circle, size: 14, color: Colors.green),
                  SizedBox(width: 6),
                  Text(
                    'Location coordinates verified',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.green,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            );
          }),
          const SizedBox(height: 14),
          TextFormField(
            controller: controller.venueController,
            decoration: const InputDecoration(
              labelText: 'Venue Name (Optional)',
              hintText: 'e.g. ArtScience Museum, Sands Expo',
              prefixIcon: Icon(Icons.storefront_outlined),
            ),
          ),
          const SizedBox(height: 14),
          TextFormField(
            controller: controller.weatherNoteController,
            decoration: const InputDecoration(
              labelText: 'Weather Note (Optional)',
              hintText: 'e.g. Air-conditioned indoor café • Free cold water',
              prefixIcon: Icon(Icons.wb_sunny_outlined),
            ),
          ),
          const SizedBox(height: 14),
          TextFormField(
            controller: controller.capacityController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Total Capacity',
              hintText: 'e.g. 50 (max attendees)',
              prefixIcon: Icon(Icons.groups_outlined),
            ),
            validator: (value) {
              if (value != null &&
                  value.trim().isNotEmpty &&
                  int.tryParse(value.trim()) == null) {
                return 'Must be an integer';
              }
              return null;
            },
          ),
          const SizedBox(height: 14),
          TextFormField(
            controller: controller.attendeesCountController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Initial Attendees Count',
              hintText: 'e.g. 14',
              prefixIcon: Icon(Icons.people_outline),
            ),
            validator: (value) {
              if (value != null &&
                  value.isNotEmpty &&
                  int.tryParse(value) == null) {
                return 'Must be an integer';
              }
              return null;
            },
          ),
          const SizedBox(height: 24),
          Obx(() {
            return ElevatedButton(
              onPressed:
                  controller.isSaving.value ? null : controller.saveEvent,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: controller.isSaving.value
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : Text(
                      controller.isEditing
                          ? 'Update Event'
                          : 'Save Event to Firestore',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
            );
          }),
        ],
      ),
    );
  }
}
