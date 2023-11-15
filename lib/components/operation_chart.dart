import 'package:flutter/material.dart';
import 'package:rc_rtc_tolotanana/services/database.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class OperationChart extends StatefulWidget {
  const OperationChart({super.key});

  @override
  State<OperationChart> createState() => _OperationChartState();
}

class _OperationChartState extends State<OperationChart> {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: DatabaseClient().getPatientPerOperationType(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasData) {
            List<_OperationData> data = [];
            for (var operation in snapshot.data!) {
              data.add(_OperationData(
                  operation['name'].toString().split('.').last.toUpperCase(),
                  operation['COUNT(*)']));
            }
            return SfCircularChart(
                title: ChartTitle(text: 'Nombres d\'opérations par type'),
                legend: const Legend(isVisible: true),
                series: <CircularSeries>[
                  // Render pie chart
                  PieSeries<_OperationData, String>(
                    dataSource: data,
                    pointColorMapper: (_OperationData data, _) => data.color,
                    xValueMapper: (_OperationData data, _) => data.operation,
                    yValueMapper: (_OperationData data, _) => data.number,
                    dataLabelSettings: const DataLabelSettings(isVisible: true),
                    enableTooltip: true,
                    // explode: true,
                  ),
                ]);
          } else {
            return const Center(child: Text('No data'));
          }
        });
  }
}

class _OperationData {
  _OperationData(this.operation, this.number);

  final String operation;
  final int number;
  Color? color;
}
