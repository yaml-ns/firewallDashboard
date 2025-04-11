import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:async';
import 'dart:math';

void main() {
  runApp(FirewallDashboardApp());
}

class FirewallDashboardApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Firewall Dashboard',
      theme: ThemeData.dark().copyWith(
        colorScheme: ColorScheme.dark(primary: Colors.tealAccent),
        cardTheme: CardTheme(color: Colors.grey[900]),
      ),
      home: DashboardPage(),
    );
  }
}

class DashboardPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Firewall Dashboard ')),
      body: LayoutBuilder(
        builder: (context, constraints) {
          bool isMobile = constraints.maxWidth < 600;
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: GridView.count(
              crossAxisCount: isMobile ? 1 : 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              children: [
                StatCard(title: 'Connexions Bloquées', value: '432', icon: Icons.shield),
                StatCard(title: 'Alertes Réseau', value: '28', icon: Icons.warning),
                StatCard(title: 'Paquets Anormaux', value: '1221', icon: Icons.security),
                StatCard(title: 'Ports Scannés', value: '87', icon: Icons.portable_wifi_off),
                TrafficChartCard(),
                LogsCard(),
              ],
            ),
          );
        },
      ),
    );
  }
}

class StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;

  StatCard({required this.title, required this.value, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Icon(icon, size: 40, color: Theme.of(context).colorScheme.primary),
            SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(value, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                Text(title, style: TextStyle(color: Colors.grey))
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// class TrafficChartCard extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Card(
//       elevation: 4,
//       child: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text('Trafic Réseau (Mock)', style: TextStyle(fontSize: 16)),
//             SizedBox(height: 16),
//             Expanded(
//               child: LineChart(
//                 LineChartData(
//                   lineBarsData: [
//                     LineChartBarData(
//                       spots: [
//                         FlSpot(0, 3),
//                         FlSpot(1, 2),
//                         FlSpot(2, 5),
//                         FlSpot(3, 3.1),
//                         FlSpot(4, 4),
//                         FlSpot(5, 3),
//                       ],
//                       isCurved: true,
//                       color: Colors.tealAccent,
//                       barWidth: 2,
//                     ),
//                     LineChartBarData(
//                       spots: [
//                         FlSpot(0, 2),
//                         FlSpot(1, 2.5),
//                         FlSpot(2, 3),
//                         FlSpot(3, 3.5),
//                         FlSpot(4, 2.2),
//                         FlSpot(5, 1.8),
//                       ],
//                       isCurved: true,
//                       color: Colors.tealAccent,
//                       barWidth: 2,
//                     )
//                   ],
//                   titlesData: FlTitlesData(
//                     bottomTitles: AxisTitles(
//                       sideTitles: SideTitles(showTitles: true),
//                     ),
//                     leftTitles: AxisTitles(
//                       sideTitles: SideTitles(showTitles: true),
//                     ),
//                   ),
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

class TrafficChartCard extends StatefulWidget {
  @override
  _TrafficChartCardState createState() => _TrafficChartCardState();
}

class _TrafficChartCardState extends State<TrafficChartCard> {
  final List<FlSpot> _data = [];
  Timer? _timer;
  int _time = 0;
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _initData();
    _time = _data.length;
    _timer = Timer.periodic(Duration(seconds: 1), (_) => _updateData());
  }

  void _initData() {
    for (int i = 0; i < 20; i++) {
      _data.add(FlSpot(i.toDouble(), _random.nextDouble() * 5));
    }
  }

  void _updateData() {
    setState(() {
      _data.removeAt(0);
      _time++;
      _data.add(FlSpot(_time.toDouble(), _random.nextDouble() * 5));
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Trafic Réseau (Temps réel)', style: TextStyle(fontSize: 16)),
            SizedBox(height: 16),
            Expanded(
              child: LineChart(
                LineChartData(
                  lineBarsData: [
                    LineChartBarData(
                      spots: _data,
                      isCurved: true,
                      preventCurveOverShooting: true,
                      color: Colors.tealAccent,
                      barWidth: 2,
                      dotData: FlDotData(show: false),
                    ),
                  ],
                  titlesData: FlTitlesData(
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: true),
                    ),
                  ),
                  gridData: FlGridData(show: true),
                  borderData: FlBorderData(show: false),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
class LogsCard extends StatelessWidget {
  final List<String> mockLogs = [
    'Blocage IP: 192.168.1.45',
    'Tentative d\'intrusion détectée',
    'Connexion refusée - Port 22',
    'Scan réseau suspect détecté',
    'Port 443 ouvert en externe',
    'Comportement suspect : flood ICMP',
    'Connexion sortante non-autorisée',
  ];

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Logs (Mock)', style: TextStyle(fontSize: 16)),
            SizedBox(height: 8),
            Expanded(
              child: ListView.builder(
                itemCount: mockLogs.length,
                itemBuilder: (context, index) => ListTile(
                  dense: true,
                  leading: Icon(Icons.article_outlined, size: 18),
                  title: Text(mockLogs[index]),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}



