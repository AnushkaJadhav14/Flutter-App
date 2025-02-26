import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import '../service/mongo_auth_service.dart';
import 'otp_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _corporateIdController = TextEditingController();
  final MongoAuthService _authService = MongoAuthService();
  bool _isLoading = false;

  final List<String> imageList = [
    "assets/images/thumbnail.jpg",
    "assets/images/hat.png",
    "assets/images/image3.jpg",
  ];

  final Color redColor = const Color.fromRGBO(237, 50, 55, 1);
  final Color blueColor = const Color.fromRGBO(55, 75, 146, 1);
  final Color whiteColor = Colors.white;

  void _getOtp() async {
    setState(() => _isLoading = true);
    String corporateId = _corporateIdController.text.trim();

    if (corporateId.isEmpty) {
      _showMessage('Please enter Corporate ID');
      setState(() => _isLoading = false);
      return;
    }

    String response = await _authService.requestOtp(corporateId);
    setState(() => _isLoading = false);
    _showMessage(response);

    if (response == "OTP Sent") {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => OtpScreen(corporateId: corporateId),
        ),
      );
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Padding(
          padding: const EdgeInsets.all(8.0), 
          child: Image.asset(
            'assets/images/logo2.png', 
            width: MediaQuery.of(context).size.width > 600
                ? 50
                : 30, 
            fit: BoxFit.contain, 
          ),
        ),
        title: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            'Aadhar Housing Finance Limited',
            style: TextStyle(
              fontSize: MediaQuery.of(context).size.width > 600
                  ? 23
                  : 18, 
              color: Colors.white,
            ),
          ),
        ),
        backgroundColor: redColor,
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          // Detect screen size
          double screenWidth = constraints.maxWidth;
          double screenHeight = constraints.maxHeight;
          bool isLargeScreen = screenWidth > 600; 
          return SingleChildScrollView(
            child: Container(
              height:
                  screenHeight, 
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topRight,
                  end: Alignment.bottomRight,
                  colors: [redColor, blueColor, whiteColor],
                ),
              ),
              child: SafeArea(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 20.0),
                          child: CarouselSlider(
                            options: CarouselOptions(
                              height: isLargeScreen
                                  ? screenHeight * 0.5
                                  : screenHeight *
                                      0.3, 
                              autoPlay: true,
                              enlargeCenterPage: true,
                              enableInfiniteScroll: true,
                            ),
                            items: imageList.map((item) {
                              return Builder(
                                builder: (BuildContext context) {
                                  return Container(
                                    margin: const EdgeInsets.symmetric(
                                        horizontal:
                                            8.0), 
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(12),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black26,
                                          blurRadius: 5,
                                          spreadRadius: 2,
                                        ),
                                      ],
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(12),
                                      child: Image.asset(
                                        item,
                                        fit: BoxFit
                                            .contain, 
                                        width: isLargeScreen
                                            ? screenWidth * 0.7
                                            : screenWidth *
                                                0.9, 
                                      ),
                                    ),
                                  );
                                },
                              );
                            }).toList(),
                          ),
                        ),
                        const SizedBox(height: 50),
                        SizedBox(
                          width: isLargeScreen
                              ? screenWidth * 0.5
                              : screenWidth *
                                  0.85, 
                          child: TextField(
                            controller: _corporateIdController,
                            decoration: InputDecoration(
                              labelText: 'Corporate ID',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              filled: true,
                              fillColor: Colors.white,
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 12),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        _isLoading
                            ? const CircularProgressIndicator()
                            : SizedBox(
                                width: isLargeScreen ? null : screenWidth * 0.4,
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: redColor,
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 12, horizontal: 16),
                                    shadowColor: Colors.black26,
                                    elevation: 5,
                                  ),
                                  onPressed: _getOtp,
                                  child: const Text(
                                    'Get OTP',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              )
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
