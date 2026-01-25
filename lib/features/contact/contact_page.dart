import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/responsive/breakpoints.dart';
import '../../core/widgets/aurex_navbar.dart';
import '../../core/widgets/footer.dart';
import '../../core/widgets/primary_button.dart';
import '../../core/widgets/section_title.dart';

/// Helper to replace withOpacity (avoids deprecation warnings)
Color _op(Color c, double o) => c.withAlpha((o * 255).round());

class ContactPage extends StatefulWidget {
  const ContactPage({super.key});

  @override
  State<ContactPage> createState() => _ContactPageState();
}

class _ContactPageState extends State<ContactPage> {
  // ====== UPDATE THESE ======
  static const String whatsAppNumber = '+23359155337'; // no + sign
  static const String phoneNumber = '+233 XX XXX XXXX';
  static const String emailAddress = 'hello@aurexsecurelogistics.com';
  static const String locationText = 'Accra, Ghana';

  // Assets
  static const String heroImage = 'images/support_agent.jpg';

  // Form controllers
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _phone = TextEditingController();
  final _email = TextEditingController();
  final _pickup = TextEditingController();
  final _dropoff = TextEditingController();
  final _items = TextEditingController();
  final _notes = TextEditingController();

  bool _loading = false;

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    _email.dispose();
    _pickup.dispose();
    _dropoff.dispose();
    _items.dispose();
    _notes.dispose();
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
                  const _ContactHero(heroAssetPath: heroImage),
                  _ContactBody(
                    formKey: _formKey,
                    loading: _loading,
                    name: _name,
                    phone: _phone,
                    email: _email,
                    pickup: _pickup,
                    dropoff: _dropoff,
                    items: _items,
                    notes: _notes,
                    onSubmit: _handleSubmit,
                    onWhatsApp: _openWhatsApp,
                    onCall: _callPhone,
                    onEmail: _sendEmail,
                  ),
                  const AurexFooter(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);

    final msg = _buildQuoteMessage();
    await _openWhatsApp(message: msg);

    if (mounted) setState(() => _loading = false);
  }

  String _buildQuoteMessage() {
    final lines = [
      'Hello Aurex Secure Logistics, I want a quote:',
      '',
      'Name: ${_name.text.trim()}',
      'Phone: ${_phone.text.trim()}',
      'Email: ${_email.text.trim()}',
      'Pickup: ${_pickup.text.trim()}',
      'Drop-off: ${_dropoff.text.trim()}',
      'Items: ${_items.text.trim()}',
      if (_notes.text.trim().isNotEmpty) 'Notes: ${_notes.text.trim()}',
    ];
    return lines.join('\n');
  }

  Future<void> _openWhatsApp({String? message}) async {
    final text = Uri.encodeComponent(message ?? 'Hello Aurex, I need a quote.');
    final uri = Uri.parse('https://wa.me/$whatsAppNumber?text=$text');
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  Future<void> _callPhone() async {
    final uri = Uri.parse('tel:$phoneNumber');
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  Future<void> _sendEmail() async {
    final subject = Uri.encodeComponent(
      'Quote Request - Aurex Secure Logistics',
    );
    final body = Uri.encodeComponent(_buildQuoteMessage());
    final uri = Uri.parse('mailto:$emailAddress?subject=$subject&body=$body');
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }
}

class _ContactHero extends StatelessWidget {
  final String heroAssetPath;
  const _ContactHero({required this.heroAssetPath});

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
                          _op(theme.colorScheme.primary, 0.90),
                          _op(theme.colorScheme.primary, 0.55),
                          _op(theme.colorScheme.primary, 0.20),
                        ],
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(isDesktop ? 52 : 24),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 680),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const _Pill(text: 'Contact • Get a Quote • Support'),
                        const SizedBox(height: 14),
                        Text(
                          'Get a quote fast.',
                          style: theme.textTheme.headlineMedium?.copyWith(
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'Share pickup & destination details and what you’re moving — we’ll respond with pricing and timelines.',
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

class _ContactBody extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final bool loading;

  final TextEditingController name;
  final TextEditingController phone;
  final TextEditingController email;
  final TextEditingController pickup;
  final TextEditingController dropoff;
  final TextEditingController items;
  final TextEditingController notes;

  final VoidCallback onSubmit;
  final Future<void> Function({String? message}) onWhatsApp;
  final Future<void> Function() onCall;
  final Future<void> Function() onEmail;

  const _ContactBody({
    required this.formKey,
    required this.loading,
    required this.name,
    required this.phone,
    required this.email,
    required this.pickup,
    required this.dropoff,
    required this.items,
    required this.notes,
    required this.onSubmit,
    required this.onWhatsApp,
    required this.onCall,
    required this.onEmail,
  });

  @override
  Widget build(BuildContext context) {
    final pad = Breakpoints.sectionPadding(context);
    final maxW = Breakpoints.contentMaxWidth(context);

    return Padding(
      padding: pad.copyWith(top: 10),
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxW),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SectionTitle(
                title: 'Contact Aurex',
                subtitle:
                    'Use the form for a quote request, or reach us directly via WhatsApp, call, or email.',
              ),
              const SizedBox(height: 18),

              // ✅ NO GridView (no forced height) => fixes overflow
              LayoutBuilder(
                builder: (context, c) {
                  final isWide = c.maxWidth >= 900;

                  if (!isWide) {
                    return Column(
                      children: [
                        _QuoteFormCard(
                          formKey: formKey,
                          loading: loading,
                          name: name,
                          phone: phone,
                          email: email,
                          pickup: pickup,
                          dropoff: dropoff,
                          items: items,
                          notes: notes,
                          onSubmit: onSubmit,
                        ),
                        const SizedBox(height: 14),
                        _DirectContactCard(
                          onWhatsApp: onWhatsApp,
                          onCall: onCall,
                          onEmail: onEmail,
                        ),
                      ],
                    );
                  }

                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: _QuoteFormCard(
                          formKey: formKey,
                          loading: loading,
                          name: name,
                          phone: phone,
                          email: email,
                          pickup: pickup,
                          dropoff: dropoff,
                          items: items,
                          notes: notes,
                          onSubmit: onSubmit,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: _DirectContactCard(
                          onWhatsApp: onWhatsApp,
                          onCall: onCall,
                          onEmail: onEmail,
                        ),
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  static String? _required(String? v) {
    if (v == null || v.trim().isEmpty) return 'This field is required';
    return null;
  }
}

class _QuoteFormCard extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final bool loading;

  final TextEditingController name;
  final TextEditingController phone;
  final TextEditingController email;
  final TextEditingController pickup;
  final TextEditingController dropoff;
  final TextEditingController items;
  final TextEditingController notes;

  final VoidCallback onSubmit;

  const _QuoteFormCard({
    required this.formKey,
    required this.loading,
    required this.name,
    required this.phone,
    required this.email,
    required this.pickup,
    required this.dropoff,
    required this.items,
    required this.notes,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isWide = MediaQuery.sizeOf(context).width >= 900;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Form(
          key: formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Request a Quote',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 12),

              _Row2(
                isWide: isWide,
                left: _Field(
                  controller: name,
                  label: 'Full Name',
                  hint: 'e.g. John Mensah',
                  validator: _ContactBody._required,
                ),
                right: _Field(
                  controller: phone,
                  label: 'Phone Number',
                  hint: 'e.g. +233...',
                  validator: _ContactBody._required,
                ),
              ),
              const SizedBox(height: 12),

              _Field(
                controller: email,
                label: 'Email (optional)',
                hint: 'e.g. you@email.com',
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 12),

              _Field(
                controller: pickup,
                label: 'Pickup Location',
                hint: 'Where should we pick up from?',
                validator: _ContactBody._required,
              ),
              const SizedBox(height: 12),

              _Field(
                controller: dropoff,
                label: 'Drop-off Location',
                hint: 'Where should we deliver to?',
                validator: _ContactBody._required,
              ),
              const SizedBox(height: 12),

              _Field(
                controller: items,
                label: 'What are you moving?',
                hint: 'Documents, parcel, boxes, etc.',
                validator: _ContactBody._required,
              ),
              const SizedBox(height: 12),

              _Field(
                controller: notes,
                label: 'Notes (optional)',
                hint: 'Urgency, special handling, etc.',
                maxLines: 3,
              ),
              const SizedBox(height: 14),

              SizedBox(
                width: double.infinity,
                child: PrimaryButton(
                  label: 'Send Quote Request',
                  icon: Icons.send_rounded,
                  onPressed: loading ? null : onSubmit,
                  isLoading: loading,
                  height: 50,
                ),
              ),
              const SizedBox(height: 10),

              Text(
                'Tip: Quote requests open WhatsApp by default for faster response.',
                style: theme.textTheme.bodySmall,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DirectContactCard extends StatelessWidget {
  final Future<void> Function({String? message}) onWhatsApp;
  final Future<void> Function() onCall;
  final Future<void> Function() onEmail;

  const _DirectContactCard({
    required this.onWhatsApp,
    required this.onCall,
    required this.onEmail,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Reach us directly',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 12),

            _ContactTile(
              icon: Icons.chat_bubble_outline_rounded,
              title: 'WhatsApp',
              subtitle: 'Fast response for quotes & updates',
              onTap: () => onWhatsApp(),
            ),
            const SizedBox(height: 10),

            _ContactTile(
              icon: Icons.phone_in_talk_outlined,
              title: 'Call',
              subtitle: _ContactPageState.phoneNumber,
              onTap: onCall,
            ),
            const SizedBox(height: 10),

            _ContactTile(
              icon: Icons.email_outlined,
              title: 'Email',
              subtitle: _ContactPageState.emailAddress,
              onTap: onEmail,
            ),
            const SizedBox(height: 10),

            _ContactTile(
              icon: Icons.location_on_outlined,
              title: 'Location',
              subtitle: _ContactPageState.locationText,
              onTap: () => context.go('/'),
            ),
            const SizedBox(height: 14),

            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: _op(theme.colorScheme.primary, 0.06),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: const Color(0xFFE8ECF1)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.lock_outline_rounded, size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'We prioritize secure handling standards and clear accountability for every request.',
                      style: theme.textTheme.bodyMedium,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Row2 extends StatelessWidget {
  final bool isWide;
  final Widget left;
  final Widget right;

  const _Row2({required this.isWide, required this.left, required this.right});

  @override
  Widget build(BuildContext context) {
    if (!isWide) {
      return Column(children: [left, const SizedBox(height: 12), right]);
    }

    return Row(
      children: [
        Expanded(child: left),
        const SizedBox(width: 12),
        Expanded(child: right),
      ],
    );
  }
}

class _Field extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final int maxLines;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;

  const _Field({
    required this.controller,
    required this.label,
    required this.hint,
    this.maxLines = 1,
    this.keyboardType,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          keyboardType: keyboardType,
          validator: validator,
          decoration: InputDecoration(hintText: hint),
        ),
      ],
    );
  }
}

class _ContactTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;

  const _ContactTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFFE8ECF1)),
          color: Colors.white,
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: _op(theme.colorScheme.primary, 0.08),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: theme.colorScheme.primary),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: theme.textTheme.titleLarge),
                  const SizedBox(height: 4),
                  Text(subtitle, style: theme.textTheme.bodyMedium),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: _op(theme.colorScheme.primary, 0.60),
            ),
          ],
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
