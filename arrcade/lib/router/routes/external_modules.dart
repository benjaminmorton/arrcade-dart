import 'package:flutter/material.dart';
import 'package:arrcade/modules.dart';
import 'package:arrcade/modules/external_modules/routes/external_modules/route.dart';
import 'package:arrcade/router/routes.dart';
import 'package:arrcade/vendor.dart';

enum ExternalModulesRoutes with LunaRoutesMixin {
  HOME('/external_modules');

  @override
  final String path;

  const ExternalModulesRoutes(this.path);

  @override
  LunaModule get module => LunaModule.EXTERNAL_MODULES;

  @override
  bool isModuleEnabled(BuildContext context) => true;

  @override
  GoRoute get routes {
    switch (this) {
      case ExternalModulesRoutes.HOME:
        return route(widget: const ExternalModulesRoute());
    }
  }
}
