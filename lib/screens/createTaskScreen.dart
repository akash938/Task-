import 'dart:io';
import 'package:credestest/DataBaseService/dbService.dart';
import 'package:credestest/modelClass.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:uuid/uuid.dart';

class CreateTaskScreen extends StatefulWidget {
  const CreateTaskScreen({super.key});

  @override
  State<CreateTaskScreen> createState() => _CreateTaskScreenState();
}

class _CreateTaskScreenState extends State<CreateTaskScreen> {
  final uuid = Uuid();
  String selectedDateLabel = 'Today';
  DateTime? selectedDate;
  String selectedProject = '';
  // This projects list now holds the permanent File objects.
  final List<Map<String, dynamic>> projects = [];
  final TextEditingController projectController = TextEditingController();
  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    selectedDate = DateTime.now();
    projects.add({'name': 'Travel', 'image': null});
    projects.add({'name': 'Grocery Shopping', 'image': null});
    projects.add({'name': 'Workout Plan', 'image': null});
  }

  void _saveTask() async {
    if (titleController.text.isEmpty || selectedProject.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill out the title and select a project.'),
        ),
      );
      return;
    }

    final selectedProjectData = projects.firstWhere(
      (p) => p['name'] == selectedProject,
      orElse: () => {'image': null},
    );

    // Get the path from the permanent File object
    final String? imagePath = (selectedProjectData['image'] as File?)?.path;

    final newTask = TaskModel(
      title: titleController.text,
      description: descriptionController.text.isNotEmpty
          ? descriptionController.text
          : null,
      projectName: selectedProject,
      imagePath: imagePath,
      dueDate: selectedDate,
      id: uuid.v4(),
    );
    print('--- Creating New Task ---');
    print('ID: ${newTask.id}');
    print('Title: ${newTask.title}');
    print('Description: ${newTask.description}');
    print('Project Name: ${newTask.projectName}');
    print('Image Path: ${newTask.imagePath}');
    print('Due Date: ${newTask.dueDate}');
    print('-------------------------');
    await DatabaseService.instance.insertTask(newTask);
    titleController.clear();
    descriptionController.clear();
    Navigator.pop(context);
  }

  void handleDateSelection(String dateLabel) {
    setState(() {
      selectedDateLabel = dateLabel;
      if (dateLabel == 'Today') {
        selectedDate = DateTime.now();
      } else {
        selectedDate = DateTime.now().add(const Duration(days: 1));
      }
    });
    print('Selected Date Label: $selectedDateLabel');
    print('Selected Date: $selectedDate');
  }

  // store a permanent File object
  void addProject(String name, File? image) {
    setState(() {
      projects.insert(0, {'name': name, 'image': image});
      selectedProject = name;
    });
  }

  void removeProject(int index) {
    setState(() {
      final removedProjectName = projects[index]['name'];
      projects.removeAt(index);
      if (selectedProject == removedProjectName) {
        selectedProject = '';
      }
    });
  }

  void showAddProjectDialog() {
    File? dialogImageFile;
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateInDialog) {
            Future<void> pickAndSaveImage() async {
              final picker = ImagePicker();
              final pickedFile = await picker.pickImage(
                source: ImageSource.gallery,
                imageQuality: 75,
              );
              if (pickedFile != null) {
                // Get the permanent directory for the app
                final appDocsDir = await getApplicationDocumentsDirectory();
                final fileName = p.basename(pickedFile.path);
                final newPath = p.join(appDocsDir.path, fileName);

                // Copy the file from the temporary cache to a permanent location
                final savedImage = await File(pickedFile.path).copy(newPath);

                setStateInDialog(() {
                  dialogImageFile = savedImage;
                });
              }
            }

            return AlertDialog(
              title: const Text(
                'Add New Project',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: TextFormField(
                        controller: projectController,
                        cursorColor: Colors.black,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.grey.shade300,
                          hintText: 'Project name',
                          hintStyle: const TextStyle(color: Colors.grey),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15.0),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.all(15),
                        ),
                      ),
                    ),
                    const SizedBox(height: 15),
                    GestureDetector(
                      onTap: pickAndSaveImage,
                      child: Container(
                        height: 90,
                        width: 150,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(15),
                          image: dialogImageFile != null
                              ? DecorationImage(
                                  image: FileImage(dialogImageFile!),
                                  fit: BoxFit.cover,
                                )
                              : null,
                        ),
                        child: dialogImageFile == null
                            ? Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: const [
                                  Icon(Icons.motion_photos_on, size: 15),
                                  SizedBox(width: 5),
                                  Text(
                                    'Add Image',
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 15,
                                    ),
                                  ),
                                ],
                              )
                            : null,
                      ),
                    ),
                  ],
                ),
              ),
              actions: <Widget>[
                TextButton(
                  child: Text(
                    'Cancel',
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                  onPressed: () {
                    projectController.clear();
                    Navigator.of(context).pop();
                  },
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.shade800,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Add',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  onPressed: () {
                    if (projectController.text.isNotEmpty) {
                      addProject(projectController.text, dialogImageFile);
                      projectController.clear();
                      Navigator.of(context).pop();
                    }
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage(
                      'assets/e331455c-1031-4798-8cd2-a0a5eddb9bf2.jpeg',
                    ),
                    fit: BoxFit.cover,
                  ),
                ),
                child: Column(
                  children: [
                    Align(
                      alignment: Alignment.topRight,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Container(
                          height: 40,
                          width: 40,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.5),
                            shape: BoxShape.circle,
                            // borderRadius: BorderRadius.circular(50),
                          ),
                          child: IconButton(
                            icon: const Icon(Icons.close, size: 20),
                            onPressed: () {
                              Navigator.pop(context);
                            },
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.7),
                        shape: BoxShape.rectangle,
                        borderRadius: BorderRadius.circular(50),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 30),
                        child: Text(
                          'New Task',
                          style: TextStyle(
                            fontSize: 25,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 10),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),

                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          decoration: selectedDateLabel == 'Today'
                              ? BoxDecoration(
                                  borderRadius: BorderRadius.circular(15),
                                  gradient: RadialGradient(
                                    radius: 1.0,
                                    colors: [
                                      Color(0xFF000000),
                                      Color.fromARGB(255, 24, 18, 18),
                                      Color(0xFF000000),
                                    ],
                                    stops: [0.0, 0.6, 1.0],
                                    center: Alignment.center,
                                  ),
                                )
                              : null,
                          child: ElevatedButton(
                            onPressed: () => handleDateSelection('Today'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: selectedDateLabel == 'Today'
                                  ? Colors.transparent
                                  : const Color(0xFFF0F0F0),
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 15,
                              ),
                            ),
                            child: Text(
                              'Today',
                              style: TextStyle(
                                color: selectedDateLabel == 'Today'
                                    ? Colors.white
                                    : Colors.black,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Container(
                          decoration: selectedDateLabel == 'Tomorrow'
                              ? BoxDecoration(
                                  borderRadius: BorderRadius.circular(15),
                                  gradient: RadialGradient(
                                    radius: 1.0,
                                    colors: [
                                      Color(0xFF000000),
                                      Color.fromARGB(255, 24, 18, 18),
                                      Color(0xFF000000),
                                    ],
                                    stops: [0.0, 0.6, 1.0],
                                    center: Alignment.center,
                                  ),
                                )
                              : null,
                          child: ElevatedButton(
                            onPressed: () => handleDateSelection('Tomorrow'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: selectedDateLabel == 'Tomorrow'
                                  ? Colors.transparent
                                  : const Color(0xFFF0F0F0),
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 15,
                              ),
                            ),
                            child: Text(
                              'Tomorrow',
                              style: TextStyle(
                                color: selectedDateLabel == 'Tomorrow'
                                    ? Colors.white
                                    : Colors.black,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 30),
                    const Text(
                      'PROJECTS',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 30),
                    SizedBox(
                      height: 60,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: projects.length + 1,
                        itemBuilder: (context, index) {
                          if (index == 0) {
                            return Container(
                              width: 45,
                              height: 45,
                              margin: const EdgeInsets.only(right: 10.0),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey.shade400),
                                borderRadius: BorderRadius.circular(15),
                              ),
                              child: IconButton(
                                icon: const Icon(
                                  Icons.add,
                                  color: Colors.black,
                                ),
                                onPressed: showAddProjectDialog,
                              ),
                            );
                          }
                          final project = projects[index - 1];
                          File? projectImage = project['image'] as File?;
                          bool isSelected = selectedProject == project['name'];

                          return Padding(
                            padding: const EdgeInsets.only(right: 10.0),
                            child: Container(
                              decoration: isSelected
                                  ? BoxDecoration(
                                      borderRadius: BorderRadius.circular(15),
                                      gradient: RadialGradient(
                                        radius: 1.0,
                                        colors: [
                                          Color(0xFF000000),
                                          Color.fromARGB(255, 24, 18, 18),
                                          Color(0xFF000000),
                                        ],
                                        stops: [0.0, 0.6, 1.0],
                                        center: Alignment.center,
                                      ),
                                    )
                                  : null,
                              child: ElevatedButton(
                                onPressed: () {
                                  setState(() {
                                    selectedProject = project['name'];
                                  });
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: isSelected
                                      ? Colors.transparent
                                      : Colors.black.withOpacity(0.05),
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15),
                                    side: projectImage == null && !isSelected
                                        ? BorderSide(
                                            color: Colors.black.withOpacity(
                                              0.1,
                                            ),
                                            width: 1,
                                          )
                                        : BorderSide.none,
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 20,
                                    vertical: 15,
                                  ),
                                ),
                                child: Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    if (projectImage != null)
                                      Positioned.fill(
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(
                                            15,
                                          ),
                                          child: Image.file(
                                            projectImage,
                                            fit: BoxFit.cover,
                                            color: isSelected
                                                ? Colors.blue.withOpacity(0.6)
                                                : Colors.black.withOpacity(0.4),
                                            colorBlendMode: BlendMode.darken,
                                          ),
                                        ),
                                      ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          project['name'],
                                          style: TextStyle(
                                            color: isSelected
                                                ? Colors.white
                                                : (projectImage != null
                                                      ? Colors.white
                                                      : Colors.black),
                                            fontWeight: FontWeight.bold,
                                            shadows: projectImage != null
                                                ? [
                                                    const Shadow(
                                                      blurRadius: 3.0,
                                                      color: Colors.black,
                                                      offset: Offset(1.0, 1.0),
                                                    ),
                                                  ]
                                                : null,
                                          ),
                                        ),
                                        IconButton(
                                          icon: const Icon(
                                            Icons.close,
                                            size: 15,
                                            color: Colors.white,
                                          ),
                                          onPressed: () =>
                                              removeProject(index - 1),
                                          splashRadius: 1,
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 30),
                    const Text(
                      'TITLE',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: titleController,
                      maxLines: 1,
                      decoration: const InputDecoration(
                        hintText: 'Purchase travel insurance',
                        hintStyle: TextStyle(color: Colors.grey),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(15)),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: Color(0xFFF0F0F0),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 15,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: descriptionController,
                      maxLines: 9,
                      decoration: const InputDecoration(
                        hintText: 'Description (optional)',
                        hintStyle: TextStyle(color: Colors.grey),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(15)),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: Color(0xFFF0F0F0),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 15,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(20),
        child: ElevatedButton(
          onPressed: _saveTask,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.black,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            padding: const EdgeInsets.symmetric(vertical: 20),
          ),
          child: const Text(
            'Create',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}
