import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../responsive/breakpoints.dart';
import 'primary_button.dart';

/// Helper to replace withOpacity (avoids deprecation warnings)
Color _op(Color c, double o) => c.withAlpha((o * 255).round());

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

  bool _isSelected(String currentPath, String linkPath) {
    if (linkPath == '/') return currentPath == '/';
    return currentPath.startsWith(linkPath);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final maxW = Breakpoints.contentMaxWidth(context);
    final isDesktop = Breakpoints.isDesktop(context);

    // ✅ Current route for “selected tab stays underlined”
    final currentPath = GoRouterState.of(context).uri.path;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: _op(Colors.white, 0.92),
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
                    _NavLink(
                      label: 'Home',
                      selected: _isSelected(currentPath, '/'),
                      onTap: () => context.go('/'),
                    ),
                    _NavLink(
                      label: 'Services',
                      selected: _isSelected(currentPath, '/services'),
                      onTap: () => context.go('/services'),
                    ),
                    _NavLink(
                      label: 'Tracking',
                      selected: _isSelected(currentPath, '/tracking'),
                      onTap: () => context.go('/tracking'),
                    ),
                    _NavLink(
                      label: 'About',
                      selected: _isSelected(currentPath, '/about'),
                      onTap: () => context.go('/about'),
                    ),
                    _NavLink(
                      label: 'Contact',
                      selected: _isSelected(currentPath, '/contact'),
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
      isScrollControlled: true, // ✅ allows taller sheets
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: DraggableScrollableSheet(
            expand: false,
            initialChildSize: 0.55, // ✅ starts at 55% height
            minChildSize: 0.35,
            maxChildSize: 0.90, // ✅ can grow to 90%
            builder: (_, scrollController) {
              return Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
                child: SingleChildScrollView(
                  controller: scrollController, // ✅ sheet scroll
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
                        label: 'Tracking',
                        onTap: () {
                          Navigator.pop(context);
                          context.go('/tracking');
                        },
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
                      const SizedBox(height: 10),
                    ],
                  ),
                ),
              );
            },
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
            _LogoAsset(path: logoAssetPath),
          ] else ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: _op(theme.colorScheme.primary, 0.07),
                borderRadius: BorderRadius.circular(14),
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

    // final isSvg = path.toLowerCase().endsWith('.svg');

    return Container(
      width: 50,
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: _op(theme.colorScheme.primary, 0.04),
        borderRadius: BorderRadius.circular(14),
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

  /// ✅ keeps underline visible even when not hovered
  final bool selected;

  const _NavLink({
    required this.label,
    required this.onTap,
    this.disabled = false,
    this.selected = false,
  });

  @override
  State<_NavLink> createState() => _NavLinkState();
}

class _NavLinkState extends State<_NavLink> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final baseColor = theme.colorScheme.primary;

    final active = (!widget.disabled) && (widget.selected);

    final textColor = widget.disabled
        ? _op(baseColor, 0.35)
        : (active ? baseColor : _op(baseColor, 0.85));

    // ✅ measure text width so underline is “quite longer”
    final style = theme.textTheme.bodyMedium!.copyWith(
      fontWeight: FontWeight.w700,
      color: textColor,
      letterSpacing: (!widget.disabled && _hover) ? 0.6 : 0.0,
    );

    final tp = TextPainter(
      text: TextSpan(text: widget.label, style: style),
      maxLines: 1,
      textDirection: Directionality.of(context),
    )..layout();

    final underlineWidth = active ? (tp.width + 6) : 0.0;

    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: InkWell(
        onTap: widget.disabled ? null : widget.onTap,
        borderRadius: BorderRadius.circular(12),
        splashColor: Colors.transparent,
        hoverColor: Colors.transparent,
        highlightColor: Colors.transparent,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6),
          child: AnimatedScale(
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOut,
            scale: (!widget.disabled && _hover) ? 1.04 : 1.0,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AnimatedDefaultTextStyle(
                  duration: const Duration(milliseconds: 180),
                  curve: Curves.easeOut,
                  style: style,
                  child: Text(widget.label),
                ),
                const SizedBox(height: 4),

                // ✅ underline: longer + stays for selected tab
                AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  curve: Curves.easeOut,
                  height: 2,
                  width: underlineWidth,
                  decoration: BoxDecoration(
                    color: widget.disabled ? Colors.transparent : baseColor,
                    borderRadius: BorderRadius.circular(99),
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
    final c = theme.colorScheme.primary;

    return ListTile(
      onTap: disabled ? null : onTap,
      title: Text(
        label,
        style: theme.textTheme.titleSmall?.copyWith(
          fontWeight: FontWeight.w800,
          color: disabled ? _op(c, 0.35) : c,
        ),
      ),
      trailing: Icon(
        Icons.chevron_right_rounded,
        color: disabled ? _op(c, 0.25) : _op(c, 0.65),
      ),
    );
  }
}
