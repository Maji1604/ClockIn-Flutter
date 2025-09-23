import 'package:flutter/material.dart';

/// Empty state widget for when there's no data to display
class EmptyWidget extends StatelessWidget {
  const EmptyWidget({
    super.key,
    required this.message,
    this.icon = Icons.inbox,
    this.iconSize = 64.0,
    this.action,
  });

  final String message;
  final IconData icon;
  final double iconSize;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: iconSize, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              message,
              style: Theme.of(
                context,
              ).textTheme.bodyLarge?.copyWith(color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            if (action != null) ...[const SizedBox(height: 24), action!],
          ],
        ),
      ),
    );
  }
}

/// Empty state for search results
class EmptySearchWidget extends StatelessWidget {
  const EmptySearchWidget({super.key, required this.searchTerm, this.onClear});

  final String searchTerm;
  final VoidCallback? onClear;

  @override
  Widget build(BuildContext context) {
    return EmptyWidget(
      icon: Icons.search_off,
      message: 'No results found for "$searchTerm"',
      action: onClear != null
          ? TextButton(onPressed: onClear, child: const Text('Clear Search'))
          : null,
    );
  }
}

/// Empty state for lists
class EmptyListWidget extends StatelessWidget {
  const EmptyListWidget({
    super.key,
    required this.title,
    this.subtitle,
    this.onAdd,
    this.addButtonText = 'Add Item',
  });

  final String title;
  final String? subtitle;
  final VoidCallback? onAdd;
  final String addButtonText;

  @override
  Widget build(BuildContext context) {
    return EmptyWidget(
      icon: Icons.list_alt,
      message: subtitle != null ? '$title\n$subtitle' : title,
      action: onAdd != null
          ? ElevatedButton.icon(
              onPressed: onAdd,
              icon: const Icon(Icons.add),
              label: Text(addButtonText),
            )
          : null,
    );
  }
}

/// Empty state for specific features
class FeatureEmptyWidget extends StatelessWidget {
  const FeatureEmptyWidget({
    super.key,
    required this.featureName,
    required this.description,
    this.icon,
    this.onGetStarted,
  });

  final String featureName;
  final String description;
  final IconData? icon;
  final VoidCallback? onGetStarted;

  @override
  Widget build(BuildContext context) {
    return EmptyWidget(
      icon: icon ?? Icons.featured_play_list,
      message: '$featureName\n$description',
      action: onGetStarted != null
          ? ElevatedButton(
              onPressed: onGetStarted,
              child: const Text('Get Started'),
            )
          : null,
    );
  }
}
