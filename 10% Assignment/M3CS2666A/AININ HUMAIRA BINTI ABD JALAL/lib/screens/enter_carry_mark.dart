import 'package:flutter/material.dart';
import '../services/firestore_service.dart';
import 'login_screen.dart';

class EnterCarryMark extends StatefulWidget {
  const EnterCarryMark({super.key});

  @override
  _EnterCarryMarkState createState() => _EnterCarryMarkState();
}

class _EnterCarryMarkState extends State<EnterCarryMark> {
  final _fs = FirestoreService();
  bool _loading = true;
  List<Map<String, dynamic>> students = [];

  final Map<String, TextEditingController> _testControllers = {};
  final Map<String, TextEditingController> _assignmentControllers = {};
  final Map<String, TextEditingController> _projectControllers = {};

  @override
  void initState() {
    super.initState();
    _loadStudents();
  }

  Future<void> _loadStudents() async {
    students = await _fs.getAllStudentsWithMarks();
    for (var student in students) {
      _testControllers[student['uid']] =
          TextEditingController(text: student['marks']?['test']?.toString() ?? '0');
      _assignmentControllers[student['uid']] =
          TextEditingController(text: student['marks']?['assignment']?.toString() ?? '0');
      _projectControllers[student['uid']] =
          TextEditingController(text: student['marks']?['project']?.toString() ?? '0');
    }
    setState(() => _loading = false);
  }

  @override
  void dispose() {
    for (var c in _testControllers.values) c.dispose();
    for (var c in _assignmentControllers.values) c.dispose();
    for (var c in _projectControllers.values) c.dispose();
    super.dispose();
  }

  double calcPercentage(double raw, double percent) => (raw / 100) * percent;
  double calcTotal(double test, double assign, double project) => test + assign + project;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            color: const Color(0xFF37474F),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: const Size(0, 0),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: const Text(
                    "Back",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                    ),
                  ),
                ),

                const Text(
                  "Enter Student Carry Marks",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 22,
                    color: Color(0xFFBFE8D7),
                  ),
                ),

                TextButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => const LoginScreen()),
                    );
                  },
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: const Size(0, 0),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: const Text(
                    "Logout",
                    style: TextStyle(
                      color: Color(0xFFFF0000),
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF37474F), Color(0xFFBFE8D7)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width * 0.95),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Container(
                        color: Colors.white,
                        child: DataTable(
                          headingRowColor: MaterialStateProperty.all(
                              const Color(0xFF37474F)),
                          headingTextStyle: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFBFE8D7),
                          ),
                          columns: const [
                            DataColumn(label: Text("No.")),
                            DataColumn(label: Text("Student ID")),
                            DataColumn(label: Text("Name")),
                            DataColumn(label: Text("Test (20%)")),
                            DataColumn(label: Text("Assignment (10%)")),
                            DataColumn(label: Text("Project (20%)")),
                            DataColumn(label: Text("Total (/50)")),
                            DataColumn(label: Text("Action")),
                          ],
                          rows: List.generate(students.length, (index) {
                            final student = students[index];
                            final uid = student['uid'];

                            double rawTest =
                                double.tryParse(_testControllers[uid]!.text) ?? 0;
                            double rawAssign =
                                double.tryParse(_assignmentControllers[uid]!.text) ?? 0;
                            double rawProject =
                                double.tryParse(_projectControllers[uid]!.text) ?? 0;

                            double testPercent =
                            calcPercentage(rawTest, 20);
                            double assignPercent =
                            calcPercentage(rawAssign, 10);
                            double projectPercent =
                            calcPercentage(rawProject, 20);
                            double total = calcTotal(
                                testPercent, assignPercent, projectPercent);

                            return DataRow(cells: [
                              DataCell(Text((index + 1).toString())),
                              DataCell(Text(student['studentId'] ?? '')),
                              DataCell(Text(
                                student['name'] != null
                                    ? student['name']
                                    .toString()
                                    .toUpperCase()
                                    : '',
                              )),
                              DataCell(_cellField(_testControllers[uid]!)),
                              DataCell(
                                  _cellField(_assignmentControllers[uid]!)),
                              DataCell(_cellField(_projectControllers[uid]!)),
                              DataCell(Text(total.toStringAsFixed(1))),
                              DataCell(TextButton(
                                onPressed: () async {
                                  double t = double.tryParse(
                                      _testControllers[uid]!.text) ??
                                      0;
                                  double a = double.tryParse(
                                      _assignmentControllers[uid]!.text) ??
                                      0;
                                  double p = double.tryParse(
                                      _projectControllers[uid]!.text) ??
                                      0;

                                  await _fs.saveCarryMark(uid, t, a, p);
                                  setState(() {});

                                  ScaffoldMessenger.of(context)
                                      .showSnackBar(
                                    SnackBar(
                                      content: Text(
                                          "Saved for ${student['studentId']}"),
                                    ),
                                  );
                                },
                                child: const Text(
                                  "Save",
                                  style: TextStyle(color: Colors.green),
                                ),
                              )),
                            ]);
                          }),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _cellField(TextEditingController c) {
    return SizedBox(
      width: 100,
      child: TextField(
        controller: c,
        keyboardType: TextInputType.number,
        decoration: const InputDecoration(
          border: OutlineInputBorder(),
          contentPadding: EdgeInsets.symmetric(horizontal: 6, vertical: 8),
        ),
      ),
    );
  }
}
