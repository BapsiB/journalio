import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

void main() => runApp(MyApp());

class AppColors {
  static const Color primaryPeach = Color(0xFFF5E6D3);
  static const Color secondaryTeal = Color.fromARGB(255, 212, 213, 187);
  static const Color backgroundPeach = Color(0xFFF7EFE5);
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Daily Tracker',
      theme: ThemeData(
        primaryColor: AppColors.primaryPeach,
        scaffoldBackgroundColor: AppColors.backgroundPeach,
        colorScheme: ColorScheme.light(
          primary: AppColors.primaryPeach,
          secondary: AppColors.secondaryTeal,
        ),
        cardTheme: CardTheme(
          color: Colors.white,
          elevation: 2,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        sliderTheme: SliderThemeData(
          activeTrackColor: AppColors.secondaryTeal,
          inactiveTrackColor: AppColors.primaryPeach,
          thumbColor: AppColors.secondaryTeal,
          overlayColor: AppColors.secondaryTeal.withOpacity(0.3),
        ),
        switchTheme: SwitchThemeData(
          thumbColor: MaterialStateProperty.resolveWith((states) =>
              states.contains(MaterialState.selected)
                  ? AppColors.secondaryTeal
                  : Colors.white),
          trackColor: MaterialStateProperty.resolveWith((states) =>
              states.contains(MaterialState.selected)
                  ? AppColors.secondaryTeal.withOpacity(0.5)
                  : Colors.grey.shade300),
        ),
      ),
      home: DailyTrackerPage(),
    );
  }
}

class DailyTrackerPage extends StatefulWidget {
  @override
  _DailyTrackerPageState createState() => _DailyTrackerPageState();
}

class _DailyTrackerPageState extends State<DailyTrackerPage> {
  DateTime _selectedDate = DateTime.now();
  Map<String, dynamic> _answers = {};

  final List<Map<String, dynamic>> _questions = [
    {
      'question': 'Brumeux ?',
      'type': 'choice',
      'options': ['mild', 'moderate', 'severe']
    },
    {
      'question': 'How many hours of sleep?',
      'type': 'slider',
      'min': 0,
      'max': 12
    },
    {
      'question': 'Qualité des contacts sociaux',
      'type': 'choice',
      'options': ['Poor', 'Average', 'Good']
    },
    {'question': 'Did you take a sleeping pill?', 'type': 'boolean'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _buildDateNavigator(),
            Expanded(
              child: ListView(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                children: [
                  ..._questions.map((q) => _buildQuestionCard(q)),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(
              icon: Icon(Icons.analytics), label: 'Analytics'),
          BottomNavigationBarItem(icon: Icon(Icons.book), label: 'Journal'),
          BottomNavigationBarItem(
              icon: Icon(Icons.settings), label: 'Settings'),
        ],
        selectedItemColor: AppColors.secondaryTeal,
        unselectedItemColor: Colors.grey,
      ),
    );
  }

  Widget _buildDateNavigator() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      color: AppColors.primaryPeach,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: Icon(Icons.chevron_left, color: AppColors.secondaryTeal),
            onPressed: () => _changeDate(-1),
          ),
          Column(
            children: [
              Text(
                DateFormat('EEE MMM dd yyyy').format(_selectedDate),
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87),
              ),
              SizedBox(height: 4),
            ],
          ),
          Row(
            children: [
              IconButton(
                icon: Icon(Icons.edit, color: AppColors.secondaryTeal),
                onPressed: () {
                  // Add edit functionality here
                },
              ),
              IconButton(
                icon: Icon(Icons.chevron_right, color: AppColors.secondaryTeal),
                onPressed: () => _changeDate(1),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionCard(Map<String, dynamic> question) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(question['question'],
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87)),
            SizedBox(height: 12),
            _buildAnswerWidget(question),
            SizedBox(height: 12),
            _buildWeeklyChart(question),
          ],
        ),
      ),
    );
  }

  Widget _buildAnswerWidget(Map<String, dynamic> question) {
    switch (question['type']) {
      case 'slider':
        return Slider(
          value: _answers[question['question']] ?? question['min'].toDouble(),
          min: question['min'].toDouble(),
          max: question['max'].toDouble(),
          divisions: (question['max'] - question['min']).toInt(),
          label: _answers[question['question']]?.toStringAsFixed(1) ?? '',
          onChanged: (value) =>
              setState(() => _answers[question['question']] = value),
        );
      case 'choice':
        return Wrap(
          spacing: 8,
          children: question['options'].map<Widget>((option) {
            return ChoiceChip(
              label: Text(option),
              selected: _answers[question['question']] == option,
              selectedColor: AppColors.secondaryTeal.withOpacity(0.7),
              onSelected: (selected) {
                if (selected)
                  setState(() => _answers[question['question']] = option);
              },
            );
          }).toList(),
        );
      case 'boolean':
        return Switch(
          value: _answers[question['question']] ?? false,
          onChanged: (value) =>
              setState(() => _answers[question['question']] = value),
        );
      default:
        return SizedBox();
    }
  }

  Widget _buildWeeklyChart(Map<String, dynamic> question) {
    return Container(
      height: 40,
      child: Row(
        children: List.generate(7, (index) {
          return Expanded(
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 2),
              decoration: BoxDecoration(
                color: AppColors.secondaryTeal.withOpacity(0.1 + (0.1 * index)),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          );
        }),
      ),
    );
  }

  void _changeDate(int days) {
    setState(() {
      _selectedDate = _selectedDate.add(Duration(days: days));
    });
  }
}
