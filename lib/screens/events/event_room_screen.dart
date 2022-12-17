import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttericon/elusive_icons.dart';
import 'package:fluttericon/entypo_icons.dart';
import 'package:fluttericon/linearicons_free_icons.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_stack/image_stack.dart';
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

import 'package:mentor_me/screens/events/event_room_task_screen.dart';
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
          body: TabBarView(children: [
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
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          children: [
            // appBottomRow(),
            SizedBox(
              height: 4.h,
            ),
            Container(
              padding: EdgeInsets.all(16),
              width: double.infinity,
              decoration: BoxDecoration(
                  border: Border.all(width: 2, color: Colors.black)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        "#Day 5",
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
                    height: 2.h,
                  ),
                  Container(
                    decoration: BoxDecoration(
                        border: Border.all(width: 2, color: Colors.black45)),
                    child: ListTile(
                      leading: Icon(Icons.check_box_outline_blank),
                      minLeadingWidth: 2,
                      title: Text("Find min element in array"),
                      tileColor: Colors.white,
                    ),
                  ),
                  SizedBox(
                    height: 1.h,
                  ),
                  Container(
                    decoration: BoxDecoration(
                        border: Border.all(width: 2, color: Colors.black45)),
                    child: ListTile(
                      leading: Icon(Icons.check_box_outline_blank),
                      minLeadingWidth: 2,
                      title: Text("Sort the array"),
                      tileColor: Colors.white,
                    ),
                  ),
                  SizedBox(
                    height: 1.h,
                  ),
                  Container(
                    decoration: BoxDecoration(
                        border: Border.all(width: 2, color: Colors.black45)),
                    child: ListTile(
                      leading: Icon(Icons.check_box),
                      minLeadingWidth: 2,
                      title: Text("Schedule the courses"),
                      tileColor: Colors.white,
                    ),
                  ),
                  SizedBox(
                    height: 1.h,
                  ),
                  Container(
                    decoration: BoxDecoration(
                        border: Border.all(width: 2, color: Colors.black45)),
                    child: ListTile(
                      leading: Icon(Icons.check_box),
                      minLeadingWidth: 2,
                      title: Text("Divide the elements in k stacks"),
                      tileColor: Colors.white,
                    ),
                  ),
                  SizedBox(
                    height: 1.h,
                  ),
                  Center(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context)
                            .push(MaterialPageRoute(builder: (context) {
                          return EventTaskDesScreen();
                        }));
                      },
                      child: Text("Read More"),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  appBottomRow() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          Chip(
            label: Text('Assigned Tasks'),
            backgroundColor: Colors.blue.withOpacity(0.3),
          ),
          SizedBox(
            width: 4.w,
          ),
          Chip(
            label: Text('Leader Board'),
          ),
          SizedBox(
            width: 4.w,
          ),
          Chip(
            label: Text('Discussions'),
          ),
          SizedBox(
            width: 4.w,
          ),
        ],
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
