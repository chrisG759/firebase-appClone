import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ProjectPage extends StatefulWidget {
  final String projectId;
  final String projectTitle;

  const ProjectPage({
    super.key,
    required this.projectId,
    required this.projectTitle,
  });

  @override
  State<ProjectPage> createState() => _ProjectPageState();
}

class _ProjectPageState extends State<ProjectPage> {
  final user = FirebaseAuth.instance.currentUser;
  final firestore = FirebaseFirestore.instance;

  // Add a new task to this project
  Future<void> addTask() async {
    final TextEditingController taskTitleController = TextEditingController();

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('New Task'),
        content: TextField(
          controller: taskTitleController,
          decoration: const InputDecoration(hintText: 'Task title'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              final title = taskTitleController.text.trim();
              if (title.isNotEmpty) {
                await firestore
                    .collection('users')
                    .doc(user!.uid)
                    .collection('projects')
                    .doc(widget.projectId)
                    .collection('tasks')
                    .add({
                  'title': title,
                  'createdAt': FieldValue.serverTimestamp(),
                  'completed': false,
                });
              }
              Navigator.pop(context);
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  // Get tasks stream
  Stream<QuerySnapshot> getTasksStream() {
    return firestore
        .collection('users')
        .doc(user!.uid)
        .collection('projects')
        .doc(widget.projectId)
        .collection('tasks')
        .orderBy('createdAt', descending: false)
        .snapshots();
  }

  // Toggle task completed
  Future<void> toggleCompleted(DocumentSnapshot task) async {
    await firestore
        .collection('users')
        .doc(user!.uid)
        .collection('projects')
        .doc(widget.projectId)
        .collection('tasks')
        .doc(task.id)
        .update({
      'completed': !(task['completed'] as bool),
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.projectTitle),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: getTasksStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No tasks yet. Add one!'));
          }

          final tasks = snapshot.data!.docs;

          return ListView.builder(
            itemCount: tasks.length,
            itemBuilder: (context, index) {
              final task = tasks[index];
              final title = task['title'] ?? 'Untitled';
              final completed = task['completed'] as bool;

              return ListTile(
                title: Text(
                  title,
                  style: TextStyle(
                      decoration: completed
                          ? TextDecoration.lineThrough
                          : TextDecoration.none),
                ),
                trailing: Checkbox(
                  value: completed,
                  onChanged: (_) => toggleCompleted(task),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: addTask,
        child: const Icon(Icons.add),
      ),
    );
  }
}
