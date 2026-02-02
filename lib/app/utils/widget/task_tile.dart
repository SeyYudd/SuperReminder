import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:super_reminder/app/controllers/task.dart';
import 'package:super_reminder/app/utils/theme.dart';
import 'package:flutter/material.dart' as mat;

// removed empty import

class TaskTile extends StatelessWidget {
  final Task? task;
  const TaskTile(this.task, {super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      width: MediaQuery.of(context).size.width,
      margin: const EdgeInsets.only(bottom: 12),
      child: Container(
        padding: const EdgeInsets.all(16),
        //  width: SizeConfig.screenWidth * 0.78,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: _getBGClr(task?.color ?? 0),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          task?.title ?? "",
                          style: GoogleFonts.lato(
                            textStyle: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      // priority chip based on color index
                      mat.Chip(
                        label: Text(
                          _priorityLabel(task?.color ?? 0),
                          style: const TextStyle(fontSize: 10),
                        ),
                        backgroundColor: Colors.white24,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.access_time_rounded,
                        color: Colors.grey[200],
                        size: 18,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        "${task!.startTime} - ${task!.endTime}",
                        style: GoogleFonts.lato(
                          textStyle: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[100],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    task?.note ?? "",
                    style: GoogleFonts.lato(
                      textStyle: TextStyle(
                        fontSize: 15,
                        color: Colors.grey[100],
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  // show first hashtag as tag if present
                  _tagChip(task?.note ?? ''),
                ],
              ),
            ),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 10),
              height: 60,
              width: 0.5,
              color: Colors.grey[200]!.withValues(alpha: 0.7),
            ),
            RotatedBox(
              quarterTurns: 3,
              child: Text(
                task!.isCompleted == 1 ? "COMPLETED" : "TODO",
                style: GoogleFonts.lato(
                  textStyle: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  _getBGClr(int no) {
    switch (no) {
      case 0:
        return bataClr;
      case 1:
        return vividPinkClr;
      case 2:
        return cyanClr;
      default:
        return isabelleClr;
    }
  }

  String _priorityLabel(int idx) {
    switch (idx) {
      case 0:
        return 'Low';
      case 1:
        return 'Medium';
      case 2:
        return 'High';
      default:
        return 'Normal';
    }
  }

  Widget _tagChip(String note) {
    final re = RegExp(r'#(\w+)');
    final m = re.firstMatch(note);
    if (m != null) {
      return Padding(
        padding: const EdgeInsets.only(top: 6.0),
        child: Chip(label: Text(m.group(1)!), backgroundColor: Colors.white24),
      );
    }
    return Container();
  }
}
