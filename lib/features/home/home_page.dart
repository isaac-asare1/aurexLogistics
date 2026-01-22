import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/responsive/breakpoints.dart';
import '../../core/widgets/aurex_navbar.dart';
import '../../core/widgets/footer.dart';
import '../../core/widgets/primary_button.dart';
import '../../core/widgets/section_title.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  // Assets (place images here)
  static const String heroImage = 'assets/images/image1.webp';
  static const String service1 = 'images/delivery.jpg';
  static const String service2 = 'images/forklift.jpg';
  static const String service3 = 'images/warehouse2.jpg';
  static const String mainBackgroundImage = 'images/background.jpg';

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
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage(mainBackgroundImage),
                  fit: BoxFit.cover,
                ),
              ),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    _HeroCarousel(
                      slides: const [
                        _HeroSlide(
                          assetPath: "images/logistics_worker.jpg",
                          pill: 'Security-first handling • Verified dispatch',
                          title: 'Secure logistics you can trust.',
                          desc:
                              'We move packages, documents, and high-value items with strict handling standards, clear communication, and accountability.',
                        ),
                        _HeroSlide(
                          assetPath: 'images/containers.jpg',
                          pill:
                              'Corporate logistics • SLAs • Scheduled pickups',
                          title: 'Built for businesses and bulk movement.',
                          desc:
                              'Reliable logistics support for companies: pickups, deliveries, and structured operations that scale.',
                        ),
                        _HeroSlide(
                          assetPath: 'images/warehouse.jpg',
                          pill: 'Warehousing • Inventory • Accountability',
                          title: 'Storage handled with control and clarity.',
                          desc:
                              'Safe storage and inventory handling with organized processing, careful movement, and clear responsibility.',
                        ),
                      ],
                    ),

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
          ),
        ],
      ),
    );
  }
}

class _HeroCarousel extends StatefulWidget {
  final List<_HeroSlide> slides;
  const _HeroCarousel({required this.slides});

  @override
  State<_HeroCarousel> createState() => _HeroCarouselState();
}

class _HeroCarouselState extends State<_HeroCarousel> {
  late final PageController _controller;
  Timer? _timer;
  int _index = 0;

  @override
  void initState() {
    super.initState();
    _controller = PageController(viewportFraction: 1.0, keepPage: true);

    // ✅ Pre-cache hero images (smooth on first slide)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      for (final slide in widget.slides) {
        precacheImage(AssetImage(slide.assetPath), context);
      }
    });

    // Auto-slide
    _timer = Timer.periodic(const Duration(seconds: 7), (_) {
      if (!mounted || widget.slides.isEmpty) return;
      final next = (_index + 1) % widget.slides.length;
      _goTo(next);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  // void _goTo(int i) {
  //   _controller.animateToPage(
  //     i,
  //     duration: const Duration(milliseconds: 650),
  //     curve: Curves.easeInOutCubic,
  //   );
  // }

  void _goTo(int i) {
    final lastIndex = widget.slides.length - 1;

    // Wrap-around forward (last → first)
    if (_index == lastIndex && i == 0) {
      _controller.jumpToPage(0);
      _index = 0;
      return;
    }

    // Wrap-around backward (first → last)
    if (_index == 0 && i == lastIndex) {
      _controller.jumpToPage(lastIndex);
      _index = lastIndex;
      return;
    }

    // Normal animation
    _controller.animateToPage(
      i,
      duration: const Duration(milliseconds: 650),
      curve: Curves.easeInOutCubic,
    );

    _index = i;
  }

  void _prev() {
    if (widget.slides.isEmpty) return;
    final next = (_index - 1) < 0 ? widget.slides.length - 1 : _index - 1;
    _goTo(next);
  }

  void _next() {
    if (widget.slides.isEmpty) return;
    final next = (_index + 1) % widget.slides.length;
    _goTo(next);
  }

  void _go(BuildContext context, String route) {
    context.go(route);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final pad = Breakpoints.sectionPadding(context);
    final maxW = Breakpoints.contentMaxWidth(context);

    // ✅ MediaQuery-based responsiveness (solid on all screens)
    final width = MediaQuery.sizeOf(context).width;
    final isDesktop = width >= 1024;
    final isMobile = width < 650;

    final arrowSize = isDesktop ? 64.0 : 54.0;
    final cardHeight = isDesktop ? 430.0 : (isMobile ? 520.0 : 480.0);

    final card = ClipRRect(
      borderRadius: BorderRadius.circular(22),
      child: SizedBox(
        height: cardHeight,
        child: PageView.builder(
          controller: _controller,
          onPageChanged: (i) => setState(() => _index = i),
          itemCount: widget.slides.length,
          itemBuilder: (_, i) {
            final s = widget.slides[i];
            return Stack(
              children: [
                Positioned.fill(
                  child: _SafeBgImageOrGradient(assetPath: s.assetPath),
                ),

                // Dark overlay (NO withOpacity)
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                        colors: [
                          _op(theme.colorScheme.primary, 0.88),
                          _op(theme.colorScheme.primary, 0.55),
                          _op(theme.colorScheme.primary, 0.18),
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
                        _Pill(text: s.pill),
                        const SizedBox(height: 14),

                        SelectableText(
                          s.title,
                          style: theme.textTheme.headlineLarge?.copyWith(
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 12),

                        SelectableText(
                          s.desc,
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: _op(Colors.white, 0.92),
                          ),
                        ),
                        const SizedBox(height: 22),

                        // Buttons on ALL slides
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

                        const Spacer(),

                        // Indicators
                        Row(
                          children: List.generate(widget.slides.length, (dot) {
                            final active = dot == _index;
                            return AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              margin: const EdgeInsets.only(right: 8),
                              width: active ? 22 : 10,
                              height: 10,
                              decoration: BoxDecoration(
                                color: active
                                    ? _op(Colors.white, 0.90)
                                    : _op(Colors.white, 0.35),
                                borderRadius: BorderRadius.circular(99),
                              ),
                            );
                          }),
                        ),

                        const SizedBox(height: 10),

                        SelectableText(
                          'Fast response • Professional handling • Business-friendly',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: _op(Colors.white, 0.86),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );

    return Container(
      width: double.infinity,
      padding: pad,
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxW),
          child: isDesktop
              ? Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // LEFT big button (outside card)
                    _CarouselArrowButton(
                      size: arrowSize,
                      icon: Icons.chevron_left_rounded,
                      onTap: _prev,
                    ),
                    const SizedBox(width: 12),

                    Expanded(child: card),

                    const SizedBox(width: 12),
                    // RIGHT big button (outside card)
                    _CarouselArrowButton(
                      size: arrowSize,
                      icon: Icons.chevron_right_rounded,
                      onTap: _next,
                    ),
                  ],
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    card,
                    const SizedBox(height: 14),

                    // ✅ On mobile/tablet: arrows BELOW the card (still outside)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _CarouselArrowButton(
                          size: arrowSize,
                          icon: Icons.chevron_left_rounded,
                          onTap: _prev,
                        ),
                        _CarouselArrowButton(
                          size: arrowSize,
                          icon: Icons.chevron_right_rounded,
                          onTap: _next,
                        ),
                      ],
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}

class _CarouselArrowButton extends StatelessWidget {
  final double size;
  final IconData icon;
  final VoidCallback onTap;

  const _CarouselArrowButton({
    required this.size,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: _op(Colors.white, 0.78),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: const Color(0xFFE8ECF1), width: 1.2),
          boxShadow: [
            BoxShadow(
              color: _op(Colors.black, 0.10),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Icon(icon, size: size * 0.62, color: theme.colorScheme.primary),
      ),
    );
  }
}

class _HeroSlide {
  final String assetPath;
  final String pill;
  final String title;
  final String desc;

  const _HeroSlide({
    required this.assetPath,
    required this.pill,
    required this.title,
    required this.desc,
  });
}

Color _op(Color c, double opacity) => c.withAlpha((opacity * 255).round());

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
                whiteText: true,
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
                whiteText: true,
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
              // color: theme.colorScheme.primary.withOpacity(0.06),
              color: const Color.fromARGB(162, 255, 255, 255),
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
                          child: SelectableText(
                            t,
                            style: theme.textTheme.bodyLarge,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                PrimaryButton(
                  label: 'Contact Us',
                  icon: Icons.chat_bubble_outline_rounded,
                  onPressed: () => context.go('/contact'),
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
            SelectableText(item.title, style: theme.textTheme.titleLarge),
            const SizedBox(height: 8),
            SelectableText(item.desc, style: theme.textTheme.bodyMedium),
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
                  SelectableText(item.title, style: theme.textTheme.titleLarge),
                  const SizedBox(height: 6),
                  SelectableText(item.desc, style: theme.textTheme.bodyMedium),
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
      child: SelectableText(
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
