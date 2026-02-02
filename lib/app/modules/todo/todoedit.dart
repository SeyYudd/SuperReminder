import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:super_reminder/app/utils/theme.dart';

class TodoEdit extends StatelessWidget {
  const TodoEdit({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 8,
        backgroundColor: const Color(0XFFEEEDE7),
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(25))),
        title: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text("Edit Todo", style: HeadingStyle),
        ),
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: const Icon(Icons.arrow_back_ios),
          color: Colors.black,
        ),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.edit, color: Colors.black),
            onPressed: () {Get.back();},
          )
        ],
      ),
      body: Center(
        child: Container(
          width: 350,
          height: 600,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: const Color.fromARGB(255, 156, 155, 149),
          ),
        ),
      ),
    );
  }
}
