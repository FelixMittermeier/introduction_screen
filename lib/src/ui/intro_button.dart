import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class IntroButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final Widget child;
  final Color? color;

  const IntroButton({Key? key, this.onPressed, required this.child, this.color}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CupertinoButton(onPressed: onPressed, child: child);
  }
}
