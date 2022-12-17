import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import 'package:mentor_me/models/tasks_model.dart';
import 'package:url_launcher/url_launcher.dart';

class EventTaskDesScreen extends StatefulWidget {
  final TaskModel taskModel;
  final List<Task> tasks;

  const EventTaskDesScreen({
    Key? key,
    required this.taskModel,
    required this.tasks,
  }) : super(key: key);

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
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  widget.taskModel.title,
                  style:
                      TextStyle(fontSize: 20.sp, fontWeight: FontWeight.w400),
                ),
                Text(widget.taskModel.description),
                Text(widget.taskModel.urlname),
                SizedBox(
                  height: 1.h,
                ),
                GestureDetector(
                  onTap: () {
                    launch(widget.taskModel.url);
                  },
                  child: Text(
                    widget.taskModel.url,
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: Colors.blue,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
                Column(
                  children: widget.tasks.map((task) {
                    return buildTaskContainer(task) as Widget;
                  }).toList(),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  buildTaskContainer(Task task) {
    return Container(
      child: Column(
        children: [
          Text(task.title),
          Text(task.detail),
          Text(task.urlname),
          GestureDetector(
            onTap: () {
              launch(task.url);
            },
            child: Text(
              task.url,
              style: TextStyle(
                fontSize: 14.sp,
                color: Colors.blue,
                decoration: TextDecoration.underline,
              ),
            ),
          ),
          Image.network(task.imageUrl),
          Text(task.imageName)
        ],
      ),
    );
  }
}
