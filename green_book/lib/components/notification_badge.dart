import 'package:flutter/material.dart';

class NotificationBadge extends StatelessWidget {
  final int totalNotificationValue;
  const NotificationBadge({Key? key, required this.totalNotificationValue,}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      decoration: const BoxDecoration(
        color: Colors.redAccent,
        shape: BoxShape.circle
      ),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Text(totalNotificationValue.toString(), style: const TextStyle(fontSize: 20, color: Colors.white),),
        ),
      ),
    );
  }
}
