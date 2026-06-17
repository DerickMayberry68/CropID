import 'package:flutter/material.dart';

class DashboardLayout extends StatelessWidget {
  const DashboardLayout({
    super.key,
    required this.header,
    required this.railItems,
    required this.body,
  });

  final Widget header;
  final List<Widget> railItems;
  final Widget body;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = constraints.maxWidth >= 1024;
        if (!isDesktop) {
          return Column(
            children: [
              header,
              const Divider(height: 1),
              Expanded(child: body),
            ],
          );
        }

        return Row(
          children: [
            SizedBox(
              width: 240,
              child: Material(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: railItems,
                ),
              ),
            ),
            const VerticalDivider(width: 1),
            Expanded(
              child: Column(
                children: [
                  header,
                  const Divider(height: 1),
                  Expanded(child: body),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
