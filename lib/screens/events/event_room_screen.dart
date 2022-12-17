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
import 'package:mentor_me/screens/events/leaderboard_screen.dart';
import 'package:mentor_me/screens/events/event_task_des_screen.dart';
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
    await channel.watch();
    channel.addMembers([SessionHelper.uid!]);
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
      body: FutureBuilder(
          future: FirebaseFirestore.instance
              .collection("events")
              .doc(widget.event.id)
              .collection("TaskPost")
              .get(),
          builder: (context, snapshot) {
            List<TaskModel> taskModels = snapshot.data!.docs
                .map((task) => TaskModel.fromMap(task.data(), task.id))
                .toList();

            if (snapshot.hasError == false && snapshot.hasData == true) {
              return Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    children: taskModels.map((model) {
                      return buildPost(model) as Widget;
                    }).toList(),
                  ));
            }
            return Center(
              child: CircularProgressIndicator(),
            );
          }),
    );
  }

  buildPost(TaskModel taskModel) {
    if (taskModel.id != null) {
      return FutureBuilder(
          future: FirebaseFirestore.instance
              .collection("Tasks")
              .doc(taskModel.id)
              .collection("Assigned Tasks")
              .get(),
          builder: (context, snapshot) {
            List<Task> tasks = snapshot.data!.docs
                .map((task) => Task.fromMap(task.data(), task.id))
                .toList();
            if (snapshot.hasError == false && snapshot.hasData == true) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Container(
                  padding: EdgeInsets.all(16),
                  width: double.infinity,
                  decoration: BoxDecoration(
                      border: Border.all(width: 2, color: Colors.black)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
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
                            "3:59:00  left",
                            style: TextStyle(
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w700,
                                color: Colors.grey),
                          )
                        ],
                      ),
                      SizedBox(
                        height: 3.h,
                      ),
                      Column(
                        children: tasks.map((task) {
                          return BuildTask(task: task, modelId: taskModel.id!)
                              as Widget;
                        }).toList(),
                      ),
                      SizedBox(
                        height: 1.h,
                      ),
                      ElevatedButton(
                        onPressed: () {},
                        child: Text("Read More"),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => LeaderBoardScreen(
                                taskMode: taskModel,
                                task: tasks,
                              ),
                            ),
                          );
                        },
                        child: Text("View Analytics"),
                      ),
                    ],
                  ),
                ),
              );
            }
            return Center(
              child: CircularProgressIndicator(),
            );
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
      margin: EdgeInsets.symmetric(vertical: 4),
      decoration:
          BoxDecoration(border: Border.all(width: 2, color: Colors.black45)),
      child: ListTile(
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
            ? Icon(Icons.check_box)
            : Icon(Icons.check_box_outline_blank),
        minLeadingWidth: 2,
        title: Text(task.title),
        tileColor: Colors.white,
      ),
    );
  }
}

// class _EventRoomScreenState extends State<EventRoomScreen> {
//   final ScrollController _controller = ScrollController();
//   List<Map<String, dynamic>> ls = [];

//   @override
//   void initState() {
//     getDataOfEvent();
//     super.initState();
//   }

//   getDataOfEvent() async {
//     final snap = await FirebaseFirestore.instance
//         .collection("eventRoomFeed")
//         .doc(widget.event.id)
//         .collection("eventTasks")
//         .orderBy("dateTime", descending: true)
//         .get();
//     for (var element in snap.docs) {
//       ls.add(element.data());
//     }
//     setState(() {});
//   }

//   @override
//   Widget build(BuildContext context) {
//     return SafeArea(
//       child: Scaffold(
//         body: DefaultTabController(
//           length: 2,
//           child: NestedScrollView(
//             controller: _controller,
//             clipBehavior: Clip.none,
//             headerSliverBuilder: (_, __) {
//               return [_buildAppBar()];
//             },
//             body: TabBarView(
//               children: [
//                 _buildDashboardView(),
//                 _buildLeaderBoard(),
//               ],
//             ),
//           ),
//         ),
//         floatingActionButton: FloatingActionButton(
//           onPressed: () {
//             Navigator.of(context).pushNamed(
//               EventRoomTaskScreen.routeName,
//               arguments: EventRoomTaskScreenArgs(
//                 eventId: widget.event.id!,
//               ),
//             );
//           },
//           backgroundColor: kPrimaryBlackColor,
//           child: Icon(
//             Icons.add,
//             color: Colors.white,
//           ),
//         ),
//       ),
//     );
//   }

//   _buildAppBar() {
//     return SliverAppBar(
//       backgroundColor: kPrimaryWhiteColor,
//       floating: true,
//       snap: true,
//       automaticallyImplyLeading: true,
//       centerTitle: false,
//       pinned: true,
//       elevation: 1,
//       leading: IconButton(
//         icon: const Icon(Icons.arrow_back_ios_new_outlined),
//         onPressed: () {
//           Navigator.of(context).pop();
//         },
//       ),
//       toolbarHeight: 8.h,
//       title: Text(
//         widget.event.eventName,
//         style: TextStyle(
//           color: Colors.black,
//           fontWeight: FontWeight.bold,
//           fontFamily: kFontFamily,
//           fontSize: 14.sp,
//         ),
//       ),
//       bottom: TabBar(indicatorColor: kPrimaryBlackColor, tabs: [
//         Tab(
//           child: Text(
//             "Assigned Tasks",
//             style: TextStyle(
//               color: kPrimaryBlackColor,
//               fontSize: 12.sp,
//               fontFamily: kFontFamily,
//               fontWeight: FontWeight.w500,
//             ),
//           ),
//         ),
//         Tab(
//           child: Text(
//             "Members",
//             style: TextStyle(
//               color: kPrimaryBlackColor,
//               fontSize: 12.sp,
//               fontFamily: kFontFamily,
//               fontWeight: FontWeight.w500,
//             ),
//           ),
//         ),
//       ]),
//     );
//   }

//   List<String> images = [
//     "https://images.unsplash.com/photo-1633332755192-727a05c4013d?ixlib=rb-1.2.1&ixid=MnwxMjA3fDB8MHxzZWFyY2h8MXx8dXNlcnxlbnwwfHwwfHw%3D&w=1000&q=80",
//     "https://images.unsplash.com/photo-1494790108377-be9c29b29330?ixlib=rb-1.2.1&ixid=MnwxMjA3fDB8MHxzZWFyY2h8NHx8dXNlcnxlbnwwfHwwfHw%3D&w=1000&q=80",
//     "https://wac-cdn.atlassian.com/dam/jcr:ba03a215-2f45-40f5-8540-b2015223c918/Max-R_Headshot%20(1).jpg?cdnVersion=487",
//     "https://preview.keenthemes.com/metronic-v4/theme/assets/pages/media/profile/profile_user.jpg",
//     "https://cxl.com/wp-content/uploads/2016/03/nate_munger.png"
//   ];

//   List<bool> isCompletedList = [
//     false,
//     false,
//     false,
//     false,
//     false,
//     false,
//     false
//   ];

//   _buildDashboardView() {
//     return ListView.builder(
//       padding: EdgeInsets.only(top: 16),
//       itemBuilder: (context, index) => Row(
//         children: [
//           Container(
//             width: MediaQuery.of(context).size.width * 0.7,
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               mainAxisAlignment: MainAxisAlignment.start,
//               children: [
//                 Text(
//                   ls[index]["senderName"],
//                   style:
//                       TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w600),
//                 ),
//                 SizedBox(
//                   height: 4,
//                 ),
//                 Text(
//                   "${ls[index]['task']}",
//                   style: TextStyle(
//                     fontSize: 10.sp,
//                     fontWeight: FontWeight.w400,
//                   ),
//                 ),
//                 SizedBox(
//                   height: 16,
//                 ),
//                 Image.network(ls[index]["image"]),
//                 SizedBox(
//                   height: 16,
//                 ),
//                 GestureDetector(
//                   onTap: () async {
//                     await launchURL(context, ls[index]["link"]);
//                   },
//                   child: Text(
//                     ls[index]["link"],
//                     style: TextStyle(
//                       color: Colors.blue,
//                       fontSize: 10.sp,
//                       decoration: TextDecoration.underline,
//                     ),
//                   ),
//                 )
//               ],
//             ),
//             decoration: BoxDecoration(
//               border: Border.all(color: kPrimaryBlackColor),
//               color: kPrimaryWhiteColor,
//             ),
//             padding: EdgeInsets.only(left: 16, right: 16, top: 4, bottom: 16),
//             margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//           ),
//           Row(
//             children: [
//               true
//                   ? const Icon(LineariconsFree.checkmark_cicle,
//                       size: 16, color: kPrimaryBlackColor)
//                   : const Icon(Entypo.hourglass, color: kPrimaryBlackColor),
//               SizedBox(
//                 width: 8,
//               ),
//               Column(
//                 children: [
//                   Icon(
//                     Icons.arrow_circle_up,
//                     size: 36,
//                   ),
//                   SizedBox(
//                     height: 4,
//                   ),
//                   Text('4 Votes')
//                 ],
//               ),
//             ],
//           ),
//           Spacer()
//         ],
//       ),
//       itemCount: ls.length,
//     );
//   }

//   _buildLeaderBoard() {
//     return Container();
//   }
// }
