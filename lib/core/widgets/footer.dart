import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../responsive/breakpoints.dart';

class AurexFooter extends StatelessWidget {
  const AurexFooter({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final pad = Breakpoints.sectionPadding(context);
    final maxW = Breakpoints.contentMaxWidth(context);

    return Container(
      width: double.infinity,
      padding: pad.copyWith(top: 44, bottom: 44),
      decoration: BoxDecoration(color: theme.colorScheme.primary),
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxW),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                spacing: 40,
                runSpacing: 28,
                children: [
                  _FooterBlock(
                    title: 'Aurex Secure Logistics',
                    width: 420,
                    children: [
                      Text(
                        'Secure dispatch, corporate logistics, warehousing, and high-value deliveries handled with strict standards and accountability.',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: Colors.white.withOpacity(0.85),
                        ),
                      ),
                    ],
                  ),
                  _FooterBlock(
                    title: 'Quick Links',
                    children: const [
                      _FooterLink(label: 'Home', route: '/'),
                      _FooterLink(label: 'Services', route: '/services'),
                      _FooterLink(label: 'Tracking', route: '/tracking'),
                      _FooterLink(label: 'About', route: '/about'),
                      _FooterLink(label: 'Contact', route: '/contact'),
                    ],
                  ),
                  _FooterBlock(
                    title: 'Contact',
                    children: [
                      _FooterText('Phone: +233 XX XXX XXXX'),
                      _FooterText('Email: hello@aurexsecurelogistics.com'),
                      _FooterText('Location: Accra, Ghana'),
                      const SizedBox(height: 10),
                      Text(
                        'Working Hours: Mon–Sat, 8:00 AM – 6:00 PM',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: Colors.white.withOpacity(0.85),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 28),
              Divider(color: Colors.white.withOpacity(0.18)),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      '© ${DateTime.now().year} Aurex Secure Logistics. All rights reserved.',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.white.withOpacity(0.75),
                      ),
                    ),
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

class _FooterBlock extends StatelessWidget {
  final String title;
  final List<Widget> children;
  final double? width;

  const _FooterBlock({required this.title, required this.children, this.width});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SizedBox(
      width: width,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: theme.textTheme.titleLarge?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 12),
          ...children.map(
            (w) =>
                Padding(padding: const EdgeInsets.only(bottom: 10), child: w),
          ),
        ],
      ),
    );
  }
}

class _FooterText extends StatelessWidget {
  final String text;
  const _FooterText(this.text);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Text(
      text,
      style: theme.textTheme.bodyMedium?.copyWith(
        color: Colors.white.withOpacity(0.85),
      ),
    );
  }
}

class _FooterLink extends StatelessWidget {
  final String label;
  final String route;

  const _FooterLink({required this.label, required this.route});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: () => context.go(route),
      child: Text(
        label,
        style: theme.textTheme.bodyMedium?.copyWith(
          color: Colors.white.withOpacity(0.85),
          decoration: TextDecoration.underline,
          decorationColor: Colors.white.withOpacity(0.35),
        ),
      ),
    );
  }
}
