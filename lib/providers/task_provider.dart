import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/task.dart';
import '../services/notification_service.dart';

class TaskProvider with ChangeNotifier {
  late Box<Task> _taskBox;
  List<Task> _tasks = [];
  final NotificationService _notificationService = NotificationService();

  List<Task> get tasks => _tasks;
  
  List<Task> get completedTasks => _tasks.where((task) => task.isCompleted).toList();
  List<Task> get pendingTasks => _tasks.where((task) => !task.isCompleted && !task.isOverdue).toList();
  List<Task> get overdueTasks => _tasks.where((task) => task.isOverdue).toList();

  double get completionRate {
    if (_tasks.isEmpty) return 0;
    return completedTasks.length / _tasks.length;
  }

  Future<void> initHive() async {
    await _notificationService.init();
    _taskBox = await Hive.openBox<Task>('tasks');
    _loadTasks();
  }

  void _loadTasks() {
    _tasks = _taskBox.values.toList();
    notifyListeners();
  }

  Future<void> addTask(Task task) async {
    await _taskBox.put(task.id, task);
    if (task.reminderTime != null) {
      await _notificationService.scheduleTaskReminder(task, task.reminderTime!);
    }
    _loadTasks();
  }

  Future<void> updateTask(Task task) async {
    await _taskBox.put(task.id, task);
    await _notificationService.cancelTaskReminder(task);
    if (task.reminderTime != null) {
      await _notificationService.scheduleTaskReminder(task, task.reminderTime!);
    }
    _loadTasks();
  }

  Future<void> deleteTask(Task task) async {
    await _notificationService.cancelTaskReminder(task);
    await _taskBox.delete(task.id);
    _loadTasks();
  }

  Future<void> toggleTaskCompletion(Task task) async {
    task.isCompleted = !task.isCompleted;
    if (task.isCompleted) {
      await _notificationService.cancelTaskReminder(task);
    } else if (task.reminderTime != null && task.reminderTime!.isAfter(DateTime.now())) {
      await _notificationService.scheduleTaskReminder(task, task.reminderTime!);
    }
    await updateTask(task);
  }

  Future<void> setTaskReminder(Task task, DateTime reminderTime) async {
    task.reminderTime = reminderTime;
    await updateTask(task);
  }

  List<Task> getTasksForDay(DateTime date) {
    return _tasks.where((task) {
      return task.dueDate.year == date.year &&
             task.dueDate.month == date.month &&
             task.dueDate.day == date.day;
    }).toList();
  }
} 