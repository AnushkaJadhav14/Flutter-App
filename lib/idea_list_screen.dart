import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'idea_details_screen.dart';

class IdeaListScreen extends StatefulWidget {
  const IdeaListScreen({super.key});

  @override
  _IdeaListScreenState createState() => _IdeaListScreenState();
}

class _IdeaListScreenState extends State<IdeaListScreen> {
  List<dynamic> ideas = [];
  bool isLoading = true;
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    fetchIdeas();
  }

  Future<void> fetchIdeas() async {
    try {
      final response = await http.get(Uri.parse("http://localhost:5000/ideas"));
      if (response.statusCode == 200) {
        List<dynamic> responseData = json.decode(response.body);
        setState(() {
          ideas = responseData;
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
      }
    } catch (error) {
      setState(() {
        isLoading = false;
      });
    }
  }

  List<dynamic> getFilteredIdeas() {
    return ideas.where((idea) {
      return idea["ideaDescription"]
          .toString()
          .toLowerCase()
          .contains(searchQuery.toLowerCase());
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final Color redColor = const Color.fromRGBO(237, 50, 55, 1);
    final Color blueColor = const Color.fromRGBO(55, 75, 146, 1);
    final Color whiteColor = Colors.white;

    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;

    final double baseFontSize = screenWidth < 600 ? 14 : 16;
    final double cardMargin = screenWidth < 600 ? 8 : 16;
    final double inputHeight = screenWidth < 600 ? 50 : 60;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Submitted Ideas"),
        backgroundColor: redColor,
      ),
      body: Container(
        width: screenWidth,
        height: screenHeight,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomRight,
            colors: [redColor, blueColor, whiteColor],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: screenWidth < 600 ? 16 : screenWidth * 0.1,
              vertical: 16,
            ),
            child: Column(
              children: [
                SizedBox(
                  height: inputHeight,
                  child: TextField(
                    decoration: InputDecoration(
                      labelText: 'Search Ideas',
                      labelStyle: TextStyle(
                        fontSize: baseFontSize * 1.1,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      prefixIcon: const Icon(Icons.search),
                    ),
                    onChanged: (query) {
                      setState(() {
                        searchQuery = query;
                      });
                    },
                  ),
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : getFilteredIdeas().isEmpty
                          ? const Center(
                              child: Text("No ideas available",
                                  style: TextStyle(fontSize: 16)))
                          : ListView.builder(
                              itemCount: getFilteredIdeas().length,
                              itemBuilder: (context, index) {
                                final idea = getFilteredIdeas()[index];
                                return Card(
                                  margin: EdgeInsets.symmetric(
                                      vertical: cardMargin),
                                  child: ListTile(
                                    title: Text(
                                      idea["ideaDescription"] ??
                                          "No Description",
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: baseFontSize * 1.2,
                                      ),
                                    ),
                                    subtitle: Text(
                                      "Status: ${idea["status"] ?? "Pending"}",
                                      style: TextStyle(
                                        fontSize: baseFontSize,
                                      ),
                                    ),
                                    leading: Icon(
                                      Icons.lightbulb_outline,
                                      size: baseFontSize * 2,
                                    ),
                                    trailing: Icon(
                                      Icons.arrow_forward_ios,
                                      size: baseFontSize * 1.5,
                                    ),
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              IdeaDetailsScreen(
                                            ideaId: idea["_id"],
                                            ideaTitle: idea["ideaDescription"],
                                            ideaStatus:
                                                idea["status"] ?? "Pending",
                                            refreshList: fetchIdeas,
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
