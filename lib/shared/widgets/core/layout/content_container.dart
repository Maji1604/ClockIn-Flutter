import 'package:flutter/material.dart';

class ContentContainer extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double? maxWidth;
  final bool centerContent;

  const ContentContainer({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.maxWidth = 400,
    this.centerContent = true,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isWideScreen = screenWidth > 600;
    
    Widget content = Container(
      width: double.infinity,
      constraints: maxWidth != null 
        ? BoxConstraints(maxWidth: maxWidth!)
        : null,
      padding: padding ?? EdgeInsets.symmetric(
        horizontal: isWideScreen ? 32 : 24,
        vertical: 32,
      ),
      margin: margin,
      child: child,
    );
    
    if (centerContent) {
      content = Center(child: content);
    }
    
    return content;
  }
}