#! /usr/bin/env dcli

import 'dart:io';

// ignore: prefer_relative_imports
import 'package:dcli/dcli.dart';

/// dcli script generated by:
/// dcli create <scriptname>
///
/// See
/// https://pub.dev/packages/dcli#-installing-tab-
///
/// For details on installing dcli.
///

void main(List<String> args) {
  final parser = ArgParser()
    ..addFlag(
      'verbose',
      abbr: 'v',
      negatable: false,
      help: 'Logs additional details to the cli',
    )
    ..addOption('prompt', abbr: 'p', help: 'The prompt to show the user.');

  final parsed = parser.parse(args);

  if (parsed.wasParsed('verbose')) {
    Settings().setVerbose(enabled: true);
  }

  if (!parsed.wasParsed('prompt')) {
    print('');
    printerr(red('You must pass a prompt.'));
    showUsage(parser);
    exit(1);
  }

  final prompt = parsed['prompt'] as String;

  var valid = false;
  String response;
  do {
    response = ask('$prompt:', validator: Ask.all([Ask.alpha, Ask.required]));

    valid = confirm('Is this your response? ${green(response)}');
  } while (!valid);

  print(orange('Your response was: $response'));
}

/// Show the usage.
void showUsage(ArgParser parser) {
  print('''

Usage: ${DartScript.self.basename} -v --prompt=<a questions>
parser.usage''');
}