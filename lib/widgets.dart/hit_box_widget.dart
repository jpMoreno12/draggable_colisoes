import 'package:flutter/material.dart';

class HitBoxWidget extends StatefulWidget {
  final int? idHitBox;
  final Widget child;
  final double? width;
  final double? height;
  final Color alertOverlaps;
  
  const HitBoxWidget({super.key, required this.child, this.width, this.height, this.idHitBox, required this.alertOverlaps});

  @override
  State<HitBoxWidget> createState() => _HitBoxWidgetState();
}

class _HitBoxWidgetState extends State<HitBoxWidget> {
  Color colorHitbox = Colors.transparent;
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          color: widget.alertOverlaps,
          border: Border.all(
            color: Colors.black,
          )),
      width: widget.width,
      height: widget.height,
      child: Center(child: widget.child),
    );
  }

  
}
