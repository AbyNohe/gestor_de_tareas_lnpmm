import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:fl_chart/fl_chart.dart';
import '../providers/task_provider.dart';
import 'package:intl/intl.dart';

class StatsScreen extends StatefulWidget {
  const StatsScreen({super.key});

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  Widget build(BuildContext context) {
    final turquesa = Theme.of(context).colorScheme.primary;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestor de Tareas'),
        backgroundColor: turquesa,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Calendario y Progreso',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: turquesa,
                ),
              ),
            ),
            _buildCalendar(),
            if (_selectedDay != null) _buildSelectedDayTasks(),
            const SizedBox(height: 20),
            _buildProgressChart(),
          ],
        ),
      ),
    );
  }

  Widget _buildCalendar() {
    final turquesa = Theme.of(context).colorScheme.primary;
    final taskProvider = Provider.of<TaskProvider>(context);
    final tasks = taskProvider.tasks;
    
    return TableCalendar(
      firstDay: DateTime.utc(2024, 1, 1),
      lastDay: DateTime.utc(2025, 12, 31),
      focusedDay: _focusedDay,
      calendarFormat: _calendarFormat,
      locale: 'es_ES',
      daysOfWeekHeight: 40,
      headerStyle: HeaderStyle(
        formatButtonVisible: true,
        titleCentered: true,
        titleTextFormatter: (date, locale) {
          String month = DateFormat.MMMM(locale).format(date);
          return '${month[0].toUpperCase()}${month.substring(1)} de ${date.year}';
        },
      ),
      headerVisible: true,
      selectedDayPredicate: (day) {
        return isSameDay(_selectedDay, day);
      },
      onDaySelected: (selectedDay, focusedDay) {
        setState(() {
          _selectedDay = selectedDay;
          _focusedDay = focusedDay;
        });
      },
      onFormatChanged: (format) {
        setState(() {
          _calendarFormat = format;
        });
      },
      calendarStyle: CalendarStyle(
        selectedDecoration: BoxDecoration(
          color: turquesa,
          shape: BoxShape.circle,
        ),
        todayDecoration: BoxDecoration(
          color: turquesa.withOpacity(0.5),
          shape: BoxShape.circle,
        ),
        markerDecoration: BoxDecoration(
          color: turquesa,
          shape: BoxShape.circle,
        ),
        defaultTextStyle: const TextStyle(color: Colors.black),
        weekendTextStyle: const TextStyle(color: Colors.black),
        selectedTextStyle: const TextStyle(color: Colors.white),
        todayTextStyle: const TextStyle(color: Colors.white),
      ),
      daysOfWeekStyle: DaysOfWeekStyle(
        weekdayStyle: TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.black,
          fontSize: 14,
        ),
        weekendStyle: TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.black,
          fontSize: 14,
        ),
        dowTextFormatter: (date, locale) => 
          DateFormat.E(locale).format(date)[0].toUpperCase() + 
          DateFormat.E(locale).format(date).substring(1),
      ),
      availableCalendarFormats: const {
        CalendarFormat.month: 'Mes',
        CalendarFormat.twoWeeks: '2 Semanas',
        CalendarFormat.week: 'Semana',
      },
      eventLoader: (day) {
        return tasks.where((task) => 
          task.dueDate.year == day.year &&
          task.dueDate.month == day.month &&
          task.dueDate.day == day.day &&
          !task.isCompleted
        ).toList();
      },
    );
  }

  Widget _buildSelectedDayTasks() {
    final taskProvider = Provider.of<TaskProvider>(context);
    final tasksForDay = taskProvider.getTasksForDay(_selectedDay!);
    final pendingTasks = tasksForDay.where((task) => !task.isCompleted).toList();

    if (pendingTasks.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(16.0),
        child: Text('No hay tareas pendientes para este día'),
      );
    }

    return Container(
      margin: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 51),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Tareas para ${_selectedDay!.day}/${_selectedDay!.month}/${_selectedDay!.year}',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: pendingTasks.length,
            itemBuilder: (context, index) {
              final task = pendingTasks[index];
              return ListTile(
                title: Text(
                  task.title,
                  style: TextStyle(
                    color: task.isOverdue ? Colors.red : null,
                  ),
                ),
                subtitle: Text(task.description),
                trailing: Checkbox(
                  value: task.isCompleted,
                  onChanged: (bool? value) {
                    taskProvider.toggleTaskCompletion(task);
                  },
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildProgressChart() {
    final taskProvider = Provider.of<TaskProvider>(context);
    final completedTasks = taskProvider.completedTasks.length;
    final pendingTasks = taskProvider.pendingTasks.length;
    final overdueTasks = taskProvider.overdueTasks.length;
    final total = completedTasks + pendingTasks + overdueTasks;
    final turquesa = Theme.of(context).colorScheme.primary;

    if (total == 0) {
      return const Padding(
        padding: EdgeInsets.all(16.0),
        child: Text('No hay tareas registradas'),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Text(
            'Progreso de Tareas',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: turquesa,
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 200,
            child: PieChart(
              PieChartData(
                sections: [
                  PieChartSectionData(
                    color: turquesa,
                    value: completedTasks.toDouble(),
                    title: '${(completedTasks / total * 100).toStringAsFixed(1)}%',
                    radius: 60,
                    titleStyle: const TextStyle(color: Colors.white, fontSize: 12),
                  ),
                  PieChartSectionData(
                    color: Colors.orange[300]!,
                    value: pendingTasks.toDouble(),
                    title: '${(pendingTasks / total * 100).toStringAsFixed(1)}%',
                    radius: 60,
                    titleStyle: const TextStyle(color: Colors.white, fontSize: 12),
                  ),
                  PieChartSectionData(
                    color: Colors.red[300]!,
                    value: overdueTasks.toDouble(),
                    title: '${(overdueTasks / total * 100).toStringAsFixed(1)}%',
                    radius: 60,
                    titleStyle: const TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildLegendItem('Completadas', turquesa),
              _buildLegendItem('Pendientes', Colors.orange[300]!),
              _buildLegendItem('Atrasadas', Colors.red[300]!),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 4),
        Text(label),
      ],
    );
  }
} 