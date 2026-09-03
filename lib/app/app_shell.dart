import 'package:agrivista_field/features/interventions/domain/entities/intervention.dart';
import 'package:agrivista_field/features/interventions/presentation/pages/intervention_detail_page.dart';
import 'package:agrivista_field/features/interventions/presentation/pages/interventions_page.dart';
import 'package:agrivista_field/features/profile/presentation/pages/profile_page.dart';
import 'package:flutter/material.dart';

final class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

final class _AppShellState extends State<AppShell> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_selectedIndex == 0 ? 'AgriVista Field' : 'Profil'),
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: [
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

  void _onInterventionSelected(Intervention intervention) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => InterventionDetailPage(interventionId: intervention.id),
      ),
    );
  }
}
