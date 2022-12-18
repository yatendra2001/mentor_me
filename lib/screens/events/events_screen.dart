import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:fluttericon/linecons_icons.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_stack/image_stack.dart';
import 'package:mentor_me/blocs/blocs.dart';
import 'package:mentor_me/main.dart';
import 'package:mentor_me/screens/login/login_cubit/login_cubit.dart';
import 'package:mentor_me/screens/payments/payment_page.dart';
import 'package:mentor_me/screens/screens.dart';
import 'package:mentor_me/screens/stream_chat/cubit/initialize_stream_chat/initialize_stream_chat_cubit.dart';
import 'package:mentor_me/screens/stream_chat/ui/stream_chat_inbox.dart';
import 'package:mentor_me/widgets/user_profile_image.dart';
import 'package:otp_text_field/otp_field.dart';
import 'package:page_transition/page_transition.dart';
import 'package:rolling_switch/rolling_switch.dart';
import 'package:sizer/sizer.dart';
import 'package:mentor_me/models/event_model.dart' as eve;

import 'package:mentor_me/repositories/event/event_repository.dart';
import 'package:mentor_me/repositories/user/user_repository.dart';
import 'package:mentor_me/screens/events/create_screen.dart';
import 'package:mentor_me/screens/events/direct_to_payments.dart';
import 'package:mentor_me/screens/events/event_room_screen.dart';
import 'package:mentor_me/utils/assets_constants.dart';
import 'package:mentor_me/utils/session_helper.dart';
import 'package:mentor_me/utils/theme_constants.dart';
import 'package:mentor_me/widgets/flutter_toast.dart';
import 'package:stream_chat_flutter/stream_chat_flutter.dart';

import 'bloc/event_bloc.dart';

class EventsScreen extends StatefulWidget {
  static const routeName = 'events';

  const EventsScreen({Key? key}) : super(key: key);

  static Route route() {
    return PageTransition(
      settings: const RouteSettings(name: routeName),
      type: PageTransitionType.rightToLeft,
      child: BlocProvider<EventBloc>(
        create: (context) =>
            EventBloc(eventRepository: context.read<EventRepository>()),
        child: const EventsScreen(),
      ),
    );
  }

  @override
  State<EventsScreen> createState() => _EventsScreenState();
}

class _EventsScreenState extends State<EventsScreen> {
  final ScrollController _controller = ScrollController();
  String joinCode = "";
  late int totalCoins;
  var scaffoldKey = GlobalKey<ScaffoldState>();

  _getWalletData() async {
    await UserRepository()
        .getUserWithId(userId: SessionHelper.uid!)
        .then((value) {
      setState(() {
        totalCoins = 1000;
      });
    });
  }

  @override
  void initState() {
    context.read<EventBloc>().add(GetUserEvent());
    StreamChat.of(context)
        .client
        .on()
        .where((Event event) => event.totalUnreadCount != null)
        .listen((Event event) {
      setState(() {
        SessionHelper.totalUnreadMessagesCount = event.totalUnreadCount ?? 0;
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    _getWalletData();
    return BlocBuilder<EventBloc, EventState>(
      builder: (context, state) {
        return Scaffold(
          key: scaffoldKey,
          drawer: _drawer(context),
          floatingActionButton: SpeedDial(
            icon: Icons.add,
            overlayColor: Colors.black,
            iconTheme: IconThemeData(color: kPrimaryWhiteColor),
            foregroundColor: Colors.black,
            backgroundColor: kPrimaryBlackColor,
            children: [
              SpeedDialChild(
                label: 'Create',
                labelStyle: TextStyle(fontSize: 11.sp),
                backgroundColor: kPrimaryBlackColor,
                onTap: () {
                  Navigator.of(context)
                      .pushNamed(CreateEventScreen.routeName)
                      .then((value) {
                    context.read<EventBloc>().add(GetUserEvent());
                  });
                },
              ),
              SpeedDialChild(
                label: 'Join',
                backgroundColor: Colors.amberAccent,
                labelStyle: TextStyle(fontSize: 11.sp),
                onTap: () {
                  showDialog(
                    context: context,
                    useSafeArea: true,
                    builder: (ctx) => AlertDialog(
                      title: Text(
                        "Join Event",
                        style: TextStyle(
                            fontSize: 14.sp, color: kPrimaryBlackColor),
                        textAlign: TextAlign.center,
                      ),
                      content: OTPTextField(
                        length: 6,
                        onChanged: (val) {
                          joinCode = val;
                        },
                      ),
                      actions: [
                        OutlinedButton(
                          onPressed: () async {
                            if (joinCode.length < 6) {
                              flutterToast(msg: "Please enter a 6 digit code");
                            } else {
                              Navigator.of(context)
                                  .push(MaterialPageRoute(builder: (context) {
                                return PaymentPage(
                                    JoinCode: joinCode, onTap: () async {});
                              })).then((value) async {
                                await context
                                    .read<EventBloc>()
                                    .directToPayment(joinCode: joinCode)
                                    .then((value) {
                                  context.read<EventBloc>().add(GetUserEvent());
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                        content: Text(
                                            'Congrats !You have joined the grp')),
                                  );
                                });
                              });
                            }
                          },
                          child: const Text(
                            'Join',
                            style: TextStyle(color: kPrimaryBlackColor),
                          ),
                        )
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
          body: state.status == EventStatus.loading
              ? Center(
                  child: CircularProgressIndicator(),
                )
              : RefreshIndicator(
                  onRefresh: () async {
                    setState(() {});
                  },
                  child: DefaultTabController(
                    length: 2,
                    child: NestedScrollView(
                      controller: _controller,
                      clipBehavior: Clip.none,
                      headerSliverBuilder: (_, __) {
                        return [_buildAppBar()];
                      },
                      body: TabBarView(
                        children: [
                          _buildDashBoard(state),
                          _buildCompleted(),
                        ],
                      ),
                    ),
                  ),
                ),
        );
      },
    );
  }

  Drawer _drawer(BuildContext context) {
    return Drawer(
      width: 70.w,
      child: ListView(
        // Important: Remove any padding from the ListView.
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: kPrimaryBlackColor,
            ),
            child: Center(
                child: Text(
              'MentorMe',
              style: TextStyle(fontSize: 26.sp),
            )),
          ),
          ListTile(
            title: const Text("Switch Profile"),
            textColor: kPrimaryBlackColor,
            trailing: Transform.scale(
              scale: 0.6,
              child: RollingSwitch.icon(
                initialState: false,
                onChanged: (bool val) {
                  // context
                  //     .read<ProfileBloc>()
                  //     .add(ProfileToUpdateUser(isPrivate: val));
                  // String message = '';
                  // setState(() {
                  //   message =
                  //       state.user.isPrivate ? "Public" : "Private";
                  // });
                  // flutterToast(msg: "Profile Updated: $message");
                },
                rollingInfoRight: RollingIconInfo(
                  icon: Icons.lock,
                  backgroundColor: kPrimaryBlackColor,
                  text: Text(
                    'User',
                    style: TextStyle(
                        fontSize: 12.sp,
                        fontFamily: kFontFamily,
                        color: kPrimaryWhiteColor),
                  ),
                ),
                rollingInfoLeft: RollingIconInfo(
                  icon: Icons.public,
                  backgroundColor: Colors.grey,
                  text: Text(
                    'Mentor',
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontFamily: kFontFamily,
                    ),
                  ),
                ),
              ),
            ),
            onTap: () {
              // Update the state of the app
              // ...
              // Then close the drawer
              Navigator.pop(context);
            },
          ),
          ListTile(
            title: const Text('Logout'),
            textColor: kPrimaryBlackColor,
            trailing: IconButton(
              icon: SizedBox(
                height: 3.2.h,
                width: 3.2.h,
                child: CachedNetworkImage(
                    imageUrl:
                        "https://cdn-icons-png.flaticon.com/512/159/159707.png"),
              ),
              onPressed: () {
                showDialog(
                  context: context,
                  barrierDismissible: true,
                  builder: (context) => AlertDialog(
                    backgroundColor: Colors.grey[50],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                      side: const BorderSide(
                          color: kPrimaryBlackColor, width: 2.0),
                    ),
                    title: Center(
                      child: Text(
                        "Are you sure you want to logout?",
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w400,
                          color: kPrimaryBlackColor,
                          fontFamily: kFontFamily,
                        ),
                      ),
                    ),
                    actions: [
                      OutlinedButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text(
                            "No",
                            style: TextStyle(
                              color: kPrimaryBlackColor,
                              fontSize: 10.sp,
                              fontFamily: kFontFamily,
                            ),
                          )),
                      OutlinedButton(
                        onPressed: () {
                          context
                              .read<AuthBloc>()
                              .add(AuthLogoutRequested(context: context));
                          context.read<LoginCubit>().logoutRequested();

                          SessionHelperEmpty();
                          MyApp.navigatorKey.currentState!
                              .pushReplacementNamed(LoginPageView.routeName);
                        },
                        child: Text(
                          "Yes",
                          style: TextStyle(
                              color: kPrimaryBlackColor,
                              fontFamily: kFontFamily,
                              fontSize: 10.sp),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
            onTap: () {
              // Update the state of the app
              // ...
              // Then close the drawer
              Navigator.pop(context);
            },
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
      automaticallyImplyLeading: false,
      centerTitle: true,
      pinned: true,
      elevation: 1,
      toolbarHeight: 8.h,
      leading: Padding(
        padding: const EdgeInsets.only(left: 8.0),
        child: GestureDetector(
          onTap: () => scaffoldKey.currentState?.openDrawer(),
          child: Padding(
            padding: const EdgeInsets.only(right: 8),
            child: SessionHelper.profileImageUrl != null
                ? UserProfileImage(
                    radius: 15.sp,
                    profileImageUrl: SessionHelper.profileImageUrl!,
                    iconRadius: 27.sp)
                : Icon(FontAwesomeIcons.user),
          ),
        ),
      ),
      title: Text(
        "MentorMe",
        style: TextStyle(
          color: Colors.black,
          fontWeight: FontWeight.bold,
          fontFamily: kFontFamily,
          fontSize: 22.sp,
        ),
      ),
      bottom: TabBar(indicatorColor: kPrimaryBlackColor, tabs: [
        Tab(
          child: Text(
            "Dashboard",
            style: TextStyle(
              color: kPrimaryBlackColor,
              fontSize: 13.sp,
              fontFamily: kFontFamily,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Tab(
          child: Text(
            "Completed",
            style: TextStyle(
              color: kPrimaryBlackColor,
              fontSize: 13.sp,
              fontFamily: kFontFamily,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ]),
      actions: [
        BlocBuilder<InitializeStreamChatCubit, InitializeStreamChatState>(
          builder: (context, state) {
            if (state is StreamChatInitializedState) {
              return Padding(
                padding: const EdgeInsets.only(right: 8, top: 4, bottom: 4),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    if (SessionHelper.totalUnreadMessagesCount > 0)
                      Positioned(
                        top: 5,
                        left: 5,
                        child: Container(
                          padding: const EdgeInsets.all(5),
                          decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: kPrimaryBlackColor),
                          child: Text(
                            '${SessionHelper.totalUnreadMessagesCount}',
                            style: TextStyle(
                                color: kPrimaryWhiteColor,
                                fontFamily: kFontFamily,
                                fontSize: 12,
                                fontWeight: FontWeight.w600),
                          ),
                        ),
                      ),
                    IconButton(
                      icon: const Icon(
                        Linecons.paper_plane,
                        color: kPrimaryBlackColor,
                      ),
                      onPressed: () {
                        Navigator.pushNamed(context, StreamChatInbox.routeName);
                      },
                    ),
                  ],
                ),
              );
            }
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: IconButton(
                icon: const Icon(
                  Linecons.paper_plane,
                  color: kPrimaryBlackColor,
                ),
                onPressed: () {
                  Navigator.pushNamed(context, StreamChatInbox.routeName);
                },
              ),
            );
          },
        ),
      ],
    );
  }

  List<String> images = [
    "https://images.unsplash.com/photo-1633332755192-727a05c4013d?ixlib=rb-1.2.1&ixid=MnwxMjA3fDB8MHxzZWFyY2h8MXx8dXNlcnxlbnwwfHwwfHw%3D&w=1000&q=80",
    "https://images.unsplash.com/photo-1494790108377-be9c29b29330?ixlib=rb-1.2.1&ixid=MnwxMjA3fDB8MHxzZWFyY2h8NHx8dXNlcnxlbnwwfHwwfHw%3D&w=1000&q=80",
    "https://wac-cdn.atlassian.com/dam/jcr:ba03a215-2f45-40f5-8540-b2015223c918/Max-R_Headshot%20(1).jpg?cdnVersion=487",
    "https://preview.keenthemes.com/metronic-v4/theme/assets/pages/media/profile/profile_user.jpg",
    "https://cxl.com/wp-content/uploads/2016/03/nate_munger.png"
  ];

  _buildDashBoard(EventState state) {
    List<eve.Event> onGoingEvent = [];
    List<eve.Event> upComingEvent = [];

    bool hideOngoingEvent = false;
    bool hideUpComingEvent = false;

    if (state.events != null) {
      for (int i = 0; i < state.events!.length; i++) {
        if (state.events![i].startDate.microsecondsSinceEpoch >
            DateTime.now().microsecondsSinceEpoch) {
          upComingEvent.add(state.events![i]);
        } else {
          onGoingEvent.add(state.events![i]);
        }
      }
    }
    if (state.status.name == EventStatus.loading) {
      return Center(
        child: CircularProgressIndicator(),
      );
    }
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              "You can now create your own paid events to provide mentorship or participate in the ongoing event to get mentored. Click on the ‘+’ to create or join an event...",
              style: TextStyle(
                fontSize: 9.sp,
                color: kPrimaryBlackColor.withOpacity(0.4),
              ),
              textAlign: TextAlign.justify,
            ),
            state.events == null || state.events!.isEmpty
                ? Container()
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      SizedBox(
                        height: 32,
                      ),
                      Row(
                        children: [
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 8.0),
                            child: Text(
                              'Ongoing Event',
                              style: TextStyle(
                                  fontSize: 18.sp, fontWeight: FontWeight.w500),
                            ),
                          ),
                          Spacer(),
                          IconButton(
                              onPressed: () {
                                setState(() {
                                  hideOngoingEvent = !hideOngoingEvent;
                                });
                              },
                              icon: Icon(Icons.arrow_drop_down))
                        ],
                      ),
                      ListView.builder(
                        physics: NeverScrollableScrollPhysics(),
                        padding: const EdgeInsets.only(top: 16),
                        shrinkWrap: true,
                        itemBuilder: ((context, index) => Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 8.0),
                              child: EventCardWidget(
                                images: images,
                                event: onGoingEvent[index],
                              ),
                            )),
                        itemCount: onGoingEvent.length,
                      ),
                      SizedBox(
                        height: 32,
                      ),
                      Row(
                        children: [
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 8.0),
                            child: Text(
                              'Upcoming Event',
                              style: TextStyle(
                                  fontSize: 18.sp, fontWeight: FontWeight.w500),
                            ),
                          ),
                          Spacer(),
                          IconButton(
                              onPressed: () {
                                setState(() {
                                  hideUpComingEvent = !hideUpComingEvent;
                                });
                              },
                              icon: Icon(Icons.arrow_drop_down))
                        ],
                      ),
                      !hideUpComingEvent
                          ? ListView.builder(
                              padding: const EdgeInsets.only(top: 16),
                              shrinkWrap: true,
                              itemBuilder: ((context, index) => Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 8.0),
                                    child: EventCardWidget(
                                      images: images,
                                      event: upComingEvent[index],
                                    ),
                                  )),
                              itemCount: upComingEvent.length,
                            )
                          : SizedBox.shrink(),
                    ],
                  )
          ],
        ),
      ),
    );
  }

  _buildCompleted() {
    return Container();
  }
}

class EventCardWidget extends StatelessWidget {
  final List<String> images;
  final eve.Event event;

  const EventCardWidget({
    Key? key,
    required this.images,
    required this.event,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final difference = event.endDate.difference(DateTime.now()).inDays;

    return GestureDetector(
      onTap: () {
        Navigator.of(context).pushNamed(EventRoomScreen.routeName,
            arguments: EventRoomScreenArgs(event: event));
      },
      child: Card(
        elevation: 1.5,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(color: kPrimaryBlackColor),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    event.eventName,
                    style: TextStyle(
                        color: kPrimaryBlackColor,
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w500),
                  ),
                ],
              ),
              const SizedBox(height: 16.0),
              Text(
                "Participants",
                style: TextStyle(
                    color: kPrimaryBlackColor.withOpacity(0.5),
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w400),
              ),
              const SizedBox(height: 16.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ImageStack(
                    imageList: images,
                    totalCount: images.length,
                    imageRadius: 22.sp,
                    imageCount: 3,
                    imageBorderWidth: 0,
                  ),
                  Text(
                    "$difference day",
                    style: TextStyle(
                        color: kPrimaryBlackColor.withOpacity(0.5),
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w400),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
