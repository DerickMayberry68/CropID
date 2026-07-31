import 'package:flutter/material.dart';

import '../widgets/dashboard_layout.dart';

class FarmerDashboardScreen extends StatelessWidget {
  const FarmerDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DashboardLayout(
        header: _DashboardHeader(),
        railItems: const [
          _RailItem(icon: Icons.dashboard_outlined, label: 'Overview'),
          _RailItem(icon: Icons.map_outlined, label: 'Fields'),
          _RailItem(icon: Icons.science_outlined, label: 'Application Plans'),
          _RailItem(icon: Icons.notifications_outlined, label: 'Alerts'),
          _RailItem(icon: Icons.assignment_outlined, label: 'Requests'),
        ],
        body: const _DashboardBodyPlaceholder(),
      ),
    );
  }
}

class _DashboardHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Farmer Dashboard',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 4),
                Text(
                  'Fields, Application Plans, Alerts, and Request Status',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
          FilledButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.refresh),
            label: const Text('Refresh'),
          ),
        ],
      ),
    );
  }
}

class _RailItem extends StatelessWidget {
  const _RailItem({
    required this.icon,
    required this.label,
  });

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 8),
      leading: Icon(icon),
      title: Text(label),
      onTap: () {},
    );
  }
}

class _DashboardBodyPlaceholder extends StatelessWidget {
  const _DashboardBodyPlaceholder();

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      padding: const EdgeInsets.all(20),
      crossAxisCount: 2,
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      childAspectRatio: 2.2,
      children: const [
        _PanelCard(title: 'Field Overview'),
        _PanelCard(title: 'Selected Field Detail'),
        _PanelCard(title: 'Saved Application Plans'),
        _PanelCard(title: 'Alert Inbox'),
        _PanelCard(title: 'Service Request Status'),
      ],
    );
  }
}

class _PanelCard extends StatelessWidget {
  const _PanelCard({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Align(
          alignment: Alignment.topLeft,
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ),
      ),
    );
  }
}
