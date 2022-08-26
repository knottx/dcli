// ignore_for_file: avoid_classes_with_only_static_members

import 'package:args/command_runner.dart';
import 'package:dcli/dcli.dart';

import 'mailhog_exception.dart';

void showUsage<T>(CommandRunner<T> runner) {
  print(blue('Usage:'));
  print(runner.usage);
}

void showException<T>(CommandRunner<T> runner, Object e) {
  if (e is UsageException) {
    final lines = e.toString().split('\n');
    final error = lines.first;
    printerr(red('Error: $error'));
    final usage = lines.skip(1).join('\n');
    printerr(usage);
  } else if (e is MailHogException) {
    printerr(red('Error: ${e.message}'));

    if (e.showUsage) {
      showUsage(runner);
    }
  } else {
    // ignore: avoid_catches_without_on_clauses
    printerr(red('Error: ${e.toString()}'));
    showUsage(runner);
  }
}
