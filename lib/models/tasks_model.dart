import 'dart:convert';

import 'package:flutter/foundation.dart';

class TaskModel {
  String? id;
  String title;
  String description;
  List<Task> tasks;
  String url;
  String urlname;
  DateTime endDateTime;
  TaskModel({
    required this.id,
    required this.title,
    required this.description,
    required this.tasks,
    required this.url,
    required this.urlname,
    required this.endDateTime,
  });

  TaskModel copyWith({
    String? id,
    String? title,
    String? description,
    List<Task>? tasks,
    String? url,
    String? urlname,
    DateTime? endDateTime,
  }) {
    return TaskModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      tasks: tasks ?? this.tasks,
      url: url ?? this.url,
      urlname: urlname ?? this.urlname,
      endDateTime: endDateTime ?? this.endDateTime,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'tasks': tasks.map((x) => x.toMap()).toList(),
      'url': url,
      'urlname': urlname,
      'endDateTime': endDateTime.millisecondsSinceEpoch,
    };
  }

  factory TaskModel.fromMap(Map<String, dynamic> map) {
    return TaskModel(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      tasks: List<Task>.from(map['tasks']?.map((x) => Task.fromMap(x))),
      url: map['url'] ?? '',
      urlname: map['urlname'] ?? '',
      endDateTime: DateTime.fromMillisecondsSinceEpoch(map['endDateTime']),
    );
  }

  String toJson() => json.encode(toMap());

  factory TaskModel.fromJson(String source) =>
      TaskModel.fromMap(json.decode(source));

  @override
  String toString() {
    return 'TaskModel(id: $id, title: $title, description: $description, tasks: $tasks, url: $url, urlname: $urlname, endDateTime: $endDateTime)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is TaskModel &&
        other.id == id &&
        other.title == title &&
        other.description == description &&
        listEquals(other.tasks, tasks) &&
        other.url == url &&
        other.urlname == urlname &&
        other.endDateTime == endDateTime;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        title.hashCode ^
        description.hashCode ^
        tasks.hashCode ^
        url.hashCode ^
        urlname.hashCode ^
        endDateTime.hashCode;
  }
}

class Task {
  String title;
  String detail;
  String urlname;
  String url;
  String imageUrl;
  String imageName;
  Task({
    required this.title,
    required this.detail,
    required this.urlname,
    required this.url,
    required this.imageUrl,
    required this.imageName,
  });

  Task copyWith({
    String? title,
    String? detail,
    String? urlname,
    String? url,
    String? imageUrl,
    String? imageName,
  }) {
    return Task(
      title: title ?? this.title,
      detail: detail ?? this.detail,
      urlname: urlname ?? this.urlname,
      url: url ?? this.url,
      imageUrl: imageUrl ?? this.imageUrl,
      imageName: imageName ?? this.imageName,
    );
  }



  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'detail': detail,
      'urlname': urlname,
      'url': url,
      'imageUrl': imageUrl,
      'imageName': imageName,
    };
  }

  factory Task.fromMap(Map<String, dynamic> map) {
    return Task(
      title: map['title'] ?? '',
      detail: map['detail'] ?? '',
      urlname: map['urlname'] ?? '',
      url: map['url'] ?? '',
      imageUrl: map['imageUrl'] ?? '',
      imageName: map['imageName'] ?? '',
    );
  }

  String toJson() => json.encode(toMap());

  factory Task.fromJson(String source) => Task.fromMap(json.decode(source));

  @override
  String toString() {
    return 'Task(title: $title, detail: $detail, urlname: $urlname, url: $url, imageUrl: $imageUrl, imageName: $imageName)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Task &&
        other.title == title &&
        other.detail == detail &&
        other.urlname == urlname &&
        other.url == url &&
        other.imageUrl == imageUrl &&
        other.imageName == imageName;
  }

  @override
  int get hashCode {
    return title.hashCode ^
        detail.hashCode ^
        urlname.hashCode ^
        url.hashCode ^
        imageUrl.hashCode ^
        imageName.hashCode;
  }
}
