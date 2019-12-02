import 'package:dshell/functions/is.dart';
import 'package:dshell/pubspec/global_dependancies.dart';
import 'package:dshell/pubspec/pubspec.dart';
import 'package:dshell/pubspec/pubspec_annotation.dart';
import 'package:dshell/pubspec/pubspec_default.dart';
import 'package:dshell/pubspec/pubspec_file.dart';
import 'package:dshell/pubspec/pubspec_virtual.dart';
import 'package:dshell/script/dependency.dart';
import 'package:dshell/script/project.dart';
import 'package:dshell/script/script.dart';

class PubSpecManager {
  VirtualProject project;

  // The pubspec in the scripts annotation.
  PubSpec annotationSpec;

  // the pubspec in the virtual project
  PubSpec virtualSpec;

  // the pubsec from the scripts root directory
  // (if it exists)
  PubSpec packageSpec;

  PubSpecManager(this.project);

  /// Extract the pubspec annotation form the [_script]
  ///

  /// If necessary, extract the pubspec annotation from a script file
  /// and saves it to [path] as a pubspec.yaml file.
  ///
  void createVirtualPubSpec() {
    Script script = project.script;
    PubSpec sourcePubSpec;

    PubSpec defaultPubspec = PubSpecDefault(script);
    PubSpecAnnotation annotation = PubSpecAnnotation.fromScript(script);

    if (!annotation.exists()) {
      if (script.hasPubSpecYaml()) {
        sourcePubSpec = PubSpecFile.fromScript(script);
      } else {
        sourcePubSpec = defaultPubspec;
      }
    } else {
      sourcePubSpec = annotation;
    }

    PubSpec pubSpec = PubSpecVirtual.fromPubSpec(sourcePubSpec);

    List<Dependency> resolved = resolveDependancies(pubSpec, defaultPubspec);

    pubSpec.replaceDependancies(resolved);

    pubSpec.writeToFile(project.pubSpecPath);
  }

  bool wasModified(String pubSpecPath, DateTime scriptModified) {
    bool wasModified = true;

    // If the script hasn't changed since we last
    // updated the pubspec then we don't need to run pub get.
    DateTime pubSpecModified = lastModified(pubSpecPath);
    if (scriptModified == pubSpecModified) {
      // no changes so signal that we don't need to run pub get.
      wasModified = false;
    }
    return wasModified;
  }

  ///
  /// If the virtual pubspec.yaml exists
  /// we don't flag a clean.
  ///
  /// Currently its up to the user to tell us when
  /// to do a clean.
  bool isCleanRequired() {
    return !exists(project.pubSpecPath);
  }

  //   bool isCleanRequired() {
  //   bool cleanRequried = false;

  //   DateTime scriptLastModifed = lastModified(project.script.path);
  //   DateTime virtualPubSpecLastModified = lastModified(project.pubspec.path);

  //   if (scriptLastModifed != virtualLastModified) {
  //     /// last modified is not the same so now check the contents

  //     if (annotationSpec != virtualSpec) {
  //       _loadAnnotationYaml(project);
  //       _loadVirtualYaml(project);
  //       cleanRequried = true;
  //     }
  //   }
  //   return cleanRequried;
  // }

  /// Loads dependancies from
  /// virtual pubspec
  /// global dependancies
  /// default dependencies
  ///
  /// and returns a resolve list.
  ///
  /// To resolve a list we deduplicate any entries
  /// by name.
  /// If there are duplicates the 'preferred' entrie
  /// is selected.
  ///
  List<Dependency> resolveDependancies(
      PubSpec selected, PubSpec defaultPubSpec) {
    List<Dependency> resolved = List();

    // Start form least important to most imporant
    List<Dependency> defaultDependancies = defaultPubSpec.dependencies;
    List<Dependency> globalDependencies = _getGlobalDependancies();

    // take the preferred ones from global and default
    resolved = resolve(globalDependencies, defaultDependancies);

    List<Dependency> pubspecDependancies = selected.dependencies;

    // If the default pubspec is also the selected one then
    // we MUST NOT re-resolve otherwise the defaults will take
    // precendence over the global dependencies which is against the rules.
    if (selected != defaultPubSpec) {
      // take the preferred ones from pubspec and the above
      resolved = resolve(pubspecDependancies, resolved);
    }

    return resolved;
  }

  List<Dependency> _getGlobalDependancies() {
    GlobalDependancies gd = GlobalDependancies();
    return gd.dependancies;
  }

  List<Dependency> resolve(List<Dependency> preferred, List<Dependency> base) {
    List<Dependency> resolved = List();
    for (Dependency basic in base) {
      // if there is a matching preferred item then use that.
      Dependency add = preferred.firstWhere(
          (preference) => preference.name == basic.name,
          orElse: () => basic);

      resolved.add(add);
    }

    // add any preferred items that simply arn't in the base
    for (Dependency preference in preferred) {
      // check inf the preference is already in the list.
      Dependency found = resolved.firstWhere(
          (element) => element.name == preference.name,
          orElse: () => null);
      if (found == null) resolved.add(preference);
    }
    return resolved;
  }
}
