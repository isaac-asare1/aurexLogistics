import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/responsive/breakpoints.dart';
import '../../core/widgets/aurex_navbar.dart';
import '../../core/widgets/footer.dart';
import '../../core/widgets/primary_button.dart';
import '../../core/widgets/section_title.dart';

class ServicesPage extends StatelessWidget {
  const ServicesPage({super.key});

  // Assets (place images here)
  static const String heroImage = 'assets/images/services_hero.jpg';

  @override
  Widget build(BuildContext context) {
    final services = const [
      _Service(
        title: 'Secure Dispatch & Delivery',
        desc:
            'Careful handling for parcels and documents with clear accountability and delivery confirmation.',
        assetPath: 'assets/images/service_delivery.jpg',
        bullets: [
          'Same-day / scheduled delivery options',
          'Proof of delivery (POD)',
          'Secure packaging guidance',
        ],
      ),
      _Service(
        title: 'Corporate Logistics',
        desc:
            'Reliable support for companies: bulk movement, scheduled pickups, and consistent service standards.',
        assetPath: 'assets/images/service_corporate.jpg',
        bullets: [
          'Business-friendly operations',
          'Bulk delivery coordination',
          'Clear communication & timelines',
        ],
      ),
      _Service(
        title: 'Warehousing & Inventory',
        desc:
            'Safe storage and organized handling for items that need structured processing and tracking.',
        assetPath: 'assets/images/service_warehouse.jpg',
        bullets: [
          'Organized storage handling',
          'Inventory check-in/check-out process',
          'Careful loading & offloading',
        ],
      ),
      _Service(
        title: 'High-value & Confidential Transport',
        desc:
            'Extra care for sensitive and valuable items with strict handling expectations and controlled movement.',
        assetPath: 'assets/images/service_high_value.jpg',
        bullets: [
          'Strict handling protocols',
          'Discreet movement options',
          'Controlled handover process',
        ],
      ),
    ];

    return Scaffold(
      body: Column(
        children: [
          const AurexNavbar(tagline: 'Secure Logistics'),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const _ServicesHero(heroAssetPath: heroImage),
                  _ServicesGrid(services: services),
                  const _AssuranceSection(),
                  const _ServicesCTA(),
                  const AurexFooter(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ServicesHero extends StatelessWidget {
  final String heroAssetPath;
  const _ServicesHero({required this.heroAssetPath});

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
                          theme.colorScheme.primary.withOpacity(0.88),
                          theme.colorScheme.primary.withOpacity(0.48),
                          theme.colorScheme.primary.withOpacity(0.18),
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
                        _Pill(
                          text: 'Services • Dispatch • Warehousing • Corporate',
                        ),
                        const SizedBox(height: 14),
                        Text(
                          'Services built for safety and reliability.',
                          style: theme.textTheme.headlineMedium?.copyWith(
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'From secure deliveries to business logistics and storage, Aurex is designed to move items with clear standards and accountability.',
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: Colors.white.withOpacity(0.92),
                          ),
                        ),
                        const SizedBox(height: 18),
                        Wrap(
                          spacing: 12,
                          runSpacing: 12,
                          children: [
                            PrimaryButton(
                              label: 'Get a Quote',
                              icon: Icons.arrow_forward_rounded,
                              onPressed: () => context.go('/contact'),
                            ),
                            PrimaryButton(
                              label: 'Call / WhatsApp',
                              outline: true,
                              icon: Icons.phone_in_talk_outlined,
                              onPressed: () => context.go('/contact'),
                            ),
                          ],
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

class _ServicesGrid extends StatelessWidget {
  final List<_Service> services;
  const _ServicesGrid({required this.services});

  @override
  Widget build(BuildContext context) {
    final pad = Breakpoints.sectionPadding(context);
    final maxW = Breakpoints.contentMaxWidth(context);
    final isDesktop = Breakpoints.isDesktop(context);
    final isTablet = Breakpoints.isTablet(context);

    final crossAxisCount = isDesktop ? 2 : (isTablet ? 2 : 1);
    final ratio = isDesktop ? 1.9 : 1.6;

    return Padding(
      padding: pad.copyWith(top: 10),
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxW),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SectionTitle(
                title: 'Our services',
                subtitle:
                    'Aurex Secure Logistics provides secure movement, structured operations, and clear communication from pickup to delivery.',
              ),
              const SizedBox(height: 18),
              GridView.count(
                crossAxisCount: crossAxisCount,
                mainAxisSpacing: 14,
                crossAxisSpacing: 14,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                childAspectRatio: ratio,
                children: services
                    .map((s) => _ServiceCard(service: s))
                    .toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ServiceCard extends StatelessWidget {
  final _Service service;
  const _ServiceCard({required this.service});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Image block
            AspectRatio(
              aspectRatio: 1.0,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: _SafeBgImageOrGradient(assetPath: service.assetPath),
              ),
            ),
            const SizedBox(width: 16),
            // Text block
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(service.title, style: theme.textTheme.titleLarge),
                  const SizedBox(height: 8),
                  Text(service.desc, style: theme.textTheme.bodyMedium),
                  const SizedBox(height: 12),
                  ...service.bullets.map(
                    (b) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.check_circle_rounded,
                            size: 18,
                            color: theme.colorScheme.primary,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              b,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const Spacer(),
                  Align(
                    alignment: Alignment.bottomLeft,
                    child: PrimaryButton(
                      label: 'Request this service',
                      icon: Icons.arrow_forward_rounded,
                      onPressed: () => context.go('/contact'),
                      height: 46,
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

class _AssuranceSection extends StatelessWidget {
  const _AssuranceSection();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final pad = Breakpoints.sectionPadding(context);
    final maxW = Breakpoints.contentMaxWidth(context);
    final isDesktop = Breakpoints.isDesktop(context);

    final items = const [
      _AssuranceItem(
        title: 'Security-first handling',
        desc:
            'We prioritize careful handling standards and clear accountability at every step.',
        icon: Icons.shield_outlined,
      ),
      _AssuranceItem(
        title: 'Clear status updates',
        desc:
            'We keep communication consistent so you always know what’s happening.',
        icon: Icons.notifications_active_outlined,
      ),
      _AssuranceItem(
        title: 'Business-ready operations',
        desc:
            'Structured workflows that work well for businesses and recurring deliveries.',
        icon: Icons.apartment_outlined,
      ),
    ];

    return Padding(
      padding: pad.copyWith(top: 10),
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxW),
          child: Container(
            padding: EdgeInsets.all(isDesktop ? 26 : 18),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withOpacity(0.06),
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: const Color(0xFFE8ECF1)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SectionTitle(
                  title: 'Service assurance',
                  subtitle:
                      'We don’t just move items — we follow standards that reduce risk and increase trust.',
                ),
                const SizedBox(height: 18),
                GridView.count(
                  crossAxisCount: isDesktop ? 3 : 1,
                  mainAxisSpacing: 14,
                  crossAxisSpacing: 14,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  childAspectRatio: isDesktop ? 2.4 : 2.2,
                  children: items.map((e) => _AssuranceCard(item: e)).toList(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _AssuranceCard extends StatelessWidget {
  final _AssuranceItem item;
  const _AssuranceCard({required this.item});

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
                color: theme.colorScheme.primary.withOpacity(0.08),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFE8ECF1)),
              ),
              child: Icon(item.icon, color: theme.colorScheme.primary),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
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

class _ServicesCTA extends StatelessWidget {
  const _ServicesCTA();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final pad = Breakpoints.sectionPadding(context);
    final maxW = Breakpoints.contentMaxWidth(context);

    return Padding(
      padding: pad,
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
                          'Ready to move something securely?',
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Tell us what you’re moving and where it’s going — we’ll respond with pricing and timelines.',
                          style: theme.textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  PrimaryButton(
                    label: 'Get a Quote',
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
            theme.colorScheme.primary.withOpacity(0.28),
            theme.colorScheme.secondary.withOpacity(0.22),
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
        color: Colors.white.withOpacity(0.16),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white.withOpacity(0.20)),
      ),
      child: Text(
        text,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
          color: Colors.white.withOpacity(0.92),
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _Service {
  final String title;
  final String desc;
  final String assetPath;
  final List<String> bullets;

  const _Service({
    required this.title,
    required this.desc,
    required this.assetPath,
    required this.bullets,
  });
}

class _AssuranceItem {
  final String title;
  final String desc;
  final IconData icon;

  const _AssuranceItem({
    required this.title,
    required this.desc,
    required this.icon,
  });
}
