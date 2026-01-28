import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../../core/responsive/breakpoints.dart';
import '../../core/widgets/aurex_navbar.dart';
import '../../core/widgets/footer.dart';
import '../../core/widgets/primary_button.dart';
import '../../core/widgets/section_title.dart';

/// ✅ Opacity helper (replaces all withOpacity)
Color _op(Color c, double o) => c.withAlpha((o * 255).round());

class TrackingPage extends StatefulWidget {
  final String? initialTrackingId;
  const TrackingPage({super.key, this.initialTrackingId});

  @override
  State<TrackingPage> createState() => _TrackingPageState();
}

class _TrackingPageState extends State<TrackingPage> {
  static const String heroImage = 'assets/images/image1.webp';

  final _trackingCtrl = TextEditingController();

  bool _loading = false;
  String? _error;
  TrackingResult? _result;

  final List<String> _recent = [];

  final TrackingRepository _repo = TrackingRepository();

  StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>? _shipSub;
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _eventsSub;

  @override
  void initState() {
    super.initState();
    if (widget.initialTrackingId != null &&
        widget.initialTrackingId!.trim().isNotEmpty) {
      _trackingCtrl.text = widget.initialTrackingId!.trim();
      WidgetsBinding.instance.addPostFrameCallback((_) => _track());
    }
  }

  @override
  void dispose() {
    _shipSub?.cancel();
    _eventsSub?.cancel();
    _trackingCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const AurexNavbar(tagline: 'Secure Logistics'),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const _TrackingHero(heroAssetPath: heroImage),
                  _TrackingSearchCard(
                    controller: _trackingCtrl,
                    loading: _loading,
                    error: _error,
                    recent: _recent,
                    onTrack: _track,
                    onPickRecent: (id) {
                      _trackingCtrl.text = id;
                      _track();
                    },
                    onUseSample: (id) {
                      _trackingCtrl.text = id;
                      _track();
                    },
                  ),
                  if (_result != null) ...[
                    _TrackingSummary(result: _result!),
                    _TrackingDetails(result: _result!),
                    _TrackingTimeline(result: _result!),
                    const _TrackingHelpCTA(),
                  ] else ...[
                    const _TrackingHowItWorks(),
                  ],
                  const AurexFooter(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _track() async {
    final raw = _trackingCtrl.text.trim();
    final id = _normalizeId(raw);

    if (id.isEmpty) {
      setState(() {
        _error = 'Enter a tracking number.';
        _result = null;
      });
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
      _result = null;
    });

    // Stop previous listeners
    await _shipSub?.cancel();
    await _eventsSub?.cancel();

    // Listen to shipment doc (real-time)
    _shipSub = _repo
        .watchShipment(id)
        .listen(
          (doc) async {
            if (!mounted) return;

            if (!doc.exists) {
              setState(() {
                _loading = false;
                _error =
                    'Tracking number not found. Check and try again. Example: ARX-2401-0007';
                _result = null;
              });
              return;
            }

            // Also listen to events (real-time)
            _eventsSub ??= _repo.watchEvents(id).listen((qs) {
              if (!mounted) return;
              final events = qs.docs.map(_repo.eventFromDoc).toList()
                ..sort((a, b) => b.time.compareTo(a.time));

              final base = _repo.resultFromDoc(doc, events);

              setState(() {
                _loading = false;
                _error = null;
                _result = base;
                _pushRecent(id);
              });
            });

            // If eventsSub already exists, still update base fields instantly
            if (_eventsSub != null) {
              final events = _result?.events ?? const <TrackingEvent>[];
              final base = _repo.resultFromDoc(doc, events);

              setState(() {
                _loading = false;
                _error = null;
                _result = base;
                _pushRecent(id);
              });
            }
          },
          onError: (e) {
            if (!mounted) return;
            setState(() {
              _loading = false;
              _error =
                  'Failed to load tracking info. Check connection and try again.';
              _result = null;
            });
          },
        );
  }

  void _pushRecent(String id) {
    _recent.remove(id);
    _recent.insert(0, id);
    if (_recent.length > 5) _recent.removeLast();
  }

  String _normalizeId(String input) => input.toUpperCase().replaceAll(' ', '');
}

/* -------------------- FIRESTORE REPO -------------------- */

class TrackingRepository {
  final FirebaseFirestore _db;
  TrackingRepository([FirebaseFirestore? db])
    : _db = db ?? FirebaseFirestore.instance;

  /// Collection name: shipments
  /// Doc ID: trackingId
  CollectionReference<Map<String, dynamic>> get _shipments =>
      _db.collection('shipments');

  Stream<DocumentSnapshot<Map<String, dynamic>>> watchShipment(String id) {
    return _shipments.doc(id).snapshots();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> watchEvents(String id) {
    return _shipments
        .doc(id)
        .collection('events')
        .orderBy('time', descending: true)
        .snapshots();
  }

  TrackingEvent eventFromDoc(QueryDocumentSnapshot<Map<String, dynamic>> d) {
    final data = d.data();
    return TrackingEvent(
      title: (data['title'] ?? '').toString(),
      description: (data['description'] ?? '').toString(),
      location: (data['location'] ?? '').toString(),
      time: _asDate(data['time']) ?? DateTime.now(),
    );
  }

  TrackingResult resultFromDoc(
    DocumentSnapshot<Map<String, dynamic>> doc,
    List<TrackingEvent> events,
  ) {
    final data = doc.data() ?? {};

    final status = _statusFromString((data['status'] ?? 'created').toString());

    final lastUpdated =
        _asDate(data['lastUpdated']) ??
        (events.isNotEmpty ? events.first.time : DateTime.now());

    final eta = _asDate(data['eta']);

    final lat = _asDouble(data['latitude']);
    final lng = _asDouble(data['longitude']);

    return TrackingResult(
      trackingId: (data['trackingId'] ?? doc.id).toString(),
      serviceType: (data['serviceType'] ?? '').toString(),
      origin: (data['origin'] ?? '').toString(),
      destination: (data['destination'] ?? '').toString(),
      packageType: (data['packageType'] ?? '').toString(),
      description: (data['packageDescription'] ?? '').toString(),
      status: status,
      lastUpdated: lastUpdated,
      eta: eta,
      sender: (data['sender'] ?? '').toString(),
      receiver: (data['receiver'] ?? '').toString(),
      currentLocation: (data['currentLocation'] ?? '').toString(),
      latitude: lat,
      longitude: lng,
      events: events,
    );
  }

  DateTime? _asDate(dynamic v) {
    if (v == null) return null;
    if (v is Timestamp) return v.toDate();
    if (v is DateTime) return v;
    return null;
  }

  double _asDouble(dynamic v) {
    if (v == null) return 0;
    if (v is num) return v.toDouble();
    return double.tryParse(v.toString()) ?? 0;
  }

  TrackingStatus _statusFromString(String s) {
    switch (s.toLowerCase()) {
      case 'created':
        return TrackingStatus.created;
      case 'pickedup':
      case 'picked_up':
      case 'picked up':
        return TrackingStatus.pickedUp;
      case 'intransit':
      case 'in_transit':
      case 'in transit':
        return TrackingStatus.inTransit;
      case 'outfordelivery':
      case 'out_for_delivery':
      case 'out for delivery':
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

/* -------------------- HERO -------------------- */

class _TrackingHero extends StatelessWidget {
  final String heroAssetPath;
  const _TrackingHero({required this.heroAssetPath});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final pad = Breakpoints.sectionPadding(context);
    final maxW = Breakpoints.contentMaxWidth(context);
    final isDesktop = Breakpoints.isDesktop(context);

    return Padding(
      padding: pad,
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxW),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(22),
            child: Stack(
              children: [
                Positioned.fill(
                  child: _SafeBgImageOrGradient(assetPath: heroAssetPath),
                ),
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                        colors: [
                          _op(theme.colorScheme.primary, 0.92),
                          _op(theme.colorScheme.primary, 0.58),
                          _op(theme.colorScheme.primary, 0.20),
                        ],
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(isDesktop ? 52 : 24),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 720),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const _Pill(text: 'Tracking • Status • Updates'),
                        const SizedBox(height: 14),
                        Text(
                          'Track your shipment.',
                          style: theme.textTheme.headlineMedium?.copyWith(
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'Enter your tracking number to view real-time status, movement history, and delivery updates.',
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: _op(Colors.white, 0.92),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/* -------------------- SEARCH CARD -------------------- */

class _TrackingSearchCard extends StatelessWidget {
  final TextEditingController controller;
  final bool loading;
  final String? error;
  final List<String> recent;
  final VoidCallback onTrack;
  final void Function(String id) onPickRecent;
  final void Function(String id) onUseSample;

  const _TrackingSearchCard({
    required this.controller,
    required this.loading,
    required this.error,
    required this.recent,
    required this.onTrack,
    required this.onPickRecent,
    required this.onUseSample,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final pad = Breakpoints.sectionPadding(context);
    final maxW = Breakpoints.contentMaxWidth(context);
    final isDesktop = Breakpoints.isDesktop(context);

    // These must exist in Firestore to work (create them via Admin page)
    const samples = ['ARX-2601-5239', 'ARX-2601-3261'];

    return Padding(
      padding: pad.copyWith(top: 10),
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxW),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Enter Tracking Number',
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                      if (recent.isNotEmpty)
                        Text(
                          'Recent',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  if (isDesktop)
                    Row(
                      children: [
                        Expanded(child: _trackingField()),
                        const SizedBox(width: 12),
                        PrimaryButton(
                          label: 'Track',
                          icon: Icons.search_rounded,
                          onPressed: loading ? null : onTrack,
                          isLoading: loading,
                        ),
                      ],
                    )
                  else ...[
                    _trackingField(),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: PrimaryButton(
                        label: 'Track',
                        icon: Icons.search_rounded,
                        onPressed: loading ? null : onTrack,
                        isLoading: loading,
                      ),
                    ),
                  ],
                  if (error != null) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: _op(Colors.red, 0.06),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: _op(Colors.red, 0.18)),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.error_outline_rounded, size: 18),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              error!,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 14),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      ...samples.map(
                        (s) => _SmallChip(
                          label: 'Use sample $s',
                          onTap: () => onUseSample(s),
                        ),
                      ),
                    ],
                  ),
                  if (recent.isNotEmpty) ...[
                    const SizedBox(height: 14),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: recent
                          .map(
                            (r) => _SmallChip(
                              label: r,
                              onTap: () => onPickRecent(r),
                              icon: Icons.history_rounded,
                            ),
                          )
                          .toList(),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _trackingField() {
    return TextField(
      controller: controller,
      textCapitalization: TextCapitalization.characters,
      decoration: const InputDecoration(
        hintText: 'e.g. ARX-2401-0007',
        prefixIcon: Icon(Icons.confirmation_number_outlined),
      ),
      onSubmitted: (_) => onTrack(),
    );
  }
}

/* -------------------- SUMMARY -------------------- */

class _TrackingSummary extends StatelessWidget {
  final TrackingResult result;
  const _TrackingSummary({required this.result});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final pad = Breakpoints.sectionPadding(context);
    final maxW = Breakpoints.contentMaxWidth(context);
    final isDesktop = Breakpoints.isDesktop(context);

    return Padding(
      padding: pad.copyWith(top: 10),
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxW),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Tracking: ${result.trackingId}',
                              style: theme.textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              '${result.origin} → ${result.destination}',
                              style: theme.textTheme.bodyLarge,
                            ),
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 10,
                              runSpacing: 10,
                              children: [
                                _StatusChip(status: result.status),
                                _InfoChip(
                                  icon: Icons.inventory_2_outlined,
                                  label: result.packageType,
                                ),
                                _InfoChip(
                                  icon: Icons.local_shipping_outlined,
                                  label: result.serviceType,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      if (isDesktop) ...[
                        const SizedBox(width: 14),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              'Last update',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              _fmt(result.lastUpdated),
                              style: theme.textTheme.bodyMedium,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'ETA',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              result.eta == null ? '—' : _fmt(result.eta!),
                              style: theme.textTheme.bodyMedium,
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                  if (!isDesktop) ...[
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _MiniInfo(
                            label: 'Last update',
                            value: _fmt(result.lastUpdated),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _MiniInfo(
                            label: 'ETA',
                            value: result.eta == null ? '—' : _fmt(result.eta!),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/* -------------------- DETAILS + MAP -------------------- */

class _TrackingDetails extends StatelessWidget {
  final TrackingResult result;
  const _TrackingDetails({required this.result});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final pad = Breakpoints.sectionPadding(context);
    final maxW = Breakpoints.contentMaxWidth(context);
    final isDesktop = Breakpoints.isDesktop(context);

    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: maxW),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.only(left: 25),
            child: SectionTitle(
              title: 'Shipment details',
              titleStyle: isDesktop
                  ? null
                  : TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
              subtitle:
                  'Key information about the shipment and the parties involved.',
            ),
          ),
          const SizedBox(height: 14),
          Padding(
            padding: pad.copyWith(top: 10),
            child: Center(
              child: GridView.count(
                crossAxisCount: isDesktop ? 2 : 1,
                mainAxisSpacing: 14,
                crossAxisSpacing: 14,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                childAspectRatio: isDesktop ? 1.7 : 1.15,
                children: [
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(18),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: ScrollConfiguration(
                              behavior: ScrollConfiguration.of(
                                context,
                              ).copyWith(scrollbars: isDesktop ? true : false),
                              child: SingleChildScrollView(
                                child: Column(
                                  children: [
                                    _DetailRow(
                                      label: 'From',
                                      value: result.origin,
                                    ),
                                    _DetailRow(
                                      label: 'To',
                                      value: result.destination,
                                    ),
                                    _DetailRow(
                                      label: 'Service',
                                      value: result.serviceType,
                                    ),
                                    _DetailRow(
                                      label: 'Package',
                                      value: result.packageType,
                                    ),
                                    _DetailRow(
                                      label: 'Description',
                                      value: result.description,
                                    ),
                                    _DetailRow(
                                      label: 'Sender',
                                      value: result.sender,
                                    ),
                                    _DetailRow(
                                      label: 'Receiver',
                                      value: result.receiver,
                                    ),
                                    if (result.currentLocation
                                        .trim()
                                        .isNotEmpty)
                                      _DetailRow(
                                        label: 'Current location',
                                        value: result.currentLocation,
                                      ),
                                    _DetailRow(
                                      label: 'Coordinates',
                                      value:
                                          '${result.latitude.toStringAsFixed(6)}, ${result.longitude.toStringAsFixed(6)}',
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 14),
                          PrimaryButton(
                            label: 'Request Update',
                            outline: true,
                            icon: Icons.refresh_rounded,
                            onPressed: () => context.go('/contact'),
                            height: isDesktop ? 46 : 30,
                          ),
                        ],
                      ),
                    ),
                  ),

                  // ✅ LIVE MAP from latitude/longitude
                  Card(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(18),
                      child: Stack(
                        children: [
                          Positioned.fill(
                            child: _AurexMap(
                              lat: result.latitude,
                              lng: result.longitude,
                            ),
                          ),
                          Positioned(
                            left: 14,
                            top: 14,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 10,
                              ),
                              decoration: BoxDecoration(
                                color: _op(theme.colorScheme.primary, 0.80),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.map_outlined,
                                    size: 18,
                                    color: Colors.white,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Live location',
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Positioned(
                            left: 14,
                            right: 14,
                            bottom: 14,
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: _op(Colors.white, 0.92),
                                borderRadius: BorderRadius.circular(18),
                                border: Border.all(
                                  color: const Color(0xFFE8ECF1),
                                ),
                              ),
                              child: Text(
                                'Lat: ${result.latitude.toStringAsFixed(6)}  •  Lng: ${result.longitude.toStringAsFixed(6)}',
                                style: theme.textTheme.bodyMedium,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AurexMap extends StatelessWidget {
  final double lat;
  final double lng;

  const _AurexMap({required this.lat, required this.lng});

  bool get _valid =>
      lat.abs() <= 90 && lng.abs() <= 180 && !(lat == 0 && lng == 0);

  @override
  Widget build(BuildContext context) {
    if (!_valid) {
      return Container(
        alignment: Alignment.center,
        child: const Text('No valid coordinates yet.'),
      );
    }

    final center = LatLng(lat, lng);

    return FlutterMap(
      options: MapOptions(
        initialCenter: center,
        initialZoom: 10.5,
        interactionOptions: const InteractionOptions(
          flags: InteractiveFlag.all,
        ),
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.aurex.securelogistics',
        ),
        MarkerLayer(
          markers: [
            Marker(
              point: center,
              width: 46,
              height: 46,
              child: Icon(
                Icons.location_on_rounded,
                size: 42,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/* -------------------- TIMELINE -------------------- */

class _TrackingTimeline extends StatelessWidget {
  final TrackingResult result;
  const _TrackingTimeline({required this.result});

  @override
  Widget build(BuildContext context) {
    final pad = Breakpoints.sectionPadding(context);
    final maxW = Breakpoints.contentMaxWidth(context);

    final events = [...result.events]..sort((a, b) => b.time.compareTo(a.time));

    return Padding(
      padding: pad.copyWith(top: 10),
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxW),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SectionTitle(
                title: 'Movement history',
                subtitle: 'A timeline of scanned updates and status changes.',
              ),
              const SizedBox(height: 14),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    children: [
                      if (events.isEmpty)
                        const Text('No events yet.')
                      else
                        for (int i = 0; i < events.length; i++) ...[
                          _TimelineTile(
                            event: events[i],
                            isLast: i == events.length - 1,
                          ),
                          if (i != events.length - 1)
                            const SizedBox(height: 10),
                        ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/* -------------------- EMPTY STATE -------------------- */

class _TrackingHowItWorks extends StatelessWidget {
  const _TrackingHowItWorks();

  @override
  Widget build(BuildContext context) {
    final pad = Breakpoints.sectionPadding(context);
    final maxW = Breakpoints.contentMaxWidth(context);
    final isDesktop = Breakpoints.isDesktop(context);

    const steps = [
      _StepItem(
        title: 'Enter tracking number',
        desc: 'Use the tracking ID you received from Aurex.',
        icon: Icons.confirmation_number_outlined,
      ),
      _StepItem(
        title: 'View status + history',
        desc: 'See current status, last update, and movement timeline.',
        icon: Icons.timeline_rounded,
      ),
      _StepItem(
        title: 'Contact support',
        desc: 'If anything looks wrong, message us with the tracking ID.',
        icon: Icons.support_agent_outlined,
      ),
    ];

    return Padding(
      padding: pad,
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxW),
          child: GridView.count(
            crossAxisCount: isDesktop ? 3 : 1,
            mainAxisSpacing: 14,
            crossAxisSpacing: 14,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            childAspectRatio: isDesktop ? 2.4 : 2.0,
            children: steps.map((s) => _StepCard(item: s)).toList(),
          ),
        ),
      ),
    );
  }
}

/* -------------------- CTA -------------------- */

class _TrackingHelpCTA extends StatelessWidget {
  const _TrackingHelpCTA();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final pad = Breakpoints.sectionPadding(context);
    final maxW = Breakpoints.contentMaxWidth(context);

    return Padding(
      padding: pad.copyWith(top: 10),
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxW),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Need help with this shipment?',
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Send your tracking ID to support and we’ll assist quickly.',
                          style: theme.textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 14),
                  PrimaryButton(
                    label: 'Contact Support',
                    icon: Icons.arrow_forward_rounded,
                    onPressed: () => context.go('/contact'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/* -------------------- UI bits -------------------- */

class _TimelineTile extends StatelessWidget {
  final TrackingEvent event;
  final bool isLast;

  const _TimelineTile({required this.event, required this.isLast});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: _op(theme.colorScheme.primary, 0.10),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFE8ECF1)),
              ),
              child: Icon(
                Icons.check_circle_rounded,
                size: 18,
                color: theme.colorScheme.primary,
              ),
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 46,
                margin: const EdgeInsets.only(top: 6),
                color: const Color(0xFFE8ECF1),
              ),
          ],
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: const Color(0xFFE8ECF1)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        event.title,
                        style: theme.textTheme.titleLarge,
                      ),
                    ),
                    Text(_fmt(event.time), style: theme.textTheme.bodySmall),
                  ],
                ),
                const SizedBox(height: 6),
                Text(event.description, style: theme.textTheme.bodyMedium),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.place_outlined,
                      size: 18,
                      color: _op(theme.colorScheme.primary, 0.70),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        event.location,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _StepCard extends StatelessWidget {
  final _StepItem item;
  const _StepCard({required this.item});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: _op(theme.colorScheme.primary, 0.08),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFE8ECF1)),
              ),
              child: Icon(item.icon, color: theme.colorScheme.primary),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.title, style: theme.textTheme.titleLarge),
                  const SizedBox(height: 6),
                  Text(item.desc, style: theme.textTheme.bodyMedium),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MiniInfo extends StatelessWidget {
  final String label;
  final String value;

  const _MiniInfo({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _op(theme.colorScheme.primary, 0.06),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE8ECF1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          Text(value, style: theme.textTheme.bodyMedium),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 130,
            child: Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          Expanded(child: Text(value, style: theme.textTheme.bodyMedium)),
        ],
      ),
    );
  }
}

class _SmallChip extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final IconData? icon;

  const _SmallChip({required this.label, required this.onTap, this.icon});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: _op(theme.colorScheme.primary, 0.06),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: const Color(0xFFE8ECF1)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 16, color: theme.colorScheme.primary),
              const SizedBox(width: 8),
            ],
            Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _InfoChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: _op(Colors.white, 0.18),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: _op(Colors.white, 0.22)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: theme.colorScheme.primary),
          const SizedBox(width: 8),
          Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w800,
              color: theme.colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final TrackingStatus status;
  const _StatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    IconData icon;
    String text;

    switch (status) {
      case TrackingStatus.created:
        icon = Icons.fiber_new_rounded;
        text = 'Created';
        break;
      case TrackingStatus.pickedUp:
        icon = Icons.storefront_rounded;
        text = 'Picked up';
        break;
      case TrackingStatus.inTransit:
        icon = Icons.local_shipping_rounded;
        text = 'In transit';
        break;
      case TrackingStatus.outForDelivery:
        icon = Icons.delivery_dining_rounded;
        text = 'Out for delivery';
        break;
      case TrackingStatus.delivered:
        icon = Icons.check_circle_rounded;
        text = 'Delivered';
        break;
      case TrackingStatus.delayed:
        icon = Icons.warning_amber_rounded;
        text = 'Delayed';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: _op(theme.colorScheme.primary, 0.08),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: const Color(0xFFE8ECF1)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: theme.colorScheme.primary),
          const SizedBox(width: 8),
          Text(
            text,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  final String text;
  const _Pill({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: _op(Colors.white, 0.16),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: _op(Colors.white, 0.20)),
      ),
      child: Text(
        text,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
          color: _op(Colors.white, 0.92),
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _SafeBgImageOrGradient extends StatelessWidget {
  final String assetPath;
  const _SafeBgImageOrGradient({required this.assetPath});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            _op(theme.colorScheme.primary, 0.28),
            _op(theme.colorScheme.secondary, 0.22),
          ],
        ),
      ),
      child: Image.asset(
        assetPath,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => const SizedBox.expand(),
      ),
    );
  }
}

/* -------------------- Models -------------------- */

enum TrackingStatus {
  created,
  pickedUp,
  inTransit,
  outForDelivery,
  delivered,
  delayed,
}

class TrackingResult {
  final String trackingId;
  final String serviceType;
  final String origin;
  final String destination;
  final String packageType;
  final String description;
  final TrackingStatus status;
  final DateTime lastUpdated;
  final DateTime? eta;
  final String sender;
  final String receiver;

  // ✅ NEW: location fields
  final String currentLocation;
  final double latitude;
  final double longitude;

  final List<TrackingEvent> events;

  const TrackingResult({
    required this.trackingId,
    required this.serviceType,
    required this.origin,
    required this.destination,
    required this.packageType,
    required this.description,
    required this.status,
    required this.lastUpdated,
    required this.eta,
    required this.sender,
    required this.receiver,
    required this.currentLocation,
    required this.latitude,
    required this.longitude,
    required this.events,
  });
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
}

/* -------------------- utils -------------------- */

String _fmt(DateTime dt) {
  String two(int n) => n.toString().padLeft(2, '0');
  final y = dt.year;
  final m = two(dt.month);
  final d = two(dt.day);
  final hh = two(dt.hour);
  final mm = two(dt.minute);
  return '$y-$m-$d  $hh:$mm';
}

class _StepItem {
  final String title;
  final String desc;
  final IconData icon;

  const _StepItem({
    required this.title,
    required this.desc,
    required this.icon,
  });
}
