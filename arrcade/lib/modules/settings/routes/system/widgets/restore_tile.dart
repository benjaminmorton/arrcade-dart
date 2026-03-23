import 'package:flutter/material.dart';

import 'package:arrcade/core.dart';
import 'package:arrcade/database/config.dart';
import 'package:arrcade/system/filesystem/file.dart';
import 'package:arrcade/system/filesystem/filesystem.dart';

class SettingsSystemBackupRestoreRestoreTile extends StatelessWidget {
  const SettingsSystemBackupRestoreRestoreTile({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LunaBlock(
      title: 'settings.RestoreFromDevice'.tr(),
      body: [TextSpan(text: 'settings.RestoreFromDeviceDescription'.tr())],
      trailing: const LunaIconButton(icon: Icons.download_rounded),
      onTap: () async => _restore(context),
    );
  }

  Future<void> _restore(BuildContext context) async {
    try {
      LunaFile? file = await LunaFileSystem().read(context, ['arrcade']);
      if (file != null) await _decryptBackup(context, file);
    } catch (error, stack) {
      LunaLogger().error('Failed to restore device backup', error, stack);
      showLunaErrorSnackBar(
        title: 'settings.RestoreFromCloudFailure'.tr(),
        error: error,
      );
    }
  }

  Future<void> _decryptBackup(
    BuildContext context,
    LunaFile file,
  ) async {
    String encrypted = String.fromCharCodes(file.data);
    try {
      await LunaConfig().import(context, encrypted);
      showLunaSuccessSnackBar(
        title: 'settings.RestoreFromCloudSuccess'.tr(),
        message: 'settings.RestoreFromCloudSuccessMessage'.tr(),
      );
    } catch (_) {
      showLunaErrorSnackBar(
        title: 'settings.RestoreFromCloudFailure'.tr(),
        message: 'arrcade.IncorrectEncryptionKey'.tr(),
        showButton: true,
        buttonText: 'arrcade.Retry'.tr(),
        buttonOnPressed: () async => _decryptBackup(context, file),
      );
    }
  }
}
