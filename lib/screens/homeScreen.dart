// lib/screens/homeScreen.dart

import 'dart:io';

import 'package:credestest/DataBaseService/dbService.dart';
import 'package:credestest/modelClass.dart';
import 'package:credestest/screens/createTaskScreen.dart';
import 'package:credestest/screens/detailScreen.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  List<TaskModel> allTasks = [];
  late final AnimationController controller;

  @override
  void initState() {
    super.initState();
    controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600), 
    );
    fetchTasks();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void fetchTasks() async {
    final tasks = await DatabaseService.instance.getTasks();
    setState(() {
      allTasks = tasks;
      allTasks.sort((a, b) => b.dueDate!.compareTo(a.dueDate!));
      controller.reset();
      controller.forward();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F0F0),
      body: Column(
        children: [
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  SizedBox(height: 50),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Hello, Triangle',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          SizedBox(height: 5),
                          Text(
                            'Welcome Back!',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),
                      CircleAvatar(
                        radius: 30,
                        backgroundImage: AssetImage('assets/triangle.jpeg'),
                      ),
                    ],
                  ),
                  SizedBox(height: 30),
                ],
              ),
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              color: Colors.red[900],
              onRefresh: () async {
                await fetchTasks;
              },
              child: allTasks.isEmpty
                  ? const Center(
                      child: Text(
                        'No tasks found! Pull down to refresh or create a new one.',
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(10),
                      itemCount: allTasks.length,
                      itemBuilder: (context, index) {
                        final task = allTasks[index];
                        final String? imagePath = task.imagePath;
                        final DateTime? date = task.dueDate;

                        // Calculate the delay for each item
                        final animation = Tween<Offset>(
                          begin: const Offset(1.0, 0),
                          end: Offset.zero,
                        ).animate(
                          CurvedAnimation(
                            parent: controller,
                            curve: Interval(
                              (index / allTasks.length) * 0.5, 
                              1.0, 
                              curve: Curves.easeOut,
                            ),
                          ),
                        );

                        return SlideTransition(
                          position: animation,
                          child: Dismissible(
                            key: ValueKey(task.id),
                            direction: DismissDirection.endToStart,
                            background: Container(
                              decoration: BoxDecoration(
                                color: Colors.red.shade900,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              alignment: Alignment.centerRight,
                              padding: const EdgeInsets.symmetric(horizontal: 20),
                              child: const Icon(
                                Icons.delete,
                                color: Colors.white,
                              ),
                            ),
                            onDismissed: (direction) async {
                              final deletedTask = allTasks[index];
                              setState(() {
                                allTasks.removeAt(index);
                              });
                              await DatabaseService.instance.deleteTask(deletedTask.id);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('${deletedTask.projectName} deleted'),
                                ),
                              );
                            },
                            child: InkWell(
                              onTap: () async {
                                await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ProjectDetailsScreen(
                                      projectId: task.id,
                                      projectTitle: task.projectName!,
                                      completedTasks: 7,
                                      totalTasks: 10,
                                      backgroundImage: imagePath ?? '',
                                      title: task.title!,
                                      description: task.description!,
                                    ),
                                  ),
                                );
                                fetchTasks();
                              },
                              child: Container(
                                height: 220,
                                margin: const EdgeInsets.symmetric(
                                  vertical: 8,
                                  horizontal: 5,
                                ),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.1),
                                      blurRadius: 10,
                                      offset: const Offset(0, 5),
                                    ),
                                  ],
                                  image:
                                      (imagePath != null && imagePath.isNotEmpty)
                                          ? DecorationImage(
                                              image: FileImage(File(imagePath)),
                                              fit: BoxFit.cover,
                                              colorFilter: ColorFilter.mode(
                                                Colors.black.withOpacity(0.4),
                                                BlendMode.darken,
                                              ),
                                            )
                                          : null,
                                  gradient:
                                      (imagePath == null || imagePath.isEmpty)
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
                                child: Stack(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.all(20.0),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        children: [
                                          Text(
                                            task.projectName!,
                                            style: const TextStyle(
                                              fontSize: 28,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                            ),
                                          ),
                                          const SizedBox(height: 35),
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
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 30),
                                    Align(
                                      alignment: Alignment.bottomCenter,
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 20.0,
                                          vertical: 15.0,
                                        ),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Container(
                                              decoration: BoxDecoration(
                                                color: Colors.white.withOpacity(0.2),
                                                shape: BoxShape.circle,
                                              ),
                                              child: const Padding(
                                                padding: EdgeInsets.all(8.0),
                                                child: Icon(
                                                  Icons.more_horiz,
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ),
                                            Container(
                                              decoration: BoxDecoration(
                                                color: Colors.white.withOpacity(0.2),
                                                shape: BoxShape.rectangle,
                                                borderRadius: BorderRadius.circular(20),
                                              ),
                                              child: date != null
                                                  ? Padding(
                                                      padding: const EdgeInsets.symmetric(
                                                        vertical: 7,
                                                        horizontal: 30,
                                                      ),
                                                      child: Text(
                                                        DateFormat('MMM d').format(date),
                                                        style: const TextStyle(
                                                          color: Colors.white,
                                                        ),
                                                      ),
                                                    )
                                                  : const SizedBox(),
                                            ),
                                            Container(
                                              decoration: BoxDecoration(
                                                color: Colors.white.withOpacity(0.2),
                                                shape: BoxShape.circle,
                                              ),
                                              child: const Padding(
                                                padding: EdgeInsets.all(8.0),
                                                child: Icon(Icons.add, color: Colors.white),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ),
        ],
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.all(15),
        child: FloatingActionButton(
          onPressed: () async {
            await Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const CreateTaskScreen()),
            );
            fetchTasks();
          },
          backgroundColor: const Color.fromARGB(244, 0, 0, 0),
          shape: const CircleBorder(),
          child: const Text('create', style: TextStyle(color: Colors.white)),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}