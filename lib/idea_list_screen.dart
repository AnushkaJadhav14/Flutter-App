import 'package:flutter/material.dart';
import 'idea_details_screen.dart';

class IdeaListScreen extends StatelessWidget {
  const IdeaListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Dummy idea list (Replace with actual backend data)
    List<Map<String, String>> ideas = [
      {"title": "AI-powered Finance App", "status": "Pending"},
      {"title": "Green Energy Initiatives", "status": "Approved"},
      {"title": "New Loan Scheme", "status": "Rejected"},
    ];

    // Colors from LoginScreen
    final Color redColor = const Color.fromRGBO(237, 50, 55, 1);
    final Color blueColor = const Color.fromRGBO(55, 75, 146, 1);
    final Color whiteColor = Colors.white;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Submitted Ideas"),
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
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // Search Bar
                TextField(
                  decoration: InputDecoration(
                    labelText: 'Search Ideas',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    prefixIcon: const Icon(Icons.search),
                  ),
                ),
                const SizedBox(height: 20),

                // List of Ideas
                Expanded(
                  child: ListView.builder(
                    itemCount: ideas.length,
                    itemBuilder: (context, index) {
                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        child: ListTile(
                          title: Text(
                            ideas[index]["title"]!,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text("Status: ${ideas[index]["status"]}"),
                          leading: const Icon(Icons.lightbulb_outline),
                          trailing: const Icon(Icons.arrow_forward_ios),
                          onTap: () {
                            // Navigate to idea details screen
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => IdeaDetailsScreen(
                                  ideaTitle: ideas[index]["title"]!,
                                  ideaStatus: ideas[index]["status"]!,
                                ),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
