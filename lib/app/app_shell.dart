import 'package:agrivista_field/app/app_constants.dart';
import 'package:agrivista_field/features/dashboard/presentation/pages/dashboard_page.dart';
import 'package:agrivista_field/features/interventions/domain/entities/intervention.dart';
import 'package:agrivista_field/features/interventions/presentation/pages/intervention_detail_page.dart';
import 'package:agrivista_field/features/interventions/presentation/pages/interventions_page.dart';
import 'package:agrivista_field/features/interventions/presentation/providers/intervention_filters.dart';
import 'package:agrivista_field/features/profile/presentation/pages/profile_page.dart';
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
    return Scaffold(
      appBar: AppBar(
        title: Text(_selectedIndex == 2 ? 'Profil' : AppConstants.name),
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          DashboardPage(
            onStatusSelected: _openStatus,
            onPrioritySelected: _openPriority,
          ),
          InterventionsPage(onInterventionSelected: _onInterventionSelected),
          const ProfilePage(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          setState(() => _selectedIndex = index);
        },
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
