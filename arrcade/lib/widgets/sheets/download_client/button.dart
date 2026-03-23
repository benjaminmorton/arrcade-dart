import 'package:flutter/material.dart';
import 'package:arrcade/database/models/profile.dart';
import 'package:arrcade/widgets/sheets/download_client/sheet.dart';
import 'package:arrcade/widgets/ui.dart';

class DownloadClientButton extends StatelessWidget {
  const DownloadClientButton({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    if (_shouldShow) {
      return LunaIconButton.appBar(
        icon: LunaIcons.DOWNLOAD,
        onPressed: DownloadClientSheet().show,
      );
    }
    return const SizedBox();
  }

  bool get _shouldShow {
    final profile = LunaProfile.current;
    return profile.sabnzbdEnabled || profile.nzbgetEnabled;
  }
}
