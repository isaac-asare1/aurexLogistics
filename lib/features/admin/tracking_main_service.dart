import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'tracking_models.dart';

class TrackingAdminService {
  TrackingAdminService({FirebaseFirestore? db})
    : _db = db ?? FirebaseFirestore.instance;

  final FirebaseFirestore _db;

  CollectionReference<Map<String, dynamic>> get _shipments =>
      _db.collection('shipments');

  /// Stream all packages (admin list)
  Stream<List<TrackingShipment>> streamShipments() {
    return _shipments
        .orderBy('lastUpdated', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map(TrackingShipment.fromDoc).toList());
  }

  /// Public tracking page will use this:
  Future<TrackingShipment?> getShipment(String trackingId) async {
    final doc = await _shipments.doc(trackingId).get();
    if (!doc.exists) return null;
    return TrackingShipment.fromDoc(doc);
  }

  /// Events stream (optional)
  Stream<List<TrackingEvent>> streamEvents(String trackingId) {
    return _shipments
        .doc(trackingId)
        .collection('events')
        .orderBy('time', descending: true)
        .snapshots()
        .map((s) => s.docs.map(TrackingEvent.fromDoc).toList());
  }

  /// Create package (trackingId is document ID)
  Future<void> createShipment(TrackingShipment shipment) async {
    await _shipments.doc(shipment.trackingId).set(shipment.toMap());

    // Add an initial event to match your TrackingPage timeline behavior
    await _shipments
        .doc(shipment.trackingId)
        .collection('events')
        .add(
          TrackingEvent(
            title: shipment.status.label,
            description: 'Shipment created/updated by admin.',
            location: shipment.currentLocation.isNotEmpty
                ? shipment.currentLocation
                : shipment.origin,
            time: shipment.lastUpdated,
          ).toMap(),
        );
  }

  /// Update any fields (status, coords, etc.)
  Future<void> updateShipment(
    String trackingId,
    Map<String, dynamic> patch, {
    bool addEvent = true,
    String? eventTitle,
    String? eventDescription,
    String? eventLocation,
  }) async {
    // Always refresh lastUpdated if not provided
    patch.putIfAbsent('lastUpdated', () => Timestamp.fromDate(DateTime.now()));

    // If coords provided, keep GeoPoint in sync
    final lat = patch['latitude'];
    final lng = patch['longitude'];
    if (lat is num && lng is num) {
      patch['geo'] = GeoPoint(lat.toDouble(), lng.toDouble());
    }

    await _shipments.doc(trackingId).update(patch);

    if (addEvent) {
      final now = DateTime.now();
      await _shipments
          .doc(trackingId)
          .collection('events')
          .add(
            TrackingEvent(
              title: eventTitle ?? 'Updated',
              description: eventDescription ?? 'Shipment updated by admin.',
              location: eventLocation ?? '',
              time: now,
            ).toMap(),
          );
    }
  }

  /// Delete package completely (no longer trackable)
  Future<void> deleteShipment(String trackingId) async {
    // Delete subcollection "events" first (Firestore doesn’t auto-delete)
    final ev = await _shipments.doc(trackingId).collection('events').get();
    for (final d in ev.docs) {
      await d.reference.delete();
    }
    await _shipments.doc(trackingId).delete();
  }

  /// Generates a unique tracking ID like ARX-2601-4832
  Future<String> generateTrackingId() async {
    final now = DateTime.now();
    final yy = (now.year % 100).toString().padLeft(2, '0');
    final mm = now.month.toString().padLeft(2, '0');

    final rnd = Random.secure();
    for (int i = 0; i < 30; i++) {
      final suffix = (rnd.nextInt(9000) + 1000).toString(); // 1000..9999
      final id = 'ARX-$yy$mm-$suffix';

      final doc = await _shipments.doc(id).get();
      if (!doc.exists) return id;
    }

    // fallback (very unlikely)
    return 'ARX-${DateTime.now().millisecondsSinceEpoch}';
  }
}
