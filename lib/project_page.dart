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

  final _formKey = GlobalKey<FormState>();


  Future<void> addTask() async {
    final TextEditingController taskTitleController = TextEditingController();
    final TextEditingController taskDescriptionController = TextEditingController();

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('New Task'),
        content: Form(
            key: _formKey,
            child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    validator: (value){
                      if(value == null || value.isEmpty){
                        return "Please enter task title";
                      }
                      return null;
                    },
                    controller: taskTitleController,
                    decoration: const InputDecoration(hintText: 'Task title'),
                  ),
                  TextFormField(
                    validator: (value){
                      if(value == null || value.isEmpty){
                        return "Please enter task description";
                      }
                      return null;
                    },
                    controller: taskDescriptionController,
                    decoration: const InputDecoration(hintText: 'Task description'),
                  ),
                ]
            )
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              final title = taskTitleController.text.trim();
              final description = taskDescriptionController.text.trim();
              if (_formKey.currentState!.validate()) {
                await firestore
                    .collection('users')
                    .doc(user!.uid)
                    .collection('projects')
                    .doc(widget.projectId)
                    .collection('tasks')
                    .add({
                  'title': title,
                  'description': description,
                  'createdAt': FieldValue.serverTimestamp(),
                  'completed': false,
                });
                Navigator.pop(context);
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }
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
            return const Center(child: Text('No tasks yet'));
          }

          final tasks = snapshot.data!.docs;

          return ListView.builder(
            itemCount: tasks.length,
            itemBuilder: (context, index) {
              final task = tasks[index];
              final title = task['title'] ?? 'Untitled';
              final completed = task['completed'] as bool;


              Future<void> viewTask() async {
                final taskTitle = task['title'] ?? 'Untitled';
                final taskDescription = task['description'] ?? 'No description';
                final Timestamp? createdAtTimestamp = task['createdAt'];
                final createdAt = createdAtTimestamp != null
                    ? createdAtTimestamp.toDate().toString()
                    : 'Unknown date';
                await showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: Text(taskTitle),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Description: $taskDescription'),
                        const SizedBox(height: 10),
                        Text('Created at: $createdAt'),
                      ],
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Close'),
                      ),
                    ],
                  ),
                );
              }
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
                onLongPress: viewTask,
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
