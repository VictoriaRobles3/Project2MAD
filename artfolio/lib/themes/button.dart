import 'package:flutter/material.dart';

class myButton extends StatelessWidget{
  final Color? color;
  final void Function()? onTap;
  const myButton({super.key, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context){
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(8),

        ),
        padding: const EdgeInsets.all(12),
        child: const Center(child: Text("          ", style: TextStyle(fontSize: 10),)),
      ),
    );
  }
}