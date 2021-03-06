// Copyright 2014 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:meta/meta.dart';

import '../base/common.dart';
import '../build_info.dart';
import '../build_system/targets/web.dart';
import '../features.dart';
import '../project.dart';
import '../runner/flutter_command.dart'
    show DevelopmentArtifact, FlutterCommandResult;
import '../web/compile.dart';
import 'build.dart';

class BuildWebCommand extends BuildSubCommand {
  BuildWebCommand({
    @required bool verboseHelp,
  }) {
    addTreeShakeIconsFlag(enabledByDefault: false);
    usesTargetOption();
    usesPubOption();
    addBuildModeFlags(excludeDebug: true);
    usesDartDefineOption();
    usesWebRendererOption();
    addEnableExperimentation(hide: !verboseHelp);
    addNullSafetyModeOptions(hide: !verboseHelp);
    argParser.addFlag('csp',
      defaultsTo: false,
      negatable: false,
      help: 'Disable dynamic generation of code in the generated output. '
        'This is necessary to satisfy CSP restrictions (see http://www.w3.org/TR/CSP/).'
    );
    argParser.addFlag(
      'source-maps',
      defaultsTo: false,
      help: 'Whether to generate a sourcemap file. These can be used by browsers '
      'To view and debug the original source code of a compiled and minified Dart '
      'application. Defaults to false (i.e. no sourcemaps produced).'
    );
    argParser.addOption('pwa-strategy',
      defaultsTo: kOfflineFirst,
      help:
        'The caching strategy to be used by the PWA service worker.\n'
        'offline-first will attempt to cache the app shell eagerly and '
        'then lazily cache all subsequent assets as they are loaded. When '
        'making a network request for an asset, the offline cache will be '
        'preferred.\n'
        'none will generate a service worker with no body. This is useful for '
        'local testing or in cases where the service worker caching functionality '
        'is not desirable',
      allowed: <String>[
        kOfflineFirst,
        kNoneWorker,
      ]
    );
  }

  @override
  Future<Set<DevelopmentArtifact>> get requiredArtifacts async =>
      const <DevelopmentArtifact>{
        DevelopmentArtifact.web,
      };

  @override
  final String name = 'web';

  @override
  bool get hidden => !featureFlags.isWebEnabled;

  @override
  final String description = 'Build a web application bundle.';

  @override
  Future<FlutterCommandResult> runCommand() async {
    if (!featureFlags.isWebEnabled) {
      throwToolExit('"build web" is not currently supported.');
    }
    final FlutterProject flutterProject = FlutterProject.current();
    final String target = stringArg('target');
    final BuildInfo buildInfo = await getBuildInfo();
    if (buildInfo.isDebug) {
      throwToolExit('debug builds cannot be built directly for the web. Try using "flutter run"');
    }
    await buildWeb(
      flutterProject,
      target,
      buildInfo,
      boolArg('csp'),
      stringArg('pwa-strategy'),
      boolArg('source-maps'),
    );
    return FlutterCommandResult.success();
  }
}
