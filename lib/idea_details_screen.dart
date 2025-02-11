import 'package:flutter/material.dart';

class IdeaDetailsScreen extends StatelessWidget {
  final String ideaTitle;
  final String ideaStatus;

  const IdeaDetailsScreen({
    super.key,
    required this.ideaTitle,
    required this.ideaStatus,
  });

  @override
  Widget build(BuildContext context) {
    final Color redColor = const Color.fromRGBO(237, 50, 55, 1);

    return Scaffold(
      appBar: AppBar(
        title: Text(ideaTitle),
        backgroundColor: redColor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Idea Title:",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Text(ideaTitle, style: TextStyle(fontSize: 16)),
            SizedBox(height: 20),
            Text("Status:",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Text(ideaStatus,
                style: TextStyle(fontSize: 16, color: Colors.blue)),
            SizedBox(height: 40),

            // Action Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () {
                    // Approve Action
                  },
                  style:
                      ElevatedButton.styleFrom(backgroundColor: Colors.green),
                  child: Text("Approve"),
                ),
                ElevatedButton(
                  onPressed: () {
                    // Reject Action
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  child: Text("Reject"),
                ),
                ElevatedButton(
                  onPressed: () {
                    // Recommend to L2
                  },
                  style:
                      ElevatedButton.styleFrom(backgroundColor: Colors.orange),
                  child: Text("Recommend to L2"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
