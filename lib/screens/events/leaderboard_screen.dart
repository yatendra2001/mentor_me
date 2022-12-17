import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';

import 'package:mentor_me/models/models.dart';
import 'package:mentor_me/models/tasks_model.dart';
import 'package:mentor_me/repositories/repositories.dart';
import 'package:mentor_me/widgets/user_profile_image.dart';

class LeaderBoardScreen extends StatefulWidget {
  final TaskModel taskMode;
  final List<Task> task;
  const LeaderBoardScreen({
    Key? key,
    required this.taskMode,
    required this.task,
  }) : super(key: key);

  @override
  State<LeaderBoardScreen> createState() => _LeaderBoardScreenState();
}

class _LeaderBoardScreenState extends State<LeaderBoardScreen> {
  bool loading = false;
  List<Map<User, int>> members = [];

  @override
  void initState() {
    fun();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        leading: IconButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          icon: Icon(Icons.arrow_back_ios_new_outlined),
        ),
        title: Text(
          "LeaderBoard",
          style: TextStyle(
            fontSize: 20.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Column(
        children: [
          Column(
            children:
                members.map((member) => buildTile(member) as Widget).toList(),
          ),
          SizedBox(
            height: 4.h,
          ),
          Column(
            children: widget.task
                .map((task) => BuildTaskCard(
                      task: task,
                      taskModelId: widget.taskMode.id!,
                    ))
                .toList(),
          )
        ],
      ),
    );
  }

  buildTile(Map<User, int> mp) {
    User? user = mp.keys.first;
    int point = mp.values.first;
    return ListTile(
      tileColor: members[0] == mp ? Colors.yellow[100] : Colors.white,
      leading: UserProfileImage(
          radius: 20, profileImageUrl: user.profileImageUrl, iconRadius: 40),
      title: Text(user.displayName),
      trailing: Text("$point points"),
      subtitle: Text(members[0] == mp ? "Winning" : ""),
    );
  }

  Future<void> loadUser(QuerySnapshot snapshot) async {
    for (var doc in snapshot.docs) {
      User user =
          await context.read<UserRepository>().getUserWithId(userId: doc.id);
      members.add({user: doc['points']});
    }
  }

  Future<void> fun() async {
    await FirebaseFirestore.instance
        .collection("Tasks")
        .doc(widget.taskMode.id)
        .collection("leaderboard")
        .get()
        .then((value) {
      loadUser(value).then((value) {
        members.sort(
          (a, b) => a.values.first.compareTo(a.values.first),
        );
        log(members.toString());
        setState(() {});
      });
    });
  }
}

class BuildTaskCard extends StatefulWidget {
  final String taskModelId;
  final Task task;
  const BuildTaskCard({
    Key? key,
    required this.taskModelId,
    required this.task,
  }) : super(key: key);

  @override
  State<BuildTaskCard> createState() => _BuildTaskCardState();
}

class _BuildTaskCardState extends State<BuildTaskCard> {
  List<User> users = [];

  @override
  void initState() {
    funk();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          
          Text(
            widget.task.title,
            style: TextStyle(fontSize: 18.sp),
          ),
          Column(
            children:
                users.map((user) => buildTasktile(user) as Widget).toList(),
          )
        ],
      ),
    );
  }

  buildTasktile(User user) {
    return ListTile(
      title: Text(user.displayName),
    );
  }

  Future<void> funk() async {
    await FirebaseFirestore.instance
        .collection("Tasks")
        .doc(widget.taskModelId)
        .collection("Assigned Tasks")
        .doc(widget.task.id)
        .collection("completed")
        .get()
        .then((value) async {
      for (var doc in value.docs) {
        User user =
            await context.read<UserRepository>().getUserWithId(userId: doc.id);
        users.add(user);
        setState(() {});
      }
    });
  }
}
