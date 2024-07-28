import 'package:flutter/material.dart';

class BoxContainer extends StatelessWidget {
  final Widget child;
  final double height;
  final double width;

  const BoxContainer({
    Key? key,
    required this.child,
    required this.height,
    required this.width,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: width,
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade800,
            offset: const Offset(-2.0, -2.0),
            blurRadius: 10,
          ),
        ],
      ),
      child: child,
    );
  }
}
