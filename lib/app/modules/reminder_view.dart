import 'package:date_picker_timeline/date_picker_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'dart:math';
import 'package:intl/intl.dart';

import 'package:super_reminder/app/controllers/task.dart';
import 'package:super_reminder/app/controllers/task_controller.dart';
import 'package:super_reminder/app/data/notification_services.dart';
import 'package:super_reminder/app/modules/home_view.dart';
import 'package:super_reminder/app/utils/add_tasskbar.dart';
import 'package:super_reminder/app/utils/time_utils.dart';
import 'package:super_reminder/app/utils/button.dart';
import 'package:super_reminder/app/utils/theme.dart';
// removed unused TaskTile import (using inline task row)

class ReminderView extends StatefulWidget {
  const ReminderView({super.key});

  @override
  _ReminderViewState createState() => _ReminderViewState();
}

class _ReminderViewState extends State<ReminderView> {
  DateTime _selectedDate = DateTime.now();
  final _taskController = Get.put(TaskController());

  var notifyHelper;
  @override
  void initState() {
    notifyHelper = NotifiHelper();
    notifyHelper.initializeNotification();
    notifyHelper.requestIOSPermissions();
    _showTasks();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _appbar(),
      body: Column(
        children: [
          _addTaskBar(),
          _addDateBar(),
          const SizedBox(height: 10),
          _showTasks(),
        ],
      ),
    );
  }

  Expanded _showTasks() {
    return Expanded(
      child: Obx(() {
        return ListView.builder(
          itemCount: _taskController.taskList.length,
          itemBuilder: (_, index) {
            Task task = _taskController.taskList[index];
            if (task.repeat == 'Daily') {
              DateTime date = parseTimeString(task.startTime.toString());
              var myTime = DateFormat("HH:mm").format(date);
              notifyHelper
                  .scheduledNotification(
                    int.parse(myTime.toString().split(":")[0]),
                    int.parse(myTime.toString().split(":")[1]),
                    task,
                  )
                  .catchError((e, st) {
                    print(
                      'Error scheduling notification for task ${task.id} (startTime=${task.startTime}): $e',
                    );
                    print(st);
                  });
              return AnimationConfiguration.staggeredList(
                position: index,
                child: SlideAnimation(
                  child: FadeInAnimation(
                    child: Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              _showBottomSheet(context, task);
                            },
                            child: _buildTaskRow(task),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }
            if (task.date == DateFormat.yMd().format(_selectedDate)) {
              DateTime date = parseTimeString(task.startTime.toString());
              var myTime = DateFormat("HH:mm").format(date);
              if (DateTime.now().day.toString() == task.date!.split('/')[1] &&
                  DateTime.now().month.toString() == task.date!.split('/')[0] &&
                  DateTime.now().year.toString() == task.date!.split('/')[2]) {
                notifyHelper
                    .scheduledNotification(
                      int.parse(myTime.toString().split(":")[0]),
                      int.parse(myTime.toString().split(":")[1]),
                      task,
                    )
                    .catchError((e, st) {
                      print(
                        'Error scheduling notification for task ${task.id} (startTime=${task.startTime}): $e',
                      );
                      print(st);
                    });
              }
              return AnimationConfiguration.staggeredList(
                position: index,
                child: SlideAnimation(
                  child: FadeInAnimation(
                    child: Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              _showBottomSheet(context, task);
                            },
                            child: _buildTaskRow(task),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            } else {
              return Container();
            }
          },
        );
      }),
    );
  }

  void _showBottomSheet(BuildContext context, Task task) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.only(top: 4),
        height: task.isCompleted == 1
            ? MediaQuery.of(context).size.height * 0.24
            : MediaQuery.of(context).size.height * 0.32,
        color: Get.isDarkMode ? darkGreyClr : Colors.white,
        child: Column(
          children: [
            Container(
              height: 6,
              width: 120,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: Get.isDarkMode ? Colors.grey[600] : Colors.grey[300],
              ),
            ),
            const Spacer(),
            task.isCompleted == 1
                ? Container()
                : _bottomSheetButton(
                    label: "Task Completed",
                    ontap: () {
                      _taskController.markTaskCompleted(task, _selectedDate);
                      Get.back();
                    },
                    clr: primaryClr,
                    context: context,
                  ),
            const SizedBox(height: 5),
            _bottomSheetButton(
              label: "Delete Task",
              ontap: () {
                _confirmalert(context, task);
              },
              clr: Colors.red[300]!,
              context: context,
            ),
            const SizedBox(height: 20),
            _bottomSheetButton(
              label: "Stop Reminders",
              ontap: () {
                _stopRemindersFlow(task);
              },
              clr: Colors.orangeAccent,
              context: context,
            ),
            const SizedBox(height: 10),
            _bottomSheetButton(
              label: "Close",
              ontap: () {
                Get.back();
              },
              clr: Colors.red[300]!,
              isClose: true,
              context: context,
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  void _stopRemindersFlow(Task task) async {
    final box = GetStorage();
    final bool isGame = box.read('isGame') == true;
    Get.back(); // close bottom sheet

    if (isGame) {
      final rnd = Random();
      final a = (rnd.nextInt(9) + 1) * 100; // 100..900
      final b = (rnd.nextInt(9) + 1) * 100;
      final correct = a + b;
      final TextEditingController answerC = TextEditingController();
      await showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Solve to stop reminders'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('What is $a + $b ?'),
              const SizedBox(height: 8),
              TextField(
                controller: answerC,
                keyboardType: TextInputType.number,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final ans = int.tryParse(answerC.text.trim());
                if (ans == correct) {
                  if (task.id != null) {
                    NotificationController.cancelNotificationById(task.id!);
                  }
                  _taskController.markTaskCompleted(task, _selectedDate);
                  Navigator.of(ctx).pop();
                  Fluttertoast.showToast(msg: 'Reminders stopped');
                } else {
                  Fluttertoast.showToast(msg: 'Wrong answer');
                }
              },
              child: const Text('Submit'),
            ),
          ],
        ),
      );
    } else {
      if (task.id != null) {
        NotificationController.cancelNotificationById(task.id!);
      }
      Fluttertoast.showToast(msg: 'Reminders stopped');
    }
  }

  void _confirmalert(BuildContext context, Task task) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          title: const Text('Are You sure you want to delete?'),
          content: const Text('The data will be delete permanently'),
          actions: [
            CupertinoDialogAction(
              onPressed: () {
                setState(() {
                  _taskController.delete(task);
                  NotificationController.cancelSchedulesByChannelKey(
                    'basic_channel',
                  );
                  Fluttertoast.showToast(
                    msg: "You've been delete Data",
                    gravity: ToastGravity.BOTTOM,
                    toastLength: Toast.LENGTH_SHORT,
                    textColor: Colors.white,
                    fontSize: 14,
                  );
                  Get.offAll(const ReminderView());
                });
              },
              child: const Text('Yes'),
            ),
            CupertinoDialogAction(
              onPressed: () {
                Get.back();
              },
              child: const Text('No'),
            ),
          ],
        );
      },
    );
  }

  GestureDetector _bottomSheetButton({
    required String label,
    required Function()? ontap,
    required Color clr,
    bool isClose = false,
    required BuildContext context,
  }) {
    return GestureDetector(
      onTap: ontap,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        height: 55,
        width: MediaQuery.of(context).size.width * 0.9,
        decoration: BoxDecoration(
          border: Border.all(
            width: 2,
            color: isClose == true
                ? Get.isDarkMode
                      ? Colors.grey[600]!
                      : Colors.grey[300]!
                : clr,
          ),
          borderRadius: BorderRadius.circular(20),
          color: isClose == true ? Colors.transparent : clr,
        ),
        child: Center(
          child: Text(
            label,
            style: isClose
                ? titleStyle
                : titleStyle.copyWith(color: Colors.white),
          ),
        ),
      ),
    );
  }

  Container _addDateBar() {
    return Container(
      margin: const EdgeInsets.only(top: 20, left: 20),
      child: DatePicker(
        DateTime.now(),
        height: 100,
        width: 80,
        initialSelectedDate: DateTime.now(),
        selectionColor: primaryClr,
        selectedTextColor: Colors.white,
        dateTextStyle: addDateBar1,
        dayTextStyle: addDateBar2,
        monthTextStyle: addDateBar3,
        onDateChange: (date) {
          setState(() {
            _selectedDate = date;
          });
        },
      ),
    );
  }

  Container _addTaskBar() {
    return Container(
      margin: const EdgeInsets.only(left: 10, right: 10, top: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  DateFormat.yMMMMd().format(DateTime.now()),
                  style: subHeadingStyle,
                ),
                Text("Today", style: HeadingStyle),
              ],
            ),
          ),
          MyButton(
            label: "+ Add Reminder",
            onTap: () async {
              await Get.to(const AddTaskPage());
              _taskController.getTask();
            },
          ),
        ],
      ),
    );
  }

  AppBar _appbar() {
    return AppBar(
      elevation: 8,
      backgroundColor: const Color(0XFFE7D2CC),
      title: Text('Reminder', style: HeadingStyle),
      leading: IconButton(
        onPressed: () => Get.off(const HomeView()),
        icon: const Icon(Icons.arrow_back_ios),
        color: Colors.black,
      ),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(25)),
      ),
    );
  }

  Widget _buildTaskRow(Task task) {
    // Priority label
    final priority = (task.color ?? 0) > 0 ? 'High' : 'Normal';
    final time = parseTimeString(task.startTime.toString());
    final timeStr = DateFormat('HH:mm').format(time);
    final dateStr = task.date ?? DateFormat.yMd().format(_selectedDate);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
      decoration: BoxDecoration(
        color: Get.isDarkMode ? Colors.grey[850] : Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  task.title ?? '',
                  style: titleStyle.copyWith(fontSize: 16),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: (task.color ?? 0) > 0
                      ? Colors.redAccent
                      : Colors.green,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  priority,
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Text(
                '$timeStr / ${dateStr.replaceAll("/", "")}',
                style: subHeadingStyle.copyWith(fontSize: 12),
              ),
              const Spacer(),
              Text(
                task.repeat ?? '',
                style: subHeadingStyle.copyWith(fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            task.note ?? '',
            style: subHeadingStyle.copyWith(fontSize: 13),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Text(
                'Spam: ${task.isCompleted == 1 ? "OFF" : "ON"}',
                style: subHeadingStyle.copyWith(fontSize: 12),
              ),
              const SizedBox(width: 12),
              Text(
                'Repeat: ${task.repeat ?? "-"}',
                style: subHeadingStyle.copyWith(fontSize: 12),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
