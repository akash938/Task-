* Task+

This Flutter-based mobile application is a task management tool that helps users organize their daily activities. The app allows users to create new tasks, each associated with a custom project and an optional image. Key features include:

Task Creation: Easily add new tasks with a title, description, and due date.

Project Management: Organize tasks into different projects. Users can add new projects with custom names and images.

Persistent Storage: All task data, including projects and subtasks, is stored locally on the device using a SQLite database, ensuring data persists across app sessions.

Interactive UI: Tasks can be marked as completed with a tap. The main screen provides a clean overview of all tasks.

Swipe-to-Delete: Quickly delete tasks by swiping them from right to left on the home screen.

Pull-to-Refresh: The task list can be instantly refreshed by pulling down on the screen.


* Technologies Used

Flutter: UI framework for building cross-platform mobile applications.

SQLite: A lightweight relational database for local data persistence, managed via the sqflite package.

image_picker: A Flutter plugin for picking images from the device's gallery.

path_provider: Provides access to the device's file system for permanent image storage.

uuid: Generates a universally unique identifier (UUID) for each task, ensuring data integrity in the database.
