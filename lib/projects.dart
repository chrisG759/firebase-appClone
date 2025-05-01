import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';


class ProjectsPage extends StatelessWidget{
  const ProjectsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Tasks"),
        centerTitle: true,
      ),
      drawer: Drawer(
        child: DrawerHeader(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Projects", style: TextStyle(fontSize: 25,),),
                IconButton(
                    onPressed: () {

                    },
                    icon: Icon(CupertinoIcons.plus)
                )
              ],
            )
        ),
      ),
    );
  }
}