import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../responsive/breakpoints.dart';
import 'primary_button.dart';

class AurexNavbar extends StatelessWidget {
  /// If true, uses [logoAssetPath]. If false, shows "Aurex" text.
  final bool useLogoAsset;

  /// Example: 'assets/icons/logo.svg' or 'assets/icons/logo.png'
  final String logoAssetPath;

  /// Optional: a short tagline next to logo on desktop
  final String? tagline;

  const AurexNavbar({
    super.key,
    this.useLogoAsset = false,
    this.logoAssetPath = 'assets/icons/logo.svg',
    this.tagline,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final maxW = Breakpoints.contentMaxWidth(context);

    final isDesktop = Breakpoints.isDesktop(context);

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.92),
        border: const Border(bottom: BorderSide(color: Color(0xFFE8ECF1))),
      ),
      child: SafeArea(
        bottom: false,
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: maxW),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                children: [
                  _LogoBlock(
                    useLogoAsset: useLogoAsset,
                    logoAssetPath: logoAssetPath,
                    tagline: tagline,
                  ),
                  const Spacer(),

                  // Desktop nav
                  if (isDesktop) ...[
                    _NavLink(label: 'Home', onTap: () => context.go('/')),
                    _NavLink(
                      label: 'Services',
                      onTap: () => context.go('/services'),
                    ),
                    // Similar vibe to the reference site’s "Tracking"
                    // We’ll create this page later if you want it:
                    _NavLink(
                      label: 'Tracking',
                      onTap: () => context.go('/tracking'),
                      disabled: false,
                    ),
                    _NavLink(label: 'About', onTap: () => context.go('/about')),
                    _NavLink(
                      label: 'Contact',
                      onTap: () => context.go('/contact'),
                    ),
                    const SizedBox(width: 12),
                    PrimaryButton(
                      label: 'Get a Quote',
                      icon: Icons.arrow_forward_rounded,
                      onPressed: () => context.go('/contact'),
                    ),
                  ],

                  // Mobile menu button
                  if (!isDesktop) ...[
                    IconButton(
                      tooltip: 'Menu',
                      onPressed: () => _openMobileMenu(context),
                      icon: Icon(
                        Icons.menu_rounded,
                        color: theme.colorScheme.primary,
                      ),
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

  void _openMobileMenu(BuildContext context) {
    final theme = Theme.of(context);

    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (_) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _MobileItem(
                  label: 'Home',
                  onTap: () {
                    Navigator.pop(context);
                    context.go('/');
                  },
                ),
                _MobileItem(
                  label: 'Services',
                  onTap: () {
                    Navigator.pop(context);
                    context.go('/services');
                  },
                ),
                _MobileItem(
                  label: 'Tracking (Soon)',
                  onTap: null,
                  disabled: true,
                ),
                _MobileItem(
                  label: 'About',
                  onTap: () {
                    Navigator.pop(context);
                    context.go('/about');
                  },
                ),
                _MobileItem(
                  label: 'Contact',
                  onTap: () {
                    Navigator.pop(context);
                    context.go('/contact');
                  },
                ),
                const SizedBox(height: 14),
                SizedBox(
                  width: double.infinity,
                  child: PrimaryButton(
                    label: 'Get a Quote',
                    icon: Icons.arrow_forward_rounded,
                    onPressed: () {
                      Navigator.pop(context);
                      context.go('/contact');
                    },
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Aurex Secure Logistics',
                  style: theme.textTheme.bodyMedium,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _LogoBlock extends StatelessWidget {
  final bool useLogoAsset;
  final String logoAssetPath;
  final String? tagline;

  const _LogoBlock({
    required this.useLogoAsset,
    required this.logoAssetPath,
    this.tagline,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: () => context.go('/'),
      borderRadius: BorderRadius.circular(14),
      child: Row(
        children: [
          if (useLogoAsset) ...[
            // Put your logo here:
            // - SVG: assets/icons/logo.svg
            // - PNG: assets/icons/logo.png
            _LogoAsset(path: logoAssetPath),
          ] else ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withOpacity(0.07),
                borderRadius: BorderRadius.circular(14),
                // border: const BorderSide(color: Color(0xFFE8ECF1)),
              ),
              child: Text(
                'Aurex',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w900,
                  color: theme.colorScheme.primary,
                ),
              ),
            ),
          ],
          if (tagline != null) ...[
            const SizedBox(width: 10),
            Text(tagline!, style: theme.textTheme.bodyMedium),
          ],
        ],
      ),
    );
  }
}

class _LogoAsset extends StatelessWidget {
  final String path;
  const _LogoAsset({required this.path});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final isSvg = path.toLowerCase().endsWith('.svg');

    return Container(
      width: 50,
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withOpacity(0.04),
        borderRadius: BorderRadius.circular(14),
        // border: const BorderSide(color: Color(0xFFE8ECF1)),
      ),
      // child: isSvg
      //     ? SvgPicture.asset(path, height: 26)
      //     : Image.asset(path, height: 26, fit: BoxFit.contain),
    );
  }
}

class _NavLink extends StatefulWidget {
  final String label;
  final VoidCallback? onTap;
  final bool disabled;

  const _NavLink({
    required this.label,
    required this.onTap,
    this.disabled = false,
  });

  @override
  State<_NavLink> createState() => _NavLinkState();
}

class _NavLinkState extends State<_NavLink> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final color = widget.disabled
        ? theme.colorScheme.primary.withOpacity(0.35)
        : (_hover
              ? theme.colorScheme.primary
              : theme.colorScheme.primary.withOpacity(0.85));

    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: InkWell(
        onTap: widget.disabled ? null : widget.onTap,
        borderRadius: BorderRadius.circular(12),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          margin: const EdgeInsets.symmetric(horizontal: 6),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: _hover && !widget.disabled
                ? theme.colorScheme.primary.withOpacity(0.06)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            widget.label,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ),
      ),
    );
  }
}

class _MobileItem extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;
  final bool disabled;

  const _MobileItem({
    required this.label,
    required this.onTap,
    this.disabled = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListTile(
      onTap: disabled ? null : onTap,
      title: Text(
        label,
        style: theme.textTheme.titleSmall?.copyWith(
          fontWeight: FontWeight.w800,
          color: disabled
              ? theme.colorScheme.primary.withOpacity(0.35)
              : theme.colorScheme.primary,
        ),
      ),
      trailing: Icon(
        Icons.chevron_right_rounded,
        color: disabled
            ? theme.colorScheme.primary.withOpacity(0.25)
            : theme.colorScheme.primary.withOpacity(0.65),
      ),
    );
  }
}
