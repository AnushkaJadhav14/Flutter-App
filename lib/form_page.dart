import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

class FormPage extends StatefulWidget {
  final String corporateId;
  const FormPage({Key? key, required this.corporateId}) : super(key: key);

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
  bool _fileUploaded = false;

  List<PlatformFile> _selectedFiles = [];
  final double maxFileSizeMB = 2.0;

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

  final String backendUrl = "http://localhost:5000";

  Future<void> _fetchEmployeeDetails(String corporateId) async {
    try {
      final response = await http.post(
        Uri.parse("$backendUrl/getUserDetails"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"corporateId": corporateId}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _employeeNameController.text = data['employeeName'] ?? "";
          _employeeFunctionController.text = data['employeeFunction'] ?? "";

          // Use the correct key from your response. For example, 'location'
          String fetchedLocation = data['location'] ?? "";

          // Only add the fetched location if it is non-empty and not already in the list
          if (fetchedLocation.isNotEmpty &&
              !locations.contains(fetchedLocation)) {
            locations.add(fetchedLocation);
          }
          _selectedLocation =
              fetchedLocation.isNotEmpty ? fetchedLocation : null;
        });
      } else {
        setState(() {
          _employeeNameController.clear();
          _employeeFunctionController.clear();
          _selectedLocation = null;
        });
      }
    } catch (error) {
      setState(() {
        _employeeNameController.clear();
        _employeeFunctionController.clear();
        _selectedLocation = null;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error fetching employee details: $error")),
      );
    }
  }

  Future<void> _pickFiles() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'png', 'pdf'],
      withData: kIsWeb,
      allowMultiple: true,
    );

    if (result != null) {
      List<PlatformFile> validFiles = [];
      for (var file in result.files) {
        double fileSizeMB = file.size / (1024 * 1024);
        if (fileSizeMB <= maxFileSizeMB) {
          validFiles.add(file);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("⚠️ ${file.name} exceeds the 2MB limit."),
              backgroundColor: Colors.orange,
            ),
          );
        }
      }

      setState(() {
        _selectedFiles.addAll(validFiles);
        _fileUploaded = _selectedFiles.isNotEmpty;
      });
    }
  }

  void _removeFile(int index) {
    setState(() {
      _selectedFiles.removeAt(index);
      _fileUploaded = _selectedFiles.isNotEmpty;
    });
  }

  void _previewFile(PlatformFile file) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(file.name),
        content: file.bytes != null
            ? Image.memory(Uint8List.fromList(file.bytes!))
            : Text("Preview not available for this file type."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Close"),
          ),
        ],
      ),
    );
  }

  Future<void> _submitForm() async {
    List<String> missingFields = [];

    if (_employeeNameController.text.isEmpty)
      missingFields.add("Employee Name");
    if (_employeeIdController.text.isEmpty) missingFields.add("Employee ID");
    if (_employeeFunctionController.text.isEmpty)
      missingFields.add("Employee Function");
    if (_selectedLocation == null) missingFields.add("Location");
    if (_selectedIdeaTheme == null) missingFields.add("Idea Theme");
    if (_selectedDepartment == null) missingFields.add("Department");
    if (_selectedBenefitsCategory == null)
      missingFields.add("Benefits Category");
    if (_ideaDescriptionController.text.isEmpty)
      missingFields.add("Idea Description");
    if (_impactedProcessController.text.isEmpty)
      missingFields.add("Impacted Process");
    if (_expectedBenefitsValueController.text.isEmpty)
      missingFields.add("Expected Benefits Value");

    if (missingFields.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "⚠️ Please fill in the following required fields:\n${missingFields.join(", ")}",
          ),
          backgroundColor: Colors.orange,
          duration: const Duration(seconds: 3),
        ),
      );
      return;
    }

    try {
      var request =
          http.MultipartRequest("POST", Uri.parse("$backendUrl/submit-form"));
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

      for (var file in _selectedFiles) {
        String corporateId = _employeeIdController.text;
        String originalFileName = file.name;
        String newFileName = "$corporateId/$originalFileName";

        if (kIsWeb) {
          request.files.add(http.MultipartFile.fromBytes(
            "attachment",
            file.bytes!,
            filename: newFileName,
          ));
        } else {
          request.files.add(await http.MultipartFile.fromPath(
            "attachment",
            file.path!,
            filename: newFileName,
          ));
        }
      }

      var response = await request.send();
      var responseBody = await response.stream.bytesToString();
      var decodedResponse = jsonDecode(responseBody);

      if (response.statusCode == 201) {
        // _employeeNameController.clear();
        // _employeeIdController.clear();
        // _employeeFunctionController.clear();
        _ideaDescriptionController.clear();
        _impactedProcessController.clear();
        _expectedBenefitsValueController.clear();

        setState(() {
          // _selectedLocation = null;
          _selectedIdeaTheme = null;
          _selectedDepartment = null;
          _selectedBenefitsCategory = null;
          _selectedFiles.clear();
          _fileUploaded = false;
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
  void initState() {
    super.initState();
    // Auto-fetch the employee details once the form loads:
    _employeeIdController.text = widget.corporateId;
    _fetchEmployeeDetails(widget.corporateId);
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
        child: LayoutBuilder(
          builder: (context, constraints) {
            double width = constraints.maxWidth;
            double formWidth = 600.0;
            if (width < 600)
              formWidth = width * 0.9;
            else if (width < 1200)
              formWidth = width * 0.8;
            else
              formWidth = 900.0;

            return SingleChildScrollView(
              child: Center(
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 500),
                  width: formWidth,
                  child: Column(
                    children: [
                      _buildRoundedTextField(
                        _employeeIdController,
                        'Corporate ID',
                        onChanged: (value) {
                          if (value.isNotEmpty) _fetchEmployeeDetails(value);
                        },
                      ),
                      _buildRoundedTextField(
                          _employeeNameController, 'Employee Name',
                          enabled: false),
                      _buildRoundedTextField(
                          _employeeFunctionController, 'Employee Function',
                          enabled: false),
                      _buildDropdownField(
                        'Location',
                        locations,
                        _selectedLocation,
                        (val) => setState(() => _selectedLocation = val),
                      ),
                      _buildRequiredDropdownField(
                          'Idea Theme',
                          ideaThemes,
                          _selectedIdeaTheme,
                          (val) => setState(() => _selectedIdeaTheme = val)),
                      _buildRequiredDropdownField(
                          'Department',
                          departments,
                          _selectedDepartment,
                          (val) => setState(() => _selectedDepartment = val)),
                      _buildRequiredDropdownField(
                          'Benefits Category',
                          benefitsCategories,
                          _selectedBenefitsCategory,
                          (val) =>
                              setState(() => _selectedBenefitsCategory = val)),
                      _buildMultilineTextField(_ideaDescriptionController,
                          'Idea Description', 3, 500),
                      _buildMultilineTextField(_impactedProcessController,
                          'Impacted Process', 2, 50),
                      _buildMultilineTextField(_expectedBenefitsValueController,
                          'Expected Benefits Value', 1, 40),
                      SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          const Text(
                            "Attach File :",
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(width: 10),
                          ElevatedButton.icon(
                            onPressed: _pickFiles,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: blueColor,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20)),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 12),
                            ),
                            icon: const Icon(Icons.upload_file,
                                color: Colors.white),
                            label: const Text("Upload Files",
                                style: TextStyle(
                                    color: Colors.white, fontSize: 16)),
                          ),
                          const SizedBox(width: 10),
                          if (_fileUploaded)
                            const Text('File Uploaded',
                                style: TextStyle(color: Colors.green)),
                        ],
                      ),
                      SizedBox(height: 10),
                      if (_selectedFiles.isNotEmpty)
                        Column(
                          children: _selectedFiles.asMap().entries.map((entry) {
                            int index = entry.key;
                            PlatformFile file = entry.value;
                            return ListTile(
                              title: Text(file.name),
                              subtitle: Text(
                                  "${(file.size / 1024).toStringAsFixed(2)} KB"),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                      icon: Icon(Icons.preview),
                                      onPressed: () => _previewFile(file)),
                                  IconButton(
                                      icon:
                                          Icon(Icons.delete, color: Colors.red),
                                      onPressed: () => _removeFile(index)),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: _submitForm,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: redColor,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20)),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 40, vertical: 12),
                        ),
                        child: const Text("Submit",
                            style:
                                TextStyle(color: Colors.white, fontSize: 18)),
                      )
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

Widget _buildRequiredField(TextEditingController controller, String label) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 20),
    child: Stack(
      children: [
        TextField(
          controller: controller,
          decoration: InputDecoration(
            labelText: label,
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
          ),
        ),
        Positioned(
          top: 6,
          right: 10,
          child: Text(
            '*',
            style: TextStyle(fontSize: 20, color: Colors.red),
          ),
        ),
      ],
    ),
  );
}

Widget _buildRequiredDropdownField(String label, List<String> items,
    String? selectedValue, ValueChanged<String?> onChanged) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 20),
    child: Stack(
      children: [
        DropdownButtonFormField<String>(
          value: selectedValue,
          onChanged: onChanged,
          items: items
              .map((item) => DropdownMenuItem<String>(
                    value: item,
                    child: Text(item),
                  ))
              .toList(),
          decoration: InputDecoration(
            labelText: label,
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
          ),
        ),
        Positioned(
          top: 6,
          right: 10,
          child: Text(
            '*',
            style: TextStyle(fontSize: 20, color: Colors.red),
          ),
        ),
      ],
    ),
  );
}

Widget _buildRoundedTextField(
  TextEditingController controller,
  String label, {
  Function(String)? onChanged,
  bool enabled = true, // Add this parameter with a default value
}) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 20),
    child: TextField(
      controller: controller,
      onChanged: onChanged,
      enabled: enabled, // Use the enabled parameter
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: Colors.white, // Ensuring white background
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
      ),
    ),
  );
}

Widget _buildMultilineTextField(TextEditingController controller, String label,
    int maxLines, int maxLength) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 20),
    child: TextField(
      controller: controller,
      maxLines: maxLines,
      maxLength: maxLength,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
        suffixIcon: const Padding(
          padding: EdgeInsets.only(right: 8.0),
          child: Text(
            "*",
            style: TextStyle(
              color: Colors.red,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
        ),
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
          .map(
              (String item) => DropdownMenuItem(value: item, child: Text(item)))
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
