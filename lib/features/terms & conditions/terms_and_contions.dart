import 'package:aurex_secure_logistics/core/widgets/aurex_navbar.dart';
import 'package:aurex_secure_logistics/core/widgets/footer.dart';
import 'package:flutter/material.dart';
import 'package:aurex_secure_logistics/core/responsive/breakpoints.dart';

class TermsAndConditionsPage extends StatelessWidget {
  const TermsAndConditionsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final pad = Breakpoints.sectionPadding(context);
    final maxW = Breakpoints.contentMaxWidth(context);

    return Scaffold(
      body: SelectionArea(
        child: CustomScrollView(
          slivers: [
            // TOP NAVBAR
            SliverToBoxAdapter(child: const AurexNavbar()),

            // PAGE CONTENT
            SliverToBoxAdapter(
              child: Container(
                color: theme.colorScheme.surface,
                padding: pad.copyWith(top: 24, bottom: 24),
                child: Center(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: maxW),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _HeroHeader(theme: theme),
                        const SizedBox(height: 18),

                        _Card(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _MetaRow(theme: theme),
                              const SizedBox(height: 18),

                              _Section(
                                title: "1. Acceptance of Terms",
                                children: const [
                                  Text(
                                    "By accessing or using Aurex Secure Logistics services, website, or platforms (the “Services”), you agree to these Terms & Conditions. "
                                    "If you do not agree, do not use the Services.",
                                  ),
                                ],
                              ),

                              _Section(
                                title: "2. Services",
                                children: const [
                                  Text(
                                    "Aurex provides logistics, delivery, shipment coordination, tracking, and related services. "
                                    "Service availability may vary by location, carrier, route, weather, and operational constraints.",
                                  ),
                                  SizedBox(height: 10),
                                  _BulletList(
                                    items: [
                                      "Pickup, transport, and delivery (where available).",
                                      "Shipment tracking and status updates (subject to carrier data).",
                                      "Support for domestic and international shipments (where available).",
                                    ],
                                  ),
                                ],
                              ),

                              _Section(
                                title: "3. Eligibility and Accounts",
                                children: const [
                                  Text(
                                    "If you create an account, you are responsible for keeping your login credentials secure and for all activity under your account. "
                                    "You agree to provide accurate and up-to-date information.",
                                  ),
                                ],
                              ),

                              _Section(
                                title: "4. Pricing, Payments, and Quotes",
                                children: const [
                                  Text(
                                    "Prices may be shown as estimates or quotes. Final charges can change due to weight/volume verification, route changes, fuel adjustments, "
                                    "carrier fees, storage/handling, customs charges, taxes, or other third-party costs.",
                                  ),
                                  SizedBox(height: 10),
                                  _BulletList(
                                    items: [
                                      "Payment terms may differ by service type and customer category.",
                                      "Unpaid balances may result in shipment holds or cancellation.",
                                      "Refunds (if any) are subject to service stage and incurred costs.",
                                    ],
                                  ),
                                ],
                              ),

                              _Section(
                                title:
                                    "5. Shipment Details and Customer Responsibilities",
                                children: const [
                                  Text(
                                    "You are responsible for providing accurate shipment information, including recipient details, address, contact number, package description, and value (where required). "
                                    "Incorrect details may cause delays, returns, or extra charges.",
                                  ),
                                  SizedBox(height: 10),
                                  _BulletList(
                                    items: [
                                      "Package must be securely packed and labeled (unless packaging is provided by Aurex).",
                                      "You must ensure the contents are lawful to ship.",
                                      "You must be available (or ensure someone is available) for pickup/delivery when scheduled.",
                                    ],
                                  ),
                                ],
                              ),

                              _Section(
                                title: "6. Prohibited and Restricted Items",
                                children: const [
                                  Text(
                                    "Certain items cannot be shipped due to safety, legal, or carrier restrictions. We may refuse, hold, or report shipments that violate laws or policies.",
                                  ),
                                  SizedBox(height: 10),
                                  _BulletList(
                                    items: [
                                      "Illegal items or contraband.",
                                      "Hazardous materials (unless explicitly supported and documented).",
                                      "Items requiring special permits without proper documentation.",
                                      "Any item prohibited by the destination or transit country rules.",
                                    ],
                                  ),
                                ],
                              ),

                              _Section(
                                title:
                                    "7. Customs, Duties, and International Shipments",
                                children: const [
                                  Text(
                                    "For international shipments, customs clearance may be required. You are responsible for providing accurate documents and paying applicable duties, taxes, and customs fees "
                                    "unless otherwise agreed in writing.",
                                  ),
                                  SizedBox(height: 10),
                                  _BulletList(
                                    items: [
                                      "Delays may occur due to customs inspections or documentation issues.",
                                      "Declared values must be truthful and supported if requested.",
                                    ],
                                  ),
                                ],
                              ),

                              _Section(
                                title: "8. Delivery Timelines and Delays",
                                children: const [
                                  Text(
                                    "Delivery timelines are estimates and not guaranteed unless a written guaranteed service is explicitly offered. "
                                    "Delays can happen due to traffic, weather, security events, mechanical issues, carrier capacity, customs, incorrect addresses, or force majeure.",
                                  ),
                                ],
                              ),

                              _Section(
                                title: "9. Tracking and Notifications",
                                children: const [
                                  Text(
                                    "Tracking updates depend on carrier scans and system availability. "
                                    "Status updates may be delayed or temporarily inaccurate. Notifications (SMS/email/push) are best-effort.",
                                  ),
                                ],
                              ),

                              _Section(
                                title:
                                    "10. Lost, Damaged, or Missing Shipments",
                                children: const [
                                  Text(
                                    "If a shipment is lost or damaged, you must notify Aurex as soon as possible. Claims may require proof of value, photos, and packaging evidence.",
                                  ),
                                  SizedBox(height: 10),
                                  _BulletList(
                                    items: [
                                      "Liability (if any) may be limited by service type, carrier terms, or declared value rules.",
                                      "Some items may be excluded from coverage depending on category and packaging.",
                                    ],
                                  ),
                                ],
                              ),

                              _Section(
                                title: "11. Limitation of Liability",
                                children: const [
                                  Text(
                                    "To the maximum extent permitted by law, Aurex is not liable for indirect, incidental, special, or consequential damages "
                                    "(including loss of profits or business interruption). Where liability applies, it may be limited to the amount paid for the service or a capped amount per shipment "
                                    "(as permitted by law and service terms).",
                                  ),
                                ],
                              ),

                              _Section(
                                title: "12. Cancellations and Returns",
                                children: const [
                                  Text(
                                    "Cancellations may be possible before dispatch or pickup. After dispatch, cancellation may not be possible and fees may apply. "
                                    "Returned or undeliverable shipments may incur additional charges (return shipping, storage, re-delivery).",
                                  ),
                                ],
                              ),

                              _Section(
                                title: "13. Privacy",
                                children: const [
                                  Text(
                                    "We collect and use data to provide the Services (including shipment handling, tracking, support, and security). "
                                    "Please review our Privacy Policy for details on how data is processed.",
                                  ),
                                ],
                              ),

                              _Section(
                                title: "14. Intellectual Property",
                                children: const [
                                  Text(
                                    "All content, logos, brand assets, and platform features belong to Aurex or licensors. "
                                    "You may not copy, modify, distribute, or reverse engineer the platform without written permission.",
                                  ),
                                ],
                              ),

                              _Section(
                                title: "15. Termination",
                                children: const [
                                  Text(
                                    "We may suspend or terminate access if we suspect fraud, abuse, unlawful activity, or violations of these Terms. "
                                    "You may stop using the Services at any time.",
                                  ),
                                ],
                              ),

                              _Section(
                                title: "16. Changes to These Terms",
                                children: const [
                                  Text(
                                    "We may update these Terms occasionally. Continued use of the Services after changes means you accept the updated Terms.",
                                  ),
                                ],
                              ),

                              _Section(
                                title: "17. Governing Law",
                                children: const [
                                  Text(
                                    "These Terms are governed by applicable laws based on the service location and/or company registration jurisdiction, unless otherwise required by law.",
                                  ),
                                ],
                              ),

                              _Section(
                                title: "18. Contact",
                                children: const [
                                  Text(
                                    "For questions or support, contact Aurex Secure Logistics:",
                                  ),
                                  SizedBox(height: 10),
                                  _BulletList(
                                    items: [
                                      "Email: info@aurexfreight.org",
                                      "Phone: +44 20 1234 5678",
                                      "Address: 8-14 Exchange St, Manchester, M2 7HA",
                                    ],
                                  ),
                                ],
                              ),

                              const SizedBox(height: 6),
                            ],
                          ),
                        ),

                        const SizedBox(height: 18),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // FOOTER
            SliverToBoxAdapter(child: const AurexFooter()),
          ],
        ),
      ),
    );
  }
}

class _HeroHeader extends StatelessWidget {
  final ThemeData theme;
  const _HeroHeader({required this.theme});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Terms & Conditions",
          style: theme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          "Please read these terms carefully before using Aurex Secure Logistics services.",
          style: theme.textTheme.bodyLarge?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.75),
          ),
        ),
      ],
    );
  }
}

class _MetaRow extends StatelessWidget {
  final ThemeData theme;
  const _MetaRow({required this.theme});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: [
        _Pill(
          icon: Icons.verified_user,
          label: "Applies to: Website & Services",
          theme: theme,
        ),
      ],
    );
  }
}

class _Pill extends StatelessWidget {
  final IconData icon;
  final String label;
  final ThemeData theme;

  const _Pill({required this.icon, required this.label, required this.theme});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.6),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: theme.dividerColor.withOpacity(0.35)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18),
          const SizedBox(width: 8),
          Text(label, style: theme.textTheme.bodyMedium),
        ],
      ),
    );
  }
}

class _Card extends StatelessWidget {
  final Widget child;
  const _Card({required this.child});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.dividerColor.withOpacity(0.35)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _Section extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _Section({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          ...children.map(
            (w) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: DefaultTextStyle(
                style: theme.textTheme.bodyMedium!.copyWith(
                  height: 1.5,
                  color: theme.colorScheme.onSurface.withOpacity(0.88),
                ),
                child: w,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BulletList extends StatelessWidget {
  final List<String> items;
  const _BulletList({required this.items});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: items
          .map(
            (t) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 7),
                    child: Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.onSurface.withOpacity(0.75),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      t,
                      style: theme.textTheme.bodyMedium?.copyWith(height: 1.5),
                    ),
                  ),
                ],
              ),
            ),
          )
          .toList(),
    );
  }
}
