// using NotifiHelper (flutter_local_notifications)
import 'package:flutter/material.dart';

import 'dart:async';
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:super_reminder/app/modules/reminder_view.dart';
import 'package:super_reminder/app/routes/app_pages.dart';
import 'package:super_reminder/app/utils/theme.dart';

import '../data/notification_services.dart';

class _Quote {
  final String title;
  final String text;
  _Quote(this.title, this.text);
  factory _Quote.fromMap(Map<String, dynamic> m) =>
      _Quote(m['title'] ?? '', m['text'] ?? '');
}

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  List<_Quote> _quotes = [];
  int _quoteIndex = 0;
  Timer? _quoteTimer;

  @override
  void initState() {
    super.initState();
    NotifiHelper().initializeNotification();
    _loadQuotes();
  }

  Future<void> _loadQuotes() async {
    try {
      final s = await rootBundle.loadString('assets/data/motivation.json');
      final List parsed = json.decode(s) as List;
      setState(() {
        _quotes = parsed
            .map((e) => _Quote.fromMap(e as Map<String, dynamic>))
            .toList();
      });
      _quoteTimer = Timer.periodic(const Duration(seconds: 5), (_) {
        setState(
          () => _quoteIndex =
              (_quoteIndex + 1) % (_quotes.isEmpty ? 1 : _quotes.length),
        );
      });
    } catch (_) {}
  }

  @override
  void dispose() {
    _quoteTimer?.cancel();
    super.dispose();
  }

  Widget _featureRow(IconData icon, String label, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, size: 28, color: Colors.black87),
      title: Text(label, style: titleStyle.copyWith(fontSize: 16)),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 8.0,
        vertical: 4.0,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final quote = _quotes.isNotEmpty ? _quotes[_quoteIndex] : null;
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(child: Text('Aloha', style: HeadingStyle)),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        DateFormat('dd MMM yyyy').format(DateTime.now()),
                        style: subHeadingStyle,
                      ),
                      const SizedBox(height: 6),
                      InkWell(
                        onTap: () => Get.toNamed(Routes.MOTIVATION),
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: const Color(0xFFe0e0e0),
                          ),
                          child: const Text(
                            'I',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 18),
              // Quote card
              if (quote != null)
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          quote.title,
                          style: titleStyle.copyWith(fontSize: 16),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          quote.text,
                          style: subHeadingStyle.copyWith(fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                ),
              const SizedBox(height: 12),
              const Divider(),
              const SizedBox(height: 8),
              Text('Features', style: HeadingStyle.copyWith(fontSize: 18)),
              const SizedBox(height: 6),
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    _featureRow(
                      Icons.format_quote,
                      'Motivasi',
                      () => Get.toNamed(Routes.MOTIVATION),
                    ),
                    _featureRow(
                      Icons.alarm,
                      'Reminder',
                      () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const ReminderView()),
                      ),
                    ),
                    _featureRow(
                      Icons.check_box,
                      'Todo',
                      () => Get.toNamed(Routes.TODO),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
