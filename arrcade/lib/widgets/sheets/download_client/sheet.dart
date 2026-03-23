import 'package:flutter/material.dart';
import 'package:arrcade/database/models/profile.dart';
import 'package:arrcade/modules.dart';
import 'package:arrcade/modules/nzbget.dart';
import 'package:arrcade/modules/sabnzbd/routes.dart';
import 'package:arrcade/utils/dialogs.dart';
import 'package:arrcade/vendor.dart';
import 'package:arrcade/widgets/pages/invalid_route.dart';
import 'package:arrcade/widgets/ui.dart';

class DownloadClientSheet extends LunaBottomModalSheet {
  Future<LunaModule?> getDownloadClient() async {
    final profile = LunaProfile.current;
    final nzbget = profile.nzbgetEnabled;
    final sabnzbd = profile.sabnzbdEnabled;

    if (nzbget && sabnzbd) {
      return LunaDialogs().selectDownloadClient();
    }
    if (nzbget) {
      return LunaModule.NZBGET;
    }
    if (sabnzbd) {
      return LunaModule.SABNZBD;
    }

    return null;
  }

  @override
  Future<dynamic> show({
    Widget Function(BuildContext context)? builder,
  }) async {
    final module = await getDownloadClient();
    if (module != null) {
      return showModal(builder: (context) {
        if (module == LunaModule.SABNZBD) {
          return const SABnzbdRoute(showDrawer: false);
        }
        if (module == LunaModule.NZBGET) {
          return const NZBGetRoute(showDrawer: false);
        }
        return InvalidRoutePage();
      });
    }
  }
}
