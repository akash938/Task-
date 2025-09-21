class TaskModel {
  final String id;
  final String title;
  final String? description;
  final String projectName;
  final String? imagePath;
  final DateTime? dueDate;

  TaskModel({
    required this.id,
    required this.title,
    this.description,
    required this.projectName,
    this.imagePath,
    this.dueDate,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'projectName': projectName,
      'imagePath': imagePath,
      'dueDate': dueDate?.toIso8601String(),
    };
  }

  // Update the fromMap constructor to handle the String id
  factory TaskModel.fromMap(Map<String, dynamic> map) {
    return TaskModel(
      id: map['id'] as String,
      title: map['title'] as String,
      description: map['description'] as String?,
      projectName: map['projectName'] as String,
      imagePath: map['imagePath'] as String?,
      dueDate: map['dueDate'] != null
          ? DateTime.parse(map['dueDate'] as String)
          : null,
    );
  }
}

class SubTaskModel {
  final int? id;
  final String title;
  final String projectId;
  final bool isCompleted;

  SubTaskModel({
    this.id,
    required this.title,
    required this.projectId,
    this.isCompleted = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'projectId': projectId,
      'isCompleted': isCompleted ? 1 : 0,
    };
  }

  factory SubTaskModel.fromMap(Map<String, dynamic> map) {
    return SubTaskModel(
      id: map['id'],
      title: map['title'],
      projectId: map['projectId'],
      isCompleted: map['isCompleted'] == 1,
    );
  }
}
