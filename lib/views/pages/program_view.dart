// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';

import 'package:rc_rtc_tolotanana/models/edition.dart';
import 'package:rc_rtc_tolotanana/views/pages/program_day_view.dart';

class ProgramPage extends StatefulWidget {
  const ProgramPage({
    Key? key,
    required this.edition,
  }) : super(key: key);
  final Edition edition;

  @override
  State<ProgramPage> createState() => _ProgramPageState();
}

class _ProgramPageState extends State<ProgramPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 6, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: const Text('Programme de la mission'),
          bottom: TabBar(
            controller: _tabController,
            tabs: const <Widget>[
              Tab(text: 'Non'),
              Tab(text: 'Lun'),
              Tab(text: 'Mar'),
              Tab(text: 'Mer'),
              Tab(text: 'Jeu'),
              Tab(text: 'Ven'),
            ],
          )),
      body: TabBarView(
        controller: _tabController,
        children: const <Widget>[
          ProgramDayView(day: 0),
          ProgramDayView(day: 1),
          ProgramDayView(day: 2),
          ProgramDayView(day: 3),
          ProgramDayView(day: 4),
          ProgramDayView(day: 5),
        ],
      ),
    );
  }
}
