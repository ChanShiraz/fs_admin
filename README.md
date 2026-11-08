# FridaySocial Admin

A simple Flutter admin panel for FridaySocial to create, edit, and manage events stored in Firebase Cloud Firestore.

## Features & How It Works

- **Event Management**: Create and update events with title, description, venue, date, start/end times, capacity, and attendee count.
- **Real-Time Sync**: Connects directly to Cloud Firestore (`events` collection) with instant updates across the dashboard.
- **Location & Geocoding**: Search venues or addresses directly in the form without manually entering latitude and longitude. Coordinates are resolved in the background and attached to the event.

## Free Places Search (OpenStreetMap)

Instead of paid services that require billing or credit cards (like Google Places API), this project uses **OpenStreetMap (Nominatim)**:

- **100% Free**: No API key or payment setup required.
- **Country Code**: The API filters results by country code. It is currently set to **Singapore (`sg`)** in `lib/services/places_service.dart`. If you want to use it for another country, just update `_countryCode` (for example, `'us'`, `'uk'`, `'pk'`, etc.).
- **Automatic Coordinates**: When you select a suggestion from the search field, its exact latitude and longitude are automatically fetched and pinned to the event.
- **Offline Fallback**: A list of popular Singapore locations is included as a fallback if the network request fails or you are working offline.

## Project Structure

```
lib/
├── core/theme/         # Minimal warm theme (cream, charcoal, terracotta)
├── features/events/    # Event list, form screens, controllers, and widgets
├── models/             # Event and place prediction data models
├── repositories/       # Firestore read/write operations
├── services/           # OpenStreetMap location search service
├── firebase_options.dart # Generated Firebase config
└── main.dart           # App entry point
```

## Getting Started

1. Make sure you have Flutter installed.
2. Install dependencies:
   ```bash
   flutter pub get
   ```
3. Run the app:
   ```bash
   flutter run
   ```
