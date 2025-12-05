import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';
import 'login_screen.dart';

class StudentDashboard extends StatefulWidget {
  const StudentDashboard({super.key});

  @override
  _StudentDashboardState createState() => _StudentDashboardState();
}

class _StudentDashboardState extends State<StudentDashboard> {
  final _fs = FirestoreService();
  bool _loading = true;
  Map<String, dynamic>? marks;
  String? selectedGrade;
  String studentName = "Student";

  @override
  void initState() {
    super.initState();
    _checkUser();
  }

  Future<void> _checkUser() async {
    final auth = Provider.of<AuthService>(context, listen: false);
    final user = await auth.userStream.first;
    if (user == null || user.role != 'student') {
      if (mounted) {
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (_) => const LoginScreen()));
      }
    } else {
      marks = await _fs.getCarryMark(user.uid);
      studentName = user.name ?? "Student";
      if (mounted) setState(() => _loading = false);
    }
  }

  double calculateCarryScore() {
    if (marks == null) return 0;
    final t = (marks?['test'] ?? 0.0) * 0.2;
    final a = (marks?['assignment'] ?? 0.0) * 0.1;
    final p = (marks?['project'] ?? 0.0) * 0.2;
    return t + a + p;
  }

  Map<String, Map<String, double>> calculateFinalExamTargets(double carryScore) {
    final targets = <String, Map<String, double>>{};
    final gradeThresholds = {
      'A+': 90.0,
      'A': 80.0,
      'A-': 75.0,
      'B+': 70.0,
      'B': 65.0,
      'B-': 60.0,
      'C+': 55.0,
      'C': 50.0,
    };

    gradeThresholds.forEach((grade, threshold) {
      double remaining = threshold - carryScore;
      if (remaining < 0) remaining = 0;
      double requiredExam100 = remaining / 0.5;
      if (requiredExam100 > 100) requiredExam100 = 100;
      double requiredExam50 = requiredExam100 * 0.5;
      targets[grade] = {
        'exam100': requiredExam100,
        'exam50': requiredExam50,
      };
    });

    return targets;
  }

  String getMaxAchievableGrade(double carryScore) {
    final gradeThresholds = {
      'A+': 90.0,
      'A': 80.0,
      'A-': 75.0,
      'B+': 70.0,
      'B': 65.0,
      'B-': 60.0,
      'C+': 55.0,
      'C': 50.0,
    };
    for (var entry in gradeThresholds.entries.toList().reversed) {
      double maxTotal = carryScore + 50.0;
      if (maxTotal >= entry.value) return entry.key;
    }
    return 'F';
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthService>(context, listen: false);
    final carryScore = calculateCarryScore();
    final targets = calculateFinalExamTargets(carryScore);
    final maxGrade = getMaxAchievableGrade(carryScore);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF37474F), Color(0xFFBFE8D7)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: _loading
              ? const Center(child: CircularProgressIndicator())
              : Padding(
            padding: const EdgeInsets.all(20),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF37474F),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Welcome, $studentName",
                          style: const TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFFBFE8D7)),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          "Your current carry mark: ${carryScore.toStringAsFixed(2)} / 50",
                          style: const TextStyle(
                              fontSize: 16, color: Color(0xFFBFE8D7)),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8.0),
                    child: Text(
                      "Marks",
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFBFE8D7)),
                    ),
                  ),
                  Card(
                    color: const Color(0xFFF5F5F5),
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Table(
                        border:
                        TableBorder.all(color: Colors.grey.shade400),
                        columnWidths: const {
                          0: FlexColumnWidth(2),
                          1: FlexColumnWidth(2),
                          2: FlexColumnWidth(2),
                        },
                        children: [
                          TableRow(
                              decoration: BoxDecoration(
                                  color: Colors.blueGrey.shade50),
                              children: const [
                                Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: Text("Test",
                                      textAlign: TextAlign.center),
                                ),
                                Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: Text("Assignment",
                                      textAlign: TextAlign.center),
                                ),
                                Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: Text("Project",
                                      textAlign: TextAlign.center),
                                ),
                              ]),
                          TableRow(children: [
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text("${marks?['test'] ?? 0}",
                                  textAlign: TextAlign.center),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text("${marks?['assignment'] ?? 0}",
                                  textAlign: TextAlign.center),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text("${marks?['project'] ?? 0}",
                                  textAlign: TextAlign.center),
                            ),
                          ]),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8.0),
                    child: Text(
                      "Carry Marks",
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFBFE8D7)),
                    ),
                  ),
                  Card(
                    color: const Color(0xFFF5F5F5),
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Table(
                        border:
                        TableBorder.all(color: Colors.grey.shade400),
                        columnWidths: const {
                          0: FlexColumnWidth(2),
                          1: FlexColumnWidth(2),
                          2: FlexColumnWidth(2),
                        },
                        children: [
                          TableRow(
                              decoration: BoxDecoration(
                                  color: Colors.blueGrey.shade50),
                              children: const [
                                Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: Text("Test (20%)",
                                      textAlign: TextAlign.center),
                                ),
                                Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: Text("Assignment (10%)",
                                      textAlign: TextAlign.center),
                                ),
                                Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: Text("Project (20%)",
                                      textAlign: TextAlign.center),
                                ),
                              ]),
                          TableRow(children: [
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                  "${((marks?['test'] ?? 0) * 0.2).toStringAsFixed(1)}",
                                  textAlign: TextAlign.center),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                  "${((marks?['assignment'] ?? 0) * 0.1).toStringAsFixed(1)}",
                                  textAlign: TextAlign.center),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                  "${((marks?['project'] ?? 0) * 0.2).toStringAsFixed(1)}",
                                  textAlign: TextAlign.center),
                            ),
                          ]),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 25),
                  Card(
                    color: const Color(0xFFF5F5F5),
                    elevation: 1,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const Text("Select Target Grade: ",
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold)),
                              const SizedBox(width: 12),
                              DropdownButton<String>(
                                value: selectedGrade,
                                hint: const Text("Choose Grade"),
                                icon: const SizedBox.shrink(),
                                items: targets.keys
                                    .map((g) => DropdownMenuItem(
                                  value: g,
                                  child: Text(g),
                                ))
                                    .toList(),
                                onChanged: (v) =>
                                    setState(() => selectedGrade = v),
                              ),
                            ],
                          ),
                          if (selectedGrade != null)
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  "Required Exam Score (/100): ${targets[selectedGrade]!['exam100']!.toStringAsFixed(1)}",
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFFFF6F61)),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  "Contribution to Total (/50%): ${targets[selectedGrade]!['exam50']!.toStringAsFixed(1)}",
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFFFF6F61)),
                                ),
                              ],
                            ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      appBar: AppBar(
        backgroundColor: const Color(0xFF37474F),
        title: const Text(
          "Student Dashboard",
          style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 22,
              color: Color(0xFFBFE8D7)),
        ),
        actions: [
          TextButton(
            onPressed: () {
              auth.signOut();
              Navigator.pushReplacement(
                  context, MaterialPageRoute(builder: (_) => const LoginScreen()));
            },
            child: const Text(
              "Logout",
              style: TextStyle(
                  color: Color(0xFFFF0000),
                  fontWeight: FontWeight.bold),
            ),
          )
        ],
      ),
    );
  }
}
