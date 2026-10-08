import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const RegistrationApp());
}

class RegistrationApp extends StatelessWidget {
  const RegistrationApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Registration',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1565C0),
        ),
        scaffoldBackgroundColor: const Color(0xFFF4F7FB),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(
              color: Color(0xFFE0E6EF),
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(
              color: Color(0xFF1565C0),
              width: 2,
            ),
          ),
        ),
      ),
      home: const RegistrationPage(),
    );
  }
}

class RegistrationPage extends StatefulWidget {
  const RegistrationPage({super.key});

  @override
  State<RegistrationPage> createState() => _RegistrationPageState();
}

class _RegistrationPageState extends State<RegistrationPage> {
  int currentStep = 0;

  final nameController = TextEditingController();
  final sectionController = TextEditingController();
  final courseController = TextEditingController();

  final subject1Controller = TextEditingController();
  final subject1TimeController = TextEditingController();

  final subject2Controller = TextEditingController();
  final subject2TimeController = TextEditingController();

  bool isSaving = false;

  @override
  void dispose() {
    nameController.dispose();
    sectionController.dispose();
    courseController.dispose();
    subject1Controller.dispose();
    subject1TimeController.dispose();
    subject2Controller.dispose();
    subject2TimeController.dispose();
    super.dispose();
  }

  void nextStep() {
    if (currentStep == 0) {
      if (nameController.text.trim().isEmpty ||
          sectionController.text.trim().isEmpty ||
          courseController.text.trim().isEmpty) {
        showMessage('Please complete all registration fields.');
        return;
      }
    }

    if (currentStep == 1) {
      if (subject1Controller.text.trim().isEmpty ||
          subject1TimeController.text.trim().isEmpty ||
          subject2Controller.text.trim().isEmpty ||
          subject2TimeController.text.trim().isEmpty) {
        showMessage('Please complete all subject fields.');
        return;
      }
    }

    setState(() {
      currentStep++;
    });
  }

  void previousStep() {
    if (currentStep > 0) {
      setState(() {
        currentStep--;
      });
    }
  }

  Future<void> saveData() async {
    setState(() {
      isSaving = true;
    });

    try {
      await FirebaseFirestore.instance.collection('registrations').add({
        'name': nameController.text.trim(),
        'section': sectionController.text.trim(),
        'course': courseController.text.trim(),
        'subjects': [
          {
            'subject': subject1Controller.text.trim(),
            'time': subject1TimeController.text.trim(),
          },
          {
            'subject': subject2Controller.text.trim(),
            'time': subject2TimeController.text.trim(),
          },
        ],
        'createdAt': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: const Row(
              children: [
                Icon(
                  Icons.check_circle,
                  color: Colors.green,
                  size: 32,
                ),
                SizedBox(width: 10),
                Text('Registration Saved'),
              ],
            ),
            content: const Text(
              'Your registration has been successfully saved to Firebase Firestore.',
            ),
            actions: [
              FilledButton(
                onPressed: () {
                  Navigator.pop(context);
                  resetForm();
                },
                child: const Text('Done'),
              ),
            ],
          );
        },
      );
    } catch (e) {
      showMessage('Failed to save data: $e');
    } finally {
      if (mounted) {
        setState(() {
          isSaving = false;
        });
      }
    }
  }

  void resetForm() {
    nameController.clear();
    sectionController.clear();
    courseController.clear();
    subject1Controller.clear();
    subject1TimeController.clear();
    subject2Controller.clear();
    subject2TimeController.clear();

    setState(() {
      currentStep = 0;
    });
  }

  void showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        backgroundColor: const Color(0xFF1565C0),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF1565C0),
        foregroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
        title: const Text(
          'Registration',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 21,
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            buildProgress(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: buildCurrentStep(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildProgress() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 18,
      ),
      child: Row(
        children: [
          progressItem(
            number: 1,
            title: 'Registration',
            active: currentStep >= 0,
          ),
          progressLine(currentStep >= 1),
          progressItem(
            number: 2,
            title: 'Subjects',
            active: currentStep >= 1,
          ),
          progressLine(currentStep >= 2),
          progressItem(
            number: 3,
            title: 'Verify',
            active: currentStep >= 2,
          ),
        ],
      ),
    );
  }

  Widget progressItem({
    required int number,
    required String title,
    required bool active,
  }) {
    return Expanded(
      child: Column(
        children: [
          CircleAvatar(
            radius: 17,
            backgroundColor: active
                ? const Color(0xFF1565C0)
                : const Color(0xFFE0E6EF),
            child: Text(
              '$number',
              style: TextStyle(
                color: active ? Colors.white : Colors.grey,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            title,
            style: TextStyle(
              fontSize: 11,
              fontWeight: active
                  ? FontWeight.bold
                  : FontWeight.normal,
              color: active
                  ? const Color(0xFF1565C0)
                  : Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget progressLine(bool active) {
    return Container(
      height: 2,
      width: 25,
      margin: const EdgeInsets.only(bottom: 22),
      color: active
          ? const Color(0xFF1565C0)
          : const Color(0xFFE0E6EF),
    );
  }

  Widget buildCurrentStep() {
    switch (currentStep) {
      case 0:
        return buildRegistration();

      case 1:
        return buildSubjects();

      case 2:
        return buildVerification();

      default:
        return const SizedBox();
    }
  }

  Widget buildRegistration() {
    return Column(
      key: const ValueKey('registration'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        buildHeader(
          icon: Icons.person_add_alt_1,
          title: 'User Registration',
          subtitle:
              'Enter your personal and academic information.',
        ),
        const SizedBox(height: 25),

        buildLabel('Name'),
        buildTextField(
          controller: nameController,
          hint: 'Enter your name',
          icon: Icons.person_outline,
        ),

        const SizedBox(height: 18),

        buildLabel('Section'),
        buildTextField(
          controller: sectionController,
          hint: 'Example: 301',
          icon: Icons.groups_outlined,
        ),

        const SizedBox(height: 18),

        buildLabel('course'),
        buildTextField(
          controller: courseController,
          hint: 'Example: BST',
          icon: Icons.school_outlined,
        ),

        const SizedBox(height: 35),

        buildNextButton(),
      ],
    );
  }

  Widget buildSubjects() {
    return Column(
      key: const ValueKey('subjects'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        buildHeader(
          icon: Icons.menu_book_outlined,
          title: 'Subject Enrollment',
          subtitle:
              'Enter the subjects and their scheduled time.',
        ),

        const SizedBox(height: 25),

        buildSubjectCard(
          number: '1',
          subjectController: subject1Controller,
          timeController: subject1TimeController,
        ),

        const SizedBox(height: 18),

        buildSubjectCard(
          number: '2',
          subjectController: subject2Controller,
          timeController: subject2TimeController,
        ),

        const SizedBox(height: 30),

        buildNavigationButtons(),
      ],
    );
  }

  Widget buildVerification() {
    return Column(
      key: const ValueKey('verification'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        buildHeader(
          icon: Icons.verified_outlined,
          title: 'Subject Verification',
          subtitle:
              'Review your details before saving.',
        ),

        const SizedBox(height: 25),

        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 12,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Details',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Color(0xFF172B4D),
                ),
              ),

              const SizedBox(height: 15),

              verificationRow(
                'Name',
                nameController.text,
                Icons.person_outline,
              ),

              verificationRow(
                'Section',
                sectionController.text,
                Icons.groups_outlined,
              ),

              verificationRow(
                'Course',
                courseController.text,
                Icons.school_outlined,
              ),

              const Divider(height: 25),

              verificationRow(
                '1',
                subject1Controller.text,
                Icons.book_outlined,
              ),

              verificationRow(
                'time',
                subject1TimeController.text,
                Icons.access_time_outlined,
              ),

              const Divider(height: 25),

              verificationRow(
                '2',
                subject2Controller.text,
                Icons.book_outlined,
              ),

              verificationRow(
                'time',
                subject2TimeController.text,
                Icons.access_time_outlined,
              ),
            ],
          ),
        ),

        const SizedBox(height: 30),

        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: isSaving ? null : previousStep,
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    vertical: 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: const Text('Back'),
              ),
            ),

            const SizedBox(width: 12),

            Expanded(
              flex: 2,
              child: FilledButton.icon(
                onPressed: isSaving ? null : saveData,
                icon: isSaving
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(
                        Icons.cloud_upload_outlined,
                      ),
                label: Text(
                  isSaving ? 'Saving...' : 'Save',
                ),
                style: FilledButton.styleFrom(
                  backgroundColor:
                      const Color(0xFF1565C0),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    vertical: 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget buildHeader({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(13),
          decoration: BoxDecoration(
            color: const Color(0xFFE3F2FD),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(
            icon,
            color: const Color(0xFF1565C0),
            size: 28,
          ),
        ),

        const SizedBox(height: 15),

        Text(
          title,
          style: const TextStyle(
            fontSize: 25,
            fontWeight: FontWeight.bold,
            color: Color(0xFF172B4D),
          ),
        ),

        const SizedBox(height: 5),

        Text(
          subtitle,
          style: const TextStyle(
            color: Colors.grey,
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  Widget buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          color: Color(0xFF172B4D),
        ),
      ),
    );
  }

  Widget buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
  }) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(
          icon,
          color: const Color(0xFF1565C0),
        ),
      ),
    );
  }

  Widget buildSubjectCard({
    required String number,
    required TextEditingController subjectController,
    required TextEditingController timeController,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: const Color(0xFFE0E6EF),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFE3F2FD),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Subject $number',
                  style: const TextStyle(
                    color: Color(0xFF1565C0),
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 15),

          buildLabel('Subject'),

          buildTextField(
            controller: subjectController,
            hint: 'Example: BMC',
            icon: Icons.book_outlined,
          ),

          const SizedBox(height: 14),

          buildLabel('time'),

          buildTextField(
            controller: timeController,
            hint: 'Example: 7:30 - 10:30',
            icon: Icons.access_time_outlined,
          ),
        ],
      ),
    );
  }

  Widget verificationRow(
    String label,
    String value,
    IconData icon,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            color: const Color(0xFF1565C0),
            size: 21,
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 12,
                  ),
                ),

                const SizedBox(height: 3),

                Text(
                  value.isEmpty ? '-' : value,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildNextButton() {
    return SizedBox(
      width: double.infinity,
      child: FilledButton.icon(
        onPressed: nextStep,
        icon: const Icon(Icons.arrow_forward),
        label: const Text('Next'),
        style: FilledButton.styleFrom(
          backgroundColor: const Color(0xFF1565C0),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(
            vertical: 17,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
    );
  }

  Widget buildNavigationButtons() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: previousStep,
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(
                vertical: 16,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            child: const Text('Back'),
          ),
        ),

        const SizedBox(width: 12),

        Expanded(
          flex: 2,
          child: FilledButton.icon(
            onPressed: nextStep,
            icon: const Icon(Icons.arrow_forward),
            label: const Text('Next'),
            style: FilledButton.styleFrom(
              backgroundColor:
                  const Color(0xFF1565C0),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(
                vertical: 16,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
        ),
      ],
    );
  }
}