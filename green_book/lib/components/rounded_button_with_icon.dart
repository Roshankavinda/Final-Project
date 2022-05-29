import 'package:flutter/material.dart';

class RoundedButtonWithIcon extends StatelessWidget {
  final Color color;
  final String title;
  final VoidCallback onClick;
  final IconData? icon;
  final double? width;

  const RoundedButtonWithIcon({required this.color, required this.title, required this.onClick, this.icon, this.width});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
      child: Material(
        elevation: 5.0,
        color: color,
        borderRadius: BorderRadius.circular(30.0),
        child: MaterialButton(
          onPressed: onClick,
          minWidth: width ?? 200.0,
          height: 42.0,
          child: SizedBox(
            width: width ?? 200,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(
                    icon,
                    color: Colors.white,
                ),
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}