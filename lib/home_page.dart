import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'login.dart';
import 'project_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';



class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final user = FirebaseAuth.instance.currentUser;
  final firestore = FirebaseFirestore.instance;

  Future<void> addProject() async {
    final TextEditingController titleController = TextEditingController();
    final TextEditingController descriptionController = TextEditingController();
    final TextEditingController taskCountController = TextEditingController();

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('New Project'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(hintText: 'Project Title'),
            ),
            TextField(
              controller: descriptionController,
              decoration: const InputDecoration(hintText: 'Description'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              final title = titleController.text.trim();
              final description = descriptionController.text.trim();
              if (title.isNotEmpty) {
                await firestore
                    .collection('users')
                    .doc(user!.uid)
                    .collection('projects')
                    .add({
                  'title': title,
                  'description': description,
                  'createdAt': FieldValue.serverTimestamp(),
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

  Stream<QuerySnapshot> getProjectsStream() {
    return firestore
        .collection('users')
        .doc(user!.uid)
        .collection('projects')
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Projects'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.pushReplacement(context, LoginPage.route());
            },
          )
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: getProjectsStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No projects yet'));
          }

          final projects = snapshot.data!.docs;

          return ListView.builder(
            itemCount: projects.length,
            itemBuilder: (context, index) {
              final project = projects[index];
              final title = project['title'] ?? 'Untitled';
              final description = project['description'] ?? '';

              return Card(
                child: ListTile(
                  title: Text(title),
                  subtitle: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(description),
                      FutureBuilder<AggregateQuerySnapshot>(
                          future: FirebaseFirestore.instance
                              .collection('users')
                              .doc(user!.uid)
                              .collection('projects')
                              .doc(project.id)
                              .collection('tasks')
                              .count()
                              .get(),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState == ConnectionState.waiting) {
                              return Text('Loading...');
                            } else if (snapshot.hasError) {
                              return Text('Error');
                            } else {
                              final count = snapshot.data?.count ?? 0;
                              return Text('$count', style: TextStyle(fontSize: 20),);
                            }
                          },
                      )
                    ],
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ProjectPage(
                          projectId: project.id,
                          projectTitle: title,
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: addProject,
        child: const Icon(Icons.add),
      ),
    );
  }
}
