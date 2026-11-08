import 'dart:async';
import 'package:flutter/material.dart';
import '../../../models/place_prediction.dart';
import '../../../services/places_service.dart';

class PlaceAutocompleteField extends StatefulWidget {
  final TextEditingController controller;
  final PlacesService placesService;
  final ValueChanged<PlaceDetails> onPlaceSelected;
  final String labelText;
  final String hintText;
  final FormFieldValidator<String>? validator;

  const PlaceAutocompleteField({
    super.key,
    required this.controller,
    required this.placesService,
    required this.onPlaceSelected,
    this.labelText = 'Location / Address *',
    this.hintText = 'Search venue or address...',
    this.validator,
  });

  @override
  State<PlaceAutocompleteField> createState() => _PlaceAutocompleteFieldState();
}

class _PlaceAutocompleteFieldState extends State<PlaceAutocompleteField> {
  Timer? _debounceTimer;
  List<PlacePrediction> _predictions = [];
  bool _isLoading = false;
  bool _showOverlay = false;

  @override
  void dispose() {
    _debounceTimer?.cancel();
    super.dispose();
  }

  void _onTextChanged(String query) {
    _debounceTimer?.cancel();

    if (query.trim().isEmpty) {
      setState(() {
        _predictions = [];
        _showOverlay = false;
        _isLoading = false;
      });
      return;
    }

    _debounceTimer = Timer(const Duration(milliseconds: 350), () async {
      setState(() => _isLoading = true);

      final results = await widget.placesService.searchPredictions(query);

      if (mounted) {
        setState(() {
          _predictions = results;
          _showOverlay = results.isNotEmpty;
          _isLoading = false;
        });
      }
    });
  }

  Future<void> _selectPrediction(PlacePrediction prediction) async {
    setState(() {
      _showOverlay = false;
      _isLoading = true;
    });

    final details =
        await widget.placesService.fetchPlaceDetails(prediction.placeId);

    if (mounted) {
      setState(() => _isLoading = false);

      if (details != null) {
        widget.controller.text = details.formattedAddress;
        widget.onPlaceSelected(details);
      } else {
        widget.controller.text = prediction.description;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: widget.controller,
          onChanged: _onTextChanged,
          decoration: InputDecoration(
            labelText: widget.labelText,
            hintText: widget.hintText,
            prefixIcon: const Icon(Icons.location_on_outlined),
            suffixIcon: _isLoading
                ? const Padding(
                    padding: EdgeInsets.all(12),
                    child: SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  )
                : widget.controller.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, size: 18),
                        onPressed: () {
                          widget.controller.clear();
                          _onTextChanged('');
                        },
                      )
                    : null,
          ),
          validator: widget.validator,
        ),
        if (_showOverlay && _predictions.isNotEmpty) ...[
          const SizedBox(height: 4),
          Card(
            elevation: 3,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
              side: const BorderSide(color: Colors.black12),
            ),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 220),
              child: ListView.separated(
                shrinkWrap: true,
                padding: EdgeInsets.zero,
                itemCount: _predictions.length,
                separatorBuilder: (context, index) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final prediction = _predictions[index];
                  return ListTile(
                    dense: true,
                    leading: const Icon(Icons.place_outlined,
                        size: 20, color: Color(0xFFA23E18)),
                    title: Text(
                      prediction.mainText,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                    subtitle: prediction.secondaryText != null
                        ? Text(
                            prediction.secondaryText!,
                            style: const TextStyle(fontSize: 11),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          )
                        : null,
                    onTap: () => _selectPrediction(prediction),
                  );
                },
              ),
            ),
          ),
        ],
      ],
    );
  }
}
