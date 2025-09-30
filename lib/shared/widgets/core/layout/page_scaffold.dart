import 'package:flutter/material.dart';
import '../../../../core/core.dart';

class PageScaffold extends StatelessWidget {
  final Widget body;
  final String? title;
  final List<Widget>? actions;
  final Widget? floatingActionButton;
  final bool showAppBar;
  final bool resizeToAvoidBottomInset;
  final Color? backgroundColor;

  const PageScaffold({
    super.key,
    required this.body,
    this.title,
    this.actions,
    this.floatingActionButton,
    this.showAppBar = false,
    this.resizeToAvoidBottomInset = true,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor ?? AppColors.surface,
      resizeToAvoidBottomInset: resizeToAvoidBottomInset,
      appBar: showAppBar ? AppBar(
        title: title != null ? Text(title!) : null,
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        actions: actions,
        titleTextStyle: Theme.of(context).textTheme.titleLarge?.copyWith(
          color: AppColors.textPrimary,
          fontWeight: FontWeight.w600,
        ),
        iconTheme: const IconThemeData(
          color: AppColors.textPrimary,
        ),
      ) : null,
      body: SafeArea(child: body),
      floatingActionButton: floatingActionButton,
    );
  }
}