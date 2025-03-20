import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math' as math;

class Prediction extends StatefulWidget {
  const Prediction({super.key});

  @override
  State<Prediction> createState() => _PredictionState();
}

class _PredictionState extends State<Prediction> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    _controller.forward();
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Color primaryColor = const Color.fromARGB(255, 126, 62, 43);
    final Color backgroundColor = const Color(0xFF2A2A2A);
    final Color cardColor = const Color(0xFF383838);
    
    // Get arguments from route
    final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;
    final double predictedCharges = args?['predicted_charges'] ?? 0.0;
    final Map<String, dynamic> inputData = args?['inputData'] ?? {};
    
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: const Text('Your Insurance Estimate', style: TextStyle(color: Colors.white)),
        backgroundColor: primaryColor,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Main price card
                FadeTransition(
                  opacity: _controller,
                  child: Card(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    color: cardColor,
                    elevation: 4,
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        children: [
                          const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.price_check, color: Colors.white70),
                              SizedBox(width: 8),
                              Text(
                                'Estimated Annual Premium',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          TweenAnimationBuilder<double>(
                            duration: const Duration(seconds: 1),
                            curve: Curves.easeOutCubic,
                            tween: Tween<double>(
                              begin: 0,
                              end: predictedCharges,
                            ),
                            builder: (context, value, child) {
                              return Text(
                                '\$${value.toStringAsFixed(2)}',
                                style: TextStyle(
                                  color: primaryColor,
                                  fontSize: 36,
                                  fontWeight: FontWeight.bold,
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 16),
                          // Horizontal price gauge
                          Container(
                            height: 12,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(6),
                              color: Colors.grey.shade800,
                            ),
                            child: TweenAnimationBuilder<double>(
                              duration: const Duration(milliseconds: 1200),
                              curve: Curves.easeOutQuart,
                              tween: Tween<double>(
                                begin: 0,
                                end: math.min(1.0, predictedCharges / 50000),
                              ),
                              builder: (context, value, _) {
                                return FractionallySizedBox(
                                  alignment: Alignment.centerLeft,
                                  widthFactor: value,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(6),
                                      color: primaryColor,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('\$0', 
                                style: TextStyle(color: Colors.grey.shade400, fontSize: 12),
                              ),
                              Text('\$50,000', 
                                style: TextStyle(color: Colors.grey.shade400, fontSize: 12),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Your Information section
                Padding(
                  padding: const EdgeInsets.only(left: 8, bottom: 12),
                  child: Row(
                    children: [
                      Icon(Icons.person_outline, color: primaryColor, size: 20),
                      const SizedBox(width: 6),
                      const Text(
                        'Your Information',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                
                SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0, 0.2),
                    end: Offset.zero,
                  ).animate(CurvedAnimation(
                    parent: _controller,
                    curve: const Interval(0.2, 1.0, curve: Curves.easeOutCubic),
                  )),
                  child: Card(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    color: cardColor,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          _buildInfoRow(context, 'Age', '${inputData['age'] ?? "N/A"}', Icons.calendar_today),
                          _buildInfoRow(context, 'Sex', '${(inputData['sex'] ?? "").toString().capitalize()}', Icons.person),
                          _buildInfoRow(context, 'BMI', '${inputData['bmi']?.toStringAsFixed(1) ?? "N/A"}', Icons.monitor_weight),
                          _buildInfoRow(context, 'Dependents', '${inputData['children'] ?? "N/A"}', Icons.family_restroom),
                          _buildInfoRow(context, 'Smoker', '${(inputData['smoker'] ?? "").toString().capitalize()}', Icons.smoking_rooms),
                          _buildInfoRow(context, 'Region', '${(inputData['region'] ?? "").toString().capitalize()}', Icons.location_on, isLast: true),
                        ],
                      ),
                    ),
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Factors influencing cost
                SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0, 0.2),
                    end: Offset.zero,
                  ).animate(CurvedAnimation(
                    parent: _controller,
                    curve: const Interval(0.4, 1.0, curve: Curves.easeOutCubic),
                  )),
                  child: Card(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    color: primaryColor.withOpacity(0.1),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.info_outline, color: primaryColor),
                              const SizedBox(width: 8),
                              const Text(
                                'Key Factors',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          _buildFactorItem(
                            inputData['smoker'] == 'yes', 
                            'Smoking significantly increases premiums',
                            'Non-smokers typically pay lower premiums'
                          ),
                          _buildFactorItem(
                            (inputData['bmi'] ?? 0) > 30, 
                            'Higher BMI may increase insurance costs',
                            'Your BMI is in a favorable range'
                          ),
                          _buildFactorItem(
                            (inputData['age'] ?? 0) > 50, 
                            'Age is a factor in your premium calculation',
                            'Your age bracket has favorable rates'
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                
                const SizedBox(height: 32),
                
                // Buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          final text = 'Insurance Estimate: \$${predictedCharges.toStringAsFixed(2)}\n'
                              'Age: ${inputData['age']}\n'
                              'Sex: ${inputData['sex']}\n'
                              'BMI: ${inputData['bmi']}\n'
                              'Dependents: ${inputData['children']}\n'
                              'Smoker: ${inputData['smoker']}\n'
                              'Region: ${inputData['region']}';
                              
                          Clipboard.setData(ClipboardData(text: text));
                          
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: const Text('Results copied to clipboard'),
                              backgroundColor: cardColor,
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          );
                        },
                        icon: const Icon(Icons.copy, size: 20),
                        label: const Text('Copy Results'),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          side: BorderSide(color: primaryColor.withOpacity(0.5)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        icon: const Icon(Icons.refresh, size: 20),
                        label: const Text('New Estimate'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  
  Widget _buildInfoRow(BuildContext context, String label, String value, IconData icon, {bool isLast = false}) {
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 12),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.white54),
          const SizedBox(width: 12),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 15,
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w500,
              fontSize: 15,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildFactorItem(bool condition, String highText, String lowText) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(
            condition ? Icons.arrow_upward : Icons.arrow_downward,
            color: condition ? Colors.amber : Colors.green,
            size: 16,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              condition ? highText : lowText,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Extension for string capitalization
extension StringExtension on String {
  String capitalize() {
    if (isEmpty) return this;
    return "${this[0].toUpperCase()}${substring(1)}";
  }
}