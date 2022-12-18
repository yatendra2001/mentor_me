import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:intl/intl.dart';
import 'package:mentor_me/screens/login/widgets/standard_elevated_button.dart';
import 'package:mentor_me/widgets/widgets.dart';
import 'package:page_transition/page_transition.dart';
import 'package:sizer/sizer.dart';

import 'package:mentor_me/helpers/helpers.dart';
import 'package:mentor_me/models/tasks_model.dart';
import 'package:mentor_me/repositories/repositories.dart';
import 'package:mentor_me/repositories/storage/storage_repository.dart';
import 'package:mentor_me/utils/session_helper.dart';
import 'package:mentor_me/utils/theme_constants.dart';
import 'package:mentor_me/widgets/custom_appbar.dart';

List<Task> tasks = [];

class EventRoomTaskScreenArgs {
  final String eventId;

  EventRoomTaskScreenArgs({
    required this.eventId,
  });
}

class EventRoomTaskScreen extends StatefulWidget {
  static const routeName = '/eventroomtaskscreen';
  final String eventId;

  static Route route({required EventRoomTaskScreenArgs args}) {
    return PageTransition(
      settings: const RouteSettings(name: routeName),
      type: PageTransitionType.bottomToTop,
      duration: Duration(milliseconds: 500),
      child: EventRoomTaskScreen(eventId: args.eventId),
    );
  }

  const EventRoomTaskScreen({
    Key? key,
    required this.eventId,
  }) : super(key: key);

  @override
  State<EventRoomTaskScreen> createState() => _EventRoomTaskScreenState();
}

class _EventRoomTaskScreenState extends State<EventRoomTaskScreen> {
  Task empty() {
    return Task(
        id: "",
        title: "",
        detail: "",
        urlname: "",
        url: "",
        imageUrl: "",
        imageName: "");
  }

  @override
  void initState() {
    tasks.add(empty());
    super.initState();
  }

  final titleController = TextEditingController();
  final descriptionController = TextEditingController();
  final urlController = TextEditingController();
  final urlnameController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  DateTime endDate = DateTime.now().add(Duration(days: 1));
  bool isSubmitting = false;

  Future<void> fun(DocumentReference ref) async {
    for (var task in tasks) {
      await FirebaseFirestore.instance
          .collection("Tasks")
          .doc(ref.id)
          .collection("Assigned Tasks")
          .add(task.toMap());
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        return FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () => Navigator.of(context).pop(),
                          child: Text(
                            "Cancel",
                            style: TextStyle(
                                color: kPrimaryBlackColor, fontSize: 12.sp),
                          ),
                        ),
                        Spacer(),
                        Text(
                          "CREATE TASKS",
                          style: TextStyle(
                              color: kPrimaryBlackColor,
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w600),
                        ),
                        Spacer(),
                        isSubmitting == false
                            ? GestureDetector(
                                onTap: () async {
                                  if (_formKey.currentState!.validate()) {
                                    for (var task in tasks) {
                                      if (task.title.isEmpty) {
                                        flutterToast(
                                            msg:
                                                "Task title cannot be left empty.");
                                        return;
                                      }
                                    }
                                    isSubmitting = true;
                                    setState(() {});
                                    TaskModel taskModel = TaskModel(
                                      id: null,
                                      title: titleController.text,
                                      description: descriptionController.text,
                                      url: urlController.text,
                                      urlname: urlnameController.text,
                                      endDateTime: DateTime.now(),
                                    );
                                    await FirebaseFirestore.instance
                                        .collection("events")
                                        .doc(widget.eventId)
                                        .collection("TaskPost")
                                        .add(taskModel.toMap())
                                        .then((value) async {
                                      await fun(value).then((value) {
                                        isSubmitting = false;

                                        setState(() {});

                                        Navigator.of(context).pop();
                                      });
                                    });
                                  }

                                  ;
                                },
                                child: Text("Save",
                                    style: TextStyle(
                                        color: kPrimaryBlackColor,
                                        fontSize: 12.sp)),
                              )
                            : CircularProgressIndicator()
                      ],
                    ),
                    Container(
                      decoration: BoxDecoration(
                        color: kPrimaryWhiteColor,
                        border: Border.all(color: kPrimaryBlackColor),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      margin: EdgeInsets.only(top: 32),
                      padding: EdgeInsets.all(8),
                      child: TextFormField(
                        controller: titleController,
                        decoration: InputDecoration(
                          hintText: "Title",
                          hintStyle: TextStyle(
                              fontSize: 14.sp, fontWeight: FontWeight.w400),
                          border: InputBorder.none,
                        ),
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Title cannot be empty';
                          }
                          return null;
                        },
                      ),
                    ),
                    SizedBox(
                      height: 1.h,
                    ),
                    Container(
                      decoration: BoxDecoration(
                        color: kPrimaryWhiteColor,
                        border: Border.all(color: kPrimaryBlackColor),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      width: double.infinity,
                      margin: EdgeInsets.only(
                        top: 16,
                      ),
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: TextFormField(
                        controller: descriptionController,
                        maxLines: 5,
                        minLines: 5,
                        decoration: InputDecoration(
                          hintText: "Description",
                          hintStyle: TextStyle(
                              fontSize: 14.sp, fontWeight: FontWeight.w400),
                          border: InputBorder.none,
                        ),
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Description cannot be empty';
                          }
                          return null;
                        },
                      ),
                    ),
                    SizedBox(
                      height: 1.h,
                    ),
                    Container(
                      decoration: BoxDecoration(
                        color: kPrimaryWhiteColor,
                        border: Border.all(color: kPrimaryBlackColor),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      margin: EdgeInsets.only(top: 16),
                      padding: EdgeInsets.all(16),
                      child: TextFormField(
                        controller: urlnameController,
                        decoration: InputDecoration(
                          hintText: "UrlDetail",
                          hintStyle: TextStyle(
                              fontSize: 14.sp, fontWeight: FontWeight.w400),
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 1.h,
                    ),
                    Container(
                      decoration: BoxDecoration(
                        color: kPrimaryWhiteColor,
                        border: Border.all(color: kPrimaryBlackColor),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      margin: EdgeInsets.only(top: 16),
                      padding: EdgeInsets.all(16),
                      child: TextFormField(
                        controller: urlController,
                        decoration: InputDecoration(
                          hintText: "Url",
                          hintStyle: TextStyle(
                              fontSize: 14.sp, fontWeight: FontWeight.w400),
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 1.h,
                    ),
                    GestureDetector(
                      onTap: () {
                        _selectEndDate(context);
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: kPrimaryWhiteColor,
                          border: Border.all(color: kPrimaryBlackColor),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        margin: EdgeInsets.only(top: 16),
                        padding: EdgeInsets.all(16),
                        child: Row(
                          children: [
                            Text(
                              "End Date",
                              style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  fontSize: 11.sp,
                                  color: kPrimaryBlackColor),
                            ),
                            Spacer(),
                            Text(
                              DateFormat().format(endDate),
                              style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  fontSize: 11.sp,
                                  color: kPrimaryBlackColor.withOpacity(0.7)),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 3.h,
                    ),
                    Align(
                      alignment: Alignment.topLeft,
                      child: Text(
                        "Tasks",
                        style: TextStyle(
                            fontSize: 20.sp, fontWeight: FontWeight.w600),
                        textAlign: TextAlign.left,
                      ),
                    ),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemBuilder: (context, index) {
                        return BuildTaskCard(
                          index: index,
                          delete: () {
                            tasks.removeAt(index);
                            setState(() {});
                          },
                        );
                      },
                      itemCount: tasks.length,
                    ),
                    StandardElevatedButton(
                      onTap: () {
                        tasks.add(
                          empty(),
                        );
                        setState(() {});
                      },
                      labelText: "Add Tasks",
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future _selectEndDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(Duration(days: 1)),
      initialDatePickerMode: DatePickerMode.day,
      firstDate: DateTime.now().add(Duration(days: 1)),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      endDate = picked;
      setState(() {});
    }
  }
}

class BuildTaskCard extends StatefulWidget {
  final int index;
  final Function() delete;
  const BuildTaskCard({
    Key? key,
    required this.index,
    required this.delete,
  }) : super(key: key);

  @override
  State<BuildTaskCard> createState() => _BuildTaskCardState();
}

class _BuildTaskCardState extends State<BuildTaskCard> {
  final titleController = TextEditingController();
  final detailController = TextEditingController();

  final urlNameController = TextEditingController();
  final urlController = TextEditingController();
  final imageNameController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Text("#Task ${widget.index + 1}"),
            Spacer(),
            IconButton(onPressed: widget.delete, icon: Icon(Icons.delete))
          ],
        ),
        Container(
          padding: EdgeInsets.symmetric(vertical: 8, horizontal: 8),
          margin: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: kPrimaryWhiteColor,
            border: Border.all(color: kPrimaryBlackColor),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  controller: titleController,
                  decoration: InputDecoration(
                    labelText: "Title",
                    labelStyle: Theme.of(context)
                        .textTheme
                        .labelLarge!
                        .copyWith(color: kPrimaryBlackColor),
                  ),
                  onChanged: (value) {
                    tasks[widget.index] =
                        tasks[widget.index].copyWith(title: value);
                  },
                ),
                SizedBox(
                  height: 2.h,
                ),
                TextFormField(
                  controller: detailController,
                  onChanged: (value) {
                    tasks[widget.index] =
                        tasks[widget.index].copyWith(detail: value);
                  },
                  decoration: InputDecoration(
                    labelText: "Detail",
                    labelStyle: Theme.of(context)
                        .textTheme
                        .labelLarge!
                        .copyWith(color: kPrimaryBlackColor),
                  ),
                ),
                SizedBox(
                  height: 2.h,
                ),
                TextFormField(
                  controller: urlNameController,
                  onChanged: (value) {
                    tasks[widget.index] =
                        tasks[widget.index].copyWith(urlname: value);
                  },
                  decoration: InputDecoration(
                    labelText: "UrlName",
                    labelStyle: Theme.of(context)
                        .textTheme
                        .labelLarge!
                        .copyWith(color: kPrimaryBlackColor),
                  ),
                ),
                SizedBox(
                  height: 2.h,
                ),
                TextFormField(
                  controller: urlController,
                  onChanged: (value) {
                    tasks[widget.index] =
                        tasks[widget.index].copyWith(url: value);
                  },
                  decoration: InputDecoration(
                    labelText: "Url",
                    labelStyle: Theme.of(context)
                        .textTheme
                        .labelLarge!
                        .copyWith(color: kPrimaryBlackColor),
                  ),
                ),
                SizedBox(
                  height: 2.h,
                ),
                TextFormField(
                  controller: imageNameController,
                  onChanged: (value) {
                    tasks[widget.index] =
                        tasks[widget.index].copyWith(imageName: value);
                    ;
                  },
                  decoration: InputDecoration(
                    labelText: "ImageName",
                    labelStyle: Theme.of(context)
                        .textTheme
                        .labelLarge!
                        .copyWith(color: kPrimaryBlackColor),
                  ),
                ),
                SizedBox(
                  height: 2.h,
                ),
                Container(
                  margin: EdgeInsets.all(4),
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                      border: Border.all(width: 1, color: Colors.black)),
                  child: TextFormField(
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: tasks[widget.index].imageUrl == ''
                          ? 'Upload Image'
                          : tasks[widget.index].imageUrl,
                      hintStyle: Theme.of(context)
                          .textTheme
                          .labelLarge!
                          .copyWith(color: kPrimaryBlackColor),
                      suffixIcon: Icon(Icons.upload),
                    ),
                    readOnly: true,
                    onTap: () async {
                      final pickedFile = await ImageHelper.pickImageFromGallery(
                        context: context,
                        cropStyle: CropStyle.circle,
                        title: 'Task Image',
                      );
                      if (pickedFile != null) {
                        final imageurl =
                            await StorageRepository().uploadProfileImage(
                          url: '',
                          image: pickedFile,
                        );
                        tasks[widget.index] =
                            tasks[widget.index].copyWith(imageUrl: imageurl);
                        setState(() {});
                      }
                    },
                  ),
                )
              ],
            ),
          ),
        ),
      ],
    );
  }

  bool validateForm() {
    return _formKey.currentState!.validate();
  }
}
