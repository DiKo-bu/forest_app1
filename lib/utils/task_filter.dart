import '../models/forest_task.dart';

List<ForestTask> filterAndSortTasks(List<ForestTask> tasks, String currentFilter) {
  List<ForestTask> result = tasks;
  if (currentFilter != 'Все') {
    result = result.where((t) => t.type == currentFilter).toList();
  }
  result.sort((a, b) {
    if (a.isDone == b.isDone) return a.startDate.compareTo(b.startDate);
    return a.isDone ? 1 : -1;
  });
  return result;
}
