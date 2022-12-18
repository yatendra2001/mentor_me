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
                SizedBox(
                  height: 16,
                ),
                Text(
                  "Theory:",
                  style:
                      TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600),
                ),
                SizedBox(
                  height: 4,
                ),
                Text(
                  widget.taskModel.description,
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontStyle: FontStyle.italic,
                  ),
                ),
                SizedBox(
                  height: 12,
                ),
                Text(
                  "${widget.taskModel.urlname} :",
                  style:
                      TextStyle(fontSize: 10.sp, fontWeight: FontWeight.w700),
                ),
                SizedBox(
                  height: 1.h,
                ),
                InkWell(
                  onTap: () {
                    launch(widget.taskModel.url);
                  },
                  child: Text(
                    widget.taskModel.url,
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: Colors.blue,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
                SizedBox(
                  height: 2.h,
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
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            task.title,
            style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600),
          ),
          SizedBox(
            height: 1.h,
          ),
          Text(
            task.detail,
            style: TextStyle(fontSize: 12.sp),
          ),
          SizedBox(
            height: 2.h,
          ),
          Text(
            "${task.urlname} :",
            style: TextStyle(fontSize: 10.sp, fontWeight: FontWeight.w700),
          ),
          SizedBox(
            height: 1.h,
          ),
          GestureDetector(
            onTap: () {
              launch(task.url);
            },
            child: Text(
              task.url,
              style: TextStyle(
                fontSize: 12.sp,
                color: Colors.blue,
                decoration: TextDecoration.underline,
              ),
            ),
          ),
          SizedBox(
            height: 1.h,
          ),
          task.imageUrl == ''
              ? SizedBox.shrink()
              : Image.network(task.imageUrl),
          SizedBox(
            height: 1.h,
          ),
          Center(
              child: Text(
            task.imageName,
            style: TextStyle(fontSize: 8.sp, fontWeight: FontWeight.w800),
          ))
        ],
      ),
    );
  }
}
