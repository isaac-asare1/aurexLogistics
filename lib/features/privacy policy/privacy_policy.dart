import 'package:aurex_secure_logistics/core/widgets/aurex_navbar.dart';
import 'package:aurex_secure_logistics/core/widgets/footer.dart';
import 'package:flutter/material.dart';
import 'package:aurex_secure_logistics/core/responsive/breakpoints.dart';

class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({super.key});

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
                                title: "1. Overview",
                                children: const [
                                  Text(
                                    "This Privacy Policy explains how Aurex Secure Logistics (“Aurex”, “we”, “us”) collects, uses, shares, and protects your information "
                                    "when you use our website, apps, and services (the “Services”).",
                                  ),
                                ],
                              ),

                              _Section(
                                title: "2. Information We Collect",
                                children: const [
                                  Text(
                                    "We collect information you provide directly, information generated when you use the Services, and information from third parties "
                                    "(such as carriers or payment providers) where applicable.",
                                  ),
                                  SizedBox(height: 10),
                                  _BulletList(
                                    items: [
                                      "Identity & contact data: name, phone number, email, address.",
                                      "Shipment data: sender/receiver details, pickup/delivery address, package description, declared value (if provided).",
                                      "Account data: login identifiers, preferences, support interactions.",
                                      "Usage data: pages viewed, actions taken, device/browser details, IP address (where applicable).",
                                    ],
                                  ),
                                ],
                              ),

                              _Section(
                                title: "3. How We Use Your Information",
                                children: const [
                                  Text(
                                    "We use your information to provide, improve, and secure the Services, and to meet legal and operational requirements.",
                                  ),
                                  SizedBox(height: 10),
                                  _BulletList(
                                    items: [
                                      "To create and manage accounts.",
                                      "To process pickups, deliveries, shipment tracking, and customer support.",
                                      "To send notifications (e.g., status updates, confirmations).",
                                      "To prevent fraud, abuse, and security incidents.",
                                      "To improve performance, user experience, and service reliability.",
                                      "To comply with legal obligations (e.g., customs documentation, regulatory requests).",
                                    ],
                                  ),
                                ],
                              ),

                              _Section(
                                title: "4. Legal Bases (Where Applicable)",
                                children: const [
                                  Text(
                                    "Depending on your jurisdiction, we process personal data based on one or more legal grounds such as contractual necessity "
                                    "(to deliver logistics services), legitimate interests (security and service improvement), consent (optional features like marketing), "
                                    "and legal obligations (regulatory compliance).",
                                  ),
                                ],
                              ),

                              _Section(
                                title: "5. How We Share Your Information",
                                children: const [
                                  Text(
                                    "We share information only when necessary to provide the Services or to comply with law.",
                                  ),
                                  SizedBox(height: 10),
                                  _BulletList(
                                    items: [
                                      "Carriers and delivery partners (to move and track shipments).",
                                      "Payment providers (to process payments and prevent fraud).",
                                      "Cloud and infrastructure providers (hosting, analytics, logging).",
                                      "Government or regulatory authorities (e.g., customs) when legally required.",
                                      "Professional advisers (legal/accounting) when necessary.",
                                    ],
                                  ),
                                ],
                              ),

                              _Section(
                                title: "6. Cookies and Analytics",
                                children: const [
                                  Text(
                                    "Our website may use cookies and similar technologies to keep the site working properly, remember preferences, and understand usage patterns. "
                                    "You can control cookies through your browser settings. Some features may not work correctly if cookies are disabled.",
                                  ),
                                ],
                              ),

                              _Section(
                                title: "7. Data Retention",
                                children: const [
                                  Text(
                                    "We keep personal data only as long as needed to provide the Services, meet legal/accounting requirements, resolve disputes, and enforce agreements. "
                                    "Retention periods can vary depending on shipment type and legal obligations.",
                                  ),
                                ],
                              ),

                              _Section(
                                title: "8. Security",
                                children: const [
                                  Text(
                                    "We apply reasonable technical and organizational measures to protect your data (access controls, encryption where appropriate, and monitoring). "
                                    "However, no system is 100% secure, and we cannot guarantee absolute security.",
                                  ),
                                ],
                              ),

                              _Section(
                                title: "9. Your Rights and Choices",
                                children: const [
                                  Text(
                                    "Depending on your location, you may have rights such as access, correction, deletion, objection, restriction, portability, and withdrawing consent.",
                                  ),
                                  SizedBox(height: 10),
                                  _BulletList(
                                    items: [
                                      "Access/Update: request a copy of your data or correct inaccurate details.",
                                      "Delete: request deletion where legally permitted.",
                                      "Opt out: unsubscribe from marketing messages (if any).",
                                      "Consent controls: disable optional permissions like location in your device settings.",
                                    ],
                                  ),
                                ],
                              ),

                              _Section(
                                title: "10. Children’s Privacy",
                                children: const [
                                  Text(
                                    "Our Services are not intended for children. We do not knowingly collect personal data from children. "
                                    "If you believe a child has provided data, contact us and we will take appropriate steps.",
                                  ),
                                ],
                              ),

                              _Section(
                                title: "11. International Data Transfers",
                                children: const [
                                  Text(
                                    "If data is processed outside your country (for example, through cloud infrastructure), we take steps to ensure an appropriate level of protection "
                                    "consistent with applicable laws.",
                                  ),
                                ],
                              ),

                              _Section(
                                title: "12. Third-Party Links",
                                children: const [
                                  Text(
                                    "Our Services may include links to third-party sites or tools. We are not responsible for their privacy practices. "
                                    "Review their policies before providing information.",
                                  ),
                                ],
                              ),

                              _Section(
                                title: "13. Changes to This Policy",
                                children: const [
                                  Text(
                                    "We may update this Privacy Policy from time to time. We will update the “Last updated” date and may provide additional notice where required. "
                                    "By continuing to use the Services, you agree to the updated policy.",
                                  ),
                                ],
                              ),

                              _Section(
                                title: "14. Contact Us",
                                children: const [
                                  Text(
                                    "If you have questions or requests, contact Aurex Secure Logistics:",
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
          "Privacy Policy",
          style: theme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          "How Aurex Secure Logistics collects, uses, and protects your information.",
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
          icon: Icons.lock,
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
