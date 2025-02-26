import 'package:flutter/material.dart';
import 'l2_idea_details.dart';

class L2AdminDashboard extends StatelessWidget {
  L2AdminDashboard({super.key});

  final Color redColor = Color.fromRGBO(237, 50, 55, 1);
  final Color blueColor = Color.fromRGBO(55, 75, 146, 1);
  final Color whiteColor = Colors.white;

  final List<Map<String, String>> ideas = [
    {"title": "New Marketing Strategy", "submitter": "John Doe"},
    {"title": "AI-Based Loan Processing", "submitter": "Jane Smith"},
  ]; // Replace with actual backend data

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("L2 Admin Dashboard"),
        backgroundColor: redColor,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomRight,
            colors: [redColor, blueColor, whiteColor],
          ),
        ),
        child: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: ideas.length,
          itemBuilder: (context, index) {
            return Card(
              margin: const EdgeInsets.symmetric(vertical: 8),
              child: ListTile(
                title: Text(ideas[index]['title']!),
                subtitle: Text("Submitted by: ${ideas[index]['submitter']}"),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => L2IdeaDetailsScreen(
                        ideaTitle: ideas[index]['title']!,
                        submitter: ideas[index]['submitter']!,
                      ),
                    ),
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }
}
