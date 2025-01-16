import 'package:flutter/material.dart';

class TargetWidget extends StatefulWidget {
  final int id;
  final double width;
  final double height;
  const TargetWidget({super.key, required this.id, required this.width, required this.height});

  @override
  State<TargetWidget> createState() => _TargetWidgetState();
}

class _TargetWidgetState extends State<TargetWidget> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: widget.width,
      height: widget.height,
      color: Colors.red.withOpacity(0.5),
    );
  }
}
