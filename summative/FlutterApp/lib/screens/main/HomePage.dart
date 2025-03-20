import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  // Form controllers
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _heightController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _childrenController = TextEditingController();
  double _calculatedBmi = 0.0;

  // Form values
  String _sex = 'male';
  String _smoker = 'no';
  String _region = 'southeast';

  // Colors
  final Color _primaryColor = const Color.fromARGB(255, 126, 62, 43);
  final Color _backgroundColor = const Color(0xFF2A2A2A); // Slightly lighter
  final Color _cardColor = const Color(0xFF383838); // Slightly lighter cards

  // Calculate BMI
  void _calculateBmi() {
    if (_heightController.text.isNotEmpty && _weightController.text.isNotEmpty) {
      try {
        double heightInM = double.parse(_heightController.text) / 100; // Convert cm to m
        double weightInKg = double.parse(_weightController.text);
        setState(() {
          _calculatedBmi = weightInKg / (heightInM * heightInM);
        });
      } catch (e) {
        setState(() {
          _calculatedBmi = 0.0;
        });
      }
    }
  }

  // Input decoration
  InputDecoration _inputDecoration(String label, IconData icon, {String? helperText}) {
    return InputDecoration(
      labelText: label,
      helperText: helperText,
      helperStyle: const TextStyle(color: Colors.white54, fontSize: 12),
      labelStyle: const TextStyle(color: Colors.white70),
      prefixIcon: Icon(icon, color: Colors.white70),
      fillColor: _cardColor,
      filled: true,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: _primaryColor, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.redAccent, width: 1),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.redAccent, width: 2),
      ),
    );
  }

  // Section header
  Widget _sectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 24, 0, 16),
      child: Text(
        title,
        style: TextStyle(
          color: _primaryColor,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  // Submit prediction to API
  Future<void> _submitPrediction() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      final Map<String, dynamic> data = {
        'age': int.parse(_ageController.text),
        'sex': _sex,
        'bmi': _calculatedBmi > 0 ? _calculatedBmi : double.parse(_weightController.text) / (double.parse(_heightController.text) / 100 * double.parse(_heightController.text) / 100),
        'children': int.parse(_childrenController.text),
        'smoker': _smoker,
        'region': _region,
      };

      try {
        final response = await http.post(
          Uri.parse('https://linear-regression-model-oy9v.onrender.com/predict'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(data),
        );

        if (response.statusCode == 200) {
          final result = jsonDecode(response.body);

          // Navigate to the prediction screen with the result
          if (mounted) {
            Navigator.pushNamed(
              context,
              '/prediction',
              arguments: {
                'predicted_charges': result['predicted_charges'],
                'inputData': data,
              },
            );
          }
        } else {
          _showErrorDialog(
            'Something went wrong',
            'We couldn\'t process your request. Please try again in a moment.',
          );
        }
      } catch (e) {
        _showErrorDialog(
          'Connection issue',
          'Please check your internet connection and try again.',
        );
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  // Show error dialog
  void _showErrorDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: _cardColor,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(title, style: const TextStyle(color: Colors.white)),
          content: Text(message, style: const TextStyle(color: Colors.white70)),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('OK', style: TextStyle(color: _primaryColor)),
            ),
          ],
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    // Set up listeners to auto-calculate BMI
    _heightController.addListener(_calculateBmi);
    _weightController.addListener(_calculateBmi);
  }

  @override
  void dispose() {
    _ageController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    _childrenController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor,
      appBar: AppBar(
        title: const Text('Insurance Estimator', style: TextStyle(color: Colors.white)),
        backgroundColor: _primaryColor,
        elevation: 0,
      ),
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Introduction text
                      Card(
                        color: _primaryColor.withOpacity(0.1),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(color: _primaryColor, width: 1),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Row(
                            children: [
                              Icon(Icons.info_outline, color: _primaryColor),
                              const SizedBox(width: 12),
                              const Expanded(
                                child: Text(
                                  'Enter your information below to get a personalized insurance cost estimate.',
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      
                      // Personal details section
                      _sectionHeader('Personal Details'),
                      
                      TextFormField(
                        style: const TextStyle(color: Colors.white),
                        controller: _ageController,
                        keyboardType: TextInputType.number,
                        decoration: _inputDecoration('Age', Icons.calendar_today),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your age';
                          }
                          if (int.tryParse(value) == null || int.parse(value) <= 0) {
                            return 'Please enter a valid age';
                          }
                          return null;
                        },
                      ),
                      
                      const SizedBox(height: 16),
                      
                      DropdownButtonFormField<String>(
                        value: _sex,
                        decoration: _inputDecoration('Sex', Icons.person),
                        dropdownColor: _cardColor,
                        items: ['male', 'female'].map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(
                              value.substring(0, 1).toUpperCase() + value.substring(1),
                              style: const TextStyle(color: Colors.white),
                            ),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          setState(() {
                            _sex = newValue!;
                          });
                        },
                        style: const TextStyle(color: Colors.white),
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // BMI calculation section
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              style: const TextStyle(color: Colors.white),
                              controller: _heightController,
                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                              decoration: _inputDecoration('Height (cm)', Icons.height, 
                                  helperText: 'e.g., 175'),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Required';
                                }
                                if (double.tryParse(value) == null || double.parse(value) <= 0) {
                                  return 'Invalid';
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextFormField(
                              style: const TextStyle(color: Colors.white),
                              controller: _weightController,
                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                              decoration: _inputDecoration('Weight (kg)', Icons.fitness_center,
                                  helperText: 'e.g., 70'),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Required';
                                }
                                if (double.tryParse(value) == null || double.parse(value) <= 0) {
                                  return 'Invalid';
                                }
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),
                      
                      if (_calculatedBmi > 0)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Text(
                                'Your BMI: ${_calculatedBmi.toStringAsFixed(1)}',
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            ],
                          ),
                        ),
                      
                      // Insurance details section
                      _sectionHeader('Insurance Factors'),
                      
                      TextFormField(
                        style: const TextStyle(color: Colors.white),
                        controller: _childrenController,
                        keyboardType: TextInputType.number,
                        decoration: _inputDecoration('Dependents', Icons.family_restroom,
                            helperText: 'Number of children or dependents'),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter number of dependents';
                          }
                          if (int.tryParse(value) == null || int.parse(value) < 0) {
                            return 'Please enter a valid number';
                          }
                          return null;
                        },
                      ),
                      
                      const SizedBox(height: 16),
                      
                      DropdownButtonFormField<String>(
                        value: _smoker,
                        decoration: _inputDecoration('Smoker', Icons.smoking_rooms,
                            helperText: 'Do you smoke regularly?'),
                        dropdownColor: _cardColor,
                        items: ['yes', 'no'].map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(
                              value.substring(0, 1).toUpperCase() + value.substring(1),
                              style: const TextStyle(color: Colors.white),
                            ),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          setState(() {
                            _smoker = newValue!;
                          });
                        },
                        style: const TextStyle(color: Colors.white),
                      ),
                      
                      const SizedBox(height: 16),
                      
                      DropdownButtonFormField<String>(
                        value: _region,
                        decoration: _inputDecoration('Region', Icons.location_on,
                            helperText: 'Your geographic location'),
                        dropdownColor: _cardColor,
                        items: ['southwest', 'southeast', 'northwest', 'northeast'].map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(
                              value.substring(0, 1).toUpperCase() + value.substring(1),
                              style: const TextStyle(color: Colors.white),
                            ),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          setState(() {
                            _region = newValue!;
                          });
                        },
                        style: const TextStyle(color: Colors.white),
                      ),
                      
                      const SizedBox(height: 40),
                      
                      // Submit button
                      SizedBox(
                        width: double.infinity,
                        height: 54,
                        child: ElevatedButton(
                          onPressed: _submitPrediction,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _primaryColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 2,
                          ),
                          child: const Text(
                            'Get Insurance Estimate',
                            style: TextStyle(
                              fontSize: 18, 
                              fontWeight: FontWeight.bold,
                              color: Colors.white
                            ),
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ),
            
            // Loading overlay
            if (_isLoading)
              Container(
                color: Colors.black54,
                child: Center(
                  child: Card(
                    color: _cardColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(_primaryColor),
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'Calculating estimate...',
                            style: TextStyle(color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}