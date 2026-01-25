import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/responsive/breakpoints.dart';
import '../../core/widgets/aurex_navbar.dart';
import '../../core/widgets/footer.dart';
import '../../core/widgets/primary_button.dart';
import '../../core/widgets/section_title.dart';

/// Helper to replace withOpacity (avoids deprecation warnings)
Color _op(Color c, double o) => c.withAlpha((o * 255).round());

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  // ✅ Assets (place images here): assets/images/...
  static const String heroImage = 'assets/images/image1.webp';

  // ⚠️ Make sure this exists under assets/images/ and is declared in pubspec.yaml
  static const String teamImage = 'assets/images/logistic_team.jpg';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const AurexNavbar(tagline: 'Secure Logistics'),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: const [
                  _AboutHero(heroAssetPath: heroImage),
                  _MissionVision(),
                  _Values(),
                  _StatsAndTrust(teamAssetPath: teamImage),
                  _AboutCTA(),
                  AurexFooter(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AboutHero extends StatelessWidget {
  final String heroAssetPath;
  const _AboutHero({required this.heroAssetPath});

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
                        const _Pill(
                          text: 'About • Trust • Safety • Reliability',
                        ),
                        const SizedBox(height: 14),
                        Text(
                          'Built around trust and secure handling.',
                          style: theme.textTheme.headlineMedium?.copyWith(
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'Aurex Secure Logistics exists to move items with clear standards, careful handling, and professional communication — from pickup to delivery.',
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: _op(Colors.white, 0.92),
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
                              label: 'View Services',
                              outline: true,
                              icon: Icons.local_shipping_outlined,
                              onPressed: () => context.go('/services'),
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

class _MissionVision extends StatelessWidget {
  const _MissionVision();

  @override
  Widget build(BuildContext context) {
    final pad = Breakpoints.sectionPadding(context);
    final maxW = Breakpoints.contentMaxWidth(context);

    return Padding(
      padding: pad.copyWith(top: 10),
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxW),
          child: LayoutBuilder(
            builder: (context, c) {
              final isWide = c.maxWidth >= 900;

              final mission = const _InfoCard(
                title: 'Our Mission',
                desc:
                    'To deliver secure and reliable logistics services through strict handling standards, accountability, and consistent communication.',
                icon: Icons.flag_outlined,
              );

              final vision = const _InfoCard(
                title: 'Our Vision',
                desc:
                    'To become a trusted leader in secure logistics, known for safety, professionalism, and dependable delivery outcomes.',
                icon: Icons.visibility_outlined,
              );

              if (!isWide) {
                return Column(
                  children: [mission, const SizedBox(height: 14), vision],
                );
              }

              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: mission),
                  const SizedBox(width: 14),
                  Expanded(child: vision),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _Values extends StatelessWidget {
  const _Values();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final pad = Breakpoints.sectionPadding(context);
    final maxW = Breakpoints.contentMaxWidth(context);

    const values = [
      _ValueItem(
        title: 'Security-first mindset',
        desc: 'We reduce risk with careful handling and clear procedures.',
        icon: Icons.shield_outlined,
      ),
      _ValueItem(
        title: 'Accountability',
        desc: 'Clear ownership from pickup to delivery with proper handover.',
        icon: Icons.verified_outlined,
      ),
      _ValueItem(
        title: 'Professional communication',
        desc: 'Consistent updates so clients always know the status.',
        icon: Icons.support_agent_outlined,
      ),
      _ValueItem(
        title: 'Reliability',
        desc: 'Structured operations designed for repeatable results.',
        icon: Icons.schedule_outlined,
      ),
    ];

    return Padding(
      padding: pad.copyWith(top: 10),
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxW),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SectionTitle(
                title: 'Our values',
                subtitle:
                    'The principles that shape how we move items and serve clients.',
              ),
              const SizedBox(height: 18),

              // ✅ Responsive layout with no fixed heights
              LayoutBuilder(
                builder: (context, c) {
                  final w = c.maxWidth;
                  const spacing = 14.0;

                  final cols = w >= 1100 ? 4 : (w >= 760 ? 2 : 1);
                  final itemW = (w - (spacing * (cols - 1))) / cols;

                  return Wrap(
                    spacing: spacing,
                    runSpacing: spacing,
                    children: [
                      for (final v in values)
                        SizedBox(
                          width: itemW,
                          child: _ValueCard(item: v),
                        ),
                    ],
                  );
                },
              ),

              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: _op(theme.colorScheme.primary, 0.06),
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(color: const Color(0xFFE8ECF1)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.lock_outline_rounded, size: 22),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'We’re committed to secure handling standards and a professional delivery experience.',
                        style: theme.textTheme.bodyLarge,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatsAndTrust extends StatelessWidget {
  final String teamAssetPath;
  const _StatsAndTrust({required this.teamAssetPath});

  @override
  Widget build(BuildContext context) {
    final pad = Breakpoints.sectionPadding(context);
    final maxW = Breakpoints.contentMaxWidth(context);

    const stats = [
      _StatItem(label: 'Operational Focus', value: 'Security'),
      _StatItem(label: 'Service Style', value: 'Structured'),
      _StatItem(label: 'Client Promise', value: 'Reliable'),
    ];

    return Padding(
      padding: pad,
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxW),
          child: LayoutBuilder(
            builder: (context, c) {
              final isWide = c.maxWidth >= 900;

              final leftCard = Card(
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SectionTitle(
                        title: 'Trust & operations',
                        subtitle:
                            'We operate with clear steps, structured handover, and consistent communication.',
                      ),
                      const SizedBox(height: 14),
                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: stats.map((s) => _StatPill(item: s)).toList(),
                      ),
                      const SizedBox(height: 14),
                      Text(
                        'If you’re a business, we can support recurring logistics needs with predictable service standards.',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
              );

              final rightImage = Card(
                clipBehavior: Clip.antiAlias,
                child: AspectRatio(
                  aspectRatio: isWide ? 16 / 10 : 16 / 9,
                  child: _SafeBgImageOrGradient(assetPath: teamAssetPath),
                ),
              );

              if (!isWide) {
                return Column(
                  children: [leftCard, const SizedBox(height: 14), rightImage],
                );
              }

              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: leftCard),
                  const SizedBox(width: 14),
                  Expanded(child: rightImage),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _AboutCTA extends StatelessWidget {
  const _AboutCTA();

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
              child: LayoutBuilder(
                builder: (context, c) {
                  final isWide = c.maxWidth >= 700;

                  final title = Text(
                    'Want to work with Aurex?',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  );

                  final desc = Text(
                    'Tell us what you’re moving and your destination — we’ll respond with pricing and timelines.',
                    style: theme.textTheme.bodyMedium,
                  );

                  final button = PrimaryButton(
                    label: 'Contact Us',
                    icon: Icons.arrow_forward_rounded,
                    onPressed: () => context.go('/contact'),
                  );

                  if (isWide) {
                    return Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [title, const SizedBox(height: 8), desc],
                          ),
                        ),
                        const SizedBox(width: 16),
                        button,
                      ],
                    );
                  }

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      title,
                      const SizedBox(height: 8),
                      desc,
                      const SizedBox(height: 14),
                      SizedBox(width: double.infinity, child: button),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final String title;
  final String desc;
  final IconData icon;

  const _InfoCard({
    required this.title,
    required this.desc,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: _op(theme.colorScheme.primary, 0.08),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFE8ECF1)),
              ),
              child: Icon(icon, color: theme.colorScheme.primary),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: theme.textTheme.titleLarge),
                  const SizedBox(height: 8),
                  Text(desc, style: theme.textTheme.bodyMedium),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ValueCard extends StatelessWidget {
  final _ValueItem item;
  const _ValueCard({required this.item});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
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
            const SizedBox(height: 12),
            Text(item.title, style: theme.textTheme.titleLarge),
            const SizedBox(height: 8),
            Text(item.desc, style: theme.textTheme.bodyMedium),
          ],
        ),
      ),
    );
  }
}

class _StatPill extends StatelessWidget {
  final _StatItem item;
  const _StatPill({required this.item});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: _op(theme.colorScheme.primary, 0.06),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: const Color(0xFFE8ECF1)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            item.label,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(width: 8),
          Text('• ${item.value}', style: theme.textTheme.bodyMedium),
        ],
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

class _ValueItem {
  final String title;
  final String desc;
  final IconData icon;

  const _ValueItem({
    required this.title,
    required this.desc,
    required this.icon,
  });
}

class _StatItem {
  final String label;
  final String value;

  const _StatItem({required this.label, required this.value});
}
