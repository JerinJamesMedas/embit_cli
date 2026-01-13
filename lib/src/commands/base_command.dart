import 'package:args/args.dart';

abstract class BaseCommand {
  String get name;
  String get description;
  ArgParser get argParser;
  
  Future<void> execute(ArgResults results, {bool verbose = false});
}