import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

class EventTaskDesScreen extends StatefulWidget {
  const EventTaskDesScreen({super.key});

  @override
  State<EventTaskDesScreen> createState() => _EventTaskDesScreenState();
}

class _EventTaskDesScreenState extends State<EventTaskDesScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Text(
                "Details",
                style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
