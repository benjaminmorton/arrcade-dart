import 'package:flutter/material.dart';

import 'package:arrcade/system/quick_actions/quick_actions.dart';

class LunaOS {
  Future<void> boot(BuildContext context) async {
    if (LunaQuickActions.isSupported) LunaQuickActions().initialize();
  }
}
