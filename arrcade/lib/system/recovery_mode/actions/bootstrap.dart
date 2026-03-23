import 'package:flutter/material.dart';
import 'package:arrcade/main.dart';
import 'package:arrcade/system/recovery_mode/action_tile.dart';

class BootstrapTile extends RecoveryActionTile {
  const BootstrapTile({
    super.key,
    super.title = 'Bootstrap Arrcade',
    super.description = 'Run the bootstrap process and show any errors',
  });

  @override
  Future<void> action(BuildContext context) async {
    await bootstrap();
  }
}
