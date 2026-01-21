import 'package:flutter/material.dart';
import '../../core/responsive/breakpoints.dart';
import '../../core/widgets/aurex_navbar.dart';
import '../../core/widgets/footer.dart';
import '../../core/widgets/primary_button.dart';
import '../../core/widgets/section_title.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  // Assets (place images here)
  static const String heroImage = 'assets/images/hero.jpg';
  static const String service1 = 'assets/images/service_delivery.jpg';
  static const String service2 = 'assets/images/service_corporate.jpg';
  static const String service3 = 'assets/images/service_warehouse.jpg';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const AurexNavbar(
            // When you add logo: set useLogoAsset: true and point to your asset path
            // useLogoAsset: true,
            // logoAssetPath: 'assets/icons/logo.svg',
            tagline: 'Secure Logistics',
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  _HeroSection(heroAssetPath: heroImage),
                  _ServicesPreview(
                    items: const [
                      _ServiceItem(
                        title: 'Secure Dispatch & Delivery',
                        desc:
                            'Trusted delivery for documents and parcels with careful handling and verified dispatch.',
                        assetPath: service1,
                      ),
                      _ServiceItem(
                        title: 'Corporate Logistics',
                        desc:
                            'Reliable logistics support for businesses: scheduled pickups, bulk deliveries, and SLAs.',
                        assetPath: service2,
                      ),
                      _ServiceItem(
                        title: 'Warehousing & Inventory',
                        desc:
                            'Safe storage and inventory handling with organized processing and clear accountability.',
                        assetPath: service3,
                      ),
                    ],
                  ),
                  const _HowItWorks(),
                  const _WhyAurex(),
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

class _HeroSection extends StatelessWidget {
  final String heroAssetPath;
  const _HeroSection({required this.heroAssetPath});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final pad = Breakpoints.sectionPadding(context);
    final maxW = Breakpoints.contentMaxWidth(context);
    final isDesktop = Breakpoints.isDesktop(context);

    return Container(
      width: double.infinity,
      padding: pad,
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxW),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(22),
            child: Stack(
              children: [
                // Background: image if available, else a gradient block.
                Positioned.fill(
                  child: _SafeBgImageOrGradient(assetPath: heroAssetPath),
                ),

                // Dark overlay for readability
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                        colors: [
                          theme.colorScheme.primary.withOpacity(0.88),
                          theme.colorScheme.primary.withOpacity(0.55),
                          theme.colorScheme.primary.withOpacity(0.18),
                        ],
                      ),
                    ),
                  ),
                ),

                Padding(
                  padding: EdgeInsets.all(isDesktop ? 56 : 26),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 620),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _Pill(
                          text: 'Security-first handling • Verified dispatch',
                        ),
                        const SizedBox(height: 14),
                        Text(
                          'Secure logistics you can trust.',
                          style: theme.textTheme.headlineLarge?.copyWith(
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'We move packages, documents, and high-value items with strict handling standards, clear communication, and accountability.',
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: Colors.white.withOpacity(0.92),
                          ),
                        ),
                        const SizedBox(height: 22),
                        Wrap(
                          spacing: 12,
                          runSpacing: 12,
                          children: [
                            PrimaryButton(
                              label: 'Get a Quote',
                              icon: Icons.arrow_forward_rounded,
                              onPressed: () => _go(context, '/contact'),
                            ),
                            PrimaryButton(
                              label: 'View Services',
                              outline: true,
                              icon: Icons.local_shipping_outlined,
                              onPressed: () => _go(context, '/services'),
                            ),
                          ],
                        ),
                        const SizedBox(height: 18),
                        Text(
                          'Fast response • Professional handling • Business-friendly',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: Colors.white.withOpacity(0.86),
                            fontWeight: FontWeight.w600,
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

  void _go(BuildContext context, String route) {
    // We’ll keep navigation simple until we wire pages fully
    // (GoRouter is already set up in app_router.dart)
    // ignore: use_build_context_synchronously
    Navigator.of(context).pushNamed(route);
  }
}

class _ServicesPreview extends StatelessWidget {
  final List<_ServiceItem> items;
  const _ServicesPreview({required this.items});

  @override
  Widget build(BuildContext context) {
    final pad = Breakpoints.sectionPadding(context);
    final maxW = Breakpoints.contentMaxWidth(context);
    final isDesktop = Breakpoints.isDesktop(context);

    return Padding(
      padding: pad,
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxW),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SectionTitle(
                title: 'What we do',
                subtitle:
                    'Secure dispatch, corporate logistics, and storage solutions built for reliability and trust.',
              ),
              const SizedBox(height: 20),
              GridView.count(
                crossAxisCount: isDesktop ? 3 : 1,
                mainAxisSpacing: 14,
                crossAxisSpacing: 14,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                childAspectRatio: isDesktop ? 1.35 : 1.2,
                children: items.map((e) => _ServiceCard(item: e)).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HowItWorks extends StatelessWidget {
  const _HowItWorks();

  @override
  Widget build(BuildContext context) {
    final pad = Breakpoints.sectionPadding(context);
    final maxW = Breakpoints.contentMaxWidth(context);
    final isDesktop = Breakpoints.isDesktop(context);

    final steps = const [
      _StepItem(
        title: 'Request',
        desc: 'Send pickup & delivery details and what you’re moving.',
        icon: Icons.edit_note_rounded,
      ),
      _StepItem(
        title: 'Confirm',
        desc: 'We confirm pricing, timelines, and handling requirements.',
        icon: Icons.verified_rounded,
      ),
      _StepItem(
        title: 'Deliver',
        desc: 'Secure movement with status updates until completion.',
        icon: Icons.local_shipping_rounded,
      ),
    ];

    return Padding(
      padding: pad,
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxW),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SectionTitle(
                title: 'How it works',
                subtitle: 'A simple process designed to keep things secure.',
              ),
              const SizedBox(height: 18),
              GridView.count(
                crossAxisCount: isDesktop ? 3 : 1,
                mainAxisSpacing: 14,
                crossAxisSpacing: 14,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                childAspectRatio: isDesktop ? 2.2 : 2.0,
                children: steps.map((e) => _StepCard(item: e)).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _WhyAurex extends StatelessWidget {
  const _WhyAurex();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final pad = Breakpoints.sectionPadding(context);
    final maxW = Breakpoints.contentMaxWidth(context);
    final isDesktop = Breakpoints.isDesktop(context);

    final bullets = const [
      'Security-first handling standards',
      'Verified dispatch & clear accountability',
      'Professional communication and support',
      'Business-friendly operations (bulk, scheduled, SLAs)',
    ];

    return Padding(
      padding: pad,
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
                  title: 'Why Aurex',
                  subtitle:
                      'We’re built around trust, safety, and consistent delivery.',
                ),
                const SizedBox(height: 16),
                ...bullets.map(
                  (t) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.check_circle_rounded, size: 18),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(t, style: theme.textTheme.bodyLarge),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                PrimaryButton(
                  label: 'Contact Us',
                  icon: Icons.chat_bubble_outline_rounded,
                  onPressed: () => Navigator.of(context).pushNamed('/contact'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ServiceCard extends StatelessWidget {
  final _ServiceItem item;
  const _ServiceCard({required this.item});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: _SafeBgImageOrGradient(assetPath: item.assetPath),
              ),
            ),
            const SizedBox(height: 14),
            Text(item.title, style: theme.textTheme.titleLarge),
            const SizedBox(height: 8),
            Text(item.desc, style: theme.textTheme.bodyMedium),
          ],
        ),
      ),
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
                color: theme.colorScheme.primary.withOpacity(0.08),
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
        errorBuilder: (_, __, ___) {
          // If asset not found yet, keep the gradient placeholder
          return const SizedBox.expand();
        },
      ),
    );
  }
}

class _ServiceItem {
  final String title;
  final String desc;
  final String assetPath;

  const _ServiceItem({
    required this.title,
    required this.desc,
    required this.assetPath,
  });
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
