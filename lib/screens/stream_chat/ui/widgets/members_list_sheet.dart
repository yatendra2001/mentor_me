import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mentor_me/widgets/user_profile_image.dart';
import 'package:sizer/sizer.dart';
import 'package:stream_chat/stream_chat.dart';
import 'dart:io' show Platform;

import 'package:mentor_me/utils/theme_constants.dart';

class MembersListSheet extends StatefulWidget {
  final Channel channel;
  const MembersListSheet({Key? key, required this.channel}) : super(key: key);

  @override
  _MembersListSheetState createState() => _MembersListSheetState();
}

class _MembersListSheetState extends State<MembersListSheet> {
  Future<List<Member>> getAllMembers() async {
    var membersResponse = await widget.channel.queryMembers();
    var members = membersResponse.members;
    return members;
  }

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
              child: FutureBuilder(
                  future: getAllMembers(),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      var members = snapshot.data as List<Member>;
                      return ListView.builder(
                          itemCount: members.length,
                          itemBuilder: (context, index) {
                            return ListTile(
                              leading: UserProfileImage(
                                  radius: 22.sp,
                                  profileImageUrl: members[index].user!.image!,
                                  iconRadius: 28.sp),
                              title: Text(
                                members[index].user?.name ?? '',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyLarge!
                                    .copyWith(color: kPrimaryBlackColor),
                              ),
                            );
                          });
                    }
                    return Center(
                        child: (Platform.isIOS)
                            ? CupertinoActivityIndicator(
                                color: kPrimaryBlackColor)
                            : CircularProgressIndicator(
                                color: kPrimaryBlackColor));
                  }),
            ),
          ],
        ));
  }
}
