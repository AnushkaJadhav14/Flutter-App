import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';

class FormPage extends StatefulWidget {
  const FormPage({super.key});

  @override
  _FormPageState createState() => _FormPageState();
}

class _FormPageState extends State<FormPage> {
  final TextEditingController _employeeNameController = TextEditingController();
  final TextEditingController _employeeIdController = TextEditingController();
  final TextEditingController _employeeFunctionController =
      TextEditingController();
  final TextEditingController _ideaDescriptionController =
      TextEditingController();
  final TextEditingController _impactedProcessController =
      TextEditingController();
  final TextEditingController _expectedBenefitsValueController =
      TextEditingController();

  String? _selectedLocation;
  String? _selectedIdeaTheme;
  String? _selectedDepartment;
  String? _selectedBenefitsCategory;
  File? _selectedFile;

  final List<String> locations = ["A", "B", "C", "D"];
  final List<String> ideaThemes = [
    "Productivity Improvement",
    "Cost Reduction",
    "Delivery (TAT) Improvement",
    "Customer Satisfaction",
    "Compliance/ Quality Improvements",
    "Go Green"
  ];
  final List<String> departments = ["HR", "Finance", "IT", "Operations"];
  final List<String> benefitsCategories = [
    "Cost Saving",
    "Time Saving",
    "Error Reduction",
    "Compliance",
    "Go Green"
  ];

  final Color redColor = const Color.fromRGBO(237, 50, 55, 1);
  final Color blueColor = const Color.fromRGBO(55, 75, 146, 1);
  final Color whiteColor = Colors.white;

  final String backendUrl = "http://localhost:5000/submit-form";

  Future<void> _pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'png', 'pdf'],
    );

    if (result != null && result.files.single.path != null) {
      setState(() {
        _selectedFile = File(result.files.single.path!);
      });
    }
  }

  Future<void> _submitForm() async {
    if (_employeeNameController.text.isEmpty ||
        _employeeIdController.text.isEmpty ||
        _employeeFunctionController.text.isEmpty ||
        _selectedLocation == null ||
        _selectedIdeaTheme == null ||
        _selectedDepartment == null ||
        _selectedBenefitsCategory == null ||
        _ideaDescriptionController.text.isEmpty ||
        _impactedProcessController.text.isEmpty ||
        _expectedBenefitsValueController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content:
              Text("⚠️ Please fill in all required fields before submitting."),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    try {
      var request = http.MultipartRequest("POST", Uri.parse(backendUrl));

      request.fields["employeeName"] = _employeeNameController.text;
      request.fields["employeeId"] = _employeeIdController.text;
      request.fields["employeeFunction"] = _employeeFunctionController.text;
      request.fields["location"] = _selectedLocation!;
      request.fields["ideaTheme"] = _selectedIdeaTheme!;
      request.fields["department"] = _selectedDepartment!;
      request.fields["benefitsCategory"] = _selectedBenefitsCategory!;
      request.fields["ideaDescription"] = _ideaDescriptionController.text;
      request.fields["impactedProcess"] = _impactedProcessController.text;
      request.fields["expectedBenefitsValue"] =
          _expectedBenefitsValueController.text;

      if (_selectedFile != null) {
        request.files.add(await http.MultipartFile.fromPath(
            "attachment", _selectedFile!.path));
      }

      var response = await request.send();
      var responseBody = await response.stream.bytesToString();
      var decodedResponse = jsonDecode(responseBody);

      if (response.statusCode == 201) {
        // Reset form only if submission is successful
        _employeeNameController.clear();
        _employeeIdController.clear();
        _employeeFunctionController.clear();
        _ideaDescriptionController.clear();
        _impactedProcessController.clear();
        _expectedBenefitsValueController.clear();

        setState(() {
          _selectedLocation = null;
          _selectedIdeaTheme = null;
          _selectedDepartment = null;
          _selectedBenefitsCategory = null;
          _selectedFile = null;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("✅ Form Submitted Successfully!"),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("❌ Error: ${decodedResponse['message']}"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("❌ Error submitting form: $error"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Employee Idea Submission'),
        titleTextStyle: const TextStyle(fontSize: 23, color: Colors.white),
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
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            children: [
              _buildRoundedTextField(_employeeNameController, 'Employee Name'),
              _buildRoundedTextField(_employeeIdController, 'Employee ID'),
              _buildRoundedTextField(
                  _employeeFunctionController, 'Employee Function'),
              _buildDropdownField('Location', locations, _selectedLocation,
                  (val) => setState(() => _selectedLocation = val)),
              _buildDropdownField('Idea Theme', ideaThemes, _selectedIdeaTheme,
                  (val) => setState(() => _selectedIdeaTheme = val)),
              _buildDropdownField(
                  'Department',
                  departments,
                  _selectedDepartment,
                  (val) => setState(() => _selectedDepartment = val)),
              _buildDropdownField(
                  'Benefits Category',
                  benefitsCategories,
                  _selectedBenefitsCategory,
                  (val) => setState(() => _selectedBenefitsCategory = val)),
              _buildMultilineTextField(
                  _ideaDescriptionController, 'Idea Description', 3, 500),
              _buildMultilineTextField(
                  _impactedProcessController, 'Impacted Process', 2, 50),
              _buildMultilineTextField(_expectedBenefitsValueController,
                  'Expected Benefits Value', 1, 40),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  const Text(
                    "Attach File :",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(width: 10), // Space between text and button
                  ElevatedButton.icon(
                    onPressed: _pickFile,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: blueColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 12),
                    ),
                    icon: const Icon(Icons.upload_file, color: Colors.white),
                    label: const Text(
                      "Upload File",
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              if (_selectedFile != null)
                Text(_selectedFile!.path.split('/').last,
                    style: const TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submitForm,
                style: ElevatedButton.styleFrom(
                  backgroundColor: redColor,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20)),
                ),
                child: const Text("Submit",
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRoundedTextField(
      TextEditingController controller, String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: Colors.white, // Ensuring white background
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
        ),
      ),
    );
  }

  Widget _buildMultilineTextField(TextEditingController controller,
      String label, int maxLines, int maxLength) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        maxLength: maxLength,
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: Colors.white, // Ensuring white background
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
        ),
      ),
    );
  }

  Widget _buildDropdownField(String label, List<String> items, String? value,
      Function(String?) onChanged) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: DropdownButtonFormField<String>(
        value: value,
        items: items
            .map((String item) =>
                DropdownMenuItem(value: item, child: Text(item)))
            .toList(),
        onChanged: onChanged,
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: Colors.white, // Ensuring white background
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
        ),
      ),
    );
  }
}
