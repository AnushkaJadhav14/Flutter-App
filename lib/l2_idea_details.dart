import 'package:flutter/material.dart';

class L2IdeaDetailsScreen extends StatelessWidget {
  final String ideaTitle;
  final String submitter;

  const L2IdeaDetailsScreen({
    super.key,
    required this.ideaTitle,
    required this.submitter,
  });

  static const Color redColor = Color.fromRGBO(237, 50, 55, 1);
  static const Color blueColor = Color.fromRGBO(55, 75, 146, 1);
  static const Color whiteColor = Colors.white;

  void _approveIdea() {
    // API Call to approve the idea
    print("Idea Approved: $ideaTitle");
  }

  void _rejectIdea() {
    // API Call to reject the idea
    print("Idea Rejected: $ideaTitle");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Idea Details"),
        backgroundColor: redColor,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [redColor, blueColor, whiteColor],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                ideaTitle,
                style:
                    const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Text(
                "Submitted by: $submitter",
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () => _approveIdea(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          vertical: 12, horizontal: 24),
                    ),
                    child: const Text("Approve"),
                  ),
                  ElevatedButton(
                    onPressed: () => _rejectIdea(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          vertical: 12, horizontal: 24),
                    ),
                    child: const Text("Reject"),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
