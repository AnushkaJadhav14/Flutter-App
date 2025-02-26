import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class IdeaDetailsScreen extends StatelessWidget {
  final String ideaId;
  final String ideaTitle;
  final String ideaStatus;
  final VoidCallback refreshList;

  const IdeaDetailsScreen({
    super.key,
    required this.ideaId,
    required this.ideaTitle,
    required this.ideaStatus,
    required this.refreshList,
  });

  Future<void> updateStatus(BuildContext context, String status) async {
    final response = await http.put(
      Uri.parse("http://localhost:5000/update-status/$ideaId"),
      headers: {"Content-Type": "application/json"},
      body: '{"status": "$status"}',
    );

    if (response.statusCode == 200) {
      refreshList();
      Navigator.pop(context);
    }
  }

  Future<void> rejectIdea(BuildContext context) async {
    final response = await http.delete(
      Uri.parse("http://localhost:5000/reject-idea/$ideaId"),
    );

    if (response.statusCode == 200) {
      refreshList();
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final Color redColor = const Color.fromRGBO(237, 50, 55, 1);
    final double screenHeight = MediaQuery.of(context).size.height;
    final double screenWidth = MediaQuery.of(context).size.width;
    final double fontScale = MediaQuery.of(context).textScaleFactor;

    double responsiveFontSize(double size) {
      return size * fontScale;
    }

    EdgeInsets responsivePadding() {
      return EdgeInsets.symmetric(
        horizontal: 16.0,
        vertical: screenHeight * 0.03,
      );
    }

    bool isSmallScreen = screenWidth < 600;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          ideaTitle,
          style: TextStyle(fontSize: responsiveFontSize(20)),
        ),
        backgroundColor: redColor,
      ),
      body: Padding(
        padding: responsivePadding(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Idea Title
            Text(
              "Idea Title:",
              style: TextStyle(
                fontSize: responsiveFontSize(18),
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              ideaTitle,
              style: TextStyle(fontSize: responsiveFontSize(16)),
            ),
            SizedBox(height: screenHeight * 0.02),

            Text(
              "Status:",
              style: TextStyle(
                fontSize: responsiveFontSize(18),
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              ideaStatus,
              style: TextStyle(
                fontSize: responsiveFontSize(16),
                color: Colors.blue,
              ),
            ),
            SizedBox(height: screenHeight * 0.04),

            isSmallScreen
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Center(
                        child: SizedBox(
                          width: 180,
                          child: ElevatedButton(
                            onPressed: () => updateStatus(context, "Approved"),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                            ),
                            child: Text(
                              "Approve",
                              style: TextStyle(
                                fontSize: responsiveFontSize(16),
                                color: Colors.black,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 10),
                      Center(
                        child: SizedBox(
                          width: 180,
                          child: ElevatedButton(
                            onPressed: () => rejectIdea(context),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                            ),
                            child: Text(
                              "Reject",
                              style: TextStyle(
                                fontSize: responsiveFontSize(16),
                                color: Colors.black,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 10),
                      Center(
                        child: SizedBox(
                          width: 180,
                          child: ElevatedButton(
                            onPressed: () =>
                                updateStatus(context, "Recommend to L2"),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.orange,
                            ),
                            child: Text(
                              "Recommend to L2",
                              style: TextStyle(
                                fontSize: responsiveFontSize(16),
                                color: Colors.black,
                              ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                          ),
                        ),
                      ),
                    ],
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 180,
                        child: ElevatedButton(
                          onPressed: () => updateStatus(context, "Approved"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                          ),
                          child: Text(
                            "Approve",
                            style: TextStyle(
                              fontSize: responsiveFontSize(16),
                              color: Colors.black,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                      SizedBox(width: 10),
                      SizedBox(
                        width: 180,
                        child: ElevatedButton(
                          onPressed: () => rejectIdea(context),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                          ),
                          child: Text(
                            "Reject",
                            style: TextStyle(
                              fontSize: responsiveFontSize(16),
                              color: Colors.black,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                      SizedBox(width: 10),
                      SizedBox(
                        width: 180,
                        child: ElevatedButton(
                          onPressed: () =>
                              updateStatus(context, "Recommend to L2"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange,
                          ),
                          child: Text(
                            "Recommend to L2",
                            style: TextStyle(
                              fontSize: responsiveFontSize(16),
                              color: Colors.black,
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ),
                      ),
                    ],
                  ),
          ],
        ),
      ),
    );
  }
}
