import 'dart:async';
import '../service/mongo_auth_service.dart';
import 'package:flutter/material.dart';
import 'l2_admin_dashboard.dart';
import 'idea_list_screen.dart';
import 'form_page.dart';

class OtpScreen extends StatefulWidget {
  final String corporateId;

  const OtpScreen({super.key, required this.corporateId});

  @override
  _OtpScreenState createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen>
    with SingleTickerProviderStateMixin {
  final List<TextEditingController> otpControllers =
      List.generate(4, (index) => TextEditingController());
  final MongoAuthService _authService = MongoAuthService();

  int _secondsRemaining = 40;
  Timer? _timer;
  bool _isResendAvailable = false;
  late AnimationController _animationController;
  late Animation<Color?> _glowAnimation;

  final Color redColor = const Color.fromRGBO(237, 50, 55, 1);
  final Color blueColor = const Color.fromRGBO(55, 75, 146, 1);
  final Color whiteColor = Colors.white;

  @override
  void initState() {
    super.initState();
    startTimer();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat(reverse: true);

    _glowAnimation = ColorTween(
      begin: redColor.withOpacity(0.4),
      end: redColor.withOpacity(1.0),
    ).animate(_animationController);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      FocusScope.of(context).requestFocus(FocusNode());
    });
  }

  void startTimer() {
    setState(() {
      _secondsRemaining = 40; // Full countdown for OTP expiry
      _isResendAvailable = false; // Disable Resend OTP initially
    });

    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      setState(() {
        if (_secondsRemaining > 0) {
          _secondsRemaining--;

          // Enable Resend OTP only after 5 minutes (300 seconds)
          if (_secondsRemaining == 0) {
            _isResendAvailable = true;
          }
        } else {
          timer.cancel();
        }
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _animationController.dispose();
    super.dispose();
  }

  void submitOtp() async {
    String otp = otpControllers.map((controller) => controller.text).join();
    if (otp.length == 4) {
      Map<String, dynamic> response =
          await _authService.verifyOtp(widget.corporateId, otp);

      if (response.containsKey("error")) {
        if (mounted) {
          _showMessage(response["error"]);
        }
      } else {
        if (mounted) {
          _showMessage("Login Successful");

          // Check the role from the response to decide redirection
          String role = response['role'] ?? '';

          if (role == "adminL1") {
            if (mounted) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const IdeaListScreen()),
              );
            }
          } else if (role == "adminL2") {
            if (mounted) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => L2AdminDashboard()),
              );
            }
          } else {
            if (mounted) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (context) => FormPage(
                          corporateId:
                              widget.corporateId, // pass the corporateId
                        )),
              );
            }
          }
        }
      }
    } else {
      if (mounted) {
        _showMessage('Please enter a 4-digit OTP');
      }
    }
  }

  void resendOtp() async {
    try {
      String response = await _authService.requestOtp(widget.corporateId);
      if (mounted) {
        _showMessage(response);
      }
      startTimer(); // Restart the timer after resending OTP
    } catch (error) {
      if (mounted) {
        _showMessage('Failed to resend OTP. Please try again.');
      }
    }
  }

  void _showMessage(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(message)));
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    // Adjust width based on screen size
    double inputFieldWidth = screenWidth < 350 ? screenWidth * 0.15 : 50;
    double fieldGap = screenWidth < 350 ? screenWidth * 0.03 : 10;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomRight,
            colors: [redColor, blueColor, whiteColor],
          ),
        ),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Enter OTP sent to your email',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: 100),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          4,
                          (index) => AnimatedBuilder(
                            animation: _glowAnimation,
                            builder: (context, child) {
                              return Container(
                                margin: EdgeInsets.only(right: fieldGap),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  boxShadow: [
                                    BoxShadow(
                                      color: _glowAnimation.value!,
                                      blurRadius: 15,
                                      spreadRadius: 5,
                                    ),
                                  ],
                                ),
                                child: SizedBox(
                                  width: inputFieldWidth,
                                  height: 55,
                                  child: TextFormField(
                                    controller: otpControllers[index],
                                    keyboardType: TextInputType.number,
                                    textAlign: TextAlign.center,
                                    maxLength: 1,
                                    decoration: InputDecoration(
                                      filled: true,
                                      fillColor: Colors.white,
                                      counterText: '',
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                    onChanged: (value) {
                                      if (value.isNotEmpty && index < 3) {
                                        FocusScope.of(context).nextFocus();
                                      } else if (value.isEmpty && index > 0) {
                                        FocusScope.of(context).previousFocus();
                                      }
                                    },
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 30),
                      Text(
                        _isResendAvailable
                            ? 'You can resend the OTP now'
                            : 'Resend OTP in $_secondsRemaining sec',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 30),
                      SizedBox(
                        width: 200,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: redColor,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            padding: const EdgeInsets.symmetric(
                                vertical: 18, horizontal: 20),
                            shadowColor: Colors.black26,
                            elevation: 5,
                          ),
                          onPressed: submitOtp,
                          child: Text(
                            'Submit OTP',
                            style: const TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                      const SizedBox(height: 30),
                      TextButton(
                        onPressed: _isResendAvailable ? resendOtp : null,
                        child: Text(
                          'Resend OTP',
                          style: TextStyle(
                            color:
                                _isResendAvailable ? Colors.white : Colors.red,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class AdminDashboard extends StatelessWidget {
  const AdminDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Admin Dashboard')),
      body: const Center(child: Text('Welcome to Admin Dashboard!')),
    );
  }
}

class UserListPage extends StatelessWidget {
  const UserListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('User List')),
      body: const Center(child: Text('Welcome to User List!')),
    );
  }
}
