import 'dart:io';
import 'package:flutter/material.dart';
import 'package:credestest/DataBaseService/dbService.dart';
import 'package:credestest/modelClass.dart';

class ProjectDetailsScreen extends StatefulWidget {
  final String projectId;
  final String projectTitle;
  final String title;
  final String description;
  final int completedTasks;
  final int totalTasks;
  final String backgroundImage;

  const ProjectDetailsScreen({
    Key? key,
    required this.projectId,
    required this.projectTitle,
    required this.completedTasks,
    required this.totalTasks,
    required this.backgroundImage,
    required this.title,
    required this.description,
  }) : super(key: key);

  @override
  State<ProjectDetailsScreen> createState() => _ProjectDetailsScreenState();
}

class _ProjectDetailsScreenState extends State<ProjectDetailsScreen> {
  List<SubTaskModel> _subtasks = [];
  final List<TextEditingController> _subtaskControllers =
      List.generate(2, (index) => TextEditingController());

  @override
  void initState() {
    super.initState();
    _fetchSubtasks();
  }

  void _fetchSubtasks() async {
    final fetchedSubtasks =
        await DatabaseService.instance.getSubtasksForProject(widget.projectId);
    setState(() {
      _subtasks = fetchedSubtasks;
    });
  }

  void _saveSubtasks() async {
    final List<SubTaskModel> newSubtasks = [];
    for (var controller in _subtaskControllers) {
      if (controller.text.isNotEmpty) {
        newSubtasks.add(SubTaskModel(
          title: controller.text,
          projectId: widget.projectId,
          isCompleted: false, 
        ));
      }
    }

    if (newSubtasks.isNotEmpty) {
      await DatabaseService.instance.insertSubtasks(newSubtasks);
      for (var controller in _subtaskControllers) {
        controller.clear();
      }
      _fetchSubtasks();
    }
  }

  void _toggleSubtaskCompletion(int index) async {
    final subtask = _subtasks[index];
    final updatedSubtask = SubTaskModel(
      id: subtask.id,
      title: subtask.title,
      projectId: subtask.projectId,
      isCompleted: !subtask.isCompleted,
    );

    setState(() {
      _subtasks[index] = updatedSubtask;
    });
    
    // Update the database
    await DatabaseService.instance.updateSubtask(updatedSubtask);
  }

  // New method for deleting a subtask
  void _deleteSubtask(int index) async {
    final subtaskId = _subtasks[index].id;
    
    // Remove from the local list
    setState(() {
      _subtasks.removeAt(index);
    });
    
    // Delete from the database
    await DatabaseService.instance.deleteSubtask(subtaskId!);
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Subtask deleted.'),
      ),
    );
  }

  void _showAddTaskDialog() {
    _subtaskControllers.forEach((controller) => controller.clear());
    
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.black,
          title: const Text(
            'Add Tasks',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (var controller in _subtaskControllers)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: TextFormField(
                      controller: controller,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: 'add task+',
                        hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
                        filled: true,
                        fillColor: Colors.grey.shade900,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              onPressed: () {
                _saveSubtasks();
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.white),
              child: const Text('Add', style: TextStyle(color: Colors.black)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                image: widget.backgroundImage.isNotEmpty
                    ? DecorationImage(
                        image: FileImage(File(widget.backgroundImage)),
                        fit: BoxFit.cover,
                      )
                    : null,
                gradient: widget.backgroundImage.isEmpty
                    ? const LinearGradient(
                        colors: [
                          Color.fromARGB(255, 255, 57, 31),
                          Color.fromRGBO(11, 13, 121, 1),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      )
                    : null,
              ),
            ),
          ),

          // Main content
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          InkWell(
                            onTap: () => Navigator.pop(context),
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.3),
                                shape: BoxShape.circle,
                              ),
                              child: const Padding(
                                padding: EdgeInsets.all(10),
                                child: Center(
                                  child: Icon(
                                    Icons.arrow_back_ios,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          InkWell(
                            onTap: () {},
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.3),
                                shape: BoxShape.circle,
                              ),
                              child: const Padding(
                                padding: EdgeInsets.all(10),
                                child: Center(
                                  child: Icon(
                                    Icons.more_horiz,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Text(
                        widget.projectTitle,
                        style: const TextStyle(
                          fontSize: 40,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 30),
                      Row(
                        children: [
                          Container(
                            width: 5,
                            height: 30,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(5),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            '${widget.completedTasks}/${widget.totalTasks} tasks',
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 70),

              // Tasks List
              Expanded(
                child: Container(
                  color: Colors.grey[100],
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20.0,
                    vertical: 20.0,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(widget.title, style: const TextStyle(fontSize: 30)),
                      const SizedBox(height: 10),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.grey.withOpacity(0.2),
                          shape: BoxShape.rectangle,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(10),
                          child: Text(
                            widget.description,
                            style: const TextStyle(fontSize: 16),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5.0),
                            ),
                          ),
                          onPressed: _showAddTaskDialog,
                          child: const Text(
                            'Add Tasks',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                      Expanded(
                        child: _subtasks.isEmpty
                            ? const Center(child: Text('No tasks found.'))
                            : ListView.builder(
                                itemCount: _subtasks.length,
                                itemBuilder: (context, index) {
                                  final subtask = _subtasks[index];
                                  return Dismissible(
                                    key: ValueKey(subtask.id!),
                                    direction: DismissDirection.endToStart,
                                    onDismissed: (direction) => _deleteSubtask(index),
                                    background: Container(
                                      color: Colors.red.shade900,
                                      alignment: Alignment.centerRight,
                                      padding: const EdgeInsets.only(right: 20),
                                      child: const Icon(
                                        Icons.delete,
                                        color: Colors.white,
                                      ),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                                      child: Row(
                                        children: [
                                          InkWell(
                                            onTap: () => _toggleSubtaskCompletion(index),
                                            child: Container(
                                              width: 24,
                                              height: 24,
                                              decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                border: Border.all(color: Colors.grey),
                                                color: subtask.isCompleted
                                                    ? Colors.black
                                                    : Colors.transparent,
                                              ),
                                              child: subtask.isCompleted
                                                  ? const Icon(
                                                      Icons.check,
                                                      color: Colors.white,
                                                      size: 16,
                                                    )
                                                  : null,
                                            ),
                                          ),
                                          const SizedBox(width: 15),
                                          Expanded(
                                            child: Text(
                                              subtask.title,
                                              style: TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.w500,
                                                color: subtask.isCompleted
                                                    ? Colors.grey
                                                    : Colors.black,
                                                decoration: subtask.isCompleted
                                                    ? TextDecoration.lineThrough
                                                    : null,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}