import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:fluttericon/elusive_icons.dart';
import 'package:fluttericon/entypo_icons.dart';
import 'package:fluttericon/linearicons_free_icons.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_stack/image_stack.dart';
import 'package:intl/intl.dart';
import 'package:mentor_me/screens/events/leaderboard_screen.dart';
import 'package:mentor_me/screens/events/event_task_des_screen.dart';
import 'package:mentor_me/screens/login/widgets/standard_elevated_button.dart';
import 'package:mentor_me/screens/stream_chat/models/chat_type.dart';
import 'package:mentor_me/screens/stream_chat/ui/channel_screen.dart';
import 'package:mentor_me/screens/stream_chat/ui/widgets/groups_inbox.dart';
import 'package:mentor_me/screens/stream_chat/ui/widgets/members_list_sheet.dart';
import 'package:mentor_me/utils/session_helper.dart';
import 'package:page_transition/page_transition.dart';
import 'package:sizer/sizer.dart';
import 'package:stream_chat_flutter/stream_chat_flutter.dart';
import 'package:timeago/timeago.dart' as timeago;

import 'package:mentor_me/models/tasks_model.dart';
import 'package:mentor_me/screens/events/event_room_task_screen.dart';
import 'package:mentor_me/screens/events/event_task_des_screen.dart';
import 'package:mentor_me/screens/stream_chat/ui/widgets/groups_inbox.dart';
import 'package:mentor_me/utils/theme_constants.dart';

import '../../models/event_model.dart' as eve;

class EventRoomScreenArgs {
  final eve.Event event;

  const EventRoomScreenArgs({
    required this.event,
  });
}

class EventRoomScreen extends StatefulWidget {
  EventRoomScreen({
    Key? key,
    required this.event,
  }) : super(key: key);

  static const routeName = 'eventRoomScreen';
  final eve.Event event;

  static Route route({required EventRoomScreenArgs args}) {
    return PageTransition(
      settings: const RouteSettings(name: routeName),
      type: PageTransitionType.rightToLeft,
      child: EventRoomScreen(
        event: args.event,
      ),
    );
  }

  @override
  State<EventRoomScreen> createState() => _EventRoomScreenState();
}

class _EventRoomScreenState extends State<EventRoomScreen> {
  final ScrollController _controller = ScrollController();
  late Channel channel;
  Message? _quotedMessage;
  @override
  void initState() {
    _setChannel();
    super.initState();
  }

  _setChannel() async {
    channel = StreamChat.of(context).client.channel(
          'messaging',
          extraData: {
            'name': widget.event.eventName,
            'members': [],
            'chat_type': ChatType.event,
          },
          id: widget.event.id,
        );
    log(SessionHelper.uid!);
    channel.addMembers([SessionHelper.uid!]);
    await channel.watch();
    // await channel.deleteReaction(, 'love');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DefaultTabController(
        length: 2,
        child: NestedScrollView(
          controller: _controller,
          clipBehavior: Clip.none,
          headerSliverBuilder: (_, __) {
            return [_buildAppBar()];
          },
          body: TabBarView(physics: NeverScrollableScrollPhysics(), children: [
            _tasksList(context),
            _communityChatWidget(),
          ]),
        ),
      ),
    );
  }

  StreamChannel _communityChatWidget() {
    return StreamChannel(
      channel: channel,
      child: Column(
        children: <Widget>[
          Expanded(
            child: MessageListView(
              // threadBuilder: (_, parentMessage) {
              //   return ThreadPage();
              // },
              onMessageSwiped: (message) {
                setState(() {
                  _quotedMessage = message;
                });
              },
              messageBuilder: (context, details, messages, defaultMessage) {
                // Retrieving the message from details
                final message = details.message;
                return defaultMessage.copyWith(
                    message: message,
                    showFlagButton: true,
                    showEditMessage: details.isMyMessage,
                    showCopyMessage: true,
                    showDeleteMessage: details.isMyMessage,
                    showReplyMessage: true,
                    showThreadReplyMessage: true,
                    onReplyTap: (message) {
                      setState(() {
                        _quotedMessage = message;
                      });
                    });
              },
            ),
          ),
          MessageInput(
            quotedMessage: _quotedMessage,
            idleSendButton: const Padding(
              padding: EdgeInsets.all(8.0),
              child: CircleAvatar(
                backgroundColor: Colors.grey,
                radius: 16,
                child: Icon(
                  Icons.arrow_forward,
                  color: kPrimaryWhiteColor,
                  size: 16,
                ),
              ),
            ),
            activeSendButton: const Padding(
              padding: EdgeInsets.all(8.0),
              child: CircleAvatar(
                radius: 16,
                backgroundColor: Colors.black,
                child: Icon(
                  Icons.arrow_upward,
                  size: 16,
                  color: kPrimaryWhiteColor,
                ),
              ),
            ),
            onQuotedMessageCleared: () {
              setState(() => _quotedMessage = null);
            },
            onMessageSent: (message) => log('Sending message: ${message.text}'),
          ),
        ],
      ),
    );
  }

  _buildAppBar() {
    return SliverAppBar(
      backgroundColor: kPrimaryWhiteColor,
      floating: true,
      snap: true,
      automaticallyImplyLeading: true,
      centerTitle: false,
      pinned: true,
      elevation: 1,
      toolbarHeight: 8.h,
      title: Text(
        widget.event.eventName,
        style: TextStyle(
          fontSize: 16.sp,
          fontWeight: FontWeight.w600,
        ),
      ),
      bottom: TabBar(indicatorColor: kPrimaryBlackColor, tabs: [
        Tab(
          child: Text(
            "Assigned Tasks",
            style: TextStyle(
              color: kPrimaryBlackColor,
              fontSize: 11.sp,
              fontFamily: kFontFamily,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Tab(
          child: Text(
            "Community Chat",
            style: TextStyle(
              color: kPrimaryBlackColor,
              fontSize: 11.sp,
              fontFamily: kFontFamily,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ]),
      actions: [
        SizedBox(
          width: 30,
          child: PopupMenuButton(
              padding: EdgeInsets.zero,
              onSelected: (index) {
                if (index == 0) {
                  showModalBottomSheet(
                      context: context,
                      clipBehavior: Clip.antiAlias,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(32),
                              topRight: Radius.circular(32))),
                      builder: (context) {
                        return MembersListSheet(
                          channel: channel,
                        );
                      });
                }
              },
              itemBuilder: (context) {
                return [
                  PopupMenuItem(
                    value: 0,
                    child: Text('Show Members'),
                  )
                ];
              }),
        )
      ],
    );
  }

  Widget _tasksList(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).pushNamed(
            EventRoomTaskScreen.routeName,
            arguments: EventRoomTaskScreenArgs(
              eventId: widget.event.id!,
            ),
          );
        },
        backgroundColor: kPrimaryBlackColor,
        child: Icon(
          Icons.add,
          color: Colors.white,
        ),
      ),
      body: SingleChildScrollView(
        child: FutureBuilder(
            future: FirebaseFirestore.instance
                .collection("events")
                .doc(widget.event.id)
                .collection("TaskPost")
                .orderBy("endDateTime", descending: true)
                .get(),
            builder: (context, snapshot) {
              if (snapshot.hasError == false && snapshot.hasData == true) {
                List<TaskModel> taskModels = snapshot.data!.docs
                    .map((task) => TaskModel.fromMap(task.data(), task.id))
                    .toList();
                return Column(
                  children: taskModels.map((model) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: buildPost(model) as Widget,
                    );
                  }).toList(),
                );
              }
              return Center(
                child: CircularProgressIndicator(),
              );
            }),
      ),
    );
  }

  buildPost(TaskModel taskModel) {
    if (taskModel.id != null) {
      bool open = (taskModel.endDateTime.isAfter(DateTime.now()));
      return FutureBuilder(
          future: FirebaseFirestore.instance
              .collection("Tasks")
              .doc(taskModel.id)
              .collection("Assigned Tasks")
              .get(),
          builder: (context, snapshot) {
            if (snapshot.hasError == false && snapshot.hasData == true) {
              List<Task> tasks = snapshot.data!.docs
                  .map((task) => Task.fromMap(task.data(), task.id))
                  .toList();
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8),
                color: kPrimaryWhiteColor,
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Container(
                    padding: EdgeInsets.all(16),
                    width: double.infinity,
                    // decoration: BoxDecoration(
                    //     border: Border.all(width: 2, color: Colors.black)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Row(
                          children: [
                            Text(
                              "#${taskModel.title}",
                              style: TextStyle(
                                  fontSize: 16.sp, fontWeight: FontWeight.w600),
                            ),
                            Spacer(),
                            Icon(Icons.alarm),
                            SizedBox(
                              width: 1.w,
                            ),
                            Text(
                              DateFormat("dd MMM - hh:mm a")
                                  .format(taskModel.endDateTime),
                              style: TextStyle(
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.w500,
                                  color: kPrimaryBlackColor),
                            )
                          ],
                        ),
                        Align(
                            alignment: Alignment.topLeft,
                            child: Chip(
                              backgroundColor:
                                  open ? Colors.green.withOpacity(0.3) : null,
                              label: Text(open ? "open" : "closed"),
                            )),
                        Column(
                          children: tasks.map((task) {
                            return BuildTask(task: task, modelId: taskModel.id!)
                                as Widget;
                          }).toList(),
                        ),
                        SizedBox(
                          height: 1.h,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            StandardElevatedButton(
                              onTap: () {
                                Navigator.of(context).push(MaterialPageRoute(
                                  builder: (context) => EventTaskDesScreen(
                                    taskModel: taskModel,
                                    tasks: tasks,
                                  ),
                                ));
                              },
                              labelText: "Instructions",
                            ),
                            StandardElevatedButton(
                              onTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) => LeaderBoardScreen(
                                      taskMode: taskModel,
                                      task: tasks,
                                    ),
                                  ),
                                );
                              },
                              labelText: "Analytics",
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }
            return SizedBox.shrink();
          });
    }
  }
}

class BuildTask extends StatefulWidget {
  final Task task;
  final String modelId;
  const BuildTask({
    Key? key,
    required this.modelId,
    required this.task,
  }) : super(key: key);

  @override
  State<BuildTask> createState() => _BuildTaskState();
}

class _BuildTaskState extends State<BuildTask> {
  bool isCompleted = false;

  @override
  void initState() {
    checkCompletion();
    super.initState();
  }

  checkCompletion() async {
    var doc = await FirebaseFirestore.instance
        .collection("Tasks")
        .doc(widget.modelId)
        .collection("Assigned Tasks")
        .doc(widget.task.id)
        .collection("completed")
        .doc(SessionHelper.uid)
        .get();
    isCompleted = doc.exists;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    Task task = widget.task;
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: ListTile(
        shape: RoundedRectangleBorder(
            side: const BorderSide(color: kPrimaryBlackColor),
            borderRadius: BorderRadius.circular(8)),
        onTap: () async {
          if (!isCompleted) {
            await FirebaseFirestore.instance
                .collection("Tasks")
                .doc(widget.modelId)
                .collection("Assigned Tasks")
                .doc(widget.task.id)
                .collection("completed")
                .doc(SessionHelper.uid)
                .set({}).then((value) async {
              var doc = await FirebaseFirestore.instance
                  .collection("Tasks")
                  .doc(widget.modelId)
                  .collection("leaderboard")
                  .doc(SessionHelper.uid)
                  .get();
              if (doc.exists) {
                await FirebaseFirestore.instance
                    .collection("Tasks")
                    .doc(widget.modelId)
                    .collection("leaderboard")
                    .doc(SessionHelper.uid)
                    .update({'points': FieldValue.increment(10)});
              } else {
                await FirebaseFirestore.instance
                    .collection("Tasks")
                    .doc(widget.modelId)
                    .collection("leaderboard")
                    .doc(SessionHelper.uid)
                    .set({'points': 10});
              }
            }).then((value) {
              isCompleted = !isCompleted;
              setState(() {});
            });
          } else {
            await FirebaseFirestore.instance
                .collection("Tasks")
                .doc(widget.modelId)
                .collection("Assigned Tasks")
                .doc(widget.task.id)
                .collection("completed")
                .doc(SessionHelper.uid)
                .delete()
                .then((value) async {
              await FirebaseFirestore.instance
                  .collection("Tasks")
                  .doc(widget.modelId)
                  .collection("leaderboard")
                  .doc(SessionHelper.uid)
                  .update({"points": FieldValue.increment(-10)}).then((value) {
                isCompleted = !isCompleted;
                setState(() {});
              });
            });
          }
        },
        leading: isCompleted
            ? Icon(
                Icons.check_box,
                color: Colors.green,
              )
            : Icon(
                Icons.check_box_outline_blank,
                color: kPrimaryBlackColor,
              ),
        minLeadingWidth: 2,
        title: Text(task.title),
        tileColor: Colors.white,
      ),
    );
  }
}
