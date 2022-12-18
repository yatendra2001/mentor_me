import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:mentor_me/models/user_model.dart';
import 'package:mentor_me/screens/stream_chat/models/chat_type.dart';
import 'package:mentor_me/screens/stream_chat/ui/channel_screen.dart';
import 'package:mentor_me/widgets/user_profile_image.dart';
import 'package:sizer/sizer.dart';
import 'dart:io' show Platform;

import 'package:mentor_me/utils/theme_constants.dart';

class MenteeCompletedBotomSheet extends StatefulWidget {
  final List<User> mentees;
  const MenteeCompletedBotomSheet({Key? key, required this.mentees})
      : super(key: key);

  @override
  _MenteeCompletedBotomSheetState createState() =>
      _MenteeCompletedBotomSheetState();
}

class _MenteeCompletedBotomSheetState extends State<MenteeCompletedBotomSheet> {
  @override
  Widget build(BuildContext context) {
    return Container(
        padding: EdgeInsets.only(left: 16, right: 16, bottom: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Align(
                alignment: Alignment.center,
                child: Container(
                  width: 80,
                  height: 4,
                  margin: EdgeInsets.only(top: 8, bottom: 16),
                  decoration: BoxDecoration(
                    color: kPrimaryBlackColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                )),
            Align(
              alignment: Alignment.center,
              child: Text(
                'Members',
                style: Theme.of(context)
                    .textTheme
                    .headlineSmall!
                    .copyWith(color: kPrimaryBlackColor),
              ),
            ),
            SizedBox(
              height: 10,
            ),
            Expanded(
              child: ListView.builder(
                  itemCount: widget.mentees.length,
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      onTap: () => Navigator.of(context).pushNamed(
                        ChannelScreen.routeName,
                        arguments: ChannelScreenArgs(
                          user: widget.mentees[index],
                          profileImage: widget.mentees[index].profileImageUrl,
                          chatType: ChatType.oneOnOne,
                        ),
                      ),
                      child: ListTile(
                        leading: UserProfileImage(
                            radius: 22.sp,
                            profileImageUrl:
                                widget.mentees[index].profileImageUrl,
                            iconRadius: 28.sp),
                        title: Text(
                          widget.mentees[index].displayName ?? '',
                          style: Theme.of(context)
                              .textTheme
                              .bodyLarge!
                              .copyWith(color: kPrimaryBlackColor),
                        ),
                      ),
                    );
                  }),
            ),
          ],
        ));
  }
}
