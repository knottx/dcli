#! /usr/bin/env dshell
import 'package:dshell/dshell.dart';
import 'package:args/args.dart';

void main(List<String> args) {

	var parser = ArgParser();
	parser.addFlag('runOnly', abbr: 'r', defaultsTo: false);

	var results = parser.parse(args);
	var runOnly = results['runOnly'];

	if (!runOnly)
	{	
		'sudo docker build -f ./Dockerfile.local -t dshell:install_test_local ..'.run;
	}

	'sudo docker run dshell:install_test_local'.run;


}
