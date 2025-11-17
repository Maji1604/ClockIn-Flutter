import 'package:equatable/equatable.dart';

class HolidayModel extends Equatable {
  final String id;
  final String title;
  final String date;
  final String? description;
  final bool isRecurring;
  final String createdAt;
  final String updatedAt;
  final String? createdBy;

  const HolidayModel({
    required this.id,
    required this.title,
    required this.date,
    this.description,
    required this.isRecurring,
    required this.createdAt,
    required this.updatedAt,
    this.createdBy,
  });

  factory HolidayModel.fromJson(Map<String, dynamic> json) {
    return HolidayModel(
      id: json['id'] as String,
      title: json['title'] as String,
      date: json['date'] as String,
      description: json['description'] as String?,
      isRecurring: json['isRecurring'] as bool? ?? false,
      createdAt: json['createdAt'] as String,
      updatedAt: json['updatedAt'] as String,
      createdBy: json['createdBy'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'date': date,
      'description': description,
      'isRecurring': isRecurring,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'createdBy': createdBy,
    };
  }

  DateTime get dateTime => DateTime.parse(date);

  @override
  List<Object?> get props => [
    id,
    title,
    date,
    description,
    isRecurring,
    createdAt,
    updatedAt,
    createdBy,
  ];
}
