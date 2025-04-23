import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

enum CalendarViewType { day, week, month, schedule }

class EventModel extends Equatable {
  final String id;
  final String title;
  final String description;
  final DateTime start;
  final DateTime end;
  final Color color;

  const EventModel({
    required this.id,
    required this.title,
    required this.description,
    required this.start,
    required this.end,
    this.color = Colors.blue,
  });

  EventModel copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? start,
    DateTime? end,
    Color? color,
  }) {
    return EventModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      start: start ?? this.start,
      end: end ?? this.end,
      color: color ?? this.color,
    );
  }

  @override
  List<Object?> get props => [id, title, description, start, end, color];
}
