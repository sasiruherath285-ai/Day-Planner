import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../utils/timeline_utils.dart';
import '../../widgets/app_drawer.dart';
import '../../widgets/month_calendar_card.dart';
import '../auth/sign_in_screen.dart';
import '../day/day_view_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  static const int _displayStartYear = 2026;

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final anchor = DateTime(_displayStartYear, DateTime.now().month);
    final months = generateMonthList(anchor: anchor);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        leading: Builder(
          builder: (ctx) => IconButton(
            icon: const Icon(Icons.menu_rounded),
            tooltip: 'Menu',
            onPressed: () => Scaffold.of(ctx).openDrawer(),
          ),
        ),
        title: const Text(
          'Plan your Day',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.account_circle_outlined),
            tooltip: auth.isAuthenticated ? 'Profile' : 'Sign in',
            onPressed: () {
              if (auth.isAuthenticated) {
                Scaffold.of(context).openEndDrawer();
              } else {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => const SignInScreen(),
                  ),
                );
              }
            },
          ),
        ],
      ),
      drawer: const AppDrawer(),
      endDrawer: auth.isAuthenticated
          ? Drawer(
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CircleAvatar(
                        radius: 40,
                        child: Text(
                          (auth.user?.name.isNotEmpty == true
                                  ? auth.user!.name[0]
                                  : '?')
                              .toUpperCase(),
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        auth.user?.name ?? '',
                        style: theme.textTheme.headlineSmall,
                      ),
                      Text(auth.user?.email ?? ''),
                      const Spacer(),
                      ListTile(
                        leading: const Icon(Icons.logout_rounded),
                        title: const Text('Sign out'),
                        onTap: () async {
                          Navigator.pop(context);
                          await auth.signOut();
                        },
                      ),
                    ],
                  ),
                ),
              ),
            )
          : null,
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
              child: Text(
                '$_displayStartYear',
                textAlign: TextAlign.center,
                style: theme.textTheme.displayLarge?.copyWith(
                  fontWeight: FontWeight.w200,
                  letterSpacing: -2,
                  height: 1,
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final month = months[index];
                  final showYearHeader =
                      index > 0 && months[index - 1].year != month.year;

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (showYearHeader)
                        Padding(
                          padding: const EdgeInsets.only(top: 24, bottom: 12),
                          child: Text(
                            '${month.year}',
                            textAlign: TextAlign.center,
                            style: theme.textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.w300,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                        ),
                      MonthCalendarCard(
                        month: month,
                        onDateSelected: (date) {
                          Navigator.of(context).push(
                            MaterialPageRoute<void>(
                              builder: (_) =>
                                  DayViewScreen(selectedDate: date),
                            ),
                          );
                        },
                      ),
                    ],
                  );
                },
                childCount: months.length,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
