import 'package:aurex_secure_logistics/features/admin/tracking_main_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'tracking_models.dart';

/// ===============================================================
/// AdminTrackingPage (GATE)
/// - Shows login if not signed in
/// - If signed in, checks admins/{uid} exists
/// - If admin => shows the real admin tracking UI
/// ===============================================================
class AdminTrackingPage extends StatelessWidget {
  const AdminTrackingPage({super.key});

  Future<bool> _isAdmin(String uid) async {
    final doc = await FirebaseFirestore.instance
        .collection('admins')
        .doc(uid)
        .get();
    return doc.exists;
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, authSnap) {
        if (authSnap.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final user = authSnap.data;
        if (user == null) return const _AdminLoginScreen();

        return FutureBuilder<bool>(
          future: _isAdmin(user.uid),
          builder: (context, adminSnap) {
            if (adminSnap.connectionState == ConnectionState.waiting) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }

            final isAdmin = adminSnap.data == true;
            if (!isAdmin) return _NotAuthorized(email: user.email ?? '');

            return const _AdminTrackingHome();
          },
        );
      },
    );
  }
}

/// Admin Login Screen
/// ===============================================================
class _AdminLoginScreen extends StatefulWidget {
  const _AdminLoginScreen();

  @override
  State<_AdminLoginScreen> createState() => _AdminLoginScreenState();
}

class _AdminLoginScreenState extends State<_AdminLoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _loading = false;
  bool _obscure = true;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Admin Login')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 460),
          child: Card(
            margin: const EdgeInsets.all(16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Sign in to Admin',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Use your admin email and password.',
                      style: theme.textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 14),

                    TextFormField(
                      controller: _email,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        prefixIcon: Icon(Icons.email_outlined),
                      ),
                      validator: (v) {
                        final x = (v ?? '').trim();
                        if (x.isEmpty) return 'Required';
                        if (!x.contains('@')) return 'Invalid email';
                        return null;
                      },
                    ),
                    const SizedBox(height: 10),

                    TextFormField(
                      controller: _password,
                      obscureText: _obscure,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        prefixIcon: const Icon(Icons.lock_outline),
                        suffixIcon: IconButton(
                          tooltip: _obscure ? 'Show' : 'Hide',
                          onPressed: () => setState(() => _obscure = !_obscure),
                          icon: Icon(
                            _obscure
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                          ),
                        ),
                      ),
                      validator: (v) {
                        final x = (v ?? '').trim();
                        if (x.isEmpty) return 'Required';
                        if (x.length < 6) return 'Min 6 characters';
                        return null;
                      },
                    ),

                    const SizedBox(height: 14),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed: _loading ? null : _signIn,
                        icon: _loading
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(Icons.login_rounded),
                        label: Text(_loading ? 'Signing in...' : 'Sign in'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _signIn() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _email.text.trim(),
        password: _password.text.trim(),
      );
    } on FirebaseAuthException catch (e) {
      _toast('Login failed: ${e.message ?? e.code}');
    } catch (e) {
      _toast('Login failed: $e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _toast(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }
}

class _NotAuthorized extends StatelessWidget {
  final String email;
  const _NotAuthorized({required this.email});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Access'),
        actions: [
          TextButton.icon(
            onPressed: () => FirebaseAuth.instance.signOut(),
            icon: const Icon(Icons.logout_rounded),
            label: const Text('Logout'),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'Signed in as: $email\n\nThis account is not authorized as an admin.\nAsk an existing admin to add you.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// ===============================================================
/// REAL ADMIN TRACKING UI (your original code + AppBar buttons)
/// ===============================================================
class _AdminTrackingHome extends StatefulWidget {
  const _AdminTrackingHome();

  @override
  State<_AdminTrackingHome> createState() => _AdminTrackingHomeState();
}

class _AdminTrackingHomeState extends State<_AdminTrackingHome> {
  final _svc = TrackingAdminService();

  // Create form
  final _formKey = GlobalKey<FormState>();

  final _sender = TextEditingController();
  final _receiver = TextEditingController();
  final _serviceType = TextEditingController();
  final _origin = TextEditingController();
  final _destination = TextEditingController();
  final _packageType = TextEditingController();
  final _packageDesc = TextEditingController();
  final _currentLocation = TextEditingController();
  final _lat = TextEditingController();
  final _lng = TextEditingController();

  TrackingStatus _status = TrackingStatus.created;

  bool _creating = false;

  @override
  void dispose() {
    _sender.dispose();
    _receiver.dispose();
    _serviceType.dispose();
    _origin.dispose();
    _destination.dispose();
    _packageType.dispose();
    _packageDesc.dispose();
    _currentLocation.dispose();
    _lat.dispose();
    _lng.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin • Package Tracking'),
        actions: [
          TextButton.icon(
            onPressed: () => _openAddAdminSheet(context),
            icon: const Icon(Icons.person_add_alt_1_rounded),
            label: const Text('Add Admin'),
          ),
          const SizedBox(width: 6),
          TextButton.icon(
            onPressed: () => _openAdminsList(context),
            icon: const Icon(Icons.admin_panel_settings_outlined),
            label: const Text('View Admins'),
          ),
          const SizedBox(width: 6),
          TextButton.icon(
            onPressed: () => FirebaseAuth.instance.signOut(),
            icon: const Icon(Icons.logout_rounded),
            label: const Text('Logout'),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, c) {
          final isWide = c.maxWidth >= 980;
          final left = _buildCreateCard(theme);
          final right = _buildList(theme);

          if (!isWide) {
            return ListView(
              padding: const EdgeInsets.all(16),
              children: [left, const SizedBox(height: 14), right],
            );
          }

          return Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(width: 420, child: left),
                const SizedBox(width: 14),
                Expanded(child: right),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<void> _openAddAdminSheet(BuildContext context) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => const _AddAdminSheet(),
    );
  }

  Future<void> _openAdminsList(BuildContext context) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => const _AdminsListSheet(),
    );
  }

  Widget _buildCreateCard(ThemeData theme) {
    return SingleChildScrollView(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Create Package',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Tracking ID will be generated automatically.',
                  style: theme.textTheme.bodyMedium,
                ),
                const SizedBox(height: 14),

                _field(_sender, 'Sender', required: true),
                const SizedBox(height: 10),
                _field(_receiver, 'Receiver', required: true),
                const SizedBox(height: 10),
                _field(
                  _serviceType,
                  'Service Type',
                  hint: 'e.g. Secure Dispatch',
                ),
                const SizedBox(height: 10),
                _field(_origin, 'Origin', required: true),
                const SizedBox(height: 10),
                _field(_destination, 'Destination', required: true),
                const SizedBox(height: 10),
                _field(_packageType, 'Package Type', required: true),
                const SizedBox(height: 10),
                _field(_packageDesc, 'Package Description (optional)'),
                const SizedBox(height: 10),
                _field(_currentLocation, 'Current Location', required: true),
                const SizedBox(height: 10),

                Row(
                  children: [
                    Expanded(
                      child: _field(
                        _lat,
                        'Latitude',
                        required: true,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        validator: _latValidator,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _field(
                        _lng,
                        'Longitude',
                        required: true,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        validator: _lngValidator,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                DropdownButtonFormField<TrackingStatus>(
                  value: _status,
                  decoration: const InputDecoration(labelText: 'Status'),
                  items: TrackingStatus.values
                      .map(
                        (s) => DropdownMenuItem(value: s, child: Text(s.label)),
                      )
                      .toList(),
                  onChanged: (v) => setState(() => _status = v ?? _status),
                ),

                const SizedBox(height: 14),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _creating ? null : _createPackage,
                    icon: _creating
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.add_rounded),
                    label: Text(_creating ? 'Creating...' : 'Create Package'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildList(ThemeData theme) {
    return SingleChildScrollView(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'All Packages',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 10),
              StreamBuilder<List<TrackingShipment>>(
                stream: _svc.streamShipments(),
                builder: (context, snap) {
                  if (snap.connectionState == ConnectionState.waiting) {
                    return const Padding(
                      padding: EdgeInsets.all(18),
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }

                  final items = snap.data ?? [];
                  if (items.isEmpty) {
                    return Padding(
                      padding: const EdgeInsets.all(18),
                      child: Text(
                        'No packages yet. Create one on the left.',
                        style: theme.textTheme.bodyMedium,
                      ),
                    );
                  }

                  return ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: items.length,
                    separatorBuilder: (_, __) => const Divider(height: 18),
                    itemBuilder: (_, i) => _ShipmentTile(
                      shipment: items[i],
                      onDelete: () => _confirmDelete(items[i].trackingId),
                      onSave: (updated) => _saveEdits(updated),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _createPackage() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _creating = true);

    try {
      final id = await _svc.generateTrackingId();

      final shipment = TrackingShipment(
        trackingId: id,
        serviceType: _serviceType.text.trim(),
        origin: _origin.text.trim(),
        destination: _destination.text.trim(),
        packageType: _packageType.text.trim(),
        packageDescription: _packageDesc.text.trim(),
        status: _status,
        lastUpdated: DateTime.now(),
        eta: null,
        sender: _sender.text.trim(),
        receiver: _receiver.text.trim(),
        currentLocation: _currentLocation.text.trim(),
        latitude: double.parse(_lat.text.trim()),
        longitude: double.parse(_lng.text.trim()),
      );

      await _svc.createShipment(shipment);

      if (!mounted) return;

      _formKey.currentState?.reset();
      _sender.clear();
      _receiver.clear();
      _serviceType.clear();
      _origin.clear();
      _destination.clear();
      _packageType.clear();
      _packageDesc.clear();
      _currentLocation.clear();
      _lat.clear();
      _lng.clear();
      setState(() => _status = TrackingStatus.created);

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Created package: $id')));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Create failed: $e')));
    } finally {
      if (mounted) setState(() => _creating = false);
    }
  }

  Future<void> _saveEdits(TrackingShipment updated) async {
    try {
      await _svc.updateShipment(
        updated.trackingId,
        {
          'serviceType': updated.serviceType,
          'origin': updated.origin,
          'destination': updated.destination,
          'packageType': updated.packageType,
          'packageDescription': updated.packageDescription,
          'status': updated.status.key,
          'sender': updated.sender,
          'receiver': updated.receiver,
          'currentLocation': updated.currentLocation,
          'latitude': updated.latitude,
          'longitude': updated.longitude,
          'lastUpdated': Timestamp.fromDate(DateTime.now()),
        },
        addEvent: true,
        eventTitle: updated.status.label,
        eventDescription: 'Shipment details updated by admin.',
        eventLocation: updated.currentLocation,
      );

      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Updated: ${updated.trackingId}')));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Update failed: $e')));
    }
  }

  Future<void> _confirmDelete(String trackingId) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete package?'),
        content: Text(
          'This will permanently delete $trackingId.\nIt will no longer be trackable.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (ok != true) return;

    try {
      await _svc.deleteShipment(trackingId);
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Deleted: $trackingId')));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Delete failed: $e')));
    }
  }

  // ---------- UI helpers ----------
  Widget _field(
    TextEditingController c,
    String label, {
    bool required = false,
    String? hint,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: c,
      keyboardType: keyboardType,
      validator:
          validator ??
          (required
              ? (v) {
                  if (v == null || v.trim().isEmpty) return 'Required';
                  return null;
                }
              : null),
      decoration: InputDecoration(labelText: label, hintText: hint),
    );
  }

  String? _latValidator(String? v) {
    if (v == null || v.trim().isEmpty) return 'Required';
    final n = double.tryParse(v.trim());
    if (n == null) return 'Invalid number';
    if (n < -90 || n > 90) return 'Latitude must be -90..90';
    return null;
  }

  String? _lngValidator(String? v) {
    if (v == null || v.trim().isEmpty) return 'Required';
    final n = double.tryParse(v.trim());
    if (n == null) return 'Invalid number';
    if (n < -180 || n > 180) return 'Longitude  -180..180';
    return null;
  }
}

/// ===============================================================
/// Add Admin Sheet (NO Cloud Functions)
/// Uses Secondary Firebase App Auth so it DOESN'T log out current admin.
/// Also writes admins/{uid} with email.
/// ===============================================================
class _AddAdminSheet extends StatefulWidget {
  const _AddAdminSheet();

  @override
  State<_AddAdminSheet> createState() => _AddAdminSheetState();
}

class _AddAdminSheetState extends State<_AddAdminSheet> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();

  bool _loading = false;
  bool _obscure = true;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    _confirm.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 12,
        bottom: bottom + 16,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Add Admin',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 6),
            const Text('Create a new admin account (email + password).'),
            const SizedBox(height: 14),

            TextFormField(
              controller: _email,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: 'Admin email',
                prefixIcon: Icon(Icons.email_outlined),
              ),
              validator: (v) {
                final x = (v ?? '').trim();
                if (x.isEmpty) return 'Required';
                if (!x.contains('@')) return 'Invalid email';
                return null;
              },
            ),
            const SizedBox(height: 10),

            TextFormField(
              controller: _password,
              obscureText: _obscure,
              decoration: InputDecoration(
                labelText: 'Password',
                prefixIcon: const Icon(Icons.lock_outline),
                suffixIcon: IconButton(
                  tooltip: _obscure ? 'Show' : 'Hide',
                  onPressed: () => setState(() => _obscure = !_obscure),
                  icon: Icon(
                    _obscure
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                  ),
                ),
              ),
              validator: (v) {
                final x = (v ?? '').trim();
                if (x.isEmpty) return 'Required';
                if (x.length < 6) return 'Min 6 characters';
                return null;
              },
            ),
            const SizedBox(height: 10),

            TextFormField(
              controller: _confirm,
              obscureText: _obscure,
              decoration: const InputDecoration(
                labelText: 'Confirm password',
                prefixIcon: Icon(Icons.lock_outline),
              ),
              validator: (v) {
                final x = (v ?? '').trim();
                if (x.isEmpty) return 'Required';
                if (x != _password.text.trim()) return 'Passwords do not match';
                return null;
              },
            ),

            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: _loading ? null : _createAdmin,
                icon: _loading
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.person_add_alt_1_rounded),
                label: Text(_loading ? 'Creating...' : 'Create Admin'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<FirebaseApp> _getSecondaryApp() async {
    try {
      return Firebase.app('secondary-admin');
    } catch (_) {
      // Requires default app already initialized in main()
      final opts = Firebase.app().options;
      return Firebase.initializeApp(name: 'secondary-admin', options: opts);
    }
  }

  Future<void> _createAdmin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);
    try {
      final secondaryApp = await _getSecondaryApp();
      final secondaryAuth = FirebaseAuth.instanceFor(app: secondaryApp);

      final email = _email.text.trim();
      final pass = _password.text.trim();

      final cred = await secondaryAuth.createUserWithEmailAndPassword(
        email: email,
        password: pass,
      );

      final newUser = cred.user;
      if (newUser == null) {
        throw Exception('User creation failed (no user returned).');
      }

      // Save admin record
      await FirebaseFirestore.instance
          .collection('admins')
          .doc(newUser.uid)
          .set({
            'email': email,
            'createdAt': FieldValue.serverTimestamp(),
            'createdBy': FirebaseAuth.instance.currentUser?.uid,
          });

      // Cleanup secondary auth session
      await secondaryAuth.signOut();

      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Admin created: $email')));
    } on FirebaseAuthException catch (e) {
      _toast('Add admin failed: ${e.message ?? e.code}');
    } catch (e) {
      _toast('Add admin failed: $e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _toast(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }
}

/// ===============================================================
/// Admins list sheet (shows emails from admins collection)
/// ===============================================================
class _AdminsListSheet extends StatelessWidget {
  const _AdminsListSheet();

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 12,
        bottom: bottom + 16,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Admins',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 10),
          StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
            stream: FirebaseFirestore.instance
                .collection('admins')
                .orderBy('email')
                .snapshots(),
            builder: (context, snap) {
              if (snap.connectionState == ConnectionState.waiting) {
                return const Padding(
                  padding: EdgeInsets.all(18),
                  child: Center(child: CircularProgressIndicator()),
                );
              }

              final docs = snap.data?.docs ?? [];
              if (docs.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.all(14),
                  child: Text('No admins found yet.'),
                );
              }

              return ListView.separated(
                shrinkWrap: true,
                itemCount: docs.length,
                separatorBuilder: (_, __) => const Divider(height: 12),
                itemBuilder: (_, i) {
                  final data = docs[i].data();
                  final email = (data['email'] ?? '').toString();
                  return ListTile(
                    leading: const Icon(Icons.verified_user_outlined),
                    title: Text(email.isEmpty ? '(no email saved)' : email),
                    subtitle: Text('UID: ${docs[i].id}'),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }
}

/// ===============================================================
/// Your Shipment Tile (unchanged)
/// ===============================================================
class _ShipmentTile extends StatefulWidget {
  final TrackingShipment shipment;
  final VoidCallback onDelete;
  final void Function(TrackingShipment updated) onSave;

  const _ShipmentTile({
    required this.shipment,
    required this.onDelete,
    required this.onSave,
  });

  @override
  State<_ShipmentTile> createState() => _ShipmentTileState();
}

class _ShipmentTileState extends State<_ShipmentTile> {
  bool _edit = false;

  late final _sender = TextEditingController(text: widget.shipment.sender);
  late final _receiver = TextEditingController(text: widget.shipment.receiver);
  late final _serviceType = TextEditingController(
    text: widget.shipment.serviceType,
  );
  late final _origin = TextEditingController(text: widget.shipment.origin);
  late final _destination = TextEditingController(
    text: widget.shipment.destination,
  );
  late final _packageType = TextEditingController(
    text: widget.shipment.packageType,
  );
  late final _packageDesc = TextEditingController(
    text: widget.shipment.packageDescription,
  );
  late final _currentLocation = TextEditingController(
    text: widget.shipment.currentLocation,
  );
  late final _lat = TextEditingController(
    text: widget.shipment.latitude.toString(),
  );
  late final _lng = TextEditingController(
    text: widget.shipment.longitude.toString(),
  );

  late TrackingStatus _status = widget.shipment.status;

  @override
  void dispose() {
    _sender.dispose();
    _receiver.dispose();
    _serviceType.dispose();
    _origin.dispose();
    _destination.dispose();
    _packageType.dispose();
    _packageDesc.dispose();
    _currentLocation.dispose();
    _lat.dispose();
    _lng.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ExpansionTile(
      tilePadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      title: Text(
        widget.shipment.trackingId,
        style: theme.textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w900,
        ),
      ),
      subtitle: Text('Status: ${_status.label}'),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            tooltip: _edit ? 'Cancel' : 'Edit',
            onPressed: () => setState(() => _edit = !_edit),
            icon: Icon(_edit ? Icons.close_rounded : Icons.edit_rounded),
          ),
          IconButton(
            tooltip: 'Delete',
            onPressed: widget.onDelete,
            icon: const Icon(Icons.delete_outline_rounded),
          ),
        ],
      ),
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _row(theme, 'Tracking ID', widget.shipment.trackingId),
              const SizedBox(height: 10),

              _edit
                  ? DropdownButtonFormField<TrackingStatus>(
                      value: _status,
                      decoration: const InputDecoration(labelText: 'Status'),
                      items: TrackingStatus.values
                          .map(
                            (s) => DropdownMenuItem(
                              value: s,
                              child: Text(s.label),
                            ),
                          )
                          .toList(),
                      onChanged: (v) => setState(() => _status = v ?? _status),
                    )
                  : _row(theme, 'Status', _status.label),

              const SizedBox(height: 10),

              if (_edit) ...[
                _tf(_sender, 'Sender'),
                const SizedBox(height: 10),
                _tf(_receiver, 'Receiver'),
                const SizedBox(height: 10),
                _tf(_serviceType, 'Service Type'),
                const SizedBox(height: 10),
                _tf(_origin, 'Origin'),
                const SizedBox(height: 10),
                _tf(_destination, 'Destination'),
                const SizedBox(height: 10),
                _tf(_packageType, 'Package Type'),
                const SizedBox(height: 10),
                _tf(_packageDesc, 'Package Description'),
                const SizedBox(height: 10),
                _tf(_currentLocation, 'Current Location'),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: _tf(
                        _lat,
                        'Latitude',
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _tf(
                        _lng,
                        'Longitude',
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: _save,
                    icon: const Icon(Icons.save_rounded),
                    label: const Text('Save changes'),
                  ),
                ),
              ] else ...[
                _row(theme, 'Sender', widget.shipment.sender),
                _row(theme, 'Receiver', widget.shipment.receiver),
                _row(theme, 'Service', widget.shipment.serviceType),
                _row(theme, 'From', widget.shipment.origin),
                _row(theme, 'To', widget.shipment.destination),
                _row(theme, 'Package', widget.shipment.packageType),
                if (widget.shipment.packageDescription.trim().isNotEmpty)
                  _row(
                    theme,
                    'Description',
                    widget.shipment.packageDescription,
                  ),
                _row(
                  theme,
                  'Current location',
                  widget.shipment.currentLocation,
                ),
                _row(theme, 'Latitude', widget.shipment.latitude.toString()),
                _row(theme, 'Longitude', widget.shipment.longitude.toString()),
              ],
            ],
          ),
        ),
      ],
    );
  }

  void _save() {
    final lat = double.tryParse(_lat.text.trim());
    final lng = double.tryParse(_lng.text.trim());
    if (lat == null || lng == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid latitude/longitude')),
      );
      return;
    }
    if (lat < -90 || lat > 90 || lng < -180 || lng > 180) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Coordinates out of range')));
      return;
    }

    final updated = widget.shipment.copyWith(
      sender: _sender.text.trim(),
      receiver: _receiver.text.trim(),
      serviceType: _serviceType.text.trim(),
      origin: _origin.text.trim(),
      destination: _destination.text.trim(),
      packageType: _packageType.text.trim(),
      packageDescription: _packageDesc.text.trim(),
      currentLocation: _currentLocation.text.trim(),
      latitude: lat,
      longitude: lng,
      status: _status,
      lastUpdated: DateTime.now(),
    );

    widget.onSave(updated);
    setState(() => _edit = false);
  }

  Widget _tf(
    TextEditingController c,
    String label, {
    TextInputType? keyboardType,
  }) {
    return TextField(
      controller: c,
      keyboardType: keyboardType,
      decoration: InputDecoration(labelText: label),
    );
  }

  Widget _row(ThemeData theme, String k, String v) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              k,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          Expanded(child: Text(v, style: theme.textTheme.bodyMedium)),
        ],
      ),
    );
  }
}
