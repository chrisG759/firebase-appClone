import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddProjectPage extends StatefulWidget{
  const AddProjectPage({super.key});

  @override
  State<AddProjectPage> createState() => _AddProjectPageState();
}

class _AddProjectPageState extends State<AddProjectPage> {
  final _formKey = GlobalKey<FormState>();

  final _projectNameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Align(
        alignment: Alignment.center,
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              TextFormField(
                controller: _projectNameController,
                decoration: InputDecoration(
                  label: Text("Project Name")
                ),
              ),
              MaterialButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    try {
                      CollectionReference colRef = FirebaseFirestore.instance.collection('projects');
                      await colRef.add({
                        "name": _projectNameController.text.trim(),
                        "created_at": Timestamp.now(), // optional: track creation time
                      });
                      Navigator.pop(context);
                    } catch (e) {
                      // Optional: show error to user
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Failed to add project: $e')),
                      );
                    }
                  }
                },
                child: Text("Submit"),
              )
            ],
          ),
        ),
      ),
    );
  }
}