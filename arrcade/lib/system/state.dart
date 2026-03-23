import 'package:flutter/material.dart';

import 'package:provider/provider.dart';
import 'package:arrcade/modules/dashboard/core/state.dart';
import 'package:arrcade/modules/lidarr/core/state.dart';
import 'package:arrcade/modules/radarr/core/state.dart';
import 'package:arrcade/modules/search/core/state.dart';
import 'package:arrcade/modules/settings/core/state.dart';
import 'package:arrcade/modules/sonarr/core/state.dart';
import 'package:arrcade/modules/sabnzbd/core/state.dart';
import 'package:arrcade/modules/nzbget/core/state.dart';
import 'package:arrcade/modules/tautulli/core/state.dart';
import 'package:arrcade/modules.dart';
import 'package:arrcade/router/router.dart';

class LunaState {
  LunaState._();

  static BuildContext get context => LunaRouter.navigator.currentContext!;

  /// Calls `.reset()` on all states which extend [LunaModuleState].
  static void reset([BuildContext? context]) {
    final ctx = context ?? LunaState.context;
    LunaModule.values.forEach((module) => module.state(ctx)?.reset());
  }

  static MultiProvider providers({required Widget child}) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => DashboardState()),
        ChangeNotifierProvider(create: (_) => SettingsState()),
        ChangeNotifierProvider(create: (_) => SearchState()),
        ChangeNotifierProvider(create: (_) => LidarrState()),
        ChangeNotifierProvider(create: (_) => RadarrState()),
        ChangeNotifierProvider(create: (_) => SonarrState()),
        ChangeNotifierProvider(create: (_) => NZBGetState()),
        ChangeNotifierProvider(create: (_) => SABnzbdState()),
        ChangeNotifierProvider(create: (_) => TautulliState()),
      ],
      child: child,
    );
  }
}

abstract class LunaModuleState extends ChangeNotifier {
  /// Reset the state back to the default
  void reset();
}
