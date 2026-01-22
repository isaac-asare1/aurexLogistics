import 'package:aurex_secure_logistics/features/home/home_page.dart';
import 'package:aurex_secure_logistics/features/tracking/tracking_page.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/services/services_page.dart';
import '../../features/about/about_page.dart';
import '../../features/contact/contact_page.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/',
    routes: <RouteBase>[
      GoRoute(
        path: '/',
        name: 'home',
        builder: (context, state) => const HomePage(),
      ),
      GoRoute(
        path: '/services',
        name: 'services',
        builder: (context, state) => const ServicesPage(),
      ),
      GoRoute(
        path: '/tracking',
        name: 'tracking',
        builder: (context, state) => const TrackingPage(),
      ),
      GoRoute(
        path: '/about',
        name: 'about',
        builder: (context, state) => const AboutPage(),
      ),
      GoRoute(
        path: '/contact',
        name: 'contact',
        builder: (context, state) => const ContactPage(),
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, size: 56),
              const SizedBox(height: 12),
              Text(
                'Page not found',
                style: Theme.of(context).textTheme.headlineMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                state.error?.toString() ?? 'That route does not exist.',
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () => context.go('/'),
                child: const Text('Go Home'),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
