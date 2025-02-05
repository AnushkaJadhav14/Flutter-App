import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import '../service/mongo_auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _corporateIdController = TextEditingController();
  final _otpController = TextEditingController();
  final MongoAuthService _authService = MongoAuthService();
  bool _otpSent = false;
  bool _isLoading = false;

  final List<String> imageList = [
    "assets/images/thumbnail.jpg",
    "assets/images/hat.png",
    "assets/images/image3.jpg",
  ];

  // Define theme colors
  final Color redColor = const Color.fromRGBO(237, 50, 55, 1);
  final Color blueColor = const Color.fromRGBO(55, 75, 146, 1);

  // Function to handle OTP request
  void _getOtp() async {
    setState(() => _isLoading = true);
    String corporateId = _corporateIdController.text.trim();

    // Check if Corporate ID is entered
    if (corporateId.isEmpty) {
      _showMessage('Please enter Corporate ID');
      setState(() => _isLoading = false);
      return;
    }

    // Request OTP
    String response = await _authService.requestOtp(corporateId);
    setState(() {
      _isLoading = false;
      _otpSent = response == "OTP Sent";
    });
    _showMessage(response);
  }

  // Function to verify OTP
  void _verifyOtp() async {
    String corporateId = _corporateIdController.text.trim();
    String otp = _otpController.text.trim();

    // Check if OTP is entered
    if (otp.isEmpty) {
      _showMessage('Please enter OTP');
      return;
    }

    String response = await _authService.verifyOtp(corporateId, otp);
    _showMessage(response);

    if (response == "Login Successful") {
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => const NextPage()));
    }
  }

  // Show messages in Snackbar
  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Aadhar Housing Finance Limited'),
        backgroundColor: redColor,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [redColor, blueColor],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CarouselSlider(
                      options: CarouselOptions(
                        height: 200.0,
                        autoPlay: true,
                        enlargeCenterPage: true,
                      ),
                      items: imageList.map((item) {
                        return Container(
                          margin: const EdgeInsets.all(5.0),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: const [
                              BoxShadow(color: Colors.black26, blurRadius: 5)
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.asset(item, fit: BoxFit.cover),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 30),
                    TextField(
                      controller: _corporateIdController,
                      decoration: InputDecoration(
                        labelText: 'Corporate ID',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 20),
                    _isLoading
                        ? const CircularProgressIndicator()
                        : ElevatedButton(
                            style: ElevatedButton.styleFrom(
                                backgroundColor: redColor),
                            onPressed: _getOtp,
                            child: const Text('Get OTP'),
                          ),
                    if (_otpSent) ...[
                      const SizedBox(height: 20),
                      TextField(
                        controller: _otpController,
                        decoration: InputDecoration(
                          labelText: 'Enter OTP',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                        maxLength: 4,
                        keyboardType: TextInputType.number,
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            backgroundColor: blueColor),
                        onPressed: _verifyOtp,
                        child: const Text('Verify OTP'),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class NextPage extends StatelessWidget {
  const NextPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Dashboard')),
      body: const Center(child: Text('Welcome to the dashboard!')),
    );
  }
}
