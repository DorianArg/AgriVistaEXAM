import 'package:agrivista_field/app/app_constants.dart';
import 'package:agrivista_field/features/dashboard/presentation/pages/dashboard_page.dart';
import 'package:agrivista_field/features/interventions/domain/entities/intervention.dart';
import 'package:agrivista_field/features/interventions/presentation/pages/intervention_detail_page.dart';
import 'package:agrivista_field/features/interventions/presentation/pages/interventions_page.dart';
import 'package:agrivista_field/features/interventions/presentation/providers/intervention_filters.dart';
import 'package:agrivista_field/features/profile/presentation/pages/profile_page.dart';
import 'package:agrivista_field/core/utils/responsive_breakpoints.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final class AppShell extends ConsumerStatefulWidget {
  const AppShell({super.key});

  @override
  ConsumerState<AppShell> createState() => _AppShellState();
}

final class _AppShellState extends ConsumerState<AppShell> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isTablet = ResponsiveBreakpoints.isTablet(constraints);
        final content = _buildContent(isTablet: isTablet);

        if (isTablet) {
          return Scaffold(
            key: const Key('tablet-app-shell'),
            body: Row(
              children: [
                SafeArea(
                  child: NavigationRail(
                    key: const Key('tablet-navigation-rail'),
                    selectedIndex: _selectedIndex,
                    onDestinationSelected: _selectDestination,
                    labelType: NavigationRailLabelType.all,
                    destinations: const [
                      NavigationRailDestination(
                        icon: Icon(Icons.dashboard_outlined),
                        selectedIcon: Icon(Icons.dashboard),
                        label: Text('Dashboard'),
                      ),
                      NavigationRailDestination(
                        icon: Icon(Icons.assignment_outlined),
                        selectedIcon: Icon(Icons.assignment),
                        label: Text('Interventions'),
                      ),
                      NavigationRailDestination(
                        icon: Icon(Icons.person_outline),
                        selectedIcon: Icon(Icons.person),
                        label: Text('Profil'),
                      ),
                    ],
                  ),
                ),
                const VerticalDivider(width: 1),
                Expanded(
                  child: Scaffold(appBar: _buildAppBar(), body: content),
                ),
              ],
            ),
          );
        }

        return Scaffold(
          key: const Key('phone-app-shell'),
          appBar: _buildAppBar(),
          body: content,
          bottomNavigationBar: NavigationBar(
            key: const Key('phone-navigation-bar'),
            selectedIndex: _selectedIndex,
            onDestinationSelected: _selectDestination,
            destinations: const [
              NavigationDestination(
                icon: Icon(Icons.dashboard_outlined),
                selectedIcon: Icon(Icons.dashboard),
                label: 'Dashboard',
              ),
              NavigationDestination(
                icon: Icon(Icons.assignment_outlined),
                selectedIcon: Icon(Icons.assignment),
                label: 'Interventions',
              ),
              NavigationDestination(
                icon: Icon(Icons.person_outline),
                selectedIcon: Icon(Icons.person),
                label: 'Profil',
              ),
            ],
          ),
        );
      },
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: Text(_selectedIndex == 2 ? 'Profil' : AppConstants.name),
    );
  }

  Widget _buildContent({required bool isTablet}) {
    return IndexedStack(
      index: _selectedIndex,
      children: [
        DashboardPage(
          onStatusSelected: _openStatus,
          onPrioritySelected: _openPriority,
          isTablet: isTablet,
        ),
        InterventionsPage(
          masterDetail: isTablet,
          onInterventionSelected: isTablet ? null : _onInterventionSelected,
        ),
        ProfilePage(isTablet: isTablet),
      ],
    );
  }

  void _selectDestination(int index) {
    setState(() => _selectedIndex = index);
  }

  void _openStatus(StatutFilter statut) {
    ref
        .read(interventionFiltersProvider.notifier)
        .appliquerStatutDepuisDashboard(statut);
    setState(() => _selectedIndex = 1);
  }

  void _openPriority(PrioriteFilter priorite) {
    ref
        .read(interventionFiltersProvider.notifier)
        .appliquerPrioriteDepuisDashboard(priorite);
    setState(() => _selectedIndex = 1);
  }

  void _onInterventionSelected(Intervention intervention) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => InterventionDetailPage(interventionId: intervention.id),
      ),
    );
  }
}
