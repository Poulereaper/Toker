import 'package:flutter/material.dart';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

class MobileFrame extends StatelessWidget {
  final Widget child;

  const MobileFrame({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    // Only show frame on web or desktop
    final bool shouldShowFrame = kIsWeb || 
        (!Platform.isAndroid && !Platform.isIOS);

    if (!shouldShowFrame) {
      return child;
    }

    return Container(
      color: const Color(0xFF1a1a1a),
      child: Center(
        child: Container(
          width: 375, // iPhone width
          height: 812, // iPhone height
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(40),
            border: Border.all(color: Colors.grey[800]!, width: 8),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.5),
                blurRadius: 30,
                spreadRadius: 5,
              ),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: child,
        ),
      ),
    );
  }
}
