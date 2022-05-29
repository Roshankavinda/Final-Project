import 'package:flutter/material.dart';

class RoundedIconButton extends StatelessWidget {

  final Color color;
  final IconData icon;
  final VoidCallback onClick;


  const RoundedIconButton({required this.color, required this.icon, required this.onClick});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Material(
        elevation: 5.0,
        color: color,
        borderRadius: BorderRadius.circular(5.0),
        child: MaterialButton(
          onPressed: onClick,
          minWidth: 70.0,
          height: 42.0,
          child: Icon(
            icon,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
