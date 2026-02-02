import 'dart:convert';
import 'package:super_reminder/app/controllers/db_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:get/get.dart';
import 'package:super_reminder/app/utils/theme.dart';

class TodoView extends StatefulWidget {
  const TodoView({
    super.key,
  });
  @override
  _TodoViewState createState() => _TodoViewState();
}

class _TodoViewState extends State<TodoView> {
  String title = "";
  String description = "";
  bool isComplete = false;
  @override
  void initState() {
    super.initState();
    DBHelper.initDB();
  }

  Future<void> createToDo() async {
    final id = DateTime.now().toIso8601String();
    final reminder = {
      'id': id,
      'title': title,
      'description': description,
      'display':
          json.encode({'category': 'todo', 'color': '#FFFFFF', 'priority': 3}),
      'schedule': json.encode({
        'targetTime': DateTime.now().toIso8601String(),
        'repeatDays': [],
        'isExact': false
      }),
      'spam': json.encode({
        'isEnabled': false,
        'intervalSeconds': 0,
        'maxRetries': 0,
        'isPersistent': false
      }),
      'challenge': json
          .encode({'type': 'NONE', 'difficulty': 'EASY', 'isLocked': false}),
      'status': json.encode({'isCompleted': false, 'lastFired': null}),
    };
    await DBHelper.insertReminder(reminder);
    setState(() {});
  }

  Future<void> deleteTodo(String id) async {
    await DBHelper.deleteReminder(id);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _appbar(),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: DBHelper.queryReminders(),
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          final items = snapshot.data ?? [];
          if (items.isEmpty) {
            return Center(
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                  const Icon(Icons.sentiment_dissatisfied_outlined,
                      size: 50, color: Colors.grey),
                  Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Click the ', style: subHeadingStyle),
                        const Icon(Icons.add_circle_sharp, color: Colors.grey),
                        Text(' to add new Todo', style: subHeadingStyle)
                      ])
                ]));
          }
          return AnimationLimiter(
            child: ListView.builder(
                padding: const EdgeInsets.only(top: 10),
                shrinkWrap: true,
                itemCount: items.length,
                itemBuilder: (BuildContext context, int index) {
                  final documentSnapshot = items[index];
                  return AnimationConfiguration.staggeredList(
                      position: index,
                      delay: const Duration(milliseconds: 100),
                      child: SlideAnimation(
                        duration: const Duration(milliseconds: 2500),
                        curve: Curves.fastLinearToSlowEaseIn,
                        child: FadeInAnimation(
                            curve: Curves.fastLinearToSlowEaseIn,
                            duration: const Duration(milliseconds: 2500),
                            key: UniqueKey(),
                            child: Card(
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20)),
                              elevation: 8,
                              child: ExpansionTile(
                                leading: IconButton(
                                    onPressed: () {
                                      setState(() {
                                        isComplete = !isComplete;
                                      });
                                    },
                                    icon: Icon(Icons.done_all_rounded,
                                        color: isComplete
                                            ? Colors.greenAccent
                                            : Colors.grey)),
                                title: Center(
                                  child: Text(documentSnapshot["title"] ?? "",
                                      style: motivationcontextStyle),
                                ),
                                children: <Widget>[
                                  ListTile(
                                    title: Center(
                                      child: Text(
                                          documentSnapshot["description"] ?? "",
                                          style: motivationcontextStyle),
                                    ),
                                    trailing: IconButton(
                                      onPressed: () {
                                        deleteTodo(documentSnapshot['id']);
                                      },
                                      icon: const Icon(
                                        Icons.delete,
                                        color: Colors.red,
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            )),
                      ));
                }),
          );
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20)),
                  title: Text("Add Todo", style: motivationStyle),
                  content: SizedBox(
                    width: 400,
                    height: 100,
                    child: Column(
                      children: [
                        TextFormField(
                          onChanged: (String value) {
                            title = value;
                          },
                          decoration: const InputDecoration(hintText: "Title"),
                        ),
                        TextField(
                          onChanged: (String value) {
                            description = value;
                          },
                          decoration:
                              const InputDecoration(hintText: "Description"),
                        ),
                      ],
                    ),
                  ),
                  actions: <Widget>[
                    TextButton(
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.black87,
                          backgroundColor: const Color(0XFFE7D2CC),
                          elevation: 8,
                          shadowColor: Colors.black,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30)),
                        ),
                        onPressed: () {
                          setState(() {
                            createToDo();
                          });
                          Navigator.of(context).pop();
                        },
                        child: const Text("Add"))
                  ],
                );
              });
        },
        backgroundColor: const Color(0XFFE7D2CC),
        child: const Icon(
          Icons.add,
          color: Colors.black87,
        ),
      ),
    );
  }

  AppBar _appbar() {
    return AppBar(
      elevation: 8,
      backgroundColor: const Color(0XFFEEEDE7),
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(25))),
      title: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text("Todo", style: HeadingStyle),
      ),
      leading: IconButton(
        onPressed: () => Get.back(),
        icon: const Icon(Icons.arrow_back_ios),
        color: Colors.black,
      ),
    );
  }

  // Deleted Firestore delete helper; use deleteTodo(id) directly.
}
