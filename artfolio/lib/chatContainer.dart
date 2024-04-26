import 'package:flutter/material.dart';

class ChatContainer extends StatelessWidget{
  final String message;
  const ChatContainer({
    super.key,
    required this.message,
  });

  @override
  Widget build(BuildContext context){
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: Color.fromARGB(255, 127, 142, 243),
      ),
      child: Text(
        message,
        style: const TextStyle(fontSize: 16),
      ),
    );
  }
}