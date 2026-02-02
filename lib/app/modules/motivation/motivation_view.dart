import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class MotivationView extends StatelessWidget {
  const MotivationView({super.key});

  Future<List<Map<String, dynamic>>> _loadMotivations() async {
    final data = await rootBundle.loadString('assets/data/motivation.json');
    final list = json.decode(data) as List<dynamic>;
    return list.map((e) => e as Map<String, dynamic>).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Motivasi Harian'),
        centerTitle: true,
        elevation: 0,
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _loadMotivations(),
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          final items = snapshot.data ?? [];
          return Padding(
            padding: const EdgeInsets.all(12.0),
            child: ListView.separated(
              itemCount: items.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final it = items[index];
                return Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (it['title'] != null)
                          Text(
                            it['title'],
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                        const SizedBox(height: 8),
                        Text(
                          it['text'] ?? '',
                          style: Theme.of(
                            context,
                          ).textTheme.bodyMedium?.copyWith(height: 1.4),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
