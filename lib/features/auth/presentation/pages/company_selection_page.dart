import 'package:flutter/material.dart';
import '../../domain/entities/company_membership.dart';

/// Page that displays a list of company memberships for the user to choose from
class CompanySelectionPage extends StatelessWidget {
  final List<CompanyMembership> memberships;

  const CompanySelectionPage({super.key, required this.memberships});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Select Company')),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: memberships.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, idx) {
          final m = memberships[idx];
          return Card(
            child: ListTile(
              title: Text(m.companyName, style: theme.textTheme.titleMedium),
              subtitle: Text(m.companySlug),
              trailing: ElevatedButton(
                child: const Text('Select'),
                onPressed: () {
                  // When selecting a company, navigate back to login and
                  // re-dispatch a login with the selected company slug.
                  // The simplest approach: pop with the selected slug.
                  Navigator.pop(context, m.companySlug);
                },
              ),
            ),
          );
        },
      ),
    );
  }
}
