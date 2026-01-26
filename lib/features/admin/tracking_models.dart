import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';

/// Avoids any withOpacity warnings (uses alpha).
Color op(Color c, double o) => c.withAlpha((o * 255).round());

enum TrackingStatus {
  created,
  pickedUp,
  inTransit,
  outForDelivery,
  delivered,
  delayed,
}

extension TrackingStatusX on TrackingStatus {
  String get key => switch (this) {
    TrackingStatus.created => 'created',
    TrackingStatus.pickedUp => 'pickedUp',
    TrackingStatus.inTransit => 'inTransit',
    TrackingStatus.outForDelivery => 'outForDelivery',
    TrackingStatus.delivered => 'delivered',
    TrackingStatus.delayed => 'delayed',
  };

  String get label => switch (this) {
    TrackingStatus.created => 'Created',
    TrackingStatus.pickedUp => 'Picked up',
    TrackingStatus.inTransit => 'In transit',
    TrackingStatus.outForDelivery => 'Out for delivery',
    TrackingStatus.delivered => 'Delivered',
    TrackingStatus.delayed => 'Delayed',
  };

  static TrackingStatus fromKey(String? v) {
    switch ((v ?? '').trim()) {
      case 'created':
        return TrackingStatus.created;
      case 'pickedUp':
        return TrackingStatus.pickedUp;
      case 'inTransit':
        return TrackingStatus.inTransit;
      case 'outForDelivery':
        return TrackingStatus.outForDelivery;
      case 'delivered':
        return TrackingStatus.delivered;
      case 'delayed':
        return TrackingStatus.delayed;
      default:
        return TrackingStatus.created;
    }
  }
}

/// Matches your TrackingPage model but adds lat/lng + currentLocation + optional description.
class TrackingShipment {
  final String trackingId;

  final String serviceType;
  final String origin;
  final String destination;

  /// In your TrackingPage this is "packageType" (we keep it).
  final String packageType;

  /// Optional: a clearer "description" field (admin can fill it).
  final String packageDescription;

  final TrackingStatus status;
  final DateTime lastUpdated;
  final DateTime? eta;

  final String sender;
  final String receiver;

  /// Human readable location string (e.g. "London Hub").
  final String currentLocation;

  /// Manual coordinates input (no map picker).
  final double latitude;
  final double longitude;

  const TrackingShipment({
    required this.trackingId,
    required this.serviceType,
    required this.origin,
    required this.destination,
    required this.packageType,
    required this.packageDescription,
    required this.status,
    required this.lastUpdated,
    required this.eta,
    required this.sender,
    required this.receiver,
    required this.currentLocation,
    required this.latitude,
    required this.longitude,
  });

  Map<String, dynamic> toMap() {
    return {
      'trackingId': trackingId, // stored for convenience
      'serviceType': serviceType,
      'origin': origin,
      'destination': destination,
      'packageType': packageType,
      'packageDescription': packageDescription,
      'status': status.key,
      'lastUpdated': Timestamp.fromDate(lastUpdated),
      'eta': eta == null ? null : Timestamp.fromDate(eta!),
      'sender': sender,
      'receiver': receiver,
      'currentLocation': currentLocation,
      'latitude': latitude,
      'longitude': longitude,
      // Optional: also store a GeoPoint for future map usage
      'geo': GeoPoint(latitude, longitude),
    };
  }

  static TrackingShipment fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data() ?? {};
    DateTime asDate(dynamic v) {
      if (v is Timestamp) return v.toDate();
      if (v is DateTime) return v;
      return DateTime.now();
    }

    double asDouble(dynamic v) {
      if (v is num) return v.toDouble();
      if (v is String) return double.tryParse(v.trim()) ?? 0.0;
      return 0.0;
    }

    return TrackingShipment(
      trackingId: (d['trackingId'] ?? doc.id).toString(),
      serviceType: (d['serviceType'] ?? '').toString(),
      origin: (d['origin'] ?? '').toString(),
      destination: (d['destination'] ?? '').toString(),
      packageType: (d['packageType'] ?? '').toString(),
      packageDescription: (d['packageDescription'] ?? '').toString(),
      status: TrackingStatusX.fromKey(d['status']?.toString()),
      lastUpdated: asDate(d['lastUpdated']),
      eta: d['eta'] == null ? null : asDate(d['eta']),
      sender: (d['sender'] ?? '').toString(),
      receiver: (d['receiver'] ?? '').toString(),
      currentLocation: (d['currentLocation'] ?? '').toString(),
      latitude: asDouble(d['latitude']),
      longitude: asDouble(d['longitude']),
    );
  }

  TrackingShipment copyWith({
    String? serviceType,
    String? origin,
    String? destination,
    String? packageType,
    String? packageDescription,
    TrackingStatus? status,
    DateTime? lastUpdated,
    DateTime? eta,
    String? sender,
    String? receiver,
    String? currentLocation,
    double? latitude,
    double? longitude,
  }) {
    return TrackingShipment(
      trackingId: trackingId,
      serviceType: serviceType ?? this.serviceType,
      origin: origin ?? this.origin,
      destination: destination ?? this.destination,
      packageType: packageType ?? this.packageType,
      packageDescription: packageDescription ?? this.packageDescription,
      status: status ?? this.status,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      eta: eta ?? this.eta,
      sender: sender ?? this.sender,
      receiver: receiver ?? this.receiver,
      currentLocation: currentLocation ?? this.currentLocation,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
    );
  }
}

class TrackingEvent {
  final String title;
  final String description;
  final String location;
  final DateTime time;

  const TrackingEvent({
    required this.title,
    required this.description,
    required this.location,
    required this.time,
  });

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'location': location,
      'time': Timestamp.fromDate(time),
    };
  }

  static TrackingEvent fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data() ?? {};
    final t = d['time'];
    return TrackingEvent(
      title: (d['title'] ?? '').toString(),
      description: (d['description'] ?? '').toString(),
      location: (d['location'] ?? '').toString(),
      time: t is Timestamp ? t.toDate() : DateTime.now(),
    );
  }
}
